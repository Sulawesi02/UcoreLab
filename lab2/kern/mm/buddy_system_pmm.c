#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <buddy_system_pmm.h>

free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)
#define MAX_INIT_PAGES (1 << 14)  // 2^14 = 16384 页

static void
buddy_system_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

static void
buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);

    n = MAX_INIT_PAGES; // 限制最大分配的页数为 16384 页

    // 初始化每个页, 将其标记为未使用, 并将页面引用计数清零
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;// 将起始页的 property 设置为 n，表示这是一个大小为 n 页的空闲块
    SetPageProperty(base);// 标记 base 这个块为空闲块 
    nr_free += n;// 更新空闲页计数器
    if (list_empty(&free_list)) {
        // 将这个空闲块插入到 free_list 中
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
}

static size_t round_up_pow2(size_t n) {
    size_t size = 1;
    while (size < n) {
        size <<= 1;
    }
    return size;
}

static struct Page *
buddy_system_alloc_pages(size_t n) {
    assert(n > 0);
    n = round_up_pow2(n);// 将请求的块大小调整为大于等于 n 的最小的 2 的幂次方
    if (n > nr_free) {
        return NULL;// 如果请求的页数大于可用页数，返回 NULL
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // 遍历空闲块链表，查找第一个块大小大于等于n的空闲块
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            page = p;// 找到第一个块大小大于等于n的空闲块
            break;
        }
    }

    // 分裂空闲块
    if (page != NULL) {
        list_entry_t* prev = list_prev(&(page->page_link));// 找到 page 前面的块
        list_del(&(page->page_link));// 从空闲块链表中移除该空闲块

        // 持续分裂，直到获得足够大小的块
        while (page->property > n) {
            struct Page *p = page + (page->property >> 1);// 分裂当前空闲块成两个块
            p->property = page->property >> 1;// 设置 p 的大小为空闲块的一半
            SetPageProperty(p);// 标记 p 这个块为空闲块 
            list_add(prev, &(p->page_link));// 将 p 插入到空闲块链表中
            page->property >>= 1;// 将当前空闲块的大小减半
        }
        nr_free -= n;// 更新空闲页计数器
        ClearPageProperty(page);
    }
    return page;
}

static void
buddy_system_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    n = round_up_pow2(n);// 将请求的块大小调整为大于等于 n 的最小的 2 的幂次方
    
    // 遍历该块的每个页, 将其标记为未使用, 并将页面引用计数清零
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);// 页面引用计数清零 
    }
    base->property = n;// 将起始页的 property 设置为 n，表示这是一个大小为 n 页的空闲块
    SetPageProperty(base);// 标记 base 这个块为空闲块 
    nr_free += n;// 更新空闲页计数器

    // 将 base 插入到空闲块链表中
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }

    // 向前向后循环，尝试合并相邻的空闲块
    int merged = 1;  // 标记是否进行了合并
    while (merged) {
        merged = 0;
        // 检查前一块是否可以合并
        list_entry_t* le = list_prev(&(base->page_link));
        if (le != &free_list) {
            p = le2page(le, page_link);
            if (p + p->property == base && p->property == base->property) {// 前一空闲块和当前块大小相同
                p->property += base->property;
                ClearPageProperty(base);
                list_del(&(base->page_link));
                base = p;
                merged = 1;  // 标记为合并
            }
        }

        // 检查后一块是否可以合并
        le = list_next(&(base->page_link));
        if (le != &free_list) {
            p = le2page(le, page_link);
            if (base + base->property == p && base->property == p->property) {// 当前块和后一空闲块大小相同
                base->property += p->property;
                ClearPageProperty(p);
                list_del(&(p->page_link));
                merged = 1;  // 标记为合并
            }
        }
    }
}

static size_t
buddy_system_nr_free_pages(void) {
    return nr_free;
}

static void
basic_check(void) {
    cprintf("=============================基础测试开始=============================\n");
    int count = 0, total = 0;
    list_entry_t *le = &free_list;

    // 计算当前空闲块数目和空闲页数目
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    cprintf("空闲块数目为: %d\n", count);
    cprintf("空闲页数目为: %d\n", nr_free);

    // p0 请求 7 页
    cprintf("p0请求7页\n");
    struct Page *p0 = alloc_pages(7);
    assert(p0 != NULL);
    assert(!PageProperty(p0));
    cprintf("空闲页数目为: %d\n", nr_free);

    // p1 请求 14 页
    cprintf("p1请求14页\n");
    struct Page *p1 = alloc_pages(14);
    assert(p1 != NULL);
    assert(!PageProperty(p1));
    cprintf("空闲页数目为: %d\n", nr_free);

    // p2 请求 21 页
    cprintf("p2请求21页\n");
    struct Page *p2 = alloc_pages(21);
    assert(p2 != NULL);
    assert(!PageProperty(p2));
    cprintf("空闲页数目为: %d\n", nr_free);

    // 确保分配的页是不同的
    assert(p0 != p1 && p0 != p2 && p1 != p2);
    // 确保分配页的引用计数为 0
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    // 确保分配的页地址在物理内存范围内
    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    // 释放 p0
    free_pages(p0, 7);
    le = &free_list;
    count = 0, total = 0;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    cprintf("释放p0后，空闲块数目为: %d\n", count);
    cprintf("释放p0后，空闲页数目为: %d\n", total);

    // 释放 p1
    free_pages(p1, 14);
    le = &free_list;
    count = 0, total = 0;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    cprintf("释放p1后，空闲块数目为: %d\n", count);
    cprintf("释放p1后，空闲页数目为: %d\n", total);

    // 释放 p2
    free_pages(p2, 21);
    le = &free_list;
    count = 0, total = 0;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    cprintf("释放p2后，空闲块数目为: %d\n", count);
    cprintf("释放p2后，空闲页数目为: %d\n", total);

    // 清空空闲页，再尝试分配内存块
    unsigned int nr_free_store = nr_free;// 暂存当前的空闲页数目
    cprintf("清空空闲页！\n");
    nr_free = 0;
    // p3 请求 28 页
    cprintf("p4请求28页\n");
    struct Page *p3 = alloc_pages(28);
    assert(p3 == NULL);
    cprintf("分配失败，空闲页数目为: %d\n", nr_free);

    nr_free = nr_free_store;

    // // 暂存当前的空闲链表状态
    // list_entry_t free_list_store = free_list;
    // list_init(&free_list);
    // assert(list_empty(&free_list));

    // // 暂存当前的空闲页数目
    // unsigned int nr_free_store = nr_free;
    // nr_free = 0;

    // // 空闲链表为空时，分配应该返回 NULL
    // assert(alloc_page() == NULL);

    // // 释放之前分配的页面
    // free_page(p0);
    // free_page(p1);
    // free_page(p2);
    // assert(nr_free == 3);

    // // 再次分配，确保可以重新获得刚刚释放的页面
    // assert((p0 = alloc_page()) != NULL);
    // assert((p1 = alloc_page()) != NULL);
    // assert((p2 = alloc_page()) != NULL);

    // // 再次分配失败，因为没有剩余的空闲页
    // assert(alloc_page() == NULL);

    // // 测试单页释放后的行为
    // free_page(p0);
    // assert(!list_empty(&free_list)); // 释放后链表不应为空

    // struct Page *p;
    // // 再次分配应该得到 p0
    // assert((p = alloc_page()) == p0);
    // assert(alloc_page() == NULL);

    // // 测试空闲页数
    // assert(nr_free == 0);
    // free_list = free_list_store;
    // nr_free = nr_free_store;

    // // 恢复之前的空闲链表
    // free_page(p);
    // free_page(p1);
    // free_page(p2);
    cprintf("=============================基础测试完毕=============================\n");

}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, buddy_system_check functions!
static void
buddy_system_check(void) {
    basic_check();

    cprintf("=============================复杂测试开始=============================\n");
    int count = 0, total = 0;
    list_entry_t *le = &free_list;

    // 计算当前空闲块数目和空闲页数目
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    cprintf("空闲块数目为: %d\n", count);
    cprintf("空闲页数目为: %d\n", nr_free);

    // Step 1: 多次分配和释放，确保伙伴系统正常工作
    cprintf("-----------------------------Step 1: 多次分配和释放-------------------\n");
    struct Page *p0 = alloc_pages(32);  // 请求 32 页
    cprintf("p0请求32页，空闲页数目为: %d\n", nr_free);
    struct Page *p1 = alloc_pages(16);  // 请求 16 页
    cprintf("p1请求16页，空闲页数目为: %d\n", nr_free);
    struct Page *p2 = alloc_pages(8);   // 请求 8 页
    cprintf("p2请求8页，空闲页数目为: %d\n", nr_free);
    assert(p0 != NULL && p1 != NULL && p2 != NULL);
    assert(!PageProperty(p0) && !PageProperty(p1) && !PageProperty(p2));

    free_pages(p0, 32);  // 释放 32 页
    cprintf("释放 32 页成功，空闲页数目为: %d\n", nr_free);
    free_pages(p1, 16);  // 释放 16 页
    cprintf("释放 16 页成功，空闲页数目为: %d\n", nr_free);
    free_pages(p2, 8);   // 释放 8 页
    cprintf("释放 8 页成功，空闲页数目为: %d\n", nr_free);

    // Step 2: 边界条件测试 - 分配最大可用块
    cprintf("-----------------------------Step 2: 边界条件测试 - 分配最大可用块-----\n");
    struct Page *p3 = alloc_pages(MAX_INIT_PAGES);  // 请求最大块 16384 页
    assert(p3 != NULL);
    assert(!PageProperty(p3));
    cprintf("分配最大块成功，空闲页数目为: %d\n", nr_free);
    free_pages(p3, MAX_INIT_PAGES);  // 释放最大块
    cprintf("释放最大块成功，空闲页数目为: %d\n", nr_free);

    // Step 3: 边界条件测试 - 超出可用块请求
    cprintf("-----------------------------Step 3: 边界条件测试 - 超出可用块请求-----\n");
    struct Page *p4 = alloc_pages(MAX_INIT_PAGES + 1);  // 请求超过最大块
    assert(p4 == NULL);
    cprintf("分配超过最大块失败，空闲页数目为: %d\n", nr_free);

    // Step 4: 随机分配和释放测试
    cprintf("-----------------------------Step 4: 随机分配和释放测试---------------\n");
    struct Page *p5 = alloc_pages(3);   // 请求 3 页
    cprintf("p5请求32页，空闲页数目为: %d\n", nr_free);
    struct Page *p6 = alloc_pages(5);   // 请求 5 页
    cprintf("p6请求32页，空闲页数目为: %d\n", nr_free);
    struct Page *p7 = alloc_pages(7);   // 请求 7 页
    cprintf("p7请求32页，空闲页数目为: %d\n", nr_free);
    struct Page *p8 = alloc_pages(9);   // 请求 9 页
    cprintf("p8请求32页，空闲页数目为: %d\n", nr_free);
    assert(p5 != NULL && p6 != NULL && p7 != NULL && p8 != NULL);
    assert(!PageProperty(p5) && !PageProperty(p6) && !PageProperty(p7) && !PageProperty(p8));

    free_pages(p6, 5);   // 释放 5 页
    cprintf("释放 5 页成功，空闲页数目为: %d\n", nr_free);
    free_pages(p8, 9);   // 释放 9 页
    cprintf("释放 9 页成功，空闲页数目为: %d\n", nr_free);

    // 再次分配测试
    cprintf("重新分配测试\n");
    p6 = alloc_pages(5);  // 重新分配 5 页
    cprintf("p6请求32页，空闲页数目为: %d\n", nr_free);
    p8 = alloc_pages(9);  // 重新分配 9 页
    assert(p6 != NULL && p8 != NULL);
    cprintf("p8请求32页，空闲页数目为: %d\n", nr_free);
    cprintf("重新分配 5, 9 页成功，空闲页数目为: %d\n", nr_free);

    // 释放所有剩余的块
    free_pages(p5, 3);
    cprintf("释放 3 页成功，空闲页数目为: %d\n", nr_free);
    free_pages(p6, 5);
    cprintf("释放 5 页成功，空闲页数目为: %d\n", nr_free);
    free_pages(p7, 7);
    cprintf("释放 7 页成功，空闲页数目为: %d\n", nr_free);
    free_pages(p8, 9);
    cprintf("释放 9 页成功，空闲页数目为: %d\n", nr_free);

    cprintf("=============================复杂测试完毕=============================\n");
    // struct Page *p0 = alloc_pages(5), *p1, *p2;
    // assert(p0 != NULL);
    // assert(!PageProperty(p0));

    // list_entry_t free_list_store = free_list;
    // list_init(&free_list);
    // assert(list_empty(&free_list));
    // assert(alloc_page() == NULL);

    // unsigned int nr_free_store = nr_free;
    // nr_free = 0;

    // free_pages(p0 + 2, 3);
    // assert(alloc_pages(4) == NULL);
    // assert(PageProperty(p0 + 2) && p0[2].property == 3);
    // assert((p1 = alloc_pages(3)) != NULL);
    // assert(alloc_page() == NULL);
    // assert(p0 + 2 == p1);

    // p2 = p0 + 1;
    // free_page(p0);
    // free_pages(p1, 3);
    // assert(PageProperty(p0) && p0->property == 1);
    // assert(PageProperty(p1) && p1->property == 3);

    // assert((p0 = alloc_page()) == p2 - 1);
    // free_page(p0);
    // assert((p0 = alloc_pages(2)) == p2 + 1);

    // free_pages(p0, 2);
    // free_page(p2);

    // assert((p0 = alloc_pages(5)) != NULL);
    // assert(alloc_page() == NULL);

    // assert(nr_free == 0);
    // nr_free = nr_free_store;

    // free_list = free_list_store;
    // free_pages(p0, 5);

    // le = &free_list;
    // while ((le = list_next(le)) != &free_list) {
    //     struct Page *p = le2page(le, page_link);
    //     count --, total -= p->property;
    // }
    // assert(count == 0);
    // assert(total == 0);
}
//这个结构体在
const struct pmm_manager buddy_system_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_system_init,
    .init_memmap = buddy_system_init_memmap,
    .alloc_pages = buddy_system_alloc_pages,
    .free_pages = buddy_system_free_pages,
    .nr_free_pages = buddy_system_nr_free_pages,
    .check = buddy_system_check,
};

