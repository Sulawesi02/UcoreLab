## 1. 概述
最久未使用(least recently used, LRU)算法：利用局部性，通过过去的访问情况预测未来的访问情况，我们可以认为最近还被访问过的页面将来被访问的可能性大，而很久没访问过的页面将来不太可能被访问。于是我们比较当前内存里的页面最近一次被访问的时间，把上一次访问时间离现在最久的页面置换出去。
## 2.设计思路
FIFO算法将可交换页面链表看作是一个队列，每次添加新页面会将页面添加到链表头部（队列尾部）。每次换出页面时将链表尾部（队列头部）页面换出。

LRU算法只需要在FIFO算法的基础上，每次访问一个虚拟地址的时候，将它所对应的页面移到链表头部（队列尾部）即可。我们可以通过先删后插的方式实现对链表的更新。
## 3.实现过程
1.仿照`swap_fifo.h`、`swap_fifo.c`创建`swap_lru.h`、`swap_lru.c`文件

2.在`swap_lru.c`文件中新增函数，用于访存的时候更新可交换页面链表
```
static int
_lru_update_swapqueue(struct mm_struct *mm, struct Page *page)
{
    queue_entry_t *head=(queue_entry_t*) mm->sm_priv;
    queue_entry_t *entry=&(page->pra_page_link);
    assert(entry != NULL && head != NULL);
    //将页面移到链表头部
    queue_del(entry);
    queue_add(head, entry);
    return 0;
}
```

向外界提供可供调用的接口
```
struct swap_manager swap_manager_lru =
{
     ……
     .update_swapqueue = &_lru_update_swapqueue,
};
```

3.在`swap.h`文件中

`swap_manager`结构体新增成员函数，用于访存的时候更新可交换页面链表
```
struct swap_manager
{
	……
	int (*update_swapqueue) (struct mm_struct *mm, struct Page *page);
}
```

4.在`swap.c`文件中

`check_swap()`函数通过`check_content_set()`函数给特定的虚拟地址赋值，但并没有更新可交换页面链表，因此我们实现了`check_content_set_fixed()`函数进行赋值和更新链表
```
static inline void
check_content_set_fixed(pde_t* pgdir,struct mm_struct *mm, uintptr_t addr, uintptr_t value){
     *(unsigned char *)addr = value;
     pte_t *ptep = get_pte(pgdir, addr, 0);
     struct Page *page = pte2page(*ptep);
     sm->update_swapqueue(mm, page);
}
```
- 访问虚拟内存，也就是给某个虚拟地址赋值
- 调用`get_pte`函数根据给定的页表基址`pgdir`和虚拟地址`la`，查找对应的页表项
- 调用`pte2page`函数得到该页表项对应的物理页面
- 调用`sm->update_swapqueue`函数（也就是`_lru_update_swapqueue`函数）将该页面移到链表头部

## 4.测试

在`check_swap()`函数中进行测试
```
     check_content_set_fixed(pgdir, mm, 0x1000, 0x0a);
     assert(pgfault_num==1);
     //1000
     check_content_set_fixed(pgdir, mm, 0x1010, 0x0a);
     assert(pgfault_num==1);
     //1000
     check_content_set_fixed(pgdir, mm, 0x2000, 0x0b);
     assert(pgfault_num==2);
     //2000-1000
     check_content_set_fixed(pgdir, mm, 0x2010, 0x0b);
     assert(pgfault_num==2);
     //2000-1000
     check_content_set_fixed(pgdir, mm, 0x3000, 0x0c);
     assert(pgfault_num==3);
     //3000-2000-1000
     check_content_set_fixed(pgdir, mm, 0x3010, 0x0c);
     assert(pgfault_num==3);
     //3000-2000-1000
     check_content_set_fixed(pgdir, mm, 0x4000, 0x0d);
     assert(pgfault_num==4);
     //4000-3000-2000-1000
     check_content_set_fixed(pgdir, mm, 0x4010, 0x0d);
     assert(pgfault_num==4);
     //4000-3000-2000-1000
     check_content_set_fixed(pgdir, mm, 0x2010, 0x0b);
     assert(pgfault_num==4);
     //2000-4000-3000-1000
     check_content_set_fixed(pgdir, mm, 0x5010, 0x0e);
     assert(pgfault_num==5);
     //5000-2000-4000-3000
     check_content_set_fixed(pgdir, mm, 0x1010, 0x0a);
     assert(pgfault_num==6);
     //1000-5000-2000-4000
     check_content_set_fixed(pgdir, mm, 0x3010, 0x0c);
     assert(pgfault_num==7);
     //3000-1000-5000-2000
```

测试结果如下：
1.访问0x1000、0x1010、0x2000、0x2010、0x3000、0x3010、0x4000、0x4010，会导致4次page fault，需要注意0x1000和0x1010是同一页的，以此类推
```
Store/AMO page fault
page fault at 0x00001000: K/W
Store/AMO page fault
page fault at 0x00002000: K/W
Store/AMO page fault
page fault at 0x00003000: K/W
Store/AMO page fault
page fault at 0x00004000: K/W
```
此时链表为：（链头/队尾）4000-3000-2000-1000（链尾/队头）

2.访问0x2010，会根据`_lru_update_swapqueue`函数将对应的页面移到链表头部（队列尾部）。
此时链表为：（链头/队尾）2000-4000-3000-1000（链尾/队头）

3.访问0x5010，导致page fault，会根据`_lru_swap_out_victim`函数将链表尾部（队列头部）页面换出，将0x5010所对应的页面插到链表头部（队列尾部）
```
Store/AMO page fault
page fault at 0x00005010: K/W
swap_out: i 0, store page in vaddr 0x1000 to disk swap entry 2
```
此时链表为：（链头/队尾）5000-2000-4000-3000（链尾/队头）

4.访问0x1010，导致page fault，会根据`_lru_swap_out_victim`函数将链表尾部（队列头部）页面换出
```
Store/AMO page fault
page fault at 0x00001010: K/W
swap_out: i 0, store page in vaddr 0x3000 to disk swap entry 4
swap_in: load disk swap entry 2 with swap_page in vadr 0x1000
```
此时链表为：（链头/队尾）1000-5000-2000-4000（链尾/队头）

5.访问0x3010，导致page fault，会根据`_lru_swap_out_victim`函数将链表尾部（队列头部）页面换出
```
Store/AMO page fault
page fault at 0x00003010: K/W
swap_out: i 0, store page in vaddr 0x4000 to disk swap entry 5
swap_in: load disk swap entry 4 with swap_page in vadr 0x3000
```
此时链表为：（链头/队尾）3000-1000-5000-2000（链尾/队头）