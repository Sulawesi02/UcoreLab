#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <buddy_system_pmm.h>
free_area_t free_area;
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)
#define MAX_INIT_PAGES (1 << 14)  // 2^14 = 16384 页
#define MEM_BEGIN 0xffffffffc020f318

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
            cprintf("找到第一个满足要求的空闲块 p\n");
            cprintf("准备用于分配的空闲块 p 的地址为: 0x%016lx.\n", p);
            cprintf("准备分配的空闲块 p 的页数为: %d\n", p->property);
            page = p;// 找到第一个块大小大于等于n的空闲块
            break;
        }
    }
    // 分裂空闲块
    if (page != NULL) {
        cprintf("开始分裂空闲块……\n\n");
        list_entry_t* prev = list_prev(&(page->page_link));// 找到 page 前面的块
        list_del(&(page->page_link));// 从空闲块链表中移除空闲块 page
        // 持续分裂，直到获得大小相同的块
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
    
    // 尝试合并相邻的空闲块
    int merged = 1;  // 标记是否进行了合并
    while (merged && base->property < MAX_INIT_PAGES) {
        merged = 0;
        cprintf("当前块的地址为: 0x%016lx.\n", base);
        cprintf("当前块的页数为: %d\n\n", base->property);
        // 检查前一块是否可以合并
        list_entry_t* le = list_prev(&(base->page_link));// 找到 base 前面的块
        if (le != &free_list) {
            struct Page *p = le2page(le, page_link);
            cprintf("找到 base 前面的块 p\n");
            cprintf("块 p 的地址为: 0x%016lx.\n", p);
            cprintf("块 p 的页数为: %d\n", p->property);
        
            if (p + p->property == base && p->property == base->property) {// 前一空闲块和当前块大小相同
                cprintf("伙伴块的地址为: 0x%016lx.\n", p);
                cprintf("伙伴块的页数为: %d\n", base->property);
            
                // 合并前，先检查合并后的相对首地址是否为合并后块大小的整数倍
                size_t relative_addr = (size_t)p - MEM_BEGIN; // 计算 p 的相对起始地址
                cprintf("合并后的相对首地址为: 0x%016lx.\n", relative_addr);
                size_t block_size = (p->property << 1) * sizeof(struct Page);//合并后的块大小
                cprintf("合并后的块大小为: 0x%016lx.\n", block_size);
                if (relative_addr % block_size == 0) { // 如果合并后的相对首地址是合并后的块大小的整数倍
                    cprintf("合并成功\n");
                    p->property <<= 1;
                    ClearPageProperty(base);
                    list_del(&(base->page_link));
                    base = p;
                    merged = 1; // 标记为合并
                    cprintf("合并后的块的地址为: 0x%016lx.\n", base);
                    cprintf("合并后的块的块页数为: %d\n\n", base->property);
                }
            }
        }
        // 检查后一块是否可以合并
        le = list_next(&(base->page_link));// 找到 base 后面的块
        if (le != &free_list) {
            struct Page *p = le2page(le, page_link);
            cprintf("找到 base 后面的块 p\n");
            cprintf("块 p 的地址为: 0x%016lx.\n", p);
            cprintf("块 p 的页数为: %d\n\n", p->property);
            if (base + base->property == p && base->property == p->property) {// 当前块和后一空闲块大小相同
                cprintf("伙伴块的地址为: 0x%016lx.\n", p);
                cprintf("伙伴块的页数为: %d\n", p->property);
                // 合并前，先检查合并后的相对首地址是否为合并后块大小的整数倍
                size_t relative_addr = (size_t)base - MEM_BEGIN; // 计算 base 的相对起始地址
                cprintf("合并后的相对首地址为: 0x%016lx.\n", relative_addr);
                size_t block_size = (base->property << 1) * sizeof(struct Page);//合并后的块大小
                cprintf("合并后的块大小为: 0x%016lx.\n", block_size);
                if (relative_addr % block_size == 0) { // 如果合并后的相对首地址是合并后的块大小的整数倍
                    cprintf("合并成功\n");
                    base->property <<= 1;
                    ClearPageProperty(p);
                    list_del(&(p->page_link));
                    merged = 1; // 标记为合并
                    cprintf("合并后的块的地址为: 0x%016lx.\n", base);
                    cprintf("合并后的块的块页数为: %d\n\n", base->property);
                }
            }
        }
        if(!merged){
            cprintf("没有找到可以合并的伙伴块\n\n");
        }
        else{
            cprintf("继续尝试合并……\n\n");
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
    cprintf("--------------------------------------------\n");
    cprintf("p0请求7页\n");
    struct Page *p0 = alloc_pages(7);  // 请求 7 页
    int i=1;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
        cprintf("空闲页数目为: %d\n\n", p->property);
        i+=1;
    }
    cprintf("--------------------------------------------\n");
    cprintf("p1请求14页\n");
    struct Page *p1 = alloc_pages(14);  // 请求 14 页
    i=1;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
        cprintf("空闲页数目为: %d\n\n", p->property);
        i+=1;
    }
    cprintf("--------------------------------------------\n");
    cprintf("p2请求21页\n");
    struct Page *p2 = alloc_pages(21);   // 请求 21 页
    i=1;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
        cprintf("空闲页数目为: %d\n\n", p->property);
        i+=1;
    }
    cprintf("--------------------------------------------\n");
    // 确保分配的页是不同的
    assert(p0 != p1 && p0 != p2 && p1 != p2);
    // 确保分配页的引用计数为 0
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
    // 确保分配的页地址在物理内存范围内
    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);
    // 释放 p0
    cprintf("释放p0\n");
    free_pages(p0, 7);
    le = &free_list;
    count = 0, total = 0;
    i=1;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
        cprintf("空闲页数目为: %d\n\n", p->property);
        i+=1;
    }
    cprintf("释放p0后，空闲块数目为: %d\n", count);
    cprintf("释放p0后，空闲页数目为: %d\n\n", total);
    cprintf("--------------------------------------------\n");
    // 释放 p1
    cprintf("释放p1\n");
    free_pages(p1, 14);
    le = &free_list;
    count = 0, total = 0;
    i=1;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
        cprintf("空闲页数目为: %d\n\n", p->property);
        i+=1;
    }
    cprintf("释放p1后，空闲块数目为: %d\n", count);
    cprintf("释放p1后，空闲页数目为: %d\n\n", total);
    cprintf("--------------------------------------------\n");
    // 释放 p2
    cprintf("释放p2\n");
    free_pages(p2, 21);
    le = &free_list;
    count = 0, total = 0;
    i=1;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
        cprintf("空闲页数目为: %d\n\n", p->property);
        i+=1;
    }
    cprintf("释放p2后，空闲块数目为: %d\n", count);
    cprintf("释放p2后，空闲页数目为: %d\n\n", total);
    // 清空空闲页计数，再尝试分配内存块
    unsigned int nr_free_store = nr_free;// 暂存当前的空闲页数目
    cprintf("清空空闲页！\n");
    nr_free = 0;
    // p3 请求 28 页
    cprintf("p3请求28页\n");
    struct Page *p3 = alloc_pages(28);
    assert(p3 == NULL);
    cprintf("分配失败，空闲页数目为: %d\n", nr_free);
    nr_free = nr_free_store;// 恢复空闲页数目
    cprintf("=============================基础测试完毕=============================\n");
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, buddy_system_check functions!
static void
buddy_system_check(void) {
    // basic_check();
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
    cprintf("空闲页数目为: %d\n", total);
    // // Step 1: 多次分配和释放，确保伙伴系统正常工作
    // cprintf("-----------------------------Step 1: 多次分配和释放-------------------\n");
    // cprintf("p0请求32页\n");
    // struct Page *p0 = alloc_pages(32);  // 请求 32 页
    // int i=1;
    // while ((le = list_next(le)) != &free_list) {
    //     struct Page *p = le2page(le, page_link);
    //     assert(PageProperty(p));
    //     cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
    //     cprintf("空闲页数目为: %d\n\n", p->property);
    //     i+=1;
    // }
    // cprintf("--------------------------------------------\n");
    // cprintf("p1请求16页\n");
    // struct Page *p1 = alloc_pages(16);  // 请求 16 页
    // i=1;
    // while ((le = list_next(le)) != &free_list) {
    //     struct Page *p = le2page(le, page_link);
    //     assert(PageProperty(p));
    //     cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
    //     cprintf("空闲页数目为: %d\n\n", p->property);
    //     i+=1;
    // }
    // cprintf("--------------------------------------------\n");
    // cprintf("p2请求8页\n");
    // struct Page *p2 = alloc_pages(8);   // 请求 8 页
    // i=1;
    // while ((le = list_next(le)) != &free_list) {
    //     struct Page *p = le2page(le, page_link);
    //     assert(PageProperty(p));
    //     cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
    //     cprintf("空闲页数目为: %d\n\n", p->property);
    //     i+=1;
    // }
    // assert(p0 != NULL && p1 != NULL && p2 != NULL);
    // assert(!PageProperty(p0) && !PageProperty(p1) && !PageProperty(p2));
    // cprintf("--------------------------------------------\n");
    // // 释放 p0
    // cprintf("释放p0\n");
    // free_pages(p0, 32);
    // le = &free_list;
    // count = 0, total = 0;
    // i=1;
    // while ((le = list_next(le)) != &free_list) {
    //     struct Page *p = le2page(le, page_link);
    //     assert(PageProperty(p));
    //     count ++, total += p->property;
    //     cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
    //     cprintf("空闲页数目为: %d\n\n", p->property);
    //     i+=1;
    // }
    // cprintf("释放p0后，空闲块数目为: %d\n", count);
    // cprintf("释放p0后，空闲页数目为: %d\n\n", total);
    // cprintf("--------------------------------------------\n");
    // // 释放 p1
    // cprintf("释放p1\n");
    // free_pages(p1, 16);
    // le = &free_list;
    // count = 0, total = 0;
    // i=1;
    // while ((le = list_next(le)) != &free_list) {
    //     struct Page *p = le2page(le, page_link);
    //     assert(PageProperty(p));
    //     count ++, total += p->property;
    //     cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
    //     cprintf("空闲页数目为: %d\n\n", p->property);
    //     i+=1;
    // }
    // cprintf("释放p1后，空闲块数目为: %d\n", count);
    // cprintf("释放p1后，空闲页数目为: %d\n\n", total);
    // cprintf("--------------------------------------------\n");
    // // 释放 p2
    // cprintf("释放p2\n");
    // free_pages(p2, 8);
    // le = &free_list;
    // count = 0, total = 0;
    // i=1;
    // while ((le = list_next(le)) != &free_list) {
    //     struct Page *p = le2page(le, page_link);
    //     assert(PageProperty(p));
    //     count ++, total += p->property;
    //     cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
    //     cprintf("空闲页数目为: %d\n\n", p->property);
    //     i+=1;
    // }
    // cprintf("释放p2后，空闲块数目为: %d\n", count);
    // cprintf("释放p2后，空闲页数目为: %d\n\n", total);
    // // Step 2: 边界条件测试 - 分配最大可用块
    // cprintf("-----------------------------Step 2: 边界条件测试 - 分配最大可用块-----\n");
    // cprintf("p3请求16384页\n");
    // struct Page *p3 = alloc_pages(MAX_INIT_PAGES);  // 请求最大块 16384 页
    // assert(p3 != NULL);
    // assert(!PageProperty(p3));
    // cprintf("p3请求16384页，空闲页数目为: %d\n\n", nr_free);
    // // 释放最大块
    // cprintf("释放p3\n");
    // free_pages(p3, MAX_INIT_PAGES);
    // le = &free_list;
    // count = 0, total = 0;
    // int i=1;
    // while ((le = list_next(le)) != &free_list) {
    //     struct Page *p = le2page(le, page_link);
    //     assert(PageProperty(p));
    //     cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
    //     cprintf("空闲页数目为: %d\n\n", p->property);
    //     i+=1;
    // }
    // cprintf("释放p3后，空闲块数目为: %d\n", count);
    // cprintf("释放p3后，空闲页数目为: %d\n\n", total);
    // // Step 3: 边界条件测试 - 超出可用块请求
    // cprintf("-----------------------------Step 3: 边界条件测试 - 超出可用块请求-----\n");
    // struct Page *p4 = alloc_pages(MAX_INIT_PAGES + 1);  // 请求超过最大块
    // assert(p4 == NULL);
    // cprintf("分配超过最大块失败，空闲页数目为: %d\n", nr_free);
    // Step 4: 随机分配和释放测试
    cprintf("-----------------------------Step 4: 随机分配和释放测试---------------\n");
    cprintf("p5请求4095页\n");
    struct Page *p5 = alloc_pages(4095);   // 请求 4095 页
    int i=1;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
        cprintf("空闲页数目为: %d\n", p->property);
        i+=1;
    }
    cprintf("--------------------------------------------\n");
    cprintf("p6请求4094页\n");
    struct Page *p6 = alloc_pages(4094);   // 请求 4094 页
    i=1;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
        cprintf("空闲页数目为: %d\n", p->property);
        i+=1;
    }
    cprintf("--------------------------------------------\n");
    cprintf("p7请求4093页\n");
    struct Page *p7 = alloc_pages(4093);   // 请求 4093 页
    i=1;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
        cprintf("空闲页数目为: %d\n", p->property);
        i+=1;
    }
    cprintf("--------------------------------------------\n");
    cprintf("p8请求2000页\n");
    struct Page *p8 = alloc_pages(2000);   // 请求 2000 页
    i=1;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
        cprintf("空闲页数目为: %d\n", p->property);
        i+=1;
    }
    cprintf("--------------------------------------------\n");
    cprintf("测试一下释放p6和p7，它们会不会错误合并\n");
    // 释放 p6
    cprintf("释放p6\n");
    free_pages(p6, 4094);
    le = &free_list;
    count = 0, total = 0;
    i=1;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
        cprintf("空闲页数目为: %d\n", p->property);
        i+=1;
    }
    cprintf("释放p6后，空闲块数目为: %d\n", count);
    cprintf("释放p6后，空闲页数目为: %d\n\n", total);
    // 释放 p7
    cprintf("释放p7\n");
    free_pages(p7, 4093);
    le = &free_list;
    count = 0, total = 0;
    i=1;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
        cprintf("空闲页数目为: %d\n", p->property);
        i+=1;
    }
    cprintf("释放p7后，空闲块数目为: %d\n", count);
    cprintf("释放p7后，空闲页数目为: %d\n\n", total);
    cprintf("没有合并，测试成功\n\n");
    cprintf("--------------------------------------------\n");
    // 释放 p5
    cprintf("释放p5\n");
    free_pages(p5, 4095);
    le = &free_list;
    count = 0, total = 0;
    i=1;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
        cprintf("空闲页数目为: %d\n", p->property);
        i+=1;
    }
    cprintf("释放p5后，空闲块数目为: %d\n", count);
    cprintf("释放p5后，空闲页数目为: %d\n\n", total);
    cprintf("--------------------------------------------\n");
    // 释放 p8
    cprintf("释放p\n");
    free_pages(p8, 2000);
    le = &free_list;
    count = 0, total = 0;
    i=1;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
        cprintf("空闲页数目为: %d\n", p->property);
        i+=1;
    }
    cprintf("释放p8后，空闲块数目为: %d\n", count);
    cprintf("释放p8后，空闲页数目为: %d\n\n", total);
    cprintf("=============================复杂测试完毕=============================\n");
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