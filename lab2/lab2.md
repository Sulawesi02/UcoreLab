# Lab2:物理内存和页表

## 实验目的
- 理解页表的建立和使用方法
- 理解物理内存的管理方法
- 理解页面分配算法
### 练习
#### 练习1：理解 first-fit 连续物理内存分配算法（思考题）
first-fit 连续物理内存分配算法作为物理内存分配一个很基础的方法，需要同学们理解它的实现过程。请大家仔细阅读实验手册的教程并结合`kern/mm/default_pmm.c`中的相关代码，认真分析default_init，default_init_memmap，default_alloc_pages， default_free_pages等相关函数，并描述程序在进行物理内存分配的过程以及各个函数的作用。 请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 你的first fit算法是否有进一步的改进空间？

First-Fit首次适应算法通过保持一个空闲块链表（free list），并在接收到内存请求时，扫描链表以找到第一个足够大的块来满足请求。如果选择的块明显大于所请求的大小，它通常会被分割，剩余的部分会被添加回空闲块链表。

程序执行流程：
1. `entry.S`中包含实现分页机制的代码，并跳转到`kern_init()`。
2. `kern_init()`函数新增`pmm_init()`函数，用于初始化物理内存管理。
3. `pmm_init()`负责初始化操作系统的物理内存管理模块，检测可用的物理内存，保留已使用内存，并使用所选的内存管理策略管理剩余的空闲内存。
    - `init_pmm_manager()`初始化物理内存管理器，选择best-fit策略管理物理内存。
    - `page_init()` 初始化物理页，并调用`init_memmap()`建立空闲页链表。
    - `check_alloc_page()`调用物理内存管理器的 `check` 方法来测试物理内存的分配和释放功能。
数据结构
- `Page` 结构体
```
struct Page {
    int ref;                        // 页框的引用计数
    uint64_t flags;                 // 描述页框状态的 64 位标志数组
    unsigned int property;          // 表示块的大小（空闲块的数量）
    list_entry_t page_link;         // 双向链表指针，用于将这个 Page 链接到空闲列表
};
```
`Page`结构体表示一个物理页面，其中`property`字段用于表示页面的大小，`page_link`用于将页面链接到空闲块链表中。

- `free_area_t` 结构体
```
typedef struct {
    list_entry_t free_list;         // 空闲块链表的头
    unsigned int nr_free;           // 空闲页的数量
} free_area_t;
```
`free_area_t`结构体使用双向链表 `free_list` 来维护空闲块，通过 `nr_free` 记录空闲页的数量。

各个函数的作用：
- default_init()函数：初始化空闲块链表 `free_list` 以及空闲页面数量 `nr_free`。
- default_init_memmap()函数：初始化物理内存区域，并将空闲页面插入到空闲块链表中。
	- 初始化每个页，清空 `flags` 和 `property`字段，将其标记为未使用，并将页面引用计数清零。
	- 将起始页的 `property` 设置为 `n`，表示这是一个大小为 `n` 页的空闲块。调用 `SetPageProperty` 来标记 base 这个块为空闲块，并更新空闲页计数器。
	- 将空闲块插入到空闲块链表中。
- default_alloc_pages()函数：分配连续的物理页。
	- 遍历空闲块链表，查找第一个块大小大于等于请求的页面数的空闲块。
	- 找到空闲块后，从空闲块链表中移除该空闲块。
	- 如果找到的块比所需的块大，将多余的页面作为新的空闲块重新插入到空闲块链表中。
	- 更新空闲页计数器，调用 `ClearPageProperty(page)` 表示该块已经分配，不再是空闲块。
- default_free_pages()函数：将已分配的物理页重新释放回空闲块链表，并在可能的情况下将相邻的空闲内存块进行合并。
	- 遍历该块的每个页，使用断言确保这些页既不是保留页（`PageReserved`），也不是标记为空闲的页（`PageProperty`），将其标记为未使用，并将页面引用计数清零
	- 将起始页的 `property` 设置为 `n`，表示这是一个大小为 `n` 页的空闲块。调用 `SetPageProperty` 来标记 base 这个块为空闲块，并更新空闲页计数器。
	- 将 base 这个块添加到空闲块链表中。
	- 查找该空闲块前面的和后面的空闲块，如果成功就进行合并，通过增加 `property` 来扩展块的大小，并从链表中删除原空闲块。

改进空间：
- 当前的链表插入是顺序遍历链表寻找合适的位置，如果链表很长，性能会下降。可以考虑使用更高效的数据结构，比如跳表或红黑树。
- 如果空闲块被频繁分割，可能导致内存碎片化。可以进一步优化合并策略或者引入更复杂的分配算法（如Best-Fit）。
#### 练习2：实现 Best-Fit 连续物理内存分配算法（需要编程）
在完成练习一后，参考kern/mm/default_pmm.c对First Fit算法的实现，编程实现Best Fit页面分配算法，算法的时空复杂度不做要求，能通过测试即可。 请在实验报告中简要说明你的设计实现过程，阐述代码是如何对物理内存进行分配和释放，并回答如下问题：

- 你的 Best-Fit 算法是否有进一步的改进空间？

设计实现过程：和 first-fit 算法主要的不同是内存分配函数的设计。遍历空闲块链表，查找比所需页面数大的空闲块。如果当前的空闲块是第一个满足条件的块，就把当前的空闲块分配给它，或者如果找到更小的空闲块，就把更小的空闲块分配给它。

和 first-fit 算法的主要区别是增加了`if(page == NULL || page->property > p->property)`
```
while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            if(page == NULL || page->property > p->property)
                page = p;
        }
    }
```

- best_fit_alloc_pages()函数：分配指定页面数的内存块。
	- 遍历空闲块链表，查找块大小大于等于请求的页面数中页面数最小的空闲块。
	- 找到空闲块后，从空闲块链表中移除该空闲块。
	- 如果找到的块比所需的块大，将多余的页面作为新的空闲块重新插入到空闲块链表中。
	- 更新空闲页计数器，调用 `ClearPageProperty(page)` 表示该块已经分配，不再是空闲块。
- best_fit_free_pages()函数：释放指定页面数的内存块。
	- 遍历该块的每个页，使用断言确保这些页既不是保留页（`PageReserved`），也不是标记为空闲的页（`PageProperty`），将其标记为未使用，并将页面引用计数清零
	- 将起始页的 `property` 设置为 `n`，表示这是一个大小为 `n` 页的空闲块。调用 `SetPageProperty` 来标记 base 这个块为空闲块，并更新空闲页计数器。
	- 将 base 这个块添加到空闲块链表中。
	- 查找该空闲块前面的和后面的空闲块，如果成功就进行合并，通过增加 `property` 来扩展块的大小，并从链表中删除原空闲块。

改进空间：
- 当前的链表插入是顺序遍历链表寻找合适的位置，如果链表很长，性能会下降。可以考虑使用更高效的数据结构，比如跳表或红黑树。

执行
```
make qemu
```

输出结果：
```
(THU.CST) os is loading ...
Special kernel symbols:
  entry  0xffffffffc0200036 (virtual)
  etext  0xffffffffc0201ad8 (virtual)
  edata  0xffffffffc0206010 (virtual)
  end    0xffffffffc0206470 (virtual)
Kernel executable memory footprint: 26KB
memory management: best_fit_pmm_manager
physcial memory map:
  memory: 0x0000000007e00000, [0x0000000080200000, 0x0000000087ffffff].
check_alloc_page() succeeded!
satp virtual address: 0xffffffffc0205000
satp physical address: 0x0000000080205000
++ setup timer interrupts
100 ticks
100 ticks
100 ticks
100 ticks
……
```

#### 扩展练习Challenge：buddy system（伙伴系统）分配算法（需要编程）
Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 每个存储块的大小必须是2的n次幂(Pow(2, n)), 即1, 2, 4, 8, 16, 32, 64, 128...

- 参考[伙伴分配器的一个极简实现](http://coolshell.cn/articles/10427.html)， 在ucore中实现buddy system分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

见buddy_system设计文档
#### 扩展练习Challenge：任意大小的内存单元slub分配算法（需要编程）
slub算法，实现两层架构的高效内存单元分配，第一层是基于页大小的内存分配，第二层是在第一层基础上实现基于任意大小的内存分配。可简化实现，能够体现其主体思想即可。
- 参考[linux的slub分配算法/](https://github.com/torvalds/linux/blob/master/mm/slub.c)，在ucore中实现slub分配算法。要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

#### 扩展练习Challenge：硬件的可用物理内存范围的获取方法（思考题）
- 如果 OS 无法提前知道当前硬件的可用物理内存范围，请问你有何办法让 OS 获取可用物理内存范围？
#### 1.内存探测技术
操作系统可以通过探测物理地址空间的方式来确定可用的物理内存范围。在每个待探测的内存块中，操作系统尝试写入数据，写入数据后，操作系统读取该块内存的内容，并与之前写入的数据进行比较。如果读出的数据与写入的数据一致，说明该块内存是可用的。当一个内存块通过读写测试后，操作系统将其标记为可用内存区域，纳入内存管理系统中。
#### 2.设备树
系统启时，OpenSBI 作为 RISC-V 架构上的固件层，可以利用设备树来提供硬件的相关信息给上层的操作系统，其中包含了内存布局的信息。设备树是一种数据结构，用于描述计算机硬件的各种属性，如内存大小、缓存大小、处理器类型等。操作系统可以从设备树中解析出可用的物理内存范围。

OpenSBI 固件完成对于包括物理内存在内的各外设的扫描，将扫描结果以设备树二进制对象（DTB，Device Tree Blob）的格式保存在物理内存中的某个地方。而这个放置的物理地址将放在 a1 寄存器中，而将会把 HART ID （HART，Hardware Thread，硬件线程，可以理解为执行的 CPU 核）放在 a0 寄存器上。


