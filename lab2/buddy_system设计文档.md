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
### 3.2 free_area_t 结构体
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
#define MEM_BEGIN 0xffffffffc020f318
```
调用`cprintf`函数直接打印`nr_free`空闲页数目，我们发现值为31929，但显然不是一个2的幂次方项，所以我们规定最大空闲页数为常量$2^{14} = 16384$

`MEM_BEGIN`表示内存的起始地址。
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
用于将指定页面数的内存块初始化为一个大的空闲块，并将其插入到 `free_list` 链表中。

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
```
用于分配指定页面数的内存块。

- 将页面数向上取整到最接近的 2 的幂次方。
- 遍历空闲块链表，找到第一个块大小大于等于调整后的页面数的空闲块
- 如果空闲块的大小大于调整后的页面数，则将该块分裂为两个块，将多余的页面作为新的空闲块重新插入到空闲块链表中，直到空闲块的大小等于调整后的页面数。
- 更新空闲页计数器，调用 `ClearPageProperty(page)` 表示该块已经分配，不再是空闲块。
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
```
用于释放指定页面数的内存块。

- 同样将页面数向上取整到最接近的 2 的幂次方
- 遍历该块的每个页，将其标记为未使用，并将页面引用计数清零。
- 将起始页的 `property` 设置为 `n`，表示这是一个大小为 `n` 页的空闲块。调用 `SetPageProperty` 来标记 base 这个块为空闲块，并更新空闲页计数器。
- 将 base 这个块添加到空闲块链表中。
- 向前向后循环，尝试合并相邻的空闲块。如果当前块和前一空闲块或后一空闲块大小相同，并且合并后的相对首地址是合并后的块大小的整数倍，就进行合并；否则，退出合并。

> 我觉得buddy_system算法设计的最难点就在于合并的处理。用双向链表处理内存分配、内存释放都很容易，但处理合并较为困难。例如分配了四个块（见复杂测试4），要释放中间的两个块，如果仅仅判断是否相邻、块大小是否相等，就进行合并，显然会违反二叉树结构的定义。最终我发现，只要在合并条件里加上合并后的相对首地址是否是合并后的块大小的整数倍，就能解决问题（这实际上是在检查合并后的块是否满足buddy_system的二叉树结构）。下面我会讲解一下这种方法蕴含的逻辑。
> 
> 合并操作实际上是在二叉树结构的同一层节点上进行的操作。假设我们有4个大小为0x1000的空闲块，它们的相对首地址分别是0x0000、0x1000、0x2000、0x3000。如果要合并0x1000、0x2000，那么合并后的相对首地址是0x1000，块大小为0x2000。而0x1000不是0x2000的整数倍，所以这两个块不能合并。
> 
> 知道了原理，我们就要开始构造合并后的相对首地址和合并后的块大小。我们定义了一个宏`MEM_BEGIN`（实际上是`0xffffffffc020f318`）表示内存的起始地址，让`base`等于要合并的两个块中地址较小的那一个，再减去`MEM_BEGIN`就能得到相对首地址。因为相对首地址是用字节表示大小，那么计算合并后的块大小也得表示为字节。`base->property`表示`base`的页数，左移一位（`<< 1`）就能得到合并后的块的页数，再乘上页结构体的大小`sizeof(struct Page)`就能得到合并后的块大小。而在合并条件里加上取模运算检验一下余数，就能实现合并的判断了 。

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
- 清空空闲页计数，再尝试分配内存块，显示分配失败，空闲页数目为: 0

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
```

测试结果如下：
```
=============================基础测试开始=============================
空闲块数目为: 1
空闲页数目为: 16384
--------------------------------------------
p0请求7页
找到第一个满足要求的空闲块 p
准备用于分配的空闲块 p 的地址为: 0xffffffffc020f318.
准备分配的空闲块 p 的页数为: 16384
开始分裂空闲块……

空闲块1的虚拟地址为:0xffffffffc020f458.
空闲页数目为: 8

空闲块2的虚拟地址为:0xffffffffc020f598.
空闲页数目为: 16

空闲块3的虚拟地址为:0xffffffffc020f818.
空闲页数目为: 32

空闲块4的虚拟地址为:0xffffffffc020fd18.
空闲页数目为: 64

空闲块5的虚拟地址为:0xffffffffc0210718.
空闲页数目为: 128

空闲块6的虚拟地址为:0xffffffffc0211b18.
空闲页数目为: 256

空闲块7的虚拟地址为:0xffffffffc0214318.
空闲页数目为: 512

空闲块8的虚拟地址为:0xffffffffc0219318.
空闲页数目为: 1024

空闲块9的虚拟地址为:0xffffffffc0223318.
空闲页数目为: 2048

空闲块10的虚拟地址为:0xffffffffc0237318.
空闲页数目为: 4096

空闲块11的虚拟地址为:0xffffffffc025f318.
空闲页数目为: 8192

--------------------------------------------
p1请求14页
找到第一个满足要求的空闲块 p
准备用于分配的空闲块 p 的地址为: 0xffffffffc020f598.
准备分配的空闲块 p 的页数为: 16
开始分裂空闲块……

空闲块1的虚拟地址为:0xffffffffc020f458.
空闲页数目为: 8

空闲块2的虚拟地址为:0xffffffffc020f818.
空闲页数目为: 32

空闲块3的虚拟地址为:0xffffffffc020fd18.
空闲页数目为: 64

空闲块4的虚拟地址为:0xffffffffc0210718.
空闲页数目为: 128

空闲块5的虚拟地址为:0xffffffffc0211b18.
空闲页数目为: 256

空闲块6的虚拟地址为:0xffffffffc0214318.
空闲页数目为: 512

空闲块7的虚拟地址为:0xffffffffc0219318.
空闲页数目为: 1024

空闲块8的虚拟地址为:0xffffffffc0223318.
空闲页数目为: 2048

空闲块9的虚拟地址为:0xffffffffc0237318.
空闲页数目为: 4096

空闲块10的虚拟地址为:0xffffffffc025f318.
空闲页数目为: 8192

--------------------------------------------
p2请求21页
找到第一个满足要求的空闲块 p
准备用于分配的空闲块 p 的地址为: 0xffffffffc020f818.
准备分配的空闲块 p 的页数为: 32
开始分裂空闲块……

空闲块1的虚拟地址为:0xffffffffc020f458.
空闲页数目为: 8

空闲块2的虚拟地址为:0xffffffffc020fd18.
空闲页数目为: 64

空闲块3的虚拟地址为:0xffffffffc0210718.
空闲页数目为: 128

空闲块4的虚拟地址为:0xffffffffc0211b18.
空闲页数目为: 256

空闲块5的虚拟地址为:0xffffffffc0214318.
空闲页数目为: 512

空闲块6的虚拟地址为:0xffffffffc0219318.
空闲页数目为: 1024

空闲块7的虚拟地址为:0xffffffffc0223318.
空闲页数目为: 2048

空闲块8的虚拟地址为:0xffffffffc0237318.
空闲页数目为: 4096

空闲块9的虚拟地址为:0xffffffffc025f318.
空闲页数目为: 8192

--------------------------------------------
释放p0
当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 8

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc020f458.
块 p 的页数为: 8

伙伴块的地址为: 0xffffffffc020f458.
伙伴块的页数为: 8
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000000280.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 16

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 16

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc020fd18.
块 p 的页数为: 64

没有找到可以合并的伙伴块

空闲块1的虚拟地址为:0xffffffffc020f318.
空闲页数目为: 16

空闲块2的虚拟地址为:0xffffffffc020fd18.
空闲页数目为: 64

空闲块3的虚拟地址为:0xffffffffc0210718.
空闲页数目为: 128

空闲块4的虚拟地址为:0xffffffffc0211b18.
空闲页数目为: 256

空闲块5的虚拟地址为:0xffffffffc0214318.
空闲页数目为: 512

空闲块6的虚拟地址为:0xffffffffc0219318.
空闲页数目为: 1024

空闲块7的虚拟地址为:0xffffffffc0223318.
空闲页数目为: 2048

空闲块8的虚拟地址为:0xffffffffc0237318.
空闲页数目为: 4096

空闲块9的虚拟地址为:0xffffffffc025f318.
空闲页数目为: 8192

释放p0后，空闲块数目为: 9
释放p0后，空闲页数目为: 16336

--------------------------------------------
释放p1
当前块的地址为: 0xffffffffc020f598.
当前块的页数为: 16

找到 base 前面的块 p
块 p 的地址为: 0xffffffffc020f318.
块 p 的页数为: 16
伙伴块的地址为: 0xffffffffc020f318.
伙伴块的页数为: 16
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000000500.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 32

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc020fd18.
块 p 的页数为: 64

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 32

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc020fd18.
块 p 的页数为: 64

没有找到可以合并的伙伴块

空闲块1的虚拟地址为:0xffffffffc020f318.
空闲页数目为: 32

空闲块2的虚拟地址为:0xffffffffc020fd18.
空闲页数目为: 64

空闲块3的虚拟地址为:0xffffffffc0210718.
空闲页数目为: 128

空闲块4的虚拟地址为:0xffffffffc0211b18.
空闲页数目为: 256

空闲块5的虚拟地址为:0xffffffffc0214318.
空闲页数目为: 512

空闲块6的虚拟地址为:0xffffffffc0219318.
空闲页数目为: 1024

空闲块7的虚拟地址为:0xffffffffc0223318.
空闲页数目为: 2048

空闲块8的虚拟地址为:0xffffffffc0237318.
空闲页数目为: 4096

空闲块9的虚拟地址为:0xffffffffc025f318.
空闲页数目为: 8192

释放p1后，空闲块数目为: 9
释放p1后，空闲页数目为: 16352

--------------------------------------------
释放p2
当前块的地址为: 0xffffffffc020f818.
当前块的页数为: 32

找到 base 前面的块 p
块 p 的地址为: 0xffffffffc020f318.
块 p 的页数为: 32
伙伴块的地址为: 0xffffffffc020f318.
伙伴块的页数为: 32
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000000a00.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 64

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc020fd18.
块 p 的页数为: 64

伙伴块的地址为: 0xffffffffc020fd18.
伙伴块的页数为: 64
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000001400.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 128

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 128

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc0210718.
块 p 的页数为: 128

伙伴块的地址为: 0xffffffffc0210718.
伙伴块的页数为: 128
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000002800.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 256

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 256

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc0211b18.
块 p 的页数为: 256

伙伴块的地址为: 0xffffffffc0211b18.
伙伴块的页数为: 256
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000005000.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 512

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 512

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc0214318.
块 p 的页数为: 512

伙伴块的地址为: 0xffffffffc0214318.
伙伴块的页数为: 512
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x000000000000a000.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 1024

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 1024

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc0219318.
块 p 的页数为: 1024

伙伴块的地址为: 0xffffffffc0219318.
伙伴块的页数为: 1024
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000014000.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 2048

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 2048

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc0223318.
块 p 的页数为: 2048

伙伴块的地址为: 0xffffffffc0223318.
伙伴块的页数为: 2048
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000028000.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 4096

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 4096

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc0237318.
块 p 的页数为: 4096

伙伴块的地址为: 0xffffffffc0237318.
伙伴块的页数为: 4096
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000050000.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 8192

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 8192

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc025f318.
块 p 的页数为: 8192

伙伴块的地址为: 0xffffffffc025f318.
伙伴块的页数为: 8192
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x00000000000a0000.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 16384

继续尝试合并……

空闲块1的虚拟地址为:0xffffffffc020f318.
空闲页数目为: 16384

释放p2后，空闲块数目为: 1
释放p2后，空闲页数目为: 16384

清空空闲页！
p3请求28页
分配失败，空闲页数目为: 0
=============================基础测试完毕=============================

```
### 7.2复杂测试
- Step 1：连续请求分配大小为32、16、8 页的块，再释放它们，检查伙伴系统能否正确处理。
- Step 2：测试分配最大可用块，确保系统在极端情况下可以正常分配。
- Step 3：尝试分配超过系统容量的块，确保在这种情况下，系统会返回 NULL。
- Step 4：随机分配多个大块，释放部分块，测试会不会出现错误合并。

测试代码如下：
```
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

        // Step 1: 多次分配和释放，确保伙伴系统正常工作
        cprintf("-----------------------------Step 1: 多次分配和释放-------------------\n");
        cprintf("p0请求32页\n");
        struct Page *p0 = alloc_pages(32);  // 请求 32 页

        int i=1;
        while ((le = list_next(le)) != &free_list) {
            struct Page *p = le2page(le, page_link);
            assert(PageProperty(p));
            cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
            cprintf("空闲页数目为: %d\n\n", p->property);
            i+=1;
        }

        cprintf("--------------------------------------------\n");

        cprintf("p1请求16页\n");
        struct Page *p1 = alloc_pages(16);  // 请求 16 页

        i=1;
        while ((le = list_next(le)) != &free_list) {
            struct Page *p = le2page(le, page_link);
            assert(PageProperty(p));
            cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
            cprintf("空闲页数目为: %d\n\n", p->property);
            i+=1;
        }

        cprintf("--------------------------------------------\n");

        cprintf("p2请求8页\n");
        struct Page *p2 = alloc_pages(8);   // 请求 8 页

        i=1;
        while ((le = list_next(le)) != &free_list) {
            struct Page *p = le2page(le, page_link);
            assert(PageProperty(p));
            cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
            cprintf("空闲页数目为: %d\n\n", p->property);
            i+=1;
        }

        assert(p0 != NULL && p1 != NULL && p2 != NULL);
        assert(!PageProperty(p0) && !PageProperty(p1) && !PageProperty(p2));

        cprintf("--------------------------------------------\n");

        // 释放 p0
        cprintf("释放p0\n");
        free_pages(p0, 32);
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
        free_pages(p1, 16);
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
        free_pages(p2, 8);
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

        // Step 2: 边界条件测试 - 分配最大可用块
        cprintf("-----------------------------Step 2: 边界条件测试 - 分配最大可用块-----\n");
        cprintf("p3请求16384页\n");
        struct Page *p3 = alloc_pages(MAX_INIT_PAGES);  // 请求最大块 16384 页
        assert(p3 != NULL);
        assert(!PageProperty(p3));
        cprintf("p3请求16384页，空闲页数目为: %d\n\n", nr_free);

        // 释放最大块
        cprintf("释放p3\n");
        free_pages(p3, MAX_INIT_PAGES);
        le = &free_list;
        count = 0, total = 0;

        int i=1;
        while ((le = list_next(le)) != &free_list) {
            struct Page *p = le2page(le, page_link);
            assert(PageProperty(p));
            cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
            cprintf("空闲页数目为: %d\n\n", p->property);
            i+=1;
        }

        cprintf("释放p3后，空闲块数目为: %d\n", count);
        cprintf("释放p3后，空闲页数目为: %d\n\n", total);

        // Step 3: 边界条件测试 - 超出可用块请求
        cprintf("-----------------------------Step 3: 边界条件测试 - 超出可用块请求-----\n");
        struct Page *p4 = alloc_pages(MAX_INIT_PAGES + 1);  // 请求超过最大块
        assert(p4 == NULL);
        cprintf("分配超过最大块失败，空闲页数目为: %d\n", nr_free);

        Step 4: 随机分配和释放测试
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

```
测试结果如下：
```
=============================复杂测试开始=============================
空闲块数目为: 1
空闲页数目为: 16384
-----------------------------Step 1: 多次分配和释放-------------------
p0请求32页
找到第一个满足要求的空闲块 p
准备用于分配的空闲块 p 的地址为: 0xffffffffc020f318.
准备分配的空闲块 p 的页数为: 16384
开始分裂空闲块……

空闲块1的虚拟地址为:0xffffffffc020f818.
空闲页数目为: 32

空闲块2的虚拟地址为:0xffffffffc020fd18.
空闲页数目为: 64

空闲块3的虚拟地址为:0xffffffffc0210718.
空闲页数目为: 128

空闲块4的虚拟地址为:0xffffffffc0211b18.
空闲页数目为: 256

空闲块5的虚拟地址为:0xffffffffc0214318.
空闲页数目为: 512

空闲块6的虚拟地址为:0xffffffffc0219318.
空闲页数目为: 1024

空闲块7的虚拟地址为:0xffffffffc0223318.
空闲页数目为: 2048

空闲块8的虚拟地址为:0xffffffffc0237318.
空闲页数目为: 4096

空闲块9的虚拟地址为:0xffffffffc025f318.
空闲页数目为: 8192

--------------------------------------------
p1请求16页
找到第一个满足要求的空闲块 p
准备用于分配的空闲块 p 的地址为: 0xffffffffc020f818.
准备分配的空闲块 p 的页数为: 32
开始分裂空闲块……

空闲块1的虚拟地址为:0xffffffffc020fa98.
空闲页数目为: 16

空闲块2的虚拟地址为:0xffffffffc020fd18.
空闲页数目为: 64

空闲块3的虚拟地址为:0xffffffffc0210718.
空闲页数目为: 128

空闲块4的虚拟地址为:0xffffffffc0211b18.
空闲页数目为: 256

空闲块5的虚拟地址为:0xffffffffc0214318.
空闲页数目为: 512

空闲块6的虚拟地址为:0xffffffffc0219318.
空闲页数目为: 1024

空闲块7的虚拟地址为:0xffffffffc0223318.
空闲页数目为: 2048

空闲块8的虚拟地址为:0xffffffffc0237318.
空闲页数目为: 4096

空闲块9的虚拟地址为:0xffffffffc025f318.
空闲页数目为: 8192

--------------------------------------------
p2请求8页
找到第一个满足要求的空闲块 p
准备用于分配的空闲块 p 的地址为: 0xffffffffc020fa98.
准备分配的空闲块 p 的页数为: 16
开始分裂空闲块……

空闲块1的虚拟地址为:0xffffffffc020fbd8.
空闲页数目为: 8

空闲块2的虚拟地址为:0xffffffffc020fd18.
空闲页数目为: 64

空闲块3的虚拟地址为:0xffffffffc0210718.
空闲页数目为: 128

空闲块4的虚拟地址为:0xffffffffc0211b18.
空闲页数目为: 256

空闲块5的虚拟地址为:0xffffffffc0214318.
空闲页数目为: 512

空闲块6的虚拟地址为:0xffffffffc0219318.
空闲页数目为: 1024

空闲块7的虚拟地址为:0xffffffffc0223318.
空闲页数目为: 2048

空闲块8的虚拟地址为:0xffffffffc0237318.
空闲页数目为: 4096

空闲块9的虚拟地址为:0xffffffffc025f318.
空闲页数目为: 8192

--------------------------------------------
释放p0
当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 32

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc020fbd8.
块 p 的页数为: 8

没有找到可以合并的伙伴块

空闲块1的虚拟地址为:0xffffffffc020f318.
空闲页数目为: 32

空闲块2的虚拟地址为:0xffffffffc020fbd8.
空闲页数目为: 8

空闲块3的虚拟地址为:0xffffffffc020fd18.
空闲页数目为: 64

空闲块4的虚拟地址为:0xffffffffc0210718.
空闲页数目为: 128

空闲块5的虚拟地址为:0xffffffffc0211b18.
空闲页数目为: 256

空闲块6的虚拟地址为:0xffffffffc0214318.
空闲页数目为: 512

空闲块7的虚拟地址为:0xffffffffc0219318.
空闲页数目为: 1024

空闲块8的虚拟地址为:0xffffffffc0223318.
空闲页数目为: 2048

空闲块9的虚拟地址为:0xffffffffc0237318.
空闲页数目为: 4096

空闲块10的虚拟地址为:0xffffffffc025f318.
空闲页数目为: 8192

释放p0后，空闲块数目为: 10
释放p0后，空闲页数目为: 16360

--------------------------------------------
释放p1
当前块的地址为: 0xffffffffc020f818.
当前块的页数为: 16

找到 base 前面的块 p
块 p 的地址为: 0xffffffffc020f318.
块 p 的页数为: 32
找到 base 后面的块 p
块 p 的地址为: 0xffffffffc020fbd8.
块 p 的页数为: 8

没有找到可以合并的伙伴块

空闲块1的虚拟地址为:0xffffffffc020f318.
空闲页数目为: 32

空闲块2的虚拟地址为:0xffffffffc020f818.
空闲页数目为: 16

空闲块3的虚拟地址为:0xffffffffc020fbd8.
空闲页数目为: 8

空闲块4的虚拟地址为:0xffffffffc020fd18.
空闲页数目为: 64

空闲块5的虚拟地址为:0xffffffffc0210718.
空闲页数目为: 128

空闲块6的虚拟地址为:0xffffffffc0211b18.
空闲页数目为: 256

空闲块7的虚拟地址为:0xffffffffc0214318.
空闲页数目为: 512

空闲块8的虚拟地址为:0xffffffffc0219318.
空闲页数目为: 1024

空闲块9的虚拟地址为:0xffffffffc0223318.
空闲页数目为: 2048

空闲块10的虚拟地址为:0xffffffffc0237318.
空闲页数目为: 4096

空闲块11的虚拟地址为:0xffffffffc025f318.
空闲页数目为: 8192

释放p1后，空闲块数目为: 11
释放p1后，空闲页数目为: 16376

--------------------------------------------
释放p2
当前块的地址为: 0xffffffffc020fa98.
当前块的页数为: 8

找到 base 前面的块 p
块 p 的地址为: 0xffffffffc020f818.
块 p 的页数为: 16
找到 base 后面的块 p
块 p 的地址为: 0xffffffffc020fbd8.
块 p 的页数为: 8

伙伴块的地址为: 0xffffffffc020fbd8.
伙伴块的页数为: 8
合并后的相对首地址为: 0x0000000000000780.
合并后的块大小为: 0x0000000000000280.
合并成功
合并后的块的地址为: 0xffffffffc020fa98.
合并后的块的块页数为: 16

继续尝试合并……

当前块的地址为: 0xffffffffc020fa98.
当前块的页数为: 16

找到 base 前面的块 p
块 p 的地址为: 0xffffffffc020f818.
块 p 的页数为: 16
伙伴块的地址为: 0xffffffffc020f818.
伙伴块的页数为: 16
合并后的相对首地址为: 0x0000000000000500.
合并后的块大小为: 0x0000000000000500.
合并成功
合并后的块的地址为: 0xffffffffc020f818.
合并后的块的块页数为: 32

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc020fd18.
块 p 的页数为: 64

继续尝试合并……

当前块的地址为: 0xffffffffc020f818.
当前块的页数为: 32

找到 base 前面的块 p
块 p 的地址为: 0xffffffffc020f318.
块 p 的页数为: 32
伙伴块的地址为: 0xffffffffc020f318.
伙伴块的页数为: 32
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000000a00.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 64

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc020fd18.
块 p 的页数为: 64

伙伴块的地址为: 0xffffffffc020fd18.
伙伴块的页数为: 64
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000001400.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 128

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 128

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc0210718.
块 p 的页数为: 128

伙伴块的地址为: 0xffffffffc0210718.
伙伴块的页数为: 128
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000002800.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 256

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 256

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc0211b18.
块 p 的页数为: 256

伙伴块的地址为: 0xffffffffc0211b18.
伙伴块的页数为: 256
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000005000.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 512

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 512

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc0214318.
块 p 的页数为: 512

伙伴块的地址为: 0xffffffffc0214318.
伙伴块的页数为: 512
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x000000000000a000.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 1024

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 1024

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc0219318.
块 p 的页数为: 1024

伙伴块的地址为: 0xffffffffc0219318.
伙伴块的页数为: 1024
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000014000.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 2048

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 2048

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc0223318.
块 p 的页数为: 2048

伙伴块的地址为: 0xffffffffc0223318.
伙伴块的页数为: 2048
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000028000.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 4096

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 4096

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc0237318.
块 p 的页数为: 4096

伙伴块的地址为: 0xffffffffc0237318.
伙伴块的页数为: 4096
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000050000.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 8192

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 8192

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc025f318.
块 p 的页数为: 8192

伙伴块的地址为: 0xffffffffc025f318.
伙伴块的页数为: 8192
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x00000000000a0000.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 16384

继续尝试合并……

空闲块1的虚拟地址为:0xffffffffc020f318.
空闲页数目为: 16384

释放p2后，空闲块数目为: 1
释放p2后，空闲页数目为: 16384
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
-----------------------------Step 2: 边界条件测试 - 分配最大可用块-----
p3请求16384页
找到第一个满足要求的空闲块 p
准备用于分配的空闲块 p 的地址为: 0xffffffffc020f318.
准备分配的空闲块 p 的页数为: 16384
开始分裂空闲块……

p3请求16384页，空闲页数目为: 0

释放p3
空闲块1的虚拟地址为:0xffffffffc020f318.
空闲页数目为: 16384

释放p3后，空闲块数目为: 0
释放p3后，空闲页数目为: 0
-----------------------------Step 3: 边界条件测试 - 超出可用块请求-----
分配超过最大块失败，空闲页数目为: 16384
-----------------------------Step 4: 随机分配和释放测试---------------
p5请求4095页
找到第一个满足要求的空闲块 p
准备用于分配的空闲块 p 的地址为: 0xffffffffc020f318.
准备分配的空闲块 p 的页数为: 16384
开始分裂空闲块……

空闲块1的虚拟地址为:0xffffffffc0237318.
空闲页数目为: 4096
空闲块2的虚拟地址为:0xffffffffc025f318.
空闲页数目为: 8192
--------------------------------------------
p6请求4094页
找到第一个满足要求的空闲块 p
准备用于分配的空闲块 p 的地址为: 0xffffffffc0237318.
准备分配的空闲块 p 的页数为: 4096
开始分裂空闲块……

空闲块1的虚拟地址为:0xffffffffc025f318.
空闲页数目为: 8192
--------------------------------------------
p7请求4093页
找到第一个满足要求的空闲块 p
准备用于分配的空闲块 p 的地址为: 0xffffffffc025f318.
准备分配的空闲块 p 的页数为: 8192
开始分裂空闲块……

空闲块1的虚拟地址为:0xffffffffc0287318.
空闲页数目为: 4096
--------------------------------------------
p8请求2000页
找到第一个满足要求的空闲块 p
准备用于分配的空闲块 p 的地址为: 0xffffffffc0287318.
准备分配的空闲块 p 的页数为: 4096
开始分裂空闲块……

空闲块1的虚拟地址为:0xffffffffc029b318.
空闲页数目为: 2048
--------------------------------------------
测试一下释放p6和p7，它们会不会错误合并
释放p6
当前块的地址为: 0xffffffffc0237318.
当前块的页数为: 4096

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc029b318.
块 p 的页数为: 2048

没有找到可以合并的伙伴块

空闲块1的虚拟地址为:0xffffffffc0237318.
空闲页数目为: 4096
空闲块2的虚拟地址为:0xffffffffc029b318.
空闲页数目为: 2048
释放p6后，空闲块数目为: 2
释放p6后，空闲页数目为: 6144

释放p7
当前块的地址为: 0xffffffffc025f318.
当前块的页数为: 4096

找到 base 前面的块 p
块 p 的地址为: 0xffffffffc0237318.
块 p 的页数为: 4096
伙伴块的地址为: 0xffffffffc0237318.
伙伴块的页数为: 4096
合并后的相对首地址为: 0x0000000000028000.
合并后的块大小为: 0x0000000000050000.
找到 base 后面的块 p
块 p 的地址为: 0xffffffffc029b318.
块 p 的页数为: 2048

没有找到可以合并的伙伴块

空闲块1的虚拟地址为:0xffffffffc0237318.
空闲页数目为: 4096
空闲块2的虚拟地址为:0xffffffffc025f318.
空闲页数目为: 4096
空闲块3的虚拟地址为:0xffffffffc029b318.
空闲页数目为: 2048
释放p7后，空闲块数目为: 3
释放p7后，空闲页数目为: 10240

没有合并，测试成功

--------------------------------------------
释放p5
当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 4096

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc0237318.
块 p 的页数为: 4096

伙伴块的地址为: 0xffffffffc0237318.
伙伴块的页数为: 4096
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x0000000000050000.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 8192

继续尝试合并……

当前块的地址为: 0xffffffffc020f318.
当前块的页数为: 8192

找到 base 后面的块 p
块 p 的地址为: 0xffffffffc025f318.
块 p 的页数为: 4096

没有找到可以合并的伙伴块

空闲块1的虚拟地址为:0xffffffffc020f318.
空闲页数目为: 8192
空闲块2的虚拟地址为:0xffffffffc025f318.
空闲页数目为: 4096
空闲块3的虚拟地址为:0xffffffffc029b318.
空闲页数目为: 2048
释放p5后，空闲块数目为: 3
释放p5后，空闲页数目为: 14336

--------------------------------------------
释放p
当前块的地址为: 0xffffffffc0287318.
当前块的页数为: 2048

找到 base 前面的块 p
块 p 的地址为: 0xffffffffc025f318.
块 p 的页数为: 4096
找到 base 后面的块 p
块 p 的地址为: 0xffffffffc029b318.
块 p 的页数为: 2048

伙伴块的地址为: 0xffffffffc029b318.
伙伴块的页数为: 2048
合并后的相对首地址为: 0x0000000000078000.
合并后的块大小为: 0x0000000000028000.
合并成功
合并后的块的地址为: 0xffffffffc0287318.
合并后的块的块页数为: 4096

继续尝试合并……

当前块的地址为: 0xffffffffc0287318.
当前块的页数为: 4096

找到 base 前面的块 p
块 p 的地址为: 0xffffffffc025f318.
块 p 的页数为: 4096
伙伴块的地址为: 0xffffffffc025f318.
伙伴块的页数为: 4096
合并后的相对首地址为: 0x0000000000050000.
合并后的块大小为: 0x0000000000050000.
合并成功
合并后的块的地址为: 0xffffffffc025f318.
合并后的块的块页数为: 8192

继续尝试合并……

当前块的地址为: 0xffffffffc025f318.
当前块的页数为: 8192

找到 base 前面的块 p
块 p 的地址为: 0xffffffffc020f318.
块 p 的页数为: 8192
伙伴块的地址为: 0xffffffffc020f318.
伙伴块的页数为: 8192
合并后的相对首地址为: 0x0000000000000000.
合并后的块大小为: 0x00000000000a0000.
合并成功
合并后的块的地址为: 0xffffffffc020f318.
合并后的块的块页数为: 16384

继续尝试合并……

空闲块1的虚拟地址为:0xffffffffc020f318.
空闲页数目为: 16384
释放p8后，空闲块数目为: 1
释放p8后，空闲页数目为: 16384

=============================复杂测试完毕=============================
```