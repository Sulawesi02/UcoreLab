## 1. 概述

Buddy System（伙伴系统）是一种内存管理算法，它通过将内存分割成大小为2的幂次方的块来管理内存。这种算法特别适用于那些需要频繁分配和释放不同大小内存块的系统。该算法通过分裂和合并内存块的方式处理内存分配和释放，保证内存碎片化程度较低，并且能够在内存不足的情况下迅速找到合适大小的块。
## 2. 设计目标

- 实现初始化函数，配置系统中的初始内存块。
- 实现内存分配和释放的核心算法，并确保能处理不同大小的内存请求。
- 支持内存块的合并与分裂操作。
- 提供充足的测试用例来验证算法的正确性。
## 3.数据结构
### 3.1 Page 结构体
```
struct Page {
    int ref;                        // 页框的引用计数
    uint64_t flags;                 // 描述页框状态的 64 位标志数组
    unsigned int property;          // 表示块的大小（空闲块的数量）
    list_entry_t page_link;         // 双向链表指针，用于将这个 Page 链接到空闲列表
};
```
`Page`结构体表示一个物理页面，其中`property`字段用于表示页面的大小，`page_link`用于将页面链接到空闲块链表中。
### 3.2 free_area_t
```
typedef struct {
    list_entry_t free_list;         // 空闲块链表的头
    unsigned int nr_free;           // 空闲页的数量
} free_area_t;
```
`free_area_t`结构体使用双向链表 `free_list` 来维护空闲块，通过 `nr_free` 记录空闲页的数量。
## 4.宏定义
```
#define MAX_INIT_PAGES (1 << 14)  // 2^14 = 16384 页
```
调用`cprintf`函数直接打印`nr_free`空闲页数目，我们发现值为31929，但显然不是一个2的幂次方项，所以我们调整最大空闲页数为常量$2^{14} = 16384$
## 5.算法实现
### 辅助函数
```
static size_t round_up_pow2(size_t n) {
    size_t size = 1;
    while (size < n) {
        size <<= 1;
    }
    return size;
}
```
用于将输入的 `n` 向上取整到最接近的 2 的幂次方。
### 5.1初始化
```
static void
buddy_system_init(void) {
    list_init(&free_list);
    nr_free = 0;
}
```
用于初始化空闲块链表和空闲页数。
### 5.2初始化内存映射
```
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
```
用于将指定基地址和页面数的内存块初始化为一个大的空闲块，并将其插入到 `free_list` 链表中。

在这个过程中，我们会手动限制最大分配的页数为 16384 页。
### 5.3内存分配
```
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
```
用于分配指定基地址和页面数的内存块。

- 将页面数向上取整到最接近的 2 的幂次方
- 遍历空闲块链表，找到第一个块大小大于等于调整后的页面数的空闲块
- 如果空闲块的大小大于请求的大小，则将该块分裂为两个块，直到空闲块的大小等于调整后的页面数。
### 5.4内存释放
```
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

    // 向前向后循环，尝试合并空闲块
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
```
用于释放指定基地址和页面数的内存块。

- 同样将页面数向上取整到最接近的 2 的幂次方，然后将释放的内存块标记为未使用，并将页面引用计数清零。
- 将 base 插入到空闲块链表中。
- 向前向后循环，尝试合并相邻的空闲块。如果当前块和前一空闲块或后一空闲块大小相同，就继续合并；否则，退出合并。
## 6. 接口
```
const struct pmm_manager buddy_system_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_system_init,
    .init_memmap = buddy_system_init_memmap,
    .alloc_pages = buddy_system_alloc_pages,
    .free_pages = buddy_system_free_pages,
    .nr_free_pages = buddy_system_nr_free_pages,
    .check = buddy_system_check,
};
```
提供给系统的接口，包括初始化、内存分配、内存释放、获取空闲页数和检查算法正确性。
## 7.测试样例
### 7.1基础测试
- 连续请求分配大小为7页、14页、21页的块，buddy_system会为其分配大小为8页、16页、32页的块。
- 释放大小为7页、14页、21页的块，buddy_system会在其基地址上释放大小为8页、16页、32页的块，并尝试合并能合并的空闲块。
- 清空空闲页计数，再尝试分配内存块，显示分配失败，空闲页数目为:0。

测试代码如下：
```
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

    // 清空空闲页计数，再尝试分配内存块
    unsigned int nr_free_store = nr_free;// 暂存当前的空闲页数目
    cprintf("清空空闲页！\n");
    nr_free = 0;
    // p3 请求 28 页
    cprintf("p4请求28页\n");
    struct Page *p3 = alloc_pages(28);
    assert(p3 == NULL);
    cprintf("分配失败，空闲页数目为: %d\n", nr_free);

    nr_free = nr_free_store;

    cprintf("=============================基础测试完毕=============================\n");
}
```

测试结果如下：
```
=============================基础测试开始=============================
空闲块数目为: 1
空闲页数目为: 16384
p0请求7页
空闲页数目为: 16376
p1请求14页
空闲页数目为: 16360
p2请求21页
空闲页数目为: 16328
释放p0后，空闲块数目为: 9
释放p0后，空闲页数目为: 16336
释放p1后，空闲块数目为: 9
释放p1后，空闲页数目为: 16352
释放p2后，空闲块数目为: 1
释放p2后，空闲页数目为: 16384
清空空闲页！
p4请求28页
分配失败，空闲页数目为: 0
=============================基础测试完毕=============================
```
### 7.2复杂测试
- Step 2：连续请求分配大小为32、16、8 页的块，再释放它们，检查伙伴系统能否正确处理链表。
- Step 3：测试分配最大可用块，确保系统在极端情况下可以正常分配。
- Step 4：尝试分配超过系统容量的块，确保在这种情况下，系统会返回 NULL。
- Step 5：随机分配多个小块，并随机释放部分块，随后重新分配，验证伙伴系统能否高效管理内存碎片。

测试代码如下：
```
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
}
```
测试结果如下：
```
=============================复杂测试开始=============================
空闲块数目为: 1
空闲页数目为: 16384
-----------------------------Step 1: 多次分配和释放-------------------
p0请求32页，空闲页数目为: 16352
p1请求16页，空闲页数目为: 16336
p2请求8页，空闲页数目为: 16328
释放 32 页成功，空闲页数目为: 16360
释放 16 页成功，空闲页数目为: 16376
释放 8 页成功，空闲页数目为: 16384
-----------------------------Step 2: 边界条件测试 - 分配最大可用块-----
分配最大块成功，空闲页数目为: 0
释放最大块成功，空闲页数目为: 16384
-----------------------------Step 3: 边界条件测试 - 超出可用块请求-----
分配超过最大块失败，空闲页数目为: 16384
-----------------------------Step 4: 随机分配和释放测试---------------
p5请求32页，空闲页数目为: 16380
p6请求32页，空闲页数目为: 16372
p7请求32页，空闲页数目为: 16364
p8请求32页，空闲页数目为: 16348
释放 5 页成功，空闲页数目为: 16356
释放 9 页成功，空闲页数目为: 16372
重新分配测试
p6请求32页，空闲页数目为: 16364
p8请求32页，空闲页数目为: 16348
重新分配 5, 9 页成功，空闲页数目为: 16348
释放 3 页成功，空闲页数目为: 16352
释放 5 页成功，空闲页数目为: 16360
释放 7 页成功，空闲页数目为: 16368
释放 9 页成功，空闲页数目为: 16384
=============================复杂测试完毕=============================
```