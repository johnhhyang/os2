
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 d6 10 80       	mov    $0x8010d670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 57 37 10 80       	mov    $0x80103757,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 80 8a 10 	movl   $0x80108a80,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
80100049:	e8 b8 52 00 00       	call   80105306 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 15 11 80 84 	movl   $0x80111584,0x80111590
80100055:	15 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 15 11 80 84 	movl   $0x80111584,0x80111594
8010005f:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 b4 d6 10 80 	movl   $0x8010d6b4,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 15 11 80       	mov    0x80111594,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 15 11 80       	mov    %eax,0x80111594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
801000bd:	e8 65 52 00 00       	call   80105327 <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 15 11 80       	mov    0x80111594,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	89 c2                	mov    %eax,%edx
801000f5:	83 ca 01             	or     $0x1,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
80100104:	e8 80 52 00 00       	call   80105389 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 80 d6 10 	movl   $0x8010d680,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 1c 4f 00 00       	call   80105040 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 15 11 80       	mov    0x80111590,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
8010017c:	e8 08 52 00 00       	call   80105389 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 87 8a 10 80 	movl   $0x80108a87,(%esp)
8010019f:	e8 99 03 00 00       	call   8010053d <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 e8 25 00 00       	call   801027c0 <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 98 8a 10 80 	movl   $0x80108a98,(%esp)
801001f6:	e8 42 03 00 00       	call   8010053d <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	89 c2                	mov    %eax,%edx
80100202:	83 ca 04             	or     $0x4,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 ab 25 00 00       	call   801027c0 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 9f 8a 10 80 	movl   $0x80108a9f,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
8010023c:	e8 e6 50 00 00       	call   80105327 <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 15 11 80       	mov    0x80111594,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 15 11 80       	mov    %eax,0x80111594

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	89 c2                	mov    %eax,%edx
8010028f:	83 e2 fe             	and    $0xfffffffe,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 7a 4e 00 00       	call   8010511c <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
801002a9:	e8 db 50 00 00       	call   80105389 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	53                   	push   %ebx
801002b4:	83 ec 14             	sub    $0x14,%esp
801002b7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ba:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002be:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801002c2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801002c6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801002ca:	ec                   	in     (%dx),%al
801002cb:	89 c3                	mov    %eax,%ebx
801002cd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801002d0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801002d4:	83 c4 14             	add    $0x14,%esp
801002d7:	5b                   	pop    %ebx
801002d8:	5d                   	pop    %ebp
801002d9:	c3                   	ret    

801002da <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002da:	55                   	push   %ebp
801002db:	89 e5                	mov    %esp,%ebp
801002dd:	83 ec 08             	sub    $0x8,%esp
801002e0:	8b 55 08             	mov    0x8(%ebp),%edx
801002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801002e6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002ea:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002ed:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002f1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002f5:	ee                   	out    %al,(%dx)
}
801002f6:	c9                   	leave  
801002f7:	c3                   	ret    

801002f8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002f8:	55                   	push   %ebp
801002f9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002fb:	fa                   	cli    
}
801002fc:	5d                   	pop    %ebp
801002fd:	c3                   	ret    

801002fe <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002fe:	55                   	push   %ebp
801002ff:	89 e5                	mov    %esp,%ebp
80100301:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100304:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100308:	74 19                	je     80100323 <printint+0x25>
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	c1 e8 1f             	shr    $0x1f,%eax
80100310:	89 45 10             	mov    %eax,0x10(%ebp)
80100313:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100317:	74 0a                	je     80100323 <printint+0x25>
    x = -xx;
80100319:	8b 45 08             	mov    0x8(%ebp),%eax
8010031c:	f7 d8                	neg    %eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100321:	eb 06                	jmp    80100329 <printint+0x2b>
  else
    x = xx;
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100329:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100333:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100336:	ba 00 00 00 00       	mov    $0x0,%edx
8010033b:	f7 f1                	div    %ecx
8010033d:	89 d0                	mov    %edx,%eax
8010033f:	0f b6 90 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%edx
80100346:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100349:	03 45 f4             	add    -0xc(%ebp),%eax
8010034c:	88 10                	mov    %dl,(%eax)
8010034e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
80100352:	8b 55 0c             	mov    0xc(%ebp),%edx
80100355:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 75 d4             	divl   -0x2c(%ebp)
80100363:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100366:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010036a:	75 c4                	jne    80100330 <printint+0x32>

  if(sign)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 23                	je     80100395 <printint+0x97>
    buf[i++] = '-';
80100372:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100375:	03 45 f4             	add    -0xc(%ebp),%eax
80100378:	c6 00 2d             	movb   $0x2d,(%eax)
8010037b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
8010037f:	eb 14                	jmp    80100395 <printint+0x97>
    consputc(buf[i]);
80100381:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100384:	03 45 f4             	add    -0xc(%ebp),%eax
80100387:	0f b6 00             	movzbl (%eax),%eax
8010038a:	0f be c0             	movsbl %al,%eax
8010038d:	89 04 24             	mov    %eax,(%esp)
80100390:	e8 bb 03 00 00       	call   80100750 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
80100395:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100399:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010039d:	79 e2                	jns    80100381 <printint+0x83>
    consputc(buf[i]);
}
8010039f:	c9                   	leave  
801003a0:	c3                   	ret    

801003a1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a1:	55                   	push   %ebp
801003a2:	89 e5                	mov    %esp,%ebp
801003a4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a7:	a1 14 c6 10 80       	mov    0x8010c614,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
801003bc:	e8 66 4f 00 00       	call   80105327 <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 a6 8a 10 80 	movl   $0x80108aa6,(%esp)
801003cf:	e8 69 01 00 00       	call   8010053d <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e1:	e9 20 01 00 00       	jmp    80100506 <cprintf+0x165>
    if(c != '%'){
801003e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003ea:	74 10                	je     801003fc <cprintf+0x5b>
      consputc(c);
801003ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ef:	89 04 24             	mov    %eax,(%esp)
801003f2:	e8 59 03 00 00       	call   80100750 <consputc>
      continue;
801003f7:	e9 06 01 00 00       	jmp    80100502 <cprintf+0x161>
    }
    c = fmt[++i] & 0xff;
801003fc:	8b 55 08             	mov    0x8(%ebp),%edx
801003ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100406:	01 d0                	add    %edx,%eax
80100408:	0f b6 00             	movzbl (%eax),%eax
8010040b:	0f be c0             	movsbl %al,%eax
8010040e:	25 ff 00 00 00       	and    $0xff,%eax
80100413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100416:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010041a:	0f 84 08 01 00 00    	je     80100528 <cprintf+0x187>
      break;
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4d                	je     80100475 <cprintf+0xd4>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0x9f>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13b>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xae>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x149>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 53                	je     80100498 <cprintf+0xf7>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2b                	je     80100475 <cprintf+0xd4>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x149>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8b 00                	mov    (%eax),%eax
80100454:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100458:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010045f:	00 
80100460:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100467:	00 
80100468:	89 04 24             	mov    %eax,(%esp)
8010046b:	e8 8e fe ff ff       	call   801002fe <printint>
      break;
80100470:	e9 8d 00 00 00       	jmp    80100502 <cprintf+0x161>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100478:	8b 00                	mov    (%eax),%eax
8010047a:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
8010047e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100485:	00 
80100486:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010048d:	00 
8010048e:	89 04 24             	mov    %eax,(%esp)
80100491:	e8 68 fe ff ff       	call   801002fe <printint>
      break;
80100496:	eb 6a                	jmp    80100502 <cprintf+0x161>
    case 's':
      if((s = (char*)*argp++) == 0)
80100498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049b:	8b 00                	mov    (%eax),%eax
8010049d:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004a4:	0f 94 c0             	sete   %al
801004a7:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
801004ab:	84 c0                	test   %al,%al
801004ad:	74 20                	je     801004cf <cprintf+0x12e>
        s = "(null)";
801004af:	c7 45 ec af 8a 10 80 	movl   $0x80108aaf,-0x14(%ebp)
      for(; *s; s++)
801004b6:	eb 17                	jmp    801004cf <cprintf+0x12e>
        consputc(*s);
801004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004bb:	0f b6 00             	movzbl (%eax),%eax
801004be:	0f be c0             	movsbl %al,%eax
801004c1:	89 04 24             	mov    %eax,(%esp)
801004c4:	e8 87 02 00 00       	call   80100750 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004c9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004cd:	eb 01                	jmp    801004d0 <cprintf+0x12f>
801004cf:	90                   	nop
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 de                	jne    801004b8 <cprintf+0x117>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x161>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 68 02 00 00       	call   80100750 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 5a 02 00 00       	call   80100750 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 4f 02 00 00       	call   80100750 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 c0 fe ff ff    	jne    801003e6 <cprintf+0x45>
80100526:	eb 01                	jmp    80100529 <cprintf+0x188>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100528:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100529:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052d:	74 0c                	je     8010053b <cprintf+0x19a>
    release(&cons.lock);
8010052f:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100536:	e8 4e 4e 00 00       	call   80105389 <release>
}
8010053b:	c9                   	leave  
8010053c:	c3                   	ret    

8010053d <panic>:

void
panic(char *s)
{
8010053d:	55                   	push   %ebp
8010053e:	89 e5                	mov    %esp,%ebp
80100540:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100543:	e8 b0 fd ff ff       	call   801002f8 <cli>
  cons.locking = 0;
80100548:	c7 05 14 c6 10 80 00 	movl   $0x0,0x8010c614
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 b6 8a 10 80 	movl   $0x80108ab6,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 c5 8a 10 80 	movl   $0x80108ac5,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 41 4e 00 00       	call   801053d8 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 c7 8a 10 80 	movl   $0x80108ac7,(%esp)
801005b2:	e8 ea fd ff ff       	call   801003a1 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005bb:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bf:	7e df                	jle    801005a0 <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005c1:	c7 05 c0 c5 10 80 01 	movl   $0x1,0x8010c5c0
801005c8:	00 00 00 
  for(;;)
    ;
801005cb:	eb fe                	jmp    801005cb <panic+0x8e>

801005cd <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005cd:	55                   	push   %ebp
801005ce:	89 e5                	mov    %esp,%ebp
801005d0:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d3:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005da:	00 
801005db:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005e2:	e8 f3 fc ff ff       	call   801002da <outb>
  pos = inb(CRTPORT+1) << 8;
801005e7:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005ee:	e8 bd fc ff ff       	call   801002b0 <inb>
801005f3:	0f b6 c0             	movzbl %al,%eax
801005f6:	c1 e0 08             	shl    $0x8,%eax
801005f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005fc:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100603:	00 
80100604:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010060b:	e8 ca fc ff ff       	call   801002da <outb>
  pos |= inb(CRTPORT+1);
80100610:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100617:	e8 94 fc ff ff       	call   801002b0 <inb>
8010061c:	0f b6 c0             	movzbl %al,%eax
8010061f:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100622:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100626:	75 30                	jne    80100658 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100628:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010062b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100630:	89 c8                	mov    %ecx,%eax
80100632:	f7 ea                	imul   %edx
80100634:	c1 fa 05             	sar    $0x5,%edx
80100637:	89 c8                	mov    %ecx,%eax
80100639:	c1 f8 1f             	sar    $0x1f,%eax
8010063c:	29 c2                	sub    %eax,%edx
8010063e:	89 d0                	mov    %edx,%eax
80100640:	c1 e0 02             	shl    $0x2,%eax
80100643:	01 d0                	add    %edx,%eax
80100645:	c1 e0 04             	shl    $0x4,%eax
80100648:	89 ca                	mov    %ecx,%edx
8010064a:	29 c2                	sub    %eax,%edx
8010064c:	b8 50 00 00 00       	mov    $0x50,%eax
80100651:	29 d0                	sub    %edx,%eax
80100653:	01 45 f4             	add    %eax,-0xc(%ebp)
80100656:	eb 32                	jmp    8010068a <cgaputc+0xbd>
  else if(c == BACKSPACE){
80100658:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065f:	75 0c                	jne    8010066d <cgaputc+0xa0>
    if(pos > 0) --pos;
80100661:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100665:	7e 23                	jle    8010068a <cgaputc+0xbd>
80100667:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010066b:	eb 1d                	jmp    8010068a <cgaputc+0xbd>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066d:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100672:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100675:	01 d2                	add    %edx,%edx
80100677:	01 c2                	add    %eax,%edx
80100679:	8b 45 08             	mov    0x8(%ebp),%eax
8010067c:	66 25 ff 00          	and    $0xff,%ax
80100680:	80 cc 07             	or     $0x7,%ah
80100683:	66 89 02             	mov    %ax,(%edx)
80100686:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
8010068a:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100691:	7e 53                	jle    801006e6 <cgaputc+0x119>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100693:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 92 4f 00 00       	call   80105649 <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	01 c0                	add    %eax,%eax
801006c5:	8b 15 00 a0 10 80    	mov    0x8010a000,%edx
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 ca                	add    %ecx,%edx
801006d2:	89 44 24 08          	mov    %eax,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 14 24             	mov    %edx,(%esp)
801006e1:	e8 90 4e 00 00       	call   80105576 <memset>
  }
  
  outb(CRTPORT, 14);
801006e6:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006ed:	00 
801006ee:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006f5:	e8 e0 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
801006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fd:	c1 f8 08             	sar    $0x8,%eax
80100700:	0f b6 c0             	movzbl %al,%eax
80100703:	89 44 24 04          	mov    %eax,0x4(%esp)
80100707:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010070e:	e8 c7 fb ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
80100713:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010071a:	00 
8010071b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100722:	e8 b3 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
80100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010072a:	0f b6 c0             	movzbl %al,%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100738:	e8 9d fb ff ff       	call   801002da <outb>
  crt[pos] = ' ' | 0x0700;
8010073d:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100745:	01 d2                	add    %edx,%edx
80100747:	01 d0                	add    %edx,%eax
80100749:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010074e:	c9                   	leave  
8010074f:	c3                   	ret    

80100750 <consputc>:

void
consputc(int c)
{
80100750:	55                   	push   %ebp
80100751:	89 e5                	mov    %esp,%ebp
80100753:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100756:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
8010075b:	85 c0                	test   %eax,%eax
8010075d:	74 07                	je     80100766 <consputc+0x16>
    cli();
8010075f:	e8 94 fb ff ff       	call   801002f8 <cli>
    for(;;)
      ;
80100764:	eb fe                	jmp    80100764 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100766:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010076d:	75 26                	jne    80100795 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010076f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100776:	e8 56 69 00 00       	call   801070d1 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 4a 69 00 00       	call   801070d1 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 3e 69 00 00       	call   801070d1 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 31 69 00 00       	call   801070d1 <uartputc>
  cgaputc(c);
801007a0:	8b 45 08             	mov    0x8(%ebp),%eax
801007a3:	89 04 24             	mov    %eax,(%esp)
801007a6:	e8 22 fe ff ff       	call   801005cd <cgaputc>
}
801007ab:	c9                   	leave  
801007ac:	c3                   	ret    

801007ad <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ad:	55                   	push   %ebp
801007ae:	89 e5                	mov    %esp,%ebp
801007b0:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007b3:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
801007ba:	e8 68 4b 00 00       	call   80105327 <acquire>
  while((c = getc()) >= 0){
801007bf:	e9 41 01 00 00       	jmp    80100905 <consoleintr+0x158>
    switch(c){
801007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007c7:	83 f8 10             	cmp    $0x10,%eax
801007ca:	74 1e                	je     801007ea <consoleintr+0x3d>
801007cc:	83 f8 10             	cmp    $0x10,%eax
801007cf:	7f 0a                	jg     801007db <consoleintr+0x2e>
801007d1:	83 f8 08             	cmp    $0x8,%eax
801007d4:	74 68                	je     8010083e <consoleintr+0x91>
801007d6:	e9 94 00 00 00       	jmp    8010086f <consoleintr+0xc2>
801007db:	83 f8 15             	cmp    $0x15,%eax
801007de:	74 2f                	je     8010080f <consoleintr+0x62>
801007e0:	83 f8 7f             	cmp    $0x7f,%eax
801007e3:	74 59                	je     8010083e <consoleintr+0x91>
801007e5:	e9 85 00 00 00       	jmp    8010086f <consoleintr+0xc2>
    case C('P'):  // Process listing.
      procdump();
801007ea:	e8 d3 49 00 00       	call   801051c2 <procdump>
      break;
801007ef:	e9 11 01 00 00       	jmp    80100905 <consoleintr+0x158>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 5c 18 11 80       	mov    %eax,0x8011185c
        consputc(BACKSPACE);
80100801:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100808:	e8 43 ff ff ff       	call   80100750 <consputc>
8010080d:	eb 01                	jmp    80100810 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080f:	90                   	nop
80100810:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100816:	a1 58 18 11 80       	mov    0x80111858,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	0f 84 db 00 00 00    	je     801008fe <consoleintr+0x151>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100823:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100828:	83 e8 01             	sub    $0x1,%eax
8010082b:	83 e0 7f             	and    $0x7f,%eax
8010082e:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100835:	3c 0a                	cmp    $0xa,%al
80100837:	75 bb                	jne    801007f4 <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100839:	e9 c0 00 00 00       	jmp    801008fe <consoleintr+0x151>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010083e:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100844:	a1 58 18 11 80       	mov    0x80111858,%eax
80100849:	39 c2                	cmp    %eax,%edx
8010084b:	0f 84 b0 00 00 00    	je     80100901 <consoleintr+0x154>
        input.e--;
80100851:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100856:	83 e8 01             	sub    $0x1,%eax
80100859:	a3 5c 18 11 80       	mov    %eax,0x8011185c
        consputc(BACKSPACE);
8010085e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100865:	e8 e6 fe ff ff       	call   80100750 <consputc>
      }
      break;
8010086a:	e9 92 00 00 00       	jmp    80100901 <consoleintr+0x154>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010086f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100873:	0f 84 8b 00 00 00    	je     80100904 <consoleintr+0x157>
80100879:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
8010087f:	a1 54 18 11 80       	mov    0x80111854,%eax
80100884:	89 d1                	mov    %edx,%ecx
80100886:	29 c1                	sub    %eax,%ecx
80100888:	89 c8                	mov    %ecx,%eax
8010088a:	83 f8 7f             	cmp    $0x7f,%eax
8010088d:	77 75                	ja     80100904 <consoleintr+0x157>
        c = (c == '\r') ? '\n' : c;
8010088f:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
80100893:	74 05                	je     8010089a <consoleintr+0xed>
80100895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100898:	eb 05                	jmp    8010089f <consoleintr+0xf2>
8010089a:	b8 0a 00 00 00       	mov    $0xa,%eax
8010089f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008a2:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008a7:	89 c1                	mov    %eax,%ecx
801008a9:	83 e1 7f             	and    $0x7f,%ecx
801008ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008af:	88 91 d4 17 11 80    	mov    %dl,-0x7feee82c(%ecx)
801008b5:	83 c0 01             	add    $0x1,%eax
801008b8:	a3 5c 18 11 80       	mov    %eax,0x8011185c
        consputc(c);
801008bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008c0:	89 04 24             	mov    %eax,(%esp)
801008c3:	e8 88 fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c8:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008cc:	74 18                	je     801008e6 <consoleintr+0x139>
801008ce:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008d2:	74 12                	je     801008e6 <consoleintr+0x139>
801008d4:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008d9:	8b 15 54 18 11 80    	mov    0x80111854,%edx
801008df:	83 ea 80             	sub    $0xffffff80,%edx
801008e2:	39 d0                	cmp    %edx,%eax
801008e4:	75 1e                	jne    80100904 <consoleintr+0x157>
          input.w = input.e;
801008e6:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008eb:	a3 58 18 11 80       	mov    %eax,0x80111858
          wakeup(&input.r);
801008f0:	c7 04 24 54 18 11 80 	movl   $0x80111854,(%esp)
801008f7:	e8 20 48 00 00       	call   8010511c <wakeup>
        }
      }
      break;
801008fc:	eb 06                	jmp    80100904 <consoleintr+0x157>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008fe:	90                   	nop
801008ff:	eb 04                	jmp    80100905 <consoleintr+0x158>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100901:	90                   	nop
80100902:	eb 01                	jmp    80100905 <consoleintr+0x158>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
          input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
80100904:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100905:	8b 45 08             	mov    0x8(%ebp),%eax
80100908:	ff d0                	call   *%eax
8010090a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010090d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100911:	0f 89 ad fe ff ff    	jns    801007c4 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100917:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
8010091e:	e8 66 4a 00 00       	call   80105389 <release>
}
80100923:	c9                   	leave  
80100924:	c3                   	ret    

80100925 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100925:	55                   	push   %ebp
80100926:	89 e5                	mov    %esp,%ebp
80100928:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
8010092b:	8b 45 08             	mov    0x8(%ebp),%eax
8010092e:	89 04 24             	mov    %eax,(%esp)
80100931:	e8 8c 10 00 00       	call   801019c2 <iunlock>
  target = n;
80100936:	8b 45 10             	mov    0x10(%ebp),%eax
80100939:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
8010093c:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100943:	e8 df 49 00 00       	call   80105327 <acquire>
  while(n > 0){
80100948:	e9 a8 00 00 00       	jmp    801009f5 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
8010094d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100953:	8b 40 24             	mov    0x24(%eax),%eax
80100956:	85 c0                	test   %eax,%eax
80100958:	74 21                	je     8010097b <consoleread+0x56>
        release(&input.lock);
8010095a:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100961:	e8 23 4a 00 00       	call   80105389 <release>
        ilock(ip);
80100966:	8b 45 08             	mov    0x8(%ebp),%eax
80100969:	89 04 24             	mov    %eax,(%esp)
8010096c:	e8 03 0f 00 00       	call   80101874 <ilock>
        return -1;
80100971:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100976:	e9 a9 00 00 00       	jmp    80100a24 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
8010097b:	c7 44 24 04 a0 17 11 	movl   $0x801117a0,0x4(%esp)
80100982:	80 
80100983:	c7 04 24 54 18 11 80 	movl   $0x80111854,(%esp)
8010098a:	e8 b1 46 00 00       	call   80105040 <sleep>
8010098f:	eb 01                	jmp    80100992 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100991:	90                   	nop
80100992:	8b 15 54 18 11 80    	mov    0x80111854,%edx
80100998:	a1 58 18 11 80       	mov    0x80111858,%eax
8010099d:	39 c2                	cmp    %eax,%edx
8010099f:	74 ac                	je     8010094d <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009a1:	a1 54 18 11 80       	mov    0x80111854,%eax
801009a6:	89 c2                	mov    %eax,%edx
801009a8:	83 e2 7f             	and    $0x7f,%edx
801009ab:	0f b6 92 d4 17 11 80 	movzbl -0x7feee82c(%edx),%edx
801009b2:	0f be d2             	movsbl %dl,%edx
801009b5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801009b8:	83 c0 01             	add    $0x1,%eax
801009bb:	a3 54 18 11 80       	mov    %eax,0x80111854
    if(c == C('D')){  // EOF
801009c0:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009c4:	75 17                	jne    801009dd <consoleread+0xb8>
      if(n < target){
801009c6:	8b 45 10             	mov    0x10(%ebp),%eax
801009c9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009cc:	73 2f                	jae    801009fd <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009ce:	a1 54 18 11 80       	mov    0x80111854,%eax
801009d3:	83 e8 01             	sub    $0x1,%eax
801009d6:	a3 54 18 11 80       	mov    %eax,0x80111854
      }
      break;
801009db:	eb 20                	jmp    801009fd <consoleread+0xd8>
    }
    *dst++ = c;
801009dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009e0:	89 c2                	mov    %eax,%edx
801009e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801009e5:	88 10                	mov    %dl,(%eax)
801009e7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
801009eb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009ef:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009f3:	74 0b                	je     80100a00 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801009f9:	7f 96                	jg     80100991 <consoleread+0x6c>
801009fb:	eb 04                	jmp    80100a01 <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
801009fd:	90                   	nop
801009fe:	eb 01                	jmp    80100a01 <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a00:	90                   	nop
  }
  release(&input.lock);
80100a01:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100a08:	e8 7c 49 00 00       	call   80105389 <release>
  ilock(ip);
80100a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a10:	89 04 24             	mov    %eax,(%esp)
80100a13:	e8 5c 0e 00 00       	call   80101874 <ilock>

  return target - n;
80100a18:	8b 45 10             	mov    0x10(%ebp),%eax
80100a1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a1e:	89 d1                	mov    %edx,%ecx
80100a20:	29 c1                	sub    %eax,%ecx
80100a22:	89 c8                	mov    %ecx,%eax
}
80100a24:	c9                   	leave  
80100a25:	c3                   	ret    

80100a26 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a26:	55                   	push   %ebp
80100a27:	89 e5                	mov    %esp,%ebp
80100a29:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80100a2f:	89 04 24             	mov    %eax,(%esp)
80100a32:	e8 8b 0f 00 00       	call   801019c2 <iunlock>
  acquire(&cons.lock);
80100a37:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a3e:	e8 e4 48 00 00       	call   80105327 <acquire>
  for(i = 0; i < n; i++)
80100a43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a4a:	eb 1d                	jmp    80100a69 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a4f:	03 45 0c             	add    0xc(%ebp),%eax
80100a52:	0f b6 00             	movzbl (%eax),%eax
80100a55:	0f be c0             	movsbl %al,%eax
80100a58:	25 ff 00 00 00       	and    $0xff,%eax
80100a5d:	89 04 24             	mov    %eax,(%esp)
80100a60:	e8 eb fc ff ff       	call   80100750 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a6c:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a6f:	7c db                	jl     80100a4c <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a71:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a78:	e8 0c 49 00 00       	call   80105389 <release>
  ilock(ip);
80100a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a80:	89 04 24             	mov    %eax,(%esp)
80100a83:	e8 ec 0d 00 00       	call   80101874 <ilock>

  return n;
80100a88:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a8b:	c9                   	leave  
80100a8c:	c3                   	ret    

80100a8d <consoleinit>:

void
consoleinit(void)
{
80100a8d:	55                   	push   %ebp
80100a8e:	89 e5                	mov    %esp,%ebp
80100a90:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a93:	c7 44 24 04 cb 8a 10 	movl   $0x80108acb,0x4(%esp)
80100a9a:	80 
80100a9b:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100aa2:	e8 5f 48 00 00       	call   80105306 <initlock>
  initlock(&input.lock, "input");
80100aa7:	c7 44 24 04 d3 8a 10 	movl   $0x80108ad3,0x4(%esp)
80100aae:	80 
80100aaf:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100ab6:	e8 4b 48 00 00       	call   80105306 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100abb:	c7 05 0c 22 11 80 26 	movl   $0x80100a26,0x8011220c
80100ac2:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ac5:	c7 05 08 22 11 80 25 	movl   $0x80100925,0x80112208
80100acc:	09 10 80 
  cons.locking = 1;
80100acf:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
80100ad6:	00 00 00 

  picenable(IRQ_KBD);
80100ad9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae0:	e8 1c 33 00 00       	call   80103e01 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ae5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100aec:	00 
80100aed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100af4:	e8 89 1e 00 00       	call   80102982 <ioapicenable>
}
80100af9:	c9                   	leave  
80100afa:	c3                   	ret    
	...

80100afc <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100afc:	55                   	push   %ebp
80100afd:	89 e5                	mov    %esp,%ebp
80100aff:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b05:	e8 57 29 00 00       	call   80103461 <begin_op>
  if((ip = namei(path)) == 0){
80100b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80100b0d:	89 04 24             	mov    %eax,(%esp)
80100b10:	e8 01 19 00 00       	call   80102416 <namei>
80100b15:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b18:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b1c:	75 0f                	jne    80100b2d <exec+0x31>
    end_op();
80100b1e:	e8 bf 29 00 00       	call   801034e2 <end_op>
    return -1;
80100b23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b28:	e9 dd 03 00 00       	jmp    80100f0a <exec+0x40e>
  }
  ilock(ip);
80100b2d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b30:	89 04 24             	mov    %eax,(%esp)
80100b33:	e8 3c 0d 00 00       	call   80101874 <ilock>
  pgdir = 0;
80100b38:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b3f:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b46:	00 
80100b47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b4e:	00 
80100b4f:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b55:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b59:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b5c:	89 04 24             	mov    %eax,(%esp)
80100b5f:	e8 06 12 00 00       	call   80101d6a <readi>
80100b64:	83 f8 33             	cmp    $0x33,%eax
80100b67:	0f 86 52 03 00 00    	jbe    80100ebf <exec+0x3c3>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100b6d:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b73:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b78:	0f 85 44 03 00 00    	jne    80100ec2 <exec+0x3c6>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100b7e:	e8 92 76 00 00       	call   80108215 <setupkvm>
80100b83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b86:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b8a:	0f 84 35 03 00 00    	je     80100ec5 <exec+0x3c9>
    goto bad;

  // Load program into memory.
  sz = 0;
80100b90:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b97:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b9e:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100ba4:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ba7:	e9 c5 00 00 00       	jmp    80100c71 <exec+0x175>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100baf:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bb6:	00 
80100bb7:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bbb:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bc5:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bc8:	89 04 24             	mov    %eax,(%esp)
80100bcb:	e8 9a 11 00 00       	call   80101d6a <readi>
80100bd0:	83 f8 20             	cmp    $0x20,%eax
80100bd3:	0f 85 ef 02 00 00    	jne    80100ec8 <exec+0x3cc>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100bd9:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bdf:	83 f8 01             	cmp    $0x1,%eax
80100be2:	75 7f                	jne    80100c63 <exec+0x167>
      continue;
    if(ph.memsz < ph.filesz)
80100be4:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100bea:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100bf0:	39 c2                	cmp    %eax,%edx
80100bf2:	0f 82 d3 02 00 00    	jb     80100ecb <exec+0x3cf>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bf8:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100bfe:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c04:	01 d0                	add    %edx,%eax
80100c06:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c11:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c14:	89 04 24             	mov    %eax,(%esp)
80100c17:	e8 cb 79 00 00       	call   801085e7 <allocuvm>
80100c1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c1f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c23:	0f 84 a5 02 00 00    	je     80100ece <exec+0x3d2>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c29:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c2f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c35:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c3b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c3f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c43:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c46:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c51:	89 04 24             	mov    %eax,(%esp)
80100c54:	e8 9f 78 00 00       	call   801084f8 <loaduvm>
80100c59:	85 c0                	test   %eax,%eax
80100c5b:	0f 88 70 02 00 00    	js     80100ed1 <exec+0x3d5>
80100c61:	eb 01                	jmp    80100c64 <exec+0x168>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c63:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c64:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c68:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c6b:	83 c0 20             	add    $0x20,%eax
80100c6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c71:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c78:	0f b7 c0             	movzwl %ax,%eax
80100c7b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c7e:	0f 8f 28 ff ff ff    	jg     80100bac <exec+0xb0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c84:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c87:	89 04 24             	mov    %eax,(%esp)
80100c8a:	e8 69 0e 00 00       	call   80101af8 <iunlockput>
  end_op();
80100c8f:	e8 4e 28 00 00       	call   801034e2 <end_op>
  ip = 0;
80100c94:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100c9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c9e:	05 ff 0f 00 00       	add    $0xfff,%eax
80100ca3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ca8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cae:	05 00 20 00 00       	add    $0x2000,%eax
80100cb3:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cba:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cbe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cc1:	89 04 24             	mov    %eax,(%esp)
80100cc4:	e8 1e 79 00 00       	call   801085e7 <allocuvm>
80100cc9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ccc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cd0:	0f 84 fe 01 00 00    	je     80100ed4 <exec+0x3d8>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd9:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cde:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ce2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ce5:	89 04 24             	mov    %eax,(%esp)
80100ce8:	e8 1e 7b 00 00       	call   8010880b <clearpteu>
  sp = sz;
80100ced:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf0:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100cf3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100cfa:	e9 81 00 00 00       	jmp    80100d80 <exec+0x284>
    if(argc >= MAXARG)
80100cff:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d03:	0f 87 ce 01 00 00    	ja     80100ed7 <exec+0x3db>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d0c:	c1 e0 02             	shl    $0x2,%eax
80100d0f:	03 45 0c             	add    0xc(%ebp),%eax
80100d12:	8b 00                	mov    (%eax),%eax
80100d14:	89 04 24             	mov    %eax,(%esp)
80100d17:	e8 d8 4a 00 00       	call   801057f4 <strlen>
80100d1c:	f7 d0                	not    %eax
80100d1e:	03 45 dc             	add    -0x24(%ebp),%eax
80100d21:	83 e0 fc             	and    $0xfffffffc,%eax
80100d24:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d2a:	c1 e0 02             	shl    $0x2,%eax
80100d2d:	03 45 0c             	add    0xc(%ebp),%eax
80100d30:	8b 00                	mov    (%eax),%eax
80100d32:	89 04 24             	mov    %eax,(%esp)
80100d35:	e8 ba 4a 00 00       	call   801057f4 <strlen>
80100d3a:	83 c0 01             	add    $0x1,%eax
80100d3d:	89 c2                	mov    %eax,%edx
80100d3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d42:	c1 e0 02             	shl    $0x2,%eax
80100d45:	03 45 0c             	add    0xc(%ebp),%eax
80100d48:	8b 00                	mov    (%eax),%eax
80100d4a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d4e:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d52:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d55:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d59:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d5c:	89 04 24             	mov    %eax,(%esp)
80100d5f:	e8 6c 7c 00 00       	call   801089d0 <copyout>
80100d64:	85 c0                	test   %eax,%eax
80100d66:	0f 88 6e 01 00 00    	js     80100eda <exec+0x3de>
      goto bad;
    ustack[3+argc] = sp;
80100d6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d6f:	8d 50 03             	lea    0x3(%eax),%edx
80100d72:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d75:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d7c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d83:	c1 e0 02             	shl    $0x2,%eax
80100d86:	03 45 0c             	add    0xc(%ebp),%eax
80100d89:	8b 00                	mov    (%eax),%eax
80100d8b:	85 c0                	test   %eax,%eax
80100d8d:	0f 85 6c ff ff ff    	jne    80100cff <exec+0x203>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100d93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d96:	83 c0 03             	add    $0x3,%eax
80100d99:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100da0:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100da4:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100dab:	ff ff ff 
  ustack[1] = argc;
80100dae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db1:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100db7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dba:	83 c0 01             	add    $0x1,%eax
80100dbd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dc4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dc7:	29 d0                	sub    %edx,%eax
80100dc9:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100dcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd2:	83 c0 04             	add    $0x4,%eax
80100dd5:	c1 e0 02             	shl    $0x2,%eax
80100dd8:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ddb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dde:	83 c0 04             	add    $0x4,%eax
80100de1:	c1 e0 02             	shl    $0x2,%eax
80100de4:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100de8:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100dee:	89 44 24 08          	mov    %eax,0x8(%esp)
80100df2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100df5:	89 44 24 04          	mov    %eax,0x4(%esp)
80100df9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100dfc:	89 04 24             	mov    %eax,(%esp)
80100dff:	e8 cc 7b 00 00       	call   801089d0 <copyout>
80100e04:	85 c0                	test   %eax,%eax
80100e06:	0f 88 d1 00 00 00    	js     80100edd <exec+0x3e1>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e0c:	8b 45 08             	mov    0x8(%ebp),%eax
80100e0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e15:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e18:	eb 17                	jmp    80100e31 <exec+0x335>
    if(*s == '/')
80100e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e1d:	0f b6 00             	movzbl (%eax),%eax
80100e20:	3c 2f                	cmp    $0x2f,%al
80100e22:	75 09                	jne    80100e2d <exec+0x331>
      last = s+1;
80100e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e27:	83 c0 01             	add    $0x1,%eax
80100e2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e2d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e34:	0f b6 00             	movzbl (%eax),%eax
80100e37:	84 c0                	test   %al,%al
80100e39:	75 df                	jne    80100e1a <exec+0x31e>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e41:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e44:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e4b:	00 
80100e4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e4f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e53:	89 14 24             	mov    %edx,(%esp)
80100e56:	e8 4b 49 00 00       	call   801057a6 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e5b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e61:	8b 40 04             	mov    0x4(%eax),%eax
80100e64:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e6d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e70:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e79:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e7c:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100e7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e84:	8b 40 18             	mov    0x18(%eax),%eax
80100e87:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100e8d:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100e90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e96:	8b 40 18             	mov    0x18(%eax),%eax
80100e99:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100e9c:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100e9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea5:	89 04 24             	mov    %eax,(%esp)
80100ea8:	e8 59 74 00 00       	call   80108306 <switchuvm>
  freevm(oldpgdir);
80100ead:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100eb0:	89 04 24             	mov    %eax,(%esp)
80100eb3:	e8 c5 78 00 00       	call   8010877d <freevm>
  return 0;
80100eb8:	b8 00 00 00 00       	mov    $0x0,%eax
80100ebd:	eb 4b                	jmp    80100f0a <exec+0x40e>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100ebf:	90                   	nop
80100ec0:	eb 1c                	jmp    80100ede <exec+0x3e2>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100ec2:	90                   	nop
80100ec3:	eb 19                	jmp    80100ede <exec+0x3e2>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100ec5:	90                   	nop
80100ec6:	eb 16                	jmp    80100ede <exec+0x3e2>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100ec8:	90                   	nop
80100ec9:	eb 13                	jmp    80100ede <exec+0x3e2>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100ecb:	90                   	nop
80100ecc:	eb 10                	jmp    80100ede <exec+0x3e2>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100ece:	90                   	nop
80100ecf:	eb 0d                	jmp    80100ede <exec+0x3e2>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100ed1:	90                   	nop
80100ed2:	eb 0a                	jmp    80100ede <exec+0x3e2>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100ed4:	90                   	nop
80100ed5:	eb 07                	jmp    80100ede <exec+0x3e2>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100ed7:	90                   	nop
80100ed8:	eb 04                	jmp    80100ede <exec+0x3e2>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100eda:	90                   	nop
80100edb:	eb 01                	jmp    80100ede <exec+0x3e2>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100edd:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100ede:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ee2:	74 0b                	je     80100eef <exec+0x3f3>
    freevm(pgdir);
80100ee4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ee7:	89 04 24             	mov    %eax,(%esp)
80100eea:	e8 8e 78 00 00       	call   8010877d <freevm>
  if(ip){
80100eef:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ef3:	74 10                	je     80100f05 <exec+0x409>
    iunlockput(ip);
80100ef5:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ef8:	89 04 24             	mov    %eax,(%esp)
80100efb:	e8 f8 0b 00 00       	call   80101af8 <iunlockput>
    end_op();
80100f00:	e8 dd 25 00 00       	call   801034e2 <end_op>
  }
  return -1;
80100f05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f0a:	c9                   	leave  
80100f0b:	c3                   	ret    

80100f0c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f0c:	55                   	push   %ebp
80100f0d:	89 e5                	mov    %esp,%ebp
80100f0f:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f12:	c7 44 24 04 d9 8a 10 	movl   $0x80108ad9,0x4(%esp)
80100f19:	80 
80100f1a:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f21:	e8 e0 43 00 00       	call   80105306 <initlock>
}
80100f26:	c9                   	leave  
80100f27:	c3                   	ret    

80100f28 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f28:	55                   	push   %ebp
80100f29:	89 e5                	mov    %esp,%ebp
80100f2b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f2e:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f35:	e8 ed 43 00 00       	call   80105327 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f3a:	c7 45 f4 94 18 11 80 	movl   $0x80111894,-0xc(%ebp)
80100f41:	eb 29                	jmp    80100f6c <filealloc+0x44>
    if(f->ref == 0){
80100f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f46:	8b 40 04             	mov    0x4(%eax),%eax
80100f49:	85 c0                	test   %eax,%eax
80100f4b:	75 1b                	jne    80100f68 <filealloc+0x40>
      f->ref = 1;
80100f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f50:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f57:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f5e:	e8 26 44 00 00       	call   80105389 <release>
      return f;
80100f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f66:	eb 1e                	jmp    80100f86 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f68:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f6c:	81 7d f4 f4 21 11 80 	cmpl   $0x801121f4,-0xc(%ebp)
80100f73:	72 ce                	jb     80100f43 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f75:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f7c:	e8 08 44 00 00       	call   80105389 <release>
  return 0;
80100f81:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f86:	c9                   	leave  
80100f87:	c3                   	ret    

80100f88 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f88:	55                   	push   %ebp
80100f89:	89 e5                	mov    %esp,%ebp
80100f8b:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f8e:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f95:	e8 8d 43 00 00       	call   80105327 <acquire>
  if(f->ref < 1)
80100f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9d:	8b 40 04             	mov    0x4(%eax),%eax
80100fa0:	85 c0                	test   %eax,%eax
80100fa2:	7f 0c                	jg     80100fb0 <filedup+0x28>
    panic("filedup");
80100fa4:	c7 04 24 e0 8a 10 80 	movl   $0x80108ae0,(%esp)
80100fab:	e8 8d f5 ff ff       	call   8010053d <panic>
  f->ref++;
80100fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb3:	8b 40 04             	mov    0x4(%eax),%eax
80100fb6:	8d 50 01             	lea    0x1(%eax),%edx
80100fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fbc:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fbf:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100fc6:	e8 be 43 00 00       	call   80105389 <release>
  return f;
80100fcb:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fce:	c9                   	leave  
80100fcf:	c3                   	ret    

80100fd0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fd0:	55                   	push   %ebp
80100fd1:	89 e5                	mov    %esp,%ebp
80100fd3:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fd6:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100fdd:	e8 45 43 00 00       	call   80105327 <acquire>
  if(f->ref < 1)
80100fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe5:	8b 40 04             	mov    0x4(%eax),%eax
80100fe8:	85 c0                	test   %eax,%eax
80100fea:	7f 0c                	jg     80100ff8 <fileclose+0x28>
    panic("fileclose");
80100fec:	c7 04 24 e8 8a 10 80 	movl   $0x80108ae8,(%esp)
80100ff3:	e8 45 f5 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80100ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffb:	8b 40 04             	mov    0x4(%eax),%eax
80100ffe:	8d 50 ff             	lea    -0x1(%eax),%edx
80101001:	8b 45 08             	mov    0x8(%ebp),%eax
80101004:	89 50 04             	mov    %edx,0x4(%eax)
80101007:	8b 45 08             	mov    0x8(%ebp),%eax
8010100a:	8b 40 04             	mov    0x4(%eax),%eax
8010100d:	85 c0                	test   %eax,%eax
8010100f:	7e 11                	jle    80101022 <fileclose+0x52>
    release(&ftable.lock);
80101011:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80101018:	e8 6c 43 00 00       	call   80105389 <release>
    return;
8010101d:	e9 82 00 00 00       	jmp    801010a4 <fileclose+0xd4>
  }
  ff = *f;
80101022:	8b 45 08             	mov    0x8(%ebp),%eax
80101025:	8b 10                	mov    (%eax),%edx
80101027:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010102a:	8b 50 04             	mov    0x4(%eax),%edx
8010102d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101030:	8b 50 08             	mov    0x8(%eax),%edx
80101033:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101036:	8b 50 0c             	mov    0xc(%eax),%edx
80101039:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010103c:	8b 50 10             	mov    0x10(%eax),%edx
8010103f:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101042:	8b 40 14             	mov    0x14(%eax),%eax
80101045:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101048:	8b 45 08             	mov    0x8(%ebp),%eax
8010104b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101052:	8b 45 08             	mov    0x8(%ebp),%eax
80101055:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010105b:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80101062:	e8 22 43 00 00       	call   80105389 <release>
  
  if(ff.type == FD_PIPE)
80101067:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010106a:	83 f8 01             	cmp    $0x1,%eax
8010106d:	75 18                	jne    80101087 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010106f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101073:	0f be d0             	movsbl %al,%edx
80101076:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101079:	89 54 24 04          	mov    %edx,0x4(%esp)
8010107d:	89 04 24             	mov    %eax,(%esp)
80101080:	e8 36 30 00 00       	call   801040bb <pipeclose>
80101085:	eb 1d                	jmp    801010a4 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101087:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010108a:	83 f8 02             	cmp    $0x2,%eax
8010108d:	75 15                	jne    801010a4 <fileclose+0xd4>
    begin_op();
8010108f:	e8 cd 23 00 00       	call   80103461 <begin_op>
    iput(ff.ip);
80101094:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101097:	89 04 24             	mov    %eax,(%esp)
8010109a:	e8 88 09 00 00       	call   80101a27 <iput>
    end_op();
8010109f:	e8 3e 24 00 00       	call   801034e2 <end_op>
  }
}
801010a4:	c9                   	leave  
801010a5:	c3                   	ret    

801010a6 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010a6:	55                   	push   %ebp
801010a7:	89 e5                	mov    %esp,%ebp
801010a9:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010ac:	8b 45 08             	mov    0x8(%ebp),%eax
801010af:	8b 00                	mov    (%eax),%eax
801010b1:	83 f8 02             	cmp    $0x2,%eax
801010b4:	75 38                	jne    801010ee <filestat+0x48>
    ilock(f->ip);
801010b6:	8b 45 08             	mov    0x8(%ebp),%eax
801010b9:	8b 40 10             	mov    0x10(%eax),%eax
801010bc:	89 04 24             	mov    %eax,(%esp)
801010bf:	e8 b0 07 00 00       	call   80101874 <ilock>
    stati(f->ip, st);
801010c4:	8b 45 08             	mov    0x8(%ebp),%eax
801010c7:	8b 40 10             	mov    0x10(%eax),%eax
801010ca:	8b 55 0c             	mov    0xc(%ebp),%edx
801010cd:	89 54 24 04          	mov    %edx,0x4(%esp)
801010d1:	89 04 24             	mov    %eax,(%esp)
801010d4:	e8 4c 0c 00 00       	call   80101d25 <stati>
    iunlock(f->ip);
801010d9:	8b 45 08             	mov    0x8(%ebp),%eax
801010dc:	8b 40 10             	mov    0x10(%eax),%eax
801010df:	89 04 24             	mov    %eax,(%esp)
801010e2:	e8 db 08 00 00       	call   801019c2 <iunlock>
    return 0;
801010e7:	b8 00 00 00 00       	mov    $0x0,%eax
801010ec:	eb 05                	jmp    801010f3 <filestat+0x4d>
  }
  return -1;
801010ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010f3:	c9                   	leave  
801010f4:	c3                   	ret    

801010f5 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010f5:	55                   	push   %ebp
801010f6:	89 e5                	mov    %esp,%ebp
801010f8:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801010fb:	8b 45 08             	mov    0x8(%ebp),%eax
801010fe:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101102:	84 c0                	test   %al,%al
80101104:	75 0a                	jne    80101110 <fileread+0x1b>
    return -1;
80101106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010110b:	e9 9f 00 00 00       	jmp    801011af <fileread+0xba>
  if(f->type == FD_PIPE)
80101110:	8b 45 08             	mov    0x8(%ebp),%eax
80101113:	8b 00                	mov    (%eax),%eax
80101115:	83 f8 01             	cmp    $0x1,%eax
80101118:	75 1e                	jne    80101138 <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010111a:	8b 45 08             	mov    0x8(%ebp),%eax
8010111d:	8b 40 0c             	mov    0xc(%eax),%eax
80101120:	8b 55 10             	mov    0x10(%ebp),%edx
80101123:	89 54 24 08          	mov    %edx,0x8(%esp)
80101127:	8b 55 0c             	mov    0xc(%ebp),%edx
8010112a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010112e:	89 04 24             	mov    %eax,(%esp)
80101131:	e8 07 31 00 00       	call   8010423d <piperead>
80101136:	eb 77                	jmp    801011af <fileread+0xba>
  if(f->type == FD_INODE){
80101138:	8b 45 08             	mov    0x8(%ebp),%eax
8010113b:	8b 00                	mov    (%eax),%eax
8010113d:	83 f8 02             	cmp    $0x2,%eax
80101140:	75 61                	jne    801011a3 <fileread+0xae>
    ilock(f->ip);
80101142:	8b 45 08             	mov    0x8(%ebp),%eax
80101145:	8b 40 10             	mov    0x10(%eax),%eax
80101148:	89 04 24             	mov    %eax,(%esp)
8010114b:	e8 24 07 00 00       	call   80101874 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101150:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101153:	8b 45 08             	mov    0x8(%ebp),%eax
80101156:	8b 50 14             	mov    0x14(%eax),%edx
80101159:	8b 45 08             	mov    0x8(%ebp),%eax
8010115c:	8b 40 10             	mov    0x10(%eax),%eax
8010115f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101163:	89 54 24 08          	mov    %edx,0x8(%esp)
80101167:	8b 55 0c             	mov    0xc(%ebp),%edx
8010116a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010116e:	89 04 24             	mov    %eax,(%esp)
80101171:	e8 f4 0b 00 00       	call   80101d6a <readi>
80101176:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101179:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010117d:	7e 11                	jle    80101190 <fileread+0x9b>
      f->off += r;
8010117f:	8b 45 08             	mov    0x8(%ebp),%eax
80101182:	8b 50 14             	mov    0x14(%eax),%edx
80101185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101188:	01 c2                	add    %eax,%edx
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101190:	8b 45 08             	mov    0x8(%ebp),%eax
80101193:	8b 40 10             	mov    0x10(%eax),%eax
80101196:	89 04 24             	mov    %eax,(%esp)
80101199:	e8 24 08 00 00       	call   801019c2 <iunlock>
    return r;
8010119e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011a1:	eb 0c                	jmp    801011af <fileread+0xba>
  }
  panic("fileread");
801011a3:	c7 04 24 f2 8a 10 80 	movl   $0x80108af2,(%esp)
801011aa:	e8 8e f3 ff ff       	call   8010053d <panic>
}
801011af:	c9                   	leave  
801011b0:	c3                   	ret    

801011b1 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011b1:	55                   	push   %ebp
801011b2:	89 e5                	mov    %esp,%ebp
801011b4:	53                   	push   %ebx
801011b5:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011b8:	8b 45 08             	mov    0x8(%ebp),%eax
801011bb:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011bf:	84 c0                	test   %al,%al
801011c1:	75 0a                	jne    801011cd <filewrite+0x1c>
    return -1;
801011c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011c8:	e9 23 01 00 00       	jmp    801012f0 <filewrite+0x13f>
  if(f->type == FD_PIPE)
801011cd:	8b 45 08             	mov    0x8(%ebp),%eax
801011d0:	8b 00                	mov    (%eax),%eax
801011d2:	83 f8 01             	cmp    $0x1,%eax
801011d5:	75 21                	jne    801011f8 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011d7:	8b 45 08             	mov    0x8(%ebp),%eax
801011da:	8b 40 0c             	mov    0xc(%eax),%eax
801011dd:	8b 55 10             	mov    0x10(%ebp),%edx
801011e0:	89 54 24 08          	mov    %edx,0x8(%esp)
801011e4:	8b 55 0c             	mov    0xc(%ebp),%edx
801011e7:	89 54 24 04          	mov    %edx,0x4(%esp)
801011eb:	89 04 24             	mov    %eax,(%esp)
801011ee:	e8 5a 2f 00 00       	call   8010414d <pipewrite>
801011f3:	e9 f8 00 00 00       	jmp    801012f0 <filewrite+0x13f>
  if(f->type == FD_INODE){
801011f8:	8b 45 08             	mov    0x8(%ebp),%eax
801011fb:	8b 00                	mov    (%eax),%eax
801011fd:	83 f8 02             	cmp    $0x2,%eax
80101200:	0f 85 de 00 00 00    	jne    801012e4 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101206:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010120d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101214:	e9 a8 00 00 00       	jmp    801012c1 <filewrite+0x110>
      int n1 = n - i;
80101219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121c:	8b 55 10             	mov    0x10(%ebp),%edx
8010121f:	89 d1                	mov    %edx,%ecx
80101221:	29 c1                	sub    %eax,%ecx
80101223:	89 c8                	mov    %ecx,%eax
80101225:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101228:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010122b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010122e:	7e 06                	jle    80101236 <filewrite+0x85>
        n1 = max;
80101230:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101233:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101236:	e8 26 22 00 00       	call   80103461 <begin_op>
      ilock(f->ip);
8010123b:	8b 45 08             	mov    0x8(%ebp),%eax
8010123e:	8b 40 10             	mov    0x10(%eax),%eax
80101241:	89 04 24             	mov    %eax,(%esp)
80101244:	e8 2b 06 00 00       	call   80101874 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101249:	8b 5d f0             	mov    -0x10(%ebp),%ebx
8010124c:	8b 45 08             	mov    0x8(%ebp),%eax
8010124f:	8b 48 14             	mov    0x14(%eax),%ecx
80101252:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101255:	89 c2                	mov    %eax,%edx
80101257:	03 55 0c             	add    0xc(%ebp),%edx
8010125a:	8b 45 08             	mov    0x8(%ebp),%eax
8010125d:	8b 40 10             	mov    0x10(%eax),%eax
80101260:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80101264:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80101268:	89 54 24 04          	mov    %edx,0x4(%esp)
8010126c:	89 04 24             	mov    %eax,(%esp)
8010126f:	e8 61 0c 00 00       	call   80101ed5 <writei>
80101274:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101277:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010127b:	7e 11                	jle    8010128e <filewrite+0xdd>
        f->off += r;
8010127d:	8b 45 08             	mov    0x8(%ebp),%eax
80101280:	8b 50 14             	mov    0x14(%eax),%edx
80101283:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101286:	01 c2                	add    %eax,%edx
80101288:	8b 45 08             	mov    0x8(%ebp),%eax
8010128b:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010128e:	8b 45 08             	mov    0x8(%ebp),%eax
80101291:	8b 40 10             	mov    0x10(%eax),%eax
80101294:	89 04 24             	mov    %eax,(%esp)
80101297:	e8 26 07 00 00       	call   801019c2 <iunlock>
      end_op();
8010129c:	e8 41 22 00 00       	call   801034e2 <end_op>

      if(r < 0)
801012a1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012a5:	78 28                	js     801012cf <filewrite+0x11e>
        break;
      if(r != n1)
801012a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012aa:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012ad:	74 0c                	je     801012bb <filewrite+0x10a>
        panic("short filewrite");
801012af:	c7 04 24 fb 8a 10 80 	movl   $0x80108afb,(%esp)
801012b6:	e8 82 f2 ff ff       	call   8010053d <panic>
      i += r;
801012bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012be:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c4:	3b 45 10             	cmp    0x10(%ebp),%eax
801012c7:	0f 8c 4c ff ff ff    	jl     80101219 <filewrite+0x68>
801012cd:	eb 01                	jmp    801012d0 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
801012cf:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012d3:	3b 45 10             	cmp    0x10(%ebp),%eax
801012d6:	75 05                	jne    801012dd <filewrite+0x12c>
801012d8:	8b 45 10             	mov    0x10(%ebp),%eax
801012db:	eb 05                	jmp    801012e2 <filewrite+0x131>
801012dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012e2:	eb 0c                	jmp    801012f0 <filewrite+0x13f>
  }
  panic("filewrite");
801012e4:	c7 04 24 0b 8b 10 80 	movl   $0x80108b0b,(%esp)
801012eb:	e8 4d f2 ff ff       	call   8010053d <panic>
}
801012f0:	83 c4 24             	add    $0x24,%esp
801012f3:	5b                   	pop    %ebx
801012f4:	5d                   	pop    %ebp
801012f5:	c3                   	ret    
	...

801012f8 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801012f8:	55                   	push   %ebp
801012f9:	89 e5                	mov    %esp,%ebp
801012fb:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801012fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101301:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101308:	00 
80101309:	89 04 24             	mov    %eax,(%esp)
8010130c:	e8 95 ee ff ff       	call   801001a6 <bread>
80101311:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101317:	83 c0 18             	add    $0x18,%eax
8010131a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101321:	00 
80101322:	89 44 24 04          	mov    %eax,0x4(%esp)
80101326:	8b 45 0c             	mov    0xc(%ebp),%eax
80101329:	89 04 24             	mov    %eax,(%esp)
8010132c:	e8 18 43 00 00       	call   80105649 <memmove>
  brelse(bp);
80101331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101334:	89 04 24             	mov    %eax,(%esp)
80101337:	e8 db ee ff ff       	call   80100217 <brelse>
}
8010133c:	c9                   	leave  
8010133d:	c3                   	ret    

8010133e <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010133e:	55                   	push   %ebp
8010133f:	89 e5                	mov    %esp,%ebp
80101341:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101344:	8b 55 0c             	mov    0xc(%ebp),%edx
80101347:	8b 45 08             	mov    0x8(%ebp),%eax
8010134a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010134e:	89 04 24             	mov    %eax,(%esp)
80101351:	e8 50 ee ff ff       	call   801001a6 <bread>
80101356:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010135c:	83 c0 18             	add    $0x18,%eax
8010135f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101366:	00 
80101367:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010136e:	00 
8010136f:	89 04 24             	mov    %eax,(%esp)
80101372:	e8 ff 41 00 00       	call   80105576 <memset>
  log_write(bp);
80101377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010137a:	89 04 24             	mov    %eax,(%esp)
8010137d:	e8 e4 22 00 00       	call   80103666 <log_write>
  brelse(bp);
80101382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101385:	89 04 24             	mov    %eax,(%esp)
80101388:	e8 8a ee ff ff       	call   80100217 <brelse>
}
8010138d:	c9                   	leave  
8010138e:	c3                   	ret    

8010138f <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010138f:	55                   	push   %ebp
80101390:	89 e5                	mov    %esp,%ebp
80101392:	53                   	push   %ebx
80101393:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101396:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
8010139d:	8b 45 08             	mov    0x8(%ebp),%eax
801013a0:	8d 55 d8             	lea    -0x28(%ebp),%edx
801013a3:	89 54 24 04          	mov    %edx,0x4(%esp)
801013a7:	89 04 24             	mov    %eax,(%esp)
801013aa:	e8 49 ff ff ff       	call   801012f8 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801013af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013b6:	e9 11 01 00 00       	jmp    801014cc <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013be:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013c4:	85 c0                	test   %eax,%eax
801013c6:	0f 48 c2             	cmovs  %edx,%eax
801013c9:	c1 f8 0c             	sar    $0xc,%eax
801013cc:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013cf:	c1 ea 03             	shr    $0x3,%edx
801013d2:	01 d0                	add    %edx,%eax
801013d4:	83 c0 03             	add    $0x3,%eax
801013d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801013db:	8b 45 08             	mov    0x8(%ebp),%eax
801013de:	89 04 24             	mov    %eax,(%esp)
801013e1:	e8 c0 ed ff ff       	call   801001a6 <bread>
801013e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013e9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013f0:	e9 a7 00 00 00       	jmp    8010149c <balloc+0x10d>
      m = 1 << (bi % 8);
801013f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f8:	89 c2                	mov    %eax,%edx
801013fa:	c1 fa 1f             	sar    $0x1f,%edx
801013fd:	c1 ea 1d             	shr    $0x1d,%edx
80101400:	01 d0                	add    %edx,%eax
80101402:	83 e0 07             	and    $0x7,%eax
80101405:	29 d0                	sub    %edx,%eax
80101407:	ba 01 00 00 00       	mov    $0x1,%edx
8010140c:	89 d3                	mov    %edx,%ebx
8010140e:	89 c1                	mov    %eax,%ecx
80101410:	d3 e3                	shl    %cl,%ebx
80101412:	89 d8                	mov    %ebx,%eax
80101414:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101417:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010141a:	8d 50 07             	lea    0x7(%eax),%edx
8010141d:	85 c0                	test   %eax,%eax
8010141f:	0f 48 c2             	cmovs  %edx,%eax
80101422:	c1 f8 03             	sar    $0x3,%eax
80101425:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101428:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010142d:	0f b6 c0             	movzbl %al,%eax
80101430:	23 45 e8             	and    -0x18(%ebp),%eax
80101433:	85 c0                	test   %eax,%eax
80101435:	75 61                	jne    80101498 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
80101437:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010143a:	8d 50 07             	lea    0x7(%eax),%edx
8010143d:	85 c0                	test   %eax,%eax
8010143f:	0f 48 c2             	cmovs  %edx,%eax
80101442:	c1 f8 03             	sar    $0x3,%eax
80101445:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101448:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010144d:	89 d1                	mov    %edx,%ecx
8010144f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101452:	09 ca                	or     %ecx,%edx
80101454:	89 d1                	mov    %edx,%ecx
80101456:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101459:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010145d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101460:	89 04 24             	mov    %eax,(%esp)
80101463:	e8 fe 21 00 00       	call   80103666 <log_write>
        brelse(bp);
80101468:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010146b:	89 04 24             	mov    %eax,(%esp)
8010146e:	e8 a4 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101473:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101476:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101479:	01 c2                	add    %eax,%edx
8010147b:	8b 45 08             	mov    0x8(%ebp),%eax
8010147e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101482:	89 04 24             	mov    %eax,(%esp)
80101485:	e8 b4 fe ff ff       	call   8010133e <bzero>
        return b + bi;
8010148a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010148d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101490:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
80101492:	83 c4 34             	add    $0x34,%esp
80101495:	5b                   	pop    %ebx
80101496:	5d                   	pop    %ebp
80101497:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101498:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010149c:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014a3:	7f 15                	jg     801014ba <balloc+0x12b>
801014a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ab:	01 d0                	add    %edx,%eax
801014ad:	89 c2                	mov    %eax,%edx
801014af:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014b2:	39 c2                	cmp    %eax,%edx
801014b4:	0f 82 3b ff ff ff    	jb     801013f5 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014bd:	89 04 24             	mov    %eax,(%esp)
801014c0:	e8 52 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014c5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014d2:	39 c2                	cmp    %eax,%edx
801014d4:	0f 82 e1 fe ff ff    	jb     801013bb <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014da:	c7 04 24 15 8b 10 80 	movl   $0x80108b15,(%esp)
801014e1:	e8 57 f0 ff ff       	call   8010053d <panic>

801014e6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014e6:	55                   	push   %ebp
801014e7:	89 e5                	mov    %esp,%ebp
801014e9:	53                   	push   %ebx
801014ea:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014ed:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801014f4:	8b 45 08             	mov    0x8(%ebp),%eax
801014f7:	89 04 24             	mov    %eax,(%esp)
801014fa:	e8 f9 fd ff ff       	call   801012f8 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801014ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80101502:	89 c2                	mov    %eax,%edx
80101504:	c1 ea 0c             	shr    $0xc,%edx
80101507:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010150a:	c1 e8 03             	shr    $0x3,%eax
8010150d:	01 d0                	add    %edx,%eax
8010150f:	8d 50 03             	lea    0x3(%eax),%edx
80101512:	8b 45 08             	mov    0x8(%ebp),%eax
80101515:	89 54 24 04          	mov    %edx,0x4(%esp)
80101519:	89 04 24             	mov    %eax,(%esp)
8010151c:	e8 85 ec ff ff       	call   801001a6 <bread>
80101521:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101524:	8b 45 0c             	mov    0xc(%ebp),%eax
80101527:	25 ff 0f 00 00       	and    $0xfff,%eax
8010152c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010152f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101532:	89 c2                	mov    %eax,%edx
80101534:	c1 fa 1f             	sar    $0x1f,%edx
80101537:	c1 ea 1d             	shr    $0x1d,%edx
8010153a:	01 d0                	add    %edx,%eax
8010153c:	83 e0 07             	and    $0x7,%eax
8010153f:	29 d0                	sub    %edx,%eax
80101541:	ba 01 00 00 00       	mov    $0x1,%edx
80101546:	89 d3                	mov    %edx,%ebx
80101548:	89 c1                	mov    %eax,%ecx
8010154a:	d3 e3                	shl    %cl,%ebx
8010154c:	89 d8                	mov    %ebx,%eax
8010154e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101551:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101554:	8d 50 07             	lea    0x7(%eax),%edx
80101557:	85 c0                	test   %eax,%eax
80101559:	0f 48 c2             	cmovs  %edx,%eax
8010155c:	c1 f8 03             	sar    $0x3,%eax
8010155f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101562:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101567:	0f b6 c0             	movzbl %al,%eax
8010156a:	23 45 ec             	and    -0x14(%ebp),%eax
8010156d:	85 c0                	test   %eax,%eax
8010156f:	75 0c                	jne    8010157d <bfree+0x97>
    panic("freeing free block");
80101571:	c7 04 24 2b 8b 10 80 	movl   $0x80108b2b,(%esp)
80101578:	e8 c0 ef ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
8010157d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101580:	8d 50 07             	lea    0x7(%eax),%edx
80101583:	85 c0                	test   %eax,%eax
80101585:	0f 48 c2             	cmovs  %edx,%eax
80101588:	c1 f8 03             	sar    $0x3,%eax
8010158b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010158e:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101593:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101596:	f7 d1                	not    %ecx
80101598:	21 ca                	and    %ecx,%edx
8010159a:	89 d1                	mov    %edx,%ecx
8010159c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159f:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801015a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a6:	89 04 24             	mov    %eax,(%esp)
801015a9:	e8 b8 20 00 00       	call   80103666 <log_write>
  brelse(bp);
801015ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015b1:	89 04 24             	mov    %eax,(%esp)
801015b4:	e8 5e ec ff ff       	call   80100217 <brelse>
}
801015b9:	83 c4 34             	add    $0x34,%esp
801015bc:	5b                   	pop    %ebx
801015bd:	5d                   	pop    %ebp
801015be:	c3                   	ret    

801015bf <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015bf:	55                   	push   %ebp
801015c0:	89 e5                	mov    %esp,%ebp
801015c2:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801015c5:	c7 44 24 04 3e 8b 10 	movl   $0x80108b3e,0x4(%esp)
801015cc:	80 
801015cd:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801015d4:	e8 2d 3d 00 00       	call   80105306 <initlock>
}
801015d9:	c9                   	leave  
801015da:	c3                   	ret    

801015db <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015db:	55                   	push   %ebp
801015dc:	89 e5                	mov    %esp,%ebp
801015de:	83 ec 48             	sub    $0x48,%esp
801015e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e4:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015e8:	8b 45 08             	mov    0x8(%ebp),%eax
801015eb:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015ee:	89 54 24 04          	mov    %edx,0x4(%esp)
801015f2:	89 04 24             	mov    %eax,(%esp)
801015f5:	e8 fe fc ff ff       	call   801012f8 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801015fa:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101601:	e9 98 00 00 00       	jmp    8010169e <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
80101606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101609:	c1 e8 03             	shr    $0x3,%eax
8010160c:	83 c0 02             	add    $0x2,%eax
8010160f:	89 44 24 04          	mov    %eax,0x4(%esp)
80101613:	8b 45 08             	mov    0x8(%ebp),%eax
80101616:	89 04 24             	mov    %eax,(%esp)
80101619:	e8 88 eb ff ff       	call   801001a6 <bread>
8010161e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101621:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101624:	8d 50 18             	lea    0x18(%eax),%edx
80101627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010162a:	83 e0 07             	and    $0x7,%eax
8010162d:	c1 e0 06             	shl    $0x6,%eax
80101630:	01 d0                	add    %edx,%eax
80101632:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101635:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101638:	0f b7 00             	movzwl (%eax),%eax
8010163b:	66 85 c0             	test   %ax,%ax
8010163e:	75 4f                	jne    8010168f <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101640:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101647:	00 
80101648:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010164f:	00 
80101650:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101653:	89 04 24             	mov    %eax,(%esp)
80101656:	e8 1b 3f 00 00       	call   80105576 <memset>
      dip->type = type;
8010165b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010165e:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101662:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101665:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101668:	89 04 24             	mov    %eax,(%esp)
8010166b:	e8 f6 1f 00 00       	call   80103666 <log_write>
      brelse(bp);
80101670:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101673:	89 04 24             	mov    %eax,(%esp)
80101676:	e8 9c eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
8010167b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010167e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101682:	8b 45 08             	mov    0x8(%ebp),%eax
80101685:	89 04 24             	mov    %eax,(%esp)
80101688:	e8 e3 00 00 00       	call   80101770 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
8010168d:	c9                   	leave  
8010168e:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
8010168f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101692:	89 04 24             	mov    %eax,(%esp)
80101695:	e8 7d eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010169a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010169e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801016a4:	39 c2                	cmp    %eax,%edx
801016a6:	0f 82 5a ff ff ff    	jb     80101606 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801016ac:	c7 04 24 45 8b 10 80 	movl   $0x80108b45,(%esp)
801016b3:	e8 85 ee ff ff       	call   8010053d <panic>

801016b8 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801016b8:	55                   	push   %ebp
801016b9:	89 e5                	mov    %esp,%ebp
801016bb:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016be:	8b 45 08             	mov    0x8(%ebp),%eax
801016c1:	8b 40 04             	mov    0x4(%eax),%eax
801016c4:	c1 e8 03             	shr    $0x3,%eax
801016c7:	8d 50 02             	lea    0x2(%eax),%edx
801016ca:	8b 45 08             	mov    0x8(%ebp),%eax
801016cd:	8b 00                	mov    (%eax),%eax
801016cf:	89 54 24 04          	mov    %edx,0x4(%esp)
801016d3:	89 04 24             	mov    %eax,(%esp)
801016d6:	e8 cb ea ff ff       	call   801001a6 <bread>
801016db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e1:	8d 50 18             	lea    0x18(%eax),%edx
801016e4:	8b 45 08             	mov    0x8(%ebp),%eax
801016e7:	8b 40 04             	mov    0x4(%eax),%eax
801016ea:	83 e0 07             	and    $0x7,%eax
801016ed:	c1 e0 06             	shl    $0x6,%eax
801016f0:	01 d0                	add    %edx,%eax
801016f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016f5:	8b 45 08             	mov    0x8(%ebp),%eax
801016f8:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801016fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ff:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101702:	8b 45 08             	mov    0x8(%ebp),%eax
80101705:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101709:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170c:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101710:	8b 45 08             	mov    0x8(%ebp),%eax
80101713:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101717:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171a:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010171e:	8b 45 08             	mov    0x8(%ebp),%eax
80101721:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101725:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101728:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010172c:	8b 45 08             	mov    0x8(%ebp),%eax
8010172f:	8b 50 18             	mov    0x18(%eax),%edx
80101732:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101735:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101738:	8b 45 08             	mov    0x8(%ebp),%eax
8010173b:	8d 50 1c             	lea    0x1c(%eax),%edx
8010173e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101741:	83 c0 0c             	add    $0xc,%eax
80101744:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010174b:	00 
8010174c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101750:	89 04 24             	mov    %eax,(%esp)
80101753:	e8 f1 3e 00 00       	call   80105649 <memmove>
  log_write(bp);
80101758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175b:	89 04 24             	mov    %eax,(%esp)
8010175e:	e8 03 1f 00 00       	call   80103666 <log_write>
  brelse(bp);
80101763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101766:	89 04 24             	mov    %eax,(%esp)
80101769:	e8 a9 ea ff ff       	call   80100217 <brelse>
}
8010176e:	c9                   	leave  
8010176f:	c3                   	ret    

80101770 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101770:	55                   	push   %ebp
80101771:	89 e5                	mov    %esp,%ebp
80101773:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101776:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010177d:	e8 a5 3b 00 00       	call   80105327 <acquire>

  // Is the inode already cached?
  empty = 0;
80101782:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101789:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
80101790:	eb 59                	jmp    801017eb <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101792:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101795:	8b 40 08             	mov    0x8(%eax),%eax
80101798:	85 c0                	test   %eax,%eax
8010179a:	7e 35                	jle    801017d1 <iget+0x61>
8010179c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010179f:	8b 00                	mov    (%eax),%eax
801017a1:	3b 45 08             	cmp    0x8(%ebp),%eax
801017a4:	75 2b                	jne    801017d1 <iget+0x61>
801017a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a9:	8b 40 04             	mov    0x4(%eax),%eax
801017ac:	3b 45 0c             	cmp    0xc(%ebp),%eax
801017af:	75 20                	jne    801017d1 <iget+0x61>
      ip->ref++;
801017b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b4:	8b 40 08             	mov    0x8(%eax),%eax
801017b7:	8d 50 01             	lea    0x1(%eax),%edx
801017ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017bd:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017c0:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801017c7:	e8 bd 3b 00 00       	call   80105389 <release>
      return ip;
801017cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017cf:	eb 6f                	jmp    80101840 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017d5:	75 10                	jne    801017e7 <iget+0x77>
801017d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017da:	8b 40 08             	mov    0x8(%eax),%eax
801017dd:	85 c0                	test   %eax,%eax
801017df:	75 06                	jne    801017e7 <iget+0x77>
      empty = ip;
801017e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017e7:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801017eb:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
801017f2:	72 9e                	jb     80101792 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017f8:	75 0c                	jne    80101806 <iget+0x96>
    panic("iget: no inodes");
801017fa:	c7 04 24 57 8b 10 80 	movl   $0x80108b57,(%esp)
80101801:	e8 37 ed ff ff       	call   8010053d <panic>

  ip = empty;
80101806:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101809:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010180c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180f:	8b 55 08             	mov    0x8(%ebp),%edx
80101812:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101817:	8b 55 0c             	mov    0xc(%ebp),%edx
8010181a:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010181d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101820:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101831:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101838:	e8 4c 3b 00 00       	call   80105389 <release>

  return ip;
8010183d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101840:	c9                   	leave  
80101841:	c3                   	ret    

80101842 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101842:	55                   	push   %ebp
80101843:	89 e5                	mov    %esp,%ebp
80101845:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101848:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010184f:	e8 d3 3a 00 00       	call   80105327 <acquire>
  ip->ref++;
80101854:	8b 45 08             	mov    0x8(%ebp),%eax
80101857:	8b 40 08             	mov    0x8(%eax),%eax
8010185a:	8d 50 01             	lea    0x1(%eax),%edx
8010185d:	8b 45 08             	mov    0x8(%ebp),%eax
80101860:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101863:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010186a:	e8 1a 3b 00 00       	call   80105389 <release>
  return ip;
8010186f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101872:	c9                   	leave  
80101873:	c3                   	ret    

80101874 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101874:	55                   	push   %ebp
80101875:	89 e5                	mov    %esp,%ebp
80101877:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010187a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010187e:	74 0a                	je     8010188a <ilock+0x16>
80101880:	8b 45 08             	mov    0x8(%ebp),%eax
80101883:	8b 40 08             	mov    0x8(%eax),%eax
80101886:	85 c0                	test   %eax,%eax
80101888:	7f 0c                	jg     80101896 <ilock+0x22>
    panic("ilock");
8010188a:	c7 04 24 67 8b 10 80 	movl   $0x80108b67,(%esp)
80101891:	e8 a7 ec ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101896:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010189d:	e8 85 3a 00 00       	call   80105327 <acquire>
  while(ip->flags & I_BUSY)
801018a2:	eb 13                	jmp    801018b7 <ilock+0x43>
    sleep(ip, &icache.lock);
801018a4:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
801018ab:	80 
801018ac:	8b 45 08             	mov    0x8(%ebp),%eax
801018af:	89 04 24             	mov    %eax,(%esp)
801018b2:	e8 89 37 00 00       	call   80105040 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801018b7:	8b 45 08             	mov    0x8(%ebp),%eax
801018ba:	8b 40 0c             	mov    0xc(%eax),%eax
801018bd:	83 e0 01             	and    $0x1,%eax
801018c0:	84 c0                	test   %al,%al
801018c2:	75 e0                	jne    801018a4 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801018c4:	8b 45 08             	mov    0x8(%ebp),%eax
801018c7:	8b 40 0c             	mov    0xc(%eax),%eax
801018ca:	89 c2                	mov    %eax,%edx
801018cc:	83 ca 01             	or     $0x1,%edx
801018cf:	8b 45 08             	mov    0x8(%ebp),%eax
801018d2:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018d5:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801018dc:	e8 a8 3a 00 00       	call   80105389 <release>

  if(!(ip->flags & I_VALID)){
801018e1:	8b 45 08             	mov    0x8(%ebp),%eax
801018e4:	8b 40 0c             	mov    0xc(%eax),%eax
801018e7:	83 e0 02             	and    $0x2,%eax
801018ea:	85 c0                	test   %eax,%eax
801018ec:	0f 85 ce 00 00 00    	jne    801019c0 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018f2:	8b 45 08             	mov    0x8(%ebp),%eax
801018f5:	8b 40 04             	mov    0x4(%eax),%eax
801018f8:	c1 e8 03             	shr    $0x3,%eax
801018fb:	8d 50 02             	lea    0x2(%eax),%edx
801018fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101901:	8b 00                	mov    (%eax),%eax
80101903:	89 54 24 04          	mov    %edx,0x4(%esp)
80101907:	89 04 24             	mov    %eax,(%esp)
8010190a:	e8 97 e8 ff ff       	call   801001a6 <bread>
8010190f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101915:	8d 50 18             	lea    0x18(%eax),%edx
80101918:	8b 45 08             	mov    0x8(%ebp),%eax
8010191b:	8b 40 04             	mov    0x4(%eax),%eax
8010191e:	83 e0 07             	and    $0x7,%eax
80101921:	c1 e0 06             	shl    $0x6,%eax
80101924:	01 d0                	add    %edx,%eax
80101926:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101929:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192c:	0f b7 10             	movzwl (%eax),%edx
8010192f:	8b 45 08             	mov    0x8(%ebp),%eax
80101932:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101936:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101939:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010193d:	8b 45 08             	mov    0x8(%ebp),%eax
80101940:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101944:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101947:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010194b:	8b 45 08             	mov    0x8(%ebp),%eax
8010194e:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101952:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101955:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101959:	8b 45 08             	mov    0x8(%ebp),%eax
8010195c:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101960:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101963:	8b 50 08             	mov    0x8(%eax),%edx
80101966:	8b 45 08             	mov    0x8(%ebp),%eax
80101969:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010196c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010196f:	8d 50 0c             	lea    0xc(%eax),%edx
80101972:	8b 45 08             	mov    0x8(%ebp),%eax
80101975:	83 c0 1c             	add    $0x1c,%eax
80101978:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010197f:	00 
80101980:	89 54 24 04          	mov    %edx,0x4(%esp)
80101984:	89 04 24             	mov    %eax,(%esp)
80101987:	e8 bd 3c 00 00       	call   80105649 <memmove>
    brelse(bp);
8010198c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198f:	89 04 24             	mov    %eax,(%esp)
80101992:	e8 80 e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101997:	8b 45 08             	mov    0x8(%ebp),%eax
8010199a:	8b 40 0c             	mov    0xc(%eax),%eax
8010199d:	89 c2                	mov    %eax,%edx
8010199f:	83 ca 02             	or     $0x2,%edx
801019a2:	8b 45 08             	mov    0x8(%ebp),%eax
801019a5:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
801019a8:	8b 45 08             	mov    0x8(%ebp),%eax
801019ab:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801019af:	66 85 c0             	test   %ax,%ax
801019b2:	75 0c                	jne    801019c0 <ilock+0x14c>
      panic("ilock: no type");
801019b4:	c7 04 24 6d 8b 10 80 	movl   $0x80108b6d,(%esp)
801019bb:	e8 7d eb ff ff       	call   8010053d <panic>
  }
}
801019c0:	c9                   	leave  
801019c1:	c3                   	ret    

801019c2 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019c2:	55                   	push   %ebp
801019c3:	89 e5                	mov    %esp,%ebp
801019c5:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019c8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019cc:	74 17                	je     801019e5 <iunlock+0x23>
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	8b 40 0c             	mov    0xc(%eax),%eax
801019d4:	83 e0 01             	and    $0x1,%eax
801019d7:	85 c0                	test   %eax,%eax
801019d9:	74 0a                	je     801019e5 <iunlock+0x23>
801019db:	8b 45 08             	mov    0x8(%ebp),%eax
801019de:	8b 40 08             	mov    0x8(%eax),%eax
801019e1:	85 c0                	test   %eax,%eax
801019e3:	7f 0c                	jg     801019f1 <iunlock+0x2f>
    panic("iunlock");
801019e5:	c7 04 24 7c 8b 10 80 	movl   $0x80108b7c,(%esp)
801019ec:	e8 4c eb ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
801019f1:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801019f8:	e8 2a 39 00 00       	call   80105327 <acquire>
  ip->flags &= ~I_BUSY;
801019fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101a00:	8b 40 0c             	mov    0xc(%eax),%eax
80101a03:	89 c2                	mov    %eax,%edx
80101a05:	83 e2 fe             	and    $0xfffffffe,%edx
80101a08:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0b:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a11:	89 04 24             	mov    %eax,(%esp)
80101a14:	e8 03 37 00 00       	call   8010511c <wakeup>
  release(&icache.lock);
80101a19:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a20:	e8 64 39 00 00       	call   80105389 <release>
}
80101a25:	c9                   	leave  
80101a26:	c3                   	ret    

80101a27 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a27:	55                   	push   %ebp
80101a28:	89 e5                	mov    %esp,%ebp
80101a2a:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a2d:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a34:	e8 ee 38 00 00       	call   80105327 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a39:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3c:	8b 40 08             	mov    0x8(%eax),%eax
80101a3f:	83 f8 01             	cmp    $0x1,%eax
80101a42:	0f 85 93 00 00 00    	jne    80101adb <iput+0xb4>
80101a48:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4b:	8b 40 0c             	mov    0xc(%eax),%eax
80101a4e:	83 e0 02             	and    $0x2,%eax
80101a51:	85 c0                	test   %eax,%eax
80101a53:	0f 84 82 00 00 00    	je     80101adb <iput+0xb4>
80101a59:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a60:	66 85 c0             	test   %ax,%ax
80101a63:	75 76                	jne    80101adb <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101a65:	8b 45 08             	mov    0x8(%ebp),%eax
80101a68:	8b 40 0c             	mov    0xc(%eax),%eax
80101a6b:	83 e0 01             	and    $0x1,%eax
80101a6e:	84 c0                	test   %al,%al
80101a70:	74 0c                	je     80101a7e <iput+0x57>
      panic("iput busy");
80101a72:	c7 04 24 84 8b 10 80 	movl   $0x80108b84,(%esp)
80101a79:	e8 bf ea ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a81:	8b 40 0c             	mov    0xc(%eax),%eax
80101a84:	89 c2                	mov    %eax,%edx
80101a86:	83 ca 01             	or     $0x1,%edx
80101a89:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8c:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a8f:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a96:	e8 ee 38 00 00       	call   80105389 <release>
    itrunc(ip);
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	89 04 24             	mov    %eax,(%esp)
80101aa1:	e8 72 01 00 00       	call   80101c18 <itrunc>
    ip->type = 0;
80101aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa9:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab2:	89 04 24             	mov    %eax,(%esp)
80101ab5:	e8 fe fb ff ff       	call   801016b8 <iupdate>
    acquire(&icache.lock);
80101aba:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101ac1:	e8 61 38 00 00       	call   80105327 <acquire>
    ip->flags = 0;
80101ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad3:	89 04 24             	mov    %eax,(%esp)
80101ad6:	e8 41 36 00 00       	call   8010511c <wakeup>
  }
  ip->ref--;
80101adb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ade:	8b 40 08             	mov    0x8(%eax),%eax
80101ae1:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101aea:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101af1:	e8 93 38 00 00       	call   80105389 <release>
}
80101af6:	c9                   	leave  
80101af7:	c3                   	ret    

80101af8 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101af8:	55                   	push   %ebp
80101af9:	89 e5                	mov    %esp,%ebp
80101afb:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101afe:	8b 45 08             	mov    0x8(%ebp),%eax
80101b01:	89 04 24             	mov    %eax,(%esp)
80101b04:	e8 b9 fe ff ff       	call   801019c2 <iunlock>
  iput(ip);
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	89 04 24             	mov    %eax,(%esp)
80101b0f:	e8 13 ff ff ff       	call   80101a27 <iput>
}
80101b14:	c9                   	leave  
80101b15:	c3                   	ret    

80101b16 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b16:	55                   	push   %ebp
80101b17:	89 e5                	mov    %esp,%ebp
80101b19:	53                   	push   %ebx
80101b1a:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b1d:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b21:	77 3e                	ja     80101b61 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b23:	8b 45 08             	mov    0x8(%ebp),%eax
80101b26:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b29:	83 c2 04             	add    $0x4,%edx
80101b2c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b30:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b33:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b37:	75 20                	jne    80101b59 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b39:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3c:	8b 00                	mov    (%eax),%eax
80101b3e:	89 04 24             	mov    %eax,(%esp)
80101b41:	e8 49 f8 ff ff       	call   8010138f <balloc>
80101b46:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b49:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b4f:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b55:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b5c:	e9 b1 00 00 00       	jmp    80101c12 <bmap+0xfc>
  }
  bn -= NDIRECT;
80101b61:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b65:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b69:	0f 87 97 00 00 00    	ja     80101c06 <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b72:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b75:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b78:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b7c:	75 19                	jne    80101b97 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b81:	8b 00                	mov    (%eax),%eax
80101b83:	89 04 24             	mov    %eax,(%esp)
80101b86:	e8 04 f8 ff ff       	call   8010138f <balloc>
80101b8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b94:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101b97:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9a:	8b 00                	mov    (%eax),%eax
80101b9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b9f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ba3:	89 04 24             	mov    %eax,(%esp)
80101ba6:	e8 fb e5 ff ff       	call   801001a6 <bread>
80101bab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb1:	83 c0 18             	add    $0x18,%eax
80101bb4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bba:	c1 e0 02             	shl    $0x2,%eax
80101bbd:	03 45 ec             	add    -0x14(%ebp),%eax
80101bc0:	8b 00                	mov    (%eax),%eax
80101bc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bc5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bc9:	75 2b                	jne    80101bf6 <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bce:	c1 e0 02             	shl    $0x2,%eax
80101bd1:	89 c3                	mov    %eax,%ebx
80101bd3:	03 5d ec             	add    -0x14(%ebp),%ebx
80101bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd9:	8b 00                	mov    (%eax),%eax
80101bdb:	89 04 24             	mov    %eax,(%esp)
80101bde:	e8 ac f7 ff ff       	call   8010138f <balloc>
80101be3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101be9:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bee:	89 04 24             	mov    %eax,(%esp)
80101bf1:	e8 70 1a 00 00       	call   80103666 <log_write>
    }
    brelse(bp);
80101bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bf9:	89 04 24             	mov    %eax,(%esp)
80101bfc:	e8 16 e6 ff ff       	call   80100217 <brelse>
    return addr;
80101c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c04:	eb 0c                	jmp    80101c12 <bmap+0xfc>
  }

  panic("bmap: out of range");
80101c06:	c7 04 24 8e 8b 10 80 	movl   $0x80108b8e,(%esp)
80101c0d:	e8 2b e9 ff ff       	call   8010053d <panic>
}
80101c12:	83 c4 24             	add    $0x24,%esp
80101c15:	5b                   	pop    %ebx
80101c16:	5d                   	pop    %ebp
80101c17:	c3                   	ret    

80101c18 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c18:	55                   	push   %ebp
80101c19:	89 e5                	mov    %esp,%ebp
80101c1b:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c25:	eb 44                	jmp    80101c6b <itrunc+0x53>
    if(ip->addrs[i]){
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c2d:	83 c2 04             	add    $0x4,%edx
80101c30:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c34:	85 c0                	test   %eax,%eax
80101c36:	74 2f                	je     80101c67 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c38:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c3e:	83 c2 04             	add    $0x4,%edx
80101c41:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c45:	8b 45 08             	mov    0x8(%ebp),%eax
80101c48:	8b 00                	mov    (%eax),%eax
80101c4a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c4e:	89 04 24             	mov    %eax,(%esp)
80101c51:	e8 90 f8 ff ff       	call   801014e6 <bfree>
      ip->addrs[i] = 0;
80101c56:	8b 45 08             	mov    0x8(%ebp),%eax
80101c59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c5c:	83 c2 04             	add    $0x4,%edx
80101c5f:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c66:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c67:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c6b:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c6f:	7e b6                	jle    80101c27 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c71:	8b 45 08             	mov    0x8(%ebp),%eax
80101c74:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c77:	85 c0                	test   %eax,%eax
80101c79:	0f 84 8f 00 00 00    	je     80101d0e <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c82:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c85:	8b 45 08             	mov    0x8(%ebp),%eax
80101c88:	8b 00                	mov    (%eax),%eax
80101c8a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c8e:	89 04 24             	mov    %eax,(%esp)
80101c91:	e8 10 e5 ff ff       	call   801001a6 <bread>
80101c96:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101c99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c9c:	83 c0 18             	add    $0x18,%eax
80101c9f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ca2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ca9:	eb 2f                	jmp    80101cda <itrunc+0xc2>
      if(a[j])
80101cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cae:	c1 e0 02             	shl    $0x2,%eax
80101cb1:	03 45 e8             	add    -0x18(%ebp),%eax
80101cb4:	8b 00                	mov    (%eax),%eax
80101cb6:	85 c0                	test   %eax,%eax
80101cb8:	74 1c                	je     80101cd6 <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80101cba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cbd:	c1 e0 02             	shl    $0x2,%eax
80101cc0:	03 45 e8             	add    -0x18(%ebp),%eax
80101cc3:	8b 10                	mov    (%eax),%edx
80101cc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc8:	8b 00                	mov    (%eax),%eax
80101cca:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cce:	89 04 24             	mov    %eax,(%esp)
80101cd1:	e8 10 f8 ff ff       	call   801014e6 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101cd6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101cda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cdd:	83 f8 7f             	cmp    $0x7f,%eax
80101ce0:	76 c9                	jbe    80101cab <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ce2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ce5:	89 04 24             	mov    %eax,(%esp)
80101ce8:	e8 2a e5 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ced:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf0:	8b 50 4c             	mov    0x4c(%eax),%edx
80101cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf6:	8b 00                	mov    (%eax),%eax
80101cf8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cfc:	89 04 24             	mov    %eax,(%esp)
80101cff:	e8 e2 f7 ff ff       	call   801014e6 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d04:	8b 45 08             	mov    0x8(%ebp),%eax
80101d07:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d11:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d18:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1b:	89 04 24             	mov    %eax,(%esp)
80101d1e:	e8 95 f9 ff ff       	call   801016b8 <iupdate>
}
80101d23:	c9                   	leave  
80101d24:	c3                   	ret    

80101d25 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d25:	55                   	push   %ebp
80101d26:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d28:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2b:	8b 00                	mov    (%eax),%eax
80101d2d:	89 c2                	mov    %eax,%edx
80101d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d32:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d35:	8b 45 08             	mov    0x8(%ebp),%eax
80101d38:	8b 50 04             	mov    0x4(%eax),%edx
80101d3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d3e:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d41:	8b 45 08             	mov    0x8(%ebp),%eax
80101d44:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d48:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d4b:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d51:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d55:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d58:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5f:	8b 50 18             	mov    0x18(%eax),%edx
80101d62:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d65:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d68:	5d                   	pop    %ebp
80101d69:	c3                   	ret    

80101d6a <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d6a:	55                   	push   %ebp
80101d6b:	89 e5                	mov    %esp,%ebp
80101d6d:	53                   	push   %ebx
80101d6e:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d71:	8b 45 08             	mov    0x8(%ebp),%eax
80101d74:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d78:	66 83 f8 03          	cmp    $0x3,%ax
80101d7c:	75 60                	jne    80101dde <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d81:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d85:	66 85 c0             	test   %ax,%ax
80101d88:	78 20                	js     80101daa <readi+0x40>
80101d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d91:	66 83 f8 09          	cmp    $0x9,%ax
80101d95:	7f 13                	jg     80101daa <readi+0x40>
80101d97:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d9e:	98                   	cwtl   
80101d9f:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101da6:	85 c0                	test   %eax,%eax
80101da8:	75 0a                	jne    80101db4 <readi+0x4a>
      return -1;
80101daa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101daf:	e9 1b 01 00 00       	jmp    80101ecf <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
80101db4:	8b 45 08             	mov    0x8(%ebp),%eax
80101db7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dbb:	98                   	cwtl   
80101dbc:	8b 14 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%edx
80101dc3:	8b 45 14             	mov    0x14(%ebp),%eax
80101dc6:	89 44 24 08          	mov    %eax,0x8(%esp)
80101dca:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dcd:	89 44 24 04          	mov    %eax,0x4(%esp)
80101dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd4:	89 04 24             	mov    %eax,(%esp)
80101dd7:	ff d2                	call   *%edx
80101dd9:	e9 f1 00 00 00       	jmp    80101ecf <readi+0x165>
  }

  if(off > ip->size || off + n < off)
80101dde:	8b 45 08             	mov    0x8(%ebp),%eax
80101de1:	8b 40 18             	mov    0x18(%eax),%eax
80101de4:	3b 45 10             	cmp    0x10(%ebp),%eax
80101de7:	72 0d                	jb     80101df6 <readi+0x8c>
80101de9:	8b 45 14             	mov    0x14(%ebp),%eax
80101dec:	8b 55 10             	mov    0x10(%ebp),%edx
80101def:	01 d0                	add    %edx,%eax
80101df1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101df4:	73 0a                	jae    80101e00 <readi+0x96>
    return -1;
80101df6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dfb:	e9 cf 00 00 00       	jmp    80101ecf <readi+0x165>
  if(off + n > ip->size)
80101e00:	8b 45 14             	mov    0x14(%ebp),%eax
80101e03:	8b 55 10             	mov    0x10(%ebp),%edx
80101e06:	01 c2                	add    %eax,%edx
80101e08:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0b:	8b 40 18             	mov    0x18(%eax),%eax
80101e0e:	39 c2                	cmp    %eax,%edx
80101e10:	76 0c                	jbe    80101e1e <readi+0xb4>
    n = ip->size - off;
80101e12:	8b 45 08             	mov    0x8(%ebp),%eax
80101e15:	8b 40 18             	mov    0x18(%eax),%eax
80101e18:	2b 45 10             	sub    0x10(%ebp),%eax
80101e1b:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e25:	e9 96 00 00 00       	jmp    80101ec0 <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e2a:	8b 45 10             	mov    0x10(%ebp),%eax
80101e2d:	c1 e8 09             	shr    $0x9,%eax
80101e30:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e34:	8b 45 08             	mov    0x8(%ebp),%eax
80101e37:	89 04 24             	mov    %eax,(%esp)
80101e3a:	e8 d7 fc ff ff       	call   80101b16 <bmap>
80101e3f:	8b 55 08             	mov    0x8(%ebp),%edx
80101e42:	8b 12                	mov    (%edx),%edx
80101e44:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e48:	89 14 24             	mov    %edx,(%esp)
80101e4b:	e8 56 e3 ff ff       	call   801001a6 <bread>
80101e50:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e53:	8b 45 10             	mov    0x10(%ebp),%eax
80101e56:	89 c2                	mov    %eax,%edx
80101e58:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101e5e:	b8 00 02 00 00       	mov    $0x200,%eax
80101e63:	89 c1                	mov    %eax,%ecx
80101e65:	29 d1                	sub    %edx,%ecx
80101e67:	89 ca                	mov    %ecx,%edx
80101e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e6c:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e6f:	89 cb                	mov    %ecx,%ebx
80101e71:	29 c3                	sub    %eax,%ebx
80101e73:	89 d8                	mov    %ebx,%eax
80101e75:	39 c2                	cmp    %eax,%edx
80101e77:	0f 46 c2             	cmovbe %edx,%eax
80101e7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e80:	8d 50 18             	lea    0x18(%eax),%edx
80101e83:	8b 45 10             	mov    0x10(%ebp),%eax
80101e86:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e8b:	01 c2                	add    %eax,%edx
80101e8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e90:	89 44 24 08          	mov    %eax,0x8(%esp)
80101e94:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e98:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9b:	89 04 24             	mov    %eax,(%esp)
80101e9e:	e8 a6 37 00 00       	call   80105649 <memmove>
    brelse(bp);
80101ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea6:	89 04 24             	mov    %eax,(%esp)
80101ea9:	e8 69 e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101eae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb1:	01 45 f4             	add    %eax,-0xc(%ebp)
80101eb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb7:	01 45 10             	add    %eax,0x10(%ebp)
80101eba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ebd:	01 45 0c             	add    %eax,0xc(%ebp)
80101ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ec3:	3b 45 14             	cmp    0x14(%ebp),%eax
80101ec6:	0f 82 5e ff ff ff    	jb     80101e2a <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101ecc:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101ecf:	83 c4 24             	add    $0x24,%esp
80101ed2:	5b                   	pop    %ebx
80101ed3:	5d                   	pop    %ebp
80101ed4:	c3                   	ret    

80101ed5 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101ed5:	55                   	push   %ebp
80101ed6:	89 e5                	mov    %esp,%ebp
80101ed8:	53                   	push   %ebx
80101ed9:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ee3:	66 83 f8 03          	cmp    $0x3,%ax
80101ee7:	75 60                	jne    80101f49 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef0:	66 85 c0             	test   %ax,%ax
80101ef3:	78 20                	js     80101f15 <writei+0x40>
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101efc:	66 83 f8 09          	cmp    $0x9,%ax
80101f00:	7f 13                	jg     80101f15 <writei+0x40>
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f09:	98                   	cwtl   
80101f0a:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <writei+0x4a>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 46 01 00 00       	jmp    80102065 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 14 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%edx
80101f2e:	8b 45 14             	mov    0x14(%ebp),%eax
80101f31:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f35:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f38:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3f:	89 04 24             	mov    %eax,(%esp)
80101f42:	ff d2                	call   *%edx
80101f44:	e9 1c 01 00 00       	jmp    80102065 <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80101f49:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4c:	8b 40 18             	mov    0x18(%eax),%eax
80101f4f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f52:	72 0d                	jb     80101f61 <writei+0x8c>
80101f54:	8b 45 14             	mov    0x14(%ebp),%eax
80101f57:	8b 55 10             	mov    0x10(%ebp),%edx
80101f5a:	01 d0                	add    %edx,%eax
80101f5c:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f5f:	73 0a                	jae    80101f6b <writei+0x96>
    return -1;
80101f61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f66:	e9 fa 00 00 00       	jmp    80102065 <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
80101f6b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6e:	8b 55 10             	mov    0x10(%ebp),%edx
80101f71:	01 d0                	add    %edx,%eax
80101f73:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f78:	76 0a                	jbe    80101f84 <writei+0xaf>
    return -1;
80101f7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f7f:	e9 e1 00 00 00       	jmp    80102065 <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f84:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8b:	e9 a1 00 00 00       	jmp    80102031 <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f90:	8b 45 10             	mov    0x10(%ebp),%eax
80101f93:	c1 e8 09             	shr    $0x9,%eax
80101f96:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9d:	89 04 24             	mov    %eax,(%esp)
80101fa0:	e8 71 fb ff ff       	call   80101b16 <bmap>
80101fa5:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa8:	8b 12                	mov    (%edx),%edx
80101faa:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fae:	89 14 24             	mov    %edx,(%esp)
80101fb1:	e8 f0 e1 ff ff       	call   801001a6 <bread>
80101fb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fb9:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbc:	89 c2                	mov    %eax,%edx
80101fbe:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101fc4:	b8 00 02 00 00       	mov    $0x200,%eax
80101fc9:	89 c1                	mov    %eax,%ecx
80101fcb:	29 d1                	sub    %edx,%ecx
80101fcd:	89 ca                	mov    %ecx,%edx
80101fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fd2:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fd5:	89 cb                	mov    %ecx,%ebx
80101fd7:	29 c3                	sub    %eax,%ebx
80101fd9:	89 d8                	mov    %ebx,%eax
80101fdb:	39 c2                	cmp    %eax,%edx
80101fdd:	0f 46 c2             	cmovbe %edx,%eax
80101fe0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101fe3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe6:	8d 50 18             	lea    0x18(%eax),%edx
80101fe9:	8b 45 10             	mov    0x10(%ebp),%eax
80101fec:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ff1:	01 c2                	add    %eax,%edx
80101ff3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ff6:	89 44 24 08          	mov    %eax,0x8(%esp)
80101ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ffd:	89 44 24 04          	mov    %eax,0x4(%esp)
80102001:	89 14 24             	mov    %edx,(%esp)
80102004:	e8 40 36 00 00       	call   80105649 <memmove>
    log_write(bp);
80102009:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010200c:	89 04 24             	mov    %eax,(%esp)
8010200f:	e8 52 16 00 00       	call   80103666 <log_write>
    brelse(bp);
80102014:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102017:	89 04 24             	mov    %eax,(%esp)
8010201a:	e8 f8 e1 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010201f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102022:	01 45 f4             	add    %eax,-0xc(%ebp)
80102025:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102028:	01 45 10             	add    %eax,0x10(%ebp)
8010202b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010202e:	01 45 0c             	add    %eax,0xc(%ebp)
80102031:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102034:	3b 45 14             	cmp    0x14(%ebp),%eax
80102037:	0f 82 53 ff ff ff    	jb     80101f90 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010203d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102041:	74 1f                	je     80102062 <writei+0x18d>
80102043:	8b 45 08             	mov    0x8(%ebp),%eax
80102046:	8b 40 18             	mov    0x18(%eax),%eax
80102049:	3b 45 10             	cmp    0x10(%ebp),%eax
8010204c:	73 14                	jae    80102062 <writei+0x18d>
    ip->size = off;
8010204e:	8b 45 08             	mov    0x8(%ebp),%eax
80102051:	8b 55 10             	mov    0x10(%ebp),%edx
80102054:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102057:	8b 45 08             	mov    0x8(%ebp),%eax
8010205a:	89 04 24             	mov    %eax,(%esp)
8010205d:	e8 56 f6 ff ff       	call   801016b8 <iupdate>
  }
  return n;
80102062:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102065:	83 c4 24             	add    $0x24,%esp
80102068:	5b                   	pop    %ebx
80102069:	5d                   	pop    %ebp
8010206a:	c3                   	ret    

8010206b <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010206b:	55                   	push   %ebp
8010206c:	89 e5                	mov    %esp,%ebp
8010206e:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102071:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102078:	00 
80102079:	8b 45 0c             	mov    0xc(%ebp),%eax
8010207c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102080:	8b 45 08             	mov    0x8(%ebp),%eax
80102083:	89 04 24             	mov    %eax,(%esp)
80102086:	e8 62 36 00 00       	call   801056ed <strncmp>
}
8010208b:	c9                   	leave  
8010208c:	c3                   	ret    

8010208d <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010208d:	55                   	push   %ebp
8010208e:	89 e5                	mov    %esp,%ebp
80102090:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102093:	8b 45 08             	mov    0x8(%ebp),%eax
80102096:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010209a:	66 83 f8 01          	cmp    $0x1,%ax
8010209e:	74 0c                	je     801020ac <dirlookup+0x1f>
    panic("dirlookup not DIR");
801020a0:	c7 04 24 a1 8b 10 80 	movl   $0x80108ba1,(%esp)
801020a7:	e8 91 e4 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801020ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020b3:	e9 87 00 00 00       	jmp    8010213f <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020b8:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020bf:	00 
801020c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020c3:	89 44 24 08          	mov    %eax,0x8(%esp)
801020c7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ce:	8b 45 08             	mov    0x8(%ebp),%eax
801020d1:	89 04 24             	mov    %eax,(%esp)
801020d4:	e8 91 fc ff ff       	call   80101d6a <readi>
801020d9:	83 f8 10             	cmp    $0x10,%eax
801020dc:	74 0c                	je     801020ea <dirlookup+0x5d>
      panic("dirlink read");
801020de:	c7 04 24 b3 8b 10 80 	movl   $0x80108bb3,(%esp)
801020e5:	e8 53 e4 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801020ea:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801020ee:	66 85 c0             	test   %ax,%ax
801020f1:	74 47                	je     8010213a <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
801020f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020f6:	83 c0 02             	add    $0x2,%eax
801020f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801020fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102100:	89 04 24             	mov    %eax,(%esp)
80102103:	e8 63 ff ff ff       	call   8010206b <namecmp>
80102108:	85 c0                	test   %eax,%eax
8010210a:	75 2f                	jne    8010213b <dirlookup+0xae>
      // entry matches path element
      if(poff)
8010210c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102110:	74 08                	je     8010211a <dirlookup+0x8d>
        *poff = off;
80102112:	8b 45 10             	mov    0x10(%ebp),%eax
80102115:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102118:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010211a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010211e:	0f b7 c0             	movzwl %ax,%eax
80102121:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102124:	8b 45 08             	mov    0x8(%ebp),%eax
80102127:	8b 00                	mov    (%eax),%eax
80102129:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010212c:	89 54 24 04          	mov    %edx,0x4(%esp)
80102130:	89 04 24             	mov    %eax,(%esp)
80102133:	e8 38 f6 ff ff       	call   80101770 <iget>
80102138:	eb 19                	jmp    80102153 <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010213a:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010213b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010213f:	8b 45 08             	mov    0x8(%ebp),%eax
80102142:	8b 40 18             	mov    0x18(%eax),%eax
80102145:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102148:	0f 87 6a ff ff ff    	ja     801020b8 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010214e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102153:	c9                   	leave  
80102154:	c3                   	ret    

80102155 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102155:	55                   	push   %ebp
80102156:	89 e5                	mov    %esp,%ebp
80102158:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010215b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102162:	00 
80102163:	8b 45 0c             	mov    0xc(%ebp),%eax
80102166:	89 44 24 04          	mov    %eax,0x4(%esp)
8010216a:	8b 45 08             	mov    0x8(%ebp),%eax
8010216d:	89 04 24             	mov    %eax,(%esp)
80102170:	e8 18 ff ff ff       	call   8010208d <dirlookup>
80102175:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102178:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010217c:	74 15                	je     80102193 <dirlink+0x3e>
    iput(ip);
8010217e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102181:	89 04 24             	mov    %eax,(%esp)
80102184:	e8 9e f8 ff ff       	call   80101a27 <iput>
    return -1;
80102189:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010218e:	e9 b8 00 00 00       	jmp    8010224b <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102193:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010219a:	eb 44                	jmp    801021e0 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010219c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010219f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801021a6:	00 
801021a7:	89 44 24 08          	mov    %eax,0x8(%esp)
801021ab:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801021b2:	8b 45 08             	mov    0x8(%ebp),%eax
801021b5:	89 04 24             	mov    %eax,(%esp)
801021b8:	e8 ad fb ff ff       	call   80101d6a <readi>
801021bd:	83 f8 10             	cmp    $0x10,%eax
801021c0:	74 0c                	je     801021ce <dirlink+0x79>
      panic("dirlink read");
801021c2:	c7 04 24 b3 8b 10 80 	movl   $0x80108bb3,(%esp)
801021c9:	e8 6f e3 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801021ce:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021d2:	66 85 c0             	test   %ax,%ax
801021d5:	74 18                	je     801021ef <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021da:	83 c0 10             	add    $0x10,%eax
801021dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021e3:	8b 45 08             	mov    0x8(%ebp),%eax
801021e6:	8b 40 18             	mov    0x18(%eax),%eax
801021e9:	39 c2                	cmp    %eax,%edx
801021eb:	72 af                	jb     8010219c <dirlink+0x47>
801021ed:	eb 01                	jmp    801021f0 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801021ef:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801021f0:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021f7:	00 
801021f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801021fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801021ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102202:	83 c0 02             	add    $0x2,%eax
80102205:	89 04 24             	mov    %eax,(%esp)
80102208:	e8 38 35 00 00       	call   80105745 <strncpy>
  de.inum = inum;
8010220d:	8b 45 10             	mov    0x10(%ebp),%eax
80102210:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102217:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010221e:	00 
8010221f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102223:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102226:	89 44 24 04          	mov    %eax,0x4(%esp)
8010222a:	8b 45 08             	mov    0x8(%ebp),%eax
8010222d:	89 04 24             	mov    %eax,(%esp)
80102230:	e8 a0 fc ff ff       	call   80101ed5 <writei>
80102235:	83 f8 10             	cmp    $0x10,%eax
80102238:	74 0c                	je     80102246 <dirlink+0xf1>
    panic("dirlink");
8010223a:	c7 04 24 c0 8b 10 80 	movl   $0x80108bc0,(%esp)
80102241:	e8 f7 e2 ff ff       	call   8010053d <panic>
  
  return 0;
80102246:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010224b:	c9                   	leave  
8010224c:	c3                   	ret    

8010224d <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010224d:	55                   	push   %ebp
8010224e:	89 e5                	mov    %esp,%ebp
80102250:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102253:	eb 04                	jmp    80102259 <skipelem+0xc>
    path++;
80102255:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102259:	8b 45 08             	mov    0x8(%ebp),%eax
8010225c:	0f b6 00             	movzbl (%eax),%eax
8010225f:	3c 2f                	cmp    $0x2f,%al
80102261:	74 f2                	je     80102255 <skipelem+0x8>
    path++;
  if(*path == 0)
80102263:	8b 45 08             	mov    0x8(%ebp),%eax
80102266:	0f b6 00             	movzbl (%eax),%eax
80102269:	84 c0                	test   %al,%al
8010226b:	75 0a                	jne    80102277 <skipelem+0x2a>
    return 0;
8010226d:	b8 00 00 00 00       	mov    $0x0,%eax
80102272:	e9 86 00 00 00       	jmp    801022fd <skipelem+0xb0>
  s = path;
80102277:	8b 45 08             	mov    0x8(%ebp),%eax
8010227a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010227d:	eb 04                	jmp    80102283 <skipelem+0x36>
    path++;
8010227f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102283:	8b 45 08             	mov    0x8(%ebp),%eax
80102286:	0f b6 00             	movzbl (%eax),%eax
80102289:	3c 2f                	cmp    $0x2f,%al
8010228b:	74 0a                	je     80102297 <skipelem+0x4a>
8010228d:	8b 45 08             	mov    0x8(%ebp),%eax
80102290:	0f b6 00             	movzbl (%eax),%eax
80102293:	84 c0                	test   %al,%al
80102295:	75 e8                	jne    8010227f <skipelem+0x32>
    path++;
  len = path - s;
80102297:	8b 55 08             	mov    0x8(%ebp),%edx
8010229a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010229d:	89 d1                	mov    %edx,%ecx
8010229f:	29 c1                	sub    %eax,%ecx
801022a1:	89 c8                	mov    %ecx,%eax
801022a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801022a6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801022aa:	7e 1c                	jle    801022c8 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801022ac:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022b3:	00 
801022b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801022bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801022be:	89 04 24             	mov    %eax,(%esp)
801022c1:	e8 83 33 00 00       	call   80105649 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022c6:	eb 28                	jmp    801022f0 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022cb:	89 44 24 08          	mov    %eax,0x8(%esp)
801022cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801022d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801022d9:	89 04 24             	mov    %eax,(%esp)
801022dc:	e8 68 33 00 00       	call   80105649 <memmove>
    name[len] = 0;
801022e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022e4:	03 45 0c             	add    0xc(%ebp),%eax
801022e7:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801022ea:	eb 04                	jmp    801022f0 <skipelem+0xa3>
    path++;
801022ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022f0:	8b 45 08             	mov    0x8(%ebp),%eax
801022f3:	0f b6 00             	movzbl (%eax),%eax
801022f6:	3c 2f                	cmp    $0x2f,%al
801022f8:	74 f2                	je     801022ec <skipelem+0x9f>
    path++;
  return path;
801022fa:	8b 45 08             	mov    0x8(%ebp),%eax
}
801022fd:	c9                   	leave  
801022fe:	c3                   	ret    

801022ff <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801022ff:	55                   	push   %ebp
80102300:	89 e5                	mov    %esp,%ebp
80102302:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102305:	8b 45 08             	mov    0x8(%ebp),%eax
80102308:	0f b6 00             	movzbl (%eax),%eax
8010230b:	3c 2f                	cmp    $0x2f,%al
8010230d:	75 1c                	jne    8010232b <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010230f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102316:	00 
80102317:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010231e:	e8 4d f4 ff ff       	call   80101770 <iget>
80102323:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102326:	e9 af 00 00 00       	jmp    801023da <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010232b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102331:	8b 40 68             	mov    0x68(%eax),%eax
80102334:	89 04 24             	mov    %eax,(%esp)
80102337:	e8 06 f5 ff ff       	call   80101842 <idup>
8010233c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010233f:	e9 96 00 00 00       	jmp    801023da <namex+0xdb>
    ilock(ip);
80102344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102347:	89 04 24             	mov    %eax,(%esp)
8010234a:	e8 25 f5 ff ff       	call   80101874 <ilock>
    if(ip->type != T_DIR){
8010234f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102352:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102356:	66 83 f8 01          	cmp    $0x1,%ax
8010235a:	74 15                	je     80102371 <namex+0x72>
      iunlockput(ip);
8010235c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010235f:	89 04 24             	mov    %eax,(%esp)
80102362:	e8 91 f7 ff ff       	call   80101af8 <iunlockput>
      return 0;
80102367:	b8 00 00 00 00       	mov    $0x0,%eax
8010236c:	e9 a3 00 00 00       	jmp    80102414 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102371:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102375:	74 1d                	je     80102394 <namex+0x95>
80102377:	8b 45 08             	mov    0x8(%ebp),%eax
8010237a:	0f b6 00             	movzbl (%eax),%eax
8010237d:	84 c0                	test   %al,%al
8010237f:	75 13                	jne    80102394 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102384:	89 04 24             	mov    %eax,(%esp)
80102387:	e8 36 f6 ff ff       	call   801019c2 <iunlock>
      return ip;
8010238c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010238f:	e9 80 00 00 00       	jmp    80102414 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102394:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010239b:	00 
8010239c:	8b 45 10             	mov    0x10(%ebp),%eax
8010239f:	89 44 24 04          	mov    %eax,0x4(%esp)
801023a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a6:	89 04 24             	mov    %eax,(%esp)
801023a9:	e8 df fc ff ff       	call   8010208d <dirlookup>
801023ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023b5:	75 12                	jne    801023c9 <namex+0xca>
      iunlockput(ip);
801023b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ba:	89 04 24             	mov    %eax,(%esp)
801023bd:	e8 36 f7 ff ff       	call   80101af8 <iunlockput>
      return 0;
801023c2:	b8 00 00 00 00       	mov    $0x0,%eax
801023c7:	eb 4b                	jmp    80102414 <namex+0x115>
    }
    iunlockput(ip);
801023c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023cc:	89 04 24             	mov    %eax,(%esp)
801023cf:	e8 24 f7 ff ff       	call   80101af8 <iunlockput>
    ip = next;
801023d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023da:	8b 45 10             	mov    0x10(%ebp),%eax
801023dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801023e1:	8b 45 08             	mov    0x8(%ebp),%eax
801023e4:	89 04 24             	mov    %eax,(%esp)
801023e7:	e8 61 fe ff ff       	call   8010224d <skipelem>
801023ec:	89 45 08             	mov    %eax,0x8(%ebp)
801023ef:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801023f3:	0f 85 4b ff ff ff    	jne    80102344 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801023f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023fd:	74 12                	je     80102411 <namex+0x112>
    iput(ip);
801023ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102402:	89 04 24             	mov    %eax,(%esp)
80102405:	e8 1d f6 ff ff       	call   80101a27 <iput>
    return 0;
8010240a:	b8 00 00 00 00       	mov    $0x0,%eax
8010240f:	eb 03                	jmp    80102414 <namex+0x115>
  }
  return ip;
80102411:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102414:	c9                   	leave  
80102415:	c3                   	ret    

80102416 <namei>:

struct inode*
namei(char *path)
{
80102416:	55                   	push   %ebp
80102417:	89 e5                	mov    %esp,%ebp
80102419:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010241c:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010241f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102423:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010242a:	00 
8010242b:	8b 45 08             	mov    0x8(%ebp),%eax
8010242e:	89 04 24             	mov    %eax,(%esp)
80102431:	e8 c9 fe ff ff       	call   801022ff <namex>
}
80102436:	c9                   	leave  
80102437:	c3                   	ret    

80102438 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102438:	55                   	push   %ebp
80102439:	89 e5                	mov    %esp,%ebp
8010243b:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010243e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102441:	89 44 24 08          	mov    %eax,0x8(%esp)
80102445:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010244c:	00 
8010244d:	8b 45 08             	mov    0x8(%ebp),%eax
80102450:	89 04 24             	mov    %eax,(%esp)
80102453:	e8 a7 fe ff ff       	call   801022ff <namex>
}
80102458:	c9                   	leave  
80102459:	c3                   	ret    
	...

8010245c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010245c:	55                   	push   %ebp
8010245d:	89 e5                	mov    %esp,%ebp
8010245f:	53                   	push   %ebx
80102460:	83 ec 14             	sub    $0x14,%esp
80102463:	8b 45 08             	mov    0x8(%ebp),%eax
80102466:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010246a:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010246e:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102472:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102476:	ec                   	in     (%dx),%al
80102477:	89 c3                	mov    %eax,%ebx
80102479:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
8010247c:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102480:	83 c4 14             	add    $0x14,%esp
80102483:	5b                   	pop    %ebx
80102484:	5d                   	pop    %ebp
80102485:	c3                   	ret    

80102486 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102486:	55                   	push   %ebp
80102487:	89 e5                	mov    %esp,%ebp
80102489:	57                   	push   %edi
8010248a:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010248b:	8b 55 08             	mov    0x8(%ebp),%edx
8010248e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102491:	8b 45 10             	mov    0x10(%ebp),%eax
80102494:	89 cb                	mov    %ecx,%ebx
80102496:	89 df                	mov    %ebx,%edi
80102498:	89 c1                	mov    %eax,%ecx
8010249a:	fc                   	cld    
8010249b:	f3 6d                	rep insl (%dx),%es:(%edi)
8010249d:	89 c8                	mov    %ecx,%eax
8010249f:	89 fb                	mov    %edi,%ebx
801024a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024a4:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801024a7:	5b                   	pop    %ebx
801024a8:	5f                   	pop    %edi
801024a9:	5d                   	pop    %ebp
801024aa:	c3                   	ret    

801024ab <outb>:

static inline void
outb(ushort port, uchar data)
{
801024ab:	55                   	push   %ebp
801024ac:	89 e5                	mov    %esp,%ebp
801024ae:	83 ec 08             	sub    $0x8,%esp
801024b1:	8b 55 08             	mov    0x8(%ebp),%edx
801024b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801024b7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801024bb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024be:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024c2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801024c6:	ee                   	out    %al,(%dx)
}
801024c7:	c9                   	leave  
801024c8:	c3                   	ret    

801024c9 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024c9:	55                   	push   %ebp
801024ca:	89 e5                	mov    %esp,%ebp
801024cc:	56                   	push   %esi
801024cd:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024ce:	8b 55 08             	mov    0x8(%ebp),%edx
801024d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024d4:	8b 45 10             	mov    0x10(%ebp),%eax
801024d7:	89 cb                	mov    %ecx,%ebx
801024d9:	89 de                	mov    %ebx,%esi
801024db:	89 c1                	mov    %eax,%ecx
801024dd:	fc                   	cld    
801024de:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024e0:	89 c8                	mov    %ecx,%eax
801024e2:	89 f3                	mov    %esi,%ebx
801024e4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024e7:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024ea:	5b                   	pop    %ebx
801024eb:	5e                   	pop    %esi
801024ec:	5d                   	pop    %ebp
801024ed:	c3                   	ret    

801024ee <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801024ee:	55                   	push   %ebp
801024ef:	89 e5                	mov    %esp,%ebp
801024f1:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801024f4:	90                   	nop
801024f5:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801024fc:	e8 5b ff ff ff       	call   8010245c <inb>
80102501:	0f b6 c0             	movzbl %al,%eax
80102504:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102507:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010250a:	25 c0 00 00 00       	and    $0xc0,%eax
8010250f:	83 f8 40             	cmp    $0x40,%eax
80102512:	75 e1                	jne    801024f5 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102514:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102518:	74 11                	je     8010252b <idewait+0x3d>
8010251a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010251d:	83 e0 21             	and    $0x21,%eax
80102520:	85 c0                	test   %eax,%eax
80102522:	74 07                	je     8010252b <idewait+0x3d>
    return -1;
80102524:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102529:	eb 05                	jmp    80102530 <idewait+0x42>
  return 0;
8010252b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102530:	c9                   	leave  
80102531:	c3                   	ret    

80102532 <ideinit>:

void
ideinit(void)
{
80102532:	55                   	push   %ebp
80102533:	89 e5                	mov    %esp,%ebp
80102535:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102538:	c7 44 24 04 c8 8b 10 	movl   $0x80108bc8,0x4(%esp)
8010253f:	80 
80102540:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102547:	e8 ba 2d 00 00       	call   80105306 <initlock>
  picenable(IRQ_IDE);
8010254c:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102553:	e8 a9 18 00 00       	call   80103e01 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102558:	a1 60 39 11 80       	mov    0x80113960,%eax
8010255d:	83 e8 01             	sub    $0x1,%eax
80102560:	89 44 24 04          	mov    %eax,0x4(%esp)
80102564:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010256b:	e8 12 04 00 00       	call   80102982 <ioapicenable>
  idewait(0);
80102570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102577:	e8 72 ff ff ff       	call   801024ee <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010257c:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102583:	00 
80102584:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010258b:	e8 1b ff ff ff       	call   801024ab <outb>
  for(i=0; i<1000; i++){
80102590:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102597:	eb 20                	jmp    801025b9 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102599:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025a0:	e8 b7 fe ff ff       	call   8010245c <inb>
801025a5:	84 c0                	test   %al,%al
801025a7:	74 0c                	je     801025b5 <ideinit+0x83>
      havedisk1 = 1;
801025a9:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
801025b0:	00 00 00 
      break;
801025b3:	eb 0d                	jmp    801025c2 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801025b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801025b9:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025c0:	7e d7                	jle    80102599 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025c2:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025c9:	00 
801025ca:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025d1:	e8 d5 fe ff ff       	call   801024ab <outb>
}
801025d6:	c9                   	leave  
801025d7:	c3                   	ret    

801025d8 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025d8:	55                   	push   %ebp
801025d9:	89 e5                	mov    %esp,%ebp
801025db:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801025de:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025e2:	75 0c                	jne    801025f0 <idestart+0x18>
    panic("idestart");
801025e4:	c7 04 24 cc 8b 10 80 	movl   $0x80108bcc,(%esp)
801025eb:	e8 4d df ff ff       	call   8010053d <panic>

  idewait(0);
801025f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025f7:	e8 f2 fe ff ff       	call   801024ee <idewait>
  outb(0x3f6, 0);  // generate interrupt
801025fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102603:	00 
80102604:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010260b:	e8 9b fe ff ff       	call   801024ab <outb>
  outb(0x1f2, 1);  // number of sectors
80102610:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102617:	00 
80102618:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010261f:	e8 87 fe ff ff       	call   801024ab <outb>
  outb(0x1f3, b->sector & 0xff);
80102624:	8b 45 08             	mov    0x8(%ebp),%eax
80102627:	8b 40 08             	mov    0x8(%eax),%eax
8010262a:	0f b6 c0             	movzbl %al,%eax
8010262d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102631:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102638:	e8 6e fe ff ff       	call   801024ab <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010263d:	8b 45 08             	mov    0x8(%ebp),%eax
80102640:	8b 40 08             	mov    0x8(%eax),%eax
80102643:	c1 e8 08             	shr    $0x8,%eax
80102646:	0f b6 c0             	movzbl %al,%eax
80102649:	89 44 24 04          	mov    %eax,0x4(%esp)
8010264d:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102654:	e8 52 fe ff ff       	call   801024ab <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102659:	8b 45 08             	mov    0x8(%ebp),%eax
8010265c:	8b 40 08             	mov    0x8(%eax),%eax
8010265f:	c1 e8 10             	shr    $0x10,%eax
80102662:	0f b6 c0             	movzbl %al,%eax
80102665:	89 44 24 04          	mov    %eax,0x4(%esp)
80102669:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102670:	e8 36 fe ff ff       	call   801024ab <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102675:	8b 45 08             	mov    0x8(%ebp),%eax
80102678:	8b 40 04             	mov    0x4(%eax),%eax
8010267b:	83 e0 01             	and    $0x1,%eax
8010267e:	89 c2                	mov    %eax,%edx
80102680:	c1 e2 04             	shl    $0x4,%edx
80102683:	8b 45 08             	mov    0x8(%ebp),%eax
80102686:	8b 40 08             	mov    0x8(%eax),%eax
80102689:	c1 e8 18             	shr    $0x18,%eax
8010268c:	83 e0 0f             	and    $0xf,%eax
8010268f:	09 d0                	or     %edx,%eax
80102691:	83 c8 e0             	or     $0xffffffe0,%eax
80102694:	0f b6 c0             	movzbl %al,%eax
80102697:	89 44 24 04          	mov    %eax,0x4(%esp)
8010269b:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026a2:	e8 04 fe ff ff       	call   801024ab <outb>
  if(b->flags & B_DIRTY){
801026a7:	8b 45 08             	mov    0x8(%ebp),%eax
801026aa:	8b 00                	mov    (%eax),%eax
801026ac:	83 e0 04             	and    $0x4,%eax
801026af:	85 c0                	test   %eax,%eax
801026b1:	74 34                	je     801026e7 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801026b3:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801026ba:	00 
801026bb:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026c2:	e8 e4 fd ff ff       	call   801024ab <outb>
    outsl(0x1f0, b->data, 512/4);
801026c7:	8b 45 08             	mov    0x8(%ebp),%eax
801026ca:	83 c0 18             	add    $0x18,%eax
801026cd:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026d4:	00 
801026d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801026d9:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801026e0:	e8 e4 fd ff ff       	call   801024c9 <outsl>
801026e5:	eb 14                	jmp    801026fb <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801026e7:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801026ee:	00 
801026ef:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026f6:	e8 b0 fd ff ff       	call   801024ab <outb>
  }
}
801026fb:	c9                   	leave  
801026fc:	c3                   	ret    

801026fd <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801026fd:	55                   	push   %ebp
801026fe:	89 e5                	mov    %esp,%ebp
80102700:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102703:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
8010270a:	e8 18 2c 00 00       	call   80105327 <acquire>
  if((b = idequeue) == 0){
8010270f:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102714:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102717:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010271b:	75 11                	jne    8010272e <ideintr+0x31>
    release(&idelock);
8010271d:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102724:	e8 60 2c 00 00       	call   80105389 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102729:	e9 90 00 00 00       	jmp    801027be <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010272e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102731:	8b 40 14             	mov    0x14(%eax),%eax
80102734:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010273c:	8b 00                	mov    (%eax),%eax
8010273e:	83 e0 04             	and    $0x4,%eax
80102741:	85 c0                	test   %eax,%eax
80102743:	75 2e                	jne    80102773 <ideintr+0x76>
80102745:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010274c:	e8 9d fd ff ff       	call   801024ee <idewait>
80102751:	85 c0                	test   %eax,%eax
80102753:	78 1e                	js     80102773 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102758:	83 c0 18             	add    $0x18,%eax
8010275b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102762:	00 
80102763:	89 44 24 04          	mov    %eax,0x4(%esp)
80102767:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010276e:	e8 13 fd ff ff       	call   80102486 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102776:	8b 00                	mov    (%eax),%eax
80102778:	89 c2                	mov    %eax,%edx
8010277a:	83 ca 02             	or     $0x2,%edx
8010277d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102780:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102785:	8b 00                	mov    (%eax),%eax
80102787:	89 c2                	mov    %eax,%edx
80102789:	83 e2 fb             	and    $0xfffffffb,%edx
8010278c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010278f:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102794:	89 04 24             	mov    %eax,(%esp)
80102797:	e8 80 29 00 00       	call   8010511c <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010279c:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801027a1:	85 c0                	test   %eax,%eax
801027a3:	74 0d                	je     801027b2 <ideintr+0xb5>
    idestart(idequeue);
801027a5:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801027aa:	89 04 24             	mov    %eax,(%esp)
801027ad:	e8 26 fe ff ff       	call   801025d8 <idestart>

  release(&idelock);
801027b2:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
801027b9:	e8 cb 2b 00 00       	call   80105389 <release>
}
801027be:	c9                   	leave  
801027bf:	c3                   	ret    

801027c0 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027c0:	55                   	push   %ebp
801027c1:	89 e5                	mov    %esp,%ebp
801027c3:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801027c6:	8b 45 08             	mov    0x8(%ebp),%eax
801027c9:	8b 00                	mov    (%eax),%eax
801027cb:	83 e0 01             	and    $0x1,%eax
801027ce:	85 c0                	test   %eax,%eax
801027d0:	75 0c                	jne    801027de <iderw+0x1e>
    panic("iderw: buf not busy");
801027d2:	c7 04 24 d5 8b 10 80 	movl   $0x80108bd5,(%esp)
801027d9:	e8 5f dd ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027de:	8b 45 08             	mov    0x8(%ebp),%eax
801027e1:	8b 00                	mov    (%eax),%eax
801027e3:	83 e0 06             	and    $0x6,%eax
801027e6:	83 f8 02             	cmp    $0x2,%eax
801027e9:	75 0c                	jne    801027f7 <iderw+0x37>
    panic("iderw: nothing to do");
801027eb:	c7 04 24 e9 8b 10 80 	movl   $0x80108be9,(%esp)
801027f2:	e8 46 dd ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
801027f7:	8b 45 08             	mov    0x8(%ebp),%eax
801027fa:	8b 40 04             	mov    0x4(%eax),%eax
801027fd:	85 c0                	test   %eax,%eax
801027ff:	74 15                	je     80102816 <iderw+0x56>
80102801:	a1 58 c6 10 80       	mov    0x8010c658,%eax
80102806:	85 c0                	test   %eax,%eax
80102808:	75 0c                	jne    80102816 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
8010280a:	c7 04 24 fe 8b 10 80 	movl   $0x80108bfe,(%esp)
80102811:	e8 27 dd ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102816:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
8010281d:	e8 05 2b 00 00       	call   80105327 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102822:	8b 45 08             	mov    0x8(%ebp),%eax
80102825:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010282c:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
80102833:	eb 0b                	jmp    80102840 <iderw+0x80>
80102835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102838:	8b 00                	mov    (%eax),%eax
8010283a:	83 c0 14             	add    $0x14,%eax
8010283d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102843:	8b 00                	mov    (%eax),%eax
80102845:	85 c0                	test   %eax,%eax
80102847:	75 ec                	jne    80102835 <iderw+0x75>
    ;
  *pp = b;
80102849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010284c:	8b 55 08             	mov    0x8(%ebp),%edx
8010284f:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102851:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102856:	3b 45 08             	cmp    0x8(%ebp),%eax
80102859:	75 22                	jne    8010287d <iderw+0xbd>
    idestart(b);
8010285b:	8b 45 08             	mov    0x8(%ebp),%eax
8010285e:	89 04 24             	mov    %eax,(%esp)
80102861:	e8 72 fd ff ff       	call   801025d8 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102866:	eb 15                	jmp    8010287d <iderw+0xbd>
    sleep(b, &idelock);
80102868:	c7 44 24 04 20 c6 10 	movl   $0x8010c620,0x4(%esp)
8010286f:	80 
80102870:	8b 45 08             	mov    0x8(%ebp),%eax
80102873:	89 04 24             	mov    %eax,(%esp)
80102876:	e8 c5 27 00 00       	call   80105040 <sleep>
8010287b:	eb 01                	jmp    8010287e <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010287d:	90                   	nop
8010287e:	8b 45 08             	mov    0x8(%ebp),%eax
80102881:	8b 00                	mov    (%eax),%eax
80102883:	83 e0 06             	and    $0x6,%eax
80102886:	83 f8 02             	cmp    $0x2,%eax
80102889:	75 dd                	jne    80102868 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
8010288b:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102892:	e8 f2 2a 00 00       	call   80105389 <release>
}
80102897:	c9                   	leave  
80102898:	c3                   	ret    
80102899:	00 00                	add    %al,(%eax)
	...

8010289c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010289c:	55                   	push   %ebp
8010289d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010289f:	a1 34 32 11 80       	mov    0x80113234,%eax
801028a4:	8b 55 08             	mov    0x8(%ebp),%edx
801028a7:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801028a9:	a1 34 32 11 80       	mov    0x80113234,%eax
801028ae:	8b 40 10             	mov    0x10(%eax),%eax
}
801028b1:	5d                   	pop    %ebp
801028b2:	c3                   	ret    

801028b3 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801028b3:	55                   	push   %ebp
801028b4:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801028b6:	a1 34 32 11 80       	mov    0x80113234,%eax
801028bb:	8b 55 08             	mov    0x8(%ebp),%edx
801028be:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801028c0:	a1 34 32 11 80       	mov    0x80113234,%eax
801028c5:	8b 55 0c             	mov    0xc(%ebp),%edx
801028c8:	89 50 10             	mov    %edx,0x10(%eax)
}
801028cb:	5d                   	pop    %ebp
801028cc:	c3                   	ret    

801028cd <ioapicinit>:

void
ioapicinit(void)
{
801028cd:	55                   	push   %ebp
801028ce:	89 e5                	mov    %esp,%ebp
801028d0:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
801028d3:	a1 64 33 11 80       	mov    0x80113364,%eax
801028d8:	85 c0                	test   %eax,%eax
801028da:	0f 84 9f 00 00 00    	je     8010297f <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
801028e0:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
801028e7:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801028ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801028f1:	e8 a6 ff ff ff       	call   8010289c <ioapicread>
801028f6:	c1 e8 10             	shr    $0x10,%eax
801028f9:	25 ff 00 00 00       	and    $0xff,%eax
801028fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102901:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102908:	e8 8f ff ff ff       	call   8010289c <ioapicread>
8010290d:	c1 e8 18             	shr    $0x18,%eax
80102910:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102913:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
8010291a:	0f b6 c0             	movzbl %al,%eax
8010291d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102920:	74 0c                	je     8010292e <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102922:	c7 04 24 1c 8c 10 80 	movl   $0x80108c1c,(%esp)
80102929:	e8 73 da ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010292e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102935:	eb 3e                	jmp    80102975 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102937:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010293a:	83 c0 20             	add    $0x20,%eax
8010293d:	0d 00 00 01 00       	or     $0x10000,%eax
80102942:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102945:	83 c2 08             	add    $0x8,%edx
80102948:	01 d2                	add    %edx,%edx
8010294a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010294e:	89 14 24             	mov    %edx,(%esp)
80102951:	e8 5d ff ff ff       	call   801028b3 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102959:	83 c0 08             	add    $0x8,%eax
8010295c:	01 c0                	add    %eax,%eax
8010295e:	83 c0 01             	add    $0x1,%eax
80102961:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102968:	00 
80102969:	89 04 24             	mov    %eax,(%esp)
8010296c:	e8 42 ff ff ff       	call   801028b3 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102971:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102978:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010297b:	7e ba                	jle    80102937 <ioapicinit+0x6a>
8010297d:	eb 01                	jmp    80102980 <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
8010297f:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102980:	c9                   	leave  
80102981:	c3                   	ret    

80102982 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102982:	55                   	push   %ebp
80102983:	89 e5                	mov    %esp,%ebp
80102985:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102988:	a1 64 33 11 80       	mov    0x80113364,%eax
8010298d:	85 c0                	test   %eax,%eax
8010298f:	74 39                	je     801029ca <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102991:	8b 45 08             	mov    0x8(%ebp),%eax
80102994:	83 c0 20             	add    $0x20,%eax
80102997:	8b 55 08             	mov    0x8(%ebp),%edx
8010299a:	83 c2 08             	add    $0x8,%edx
8010299d:	01 d2                	add    %edx,%edx
8010299f:	89 44 24 04          	mov    %eax,0x4(%esp)
801029a3:	89 14 24             	mov    %edx,(%esp)
801029a6:	e8 08 ff ff ff       	call   801028b3 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801029ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801029ae:	c1 e0 18             	shl    $0x18,%eax
801029b1:	8b 55 08             	mov    0x8(%ebp),%edx
801029b4:	83 c2 08             	add    $0x8,%edx
801029b7:	01 d2                	add    %edx,%edx
801029b9:	83 c2 01             	add    $0x1,%edx
801029bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801029c0:	89 14 24             	mov    %edx,(%esp)
801029c3:	e8 eb fe ff ff       	call   801028b3 <ioapicwrite>
801029c8:	eb 01                	jmp    801029cb <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
801029ca:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
801029cb:	c9                   	leave  
801029cc:	c3                   	ret    
801029cd:	00 00                	add    %al,(%eax)
	...

801029d0 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801029d0:	55                   	push   %ebp
801029d1:	89 e5                	mov    %esp,%ebp
801029d3:	8b 45 08             	mov    0x8(%ebp),%eax
801029d6:	05 00 00 00 80       	add    $0x80000000,%eax
801029db:	5d                   	pop    %ebp
801029dc:	c3                   	ret    

801029dd <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801029dd:	55                   	push   %ebp
801029de:	89 e5                	mov    %esp,%ebp
801029e0:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801029e3:	c7 44 24 04 4e 8c 10 	movl   $0x80108c4e,0x4(%esp)
801029ea:	80 
801029eb:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
801029f2:	e8 0f 29 00 00       	call   80105306 <initlock>
  kmem.use_lock = 0;
801029f7:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
801029fe:	00 00 00 
  freerange(vstart, vend);
80102a01:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a04:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a08:	8b 45 08             	mov    0x8(%ebp),%eax
80102a0b:	89 04 24             	mov    %eax,(%esp)
80102a0e:	e8 26 00 00 00       	call   80102a39 <freerange>
}
80102a13:	c9                   	leave  
80102a14:	c3                   	ret    

80102a15 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102a15:	55                   	push   %ebp
80102a16:	89 e5                	mov    %esp,%ebp
80102a18:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a22:	8b 45 08             	mov    0x8(%ebp),%eax
80102a25:	89 04 24             	mov    %eax,(%esp)
80102a28:	e8 0c 00 00 00       	call   80102a39 <freerange>
  kmem.use_lock = 1;
80102a2d:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
80102a34:	00 00 00 
}
80102a37:	c9                   	leave  
80102a38:	c3                   	ret    

80102a39 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a39:	55                   	push   %ebp
80102a3a:	89 e5                	mov    %esp,%ebp
80102a3c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a42:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a4f:	eb 12                	jmp    80102a63 <freerange+0x2a>
    kfree(p);
80102a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a54:	89 04 24             	mov    %eax,(%esp)
80102a57:	e8 16 00 00 00       	call   80102a72 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a5c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a66:	05 00 10 00 00       	add    $0x1000,%eax
80102a6b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102a6e:	76 e1                	jbe    80102a51 <freerange+0x18>
    kfree(p);
}
80102a70:	c9                   	leave  
80102a71:	c3                   	ret    

80102a72 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a72:	55                   	push   %ebp
80102a73:	89 e5                	mov    %esp,%ebp
80102a75:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a78:	8b 45 08             	mov    0x8(%ebp),%eax
80102a7b:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a80:	85 c0                	test   %eax,%eax
80102a82:	75 1b                	jne    80102a9f <kfree+0x2d>
80102a84:	81 7d 08 5c 63 11 80 	cmpl   $0x8011635c,0x8(%ebp)
80102a8b:	72 12                	jb     80102a9f <kfree+0x2d>
80102a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a90:	89 04 24             	mov    %eax,(%esp)
80102a93:	e8 38 ff ff ff       	call   801029d0 <v2p>
80102a98:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a9d:	76 0c                	jbe    80102aab <kfree+0x39>
    panic("kfree");
80102a9f:	c7 04 24 53 8c 10 80 	movl   $0x80108c53,(%esp)
80102aa6:	e8 92 da ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102aab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102ab2:	00 
80102ab3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102aba:	00 
80102abb:	8b 45 08             	mov    0x8(%ebp),%eax
80102abe:	89 04 24             	mov    %eax,(%esp)
80102ac1:	e8 b0 2a 00 00       	call   80105576 <memset>

  if(kmem.use_lock)
80102ac6:	a1 74 32 11 80       	mov    0x80113274,%eax
80102acb:	85 c0                	test   %eax,%eax
80102acd:	74 0c                	je     80102adb <kfree+0x69>
    acquire(&kmem.lock);
80102acf:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102ad6:	e8 4c 28 00 00       	call   80105327 <acquire>
  r = (struct run*)v;
80102adb:	8b 45 08             	mov    0x8(%ebp),%eax
80102ade:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ae1:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aea:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aef:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102af4:	a1 74 32 11 80       	mov    0x80113274,%eax
80102af9:	85 c0                	test   %eax,%eax
80102afb:	74 0c                	je     80102b09 <kfree+0x97>
    release(&kmem.lock);
80102afd:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102b04:	e8 80 28 00 00       	call   80105389 <release>
}
80102b09:	c9                   	leave  
80102b0a:	c3                   	ret    

80102b0b <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b0b:	55                   	push   %ebp
80102b0c:	89 e5                	mov    %esp,%ebp
80102b0e:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b11:	a1 74 32 11 80       	mov    0x80113274,%eax
80102b16:	85 c0                	test   %eax,%eax
80102b18:	74 0c                	je     80102b26 <kalloc+0x1b>
    acquire(&kmem.lock);
80102b1a:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102b21:	e8 01 28 00 00       	call   80105327 <acquire>
  r = kmem.freelist;
80102b26:	a1 78 32 11 80       	mov    0x80113278,%eax
80102b2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b32:	74 0a                	je     80102b3e <kalloc+0x33>
    kmem.freelist = r->next;
80102b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b37:	8b 00                	mov    (%eax),%eax
80102b39:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102b3e:	a1 74 32 11 80       	mov    0x80113274,%eax
80102b43:	85 c0                	test   %eax,%eax
80102b45:	74 0c                	je     80102b53 <kalloc+0x48>
    release(&kmem.lock);
80102b47:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102b4e:	e8 36 28 00 00       	call   80105389 <release>
  return (char*)r;
80102b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b56:	c9                   	leave  
80102b57:	c3                   	ret    

80102b58 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b58:	55                   	push   %ebp
80102b59:	89 e5                	mov    %esp,%ebp
80102b5b:	53                   	push   %ebx
80102b5c:	83 ec 14             	sub    $0x14,%esp
80102b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80102b62:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b66:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102b6a:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102b6e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102b72:	ec                   	in     (%dx),%al
80102b73:	89 c3                	mov    %eax,%ebx
80102b75:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102b78:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102b7c:	83 c4 14             	add    $0x14,%esp
80102b7f:	5b                   	pop    %ebx
80102b80:	5d                   	pop    %ebp
80102b81:	c3                   	ret    

80102b82 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102b82:	55                   	push   %ebp
80102b83:	89 e5                	mov    %esp,%ebp
80102b85:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102b88:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102b8f:	e8 c4 ff ff ff       	call   80102b58 <inb>
80102b94:	0f b6 c0             	movzbl %al,%eax
80102b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9d:	83 e0 01             	and    $0x1,%eax
80102ba0:	85 c0                	test   %eax,%eax
80102ba2:	75 0a                	jne    80102bae <kbdgetc+0x2c>
    return -1;
80102ba4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ba9:	e9 23 01 00 00       	jmp    80102cd1 <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102bae:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102bb5:	e8 9e ff ff ff       	call   80102b58 <inb>
80102bba:	0f b6 c0             	movzbl %al,%eax
80102bbd:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102bc0:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102bc7:	75 17                	jne    80102be0 <kbdgetc+0x5e>
    shift |= E0ESC;
80102bc9:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102bce:	83 c8 40             	or     $0x40,%eax
80102bd1:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102bd6:	b8 00 00 00 00       	mov    $0x0,%eax
80102bdb:	e9 f1 00 00 00       	jmp    80102cd1 <kbdgetc+0x14f>
  } else if(data & 0x80){
80102be0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102be3:	25 80 00 00 00       	and    $0x80,%eax
80102be8:	85 c0                	test   %eax,%eax
80102bea:	74 45                	je     80102c31 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102bec:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102bf1:	83 e0 40             	and    $0x40,%eax
80102bf4:	85 c0                	test   %eax,%eax
80102bf6:	75 08                	jne    80102c00 <kbdgetc+0x7e>
80102bf8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bfb:	83 e0 7f             	and    $0x7f,%eax
80102bfe:	eb 03                	jmp    80102c03 <kbdgetc+0x81>
80102c00:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c03:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c06:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c09:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102c0e:	0f b6 00             	movzbl (%eax),%eax
80102c11:	83 c8 40             	or     $0x40,%eax
80102c14:	0f b6 c0             	movzbl %al,%eax
80102c17:	f7 d0                	not    %eax
80102c19:	89 c2                	mov    %eax,%edx
80102c1b:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c20:	21 d0                	and    %edx,%eax
80102c22:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102c27:	b8 00 00 00 00       	mov    $0x0,%eax
80102c2c:	e9 a0 00 00 00       	jmp    80102cd1 <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102c31:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c36:	83 e0 40             	and    $0x40,%eax
80102c39:	85 c0                	test   %eax,%eax
80102c3b:	74 14                	je     80102c51 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c3d:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c44:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c49:	83 e0 bf             	and    $0xffffffbf,%eax
80102c4c:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102c51:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c54:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102c59:	0f b6 00             	movzbl (%eax),%eax
80102c5c:	0f b6 d0             	movzbl %al,%edx
80102c5f:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c64:	09 d0                	or     %edx,%eax
80102c66:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102c6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c6e:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102c73:	0f b6 00             	movzbl (%eax),%eax
80102c76:	0f b6 d0             	movzbl %al,%edx
80102c79:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c7e:	31 d0                	xor    %edx,%eax
80102c80:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c85:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c8a:	83 e0 03             	and    $0x3,%eax
80102c8d:	8b 04 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%eax
80102c94:	03 45 fc             	add    -0x4(%ebp),%eax
80102c97:	0f b6 00             	movzbl (%eax),%eax
80102c9a:	0f b6 c0             	movzbl %al,%eax
80102c9d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ca0:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102ca5:	83 e0 08             	and    $0x8,%eax
80102ca8:	85 c0                	test   %eax,%eax
80102caa:	74 22                	je     80102cce <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80102cac:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102cb0:	76 0c                	jbe    80102cbe <kbdgetc+0x13c>
80102cb2:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102cb6:	77 06                	ja     80102cbe <kbdgetc+0x13c>
      c += 'A' - 'a';
80102cb8:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102cbc:	eb 10                	jmp    80102cce <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
80102cbe:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102cc2:	76 0a                	jbe    80102cce <kbdgetc+0x14c>
80102cc4:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102cc8:	77 04                	ja     80102cce <kbdgetc+0x14c>
      c += 'a' - 'A';
80102cca:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102cce:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102cd1:	c9                   	leave  
80102cd2:	c3                   	ret    

80102cd3 <kbdintr>:

void
kbdintr(void)
{
80102cd3:	55                   	push   %ebp
80102cd4:	89 e5                	mov    %esp,%ebp
80102cd6:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102cd9:	c7 04 24 82 2b 10 80 	movl   $0x80102b82,(%esp)
80102ce0:	e8 c8 da ff ff       	call   801007ad <consoleintr>
}
80102ce5:	c9                   	leave  
80102ce6:	c3                   	ret    
	...

80102ce8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ce8:	55                   	push   %ebp
80102ce9:	89 e5                	mov    %esp,%ebp
80102ceb:	53                   	push   %ebx
80102cec:	83 ec 14             	sub    $0x14,%esp
80102cef:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf2:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cf6:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102cfa:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102cfe:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102d02:	ec                   	in     (%dx),%al
80102d03:	89 c3                	mov    %eax,%ebx
80102d05:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102d08:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102d0c:	83 c4 14             	add    $0x14,%esp
80102d0f:	5b                   	pop    %ebx
80102d10:	5d                   	pop    %ebp
80102d11:	c3                   	ret    

80102d12 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d12:	55                   	push   %ebp
80102d13:	89 e5                	mov    %esp,%ebp
80102d15:	83 ec 08             	sub    $0x8,%esp
80102d18:	8b 55 08             	mov    0x8(%ebp),%edx
80102d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d1e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d22:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d25:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d29:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102d2d:	ee                   	out    %al,(%dx)
}
80102d2e:	c9                   	leave  
80102d2f:	c3                   	ret    

80102d30 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102d30:	55                   	push   %ebp
80102d31:	89 e5                	mov    %esp,%ebp
80102d33:	53                   	push   %ebx
80102d34:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102d37:	9c                   	pushf  
80102d38:	5b                   	pop    %ebx
80102d39:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80102d3c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d3f:	83 c4 10             	add    $0x10,%esp
80102d42:	5b                   	pop    %ebx
80102d43:	5d                   	pop    %ebp
80102d44:	c3                   	ret    

80102d45 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102d45:	55                   	push   %ebp
80102d46:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d48:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102d4d:	8b 55 08             	mov    0x8(%ebp),%edx
80102d50:	c1 e2 02             	shl    $0x2,%edx
80102d53:	01 c2                	add    %eax,%edx
80102d55:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d58:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d5a:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102d5f:	83 c0 20             	add    $0x20,%eax
80102d62:	8b 00                	mov    (%eax),%eax
}
80102d64:	5d                   	pop    %ebp
80102d65:	c3                   	ret    

80102d66 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102d66:	55                   	push   %ebp
80102d67:	89 e5                	mov    %esp,%ebp
80102d69:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102d6c:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102d71:	85 c0                	test   %eax,%eax
80102d73:	0f 84 47 01 00 00    	je     80102ec0 <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102d79:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d80:	00 
80102d81:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102d88:	e8 b8 ff ff ff       	call   80102d45 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102d8d:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102d94:	00 
80102d95:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102d9c:	e8 a4 ff ff ff       	call   80102d45 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102da1:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102da8:	00 
80102da9:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102db0:	e8 90 ff ff ff       	call   80102d45 <lapicw>
  lapicw(TICR, 10000000); 
80102db5:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102dbc:	00 
80102dbd:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102dc4:	e8 7c ff ff ff       	call   80102d45 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102dc9:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dd0:	00 
80102dd1:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102dd8:	e8 68 ff ff ff       	call   80102d45 <lapicw>
  lapicw(LINT1, MASKED);
80102ddd:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102de4:	00 
80102de5:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102dec:	e8 54 ff ff ff       	call   80102d45 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102df1:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102df6:	83 c0 30             	add    $0x30,%eax
80102df9:	8b 00                	mov    (%eax),%eax
80102dfb:	c1 e8 10             	shr    $0x10,%eax
80102dfe:	25 ff 00 00 00       	and    $0xff,%eax
80102e03:	83 f8 03             	cmp    $0x3,%eax
80102e06:	76 14                	jbe    80102e1c <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
80102e08:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e0f:	00 
80102e10:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e17:	e8 29 ff ff ff       	call   80102d45 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e1c:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e23:	00 
80102e24:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102e2b:	e8 15 ff ff ff       	call   80102d45 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e30:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e37:	00 
80102e38:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e3f:	e8 01 ff ff ff       	call   80102d45 <lapicw>
  lapicw(ESR, 0);
80102e44:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e4b:	00 
80102e4c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e53:	e8 ed fe ff ff       	call   80102d45 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e58:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e5f:	00 
80102e60:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e67:	e8 d9 fe ff ff       	call   80102d45 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e73:	00 
80102e74:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e7b:	e8 c5 fe ff ff       	call   80102d45 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102e80:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e87:	00 
80102e88:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102e8f:	e8 b1 fe ff ff       	call   80102d45 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102e94:	90                   	nop
80102e95:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e9a:	05 00 03 00 00       	add    $0x300,%eax
80102e9f:	8b 00                	mov    (%eax),%eax
80102ea1:	25 00 10 00 00       	and    $0x1000,%eax
80102ea6:	85 c0                	test   %eax,%eax
80102ea8:	75 eb                	jne    80102e95 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102eaa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102eb1:	00 
80102eb2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102eb9:	e8 87 fe ff ff       	call   80102d45 <lapicw>
80102ebe:	eb 01                	jmp    80102ec1 <lapicinit+0x15b>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102ec0:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102ec1:	c9                   	leave  
80102ec2:	c3                   	ret    

80102ec3 <cpunum>:

int
cpunum(void)
{
80102ec3:	55                   	push   %ebp
80102ec4:	89 e5                	mov    %esp,%ebp
80102ec6:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102ec9:	e8 62 fe ff ff       	call   80102d30 <readeflags>
80102ece:	25 00 02 00 00       	and    $0x200,%eax
80102ed3:	85 c0                	test   %eax,%eax
80102ed5:	74 29                	je     80102f00 <cpunum+0x3d>
    static int n;
    if(n++ == 0)
80102ed7:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80102edc:	85 c0                	test   %eax,%eax
80102ede:	0f 94 c2             	sete   %dl
80102ee1:	83 c0 01             	add    $0x1,%eax
80102ee4:	a3 60 c6 10 80       	mov    %eax,0x8010c660
80102ee9:	84 d2                	test   %dl,%dl
80102eeb:	74 13                	je     80102f00 <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
80102eed:	8b 45 04             	mov    0x4(%ebp),%eax
80102ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ef4:	c7 04 24 5c 8c 10 80 	movl   $0x80108c5c,(%esp)
80102efb:	e8 a1 d4 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102f00:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f05:	85 c0                	test   %eax,%eax
80102f07:	74 0f                	je     80102f18 <cpunum+0x55>
    return lapic[ID]>>24;
80102f09:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f0e:	83 c0 20             	add    $0x20,%eax
80102f11:	8b 00                	mov    (%eax),%eax
80102f13:	c1 e8 18             	shr    $0x18,%eax
80102f16:	eb 05                	jmp    80102f1d <cpunum+0x5a>
  return 0;
80102f18:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f1d:	c9                   	leave  
80102f1e:	c3                   	ret    

80102f1f <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f1f:	55                   	push   %ebp
80102f20:	89 e5                	mov    %esp,%ebp
80102f22:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f25:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f2a:	85 c0                	test   %eax,%eax
80102f2c:	74 14                	je     80102f42 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102f2e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f35:	00 
80102f36:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f3d:	e8 03 fe ff ff       	call   80102d45 <lapicw>
}
80102f42:	c9                   	leave  
80102f43:	c3                   	ret    

80102f44 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f44:	55                   	push   %ebp
80102f45:	89 e5                	mov    %esp,%ebp
}
80102f47:	5d                   	pop    %ebp
80102f48:	c3                   	ret    

80102f49 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f49:	55                   	push   %ebp
80102f4a:	89 e5                	mov    %esp,%ebp
80102f4c:	83 ec 1c             	sub    $0x1c,%esp
80102f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102f52:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102f55:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f5c:	00 
80102f5d:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f64:	e8 a9 fd ff ff       	call   80102d12 <outb>
  outb(CMOS_PORT+1, 0x0A);
80102f69:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f70:	00 
80102f71:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f78:	e8 95 fd ff ff       	call   80102d12 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f7d:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f84:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f87:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102f8c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f8f:	8d 50 02             	lea    0x2(%eax),%edx
80102f92:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f95:	c1 e8 04             	shr    $0x4,%eax
80102f98:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102f9b:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f9f:	c1 e0 18             	shl    $0x18,%eax
80102fa2:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fa6:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fad:	e8 93 fd ff ff       	call   80102d45 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102fb2:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102fb9:	00 
80102fba:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fc1:	e8 7f fd ff ff       	call   80102d45 <lapicw>
  microdelay(200);
80102fc6:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fcd:	e8 72 ff ff ff       	call   80102f44 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102fd2:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102fd9:	00 
80102fda:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fe1:	e8 5f fd ff ff       	call   80102d45 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102fe6:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102fed:	e8 52 ff ff ff       	call   80102f44 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102ff2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102ff9:	eb 40                	jmp    8010303b <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80102ffb:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fff:	c1 e0 18             	shl    $0x18,%eax
80103002:	89 44 24 04          	mov    %eax,0x4(%esp)
80103006:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010300d:	e8 33 fd ff ff       	call   80102d45 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103012:	8b 45 0c             	mov    0xc(%ebp),%eax
80103015:	c1 e8 0c             	shr    $0xc,%eax
80103018:	80 cc 06             	or     $0x6,%ah
8010301b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010301f:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103026:	e8 1a fd ff ff       	call   80102d45 <lapicw>
    microdelay(200);
8010302b:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103032:	e8 0d ff ff ff       	call   80102f44 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103037:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010303b:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010303f:	7e ba                	jle    80102ffb <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103041:	c9                   	leave  
80103042:	c3                   	ret    

80103043 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103043:	55                   	push   %ebp
80103044:	89 e5                	mov    %esp,%ebp
80103046:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103049:	8b 45 08             	mov    0x8(%ebp),%eax
8010304c:	0f b6 c0             	movzbl %al,%eax
8010304f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103053:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010305a:	e8 b3 fc ff ff       	call   80102d12 <outb>
  microdelay(200);
8010305f:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103066:	e8 d9 fe ff ff       	call   80102f44 <microdelay>

  return inb(CMOS_RETURN);
8010306b:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103072:	e8 71 fc ff ff       	call   80102ce8 <inb>
80103077:	0f b6 c0             	movzbl %al,%eax
}
8010307a:	c9                   	leave  
8010307b:	c3                   	ret    

8010307c <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010307c:	55                   	push   %ebp
8010307d:	89 e5                	mov    %esp,%ebp
8010307f:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103082:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103089:	e8 b5 ff ff ff       	call   80103043 <cmos_read>
8010308e:	8b 55 08             	mov    0x8(%ebp),%edx
80103091:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103093:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010309a:	e8 a4 ff ff ff       	call   80103043 <cmos_read>
8010309f:	8b 55 08             	mov    0x8(%ebp),%edx
801030a2:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801030a5:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801030ac:	e8 92 ff ff ff       	call   80103043 <cmos_read>
801030b1:	8b 55 08             	mov    0x8(%ebp),%edx
801030b4:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801030b7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801030be:	e8 80 ff ff ff       	call   80103043 <cmos_read>
801030c3:	8b 55 08             	mov    0x8(%ebp),%edx
801030c6:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801030c9:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801030d0:	e8 6e ff ff ff       	call   80103043 <cmos_read>
801030d5:	8b 55 08             	mov    0x8(%ebp),%edx
801030d8:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801030db:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801030e2:	e8 5c ff ff ff       	call   80103043 <cmos_read>
801030e7:	8b 55 08             	mov    0x8(%ebp),%edx
801030ea:	89 42 14             	mov    %eax,0x14(%edx)
}
801030ed:	c9                   	leave  
801030ee:	c3                   	ret    

801030ef <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801030ef:	55                   	push   %ebp
801030f0:	89 e5                	mov    %esp,%ebp
801030f2:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801030f5:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801030fc:	e8 42 ff ff ff       	call   80103043 <cmos_read>
80103101:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103107:	83 e0 04             	and    $0x4,%eax
8010310a:	85 c0                	test   %eax,%eax
8010310c:	0f 94 c0             	sete   %al
8010310f:	0f b6 c0             	movzbl %al,%eax
80103112:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103115:	eb 01                	jmp    80103118 <cmostime+0x29>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103117:	90                   	nop

  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103118:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010311b:	89 04 24             	mov    %eax,(%esp)
8010311e:	e8 59 ff ff ff       	call   8010307c <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103123:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
8010312a:	e8 14 ff ff ff       	call   80103043 <cmos_read>
8010312f:	25 80 00 00 00       	and    $0x80,%eax
80103134:	85 c0                	test   %eax,%eax
80103136:	75 2b                	jne    80103163 <cmostime+0x74>
        continue;
    fill_rtcdate(&t2);
80103138:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010313b:	89 04 24             	mov    %eax,(%esp)
8010313e:	e8 39 ff ff ff       	call   8010307c <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103143:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
8010314a:	00 
8010314b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010314e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103152:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103155:	89 04 24             	mov    %eax,(%esp)
80103158:	e8 90 24 00 00       	call   801055ed <memcmp>
8010315d:	85 c0                	test   %eax,%eax
8010315f:	75 b6                	jne    80103117 <cmostime+0x28>
      break;
80103161:	eb 03                	jmp    80103166 <cmostime+0x77>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103163:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103164:	eb b1                	jmp    80103117 <cmostime+0x28>

  // convert
  if (bcd) {
80103166:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010316a:	0f 84 a8 00 00 00    	je     80103218 <cmostime+0x129>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103170:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103173:	89 c2                	mov    %eax,%edx
80103175:	c1 ea 04             	shr    $0x4,%edx
80103178:	89 d0                	mov    %edx,%eax
8010317a:	c1 e0 02             	shl    $0x2,%eax
8010317d:	01 d0                	add    %edx,%eax
8010317f:	01 c0                	add    %eax,%eax
80103181:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103184:	83 e2 0f             	and    $0xf,%edx
80103187:	01 d0                	add    %edx,%eax
80103189:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010318c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010318f:	89 c2                	mov    %eax,%edx
80103191:	c1 ea 04             	shr    $0x4,%edx
80103194:	89 d0                	mov    %edx,%eax
80103196:	c1 e0 02             	shl    $0x2,%eax
80103199:	01 d0                	add    %edx,%eax
8010319b:	01 c0                	add    %eax,%eax
8010319d:	8b 55 dc             	mov    -0x24(%ebp),%edx
801031a0:	83 e2 0f             	and    $0xf,%edx
801031a3:	01 d0                	add    %edx,%eax
801031a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801031a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801031ab:	89 c2                	mov    %eax,%edx
801031ad:	c1 ea 04             	shr    $0x4,%edx
801031b0:	89 d0                	mov    %edx,%eax
801031b2:	c1 e0 02             	shl    $0x2,%eax
801031b5:	01 d0                	add    %edx,%eax
801031b7:	01 c0                	add    %eax,%eax
801031b9:	8b 55 e0             	mov    -0x20(%ebp),%edx
801031bc:	83 e2 0f             	and    $0xf,%edx
801031bf:	01 d0                	add    %edx,%eax
801031c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801031c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801031c7:	89 c2                	mov    %eax,%edx
801031c9:	c1 ea 04             	shr    $0x4,%edx
801031cc:	89 d0                	mov    %edx,%eax
801031ce:	c1 e0 02             	shl    $0x2,%eax
801031d1:	01 d0                	add    %edx,%eax
801031d3:	01 c0                	add    %eax,%eax
801031d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801031d8:	83 e2 0f             	and    $0xf,%edx
801031db:	01 d0                	add    %edx,%eax
801031dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801031e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801031e3:	89 c2                	mov    %eax,%edx
801031e5:	c1 ea 04             	shr    $0x4,%edx
801031e8:	89 d0                	mov    %edx,%eax
801031ea:	c1 e0 02             	shl    $0x2,%eax
801031ed:	01 d0                	add    %edx,%eax
801031ef:	01 c0                	add    %eax,%eax
801031f1:	8b 55 e8             	mov    -0x18(%ebp),%edx
801031f4:	83 e2 0f             	and    $0xf,%edx
801031f7:	01 d0                	add    %edx,%eax
801031f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801031fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ff:	89 c2                	mov    %eax,%edx
80103201:	c1 ea 04             	shr    $0x4,%edx
80103204:	89 d0                	mov    %edx,%eax
80103206:	c1 e0 02             	shl    $0x2,%eax
80103209:	01 d0                	add    %edx,%eax
8010320b:	01 c0                	add    %eax,%eax
8010320d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103210:	83 e2 0f             	and    $0xf,%edx
80103213:	01 d0                	add    %edx,%eax
80103215:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103218:	8b 45 08             	mov    0x8(%ebp),%eax
8010321b:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010321e:	89 10                	mov    %edx,(%eax)
80103220:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103223:	89 50 04             	mov    %edx,0x4(%eax)
80103226:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103229:	89 50 08             	mov    %edx,0x8(%eax)
8010322c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010322f:	89 50 0c             	mov    %edx,0xc(%eax)
80103232:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103235:	89 50 10             	mov    %edx,0x10(%eax)
80103238:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010323b:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010323e:	8b 45 08             	mov    0x8(%ebp),%eax
80103241:	8b 40 14             	mov    0x14(%eax),%eax
80103244:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010324a:	8b 45 08             	mov    0x8(%ebp),%eax
8010324d:	89 50 14             	mov    %edx,0x14(%eax)
}
80103250:	c9                   	leave  
80103251:	c3                   	ret    
	...

80103254 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
80103254:	55                   	push   %ebp
80103255:	89 e5                	mov    %esp,%ebp
80103257:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010325a:	c7 44 24 04 88 8c 10 	movl   $0x80108c88,0x4(%esp)
80103261:	80 
80103262:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103269:	e8 98 20 00 00       	call   80105306 <initlock>
  readsb(ROOTDEV, &sb);
8010326e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103271:	89 44 24 04          	mov    %eax,0x4(%esp)
80103275:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010327c:	e8 77 e0 ff ff       	call   801012f8 <readsb>
  log.start = sb.size - sb.nlog;
80103281:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103284:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103287:	89 d1                	mov    %edx,%ecx
80103289:	29 c1                	sub    %eax,%ecx
8010328b:	89 c8                	mov    %ecx,%eax
8010328d:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
80103292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103295:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = ROOTDEV;
8010329a:	c7 05 c4 32 11 80 01 	movl   $0x1,0x801132c4
801032a1:	00 00 00 
  recover_from_log();
801032a4:	e8 97 01 00 00       	call   80103440 <recover_from_log>
}
801032a9:	c9                   	leave  
801032aa:	c3                   	ret    

801032ab <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801032ab:	55                   	push   %ebp
801032ac:	89 e5                	mov    %esp,%ebp
801032ae:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032b8:	e9 89 00 00 00       	jmp    80103346 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801032bd:	a1 b4 32 11 80       	mov    0x801132b4,%eax
801032c2:	03 45 f4             	add    -0xc(%ebp),%eax
801032c5:	83 c0 01             	add    $0x1,%eax
801032c8:	89 c2                	mov    %eax,%edx
801032ca:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801032cf:	89 54 24 04          	mov    %edx,0x4(%esp)
801032d3:	89 04 24             	mov    %eax,(%esp)
801032d6:	e8 cb ce ff ff       	call   801001a6 <bread>
801032db:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801032de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e1:	83 c0 10             	add    $0x10,%eax
801032e4:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
801032eb:	89 c2                	mov    %eax,%edx
801032ed:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801032f2:	89 54 24 04          	mov    %edx,0x4(%esp)
801032f6:	89 04 24             	mov    %eax,(%esp)
801032f9:	e8 a8 ce ff ff       	call   801001a6 <bread>
801032fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103301:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103304:	8d 50 18             	lea    0x18(%eax),%edx
80103307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010330a:	83 c0 18             	add    $0x18,%eax
8010330d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103314:	00 
80103315:	89 54 24 04          	mov    %edx,0x4(%esp)
80103319:	89 04 24             	mov    %eax,(%esp)
8010331c:	e8 28 23 00 00       	call   80105649 <memmove>
    bwrite(dbuf);  // write dst to disk
80103321:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103324:	89 04 24             	mov    %eax,(%esp)
80103327:	e8 b1 ce ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
8010332c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010332f:	89 04 24             	mov    %eax,(%esp)
80103332:	e8 e0 ce ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103337:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010333a:	89 04 24             	mov    %eax,(%esp)
8010333d:	e8 d5 ce ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103342:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103346:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010334b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010334e:	0f 8f 69 ff ff ff    	jg     801032bd <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103354:	c9                   	leave  
80103355:	c3                   	ret    

80103356 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103356:	55                   	push   %ebp
80103357:	89 e5                	mov    %esp,%ebp
80103359:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010335c:	a1 b4 32 11 80       	mov    0x801132b4,%eax
80103361:	89 c2                	mov    %eax,%edx
80103363:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103368:	89 54 24 04          	mov    %edx,0x4(%esp)
8010336c:	89 04 24             	mov    %eax,(%esp)
8010336f:	e8 32 ce ff ff       	call   801001a6 <bread>
80103374:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103377:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010337a:	83 c0 18             	add    $0x18,%eax
8010337d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103380:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103383:	8b 00                	mov    (%eax),%eax
80103385:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
8010338a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103391:	eb 1b                	jmp    801033ae <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103393:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103396:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103399:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010339d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033a0:	83 c2 10             	add    $0x10,%edx
801033a3:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801033aa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033ae:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801033b3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033b6:	7f db                	jg     80103393 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801033b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033bb:	89 04 24             	mov    %eax,(%esp)
801033be:	e8 54 ce ff ff       	call   80100217 <brelse>
}
801033c3:	c9                   	leave  
801033c4:	c3                   	ret    

801033c5 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801033c5:	55                   	push   %ebp
801033c6:	89 e5                	mov    %esp,%ebp
801033c8:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033cb:	a1 b4 32 11 80       	mov    0x801132b4,%eax
801033d0:	89 c2                	mov    %eax,%edx
801033d2:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801033d7:	89 54 24 04          	mov    %edx,0x4(%esp)
801033db:	89 04 24             	mov    %eax,(%esp)
801033de:	e8 c3 cd ff ff       	call   801001a6 <bread>
801033e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801033e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e9:	83 c0 18             	add    $0x18,%eax
801033ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801033ef:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
801033f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033f8:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801033fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103401:	eb 1b                	jmp    8010341e <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
80103403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103406:	83 c0 10             	add    $0x10,%eax
80103409:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
80103410:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103413:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103416:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010341a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010341e:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103423:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103426:	7f db                	jg     80103403 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103428:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010342b:	89 04 24             	mov    %eax,(%esp)
8010342e:	e8 aa cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103433:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103436:	89 04 24             	mov    %eax,(%esp)
80103439:	e8 d9 cd ff ff       	call   80100217 <brelse>
}
8010343e:	c9                   	leave  
8010343f:	c3                   	ret    

80103440 <recover_from_log>:

static void
recover_from_log(void)
{
80103440:	55                   	push   %ebp
80103441:	89 e5                	mov    %esp,%ebp
80103443:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103446:	e8 0b ff ff ff       	call   80103356 <read_head>
  install_trans(); // if committed, copy from log to disk
8010344b:	e8 5b fe ff ff       	call   801032ab <install_trans>
  log.lh.n = 0;
80103450:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
80103457:	00 00 00 
  write_head(); // clear the log
8010345a:	e8 66 ff ff ff       	call   801033c5 <write_head>
}
8010345f:	c9                   	leave  
80103460:	c3                   	ret    

80103461 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103461:	55                   	push   %ebp
80103462:	89 e5                	mov    %esp,%ebp
80103464:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103467:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010346e:	e8 b4 1e 00 00       	call   80105327 <acquire>
  while(1){
    if(log.committing){
80103473:	a1 c0 32 11 80       	mov    0x801132c0,%eax
80103478:	85 c0                	test   %eax,%eax
8010347a:	74 16                	je     80103492 <begin_op+0x31>
      sleep(&log, &log.lock);
8010347c:	c7 44 24 04 80 32 11 	movl   $0x80113280,0x4(%esp)
80103483:	80 
80103484:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010348b:	e8 b0 1b 00 00       	call   80105040 <sleep>
    } else {
      log.outstanding += 1;
      release(&log.lock);
      break;
    }
  }
80103490:	eb e1                	jmp    80103473 <begin_op+0x12>
{
  acquire(&log.lock);
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103492:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
80103498:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010349d:	8d 50 01             	lea    0x1(%eax),%edx
801034a0:	89 d0                	mov    %edx,%eax
801034a2:	c1 e0 02             	shl    $0x2,%eax
801034a5:	01 d0                	add    %edx,%eax
801034a7:	01 c0                	add    %eax,%eax
801034a9:	01 c8                	add    %ecx,%eax
801034ab:	83 f8 1e             	cmp    $0x1e,%eax
801034ae:	7e 16                	jle    801034c6 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801034b0:	c7 44 24 04 80 32 11 	movl   $0x80113280,0x4(%esp)
801034b7:	80 
801034b8:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801034bf:	e8 7c 1b 00 00       	call   80105040 <sleep>
    } else {
      log.outstanding += 1;
      release(&log.lock);
      break;
    }
  }
801034c4:	eb ad                	jmp    80103473 <begin_op+0x12>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
801034c6:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801034cb:	83 c0 01             	add    $0x1,%eax
801034ce:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
801034d3:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801034da:	e8 aa 1e 00 00       	call   80105389 <release>
      break;
801034df:	90                   	nop
    }
  }
}
801034e0:	c9                   	leave  
801034e1:	c3                   	ret    

801034e2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801034e2:	55                   	push   %ebp
801034e3:	89 e5                	mov    %esp,%ebp
801034e5:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
801034e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801034ef:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801034f6:	e8 2c 1e 00 00       	call   80105327 <acquire>
  log.outstanding -= 1;
801034fb:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103500:	83 e8 01             	sub    $0x1,%eax
80103503:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
80103508:	a1 c0 32 11 80       	mov    0x801132c0,%eax
8010350d:	85 c0                	test   %eax,%eax
8010350f:	74 0c                	je     8010351d <end_op+0x3b>
    panic("log.committing");
80103511:	c7 04 24 8c 8c 10 80 	movl   $0x80108c8c,(%esp)
80103518:	e8 20 d0 ff ff       	call   8010053d <panic>
  if(log.outstanding == 0){
8010351d:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103522:	85 c0                	test   %eax,%eax
80103524:	75 13                	jne    80103539 <end_op+0x57>
    do_commit = 1;
80103526:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010352d:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
80103534:	00 00 00 
80103537:	eb 0c                	jmp    80103545 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103539:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103540:	e8 d7 1b 00 00       	call   8010511c <wakeup>
  }
  release(&log.lock);
80103545:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010354c:	e8 38 1e 00 00       	call   80105389 <release>

  if(do_commit){
80103551:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103555:	74 33                	je     8010358a <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103557:	e8 db 00 00 00       	call   80103637 <commit>
    acquire(&log.lock);
8010355c:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103563:	e8 bf 1d 00 00       	call   80105327 <acquire>
    log.committing = 0;
80103568:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
8010356f:	00 00 00 
    wakeup(&log);
80103572:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103579:	e8 9e 1b 00 00       	call   8010511c <wakeup>
    release(&log.lock);
8010357e:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103585:	e8 ff 1d 00 00       	call   80105389 <release>
  }
}
8010358a:	c9                   	leave  
8010358b:	c3                   	ret    

8010358c <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010358c:	55                   	push   %ebp
8010358d:	89 e5                	mov    %esp,%ebp
8010358f:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103592:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103599:	e9 89 00 00 00       	jmp    80103627 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010359e:	a1 b4 32 11 80       	mov    0x801132b4,%eax
801035a3:	03 45 f4             	add    -0xc(%ebp),%eax
801035a6:	83 c0 01             	add    $0x1,%eax
801035a9:	89 c2                	mov    %eax,%edx
801035ab:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801035b0:	89 54 24 04          	mov    %edx,0x4(%esp)
801035b4:	89 04 24             	mov    %eax,(%esp)
801035b7:	e8 ea cb ff ff       	call   801001a6 <bread>
801035bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
801035bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035c2:	83 c0 10             	add    $0x10,%eax
801035c5:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
801035cc:	89 c2                	mov    %eax,%edx
801035ce:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801035d3:	89 54 24 04          	mov    %edx,0x4(%esp)
801035d7:	89 04 24             	mov    %eax,(%esp)
801035da:	e8 c7 cb ff ff       	call   801001a6 <bread>
801035df:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801035e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035e5:	8d 50 18             	lea    0x18(%eax),%edx
801035e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035eb:	83 c0 18             	add    $0x18,%eax
801035ee:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801035f5:	00 
801035f6:	89 54 24 04          	mov    %edx,0x4(%esp)
801035fa:	89 04 24             	mov    %eax,(%esp)
801035fd:	e8 47 20 00 00       	call   80105649 <memmove>
    bwrite(to);  // write the log
80103602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103605:	89 04 24             	mov    %eax,(%esp)
80103608:	e8 d0 cb ff ff       	call   801001dd <bwrite>
    brelse(from); 
8010360d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103610:	89 04 24             	mov    %eax,(%esp)
80103613:	e8 ff cb ff ff       	call   80100217 <brelse>
    brelse(to);
80103618:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010361b:	89 04 24             	mov    %eax,(%esp)
8010361e:	e8 f4 cb ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103623:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103627:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010362c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010362f:	0f 8f 69 ff ff ff    	jg     8010359e <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103635:	c9                   	leave  
80103636:	c3                   	ret    

80103637 <commit>:

static void
commit()
{
80103637:	55                   	push   %ebp
80103638:	89 e5                	mov    %esp,%ebp
8010363a:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010363d:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103642:	85 c0                	test   %eax,%eax
80103644:	7e 1e                	jle    80103664 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103646:	e8 41 ff ff ff       	call   8010358c <write_log>
    write_head();    // Write header to disk -- the real commit
8010364b:	e8 75 fd ff ff       	call   801033c5 <write_head>
    install_trans(); // Now install writes to home locations
80103650:	e8 56 fc ff ff       	call   801032ab <install_trans>
    log.lh.n = 0; 
80103655:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
8010365c:	00 00 00 
    write_head();    // Erase the transaction from the log
8010365f:	e8 61 fd ff ff       	call   801033c5 <write_head>
  }
}
80103664:	c9                   	leave  
80103665:	c3                   	ret    

80103666 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103666:	55                   	push   %ebp
80103667:	89 e5                	mov    %esp,%ebp
80103669:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010366c:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103671:	83 f8 1d             	cmp    $0x1d,%eax
80103674:	7f 12                	jg     80103688 <log_write+0x22>
80103676:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010367b:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
80103681:	83 ea 01             	sub    $0x1,%edx
80103684:	39 d0                	cmp    %edx,%eax
80103686:	7c 0c                	jl     80103694 <log_write+0x2e>
    panic("too big a transaction");
80103688:	c7 04 24 9b 8c 10 80 	movl   $0x80108c9b,(%esp)
8010368f:	e8 a9 ce ff ff       	call   8010053d <panic>
  if (log.outstanding < 1)
80103694:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103699:	85 c0                	test   %eax,%eax
8010369b:	7f 0c                	jg     801036a9 <log_write+0x43>
    panic("log_write outside of trans");
8010369d:	c7 04 24 b1 8c 10 80 	movl   $0x80108cb1,(%esp)
801036a4:	e8 94 ce ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
801036a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036b0:	eb 1d                	jmp    801036cf <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
801036b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036b5:	83 c0 10             	add    $0x10,%eax
801036b8:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
801036bf:	89 c2                	mov    %eax,%edx
801036c1:	8b 45 08             	mov    0x8(%ebp),%eax
801036c4:	8b 40 08             	mov    0x8(%eax),%eax
801036c7:	39 c2                	cmp    %eax,%edx
801036c9:	74 10                	je     801036db <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
801036cb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036cf:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036d4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036d7:	7f d9                	jg     801036b2 <log_write+0x4c>
801036d9:	eb 01                	jmp    801036dc <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
801036db:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
801036dc:	8b 45 08             	mov    0x8(%ebp),%eax
801036df:	8b 40 08             	mov    0x8(%eax),%eax
801036e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036e5:	83 c2 10             	add    $0x10,%edx
801036e8:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
  if (i == log.lh.n)
801036ef:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036f4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036f7:	75 0d                	jne    80103706 <log_write+0xa0>
    log.lh.n++;
801036f9:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036fe:	83 c0 01             	add    $0x1,%eax
80103701:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
80103706:	8b 45 08             	mov    0x8(%ebp),%eax
80103709:	8b 00                	mov    (%eax),%eax
8010370b:	89 c2                	mov    %eax,%edx
8010370d:	83 ca 04             	or     $0x4,%edx
80103710:	8b 45 08             	mov    0x8(%ebp),%eax
80103713:	89 10                	mov    %edx,(%eax)
}
80103715:	c9                   	leave  
80103716:	c3                   	ret    
	...

80103718 <v2p>:
80103718:	55                   	push   %ebp
80103719:	89 e5                	mov    %esp,%ebp
8010371b:	8b 45 08             	mov    0x8(%ebp),%eax
8010371e:	05 00 00 00 80       	add    $0x80000000,%eax
80103723:	5d                   	pop    %ebp
80103724:	c3                   	ret    

80103725 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103725:	55                   	push   %ebp
80103726:	89 e5                	mov    %esp,%ebp
80103728:	8b 45 08             	mov    0x8(%ebp),%eax
8010372b:	05 00 00 00 80       	add    $0x80000000,%eax
80103730:	5d                   	pop    %ebp
80103731:	c3                   	ret    

80103732 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103732:	55                   	push   %ebp
80103733:	89 e5                	mov    %esp,%ebp
80103735:	53                   	push   %ebx
80103736:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80103739:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010373c:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
8010373f:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103742:	89 c3                	mov    %eax,%ebx
80103744:	89 d8                	mov    %ebx,%eax
80103746:	f0 87 02             	lock xchg %eax,(%edx)
80103749:	89 c3                	mov    %eax,%ebx
8010374b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010374e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103751:	83 c4 10             	add    $0x10,%esp
80103754:	5b                   	pop    %ebx
80103755:	5d                   	pop    %ebp
80103756:	c3                   	ret    

80103757 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103757:	55                   	push   %ebp
80103758:	89 e5                	mov    %esp,%ebp
8010375a:	83 e4 f0             	and    $0xfffffff0,%esp
8010375d:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103760:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103767:	80 
80103768:	c7 04 24 5c 63 11 80 	movl   $0x8011635c,(%esp)
8010376f:	e8 69 f2 ff ff       	call   801029dd <kinit1>
  kvmalloc();      // kernel page table
80103774:	e8 59 4b 00 00       	call   801082d2 <kvmalloc>
  mpinit();        // collect info about this machine
80103779:	e8 53 04 00 00       	call   80103bd1 <mpinit>
  lapicinit();
8010377e:	e8 e3 f5 ff ff       	call   80102d66 <lapicinit>
  seginit();       // set up segments
80103783:	e8 ed 44 00 00       	call   80107c75 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103788:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010378e:	0f b6 00             	movzbl (%eax),%eax
80103791:	0f b6 c0             	movzbl %al,%eax
80103794:	89 44 24 04          	mov    %eax,0x4(%esp)
80103798:	c7 04 24 cc 8c 10 80 	movl   $0x80108ccc,(%esp)
8010379f:	e8 fd cb ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
801037a4:	e8 8d 06 00 00       	call   80103e36 <picinit>
  ioapicinit();    // another interrupt controller
801037a9:	e8 1f f1 ff ff       	call   801028cd <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801037ae:	e8 da d2 ff ff       	call   80100a8d <consoleinit>
  uartinit();      // serial port
801037b3:	e8 08 38 00 00       	call   80106fc0 <uartinit>
  pinit();         // process table
801037b8:	e8 8e 0b 00 00       	call   8010434b <pinit>
  tvinit();        // trap vectors
801037bd:	e8 a1 33 00 00       	call   80106b63 <tvinit>
  binit();         // buffer cache
801037c2:	e8 6d c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037c7:	e8 40 d7 ff ff       	call   80100f0c <fileinit>
  iinit();         // inode cache
801037cc:	e8 ee dd ff ff       	call   801015bf <iinit>
  ideinit();       // disk
801037d1:	e8 5c ed ff ff       	call   80102532 <ideinit>
  if(!ismp)
801037d6:	a1 64 33 11 80       	mov    0x80113364,%eax
801037db:	85 c0                	test   %eax,%eax
801037dd:	75 05                	jne    801037e4 <main+0x8d>
    timerinit();   // uniprocessor timer
801037df:	e8 c2 32 00 00       	call   80106aa6 <timerinit>
  startothers();   // start other processors
801037e4:	e8 7f 00 00 00       	call   80103868 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037e9:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037f0:	8e 
801037f1:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037f8:	e8 18 f2 ff ff       	call   80102a15 <kinit2>
  userinit();      // first user process
801037fd:	e8 67 0c 00 00       	call   80104469 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103802:	e8 1a 00 00 00       	call   80103821 <mpmain>

80103807 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103807:	55                   	push   %ebp
80103808:	89 e5                	mov    %esp,%ebp
8010380a:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010380d:	e8 d7 4a 00 00       	call   801082e9 <switchkvm>
  seginit();
80103812:	e8 5e 44 00 00       	call   80107c75 <seginit>
  lapicinit();
80103817:	e8 4a f5 ff ff       	call   80102d66 <lapicinit>
  mpmain();
8010381c:	e8 00 00 00 00       	call   80103821 <mpmain>

80103821 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103821:	55                   	push   %ebp
80103822:	89 e5                	mov    %esp,%ebp
80103824:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103827:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010382d:	0f b6 00             	movzbl (%eax),%eax
80103830:	0f b6 c0             	movzbl %al,%eax
80103833:	89 44 24 04          	mov    %eax,0x4(%esp)
80103837:	c7 04 24 e3 8c 10 80 	movl   $0x80108ce3,(%esp)
8010383e:	e8 5e cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80103843:	e8 8f 34 00 00       	call   80106cd7 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103848:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010384e:	05 a8 00 00 00       	add    $0xa8,%eax
80103853:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010385a:	00 
8010385b:	89 04 24             	mov    %eax,(%esp)
8010385e:	e8 cf fe ff ff       	call   80103732 <xchg>
  scheduler();     // start running processes
80103863:	e8 2c 16 00 00       	call   80104e94 <scheduler>

80103868 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103868:	55                   	push   %ebp
80103869:	89 e5                	mov    %esp,%ebp
8010386b:	53                   	push   %ebx
8010386c:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010386f:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103876:	e8 aa fe ff ff       	call   80103725 <p2v>
8010387b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010387e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103883:	89 44 24 08          	mov    %eax,0x8(%esp)
80103887:	c7 44 24 04 2c c5 10 	movl   $0x8010c52c,0x4(%esp)
8010388e:	80 
8010388f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103892:	89 04 24             	mov    %eax,(%esp)
80103895:	e8 af 1d 00 00       	call   80105649 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010389a:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
801038a1:	e9 86 00 00 00       	jmp    8010392c <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
801038a6:	e8 18 f6 ff ff       	call   80102ec3 <cpunum>
801038ab:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038b1:	05 80 33 11 80       	add    $0x80113380,%eax
801038b6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038b9:	74 69                	je     80103924 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801038bb:	e8 4b f2 ff ff       	call   80102b0b <kalloc>
801038c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c6:	83 e8 04             	sub    $0x4,%eax
801038c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801038cc:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038d2:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038d7:	83 e8 08             	sub    $0x8,%eax
801038da:	c7 00 07 38 10 80    	movl   $0x80103807,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801038e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038e3:	8d 58 f4             	lea    -0xc(%eax),%ebx
801038e6:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
801038ed:	e8 26 fe ff ff       	call   80103718 <v2p>
801038f2:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801038f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038f7:	89 04 24             	mov    %eax,(%esp)
801038fa:	e8 19 fe ff ff       	call   80103718 <v2p>
801038ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103902:	0f b6 12             	movzbl (%edx),%edx
80103905:	0f b6 d2             	movzbl %dl,%edx
80103908:	89 44 24 04          	mov    %eax,0x4(%esp)
8010390c:	89 14 24             	mov    %edx,(%esp)
8010390f:	e8 35 f6 ff ff       	call   80102f49 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103914:	90                   	nop
80103915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103918:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010391e:	85 c0                	test   %eax,%eax
80103920:	74 f3                	je     80103915 <startothers+0xad>
80103922:	eb 01                	jmp    80103925 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103924:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103925:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
8010392c:	a1 60 39 11 80       	mov    0x80113960,%eax
80103931:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103937:	05 80 33 11 80       	add    $0x80113380,%eax
8010393c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010393f:	0f 87 61 ff ff ff    	ja     801038a6 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103945:	83 c4 24             	add    $0x24,%esp
80103948:	5b                   	pop    %ebx
80103949:	5d                   	pop    %ebp
8010394a:	c3                   	ret    
	...

8010394c <p2v>:
8010394c:	55                   	push   %ebp
8010394d:	89 e5                	mov    %esp,%ebp
8010394f:	8b 45 08             	mov    0x8(%ebp),%eax
80103952:	05 00 00 00 80       	add    $0x80000000,%eax
80103957:	5d                   	pop    %ebp
80103958:	c3                   	ret    

80103959 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103959:	55                   	push   %ebp
8010395a:	89 e5                	mov    %esp,%ebp
8010395c:	53                   	push   %ebx
8010395d:	83 ec 14             	sub    $0x14,%esp
80103960:	8b 45 08             	mov    0x8(%ebp),%eax
80103963:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103967:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010396b:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010396f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80103973:	ec                   	in     (%dx),%al
80103974:	89 c3                	mov    %eax,%ebx
80103976:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103979:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
8010397d:	83 c4 14             	add    $0x14,%esp
80103980:	5b                   	pop    %ebx
80103981:	5d                   	pop    %ebp
80103982:	c3                   	ret    

80103983 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103983:	55                   	push   %ebp
80103984:	89 e5                	mov    %esp,%ebp
80103986:	83 ec 08             	sub    $0x8,%esp
80103989:	8b 55 08             	mov    0x8(%ebp),%edx
8010398c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010398f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103993:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103996:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010399a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010399e:	ee                   	out    %al,(%dx)
}
8010399f:	c9                   	leave  
801039a0:	c3                   	ret    

801039a1 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801039a1:	55                   	push   %ebp
801039a2:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801039a4:	a1 64 c6 10 80       	mov    0x8010c664,%eax
801039a9:	89 c2                	mov    %eax,%edx
801039ab:	b8 80 33 11 80       	mov    $0x80113380,%eax
801039b0:	89 d1                	mov    %edx,%ecx
801039b2:	29 c1                	sub    %eax,%ecx
801039b4:	89 c8                	mov    %ecx,%eax
801039b6:	c1 f8 02             	sar    $0x2,%eax
801039b9:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801039bf:	5d                   	pop    %ebp
801039c0:	c3                   	ret    

801039c1 <sum>:

static uchar
sum(uchar *addr, int len)
{
801039c1:	55                   	push   %ebp
801039c2:	89 e5                	mov    %esp,%ebp
801039c4:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801039c7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039ce:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039d5:	eb 13                	jmp    801039ea <sum+0x29>
    sum += addr[i];
801039d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039da:	03 45 08             	add    0x8(%ebp),%eax
801039dd:	0f b6 00             	movzbl (%eax),%eax
801039e0:	0f b6 c0             	movzbl %al,%eax
801039e3:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801039e6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801039ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039ed:	3b 45 0c             	cmp    0xc(%ebp),%eax
801039f0:	7c e5                	jl     801039d7 <sum+0x16>
    sum += addr[i];
  return sum;
801039f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801039f5:	c9                   	leave  
801039f6:	c3                   	ret    

801039f7 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801039f7:	55                   	push   %ebp
801039f8:	89 e5                	mov    %esp,%ebp
801039fa:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801039fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103a00:	89 04 24             	mov    %eax,(%esp)
80103a03:	e8 44 ff ff ff       	call   8010394c <p2v>
80103a08:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a0e:	03 45 f0             	add    -0x10(%ebp),%eax
80103a11:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a17:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a1a:	eb 3f                	jmp    80103a5b <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a1c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a23:	00 
80103a24:	c7 44 24 04 f4 8c 10 	movl   $0x80108cf4,0x4(%esp)
80103a2b:	80 
80103a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a2f:	89 04 24             	mov    %eax,(%esp)
80103a32:	e8 b6 1b 00 00       	call   801055ed <memcmp>
80103a37:	85 c0                	test   %eax,%eax
80103a39:	75 1c                	jne    80103a57 <mpsearch1+0x60>
80103a3b:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a42:	00 
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	89 04 24             	mov    %eax,(%esp)
80103a49:	e8 73 ff ff ff       	call   801039c1 <sum>
80103a4e:	84 c0                	test   %al,%al
80103a50:	75 05                	jne    80103a57 <mpsearch1+0x60>
      return (struct mp*)p;
80103a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a55:	eb 11                	jmp    80103a68 <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a57:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a61:	72 b9                	jb     80103a1c <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a63:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a68:	c9                   	leave  
80103a69:	c3                   	ret    

80103a6a <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a6a:	55                   	push   %ebp
80103a6b:	89 e5                	mov    %esp,%ebp
80103a6d:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a70:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7a:	83 c0 0f             	add    $0xf,%eax
80103a7d:	0f b6 00             	movzbl (%eax),%eax
80103a80:	0f b6 c0             	movzbl %al,%eax
80103a83:	89 c2                	mov    %eax,%edx
80103a85:	c1 e2 08             	shl    $0x8,%edx
80103a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a8b:	83 c0 0e             	add    $0xe,%eax
80103a8e:	0f b6 00             	movzbl (%eax),%eax
80103a91:	0f b6 c0             	movzbl %al,%eax
80103a94:	09 d0                	or     %edx,%eax
80103a96:	c1 e0 04             	shl    $0x4,%eax
80103a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a9c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103aa0:	74 21                	je     80103ac3 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103aa2:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103aa9:	00 
80103aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aad:	89 04 24             	mov    %eax,(%esp)
80103ab0:	e8 42 ff ff ff       	call   801039f7 <mpsearch1>
80103ab5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ab8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103abc:	74 50                	je     80103b0e <mpsearch+0xa4>
      return mp;
80103abe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ac1:	eb 5f                	jmp    80103b22 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac6:	83 c0 14             	add    $0x14,%eax
80103ac9:	0f b6 00             	movzbl (%eax),%eax
80103acc:	0f b6 c0             	movzbl %al,%eax
80103acf:	89 c2                	mov    %eax,%edx
80103ad1:	c1 e2 08             	shl    $0x8,%edx
80103ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad7:	83 c0 13             	add    $0x13,%eax
80103ada:	0f b6 00             	movzbl (%eax),%eax
80103add:	0f b6 c0             	movzbl %al,%eax
80103ae0:	09 d0                	or     %edx,%eax
80103ae2:	c1 e0 0a             	shl    $0xa,%eax
80103ae5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103ae8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aeb:	2d 00 04 00 00       	sub    $0x400,%eax
80103af0:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103af7:	00 
80103af8:	89 04 24             	mov    %eax,(%esp)
80103afb:	e8 f7 fe ff ff       	call   801039f7 <mpsearch1>
80103b00:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b03:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b07:	74 05                	je     80103b0e <mpsearch+0xa4>
      return mp;
80103b09:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b0c:	eb 14                	jmp    80103b22 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b0e:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b15:	00 
80103b16:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b1d:	e8 d5 fe ff ff       	call   801039f7 <mpsearch1>
}
80103b22:	c9                   	leave  
80103b23:	c3                   	ret    

80103b24 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b24:	55                   	push   %ebp
80103b25:	89 e5                	mov    %esp,%ebp
80103b27:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b2a:	e8 3b ff ff ff       	call   80103a6a <mpsearch>
80103b2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b36:	74 0a                	je     80103b42 <mpconfig+0x1e>
80103b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3b:	8b 40 04             	mov    0x4(%eax),%eax
80103b3e:	85 c0                	test   %eax,%eax
80103b40:	75 0a                	jne    80103b4c <mpconfig+0x28>
    return 0;
80103b42:	b8 00 00 00 00       	mov    $0x0,%eax
80103b47:	e9 83 00 00 00       	jmp    80103bcf <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4f:	8b 40 04             	mov    0x4(%eax),%eax
80103b52:	89 04 24             	mov    %eax,(%esp)
80103b55:	e8 f2 fd ff ff       	call   8010394c <p2v>
80103b5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b5d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b64:	00 
80103b65:	c7 44 24 04 f9 8c 10 	movl   $0x80108cf9,0x4(%esp)
80103b6c:	80 
80103b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b70:	89 04 24             	mov    %eax,(%esp)
80103b73:	e8 75 1a 00 00       	call   801055ed <memcmp>
80103b78:	85 c0                	test   %eax,%eax
80103b7a:	74 07                	je     80103b83 <mpconfig+0x5f>
    return 0;
80103b7c:	b8 00 00 00 00       	mov    $0x0,%eax
80103b81:	eb 4c                	jmp    80103bcf <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b86:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b8a:	3c 01                	cmp    $0x1,%al
80103b8c:	74 12                	je     80103ba0 <mpconfig+0x7c>
80103b8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b91:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b95:	3c 04                	cmp    $0x4,%al
80103b97:	74 07                	je     80103ba0 <mpconfig+0x7c>
    return 0;
80103b99:	b8 00 00 00 00       	mov    $0x0,%eax
80103b9e:	eb 2f                	jmp    80103bcf <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103ba7:	0f b7 c0             	movzwl %ax,%eax
80103baa:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bb1:	89 04 24             	mov    %eax,(%esp)
80103bb4:	e8 08 fe ff ff       	call   801039c1 <sum>
80103bb9:	84 c0                	test   %al,%al
80103bbb:	74 07                	je     80103bc4 <mpconfig+0xa0>
    return 0;
80103bbd:	b8 00 00 00 00       	mov    $0x0,%eax
80103bc2:	eb 0b                	jmp    80103bcf <mpconfig+0xab>
  *pmp = mp;
80103bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80103bc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bca:	89 10                	mov    %edx,(%eax)
  return conf;
80103bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bcf:	c9                   	leave  
80103bd0:	c3                   	ret    

80103bd1 <mpinit>:

void
mpinit(void)
{
80103bd1:	55                   	push   %ebp
80103bd2:	89 e5                	mov    %esp,%ebp
80103bd4:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103bd7:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103bde:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103be1:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103be4:	89 04 24             	mov    %eax,(%esp)
80103be7:	e8 38 ff ff ff       	call   80103b24 <mpconfig>
80103bec:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bf3:	0f 84 9c 01 00 00    	je     80103d95 <mpinit+0x1c4>
    return;
  ismp = 1;
80103bf9:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103c00:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c06:	8b 40 24             	mov    0x24(%eax),%eax
80103c09:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c11:	83 c0 2c             	add    $0x2c,%eax
80103c14:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c1e:	0f b7 c0             	movzwl %ax,%eax
80103c21:	03 45 f0             	add    -0x10(%ebp),%eax
80103c24:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c27:	e9 f4 00 00 00       	jmp    80103d20 <mpinit+0x14f>
    switch(*p){
80103c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2f:	0f b6 00             	movzbl (%eax),%eax
80103c32:	0f b6 c0             	movzbl %al,%eax
80103c35:	83 f8 04             	cmp    $0x4,%eax
80103c38:	0f 87 bf 00 00 00    	ja     80103cfd <mpinit+0x12c>
80103c3e:	8b 04 85 3c 8d 10 80 	mov    -0x7fef72c4(,%eax,4),%eax
80103c45:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c4a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c50:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c54:	0f b6 d0             	movzbl %al,%edx
80103c57:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c5c:	39 c2                	cmp    %eax,%edx
80103c5e:	74 2d                	je     80103c8d <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c60:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c63:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c67:	0f b6 d0             	movzbl %al,%edx
80103c6a:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c6f:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c73:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c77:	c7 04 24 fe 8c 10 80 	movl   $0x80108cfe,(%esp)
80103c7e:	e8 1e c7 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103c83:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103c8a:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103c8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c90:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103c94:	0f b6 c0             	movzbl %al,%eax
80103c97:	83 e0 02             	and    $0x2,%eax
80103c9a:	85 c0                	test   %eax,%eax
80103c9c:	74 15                	je     80103cb3 <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103c9e:	a1 60 39 11 80       	mov    0x80113960,%eax
80103ca3:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103ca9:	05 80 33 11 80       	add    $0x80113380,%eax
80103cae:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103cb3:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103cb9:	a1 60 39 11 80       	mov    0x80113960,%eax
80103cbe:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103cc4:	81 c2 80 33 11 80    	add    $0x80113380,%edx
80103cca:	88 02                	mov    %al,(%edx)
      ncpu++;
80103ccc:	a1 60 39 11 80       	mov    0x80113960,%eax
80103cd1:	83 c0 01             	add    $0x1,%eax
80103cd4:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103cd9:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103cdd:	eb 41                	jmp    80103d20 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103ce5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103ce8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cec:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
80103cf1:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cf5:	eb 29                	jmp    80103d20 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103cf7:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cfb:	eb 23                	jmp    80103d20 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d00:	0f b6 00             	movzbl (%eax),%eax
80103d03:	0f b6 c0             	movzbl %al,%eax
80103d06:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d0a:	c7 04 24 1c 8d 10 80 	movl   $0x80108d1c,(%esp)
80103d11:	e8 8b c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103d16:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103d1d:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d23:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d26:	0f 82 00 ff ff ff    	jb     80103c2c <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d2c:	a1 64 33 11 80       	mov    0x80113364,%eax
80103d31:	85 c0                	test   %eax,%eax
80103d33:	75 1d                	jne    80103d52 <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d35:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103d3c:	00 00 00 
    lapic = 0;
80103d3f:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103d46:	00 00 00 
    ioapicid = 0;
80103d49:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80103d50:	eb 44                	jmp    80103d96 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d52:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d55:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d59:	84 c0                	test   %al,%al
80103d5b:	74 39                	je     80103d96 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d5d:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d64:	00 
80103d65:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d6c:	e8 12 fc ff ff       	call   80103983 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d71:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d78:	e8 dc fb ff ff       	call   80103959 <inb>
80103d7d:	83 c8 01             	or     $0x1,%eax
80103d80:	0f b6 c0             	movzbl %al,%eax
80103d83:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d87:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d8e:	e8 f0 fb ff ff       	call   80103983 <outb>
80103d93:	eb 01                	jmp    80103d96 <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103d95:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103d96:	c9                   	leave  
80103d97:	c3                   	ret    

80103d98 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d98:	55                   	push   %ebp
80103d99:	89 e5                	mov    %esp,%ebp
80103d9b:	83 ec 08             	sub    $0x8,%esp
80103d9e:	8b 55 08             	mov    0x8(%ebp),%edx
80103da1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103da4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103da8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103dab:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103daf:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103db3:	ee                   	out    %al,(%dx)
}
80103db4:	c9                   	leave  
80103db5:	c3                   	ret    

80103db6 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103db6:	55                   	push   %ebp
80103db7:	89 e5                	mov    %esp,%ebp
80103db9:	83 ec 0c             	sub    $0xc,%esp
80103dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103dc3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103dc7:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103dcd:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103dd1:	0f b6 c0             	movzbl %al,%eax
80103dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
80103dd8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ddf:	e8 b4 ff ff ff       	call   80103d98 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103de4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103de8:	66 c1 e8 08          	shr    $0x8,%ax
80103dec:	0f b6 c0             	movzbl %al,%eax
80103def:	89 44 24 04          	mov    %eax,0x4(%esp)
80103df3:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103dfa:	e8 99 ff ff ff       	call   80103d98 <outb>
}
80103dff:	c9                   	leave  
80103e00:	c3                   	ret    

80103e01 <picenable>:

void
picenable(int irq)
{
80103e01:	55                   	push   %ebp
80103e02:	89 e5                	mov    %esp,%ebp
80103e04:	53                   	push   %ebx
80103e05:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e08:	8b 45 08             	mov    0x8(%ebp),%eax
80103e0b:	ba 01 00 00 00       	mov    $0x1,%edx
80103e10:	89 d3                	mov    %edx,%ebx
80103e12:	89 c1                	mov    %eax,%ecx
80103e14:	d3 e3                	shl    %cl,%ebx
80103e16:	89 d8                	mov    %ebx,%eax
80103e18:	89 c2                	mov    %eax,%edx
80103e1a:	f7 d2                	not    %edx
80103e1c:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103e23:	21 d0                	and    %edx,%eax
80103e25:	0f b7 c0             	movzwl %ax,%eax
80103e28:	89 04 24             	mov    %eax,(%esp)
80103e2b:	e8 86 ff ff ff       	call   80103db6 <picsetmask>
}
80103e30:	83 c4 04             	add    $0x4,%esp
80103e33:	5b                   	pop    %ebx
80103e34:	5d                   	pop    %ebp
80103e35:	c3                   	ret    

80103e36 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e36:	55                   	push   %ebp
80103e37:	89 e5                	mov    %esp,%ebp
80103e39:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e3c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e43:	00 
80103e44:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e4b:	e8 48 ff ff ff       	call   80103d98 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e50:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e57:	00 
80103e58:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e5f:	e8 34 ff ff ff       	call   80103d98 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e64:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e6b:	00 
80103e6c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e73:	e8 20 ff ff ff       	call   80103d98 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e78:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e7f:	00 
80103e80:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e87:	e8 0c ff ff ff       	call   80103d98 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e8c:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103e93:	00 
80103e94:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e9b:	e8 f8 fe ff ff       	call   80103d98 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103ea0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103ea7:	00 
80103ea8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eaf:	e8 e4 fe ff ff       	call   80103d98 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103eb4:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ebb:	00 
80103ebc:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103ec3:	e8 d0 fe ff ff       	call   80103d98 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103ec8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103ecf:	00 
80103ed0:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ed7:	e8 bc fe ff ff       	call   80103d98 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103edc:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103ee3:	00 
80103ee4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eeb:	e8 a8 fe ff ff       	call   80103d98 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103ef0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103ef7:	00 
80103ef8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eff:	e8 94 fe ff ff       	call   80103d98 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f04:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f0b:	00 
80103f0c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f13:	e8 80 fe ff ff       	call   80103d98 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f18:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f1f:	00 
80103f20:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f27:	e8 6c fe ff ff       	call   80103d98 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f2c:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f33:	00 
80103f34:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f3b:	e8 58 fe ff ff       	call   80103d98 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f40:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f47:	00 
80103f48:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f4f:	e8 44 fe ff ff       	call   80103d98 <outb>

  if(irqmask != 0xFFFF)
80103f54:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f5b:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f5f:	74 12                	je     80103f73 <picinit+0x13d>
    picsetmask(irqmask);
80103f61:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f68:	0f b7 c0             	movzwl %ax,%eax
80103f6b:	89 04 24             	mov    %eax,(%esp)
80103f6e:	e8 43 fe ff ff       	call   80103db6 <picsetmask>
}
80103f73:	c9                   	leave  
80103f74:	c3                   	ret    
80103f75:	00 00                	add    %al,(%eax)
	...

80103f78 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f78:	55                   	push   %ebp
80103f79:	89 e5                	mov    %esp,%ebp
80103f7b:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f85:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f88:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f91:	8b 10                	mov    (%eax),%edx
80103f93:	8b 45 08             	mov    0x8(%ebp),%eax
80103f96:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f98:	e8 8b cf ff ff       	call   80100f28 <filealloc>
80103f9d:	8b 55 08             	mov    0x8(%ebp),%edx
80103fa0:	89 02                	mov    %eax,(%edx)
80103fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa5:	8b 00                	mov    (%eax),%eax
80103fa7:	85 c0                	test   %eax,%eax
80103fa9:	0f 84 c8 00 00 00    	je     80104077 <pipealloc+0xff>
80103faf:	e8 74 cf ff ff       	call   80100f28 <filealloc>
80103fb4:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fb7:	89 02                	mov    %eax,(%edx)
80103fb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fbc:	8b 00                	mov    (%eax),%eax
80103fbe:	85 c0                	test   %eax,%eax
80103fc0:	0f 84 b1 00 00 00    	je     80104077 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103fc6:	e8 40 eb ff ff       	call   80102b0b <kalloc>
80103fcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103fd2:	0f 84 9e 00 00 00    	je     80104076 <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fdb:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103fe2:	00 00 00 
  p->writeopen = 1;
80103fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe8:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103fef:	00 00 00 
  p->nwrite = 0;
80103ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff5:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ffc:	00 00 00 
  p->nread = 0;
80103fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104002:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104009:	00 00 00 
  initlock(&p->lock, "pipe");
8010400c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400f:	c7 44 24 04 50 8d 10 	movl   $0x80108d50,0x4(%esp)
80104016:	80 
80104017:	89 04 24             	mov    %eax,(%esp)
8010401a:	e8 e7 12 00 00       	call   80105306 <initlock>
  (*f0)->type = FD_PIPE;
8010401f:	8b 45 08             	mov    0x8(%ebp),%eax
80104022:	8b 00                	mov    (%eax),%eax
80104024:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010402a:	8b 45 08             	mov    0x8(%ebp),%eax
8010402d:	8b 00                	mov    (%eax),%eax
8010402f:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104033:	8b 45 08             	mov    0x8(%ebp),%eax
80104036:	8b 00                	mov    (%eax),%eax
80104038:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010403c:	8b 45 08             	mov    0x8(%ebp),%eax
8010403f:	8b 00                	mov    (%eax),%eax
80104041:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104044:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104047:	8b 45 0c             	mov    0xc(%ebp),%eax
8010404a:	8b 00                	mov    (%eax),%eax
8010404c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104052:	8b 45 0c             	mov    0xc(%ebp),%eax
80104055:	8b 00                	mov    (%eax),%eax
80104057:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010405b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010405e:	8b 00                	mov    (%eax),%eax
80104060:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104064:	8b 45 0c             	mov    0xc(%ebp),%eax
80104067:	8b 00                	mov    (%eax),%eax
80104069:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010406c:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010406f:	b8 00 00 00 00       	mov    $0x0,%eax
80104074:	eb 43                	jmp    801040b9 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104076:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104077:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010407b:	74 0b                	je     80104088 <pipealloc+0x110>
    kfree((char*)p);
8010407d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104080:	89 04 24             	mov    %eax,(%esp)
80104083:	e8 ea e9 ff ff       	call   80102a72 <kfree>
  if(*f0)
80104088:	8b 45 08             	mov    0x8(%ebp),%eax
8010408b:	8b 00                	mov    (%eax),%eax
8010408d:	85 c0                	test   %eax,%eax
8010408f:	74 0d                	je     8010409e <pipealloc+0x126>
    fileclose(*f0);
80104091:	8b 45 08             	mov    0x8(%ebp),%eax
80104094:	8b 00                	mov    (%eax),%eax
80104096:	89 04 24             	mov    %eax,(%esp)
80104099:	e8 32 cf ff ff       	call   80100fd0 <fileclose>
  if(*f1)
8010409e:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a1:	8b 00                	mov    (%eax),%eax
801040a3:	85 c0                	test   %eax,%eax
801040a5:	74 0d                	je     801040b4 <pipealloc+0x13c>
    fileclose(*f1);
801040a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801040aa:	8b 00                	mov    (%eax),%eax
801040ac:	89 04 24             	mov    %eax,(%esp)
801040af:	e8 1c cf ff ff       	call   80100fd0 <fileclose>
  return -1;
801040b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040b9:	c9                   	leave  
801040ba:	c3                   	ret    

801040bb <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801040bb:	55                   	push   %ebp
801040bc:	89 e5                	mov    %esp,%ebp
801040be:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801040c1:	8b 45 08             	mov    0x8(%ebp),%eax
801040c4:	89 04 24             	mov    %eax,(%esp)
801040c7:	e8 5b 12 00 00       	call   80105327 <acquire>
  if(writable){
801040cc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801040d0:	74 1f                	je     801040f1 <pipeclose+0x36>
    p->writeopen = 0;
801040d2:	8b 45 08             	mov    0x8(%ebp),%eax
801040d5:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801040dc:	00 00 00 
    wakeup(&p->nread);
801040df:	8b 45 08             	mov    0x8(%ebp),%eax
801040e2:	05 34 02 00 00       	add    $0x234,%eax
801040e7:	89 04 24             	mov    %eax,(%esp)
801040ea:	e8 2d 10 00 00       	call   8010511c <wakeup>
801040ef:	eb 1d                	jmp    8010410e <pipeclose+0x53>
  } else {
    p->readopen = 0;
801040f1:	8b 45 08             	mov    0x8(%ebp),%eax
801040f4:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801040fb:	00 00 00 
    wakeup(&p->nwrite);
801040fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104101:	05 38 02 00 00       	add    $0x238,%eax
80104106:	89 04 24             	mov    %eax,(%esp)
80104109:	e8 0e 10 00 00       	call   8010511c <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010410e:	8b 45 08             	mov    0x8(%ebp),%eax
80104111:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104117:	85 c0                	test   %eax,%eax
80104119:	75 25                	jne    80104140 <pipeclose+0x85>
8010411b:	8b 45 08             	mov    0x8(%ebp),%eax
8010411e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104124:	85 c0                	test   %eax,%eax
80104126:	75 18                	jne    80104140 <pipeclose+0x85>
    release(&p->lock);
80104128:	8b 45 08             	mov    0x8(%ebp),%eax
8010412b:	89 04 24             	mov    %eax,(%esp)
8010412e:	e8 56 12 00 00       	call   80105389 <release>
    kfree((char*)p);
80104133:	8b 45 08             	mov    0x8(%ebp),%eax
80104136:	89 04 24             	mov    %eax,(%esp)
80104139:	e8 34 e9 ff ff       	call   80102a72 <kfree>
8010413e:	eb 0b                	jmp    8010414b <pipeclose+0x90>
  } else
    release(&p->lock);
80104140:	8b 45 08             	mov    0x8(%ebp),%eax
80104143:	89 04 24             	mov    %eax,(%esp)
80104146:	e8 3e 12 00 00       	call   80105389 <release>
}
8010414b:	c9                   	leave  
8010414c:	c3                   	ret    

8010414d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010414d:	55                   	push   %ebp
8010414e:	89 e5                	mov    %esp,%ebp
80104150:	53                   	push   %ebx
80104151:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104154:	8b 45 08             	mov    0x8(%ebp),%eax
80104157:	89 04 24             	mov    %eax,(%esp)
8010415a:	e8 c8 11 00 00       	call   80105327 <acquire>
  for(i = 0; i < n; i++){
8010415f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104166:	e9 a6 00 00 00       	jmp    80104211 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010416b:	8b 45 08             	mov    0x8(%ebp),%eax
8010416e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104174:	85 c0                	test   %eax,%eax
80104176:	74 0d                	je     80104185 <pipewrite+0x38>
80104178:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010417e:	8b 40 24             	mov    0x24(%eax),%eax
80104181:	85 c0                	test   %eax,%eax
80104183:	74 15                	je     8010419a <pipewrite+0x4d>
        release(&p->lock);
80104185:	8b 45 08             	mov    0x8(%ebp),%eax
80104188:	89 04 24             	mov    %eax,(%esp)
8010418b:	e8 f9 11 00 00       	call   80105389 <release>
        return -1;
80104190:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104195:	e9 9d 00 00 00       	jmp    80104237 <pipewrite+0xea>
      }
      wakeup(&p->nread);
8010419a:	8b 45 08             	mov    0x8(%ebp),%eax
8010419d:	05 34 02 00 00       	add    $0x234,%eax
801041a2:	89 04 24             	mov    %eax,(%esp)
801041a5:	e8 72 0f 00 00       	call   8010511c <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041aa:	8b 45 08             	mov    0x8(%ebp),%eax
801041ad:	8b 55 08             	mov    0x8(%ebp),%edx
801041b0:	81 c2 38 02 00 00    	add    $0x238,%edx
801041b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801041ba:	89 14 24             	mov    %edx,(%esp)
801041bd:	e8 7e 0e 00 00       	call   80105040 <sleep>
801041c2:	eb 01                	jmp    801041c5 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041c4:	90                   	nop
801041c5:	8b 45 08             	mov    0x8(%ebp),%eax
801041c8:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801041ce:	8b 45 08             	mov    0x8(%ebp),%eax
801041d1:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041d7:	05 00 02 00 00       	add    $0x200,%eax
801041dc:	39 c2                	cmp    %eax,%edx
801041de:	74 8b                	je     8010416b <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801041e0:	8b 45 08             	mov    0x8(%ebp),%eax
801041e3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041e9:	89 c3                	mov    %eax,%ebx
801041eb:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801041f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041f4:	03 55 0c             	add    0xc(%ebp),%edx
801041f7:	0f b6 0a             	movzbl (%edx),%ecx
801041fa:	8b 55 08             	mov    0x8(%ebp),%edx
801041fd:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80104201:	8d 50 01             	lea    0x1(%eax),%edx
80104204:	8b 45 08             	mov    0x8(%ebp),%eax
80104207:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010420d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104211:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104214:	3b 45 10             	cmp    0x10(%ebp),%eax
80104217:	7c ab                	jl     801041c4 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104219:	8b 45 08             	mov    0x8(%ebp),%eax
8010421c:	05 34 02 00 00       	add    $0x234,%eax
80104221:	89 04 24             	mov    %eax,(%esp)
80104224:	e8 f3 0e 00 00       	call   8010511c <wakeup>
  release(&p->lock);
80104229:	8b 45 08             	mov    0x8(%ebp),%eax
8010422c:	89 04 24             	mov    %eax,(%esp)
8010422f:	e8 55 11 00 00       	call   80105389 <release>
  return n;
80104234:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104237:	83 c4 24             	add    $0x24,%esp
8010423a:	5b                   	pop    %ebx
8010423b:	5d                   	pop    %ebp
8010423c:	c3                   	ret    

8010423d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010423d:	55                   	push   %ebp
8010423e:	89 e5                	mov    %esp,%ebp
80104240:	53                   	push   %ebx
80104241:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104244:	8b 45 08             	mov    0x8(%ebp),%eax
80104247:	89 04 24             	mov    %eax,(%esp)
8010424a:	e8 d8 10 00 00       	call   80105327 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010424f:	eb 3a                	jmp    8010428b <piperead+0x4e>
    if(proc->killed){
80104251:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104257:	8b 40 24             	mov    0x24(%eax),%eax
8010425a:	85 c0                	test   %eax,%eax
8010425c:	74 15                	je     80104273 <piperead+0x36>
      release(&p->lock);
8010425e:	8b 45 08             	mov    0x8(%ebp),%eax
80104261:	89 04 24             	mov    %eax,(%esp)
80104264:	e8 20 11 00 00       	call   80105389 <release>
      return -1;
80104269:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010426e:	e9 b6 00 00 00       	jmp    80104329 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104273:	8b 45 08             	mov    0x8(%ebp),%eax
80104276:	8b 55 08             	mov    0x8(%ebp),%edx
80104279:	81 c2 34 02 00 00    	add    $0x234,%edx
8010427f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104283:	89 14 24             	mov    %edx,(%esp)
80104286:	e8 b5 0d 00 00       	call   80105040 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010428b:	8b 45 08             	mov    0x8(%ebp),%eax
8010428e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104294:	8b 45 08             	mov    0x8(%ebp),%eax
80104297:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010429d:	39 c2                	cmp    %eax,%edx
8010429f:	75 0d                	jne    801042ae <piperead+0x71>
801042a1:	8b 45 08             	mov    0x8(%ebp),%eax
801042a4:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042aa:	85 c0                	test   %eax,%eax
801042ac:	75 a3                	jne    80104251 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042b5:	eb 49                	jmp    80104300 <piperead+0xc3>
    if(p->nread == p->nwrite)
801042b7:	8b 45 08             	mov    0x8(%ebp),%eax
801042ba:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042c0:	8b 45 08             	mov    0x8(%ebp),%eax
801042c3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042c9:	39 c2                	cmp    %eax,%edx
801042cb:	74 3d                	je     8010430a <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801042cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d0:	89 c2                	mov    %eax,%edx
801042d2:	03 55 0c             	add    0xc(%ebp),%edx
801042d5:	8b 45 08             	mov    0x8(%ebp),%eax
801042d8:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042de:	89 c3                	mov    %eax,%ebx
801042e0:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801042e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801042e9:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
801042ee:	88 0a                	mov    %cl,(%edx)
801042f0:	8d 50 01             	lea    0x1(%eax),%edx
801042f3:	8b 45 08             	mov    0x8(%ebp),%eax
801042f6:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104303:	3b 45 10             	cmp    0x10(%ebp),%eax
80104306:	7c af                	jl     801042b7 <piperead+0x7a>
80104308:	eb 01                	jmp    8010430b <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
8010430a:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010430b:	8b 45 08             	mov    0x8(%ebp),%eax
8010430e:	05 38 02 00 00       	add    $0x238,%eax
80104313:	89 04 24             	mov    %eax,(%esp)
80104316:	e8 01 0e 00 00       	call   8010511c <wakeup>
  release(&p->lock);
8010431b:	8b 45 08             	mov    0x8(%ebp),%eax
8010431e:	89 04 24             	mov    %eax,(%esp)
80104321:	e8 63 10 00 00       	call   80105389 <release>
  return i;
80104326:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104329:	83 c4 24             	add    $0x24,%esp
8010432c:	5b                   	pop    %ebx
8010432d:	5d                   	pop    %ebp
8010432e:	c3                   	ret    
	...

80104330 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104330:	55                   	push   %ebp
80104331:	89 e5                	mov    %esp,%ebp
80104333:	53                   	push   %ebx
80104334:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104337:	9c                   	pushf  
80104338:	5b                   	pop    %ebx
80104339:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010433c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010433f:	83 c4 10             	add    $0x10,%esp
80104342:	5b                   	pop    %ebx
80104343:	5d                   	pop    %ebp
80104344:	c3                   	ret    

80104345 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104345:	55                   	push   %ebp
80104346:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104348:	fb                   	sti    
}
80104349:	5d                   	pop    %ebp
8010434a:	c3                   	ret    

8010434b <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010434b:	55                   	push   %ebp
8010434c:	89 e5                	mov    %esp,%ebp
8010434e:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104351:	c7 44 24 04 58 8d 10 	movl   $0x80108d58,0x4(%esp)
80104358:	80 
80104359:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104360:	e8 a1 0f 00 00       	call   80105306 <initlock>
}
80104365:	c9                   	leave  
80104366:	c3                   	ret    

80104367 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104367:	55                   	push   %ebp
80104368:	89 e5                	mov    %esp,%ebp
8010436a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010436d:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104374:	e8 ae 0f 00 00       	call   80105327 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104379:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104380:	eb 11                	jmp    80104393 <allocproc+0x2c>
    if(p->state == UNUSED)
80104382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104385:	8b 40 0c             	mov    0xc(%eax),%eax
80104388:	85 c0                	test   %eax,%eax
8010438a:	74 26                	je     801043b2 <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010438c:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104393:	81 7d f4 b4 5a 11 80 	cmpl   $0x80115ab4,-0xc(%ebp)
8010439a:	72 e6                	jb     80104382 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010439c:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801043a3:	e8 e1 0f 00 00       	call   80105389 <release>
  return 0;
801043a8:	b8 00 00 00 00       	mov    $0x0,%eax
801043ad:	e9 b5 00 00 00       	jmp    80104467 <allocproc+0x100>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801043b2:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b6:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043bd:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801043c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043c5:	89 42 10             	mov    %eax,0x10(%edx)
801043c8:	83 c0 01             	add    $0x1,%eax
801043cb:	a3 04 c0 10 80       	mov    %eax,0x8010c004
  release(&ptable.lock);
801043d0:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801043d7:	e8 ad 0f 00 00       	call   80105389 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043dc:	e8 2a e7 ff ff       	call   80102b0b <kalloc>
801043e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043e4:	89 42 08             	mov    %eax,0x8(%edx)
801043e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ea:	8b 40 08             	mov    0x8(%eax),%eax
801043ed:	85 c0                	test   %eax,%eax
801043ef:	75 11                	jne    80104402 <allocproc+0x9b>
    p->state = UNUSED;
801043f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043fb:	b8 00 00 00 00       	mov    $0x0,%eax
80104400:	eb 65                	jmp    80104467 <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
80104402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104405:	8b 40 08             	mov    0x8(%eax),%eax
80104408:	05 00 10 00 00       	add    $0x1000,%eax
8010440d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104410:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104417:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010441a:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010441d:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104421:	ba 18 6b 10 80       	mov    $0x80106b18,%edx
80104426:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104429:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010442b:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010442f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104432:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104435:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010443e:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104445:	00 
80104446:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010444d:	00 
8010444e:	89 04 24             	mov    %eax,(%esp)
80104451:	e8 20 11 00 00       	call   80105576 <memset>
  p->context->eip = (uint)forkret;
80104456:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104459:	8b 40 1c             	mov    0x1c(%eax),%eax
8010445c:	ba 14 50 10 80       	mov    $0x80105014,%edx
80104461:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104464:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104467:	c9                   	leave  
80104468:	c3                   	ret    

80104469 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104469:	55                   	push   %ebp
8010446a:	89 e5                	mov    %esp,%ebp
8010446c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010446f:	e8 f3 fe ff ff       	call   80104367 <allocproc>
80104474:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104477:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447a:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
8010447f:	e8 91 3d 00 00       	call   80108215 <setupkvm>
80104484:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104487:	89 42 04             	mov    %eax,0x4(%edx)
8010448a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448d:	8b 40 04             	mov    0x4(%eax),%eax
80104490:	85 c0                	test   %eax,%eax
80104492:	75 0c                	jne    801044a0 <userinit+0x37>
    panic("userinit: out of memory?");
80104494:	c7 04 24 5f 8d 10 80 	movl   $0x80108d5f,(%esp)
8010449b:	e8 9d c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044a0:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a8:	8b 40 04             	mov    0x4(%eax),%eax
801044ab:	89 54 24 08          	mov    %edx,0x8(%esp)
801044af:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
801044b6:	80 
801044b7:	89 04 24             	mov    %eax,(%esp)
801044ba:	e8 ae 3f 00 00       	call   8010846d <inituvm>
  p->sz = PGSIZE;
801044bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c2:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cb:	8b 40 18             	mov    0x18(%eax),%eax
801044ce:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801044d5:	00 
801044d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044dd:	00 
801044de:	89 04 24             	mov    %eax,(%esp)
801044e1:	e8 90 10 00 00       	call   80105576 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e9:	8b 40 18             	mov    0x18(%eax),%eax
801044ec:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801044f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f5:	8b 40 18             	mov    0x18(%eax),%eax
801044f8:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801044fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104501:	8b 40 18             	mov    0x18(%eax),%eax
80104504:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104507:	8b 52 18             	mov    0x18(%edx),%edx
8010450a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010450e:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104515:	8b 40 18             	mov    0x18(%eax),%eax
80104518:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010451b:	8b 52 18             	mov    0x18(%edx),%edx
8010451e:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104522:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104529:	8b 40 18             	mov    0x18(%eax),%eax
8010452c:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104536:	8b 40 18             	mov    0x18(%eax),%eax
80104539:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104543:	8b 40 18             	mov    0x18(%eax),%eax
80104546:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010454d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104550:	83 c0 6c             	add    $0x6c,%eax
80104553:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010455a:	00 
8010455b:	c7 44 24 04 78 8d 10 	movl   $0x80108d78,0x4(%esp)
80104562:	80 
80104563:	89 04 24             	mov    %eax,(%esp)
80104566:	e8 3b 12 00 00       	call   801057a6 <safestrcpy>
  p->cwd = namei("/");
8010456b:	c7 04 24 81 8d 10 80 	movl   $0x80108d81,(%esp)
80104572:	e8 9f de ff ff       	call   80102416 <namei>
80104577:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010457a:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
8010457d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104580:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104587:	c9                   	leave  
80104588:	c3                   	ret    

80104589 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104589:	55                   	push   %ebp
8010458a:	89 e5                	mov    %esp,%ebp
8010458c:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
8010458f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104595:	8b 00                	mov    (%eax),%eax
80104597:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010459a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010459e:	7e 34                	jle    801045d4 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045a0:	8b 45 08             	mov    0x8(%ebp),%eax
801045a3:	89 c2                	mov    %eax,%edx
801045a5:	03 55 f4             	add    -0xc(%ebp),%edx
801045a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045ae:	8b 40 04             	mov    0x4(%eax),%eax
801045b1:	89 54 24 08          	mov    %edx,0x8(%esp)
801045b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045b8:	89 54 24 04          	mov    %edx,0x4(%esp)
801045bc:	89 04 24             	mov    %eax,(%esp)
801045bf:	e8 23 40 00 00       	call   801085e7 <allocuvm>
801045c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045cb:	75 41                	jne    8010460e <growproc+0x85>
      return -1;
801045cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045d2:	eb 58                	jmp    8010462c <growproc+0xa3>
  } else if(n < 0){
801045d4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045d8:	79 34                	jns    8010460e <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801045da:	8b 45 08             	mov    0x8(%ebp),%eax
801045dd:	89 c2                	mov    %eax,%edx
801045df:	03 55 f4             	add    -0xc(%ebp),%edx
801045e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045e8:	8b 40 04             	mov    0x4(%eax),%eax
801045eb:	89 54 24 08          	mov    %edx,0x8(%esp)
801045ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045f2:	89 54 24 04          	mov    %edx,0x4(%esp)
801045f6:	89 04 24             	mov    %eax,(%esp)
801045f9:	e8 c3 40 00 00       	call   801086c1 <deallocuvm>
801045fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104601:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104605:	75 07                	jne    8010460e <growproc+0x85>
      return -1;
80104607:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010460c:	eb 1e                	jmp    8010462c <growproc+0xa3>
  }
  proc->sz = sz;
8010460e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104614:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104617:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104619:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010461f:	89 04 24             	mov    %eax,(%esp)
80104622:	e8 df 3c 00 00       	call   80108306 <switchuvm>
  return 0;
80104627:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010462c:	c9                   	leave  
8010462d:	c3                   	ret    

8010462e <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010462e:	55                   	push   %ebp
8010462f:	89 e5                	mov    %esp,%ebp
80104631:	57                   	push   %edi
80104632:	56                   	push   %esi
80104633:	53                   	push   %ebx
80104634:	83 ec 2c             	sub    $0x2c,%esp

  cprintf("Inside fork function of proc.c\n");
80104637:	c7 04 24 84 8d 10 80 	movl   $0x80108d84,(%esp)
8010463e:	e8 5e bd ff ff       	call   801003a1 <cprintf>
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104643:	e8 1f fd ff ff       	call   80104367 <allocproc>
80104648:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010464b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010464f:	75 0a                	jne    8010465b <fork+0x2d>
    return -1;
80104651:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104656:	e9 52 01 00 00       	jmp    801047ad <fork+0x17f>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010465b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104661:	8b 10                	mov    (%eax),%edx
80104663:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104669:	8b 40 04             	mov    0x4(%eax),%eax
8010466c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104670:	89 04 24             	mov    %eax,(%esp)
80104673:	e8 d9 41 00 00       	call   80108851 <copyuvm>
80104678:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010467b:	89 42 04             	mov    %eax,0x4(%edx)
8010467e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104681:	8b 40 04             	mov    0x4(%eax),%eax
80104684:	85 c0                	test   %eax,%eax
80104686:	75 2c                	jne    801046b4 <fork+0x86>
    kfree(np->kstack);
80104688:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010468b:	8b 40 08             	mov    0x8(%eax),%eax
8010468e:	89 04 24             	mov    %eax,(%esp)
80104691:	e8 dc e3 ff ff       	call   80102a72 <kfree>
    np->kstack = 0;
80104696:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104699:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046af:	e9 f9 00 00 00       	jmp    801047ad <fork+0x17f>
  }
  np->sz = proc->sz;
801046b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046ba:	8b 10                	mov    (%eax),%edx
801046bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046bf:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046c1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046cb:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046d1:	8b 50 18             	mov    0x18(%eax),%edx
801046d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046da:	8b 40 18             	mov    0x18(%eax),%eax
801046dd:	89 c3                	mov    %eax,%ebx
801046df:	b8 13 00 00 00       	mov    $0x13,%eax
801046e4:	89 d7                	mov    %edx,%edi
801046e6:	89 de                	mov    %ebx,%esi
801046e8:	89 c1                	mov    %eax,%ecx
801046ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ef:	8b 40 18             	mov    0x18(%eax),%eax
801046f2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801046f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104700:	eb 3d                	jmp    8010473f <fork+0x111>
    if(proc->ofile[i])
80104702:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104708:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010470b:	83 c2 08             	add    $0x8,%edx
8010470e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104712:	85 c0                	test   %eax,%eax
80104714:	74 25                	je     8010473b <fork+0x10d>
      np->ofile[i] = filedup(proc->ofile[i]);
80104716:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010471c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010471f:	83 c2 08             	add    $0x8,%edx
80104722:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104726:	89 04 24             	mov    %eax,(%esp)
80104729:	e8 5a c8 ff ff       	call   80100f88 <filedup>
8010472e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104731:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104734:	83 c1 08             	add    $0x8,%ecx
80104737:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010473b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010473f:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104743:	7e bd                	jle    80104702 <fork+0xd4>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104745:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010474b:	8b 40 68             	mov    0x68(%eax),%eax
8010474e:	89 04 24             	mov    %eax,(%esp)
80104751:	e8 ec d0 ff ff       	call   80101842 <idup>
80104756:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104759:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010475c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104762:	8d 50 6c             	lea    0x6c(%eax),%edx
80104765:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104768:	83 c0 6c             	add    $0x6c,%eax
8010476b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104772:	00 
80104773:	89 54 24 04          	mov    %edx,0x4(%esp)
80104777:	89 04 24             	mov    %eax,(%esp)
8010477a:	e8 27 10 00 00       	call   801057a6 <safestrcpy>
 
  pid = np->pid;
8010477f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104782:	8b 40 10             	mov    0x10(%eax),%eax
80104785:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104788:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
8010478f:	e8 93 0b 00 00       	call   80105327 <acquire>
  np->state = RUNNABLE;
80104794:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104797:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
8010479e:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801047a5:	e8 df 0b 00 00       	call   80105389 <release>
  
  return pid;
801047aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047ad:	83 c4 2c             	add    $0x2c,%esp
801047b0:	5b                   	pop    %ebx
801047b1:	5e                   	pop    %esi
801047b2:	5f                   	pop    %edi
801047b3:	5d                   	pop    %ebp
801047b4:	c3                   	ret    

801047b5 <clone>:
thread to the parent, and immediately start execution of the function func in the new thread’s context.
*/

int
clone(void* function, void *arg, void *stack)
{
801047b5:	55                   	push   %ebp
801047b6:	89 e5                	mov    %esp,%ebp
801047b8:	57                   	push   %edi
801047b9:	56                   	push   %esi
801047ba:	53                   	push   %ebx
801047bb:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801047be:	e8 a4 fb ff ff       	call   80104367 <allocproc>
801047c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
801047c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801047ca:	75 0a                	jne    801047d6 <clone+0x21>
    return -1;
801047cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047d1:	e9 8f 01 00 00       	jmp    80104965 <clone+0x1b0>

  np->sz = proc->sz;
801047d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047dc:	8b 10                	mov    (%eax),%edx
801047de:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e1:	89 10                	mov    %edx,(%eax)
  // if the calling process is NOT a thread, copy it. Otherwise, copy its parent, the original caller
  if (proc->isthread == 0) {
801047e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047e9:	8b 40 7c             	mov    0x7c(%eax),%eax
801047ec:	85 c0                	test   %eax,%eax
801047ee:	75 0f                	jne    801047ff <clone+0x4a>
    np->parent = proc;
801047f0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047fa:	89 50 14             	mov    %edx,0x14(%eax)
801047fd:	eb 0f                	jmp    8010480e <clone+0x59>
  }
  else {
    np->parent = proc->parent;
801047ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104805:	8b 50 14             	mov    0x14(%eax),%edx
80104808:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010480b:	89 50 14             	mov    %edx,0x14(%eax)
  }
  *np->tf = *proc->tf;
8010480e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104811:	8b 50 18             	mov    0x18(%eax),%edx
80104814:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010481a:	8b 40 18             	mov    0x18(%eax),%eax
8010481d:	89 c3                	mov    %eax,%ebx
8010481f:	b8 13 00 00 00       	mov    $0x13,%eax
80104824:	89 d7                	mov    %edx,%edi
80104826:	89 de                	mov    %ebx,%esi
80104828:	89 c1                	mov    %eax,%ecx
8010482a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010482c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010482f:	8b 40 18             	mov    0x18(%eax),%eax
80104832:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  // reallocate old process's page table to new process
  np->pgdir = proc->pgdir;
80104839:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483f:	8b 50 04             	mov    0x4(%eax),%edx
80104842:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104845:	89 50 04             	mov    %edx,0x4(%eax)
  // modified the return ip to thread function
  np->tf->eip = (int)function;
80104848:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010484b:	8b 40 18             	mov    0x18(%eax),%eax
8010484e:	8b 55 08             	mov    0x8(%ebp),%edx
80104851:	89 50 38             	mov    %edx,0x38(%eax)
  // modified the thread indicator's value
  np->isthread = 1;
80104854:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104857:	c7 40 7c 01 00 00 00 	movl   $0x1,0x7c(%eax)
  // modified the stack
  np->stack = (int)stack;
8010485e:	8b 55 10             	mov    0x10(%ebp),%edx
80104861:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104864:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  np->tf->esp = (int)stack + 4092; // move esp to the top of the new stack
8010486a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010486d:	8b 40 18             	mov    0x18(%eax),%eax
80104870:	8b 55 10             	mov    0x10(%ebp),%edx
80104873:	81 c2 fc 0f 00 00    	add    $0xffc,%edx
80104879:	89 50 44             	mov    %edx,0x44(%eax)
  *((int *)(np->tf->esp)) = (int)arg; // push the argument
8010487c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010487f:	8b 40 18             	mov    0x18(%eax),%eax
80104882:	8b 40 44             	mov    0x44(%eax),%eax
80104885:	8b 55 0c             	mov    0xc(%ebp),%edx
80104888:	89 10                	mov    %edx,(%eax)
  *((int *)(np->tf->esp - 4)) = 0xFFFFFFFF; // push the return address
8010488a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010488d:	8b 40 18             	mov    0x18(%eax),%eax
80104890:	8b 40 44             	mov    0x44(%eax),%eax
80104893:	83 e8 04             	sub    $0x4,%eax
80104896:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  np->tf->esp -= 4;
8010489c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010489f:	8b 40 18             	mov    0x18(%eax),%eax
801048a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048a5:	8b 52 18             	mov    0x18(%edx),%edx
801048a8:	8b 52 44             	mov    0x44(%edx),%edx
801048ab:	83 ea 04             	sub    $0x4,%edx
801048ae:	89 50 44             	mov    %edx,0x44(%eax)

  for(i = 0; i < NOFILE; i++)
801048b1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801048b8:	eb 3d                	jmp    801048f7 <clone+0x142>
    if(proc->ofile[i])
801048ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048c3:	83 c2 08             	add    $0x8,%edx
801048c6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048ca:	85 c0                	test   %eax,%eax
801048cc:	74 25                	je     801048f3 <clone+0x13e>
      np->ofile[i] = filedup(proc->ofile[i]);
801048ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048d7:	83 c2 08             	add    $0x8,%edx
801048da:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048de:	89 04 24             	mov    %eax,(%esp)
801048e1:	e8 a2 c6 ff ff       	call   80100f88 <filedup>
801048e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048e9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801048ec:	83 c1 08             	add    $0x8,%ecx
801048ef:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  np->tf->esp = (int)stack + 4092; // move esp to the top of the new stack
  *((int *)(np->tf->esp)) = (int)arg; // push the argument
  *((int *)(np->tf->esp - 4)) = 0xFFFFFFFF; // push the return address
  np->tf->esp -= 4;

  for(i = 0; i < NOFILE; i++)
801048f3:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801048f7:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801048fb:	7e bd                	jle    801048ba <clone+0x105>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801048fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104903:	8b 40 68             	mov    0x68(%eax),%eax
80104906:	89 04 24             	mov    %eax,(%esp)
80104909:	e8 34 cf ff ff       	call   80101842 <idup>
8010490e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104911:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104914:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010491a:	8d 50 6c             	lea    0x6c(%eax),%edx
8010491d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104920:	83 c0 6c             	add    $0x6c,%eax
80104923:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010492a:	00 
8010492b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010492f:	89 04 24             	mov    %eax,(%esp)
80104932:	e8 6f 0e 00 00       	call   801057a6 <safestrcpy>
 
  pid = np->pid;
80104937:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010493a:	8b 40 10             	mov    0x10(%eax),%eax
8010493d:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104940:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104947:	e8 db 09 00 00       	call   80105327 <acquire>
  np->state = RUNNABLE;
8010494c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010494f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80104956:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
8010495d:	e8 27 0a 00 00       	call   80105389 <release>

  // exit();
  return pid;
80104962:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104965:	83 c4 2c             	add    $0x2c,%esp
80104968:	5b                   	pop    %ebx
80104969:	5e                   	pop    %esi
8010496a:	5f                   	pop    %edi
8010496b:	5d                   	pop    %ebp
8010496c:	c3                   	ret    

8010496d <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010496d:	55                   	push   %ebp
8010496e:	89 e5                	mov    %esp,%ebp
80104970:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104973:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010497a:	a1 68 c6 10 80       	mov    0x8010c668,%eax
8010497f:	39 c2                	cmp    %eax,%edx
80104981:	75 0c                	jne    8010498f <exit+0x22>
    panic("init exiting");
80104983:	c7 04 24 a4 8d 10 80 	movl   $0x80108da4,(%esp)
8010498a:	e8 ae bb ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010498f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104996:	eb 44                	jmp    801049dc <exit+0x6f>
    if(proc->ofile[fd]){
80104998:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010499e:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049a1:	83 c2 08             	add    $0x8,%edx
801049a4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049a8:	85 c0                	test   %eax,%eax
801049aa:	74 2c                	je     801049d8 <exit+0x6b>
      fileclose(proc->ofile[fd]);
801049ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049b5:	83 c2 08             	add    $0x8,%edx
801049b8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049bc:	89 04 24             	mov    %eax,(%esp)
801049bf:	e8 0c c6 ff ff       	call   80100fd0 <fileclose>
      proc->ofile[fd] = 0;
801049c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049cd:	83 c2 08             	add    $0x8,%edx
801049d0:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801049d7:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801049d8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801049dc:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801049e0:	7e b6                	jle    80104998 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
801049e2:	e8 7a ea ff ff       	call   80103461 <begin_op>
  iput(proc->cwd);
801049e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ed:	8b 40 68             	mov    0x68(%eax),%eax
801049f0:	89 04 24             	mov    %eax,(%esp)
801049f3:	e8 2f d0 ff ff       	call   80101a27 <iput>
  end_op();
801049f8:	e8 e5 ea ff ff       	call   801034e2 <end_op>
  proc->cwd = 0;
801049fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a03:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104a0a:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104a11:	e8 11 09 00 00       	call   80105327 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104a16:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a1c:	8b 40 14             	mov    0x14(%eax),%eax
80104a1f:	89 04 24             	mov    %eax,(%esp)
80104a22:	e8 b4 06 00 00       	call   801050db <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a27:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104a2e:	eb 68                	jmp    80104a98 <exit+0x12b>
    if(p->parent == proc){
80104a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a33:	8b 50 14             	mov    0x14(%eax),%edx
80104a36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a3c:	39 c2                	cmp    %eax,%edx
80104a3e:	75 51                	jne    80104a91 <exit+0x124>
      p->parent = initproc;
80104a40:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a49:	89 50 14             	mov    %edx,0x14(%eax)

      //Kill and free the stacks of the child threads (if any)
      if(p->isthread == 1){
80104a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a4f:	8b 40 7c             	mov    0x7c(%eax),%eax
80104a52:	83 f8 01             	cmp    $0x1,%eax
80104a55:	75 22                	jne    80104a79 <exit+0x10c>
        p->state = UNUSED;
80104a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        kfree(p->kstack);
80104a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a64:	8b 40 08             	mov    0x8(%eax),%eax
80104a67:	89 04 24             	mov    %eax,(%esp)
80104a6a:	e8 03 e0 ff ff       	call   80102a72 <kfree>
        p->kstack = 0;
80104a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a72:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
      }

      if(p->state == ZOMBIE)
80104a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7c:	8b 40 0c             	mov    0xc(%eax),%eax
80104a7f:	83 f8 05             	cmp    $0x5,%eax
80104a82:	75 0d                	jne    80104a91 <exit+0x124>
        wakeup1(initproc);
80104a84:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104a89:	89 04 24             	mov    %eax,(%esp)
80104a8c:	e8 4a 06 00 00       	call   801050db <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a91:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104a98:	81 7d f4 b4 5a 11 80 	cmpl   $0x80115ab4,-0xc(%ebp)
80104a9f:	72 8f                	jb     80104a30 <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104aa1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aa7:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104aae:	e8 7d 04 00 00       	call   80104f30 <sched>
  panic("zombie exit");
80104ab3:	c7 04 24 b1 8d 10 80 	movl   $0x80108db1,(%esp)
80104aba:	e8 7e ba ff ff       	call   8010053d <panic>

80104abf <texit>:

*/

void
texit(void *retval)
{
80104abf:	55                   	push   %ebp
80104ac0:	89 e5                	mov    %esp,%ebp
80104ac2:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104ac5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104acc:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104ad1:	39 c2                	cmp    %eax,%edx
80104ad3:	75 0c                	jne    80104ae1 <texit+0x22>
    panic("init exiting");
80104ad5:	c7 04 24 a4 8d 10 80 	movl   $0x80108da4,(%esp)
80104adc:	e8 5c ba ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104ae1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104ae8:	eb 44                	jmp    80104b2e <texit+0x6f>
    if(proc->ofile[fd]){
80104aea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104af0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104af3:	83 c2 08             	add    $0x8,%edx
80104af6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104afa:	85 c0                	test   %eax,%eax
80104afc:	74 2c                	je     80104b2a <texit+0x6b>
      fileclose(proc->ofile[fd]);
80104afe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b04:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b07:	83 c2 08             	add    $0x8,%edx
80104b0a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b0e:	89 04 24             	mov    %eax,(%esp)
80104b11:	e8 ba c4 ff ff       	call   80100fd0 <fileclose>
      proc->ofile[fd] = 0;
80104b16:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b1f:	83 c2 08             	add    $0x8,%edx
80104b22:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104b29:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104b2a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104b2e:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104b32:	7e b6                	jle    80104aea <texit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104b34:	e8 28 e9 ff ff       	call   80103461 <begin_op>
  iput(proc->cwd);
80104b39:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b3f:	8b 40 68             	mov    0x68(%eax),%eax
80104b42:	89 04 24             	mov    %eax,(%esp)
80104b45:	e8 dd ce ff ff       	call   80101a27 <iput>
  end_op();
80104b4a:	e8 93 e9 ff ff       	call   801034e2 <end_op>
  proc->cwd = 0;
80104b4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b55:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104b5c:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104b63:	e8 bf 07 00 00       	call   80105327 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104b68:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b6e:	8b 40 14             	mov    0x14(%eax),%eax
80104b71:	89 04 24             	mov    %eax,(%esp)
80104b74:	e8 62 05 00 00       	call   801050db <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b79:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104b80:	eb 68                	jmp    80104bea <texit+0x12b>
    if(p->parent == proc){
80104b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b85:	8b 50 14             	mov    0x14(%eax),%edx
80104b88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b8e:	39 c2                	cmp    %eax,%edx
80104b90:	75 51                	jne    80104be3 <texit+0x124>
      p->parent = initproc;
80104b92:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9b:	89 50 14             	mov    %edx,0x14(%eax)

      //Kill and free the stacks of the child threads (if any)
      if(p->isthread == 1){
80104b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba1:	8b 40 7c             	mov    0x7c(%eax),%eax
80104ba4:	83 f8 01             	cmp    $0x1,%eax
80104ba7:	75 22                	jne    80104bcb <texit+0x10c>
        p->state = UNUSED;
80104ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bac:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        kfree(p->kstack);
80104bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb6:	8b 40 08             	mov    0x8(%eax),%eax
80104bb9:	89 04 24             	mov    %eax,(%esp)
80104bbc:	e8 b1 de ff ff       	call   80102a72 <kfree>
        p->kstack = 0;
80104bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
      }

      if(p->state == ZOMBIE)
80104bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bce:	8b 40 0c             	mov    0xc(%eax),%eax
80104bd1:	83 f8 05             	cmp    $0x5,%eax
80104bd4:	75 0d                	jne    80104be3 <texit+0x124>
        wakeup1(initproc);
80104bd6:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104bdb:	89 04 24             	mov    %eax,(%esp)
80104bde:	e8 f8 04 00 00       	call   801050db <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104be3:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104bea:	81 7d f4 b4 5a 11 80 	cmpl   $0x80115ab4,-0xc(%ebp)
80104bf1:	72 8f                	jb     80104b82 <texit+0xc3>
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }
  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104bf3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf9:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104c00:	e8 2b 03 00 00       	call   80104f30 <sched>
  panic("zombie exit");
80104c05:	c7 04 24 b1 8d 10 80 	movl   $0x80108db1,(%esp)
80104c0c:	e8 2c b9 ff ff       	call   8010053d <panic>

80104c11 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104c11:	55                   	push   %ebp
80104c12:	89 e5                	mov    %esp,%ebp
80104c14:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104c17:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104c1e:	e8 04 07 00 00       	call   80105327 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104c23:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c2a:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104c31:	e9 9d 00 00 00       	jmp    80104cd3 <wait+0xc2>
      if(p->parent != proc)
80104c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c39:	8b 50 14             	mov    0x14(%eax),%edx
80104c3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c42:	39 c2                	cmp    %eax,%edx
80104c44:	0f 85 81 00 00 00    	jne    80104ccb <wait+0xba>
        continue;
      havekids = 1;
80104c4a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c54:	8b 40 0c             	mov    0xc(%eax),%eax
80104c57:	83 f8 05             	cmp    $0x5,%eax
80104c5a:	75 70                	jne    80104ccc <wait+0xbb>
        // Found one.
        pid = p->pid;
80104c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c5f:	8b 40 10             	mov    0x10(%eax),%eax
80104c62:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c68:	8b 40 08             	mov    0x8(%eax),%eax
80104c6b:	89 04 24             	mov    %eax,(%esp)
80104c6e:	e8 ff dd ff ff       	call   80102a72 <kfree>
        p->kstack = 0;
80104c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c76:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c80:	8b 40 04             	mov    0x4(%eax),%eax
80104c83:	89 04 24             	mov    %eax,(%esp)
80104c86:	e8 f2 3a 00 00       	call   8010877d <freevm>
        p->state = UNUSED;
80104c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c98:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cac:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb3:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104cba:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104cc1:	e8 c3 06 00 00       	call   80105389 <release>
        return pid;
80104cc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cc9:	eb 56                	jmp    80104d21 <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104ccb:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ccc:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104cd3:	81 7d f4 b4 5a 11 80 	cmpl   $0x80115ab4,-0xc(%ebp)
80104cda:	0f 82 56 ff ff ff    	jb     80104c36 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104ce0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ce4:	74 0d                	je     80104cf3 <wait+0xe2>
80104ce6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cec:	8b 40 24             	mov    0x24(%eax),%eax
80104cef:	85 c0                	test   %eax,%eax
80104cf1:	74 13                	je     80104d06 <wait+0xf5>
      release(&ptable.lock);
80104cf3:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104cfa:	e8 8a 06 00 00       	call   80105389 <release>
      return -1;
80104cff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d04:	eb 1b                	jmp    80104d21 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104d06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d0c:	c7 44 24 04 80 39 11 	movl   $0x80113980,0x4(%esp)
80104d13:	80 
80104d14:	89 04 24             	mov    %eax,(%esp)
80104d17:	e8 24 03 00 00       	call   80105040 <sleep>
  }
80104d1c:	e9 02 ff ff ff       	jmp    80104c23 <wait+0x12>
}
80104d21:	c9                   	leave  
80104d22:	c3                   	ret    

80104d23 <join>:
int join(int pid, void **stack, void **retval);
*/

int
join(int joinPid, void **stack, void **retval)
{
80104d23:	55                   	push   %ebp
80104d24:	89 e5                	mov    %esp,%ebp
80104d26:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104d29:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104d30:	e8 f2 05 00 00       	call   80105327 <acquire>
  for(;;){

    havekids = 0;
80104d35:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    //iterate through the ptable to find zombies
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d3c:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104d43:	e9 e2 00 00 00       	jmp    80104e2a <join+0x107>
      // only wait for the child thread, but not the child process of the pid given
      if(p->parent != proc || p->isthread != 1 || p->parent->pid == joinPid)
80104d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d4b:	8b 50 14             	mov    0x14(%eax),%edx
80104d4e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d54:	39 c2                	cmp    %eax,%edx
80104d56:	0f 85 c6 00 00 00    	jne    80104e22 <join+0xff>
80104d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5f:	8b 40 7c             	mov    0x7c(%eax),%eax
80104d62:	83 f8 01             	cmp    $0x1,%eax
80104d65:	0f 85 b7 00 00 00    	jne    80104e22 <join+0xff>
80104d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d6e:	8b 40 14             	mov    0x14(%eax),%eax
80104d71:	8b 40 10             	mov    0x10(%eax),%eax
80104d74:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d77:	0f 84 a5 00 00 00    	je     80104e22 <join+0xff>
        continue;
      havekids = 1;
80104d7d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      //at this point, p is the process of the zombie
      if(p->state == ZOMBIE){
80104d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d87:	8b 40 0c             	mov    0xc(%eax),%eax
80104d8a:	83 f8 05             	cmp    $0x5,%eax
80104d8d:	0f 85 90 00 00 00    	jne    80104e23 <join+0x100>
        // Found one, free its stack, make unused, etc
        pid = p->pid;
80104d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d96:	8b 40 10             	mov    0x10(%eax),%eax
80104d99:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d9f:	8b 40 08             	mov    0x8(%eax),%eax
80104da2:	89 04 24             	mov    %eax,(%esp)
80104da5:	e8 c8 dc ff ff       	call   80102a72 <kfree>
        p->kstack = 0;
80104daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        p->state = UNUSED;
80104db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104db7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc1:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dcb:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd5:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ddc:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104de3:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104dea:	e8 9a 05 00 00       	call   80105389 <release>

        //copy address of return value into retval parameter
        *(int*)retval = pid;
80104def:	8b 45 10             	mov    0x10(%ebp),%eax
80104df2:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104df5:	89 10                	mov    %edx,(%eax)
		cprintf("retval is %d inside clone\n", *(int*)retval);
80104df7:	8b 45 10             	mov    0x10(%ebp),%eax
80104dfa:	8b 00                	mov    (%eax),%eax
80104dfc:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e00:	c7 04 24 bd 8d 10 80 	movl   $0x80108dbd,(%esp)
80104e07:	e8 95 b5 ff ff       	call   801003a1 <cprintf>
        //copy address of user stack into parameter
        *(int*)stack = proc->stack;
80104e0c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e12:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104e18:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e1b:	89 10                	mov    %edx,(%eax)
        return pid;
80104e1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e20:	eb 70                	jmp    80104e92 <join+0x16f>
    havekids = 0;
    //iterate through the ptable to find zombies
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      // only wait for the child thread, but not the child process of the pid given
      if(p->parent != proc || p->isthread != 1 || p->parent->pid == joinPid)
        continue;
80104e22:	90                   	nop
  acquire(&ptable.lock);
  for(;;){

    havekids = 0;
    //iterate through the ptable to find zombies
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e23:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104e2a:	81 7d f4 b4 5a 11 80 	cmpl   $0x80115ab4,-0xc(%ebp)
80104e31:	0f 82 11 ff ff ff    	jb     80104d48 <join+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children thread.
    if(!havekids || proc->killed){
80104e37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104e3b:	74 0d                	je     80104e4a <join+0x127>
80104e3d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e43:	8b 40 24             	mov    0x24(%eax),%eax
80104e46:	85 c0                	test   %eax,%eax
80104e48:	74 2d                	je     80104e77 <join+0x154>
      release(&ptable.lock);
80104e4a:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104e51:	e8 33 05 00 00       	call   80105389 <release>
      //copy address of return value into retval parameter
      *(int*)retval = -1;
80104e56:	8b 45 10             	mov    0x10(%ebp),%eax
80104e59:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
      //copy address of user stack into parameter
      *(int*)stack = proc->stack;
80104e5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e65:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e6e:	89 10                	mov    %edx,(%eax)
      return -1;
80104e70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e75:	eb 1b                	jmp    80104e92 <join+0x16f>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104e77:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e7d:	c7 44 24 04 80 39 11 	movl   $0x80113980,0x4(%esp)
80104e84:	80 
80104e85:	89 04 24             	mov    %eax,(%esp)
80104e88:	e8 b3 01 00 00       	call   80105040 <sleep>

  }
80104e8d:	e9 a3 fe ff ff       	jmp    80104d35 <join+0x12>
}
80104e92:	c9                   	leave  
80104e93:	c3                   	ret    

80104e94 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104e94:	55                   	push   %ebp
80104e95:	89 e5                	mov    %esp,%ebp
80104e97:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104e9a:	e8 a6 f4 ff ff       	call   80104345 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104e9f:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104ea6:	e8 7c 04 00 00       	call   80105327 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104eab:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104eb2:	eb 62                	jmp    80104f16 <scheduler+0x82>
      if(p->state != RUNNABLE)
80104eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb7:	8b 40 0c             	mov    0xc(%eax),%eax
80104eba:	83 f8 03             	cmp    $0x3,%eax
80104ebd:	75 4f                	jne    80104f0e <scheduler+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec2:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ecb:	89 04 24             	mov    %eax,(%esp)
80104ece:	e8 33 34 00 00       	call   80108306 <switchuvm>
      p->state = RUNNING;
80104ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed6:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104edd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ee3:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ee6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104eed:	83 c2 04             	add    $0x4,%edx
80104ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ef4:	89 14 24             	mov    %edx,(%esp)
80104ef7:	e8 20 09 00 00       	call   8010581c <swtch>
      switchkvm();
80104efc:	e8 e8 33 00 00       	call   801082e9 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104f01:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104f08:	00 00 00 00 
80104f0c:	eb 01                	jmp    80104f0f <scheduler+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104f0e:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f0f:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104f16:	81 7d f4 b4 5a 11 80 	cmpl   $0x80115ab4,-0xc(%ebp)
80104f1d:	72 95                	jb     80104eb4 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104f1f:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104f26:	e8 5e 04 00 00       	call   80105389 <release>

  }
80104f2b:	e9 6a ff ff ff       	jmp    80104e9a <scheduler+0x6>

80104f30 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104f30:	55                   	push   %ebp
80104f31:	89 e5                	mov    %esp,%ebp
80104f33:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104f36:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104f3d:	e8 03 05 00 00       	call   80105445 <holding>
80104f42:	85 c0                	test   %eax,%eax
80104f44:	75 0c                	jne    80104f52 <sched+0x22>
    panic("sched ptable.lock");
80104f46:	c7 04 24 d8 8d 10 80 	movl   $0x80108dd8,(%esp)
80104f4d:	e8 eb b5 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104f52:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f58:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104f5e:	83 f8 01             	cmp    $0x1,%eax
80104f61:	74 0c                	je     80104f6f <sched+0x3f>
    panic("sched locks");
80104f63:	c7 04 24 ea 8d 10 80 	movl   $0x80108dea,(%esp)
80104f6a:	e8 ce b5 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104f6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f75:	8b 40 0c             	mov    0xc(%eax),%eax
80104f78:	83 f8 04             	cmp    $0x4,%eax
80104f7b:	75 0c                	jne    80104f89 <sched+0x59>
    panic("sched running");
80104f7d:	c7 04 24 f6 8d 10 80 	movl   $0x80108df6,(%esp)
80104f84:	e8 b4 b5 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104f89:	e8 a2 f3 ff ff       	call   80104330 <readeflags>
80104f8e:	25 00 02 00 00       	and    $0x200,%eax
80104f93:	85 c0                	test   %eax,%eax
80104f95:	74 0c                	je     80104fa3 <sched+0x73>
    panic("sched interruptible");
80104f97:	c7 04 24 04 8e 10 80 	movl   $0x80108e04,(%esp)
80104f9e:	e8 9a b5 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104fa3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fa9:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104faf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104fb2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fb8:	8b 40 04             	mov    0x4(%eax),%eax
80104fbb:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104fc2:	83 c2 1c             	add    $0x1c,%edx
80104fc5:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fc9:	89 14 24             	mov    %edx,(%esp)
80104fcc:	e8 4b 08 00 00       	call   8010581c <swtch>
  cpu->intena = intena;
80104fd1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fd7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fda:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104fe0:	c9                   	leave  
80104fe1:	c3                   	ret    

80104fe2 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104fe2:	55                   	push   %ebp
80104fe3:	89 e5                	mov    %esp,%ebp
80104fe5:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104fe8:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104fef:	e8 33 03 00 00       	call   80105327 <acquire>
  proc->state = RUNNABLE;
80104ff4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ffa:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80105001:	e8 2a ff ff ff       	call   80104f30 <sched>
  release(&ptable.lock);
80105006:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
8010500d:	e8 77 03 00 00       	call   80105389 <release>
}
80105012:	c9                   	leave  
80105013:	c3                   	ret    

80105014 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105014:	55                   	push   %ebp
80105015:	89 e5                	mov    %esp,%ebp
80105017:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010501a:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80105021:	e8 63 03 00 00       	call   80105389 <release>

  if (first) {
80105026:	a1 20 c0 10 80       	mov    0x8010c020,%eax
8010502b:	85 c0                	test   %eax,%eax
8010502d:	74 0f                	je     8010503e <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
8010502f:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
80105036:	00 00 00 
    initlog();
80105039:	e8 16 e2 ff ff       	call   80103254 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
8010503e:	c9                   	leave  
8010503f:	c3                   	ret    

80105040 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80105040:	55                   	push   %ebp
80105041:	89 e5                	mov    %esp,%ebp
80105043:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80105046:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010504c:	85 c0                	test   %eax,%eax
8010504e:	75 0c                	jne    8010505c <sleep+0x1c>
    panic("sleep");
80105050:	c7 04 24 18 8e 10 80 	movl   $0x80108e18,(%esp)
80105057:	e8 e1 b4 ff ff       	call   8010053d <panic>

  if(lk == 0)
8010505c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105060:	75 0c                	jne    8010506e <sleep+0x2e>
    panic("sleep without lk");
80105062:	c7 04 24 1e 8e 10 80 	movl   $0x80108e1e,(%esp)
80105069:	e8 cf b4 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010506e:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80105075:	74 17                	je     8010508e <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80105077:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
8010507e:	e8 a4 02 00 00       	call   80105327 <acquire>
    release(lk);
80105083:	8b 45 0c             	mov    0xc(%ebp),%eax
80105086:	89 04 24             	mov    %eax,(%esp)
80105089:	e8 fb 02 00 00       	call   80105389 <release>
  }

  // Go to sleep.
  proc->chan = chan;
8010508e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105094:	8b 55 08             	mov    0x8(%ebp),%edx
80105097:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
8010509a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050a0:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801050a7:	e8 84 fe ff ff       	call   80104f30 <sched>

  // Tidy up.
  proc->chan = 0;
801050ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050b2:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801050b9:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
801050c0:	74 17                	je     801050d9 <sleep+0x99>
    release(&ptable.lock);
801050c2:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801050c9:	e8 bb 02 00 00       	call   80105389 <release>
    acquire(lk);
801050ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801050d1:	89 04 24             	mov    %eax,(%esp)
801050d4:	e8 4e 02 00 00       	call   80105327 <acquire>
  }
}
801050d9:	c9                   	leave  
801050da:	c3                   	ret    

801050db <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801050db:	55                   	push   %ebp
801050dc:	89 e5                	mov    %esp,%ebp
801050de:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801050e1:	c7 45 fc b4 39 11 80 	movl   $0x801139b4,-0x4(%ebp)
801050e8:	eb 27                	jmp    80105111 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
801050ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050ed:	8b 40 0c             	mov    0xc(%eax),%eax
801050f0:	83 f8 02             	cmp    $0x2,%eax
801050f3:	75 15                	jne    8010510a <wakeup1+0x2f>
801050f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050f8:	8b 40 20             	mov    0x20(%eax),%eax
801050fb:	3b 45 08             	cmp    0x8(%ebp),%eax
801050fe:	75 0a                	jne    8010510a <wakeup1+0x2f>
      p->state = RUNNABLE;
80105100:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105103:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010510a:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80105111:	81 7d fc b4 5a 11 80 	cmpl   $0x80115ab4,-0x4(%ebp)
80105118:	72 d0                	jb     801050ea <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
8010511a:	c9                   	leave  
8010511b:	c3                   	ret    

8010511c <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010511c:	55                   	push   %ebp
8010511d:	89 e5                	mov    %esp,%ebp
8010511f:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80105122:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80105129:	e8 f9 01 00 00       	call   80105327 <acquire>
  wakeup1(chan);
8010512e:	8b 45 08             	mov    0x8(%ebp),%eax
80105131:	89 04 24             	mov    %eax,(%esp)
80105134:	e8 a2 ff ff ff       	call   801050db <wakeup1>
  release(&ptable.lock);
80105139:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80105140:	e8 44 02 00 00       	call   80105389 <release>
}
80105145:	c9                   	leave  
80105146:	c3                   	ret    

80105147 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105147:	55                   	push   %ebp
80105148:	89 e5                	mov    %esp,%ebp
8010514a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010514d:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80105154:	e8 ce 01 00 00       	call   80105327 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105159:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80105160:	eb 44                	jmp    801051a6 <kill+0x5f>
    if(p->pid == pid){
80105162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105165:	8b 40 10             	mov    0x10(%eax),%eax
80105168:	3b 45 08             	cmp    0x8(%ebp),%eax
8010516b:	75 32                	jne    8010519f <kill+0x58>
      p->killed = 1;
8010516d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105170:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010517a:	8b 40 0c             	mov    0xc(%eax),%eax
8010517d:	83 f8 02             	cmp    $0x2,%eax
80105180:	75 0a                	jne    8010518c <kill+0x45>
        p->state = RUNNABLE;
80105182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105185:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010518c:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80105193:	e8 f1 01 00 00       	call   80105389 <release>
      return 0;
80105198:	b8 00 00 00 00       	mov    $0x0,%eax
8010519d:	eb 21                	jmp    801051c0 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010519f:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801051a6:	81 7d f4 b4 5a 11 80 	cmpl   $0x80115ab4,-0xc(%ebp)
801051ad:	72 b3                	jb     80105162 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801051af:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801051b6:	e8 ce 01 00 00       	call   80105389 <release>
  return -1;
801051bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801051c0:	c9                   	leave  
801051c1:	c3                   	ret    

801051c2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801051c2:	55                   	push   %ebp
801051c3:	89 e5                	mov    %esp,%ebp
801051c5:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051c8:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
801051cf:	e9 db 00 00 00       	jmp    801052af <procdump+0xed>
    if(p->state == UNUSED)
801051d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051d7:	8b 40 0c             	mov    0xc(%eax),%eax
801051da:	85 c0                	test   %eax,%eax
801051dc:	0f 84 c5 00 00 00    	je     801052a7 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801051e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051e5:	8b 40 0c             	mov    0xc(%eax),%eax
801051e8:	83 f8 05             	cmp    $0x5,%eax
801051eb:	77 23                	ja     80105210 <procdump+0x4e>
801051ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f0:	8b 40 0c             	mov    0xc(%eax),%eax
801051f3:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
801051fa:	85 c0                	test   %eax,%eax
801051fc:	74 12                	je     80105210 <procdump+0x4e>
      state = states[p->state];
801051fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105201:	8b 40 0c             	mov    0xc(%eax),%eax
80105204:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010520b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010520e:	eb 07                	jmp    80105217 <procdump+0x55>
    else
      state = "???";
80105210:	c7 45 ec 2f 8e 10 80 	movl   $0x80108e2f,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105217:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010521a:	8d 50 6c             	lea    0x6c(%eax),%edx
8010521d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105220:	8b 40 10             	mov    0x10(%eax),%eax
80105223:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105227:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010522a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010522e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105232:	c7 04 24 33 8e 10 80 	movl   $0x80108e33,(%esp)
80105239:	e8 63 b1 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
8010523e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105241:	8b 40 0c             	mov    0xc(%eax),%eax
80105244:	83 f8 02             	cmp    $0x2,%eax
80105247:	75 50                	jne    80105299 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105249:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010524c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010524f:	8b 40 0c             	mov    0xc(%eax),%eax
80105252:	83 c0 08             	add    $0x8,%eax
80105255:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80105258:	89 54 24 04          	mov    %edx,0x4(%esp)
8010525c:	89 04 24             	mov    %eax,(%esp)
8010525f:	e8 74 01 00 00       	call   801053d8 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80105264:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010526b:	eb 1b                	jmp    80105288 <procdump+0xc6>
        cprintf(" %p", pc[i]);
8010526d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105270:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105274:	89 44 24 04          	mov    %eax,0x4(%esp)
80105278:	c7 04 24 3c 8e 10 80 	movl   $0x80108e3c,(%esp)
8010527f:	e8 1d b1 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105284:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105288:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010528c:	7f 0b                	jg     80105299 <procdump+0xd7>
8010528e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105291:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105295:	85 c0                	test   %eax,%eax
80105297:	75 d4                	jne    8010526d <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105299:	c7 04 24 40 8e 10 80 	movl   $0x80108e40,(%esp)
801052a0:	e8 fc b0 ff ff       	call   801003a1 <cprintf>
801052a5:	eb 01                	jmp    801052a8 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
801052a7:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052a8:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
801052af:	81 7d f0 b4 5a 11 80 	cmpl   $0x80115ab4,-0x10(%ebp)
801052b6:	0f 82 18 ff ff ff    	jb     801051d4 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801052bc:	c9                   	leave  
801052bd:	c3                   	ret    
	...

801052c0 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801052c0:	55                   	push   %ebp
801052c1:	89 e5                	mov    %esp,%ebp
801052c3:	53                   	push   %ebx
801052c4:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801052c7:	9c                   	pushf  
801052c8:	5b                   	pop    %ebx
801052c9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
801052cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801052cf:	83 c4 10             	add    $0x10,%esp
801052d2:	5b                   	pop    %ebx
801052d3:	5d                   	pop    %ebp
801052d4:	c3                   	ret    

801052d5 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801052d5:	55                   	push   %ebp
801052d6:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801052d8:	fa                   	cli    
}
801052d9:	5d                   	pop    %ebp
801052da:	c3                   	ret    

801052db <sti>:

static inline void
sti(void)
{
801052db:	55                   	push   %ebp
801052dc:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801052de:	fb                   	sti    
}
801052df:	5d                   	pop    %ebp
801052e0:	c3                   	ret    

801052e1 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801052e1:	55                   	push   %ebp
801052e2:	89 e5                	mov    %esp,%ebp
801052e4:	53                   	push   %ebx
801052e5:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
801052e8:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801052eb:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
801052ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801052f1:	89 c3                	mov    %eax,%ebx
801052f3:	89 d8                	mov    %ebx,%eax
801052f5:	f0 87 02             	lock xchg %eax,(%edx)
801052f8:	89 c3                	mov    %eax,%ebx
801052fa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801052fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105300:	83 c4 10             	add    $0x10,%esp
80105303:	5b                   	pop    %ebx
80105304:	5d                   	pop    %ebp
80105305:	c3                   	ret    

80105306 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105306:	55                   	push   %ebp
80105307:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105309:	8b 45 08             	mov    0x8(%ebp),%eax
8010530c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010530f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105312:	8b 45 08             	mov    0x8(%ebp),%eax
80105315:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010531b:	8b 45 08             	mov    0x8(%ebp),%eax
8010531e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105325:	5d                   	pop    %ebp
80105326:	c3                   	ret    

80105327 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105327:	55                   	push   %ebp
80105328:	89 e5                	mov    %esp,%ebp
8010532a:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010532d:	e8 3d 01 00 00       	call   8010546f <pushcli>
  if(holding(lk))
80105332:	8b 45 08             	mov    0x8(%ebp),%eax
80105335:	89 04 24             	mov    %eax,(%esp)
80105338:	e8 08 01 00 00       	call   80105445 <holding>
8010533d:	85 c0                	test   %eax,%eax
8010533f:	74 0c                	je     8010534d <acquire+0x26>
    panic("acquire");
80105341:	c7 04 24 6c 8e 10 80 	movl   $0x80108e6c,(%esp)
80105348:	e8 f0 b1 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
8010534d:	90                   	nop
8010534e:	8b 45 08             	mov    0x8(%ebp),%eax
80105351:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105358:	00 
80105359:	89 04 24             	mov    %eax,(%esp)
8010535c:	e8 80 ff ff ff       	call   801052e1 <xchg>
80105361:	85 c0                	test   %eax,%eax
80105363:	75 e9                	jne    8010534e <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105365:	8b 45 08             	mov    0x8(%ebp),%eax
80105368:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010536f:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105372:	8b 45 08             	mov    0x8(%ebp),%eax
80105375:	83 c0 0c             	add    $0xc,%eax
80105378:	89 44 24 04          	mov    %eax,0x4(%esp)
8010537c:	8d 45 08             	lea    0x8(%ebp),%eax
8010537f:	89 04 24             	mov    %eax,(%esp)
80105382:	e8 51 00 00 00       	call   801053d8 <getcallerpcs>
}
80105387:	c9                   	leave  
80105388:	c3                   	ret    

80105389 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105389:	55                   	push   %ebp
8010538a:	89 e5                	mov    %esp,%ebp
8010538c:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
8010538f:	8b 45 08             	mov    0x8(%ebp),%eax
80105392:	89 04 24             	mov    %eax,(%esp)
80105395:	e8 ab 00 00 00       	call   80105445 <holding>
8010539a:	85 c0                	test   %eax,%eax
8010539c:	75 0c                	jne    801053aa <release+0x21>
    panic("release");
8010539e:	c7 04 24 74 8e 10 80 	movl   $0x80108e74,(%esp)
801053a5:	e8 93 b1 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
801053aa:	8b 45 08             	mov    0x8(%ebp),%eax
801053ad:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801053b4:	8b 45 08             	mov    0x8(%ebp),%eax
801053b7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801053be:	8b 45 08             	mov    0x8(%ebp),%eax
801053c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801053c8:	00 
801053c9:	89 04 24             	mov    %eax,(%esp)
801053cc:	e8 10 ff ff ff       	call   801052e1 <xchg>

  popcli();
801053d1:	e8 e1 00 00 00       	call   801054b7 <popcli>
}
801053d6:	c9                   	leave  
801053d7:	c3                   	ret    

801053d8 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801053d8:	55                   	push   %ebp
801053d9:	89 e5                	mov    %esp,%ebp
801053db:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801053de:	8b 45 08             	mov    0x8(%ebp),%eax
801053e1:	83 e8 08             	sub    $0x8,%eax
801053e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053e7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801053ee:	eb 32                	jmp    80105422 <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801053f0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801053f4:	74 47                	je     8010543d <getcallerpcs+0x65>
801053f6:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801053fd:	76 3e                	jbe    8010543d <getcallerpcs+0x65>
801053ff:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105403:	74 38                	je     8010543d <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105405:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105408:	c1 e0 02             	shl    $0x2,%eax
8010540b:	03 45 0c             	add    0xc(%ebp),%eax
8010540e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105411:	8b 52 04             	mov    0x4(%edx),%edx
80105414:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
80105416:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105419:	8b 00                	mov    (%eax),%eax
8010541b:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010541e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105422:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105426:	7e c8                	jle    801053f0 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105428:	eb 13                	jmp    8010543d <getcallerpcs+0x65>
    pcs[i] = 0;
8010542a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010542d:	c1 e0 02             	shl    $0x2,%eax
80105430:	03 45 0c             	add    0xc(%ebp),%eax
80105433:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105439:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010543d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105441:	7e e7                	jle    8010542a <getcallerpcs+0x52>
    pcs[i] = 0;
}
80105443:	c9                   	leave  
80105444:	c3                   	ret    

80105445 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105445:	55                   	push   %ebp
80105446:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105448:	8b 45 08             	mov    0x8(%ebp),%eax
8010544b:	8b 00                	mov    (%eax),%eax
8010544d:	85 c0                	test   %eax,%eax
8010544f:	74 17                	je     80105468 <holding+0x23>
80105451:	8b 45 08             	mov    0x8(%ebp),%eax
80105454:	8b 50 08             	mov    0x8(%eax),%edx
80105457:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010545d:	39 c2                	cmp    %eax,%edx
8010545f:	75 07                	jne    80105468 <holding+0x23>
80105461:	b8 01 00 00 00       	mov    $0x1,%eax
80105466:	eb 05                	jmp    8010546d <holding+0x28>
80105468:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010546d:	5d                   	pop    %ebp
8010546e:	c3                   	ret    

8010546f <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010546f:	55                   	push   %ebp
80105470:	89 e5                	mov    %esp,%ebp
80105472:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105475:	e8 46 fe ff ff       	call   801052c0 <readeflags>
8010547a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010547d:	e8 53 fe ff ff       	call   801052d5 <cli>
  if(cpu->ncli++ == 0)
80105482:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105488:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010548e:	85 d2                	test   %edx,%edx
80105490:	0f 94 c1             	sete   %cl
80105493:	83 c2 01             	add    $0x1,%edx
80105496:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010549c:	84 c9                	test   %cl,%cl
8010549e:	74 15                	je     801054b5 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
801054a0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054a9:	81 e2 00 02 00 00    	and    $0x200,%edx
801054af:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801054b5:	c9                   	leave  
801054b6:	c3                   	ret    

801054b7 <popcli>:

void
popcli(void)
{
801054b7:	55                   	push   %ebp
801054b8:	89 e5                	mov    %esp,%ebp
801054ba:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801054bd:	e8 fe fd ff ff       	call   801052c0 <readeflags>
801054c2:	25 00 02 00 00       	and    $0x200,%eax
801054c7:	85 c0                	test   %eax,%eax
801054c9:	74 0c                	je     801054d7 <popcli+0x20>
    panic("popcli - interruptible");
801054cb:	c7 04 24 7c 8e 10 80 	movl   $0x80108e7c,(%esp)
801054d2:	e8 66 b0 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
801054d7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054dd:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801054e3:	83 ea 01             	sub    $0x1,%edx
801054e6:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801054ec:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801054f2:	85 c0                	test   %eax,%eax
801054f4:	79 0c                	jns    80105502 <popcli+0x4b>
    panic("popcli");
801054f6:	c7 04 24 93 8e 10 80 	movl   $0x80108e93,(%esp)
801054fd:	e8 3b b0 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105502:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105508:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010550e:	85 c0                	test   %eax,%eax
80105510:	75 15                	jne    80105527 <popcli+0x70>
80105512:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105518:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010551e:	85 c0                	test   %eax,%eax
80105520:	74 05                	je     80105527 <popcli+0x70>
    sti();
80105522:	e8 b4 fd ff ff       	call   801052db <sti>
}
80105527:	c9                   	leave  
80105528:	c3                   	ret    
80105529:	00 00                	add    %al,(%eax)
	...

8010552c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010552c:	55                   	push   %ebp
8010552d:	89 e5                	mov    %esp,%ebp
8010552f:	57                   	push   %edi
80105530:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105531:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105534:	8b 55 10             	mov    0x10(%ebp),%edx
80105537:	8b 45 0c             	mov    0xc(%ebp),%eax
8010553a:	89 cb                	mov    %ecx,%ebx
8010553c:	89 df                	mov    %ebx,%edi
8010553e:	89 d1                	mov    %edx,%ecx
80105540:	fc                   	cld    
80105541:	f3 aa                	rep stos %al,%es:(%edi)
80105543:	89 ca                	mov    %ecx,%edx
80105545:	89 fb                	mov    %edi,%ebx
80105547:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010554a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010554d:	5b                   	pop    %ebx
8010554e:	5f                   	pop    %edi
8010554f:	5d                   	pop    %ebp
80105550:	c3                   	ret    

80105551 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105551:	55                   	push   %ebp
80105552:	89 e5                	mov    %esp,%ebp
80105554:	57                   	push   %edi
80105555:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105556:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105559:	8b 55 10             	mov    0x10(%ebp),%edx
8010555c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010555f:	89 cb                	mov    %ecx,%ebx
80105561:	89 df                	mov    %ebx,%edi
80105563:	89 d1                	mov    %edx,%ecx
80105565:	fc                   	cld    
80105566:	f3 ab                	rep stos %eax,%es:(%edi)
80105568:	89 ca                	mov    %ecx,%edx
8010556a:	89 fb                	mov    %edi,%ebx
8010556c:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010556f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105572:	5b                   	pop    %ebx
80105573:	5f                   	pop    %edi
80105574:	5d                   	pop    %ebp
80105575:	c3                   	ret    

80105576 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105576:	55                   	push   %ebp
80105577:	89 e5                	mov    %esp,%ebp
80105579:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
8010557c:	8b 45 08             	mov    0x8(%ebp),%eax
8010557f:	83 e0 03             	and    $0x3,%eax
80105582:	85 c0                	test   %eax,%eax
80105584:	75 49                	jne    801055cf <memset+0x59>
80105586:	8b 45 10             	mov    0x10(%ebp),%eax
80105589:	83 e0 03             	and    $0x3,%eax
8010558c:	85 c0                	test   %eax,%eax
8010558e:	75 3f                	jne    801055cf <memset+0x59>
    c &= 0xFF;
80105590:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105597:	8b 45 10             	mov    0x10(%ebp),%eax
8010559a:	c1 e8 02             	shr    $0x2,%eax
8010559d:	89 c2                	mov    %eax,%edx
8010559f:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a2:	89 c1                	mov    %eax,%ecx
801055a4:	c1 e1 18             	shl    $0x18,%ecx
801055a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801055aa:	c1 e0 10             	shl    $0x10,%eax
801055ad:	09 c1                	or     %eax,%ecx
801055af:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b2:	c1 e0 08             	shl    $0x8,%eax
801055b5:	09 c8                	or     %ecx,%eax
801055b7:	0b 45 0c             	or     0xc(%ebp),%eax
801055ba:	89 54 24 08          	mov    %edx,0x8(%esp)
801055be:	89 44 24 04          	mov    %eax,0x4(%esp)
801055c2:	8b 45 08             	mov    0x8(%ebp),%eax
801055c5:	89 04 24             	mov    %eax,(%esp)
801055c8:	e8 84 ff ff ff       	call   80105551 <stosl>
801055cd:	eb 19                	jmp    801055e8 <memset+0x72>
  } else
    stosb(dst, c, n);
801055cf:	8b 45 10             	mov    0x10(%ebp),%eax
801055d2:	89 44 24 08          	mov    %eax,0x8(%esp)
801055d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801055dd:	8b 45 08             	mov    0x8(%ebp),%eax
801055e0:	89 04 24             	mov    %eax,(%esp)
801055e3:	e8 44 ff ff ff       	call   8010552c <stosb>
  return dst;
801055e8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801055eb:	c9                   	leave  
801055ec:	c3                   	ret    

801055ed <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801055ed:	55                   	push   %ebp
801055ee:	89 e5                	mov    %esp,%ebp
801055f0:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801055f3:	8b 45 08             	mov    0x8(%ebp),%eax
801055f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801055f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801055fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801055ff:	eb 32                	jmp    80105633 <memcmp+0x46>
    if(*s1 != *s2)
80105601:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105604:	0f b6 10             	movzbl (%eax),%edx
80105607:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010560a:	0f b6 00             	movzbl (%eax),%eax
8010560d:	38 c2                	cmp    %al,%dl
8010560f:	74 1a                	je     8010562b <memcmp+0x3e>
      return *s1 - *s2;
80105611:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105614:	0f b6 00             	movzbl (%eax),%eax
80105617:	0f b6 d0             	movzbl %al,%edx
8010561a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010561d:	0f b6 00             	movzbl (%eax),%eax
80105620:	0f b6 c0             	movzbl %al,%eax
80105623:	89 d1                	mov    %edx,%ecx
80105625:	29 c1                	sub    %eax,%ecx
80105627:	89 c8                	mov    %ecx,%eax
80105629:	eb 1c                	jmp    80105647 <memcmp+0x5a>
    s1++, s2++;
8010562b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010562f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105633:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105637:	0f 95 c0             	setne  %al
8010563a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010563e:	84 c0                	test   %al,%al
80105640:	75 bf                	jne    80105601 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105642:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105647:	c9                   	leave  
80105648:	c3                   	ret    

80105649 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105649:	55                   	push   %ebp
8010564a:	89 e5                	mov    %esp,%ebp
8010564c:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010564f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105652:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105655:	8b 45 08             	mov    0x8(%ebp),%eax
80105658:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010565b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010565e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105661:	73 54                	jae    801056b7 <memmove+0x6e>
80105663:	8b 45 10             	mov    0x10(%ebp),%eax
80105666:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105669:	01 d0                	add    %edx,%eax
8010566b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010566e:	76 47                	jbe    801056b7 <memmove+0x6e>
    s += n;
80105670:	8b 45 10             	mov    0x10(%ebp),%eax
80105673:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105676:	8b 45 10             	mov    0x10(%ebp),%eax
80105679:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010567c:	eb 13                	jmp    80105691 <memmove+0x48>
      *--d = *--s;
8010567e:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105682:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105686:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105689:	0f b6 10             	movzbl (%eax),%edx
8010568c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010568f:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105691:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105695:	0f 95 c0             	setne  %al
80105698:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010569c:	84 c0                	test   %al,%al
8010569e:	75 de                	jne    8010567e <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801056a0:	eb 25                	jmp    801056c7 <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801056a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056a5:	0f b6 10             	movzbl (%eax),%edx
801056a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056ab:	88 10                	mov    %dl,(%eax)
801056ad:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801056b1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056b5:	eb 01                	jmp    801056b8 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801056b7:	90                   	nop
801056b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056bc:	0f 95 c0             	setne  %al
801056bf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056c3:	84 c0                	test   %al,%al
801056c5:	75 db                	jne    801056a2 <memmove+0x59>
      *d++ = *s++;

  return dst;
801056c7:	8b 45 08             	mov    0x8(%ebp),%eax
}
801056ca:	c9                   	leave  
801056cb:	c3                   	ret    

801056cc <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801056cc:	55                   	push   %ebp
801056cd:	89 e5                	mov    %esp,%ebp
801056cf:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801056d2:	8b 45 10             	mov    0x10(%ebp),%eax
801056d5:	89 44 24 08          	mov    %eax,0x8(%esp)
801056d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801056dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801056e0:	8b 45 08             	mov    0x8(%ebp),%eax
801056e3:	89 04 24             	mov    %eax,(%esp)
801056e6:	e8 5e ff ff ff       	call   80105649 <memmove>
}
801056eb:	c9                   	leave  
801056ec:	c3                   	ret    

801056ed <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801056ed:	55                   	push   %ebp
801056ee:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801056f0:	eb 0c                	jmp    801056fe <strncmp+0x11>
    n--, p++, q++;
801056f2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056f6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801056fa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801056fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105702:	74 1a                	je     8010571e <strncmp+0x31>
80105704:	8b 45 08             	mov    0x8(%ebp),%eax
80105707:	0f b6 00             	movzbl (%eax),%eax
8010570a:	84 c0                	test   %al,%al
8010570c:	74 10                	je     8010571e <strncmp+0x31>
8010570e:	8b 45 08             	mov    0x8(%ebp),%eax
80105711:	0f b6 10             	movzbl (%eax),%edx
80105714:	8b 45 0c             	mov    0xc(%ebp),%eax
80105717:	0f b6 00             	movzbl (%eax),%eax
8010571a:	38 c2                	cmp    %al,%dl
8010571c:	74 d4                	je     801056f2 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010571e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105722:	75 07                	jne    8010572b <strncmp+0x3e>
    return 0;
80105724:	b8 00 00 00 00       	mov    $0x0,%eax
80105729:	eb 18                	jmp    80105743 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
8010572b:	8b 45 08             	mov    0x8(%ebp),%eax
8010572e:	0f b6 00             	movzbl (%eax),%eax
80105731:	0f b6 d0             	movzbl %al,%edx
80105734:	8b 45 0c             	mov    0xc(%ebp),%eax
80105737:	0f b6 00             	movzbl (%eax),%eax
8010573a:	0f b6 c0             	movzbl %al,%eax
8010573d:	89 d1                	mov    %edx,%ecx
8010573f:	29 c1                	sub    %eax,%ecx
80105741:	89 c8                	mov    %ecx,%eax
}
80105743:	5d                   	pop    %ebp
80105744:	c3                   	ret    

80105745 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105745:	55                   	push   %ebp
80105746:	89 e5                	mov    %esp,%ebp
80105748:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010574b:	8b 45 08             	mov    0x8(%ebp),%eax
8010574e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105751:	90                   	nop
80105752:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105756:	0f 9f c0             	setg   %al
80105759:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010575d:	84 c0                	test   %al,%al
8010575f:	74 30                	je     80105791 <strncpy+0x4c>
80105761:	8b 45 0c             	mov    0xc(%ebp),%eax
80105764:	0f b6 10             	movzbl (%eax),%edx
80105767:	8b 45 08             	mov    0x8(%ebp),%eax
8010576a:	88 10                	mov    %dl,(%eax)
8010576c:	8b 45 08             	mov    0x8(%ebp),%eax
8010576f:	0f b6 00             	movzbl (%eax),%eax
80105772:	84 c0                	test   %al,%al
80105774:	0f 95 c0             	setne  %al
80105777:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010577b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010577f:	84 c0                	test   %al,%al
80105781:	75 cf                	jne    80105752 <strncpy+0xd>
    ;
  while(n-- > 0)
80105783:	eb 0c                	jmp    80105791 <strncpy+0x4c>
    *s++ = 0;
80105785:	8b 45 08             	mov    0x8(%ebp),%eax
80105788:	c6 00 00             	movb   $0x0,(%eax)
8010578b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010578f:	eb 01                	jmp    80105792 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105791:	90                   	nop
80105792:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105796:	0f 9f c0             	setg   %al
80105799:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010579d:	84 c0                	test   %al,%al
8010579f:	75 e4                	jne    80105785 <strncpy+0x40>
    *s++ = 0;
  return os;
801057a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057a4:	c9                   	leave  
801057a5:	c3                   	ret    

801057a6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801057a6:	55                   	push   %ebp
801057a7:	89 e5                	mov    %esp,%ebp
801057a9:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801057ac:	8b 45 08             	mov    0x8(%ebp),%eax
801057af:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801057b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057b6:	7f 05                	jg     801057bd <safestrcpy+0x17>
    return os;
801057b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057bb:	eb 35                	jmp    801057f2 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801057bd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057c5:	7e 22                	jle    801057e9 <safestrcpy+0x43>
801057c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ca:	0f b6 10             	movzbl (%eax),%edx
801057cd:	8b 45 08             	mov    0x8(%ebp),%eax
801057d0:	88 10                	mov    %dl,(%eax)
801057d2:	8b 45 08             	mov    0x8(%ebp),%eax
801057d5:	0f b6 00             	movzbl (%eax),%eax
801057d8:	84 c0                	test   %al,%al
801057da:	0f 95 c0             	setne  %al
801057dd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801057e1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801057e5:	84 c0                	test   %al,%al
801057e7:	75 d4                	jne    801057bd <safestrcpy+0x17>
    ;
  *s = 0;
801057e9:	8b 45 08             	mov    0x8(%ebp),%eax
801057ec:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801057ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057f2:	c9                   	leave  
801057f3:	c3                   	ret    

801057f4 <strlen>:

int
strlen(const char *s)
{
801057f4:	55                   	push   %ebp
801057f5:	89 e5                	mov    %esp,%ebp
801057f7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801057fa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105801:	eb 04                	jmp    80105807 <strlen+0x13>
80105803:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105807:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010580a:	03 45 08             	add    0x8(%ebp),%eax
8010580d:	0f b6 00             	movzbl (%eax),%eax
80105810:	84 c0                	test   %al,%al
80105812:	75 ef                	jne    80105803 <strlen+0xf>
    ;
  return n;
80105814:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105817:	c9                   	leave  
80105818:	c3                   	ret    
80105819:	00 00                	add    %al,(%eax)
	...

8010581c <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010581c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105820:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105824:	55                   	push   %ebp
  pushl %ebx
80105825:	53                   	push   %ebx
  pushl %esi
80105826:	56                   	push   %esi
  pushl %edi
80105827:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105828:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010582a:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010582c:	5f                   	pop    %edi
  popl %esi
8010582d:	5e                   	pop    %esi
  popl %ebx
8010582e:	5b                   	pop    %ebx
  popl %ebp
8010582f:	5d                   	pop    %ebp
  ret
80105830:	c3                   	ret    
80105831:	00 00                	add    %al,(%eax)
	...

80105834 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105834:	55                   	push   %ebp
80105835:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105837:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010583d:	8b 00                	mov    (%eax),%eax
8010583f:	3b 45 08             	cmp    0x8(%ebp),%eax
80105842:	76 12                	jbe    80105856 <fetchint+0x22>
80105844:	8b 45 08             	mov    0x8(%ebp),%eax
80105847:	8d 50 04             	lea    0x4(%eax),%edx
8010584a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105850:	8b 00                	mov    (%eax),%eax
80105852:	39 c2                	cmp    %eax,%edx
80105854:	76 07                	jbe    8010585d <fetchint+0x29>
    return -1;
80105856:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010585b:	eb 0f                	jmp    8010586c <fetchint+0x38>
  *ip = *(int*)(addr);
8010585d:	8b 45 08             	mov    0x8(%ebp),%eax
80105860:	8b 10                	mov    (%eax),%edx
80105862:	8b 45 0c             	mov    0xc(%ebp),%eax
80105865:	89 10                	mov    %edx,(%eax)
  return 0;
80105867:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010586c:	5d                   	pop    %ebp
8010586d:	c3                   	ret    

8010586e <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010586e:	55                   	push   %ebp
8010586f:	89 e5                	mov    %esp,%ebp
80105871:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105874:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010587a:	8b 00                	mov    (%eax),%eax
8010587c:	3b 45 08             	cmp    0x8(%ebp),%eax
8010587f:	77 07                	ja     80105888 <fetchstr+0x1a>
    return -1;
80105881:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105886:	eb 48                	jmp    801058d0 <fetchstr+0x62>
  *pp = (char*)addr;
80105888:	8b 55 08             	mov    0x8(%ebp),%edx
8010588b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010588e:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105890:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105896:	8b 00                	mov    (%eax),%eax
80105898:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010589b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010589e:	8b 00                	mov    (%eax),%eax
801058a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
801058a3:	eb 1e                	jmp    801058c3 <fetchstr+0x55>
    if(*s == 0)
801058a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058a8:	0f b6 00             	movzbl (%eax),%eax
801058ab:	84 c0                	test   %al,%al
801058ad:	75 10                	jne    801058bf <fetchstr+0x51>
      return s - *pp;
801058af:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801058b5:	8b 00                	mov    (%eax),%eax
801058b7:	89 d1                	mov    %edx,%ecx
801058b9:	29 c1                	sub    %eax,%ecx
801058bb:	89 c8                	mov    %ecx,%eax
801058bd:	eb 11                	jmp    801058d0 <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801058bf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801058c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058c6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801058c9:	72 da                	jb     801058a5 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801058cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058d0:	c9                   	leave  
801058d1:	c3                   	ret    

801058d2 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801058d2:	55                   	push   %ebp
801058d3:	89 e5                	mov    %esp,%ebp
801058d5:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801058d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058de:	8b 40 18             	mov    0x18(%eax),%eax
801058e1:	8b 50 44             	mov    0x44(%eax),%edx
801058e4:	8b 45 08             	mov    0x8(%ebp),%eax
801058e7:	c1 e0 02             	shl    $0x2,%eax
801058ea:	01 d0                	add    %edx,%eax
801058ec:	8d 50 04             	lea    0x4(%eax),%edx
801058ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801058f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801058f6:	89 14 24             	mov    %edx,(%esp)
801058f9:	e8 36 ff ff ff       	call   80105834 <fetchint>
}
801058fe:	c9                   	leave  
801058ff:	c3                   	ret    

80105900 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105900:	55                   	push   %ebp
80105901:	89 e5                	mov    %esp,%ebp
80105903:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105906:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105909:	89 44 24 04          	mov    %eax,0x4(%esp)
8010590d:	8b 45 08             	mov    0x8(%ebp),%eax
80105910:	89 04 24             	mov    %eax,(%esp)
80105913:	e8 ba ff ff ff       	call   801058d2 <argint>
80105918:	85 c0                	test   %eax,%eax
8010591a:	79 07                	jns    80105923 <argptr+0x23>
    return -1;
8010591c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105921:	eb 3d                	jmp    80105960 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105923:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105926:	89 c2                	mov    %eax,%edx
80105928:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010592e:	8b 00                	mov    (%eax),%eax
80105930:	39 c2                	cmp    %eax,%edx
80105932:	73 16                	jae    8010594a <argptr+0x4a>
80105934:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105937:	89 c2                	mov    %eax,%edx
80105939:	8b 45 10             	mov    0x10(%ebp),%eax
8010593c:	01 c2                	add    %eax,%edx
8010593e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105944:	8b 00                	mov    (%eax),%eax
80105946:	39 c2                	cmp    %eax,%edx
80105948:	76 07                	jbe    80105951 <argptr+0x51>
    return -1;
8010594a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010594f:	eb 0f                	jmp    80105960 <argptr+0x60>
  *pp = (char*)i;
80105951:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105954:	89 c2                	mov    %eax,%edx
80105956:	8b 45 0c             	mov    0xc(%ebp),%eax
80105959:	89 10                	mov    %edx,(%eax)
  return 0;
8010595b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105960:	c9                   	leave  
80105961:	c3                   	ret    

80105962 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105962:	55                   	push   %ebp
80105963:	89 e5                	mov    %esp,%ebp
80105965:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105968:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010596b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010596f:	8b 45 08             	mov    0x8(%ebp),%eax
80105972:	89 04 24             	mov    %eax,(%esp)
80105975:	e8 58 ff ff ff       	call   801058d2 <argint>
8010597a:	85 c0                	test   %eax,%eax
8010597c:	79 07                	jns    80105985 <argstr+0x23>
    return -1;
8010597e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105983:	eb 12                	jmp    80105997 <argstr+0x35>
  return fetchstr(addr, pp);
80105985:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105988:	8b 55 0c             	mov    0xc(%ebp),%edx
8010598b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010598f:	89 04 24             	mov    %eax,(%esp)
80105992:	e8 d7 fe ff ff       	call   8010586e <fetchstr>
}
80105997:	c9                   	leave  
80105998:	c3                   	ret    

80105999 <syscall>:
[SYS_texit]   sys_texit,
};

void
syscall(void)
{
80105999:	55                   	push   %ebp
8010599a:	89 e5                	mov    %esp,%ebp
8010599c:	53                   	push   %ebx
8010599d:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
801059a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059a6:	8b 40 18             	mov    0x18(%eax),%eax
801059a9:	8b 40 1c             	mov    0x1c(%eax),%eax
801059ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801059af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059b3:	7e 30                	jle    801059e5 <syscall+0x4c>
801059b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b8:	83 f8 1b             	cmp    $0x1b,%eax
801059bb:	77 28                	ja     801059e5 <syscall+0x4c>
801059bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c0:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801059c7:	85 c0                	test   %eax,%eax
801059c9:	74 1a                	je     801059e5 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801059cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059d1:	8b 58 18             	mov    0x18(%eax),%ebx
801059d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d7:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801059de:	ff d0                	call   *%eax
801059e0:	89 43 1c             	mov    %eax,0x1c(%ebx)
801059e3:	eb 3d                	jmp    80105a22 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801059e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059eb:	8d 48 6c             	lea    0x6c(%eax),%ecx
801059ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801059f4:	8b 40 10             	mov    0x10(%eax),%eax
801059f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059fa:	89 54 24 0c          	mov    %edx,0xc(%esp)
801059fe:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a02:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a06:	c7 04 24 9a 8e 10 80 	movl   $0x80108e9a,(%esp)
80105a0d:	e8 8f a9 ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105a12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a18:	8b 40 18             	mov    0x18(%eax),%eax
80105a1b:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a22:	83 c4 24             	add    $0x24,%esp
80105a25:	5b                   	pop    %ebx
80105a26:	5d                   	pop    %ebp
80105a27:	c3                   	ret    

80105a28 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a28:	55                   	push   %ebp
80105a29:	89 e5                	mov    %esp,%ebp
80105a2b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a31:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a35:	8b 45 08             	mov    0x8(%ebp),%eax
80105a38:	89 04 24             	mov    %eax,(%esp)
80105a3b:	e8 92 fe ff ff       	call   801058d2 <argint>
80105a40:	85 c0                	test   %eax,%eax
80105a42:	79 07                	jns    80105a4b <argfd+0x23>
    return -1;
80105a44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a49:	eb 50                	jmp    80105a9b <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a4e:	85 c0                	test   %eax,%eax
80105a50:	78 21                	js     80105a73 <argfd+0x4b>
80105a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a55:	83 f8 0f             	cmp    $0xf,%eax
80105a58:	7f 19                	jg     80105a73 <argfd+0x4b>
80105a5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a60:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a63:	83 c2 08             	add    $0x8,%edx
80105a66:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a71:	75 07                	jne    80105a7a <argfd+0x52>
    return -1;
80105a73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a78:	eb 21                	jmp    80105a9b <argfd+0x73>
  if(pfd)
80105a7a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a7e:	74 08                	je     80105a88 <argfd+0x60>
    *pfd = fd;
80105a80:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a83:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a86:	89 10                	mov    %edx,(%eax)
  if(pf)
80105a88:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a8c:	74 08                	je     80105a96 <argfd+0x6e>
    *pf = f;
80105a8e:	8b 45 10             	mov    0x10(%ebp),%eax
80105a91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a94:	89 10                	mov    %edx,(%eax)
  return 0;
80105a96:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a9b:	c9                   	leave  
80105a9c:	c3                   	ret    

80105a9d <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105a9d:	55                   	push   %ebp
80105a9e:	89 e5                	mov    %esp,%ebp
80105aa0:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105aa3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105aaa:	eb 30                	jmp    80105adc <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105aac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ab2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ab5:	83 c2 08             	add    $0x8,%edx
80105ab8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105abc:	85 c0                	test   %eax,%eax
80105abe:	75 18                	jne    80105ad8 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105ac0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ac6:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ac9:	8d 4a 08             	lea    0x8(%edx),%ecx
80105acc:	8b 55 08             	mov    0x8(%ebp),%edx
80105acf:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105ad3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ad6:	eb 0f                	jmp    80105ae7 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105ad8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105adc:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105ae0:	7e ca                	jle    80105aac <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105ae2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ae7:	c9                   	leave  
80105ae8:	c3                   	ret    

80105ae9 <sys_dup>:

int
sys_dup(void)
{
80105ae9:	55                   	push   %ebp
80105aea:	89 e5                	mov    %esp,%ebp
80105aec:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105aef:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105af2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105af6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105afd:	00 
80105afe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b05:	e8 1e ff ff ff       	call   80105a28 <argfd>
80105b0a:	85 c0                	test   %eax,%eax
80105b0c:	79 07                	jns    80105b15 <sys_dup+0x2c>
    return -1;
80105b0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b13:	eb 29                	jmp    80105b3e <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b18:	89 04 24             	mov    %eax,(%esp)
80105b1b:	e8 7d ff ff ff       	call   80105a9d <fdalloc>
80105b20:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b27:	79 07                	jns    80105b30 <sys_dup+0x47>
    return -1;
80105b29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b2e:	eb 0e                	jmp    80105b3e <sys_dup+0x55>
  filedup(f);
80105b30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b33:	89 04 24             	mov    %eax,(%esp)
80105b36:	e8 4d b4 ff ff       	call   80100f88 <filedup>
  return fd;
80105b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b3e:	c9                   	leave  
80105b3f:	c3                   	ret    

80105b40 <sys_read>:

int
sys_read(void)
{
80105b40:	55                   	push   %ebp
80105b41:	89 e5                	mov    %esp,%ebp
80105b43:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b46:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b49:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b54:	00 
80105b55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b5c:	e8 c7 fe ff ff       	call   80105a28 <argfd>
80105b61:	85 c0                	test   %eax,%eax
80105b63:	78 35                	js     80105b9a <sys_read+0x5a>
80105b65:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b68:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b6c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105b73:	e8 5a fd ff ff       	call   801058d2 <argint>
80105b78:	85 c0                	test   %eax,%eax
80105b7a:	78 1e                	js     80105b9a <sys_read+0x5a>
80105b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b83:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b86:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b91:	e8 6a fd ff ff       	call   80105900 <argptr>
80105b96:	85 c0                	test   %eax,%eax
80105b98:	79 07                	jns    80105ba1 <sys_read+0x61>
    return -1;
80105b9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b9f:	eb 19                	jmp    80105bba <sys_read+0x7a>
  return fileread(f, p, n);
80105ba1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ba4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105baa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105bae:	89 54 24 04          	mov    %edx,0x4(%esp)
80105bb2:	89 04 24             	mov    %eax,(%esp)
80105bb5:	e8 3b b5 ff ff       	call   801010f5 <fileread>
}
80105bba:	c9                   	leave  
80105bbb:	c3                   	ret    

80105bbc <sys_write>:

int
sys_write(void)
{
80105bbc:	55                   	push   %ebp
80105bbd:	89 e5                	mov    %esp,%ebp
80105bbf:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105bc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bc5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bc9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105bd0:	00 
80105bd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bd8:	e8 4b fe ff ff       	call   80105a28 <argfd>
80105bdd:	85 c0                	test   %eax,%eax
80105bdf:	78 35                	js     80105c16 <sys_write+0x5a>
80105be1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105be4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105be8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105bef:	e8 de fc ff ff       	call   801058d2 <argint>
80105bf4:	85 c0                	test   %eax,%eax
80105bf6:	78 1e                	js     80105c16 <sys_write+0x5a>
80105bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bfb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bff:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c02:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c0d:	e8 ee fc ff ff       	call   80105900 <argptr>
80105c12:	85 c0                	test   %eax,%eax
80105c14:	79 07                	jns    80105c1d <sys_write+0x61>
    return -1;
80105c16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1b:	eb 19                	jmp    80105c36 <sys_write+0x7a>
  return filewrite(f, p, n);
80105c1d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c20:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c26:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105c2a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c2e:	89 04 24             	mov    %eax,(%esp)
80105c31:	e8 7b b5 ff ff       	call   801011b1 <filewrite>
}
80105c36:	c9                   	leave  
80105c37:	c3                   	ret    

80105c38 <sys_close>:

int
sys_close(void)
{
80105c38:	55                   	push   %ebp
80105c39:	89 e5                	mov    %esp,%ebp
80105c3b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105c3e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c41:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c45:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c48:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c53:	e8 d0 fd ff ff       	call   80105a28 <argfd>
80105c58:	85 c0                	test   %eax,%eax
80105c5a:	79 07                	jns    80105c63 <sys_close+0x2b>
    return -1;
80105c5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c61:	eb 24                	jmp    80105c87 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105c63:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c69:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c6c:	83 c2 08             	add    $0x8,%edx
80105c6f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c76:	00 
  fileclose(f);
80105c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7a:	89 04 24             	mov    %eax,(%esp)
80105c7d:	e8 4e b3 ff ff       	call   80100fd0 <fileclose>
  return 0;
80105c82:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c87:	c9                   	leave  
80105c88:	c3                   	ret    

80105c89 <sys_fstat>:

int
sys_fstat(void)
{
80105c89:	55                   	push   %ebp
80105c8a:	89 e5                	mov    %esp,%ebp
80105c8c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105c8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c92:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c96:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c9d:	00 
80105c9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ca5:	e8 7e fd ff ff       	call   80105a28 <argfd>
80105caa:	85 c0                	test   %eax,%eax
80105cac:	78 1f                	js     80105ccd <sys_fstat+0x44>
80105cae:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105cb5:	00 
80105cb6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cbd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105cc4:	e8 37 fc ff ff       	call   80105900 <argptr>
80105cc9:	85 c0                	test   %eax,%eax
80105ccb:	79 07                	jns    80105cd4 <sys_fstat+0x4b>
    return -1;
80105ccd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd2:	eb 12                	jmp    80105ce6 <sys_fstat+0x5d>
  return filestat(f, st);
80105cd4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cda:	89 54 24 04          	mov    %edx,0x4(%esp)
80105cde:	89 04 24             	mov    %eax,(%esp)
80105ce1:	e8 c0 b3 ff ff       	call   801010a6 <filestat>
}
80105ce6:	c9                   	leave  
80105ce7:	c3                   	ret    

80105ce8 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105ce8:	55                   	push   %ebp
80105ce9:	89 e5                	mov    %esp,%ebp
80105ceb:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105cee:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105cf1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cf5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105cfc:	e8 61 fc ff ff       	call   80105962 <argstr>
80105d01:	85 c0                	test   %eax,%eax
80105d03:	78 17                	js     80105d1c <sys_link+0x34>
80105d05:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105d08:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d0c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d13:	e8 4a fc ff ff       	call   80105962 <argstr>
80105d18:	85 c0                	test   %eax,%eax
80105d1a:	79 0a                	jns    80105d26 <sys_link+0x3e>
    return -1;
80105d1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d21:	e9 41 01 00 00       	jmp    80105e67 <sys_link+0x17f>

  begin_op();
80105d26:	e8 36 d7 ff ff       	call   80103461 <begin_op>
  if((ip = namei(old)) == 0){
80105d2b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d2e:	89 04 24             	mov    %eax,(%esp)
80105d31:	e8 e0 c6 ff ff       	call   80102416 <namei>
80105d36:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d3d:	75 0f                	jne    80105d4e <sys_link+0x66>
    end_op();
80105d3f:	e8 9e d7 ff ff       	call   801034e2 <end_op>
    return -1;
80105d44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d49:	e9 19 01 00 00       	jmp    80105e67 <sys_link+0x17f>
  }

  ilock(ip);
80105d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d51:	89 04 24             	mov    %eax,(%esp)
80105d54:	e8 1b bb ff ff       	call   80101874 <ilock>
  if(ip->type == T_DIR){
80105d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d5c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d60:	66 83 f8 01          	cmp    $0x1,%ax
80105d64:	75 1a                	jne    80105d80 <sys_link+0x98>
    iunlockput(ip);
80105d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d69:	89 04 24             	mov    %eax,(%esp)
80105d6c:	e8 87 bd ff ff       	call   80101af8 <iunlockput>
    end_op();
80105d71:	e8 6c d7 ff ff       	call   801034e2 <end_op>
    return -1;
80105d76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d7b:	e9 e7 00 00 00       	jmp    80105e67 <sys_link+0x17f>
  }

  ip->nlink++;
80105d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d83:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d87:	8d 50 01             	lea    0x1(%eax),%edx
80105d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d8d:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d94:	89 04 24             	mov    %eax,(%esp)
80105d97:	e8 1c b9 ff ff       	call   801016b8 <iupdate>
  iunlock(ip);
80105d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9f:	89 04 24             	mov    %eax,(%esp)
80105da2:	e8 1b bc ff ff       	call   801019c2 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105da7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105daa:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105dad:	89 54 24 04          	mov    %edx,0x4(%esp)
80105db1:	89 04 24             	mov    %eax,(%esp)
80105db4:	e8 7f c6 ff ff       	call   80102438 <nameiparent>
80105db9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105dbc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dc0:	74 68                	je     80105e2a <sys_link+0x142>
    goto bad;
  ilock(dp);
80105dc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc5:	89 04 24             	mov    %eax,(%esp)
80105dc8:	e8 a7 ba ff ff       	call   80101874 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd0:	8b 10                	mov    (%eax),%edx
80105dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd5:	8b 00                	mov    (%eax),%eax
80105dd7:	39 c2                	cmp    %eax,%edx
80105dd9:	75 20                	jne    80105dfb <sys_link+0x113>
80105ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dde:	8b 40 04             	mov    0x4(%eax),%eax
80105de1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105de5:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105de8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105def:	89 04 24             	mov    %eax,(%esp)
80105df2:	e8 5e c3 ff ff       	call   80102155 <dirlink>
80105df7:	85 c0                	test   %eax,%eax
80105df9:	79 0d                	jns    80105e08 <sys_link+0x120>
    iunlockput(dp);
80105dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dfe:	89 04 24             	mov    %eax,(%esp)
80105e01:	e8 f2 bc ff ff       	call   80101af8 <iunlockput>
    goto bad;
80105e06:	eb 23                	jmp    80105e2b <sys_link+0x143>
  }
  iunlockput(dp);
80105e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e0b:	89 04 24             	mov    %eax,(%esp)
80105e0e:	e8 e5 bc ff ff       	call   80101af8 <iunlockput>
  iput(ip);
80105e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e16:	89 04 24             	mov    %eax,(%esp)
80105e19:	e8 09 bc ff ff       	call   80101a27 <iput>

  end_op();
80105e1e:	e8 bf d6 ff ff       	call   801034e2 <end_op>

  return 0;
80105e23:	b8 00 00 00 00       	mov    $0x0,%eax
80105e28:	eb 3d                	jmp    80105e67 <sys_link+0x17f>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105e2a:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2e:	89 04 24             	mov    %eax,(%esp)
80105e31:	e8 3e ba ff ff       	call   80101874 <ilock>
  ip->nlink--;
80105e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e39:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e3d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e43:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4a:	89 04 24             	mov    %eax,(%esp)
80105e4d:	e8 66 b8 ff ff       	call   801016b8 <iupdate>
  iunlockput(ip);
80105e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e55:	89 04 24             	mov    %eax,(%esp)
80105e58:	e8 9b bc ff ff       	call   80101af8 <iunlockput>
  end_op();
80105e5d:	e8 80 d6 ff ff       	call   801034e2 <end_op>
  return -1;
80105e62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e67:	c9                   	leave  
80105e68:	c3                   	ret    

80105e69 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105e69:	55                   	push   %ebp
80105e6a:	89 e5                	mov    %esp,%ebp
80105e6c:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e6f:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105e76:	eb 4b                	jmp    80105ec3 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105e82:	00 
80105e83:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e87:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80105e91:	89 04 24             	mov    %eax,(%esp)
80105e94:	e8 d1 be ff ff       	call   80101d6a <readi>
80105e99:	83 f8 10             	cmp    $0x10,%eax
80105e9c:	74 0c                	je     80105eaa <isdirempty+0x41>
      panic("isdirempty: readi");
80105e9e:	c7 04 24 b6 8e 10 80 	movl   $0x80108eb6,(%esp)
80105ea5:	e8 93 a6 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105eaa:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105eae:	66 85 c0             	test   %ax,%ax
80105eb1:	74 07                	je     80105eba <isdirempty+0x51>
      return 0;
80105eb3:	b8 00 00 00 00       	mov    $0x0,%eax
80105eb8:	eb 1b                	jmp    80105ed5 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ebd:	83 c0 10             	add    $0x10,%eax
80105ec0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ec3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ec9:	8b 40 18             	mov    0x18(%eax),%eax
80105ecc:	39 c2                	cmp    %eax,%edx
80105ece:	72 a8                	jb     80105e78 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105ed0:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105ed5:	c9                   	leave  
80105ed6:	c3                   	ret    

80105ed7 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105ed7:	55                   	push   %ebp
80105ed8:	89 e5                	mov    %esp,%ebp
80105eda:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105edd:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105ee0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ee4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105eeb:	e8 72 fa ff ff       	call   80105962 <argstr>
80105ef0:	85 c0                	test   %eax,%eax
80105ef2:	79 0a                	jns    80105efe <sys_unlink+0x27>
    return -1;
80105ef4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef9:	e9 af 01 00 00       	jmp    801060ad <sys_unlink+0x1d6>

  begin_op();
80105efe:	e8 5e d5 ff ff       	call   80103461 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105f03:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f06:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f09:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f0d:	89 04 24             	mov    %eax,(%esp)
80105f10:	e8 23 c5 ff ff       	call   80102438 <nameiparent>
80105f15:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f18:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f1c:	75 0f                	jne    80105f2d <sys_unlink+0x56>
    end_op();
80105f1e:	e8 bf d5 ff ff       	call   801034e2 <end_op>
    return -1;
80105f23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f28:	e9 80 01 00 00       	jmp    801060ad <sys_unlink+0x1d6>
  }

  ilock(dp);
80105f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f30:	89 04 24             	mov    %eax,(%esp)
80105f33:	e8 3c b9 ff ff       	call   80101874 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f38:	c7 44 24 04 c8 8e 10 	movl   $0x80108ec8,0x4(%esp)
80105f3f:	80 
80105f40:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f43:	89 04 24             	mov    %eax,(%esp)
80105f46:	e8 20 c1 ff ff       	call   8010206b <namecmp>
80105f4b:	85 c0                	test   %eax,%eax
80105f4d:	0f 84 45 01 00 00    	je     80106098 <sys_unlink+0x1c1>
80105f53:	c7 44 24 04 ca 8e 10 	movl   $0x80108eca,0x4(%esp)
80105f5a:	80 
80105f5b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f5e:	89 04 24             	mov    %eax,(%esp)
80105f61:	e8 05 c1 ff ff       	call   8010206b <namecmp>
80105f66:	85 c0                	test   %eax,%eax
80105f68:	0f 84 2a 01 00 00    	je     80106098 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105f6e:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105f71:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f75:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f78:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f7f:	89 04 24             	mov    %eax,(%esp)
80105f82:	e8 06 c1 ff ff       	call   8010208d <dirlookup>
80105f87:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f8a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f8e:	0f 84 03 01 00 00    	je     80106097 <sys_unlink+0x1c0>
    goto bad;
  ilock(ip);
80105f94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f97:	89 04 24             	mov    %eax,(%esp)
80105f9a:	e8 d5 b8 ff ff       	call   80101874 <ilock>

  if(ip->nlink < 1)
80105f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105fa6:	66 85 c0             	test   %ax,%ax
80105fa9:	7f 0c                	jg     80105fb7 <sys_unlink+0xe0>
    panic("unlink: nlink < 1");
80105fab:	c7 04 24 cd 8e 10 80 	movl   $0x80108ecd,(%esp)
80105fb2:	e8 86 a5 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fba:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105fbe:	66 83 f8 01          	cmp    $0x1,%ax
80105fc2:	75 1f                	jne    80105fe3 <sys_unlink+0x10c>
80105fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc7:	89 04 24             	mov    %eax,(%esp)
80105fca:	e8 9a fe ff ff       	call   80105e69 <isdirempty>
80105fcf:	85 c0                	test   %eax,%eax
80105fd1:	75 10                	jne    80105fe3 <sys_unlink+0x10c>
    iunlockput(ip);
80105fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd6:	89 04 24             	mov    %eax,(%esp)
80105fd9:	e8 1a bb ff ff       	call   80101af8 <iunlockput>
    goto bad;
80105fde:	e9 b5 00 00 00       	jmp    80106098 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105fe3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105fea:	00 
80105feb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ff2:	00 
80105ff3:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ff6:	89 04 24             	mov    %eax,(%esp)
80105ff9:	e8 78 f5 ff ff       	call   80105576 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ffe:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106001:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106008:	00 
80106009:	89 44 24 08          	mov    %eax,0x8(%esp)
8010600d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106010:	89 44 24 04          	mov    %eax,0x4(%esp)
80106014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106017:	89 04 24             	mov    %eax,(%esp)
8010601a:	e8 b6 be ff ff       	call   80101ed5 <writei>
8010601f:	83 f8 10             	cmp    $0x10,%eax
80106022:	74 0c                	je     80106030 <sys_unlink+0x159>
    panic("unlink: writei");
80106024:	c7 04 24 df 8e 10 80 	movl   $0x80108edf,(%esp)
8010602b:	e8 0d a5 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80106030:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106033:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106037:	66 83 f8 01          	cmp    $0x1,%ax
8010603b:	75 1c                	jne    80106059 <sys_unlink+0x182>
    dp->nlink--;
8010603d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106040:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106044:	8d 50 ff             	lea    -0x1(%eax),%edx
80106047:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010604a:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010604e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106051:	89 04 24             	mov    %eax,(%esp)
80106054:	e8 5f b6 ff ff       	call   801016b8 <iupdate>
  }
  iunlockput(dp);
80106059:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010605c:	89 04 24             	mov    %eax,(%esp)
8010605f:	e8 94 ba ff ff       	call   80101af8 <iunlockput>

  ip->nlink--;
80106064:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106067:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010606b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010606e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106071:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106075:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106078:	89 04 24             	mov    %eax,(%esp)
8010607b:	e8 38 b6 ff ff       	call   801016b8 <iupdate>
  iunlockput(ip);
80106080:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106083:	89 04 24             	mov    %eax,(%esp)
80106086:	e8 6d ba ff ff       	call   80101af8 <iunlockput>

  end_op();
8010608b:	e8 52 d4 ff ff       	call   801034e2 <end_op>

  return 0;
80106090:	b8 00 00 00 00       	mov    $0x0,%eax
80106095:	eb 16                	jmp    801060ad <sys_unlink+0x1d6>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106097:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80106098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609b:	89 04 24             	mov    %eax,(%esp)
8010609e:	e8 55 ba ff ff       	call   80101af8 <iunlockput>
  end_op();
801060a3:	e8 3a d4 ff ff       	call   801034e2 <end_op>
  return -1;
801060a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060ad:	c9                   	leave  
801060ae:	c3                   	ret    

801060af <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801060af:	55                   	push   %ebp
801060b0:	89 e5                	mov    %esp,%ebp
801060b2:	83 ec 48             	sub    $0x48,%esp
801060b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801060b8:	8b 55 10             	mov    0x10(%ebp),%edx
801060bb:	8b 45 14             	mov    0x14(%ebp),%eax
801060be:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801060c2:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801060c6:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801060ca:	8d 45 de             	lea    -0x22(%ebp),%eax
801060cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801060d1:	8b 45 08             	mov    0x8(%ebp),%eax
801060d4:	89 04 24             	mov    %eax,(%esp)
801060d7:	e8 5c c3 ff ff       	call   80102438 <nameiparent>
801060dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060e3:	75 0a                	jne    801060ef <create+0x40>
    return 0;
801060e5:	b8 00 00 00 00       	mov    $0x0,%eax
801060ea:	e9 7e 01 00 00       	jmp    8010626d <create+0x1be>
  ilock(dp);
801060ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f2:	89 04 24             	mov    %eax,(%esp)
801060f5:	e8 7a b7 ff ff       	call   80101874 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801060fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
801060fd:	89 44 24 08          	mov    %eax,0x8(%esp)
80106101:	8d 45 de             	lea    -0x22(%ebp),%eax
80106104:	89 44 24 04          	mov    %eax,0x4(%esp)
80106108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010610b:	89 04 24             	mov    %eax,(%esp)
8010610e:	e8 7a bf ff ff       	call   8010208d <dirlookup>
80106113:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106116:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010611a:	74 47                	je     80106163 <create+0xb4>
    iunlockput(dp);
8010611c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010611f:	89 04 24             	mov    %eax,(%esp)
80106122:	e8 d1 b9 ff ff       	call   80101af8 <iunlockput>
    ilock(ip);
80106127:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010612a:	89 04 24             	mov    %eax,(%esp)
8010612d:	e8 42 b7 ff ff       	call   80101874 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80106132:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106137:	75 15                	jne    8010614e <create+0x9f>
80106139:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010613c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106140:	66 83 f8 02          	cmp    $0x2,%ax
80106144:	75 08                	jne    8010614e <create+0x9f>
      return ip;
80106146:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106149:	e9 1f 01 00 00       	jmp    8010626d <create+0x1be>
    iunlockput(ip);
8010614e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106151:	89 04 24             	mov    %eax,(%esp)
80106154:	e8 9f b9 ff ff       	call   80101af8 <iunlockput>
    return 0;
80106159:	b8 00 00 00 00       	mov    $0x0,%eax
8010615e:	e9 0a 01 00 00       	jmp    8010626d <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106163:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106167:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010616a:	8b 00                	mov    (%eax),%eax
8010616c:	89 54 24 04          	mov    %edx,0x4(%esp)
80106170:	89 04 24             	mov    %eax,(%esp)
80106173:	e8 63 b4 ff ff       	call   801015db <ialloc>
80106178:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010617b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010617f:	75 0c                	jne    8010618d <create+0xde>
    panic("create: ialloc");
80106181:	c7 04 24 ee 8e 10 80 	movl   $0x80108eee,(%esp)
80106188:	e8 b0 a3 ff ff       	call   8010053d <panic>

  ilock(ip);
8010618d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106190:	89 04 24             	mov    %eax,(%esp)
80106193:	e8 dc b6 ff ff       	call   80101874 <ilock>
  ip->major = major;
80106198:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010619b:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010619f:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801061a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a6:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801061aa:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801061ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b1:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801061b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ba:	89 04 24             	mov    %eax,(%esp)
801061bd:	e8 f6 b4 ff ff       	call   801016b8 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
801061c2:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801061c7:	75 6a                	jne    80106233 <create+0x184>
    dp->nlink++;  // for ".."
801061c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061cc:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801061d0:	8d 50 01             	lea    0x1(%eax),%edx
801061d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d6:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801061da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061dd:	89 04 24             	mov    %eax,(%esp)
801061e0:	e8 d3 b4 ff ff       	call   801016b8 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801061e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e8:	8b 40 04             	mov    0x4(%eax),%eax
801061eb:	89 44 24 08          	mov    %eax,0x8(%esp)
801061ef:	c7 44 24 04 c8 8e 10 	movl   $0x80108ec8,0x4(%esp)
801061f6:	80 
801061f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061fa:	89 04 24             	mov    %eax,(%esp)
801061fd:	e8 53 bf ff ff       	call   80102155 <dirlink>
80106202:	85 c0                	test   %eax,%eax
80106204:	78 21                	js     80106227 <create+0x178>
80106206:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106209:	8b 40 04             	mov    0x4(%eax),%eax
8010620c:	89 44 24 08          	mov    %eax,0x8(%esp)
80106210:	c7 44 24 04 ca 8e 10 	movl   $0x80108eca,0x4(%esp)
80106217:	80 
80106218:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010621b:	89 04 24             	mov    %eax,(%esp)
8010621e:	e8 32 bf ff ff       	call   80102155 <dirlink>
80106223:	85 c0                	test   %eax,%eax
80106225:	79 0c                	jns    80106233 <create+0x184>
      panic("create dots");
80106227:	c7 04 24 fd 8e 10 80 	movl   $0x80108efd,(%esp)
8010622e:	e8 0a a3 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106233:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106236:	8b 40 04             	mov    0x4(%eax),%eax
80106239:	89 44 24 08          	mov    %eax,0x8(%esp)
8010623d:	8d 45 de             	lea    -0x22(%ebp),%eax
80106240:	89 44 24 04          	mov    %eax,0x4(%esp)
80106244:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106247:	89 04 24             	mov    %eax,(%esp)
8010624a:	e8 06 bf ff ff       	call   80102155 <dirlink>
8010624f:	85 c0                	test   %eax,%eax
80106251:	79 0c                	jns    8010625f <create+0x1b0>
    panic("create: dirlink");
80106253:	c7 04 24 09 8f 10 80 	movl   $0x80108f09,(%esp)
8010625a:	e8 de a2 ff ff       	call   8010053d <panic>

  iunlockput(dp);
8010625f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106262:	89 04 24             	mov    %eax,(%esp)
80106265:	e8 8e b8 ff ff       	call   80101af8 <iunlockput>

  return ip;
8010626a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010626d:	c9                   	leave  
8010626e:	c3                   	ret    

8010626f <sys_open>:

int
sys_open(void)
{
8010626f:	55                   	push   %ebp
80106270:	89 e5                	mov    %esp,%ebp
80106272:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106275:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106278:	89 44 24 04          	mov    %eax,0x4(%esp)
8010627c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106283:	e8 da f6 ff ff       	call   80105962 <argstr>
80106288:	85 c0                	test   %eax,%eax
8010628a:	78 17                	js     801062a3 <sys_open+0x34>
8010628c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010628f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106293:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010629a:	e8 33 f6 ff ff       	call   801058d2 <argint>
8010629f:	85 c0                	test   %eax,%eax
801062a1:	79 0a                	jns    801062ad <sys_open+0x3e>
    return -1;
801062a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a8:	e9 5a 01 00 00       	jmp    80106407 <sys_open+0x198>

  begin_op();
801062ad:	e8 af d1 ff ff       	call   80103461 <begin_op>

  if(omode & O_CREATE){
801062b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062b5:	25 00 02 00 00       	and    $0x200,%eax
801062ba:	85 c0                	test   %eax,%eax
801062bc:	74 3b                	je     801062f9 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
801062be:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062c1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801062c8:	00 
801062c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801062d0:	00 
801062d1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801062d8:	00 
801062d9:	89 04 24             	mov    %eax,(%esp)
801062dc:	e8 ce fd ff ff       	call   801060af <create>
801062e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801062e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062e8:	75 6b                	jne    80106355 <sys_open+0xe6>
      end_op();
801062ea:	e8 f3 d1 ff ff       	call   801034e2 <end_op>
      return -1;
801062ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f4:	e9 0e 01 00 00       	jmp    80106407 <sys_open+0x198>
    }
  } else {
    if((ip = namei(path)) == 0){
801062f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062fc:	89 04 24             	mov    %eax,(%esp)
801062ff:	e8 12 c1 ff ff       	call   80102416 <namei>
80106304:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106307:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010630b:	75 0f                	jne    8010631c <sys_open+0xad>
      end_op();
8010630d:	e8 d0 d1 ff ff       	call   801034e2 <end_op>
      return -1;
80106312:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106317:	e9 eb 00 00 00       	jmp    80106407 <sys_open+0x198>
    }
    ilock(ip);
8010631c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631f:	89 04 24             	mov    %eax,(%esp)
80106322:	e8 4d b5 ff ff       	call   80101874 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106327:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010632e:	66 83 f8 01          	cmp    $0x1,%ax
80106332:	75 21                	jne    80106355 <sys_open+0xe6>
80106334:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106337:	85 c0                	test   %eax,%eax
80106339:	74 1a                	je     80106355 <sys_open+0xe6>
      iunlockput(ip);
8010633b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633e:	89 04 24             	mov    %eax,(%esp)
80106341:	e8 b2 b7 ff ff       	call   80101af8 <iunlockput>
      end_op();
80106346:	e8 97 d1 ff ff       	call   801034e2 <end_op>
      return -1;
8010634b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106350:	e9 b2 00 00 00       	jmp    80106407 <sys_open+0x198>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106355:	e8 ce ab ff ff       	call   80100f28 <filealloc>
8010635a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010635d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106361:	74 14                	je     80106377 <sys_open+0x108>
80106363:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106366:	89 04 24             	mov    %eax,(%esp)
80106369:	e8 2f f7 ff ff       	call   80105a9d <fdalloc>
8010636e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106371:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106375:	79 28                	jns    8010639f <sys_open+0x130>
    if(f)
80106377:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010637b:	74 0b                	je     80106388 <sys_open+0x119>
      fileclose(f);
8010637d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106380:	89 04 24             	mov    %eax,(%esp)
80106383:	e8 48 ac ff ff       	call   80100fd0 <fileclose>
    iunlockput(ip);
80106388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010638b:	89 04 24             	mov    %eax,(%esp)
8010638e:	e8 65 b7 ff ff       	call   80101af8 <iunlockput>
    end_op();
80106393:	e8 4a d1 ff ff       	call   801034e2 <end_op>
    return -1;
80106398:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010639d:	eb 68                	jmp    80106407 <sys_open+0x198>
  }
  iunlock(ip);
8010639f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a2:	89 04 24             	mov    %eax,(%esp)
801063a5:	e8 18 b6 ff ff       	call   801019c2 <iunlock>
  end_op();
801063aa:	e8 33 d1 ff ff       	call   801034e2 <end_op>

  f->type = FD_INODE;
801063af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b2:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801063b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063be:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801063c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801063cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063ce:	83 e0 01             	and    $0x1,%eax
801063d1:	85 c0                	test   %eax,%eax
801063d3:	0f 94 c2             	sete   %dl
801063d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d9:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801063dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063df:	83 e0 01             	and    $0x1,%eax
801063e2:	84 c0                	test   %al,%al
801063e4:	75 0a                	jne    801063f0 <sys_open+0x181>
801063e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063e9:	83 e0 02             	and    $0x2,%eax
801063ec:	85 c0                	test   %eax,%eax
801063ee:	74 07                	je     801063f7 <sys_open+0x188>
801063f0:	b8 01 00 00 00       	mov    $0x1,%eax
801063f5:	eb 05                	jmp    801063fc <sys_open+0x18d>
801063f7:	b8 00 00 00 00       	mov    $0x0,%eax
801063fc:	89 c2                	mov    %eax,%edx
801063fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106401:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106404:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106407:	c9                   	leave  
80106408:	c3                   	ret    

80106409 <sys_mkdir>:

int
sys_mkdir(void)
{
80106409:	55                   	push   %ebp
8010640a:	89 e5                	mov    %esp,%ebp
8010640c:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010640f:	e8 4d d0 ff ff       	call   80103461 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106414:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106417:	89 44 24 04          	mov    %eax,0x4(%esp)
8010641b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106422:	e8 3b f5 ff ff       	call   80105962 <argstr>
80106427:	85 c0                	test   %eax,%eax
80106429:	78 2c                	js     80106457 <sys_mkdir+0x4e>
8010642b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106435:	00 
80106436:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010643d:	00 
8010643e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106445:	00 
80106446:	89 04 24             	mov    %eax,(%esp)
80106449:	e8 61 fc ff ff       	call   801060af <create>
8010644e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106451:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106455:	75 0c                	jne    80106463 <sys_mkdir+0x5a>
    end_op();
80106457:	e8 86 d0 ff ff       	call   801034e2 <end_op>
    return -1;
8010645c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106461:	eb 15                	jmp    80106478 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106463:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106466:	89 04 24             	mov    %eax,(%esp)
80106469:	e8 8a b6 ff ff       	call   80101af8 <iunlockput>
  end_op();
8010646e:	e8 6f d0 ff ff       	call   801034e2 <end_op>
  return 0;
80106473:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106478:	c9                   	leave  
80106479:	c3                   	ret    

8010647a <sys_mknod>:

int
sys_mknod(void)
{
8010647a:	55                   	push   %ebp
8010647b:	89 e5                	mov    %esp,%ebp
8010647d:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106480:	e8 dc cf ff ff       	call   80103461 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106485:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106488:	89 44 24 04          	mov    %eax,0x4(%esp)
8010648c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106493:	e8 ca f4 ff ff       	call   80105962 <argstr>
80106498:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010649b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010649f:	78 5e                	js     801064ff <sys_mknod+0x85>
     argint(1, &major) < 0 ||
801064a1:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801064a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801064af:	e8 1e f4 ff ff       	call   801058d2 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801064b4:	85 c0                	test   %eax,%eax
801064b6:	78 47                	js     801064ff <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801064b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801064bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801064bf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801064c6:	e8 07 f4 ff ff       	call   801058d2 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801064cb:	85 c0                	test   %eax,%eax
801064cd:	78 30                	js     801064ff <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801064cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064d2:	0f bf c8             	movswl %ax,%ecx
801064d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064d8:	0f bf d0             	movswl %ax,%edx
801064db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801064de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801064e2:	89 54 24 08          	mov    %edx,0x8(%esp)
801064e6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801064ed:	00 
801064ee:	89 04 24             	mov    %eax,(%esp)
801064f1:	e8 b9 fb ff ff       	call   801060af <create>
801064f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064fd:	75 0c                	jne    8010650b <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801064ff:	e8 de cf ff ff       	call   801034e2 <end_op>
    return -1;
80106504:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106509:	eb 15                	jmp    80106520 <sys_mknod+0xa6>
  }
  iunlockput(ip);
8010650b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010650e:	89 04 24             	mov    %eax,(%esp)
80106511:	e8 e2 b5 ff ff       	call   80101af8 <iunlockput>
  end_op();
80106516:	e8 c7 cf ff ff       	call   801034e2 <end_op>
  return 0;
8010651b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106520:	c9                   	leave  
80106521:	c3                   	ret    

80106522 <sys_chdir>:

int
sys_chdir(void)
{
80106522:	55                   	push   %ebp
80106523:	89 e5                	mov    %esp,%ebp
80106525:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106528:	e8 34 cf ff ff       	call   80103461 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010652d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106530:	89 44 24 04          	mov    %eax,0x4(%esp)
80106534:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010653b:	e8 22 f4 ff ff       	call   80105962 <argstr>
80106540:	85 c0                	test   %eax,%eax
80106542:	78 14                	js     80106558 <sys_chdir+0x36>
80106544:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106547:	89 04 24             	mov    %eax,(%esp)
8010654a:	e8 c7 be ff ff       	call   80102416 <namei>
8010654f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106552:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106556:	75 0c                	jne    80106564 <sys_chdir+0x42>
    end_op();
80106558:	e8 85 cf ff ff       	call   801034e2 <end_op>
    return -1;
8010655d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106562:	eb 61                	jmp    801065c5 <sys_chdir+0xa3>
  }
  ilock(ip);
80106564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106567:	89 04 24             	mov    %eax,(%esp)
8010656a:	e8 05 b3 ff ff       	call   80101874 <ilock>
  if(ip->type != T_DIR){
8010656f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106572:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106576:	66 83 f8 01          	cmp    $0x1,%ax
8010657a:	74 17                	je     80106593 <sys_chdir+0x71>
    iunlockput(ip);
8010657c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657f:	89 04 24             	mov    %eax,(%esp)
80106582:	e8 71 b5 ff ff       	call   80101af8 <iunlockput>
    end_op();
80106587:	e8 56 cf ff ff       	call   801034e2 <end_op>
    return -1;
8010658c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106591:	eb 32                	jmp    801065c5 <sys_chdir+0xa3>
  }
  iunlock(ip);
80106593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106596:	89 04 24             	mov    %eax,(%esp)
80106599:	e8 24 b4 ff ff       	call   801019c2 <iunlock>
  iput(proc->cwd);
8010659e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065a4:	8b 40 68             	mov    0x68(%eax),%eax
801065a7:	89 04 24             	mov    %eax,(%esp)
801065aa:	e8 78 b4 ff ff       	call   80101a27 <iput>
  end_op();
801065af:	e8 2e cf ff ff       	call   801034e2 <end_op>
  proc->cwd = ip;
801065b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065bd:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801065c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065c5:	c9                   	leave  
801065c6:	c3                   	ret    

801065c7 <sys_exec>:

int
sys_exec(void)
{
801065c7:	55                   	push   %ebp
801065c8:	89 e5                	mov    %esp,%ebp
801065ca:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801065d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801065d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065de:	e8 7f f3 ff ff       	call   80105962 <argstr>
801065e3:	85 c0                	test   %eax,%eax
801065e5:	78 1a                	js     80106601 <sys_exec+0x3a>
801065e7:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801065ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801065f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801065f8:	e8 d5 f2 ff ff       	call   801058d2 <argint>
801065fd:	85 c0                	test   %eax,%eax
801065ff:	79 0a                	jns    8010660b <sys_exec+0x44>
    return -1;
80106601:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106606:	e9 cc 00 00 00       	jmp    801066d7 <sys_exec+0x110>
  }
  memset(argv, 0, sizeof(argv));
8010660b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106612:	00 
80106613:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010661a:	00 
8010661b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106621:	89 04 24             	mov    %eax,(%esp)
80106624:	e8 4d ef ff ff       	call   80105576 <memset>
  for(i=0;; i++){
80106629:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106633:	83 f8 1f             	cmp    $0x1f,%eax
80106636:	76 0a                	jbe    80106642 <sys_exec+0x7b>
      return -1;
80106638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010663d:	e9 95 00 00 00       	jmp    801066d7 <sys_exec+0x110>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106645:	c1 e0 02             	shl    $0x2,%eax
80106648:	89 c2                	mov    %eax,%edx
8010664a:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106650:	01 c2                	add    %eax,%edx
80106652:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106658:	89 44 24 04          	mov    %eax,0x4(%esp)
8010665c:	89 14 24             	mov    %edx,(%esp)
8010665f:	e8 d0 f1 ff ff       	call   80105834 <fetchint>
80106664:	85 c0                	test   %eax,%eax
80106666:	79 07                	jns    8010666f <sys_exec+0xa8>
      return -1;
80106668:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010666d:	eb 68                	jmp    801066d7 <sys_exec+0x110>
    if(uarg == 0){
8010666f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106675:	85 c0                	test   %eax,%eax
80106677:	75 26                	jne    8010669f <sys_exec+0xd8>
      argv[i] = 0;
80106679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010667c:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106683:	00 00 00 00 
      break;
80106687:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106688:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010668b:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106691:	89 54 24 04          	mov    %edx,0x4(%esp)
80106695:	89 04 24             	mov    %eax,(%esp)
80106698:	e8 5f a4 ff ff       	call   80100afc <exec>
8010669d:	eb 38                	jmp    801066d7 <sys_exec+0x110>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010669f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801066a9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066af:	01 c2                	add    %eax,%edx
801066b1:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801066bb:	89 04 24             	mov    %eax,(%esp)
801066be:	e8 ab f1 ff ff       	call   8010586e <fetchstr>
801066c3:	85 c0                	test   %eax,%eax
801066c5:	79 07                	jns    801066ce <sys_exec+0x107>
      return -1;
801066c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066cc:	eb 09                	jmp    801066d7 <sys_exec+0x110>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801066ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801066d2:	e9 59 ff ff ff       	jmp    80106630 <sys_exec+0x69>
  return exec(path, argv);
}
801066d7:	c9                   	leave  
801066d8:	c3                   	ret    

801066d9 <sys_pipe>:

int
sys_pipe(void)
{
801066d9:	55                   	push   %ebp
801066da:	89 e5                	mov    %esp,%ebp
801066dc:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801066df:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801066e6:	00 
801066e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801066ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066f5:	e8 06 f2 ff ff       	call   80105900 <argptr>
801066fa:	85 c0                	test   %eax,%eax
801066fc:	79 0a                	jns    80106708 <sys_pipe+0x2f>
    return -1;
801066fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106703:	e9 9b 00 00 00       	jmp    801067a3 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106708:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010670b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010670f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106712:	89 04 24             	mov    %eax,(%esp)
80106715:	e8 5e d8 ff ff       	call   80103f78 <pipealloc>
8010671a:	85 c0                	test   %eax,%eax
8010671c:	79 07                	jns    80106725 <sys_pipe+0x4c>
    return -1;
8010671e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106723:	eb 7e                	jmp    801067a3 <sys_pipe+0xca>
  fd0 = -1;
80106725:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010672c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010672f:	89 04 24             	mov    %eax,(%esp)
80106732:	e8 66 f3 ff ff       	call   80105a9d <fdalloc>
80106737:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010673a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010673e:	78 14                	js     80106754 <sys_pipe+0x7b>
80106740:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106743:	89 04 24             	mov    %eax,(%esp)
80106746:	e8 52 f3 ff ff       	call   80105a9d <fdalloc>
8010674b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010674e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106752:	79 37                	jns    8010678b <sys_pipe+0xb2>
    if(fd0 >= 0)
80106754:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106758:	78 14                	js     8010676e <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
8010675a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106760:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106763:	83 c2 08             	add    $0x8,%edx
80106766:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010676d:	00 
    fileclose(rf);
8010676e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106771:	89 04 24             	mov    %eax,(%esp)
80106774:	e8 57 a8 ff ff       	call   80100fd0 <fileclose>
    fileclose(wf);
80106779:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010677c:	89 04 24             	mov    %eax,(%esp)
8010677f:	e8 4c a8 ff ff       	call   80100fd0 <fileclose>
    return -1;
80106784:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106789:	eb 18                	jmp    801067a3 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010678b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010678e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106791:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106793:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106796:	8d 50 04             	lea    0x4(%eax),%edx
80106799:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010679c:	89 02                	mov    %eax,(%edx)
  return 0;
8010679e:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067a3:	c9                   	leave  
801067a4:	c3                   	ret    
801067a5:	00 00                	add    %al,(%eax)
	...

801067a8 <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
801067a8:	55                   	push   %ebp
801067a9:	89 e5                	mov    %esp,%ebp
801067ab:	83 ec 08             	sub    $0x8,%esp
801067ae:	8b 55 08             	mov    0x8(%ebp),%edx
801067b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801067b4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801067b8:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801067bc:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
801067c0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801067c4:	66 ef                	out    %ax,(%dx)
}
801067c6:	c9                   	leave  
801067c7:	c3                   	ret    

801067c8 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801067c8:	55                   	push   %ebp
801067c9:	89 e5                	mov    %esp,%ebp
801067cb:	83 ec 08             	sub    $0x8,%esp
  return fork();
801067ce:	e8 5b de ff ff       	call   8010462e <fork>
}
801067d3:	c9                   	leave  
801067d4:	c3                   	ret    

801067d5 <sys_exit>:

int
sys_exit(void)
{
801067d5:	55                   	push   %ebp
801067d6:	89 e5                	mov    %esp,%ebp
801067d8:	83 ec 08             	sub    $0x8,%esp
  exit();
801067db:	e8 8d e1 ff ff       	call   8010496d <exit>
  return 0;  // not reached
801067e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067e5:	c9                   	leave  
801067e6:	c3                   	ret    

801067e7 <sys_wait>:

int
sys_wait(void)
{
801067e7:	55                   	push   %ebp
801067e8:	89 e5                	mov    %esp,%ebp
801067ea:	83 ec 08             	sub    $0x8,%esp
  return wait();
801067ed:	e8 1f e4 ff ff       	call   80104c11 <wait>
}
801067f2:	c9                   	leave  
801067f3:	c3                   	ret    

801067f4 <sys_kill>:

int
sys_kill(void)
{
801067f4:	55                   	push   %ebp
801067f5:	89 e5                	mov    %esp,%ebp
801067f7:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801067fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106801:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106808:	e8 c5 f0 ff ff       	call   801058d2 <argint>
8010680d:	85 c0                	test   %eax,%eax
8010680f:	79 07                	jns    80106818 <sys_kill+0x24>
    return -1;
80106811:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106816:	eb 0b                	jmp    80106823 <sys_kill+0x2f>
  return kill(pid);
80106818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681b:	89 04 24             	mov    %eax,(%esp)
8010681e:	e8 24 e9 ff ff       	call   80105147 <kill>
}
80106823:	c9                   	leave  
80106824:	c3                   	ret    

80106825 <sys_getpid>:

int
sys_getpid(void)
{
80106825:	55                   	push   %ebp
80106826:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106828:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010682e:	8b 40 10             	mov    0x10(%eax),%eax
}
80106831:	5d                   	pop    %ebp
80106832:	c3                   	ret    

80106833 <sys_sbrk>:

int
sys_sbrk(void)
{
80106833:	55                   	push   %ebp
80106834:	89 e5                	mov    %esp,%ebp
80106836:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106839:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010683c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106840:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106847:	e8 86 f0 ff ff       	call   801058d2 <argint>
8010684c:	85 c0                	test   %eax,%eax
8010684e:	79 07                	jns    80106857 <sys_sbrk+0x24>
    return -1;
80106850:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106855:	eb 24                	jmp    8010687b <sys_sbrk+0x48>
  addr = proc->sz;
80106857:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010685d:	8b 00                	mov    (%eax),%eax
8010685f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106862:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106865:	89 04 24             	mov    %eax,(%esp)
80106868:	e8 1c dd ff ff       	call   80104589 <growproc>
8010686d:	85 c0                	test   %eax,%eax
8010686f:	79 07                	jns    80106878 <sys_sbrk+0x45>
    return -1;
80106871:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106876:	eb 03                	jmp    8010687b <sys_sbrk+0x48>
  return addr;
80106878:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010687b:	c9                   	leave  
8010687c:	c3                   	ret    

8010687d <sys_sleep>:

int
sys_sleep(void)
{
8010687d:	55                   	push   %ebp
8010687e:	89 e5                	mov    %esp,%ebp
80106880:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106883:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106886:	89 44 24 04          	mov    %eax,0x4(%esp)
8010688a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106891:	e8 3c f0 ff ff       	call   801058d2 <argint>
80106896:	85 c0                	test   %eax,%eax
80106898:	79 07                	jns    801068a1 <sys_sleep+0x24>
    return -1;
8010689a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010689f:	eb 6c                	jmp    8010690d <sys_sleep+0x90>
  acquire(&tickslock);
801068a1:	c7 04 24 c0 5a 11 80 	movl   $0x80115ac0,(%esp)
801068a8:	e8 7a ea ff ff       	call   80105327 <acquire>
  ticks0 = ticks;
801068ad:	a1 00 63 11 80       	mov    0x80116300,%eax
801068b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801068b5:	eb 34                	jmp    801068eb <sys_sleep+0x6e>
    if(proc->killed){
801068b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068bd:	8b 40 24             	mov    0x24(%eax),%eax
801068c0:	85 c0                	test   %eax,%eax
801068c2:	74 13                	je     801068d7 <sys_sleep+0x5a>
      release(&tickslock);
801068c4:	c7 04 24 c0 5a 11 80 	movl   $0x80115ac0,(%esp)
801068cb:	e8 b9 ea ff ff       	call   80105389 <release>
      return -1;
801068d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068d5:	eb 36                	jmp    8010690d <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
801068d7:	c7 44 24 04 c0 5a 11 	movl   $0x80115ac0,0x4(%esp)
801068de:	80 
801068df:	c7 04 24 00 63 11 80 	movl   $0x80116300,(%esp)
801068e6:	e8 55 e7 ff ff       	call   80105040 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801068eb:	a1 00 63 11 80       	mov    0x80116300,%eax
801068f0:	89 c2                	mov    %eax,%edx
801068f2:	2b 55 f4             	sub    -0xc(%ebp),%edx
801068f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068f8:	39 c2                	cmp    %eax,%edx
801068fa:	72 bb                	jb     801068b7 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801068fc:	c7 04 24 c0 5a 11 80 	movl   $0x80115ac0,(%esp)
80106903:	e8 81 ea ff ff       	call   80105389 <release>
  return 0;
80106908:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010690d:	c9                   	leave  
8010690e:	c3                   	ret    

8010690f <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010690f:	55                   	push   %ebp
80106910:	89 e5                	mov    %esp,%ebp
80106912:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106915:	c7 04 24 c0 5a 11 80 	movl   $0x80115ac0,(%esp)
8010691c:	e8 06 ea ff ff       	call   80105327 <acquire>
  xticks = ticks;
80106921:	a1 00 63 11 80       	mov    0x80116300,%eax
80106926:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106929:	c7 04 24 c0 5a 11 80 	movl   $0x80115ac0,(%esp)
80106930:	e8 54 ea ff ff       	call   80105389 <release>
  return xticks;
80106935:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106938:	c9                   	leave  
80106939:	c3                   	ret    

8010693a <sys_halt>:
// signal to QEMU.
// Based on: http://pdos.csail.mit.edu/6.828/2012/homework/xv6-syscall.html
// and: https://github.com/t3rm1n4l/pintos/blob/master/devices/shutdown.c
int
sys_halt(void)
{
8010693a:	55                   	push   %ebp
8010693b:	89 e5                	mov    %esp,%ebp
8010693d:	83 ec 18             	sub    $0x18,%esp
  char *p = "Shutdown";
80106940:	c7 45 fc 19 8f 10 80 	movl   $0x80108f19,-0x4(%ebp)
  for( ; *p; p++)
80106947:	eb 18                	jmp    80106961 <sys_halt+0x27>
    outw(0xB004, 0x2000);
80106949:	c7 44 24 04 00 20 00 	movl   $0x2000,0x4(%esp)
80106950:	00 
80106951:	c7 04 24 04 b0 00 00 	movl   $0xb004,(%esp)
80106958:	e8 4b fe ff ff       	call   801067a8 <outw>
// and: https://github.com/t3rm1n4l/pintos/blob/master/devices/shutdown.c
int
sys_halt(void)
{
  char *p = "Shutdown";
  for( ; *p; p++)
8010695d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106961:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106964:	0f b6 00             	movzbl (%eax),%eax
80106967:	84 c0                	test   %al,%al
80106969:	75 de                	jne    80106949 <sys_halt+0xf>
    outw(0xB004, 0x2000);
  return 0;
8010696b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106970:	c9                   	leave  
80106971:	c3                   	ret    

80106972 <sys_clone>:


//For project 2
int
sys_clone(void)
{
80106972:	55                   	push   %ebp
80106973:	89 e5                	mov    %esp,%ebp
80106975:	83 ec 28             	sub    $0x28,%esp

int myFunction, myArgument, myStack;

if(argint(0, &myFunction) < 0 || argint(1, &myArgument) < 0 || argint(2, &myStack) < 0){
80106978:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010697b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010697f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106986:	e8 47 ef ff ff       	call   801058d2 <argint>
8010698b:	85 c0                	test   %eax,%eax
8010698d:	78 2e                	js     801069bd <sys_clone+0x4b>
8010698f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106992:	89 44 24 04          	mov    %eax,0x4(%esp)
80106996:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010699d:	e8 30 ef ff ff       	call   801058d2 <argint>
801069a2:	85 c0                	test   %eax,%eax
801069a4:	78 17                	js     801069bd <sys_clone+0x4b>
801069a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801069a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801069ad:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801069b4:	e8 19 ef ff ff       	call   801058d2 <argint>
801069b9:	85 c0                	test   %eax,%eax
801069bb:	79 07                	jns    801069c4 <sys_clone+0x52>
  return -1;
801069bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069c2:	eb 1d                	jmp    801069e1 <sys_clone+0x6f>
}

return clone((void*)myFunction, (void*)myArgument, (void*)myStack);
801069c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801069c7:	89 c1                	mov    %eax,%ecx
801069c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069cc:	89 c2                	mov    %eax,%edx
801069ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801069d5:	89 54 24 04          	mov    %edx,0x4(%esp)
801069d9:	89 04 24             	mov    %eax,(%esp)
801069dc:	e8 d4 dd ff ff       	call   801047b5 <clone>

}
801069e1:	c9                   	leave  
801069e2:	c3                   	ret    

801069e3 <sys_join>:

int
sys_join(void)
{
801069e3:	55                   	push   %ebp
801069e4:	89 e5                	mov    %esp,%ebp
801069e6:	83 ec 28             	sub    $0x28,%esp

int myPid, myStack, myRetval;

if(argint(0, &myPid) < 0 || argint(1, &myStack) < 0 || argint(2, &myRetval)){
801069e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801069f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069f7:	e8 d6 ee ff ff       	call   801058d2 <argint>
801069fc:	85 c0                	test   %eax,%eax
801069fe:	78 2e                	js     80106a2e <sys_join+0x4b>
80106a00:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a03:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a07:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a0e:	e8 bf ee ff ff       	call   801058d2 <argint>
80106a13:	85 c0                	test   %eax,%eax
80106a15:	78 17                	js     80106a2e <sys_join+0x4b>
80106a17:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a1e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106a25:	e8 a8 ee ff ff       	call   801058d2 <argint>
80106a2a:	85 c0                	test   %eax,%eax
80106a2c:	74 07                	je     80106a35 <sys_join+0x52>
  return -1;
80106a2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a33:	eb 1d                	jmp    80106a52 <sys_join+0x6f>
}

return join((int)myPid, (void**)myStack, (void**)myRetval);
80106a35:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106a38:	89 c1                	mov    %eax,%ecx
80106a3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a3d:	89 c2                	mov    %eax,%edx
80106a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a42:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106a46:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a4a:	89 04 24             	mov    %eax,(%esp)
80106a4d:	e8 d1 e2 ff ff       	call   80104d23 <join>

}
80106a52:	c9                   	leave  
80106a53:	c3                   	ret    

80106a54 <sys_texit>:

int 
sys_texit(void)
{
80106a54:	55                   	push   %ebp
80106a55:	89 e5                	mov    %esp,%ebp
80106a57:	83 ec 28             	sub    $0x28,%esp

int myRetval;

if(argint(0, &myRetval) < 0)
80106a5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a68:	e8 65 ee ff ff       	call   801058d2 <argint>
80106a6d:	85 c0                	test   %eax,%eax
80106a6f:	79 07                	jns    80106a78 <sys_texit+0x24>
  return -1;
80106a71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a76:	eb 0b                	jmp    80106a83 <sys_texit+0x2f>

texit((void*)myRetval);
80106a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a7b:	89 04 24             	mov    %eax,(%esp)
80106a7e:	e8 3c e0 ff ff       	call   80104abf <texit>
return;

}
80106a83:	c9                   	leave  
80106a84:	c3                   	ret    
80106a85:	00 00                	add    %al,(%eax)
	...

80106a88 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106a88:	55                   	push   %ebp
80106a89:	89 e5                	mov    %esp,%ebp
80106a8b:	83 ec 08             	sub    $0x8,%esp
80106a8e:	8b 55 08             	mov    0x8(%ebp),%edx
80106a91:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a94:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106a98:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106a9b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106a9f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106aa3:	ee                   	out    %al,(%dx)
}
80106aa4:	c9                   	leave  
80106aa5:	c3                   	ret    

80106aa6 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106aa6:	55                   	push   %ebp
80106aa7:	89 e5                	mov    %esp,%ebp
80106aa9:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106aac:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106ab3:	00 
80106ab4:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106abb:	e8 c8 ff ff ff       	call   80106a88 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106ac0:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106ac7:	00 
80106ac8:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106acf:	e8 b4 ff ff ff       	call   80106a88 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106ad4:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106adb:	00 
80106adc:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106ae3:	e8 a0 ff ff ff       	call   80106a88 <outb>
  picenable(IRQ_TIMER);
80106ae8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106aef:	e8 0d d3 ff ff       	call   80103e01 <picenable>
}
80106af4:	c9                   	leave  
80106af5:	c3                   	ret    
	...

80106af8 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106af8:	1e                   	push   %ds
  pushl %es
80106af9:	06                   	push   %es
  pushl %fs
80106afa:	0f a0                	push   %fs
  pushl %gs
80106afc:	0f a8                	push   %gs
  pushal
80106afe:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106aff:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106b03:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106b05:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106b07:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106b0b:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106b0d:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106b0f:	54                   	push   %esp
  call trap
80106b10:	e8 de 01 00 00       	call   80106cf3 <trap>
  addl $4, %esp
80106b15:	83 c4 04             	add    $0x4,%esp

80106b18 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106b18:	61                   	popa   
  popl %gs
80106b19:	0f a9                	pop    %gs
  popl %fs
80106b1b:	0f a1                	pop    %fs
  popl %es
80106b1d:	07                   	pop    %es
  popl %ds
80106b1e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106b1f:	83 c4 08             	add    $0x8,%esp
  iret
80106b22:	cf                   	iret   
	...

80106b24 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106b24:	55                   	push   %ebp
80106b25:	89 e5                	mov    %esp,%ebp
80106b27:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b2d:	83 e8 01             	sub    $0x1,%eax
80106b30:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106b34:	8b 45 08             	mov    0x8(%ebp),%eax
80106b37:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106b3b:	8b 45 08             	mov    0x8(%ebp),%eax
80106b3e:	c1 e8 10             	shr    $0x10,%eax
80106b41:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106b45:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106b48:	0f 01 18             	lidtl  (%eax)
}
80106b4b:	c9                   	leave  
80106b4c:	c3                   	ret    

80106b4d <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106b4d:	55                   	push   %ebp
80106b4e:	89 e5                	mov    %esp,%ebp
80106b50:	53                   	push   %ebx
80106b51:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106b54:	0f 20 d3             	mov    %cr2,%ebx
80106b57:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106b5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106b5d:	83 c4 10             	add    $0x10,%esp
80106b60:	5b                   	pop    %ebx
80106b61:	5d                   	pop    %ebp
80106b62:	c3                   	ret    

80106b63 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106b63:	55                   	push   %ebp
80106b64:	89 e5                	mov    %esp,%ebp
80106b66:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b70:	e9 c3 00 00 00       	jmp    80106c38 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b78:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80106b7f:	89 c2                	mov    %eax,%edx
80106b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b84:	66 89 14 c5 00 5b 11 	mov    %dx,-0x7feea500(,%eax,8)
80106b8b:	80 
80106b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b8f:	66 c7 04 c5 02 5b 11 	movw   $0x8,-0x7feea4fe(,%eax,8)
80106b96:	80 08 00 
80106b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b9c:	0f b6 14 c5 04 5b 11 	movzbl -0x7feea4fc(,%eax,8),%edx
80106ba3:	80 
80106ba4:	83 e2 e0             	and    $0xffffffe0,%edx
80106ba7:	88 14 c5 04 5b 11 80 	mov    %dl,-0x7feea4fc(,%eax,8)
80106bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb1:	0f b6 14 c5 04 5b 11 	movzbl -0x7feea4fc(,%eax,8),%edx
80106bb8:	80 
80106bb9:	83 e2 1f             	and    $0x1f,%edx
80106bbc:	88 14 c5 04 5b 11 80 	mov    %dl,-0x7feea4fc(,%eax,8)
80106bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc6:	0f b6 14 c5 05 5b 11 	movzbl -0x7feea4fb(,%eax,8),%edx
80106bcd:	80 
80106bce:	83 e2 f0             	and    $0xfffffff0,%edx
80106bd1:	83 ca 0e             	or     $0xe,%edx
80106bd4:	88 14 c5 05 5b 11 80 	mov    %dl,-0x7feea4fb(,%eax,8)
80106bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bde:	0f b6 14 c5 05 5b 11 	movzbl -0x7feea4fb(,%eax,8),%edx
80106be5:	80 
80106be6:	83 e2 ef             	and    $0xffffffef,%edx
80106be9:	88 14 c5 05 5b 11 80 	mov    %dl,-0x7feea4fb(,%eax,8)
80106bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bf3:	0f b6 14 c5 05 5b 11 	movzbl -0x7feea4fb(,%eax,8),%edx
80106bfa:	80 
80106bfb:	83 e2 9f             	and    $0xffffff9f,%edx
80106bfe:	88 14 c5 05 5b 11 80 	mov    %dl,-0x7feea4fb(,%eax,8)
80106c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c08:	0f b6 14 c5 05 5b 11 	movzbl -0x7feea4fb(,%eax,8),%edx
80106c0f:	80 
80106c10:	83 ca 80             	or     $0xffffff80,%edx
80106c13:	88 14 c5 05 5b 11 80 	mov    %dl,-0x7feea4fb(,%eax,8)
80106c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c1d:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80106c24:	c1 e8 10             	shr    $0x10,%eax
80106c27:	89 c2                	mov    %eax,%edx
80106c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c2c:	66 89 14 c5 06 5b 11 	mov    %dx,-0x7feea4fa(,%eax,8)
80106c33:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106c34:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c38:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106c3f:	0f 8e 30 ff ff ff    	jle    80106b75 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106c45:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
80106c4a:	66 a3 00 5d 11 80    	mov    %ax,0x80115d00
80106c50:	66 c7 05 02 5d 11 80 	movw   $0x8,0x80115d02
80106c57:	08 00 
80106c59:	0f b6 05 04 5d 11 80 	movzbl 0x80115d04,%eax
80106c60:	83 e0 e0             	and    $0xffffffe0,%eax
80106c63:	a2 04 5d 11 80       	mov    %al,0x80115d04
80106c68:	0f b6 05 04 5d 11 80 	movzbl 0x80115d04,%eax
80106c6f:	83 e0 1f             	and    $0x1f,%eax
80106c72:	a2 04 5d 11 80       	mov    %al,0x80115d04
80106c77:	0f b6 05 05 5d 11 80 	movzbl 0x80115d05,%eax
80106c7e:	83 c8 0f             	or     $0xf,%eax
80106c81:	a2 05 5d 11 80       	mov    %al,0x80115d05
80106c86:	0f b6 05 05 5d 11 80 	movzbl 0x80115d05,%eax
80106c8d:	83 e0 ef             	and    $0xffffffef,%eax
80106c90:	a2 05 5d 11 80       	mov    %al,0x80115d05
80106c95:	0f b6 05 05 5d 11 80 	movzbl 0x80115d05,%eax
80106c9c:	83 c8 60             	or     $0x60,%eax
80106c9f:	a2 05 5d 11 80       	mov    %al,0x80115d05
80106ca4:	0f b6 05 05 5d 11 80 	movzbl 0x80115d05,%eax
80106cab:	83 c8 80             	or     $0xffffff80,%eax
80106cae:	a2 05 5d 11 80       	mov    %al,0x80115d05
80106cb3:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
80106cb8:	c1 e8 10             	shr    $0x10,%eax
80106cbb:	66 a3 06 5d 11 80    	mov    %ax,0x80115d06
  
  initlock(&tickslock, "time");
80106cc1:	c7 44 24 04 24 8f 10 	movl   $0x80108f24,0x4(%esp)
80106cc8:	80 
80106cc9:	c7 04 24 c0 5a 11 80 	movl   $0x80115ac0,(%esp)
80106cd0:	e8 31 e6 ff ff       	call   80105306 <initlock>
}
80106cd5:	c9                   	leave  
80106cd6:	c3                   	ret    

80106cd7 <idtinit>:

void
idtinit(void)
{
80106cd7:	55                   	push   %ebp
80106cd8:	89 e5                	mov    %esp,%ebp
80106cda:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106cdd:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106ce4:	00 
80106ce5:	c7 04 24 00 5b 11 80 	movl   $0x80115b00,(%esp)
80106cec:	e8 33 fe ff ff       	call   80106b24 <lidt>
}
80106cf1:	c9                   	leave  
80106cf2:	c3                   	ret    

80106cf3 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106cf3:	55                   	push   %ebp
80106cf4:	89 e5                	mov    %esp,%ebp
80106cf6:	57                   	push   %edi
80106cf7:	56                   	push   %esi
80106cf8:	53                   	push   %ebx
80106cf9:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106cfc:	8b 45 08             	mov    0x8(%ebp),%eax
80106cff:	8b 40 30             	mov    0x30(%eax),%eax
80106d02:	83 f8 40             	cmp    $0x40,%eax
80106d05:	75 3e                	jne    80106d45 <trap+0x52>
    if(proc->killed)
80106d07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d0d:	8b 40 24             	mov    0x24(%eax),%eax
80106d10:	85 c0                	test   %eax,%eax
80106d12:	74 05                	je     80106d19 <trap+0x26>
      exit();
80106d14:	e8 54 dc ff ff       	call   8010496d <exit>
    proc->tf = tf;
80106d19:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d1f:	8b 55 08             	mov    0x8(%ebp),%edx
80106d22:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106d25:	e8 6f ec ff ff       	call   80105999 <syscall>
    if(proc->killed)
80106d2a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d30:	8b 40 24             	mov    0x24(%eax),%eax
80106d33:	85 c0                	test   %eax,%eax
80106d35:	0f 84 34 02 00 00    	je     80106f6f <trap+0x27c>
      exit();
80106d3b:	e8 2d dc ff ff       	call   8010496d <exit>
    return;
80106d40:	e9 2a 02 00 00       	jmp    80106f6f <trap+0x27c>
  }

  switch(tf->trapno){
80106d45:	8b 45 08             	mov    0x8(%ebp),%eax
80106d48:	8b 40 30             	mov    0x30(%eax),%eax
80106d4b:	83 e8 20             	sub    $0x20,%eax
80106d4e:	83 f8 1f             	cmp    $0x1f,%eax
80106d51:	0f 87 bc 00 00 00    	ja     80106e13 <trap+0x120>
80106d57:	8b 04 85 cc 8f 10 80 	mov    -0x7fef7034(,%eax,4),%eax
80106d5e:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106d60:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106d66:	0f b6 00             	movzbl (%eax),%eax
80106d69:	84 c0                	test   %al,%al
80106d6b:	75 31                	jne    80106d9e <trap+0xab>
      acquire(&tickslock);
80106d6d:	c7 04 24 c0 5a 11 80 	movl   $0x80115ac0,(%esp)
80106d74:	e8 ae e5 ff ff       	call   80105327 <acquire>
      ticks++;
80106d79:	a1 00 63 11 80       	mov    0x80116300,%eax
80106d7e:	83 c0 01             	add    $0x1,%eax
80106d81:	a3 00 63 11 80       	mov    %eax,0x80116300
      wakeup(&ticks);
80106d86:	c7 04 24 00 63 11 80 	movl   $0x80116300,(%esp)
80106d8d:	e8 8a e3 ff ff       	call   8010511c <wakeup>
      release(&tickslock);
80106d92:	c7 04 24 c0 5a 11 80 	movl   $0x80115ac0,(%esp)
80106d99:	e8 eb e5 ff ff       	call   80105389 <release>
    }
    lapiceoi();
80106d9e:	e8 7c c1 ff ff       	call   80102f1f <lapiceoi>
    break;
80106da3:	e9 41 01 00 00       	jmp    80106ee9 <trap+0x1f6>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106da8:	e8 50 b9 ff ff       	call   801026fd <ideintr>
    lapiceoi();
80106dad:	e8 6d c1 ff ff       	call   80102f1f <lapiceoi>
    break;
80106db2:	e9 32 01 00 00       	jmp    80106ee9 <trap+0x1f6>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106db7:	e8 17 bf ff ff       	call   80102cd3 <kbdintr>
    lapiceoi();
80106dbc:	e8 5e c1 ff ff       	call   80102f1f <lapiceoi>
    break;
80106dc1:	e9 23 01 00 00       	jmp    80106ee9 <trap+0x1f6>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106dc6:	e8 a9 03 00 00       	call   80107174 <uartintr>
    lapiceoi();
80106dcb:	e8 4f c1 ff ff       	call   80102f1f <lapiceoi>
    break;
80106dd0:	e9 14 01 00 00       	jmp    80106ee9 <trap+0x1f6>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106dd5:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106dd8:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80106dde:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106de2:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106de5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106deb:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106dee:	0f b6 c0             	movzbl %al,%eax
80106df1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106df5:	89 54 24 08          	mov    %edx,0x8(%esp)
80106df9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dfd:	c7 04 24 2c 8f 10 80 	movl   $0x80108f2c,(%esp)
80106e04:	e8 98 95 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106e09:	e8 11 c1 ff ff       	call   80102f1f <lapiceoi>
    break;
80106e0e:	e9 d6 00 00 00       	jmp    80106ee9 <trap+0x1f6>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106e13:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e19:	85 c0                	test   %eax,%eax
80106e1b:	74 11                	je     80106e2e <trap+0x13b>
80106e1d:	8b 45 08             	mov    0x8(%ebp),%eax
80106e20:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e24:	0f b7 c0             	movzwl %ax,%eax
80106e27:	83 e0 03             	and    $0x3,%eax
80106e2a:	85 c0                	test   %eax,%eax
80106e2c:	75 46                	jne    80106e74 <trap+0x181>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e2e:	e8 1a fd ff ff       	call   80106b4d <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106e33:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e36:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106e39:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106e40:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e43:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106e46:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e49:	8b 52 30             	mov    0x30(%edx),%edx
80106e4c:	89 44 24 10          	mov    %eax,0x10(%esp)
80106e50:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106e54:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106e58:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e5c:	c7 04 24 50 8f 10 80 	movl   $0x80108f50,(%esp)
80106e63:	e8 39 95 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106e68:	c7 04 24 82 8f 10 80 	movl   $0x80108f82,(%esp)
80106e6f:	e8 c9 96 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e74:	e8 d4 fc ff ff       	call   80106b4d <rcr2>
80106e79:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e7b:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e7e:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e81:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106e87:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e8a:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e8d:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e90:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e93:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e96:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e99:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e9f:	83 c0 6c             	add    $0x6c,%eax
80106ea2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106ea5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106eab:	8b 40 10             	mov    0x10(%eax),%eax
80106eae:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106eb2:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106eb6:	89 74 24 14          	mov    %esi,0x14(%esp)
80106eba:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106ebe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106ec2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106ec5:	89 54 24 08          	mov    %edx,0x8(%esp)
80106ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ecd:	c7 04 24 88 8f 10 80 	movl   $0x80108f88,(%esp)
80106ed4:	e8 c8 94 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106ed9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106edf:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106ee6:	eb 01                	jmp    80106ee9 <trap+0x1f6>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106ee8:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106ee9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106eef:	85 c0                	test   %eax,%eax
80106ef1:	74 24                	je     80106f17 <trap+0x224>
80106ef3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ef9:	8b 40 24             	mov    0x24(%eax),%eax
80106efc:	85 c0                	test   %eax,%eax
80106efe:	74 17                	je     80106f17 <trap+0x224>
80106f00:	8b 45 08             	mov    0x8(%ebp),%eax
80106f03:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f07:	0f b7 c0             	movzwl %ax,%eax
80106f0a:	83 e0 03             	and    $0x3,%eax
80106f0d:	83 f8 03             	cmp    $0x3,%eax
80106f10:	75 05                	jne    80106f17 <trap+0x224>
    exit();
80106f12:	e8 56 da ff ff       	call   8010496d <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106f17:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f1d:	85 c0                	test   %eax,%eax
80106f1f:	74 1e                	je     80106f3f <trap+0x24c>
80106f21:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f27:	8b 40 0c             	mov    0xc(%eax),%eax
80106f2a:	83 f8 04             	cmp    $0x4,%eax
80106f2d:	75 10                	jne    80106f3f <trap+0x24c>
80106f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80106f32:	8b 40 30             	mov    0x30(%eax),%eax
80106f35:	83 f8 20             	cmp    $0x20,%eax
80106f38:	75 05                	jne    80106f3f <trap+0x24c>
    yield();
80106f3a:	e8 a3 e0 ff ff       	call   80104fe2 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106f3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f45:	85 c0                	test   %eax,%eax
80106f47:	74 27                	je     80106f70 <trap+0x27d>
80106f49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f4f:	8b 40 24             	mov    0x24(%eax),%eax
80106f52:	85 c0                	test   %eax,%eax
80106f54:	74 1a                	je     80106f70 <trap+0x27d>
80106f56:	8b 45 08             	mov    0x8(%ebp),%eax
80106f59:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f5d:	0f b7 c0             	movzwl %ax,%eax
80106f60:	83 e0 03             	and    $0x3,%eax
80106f63:	83 f8 03             	cmp    $0x3,%eax
80106f66:	75 08                	jne    80106f70 <trap+0x27d>
    exit();
80106f68:	e8 00 da ff ff       	call   8010496d <exit>
80106f6d:	eb 01                	jmp    80106f70 <trap+0x27d>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106f6f:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106f70:	83 c4 3c             	add    $0x3c,%esp
80106f73:	5b                   	pop    %ebx
80106f74:	5e                   	pop    %esi
80106f75:	5f                   	pop    %edi
80106f76:	5d                   	pop    %ebp
80106f77:	c3                   	ret    

80106f78 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106f78:	55                   	push   %ebp
80106f79:	89 e5                	mov    %esp,%ebp
80106f7b:	53                   	push   %ebx
80106f7c:	83 ec 14             	sub    $0x14,%esp
80106f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80106f82:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f86:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106f8a:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106f8e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106f92:	ec                   	in     (%dx),%al
80106f93:	89 c3                	mov    %eax,%ebx
80106f95:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106f98:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106f9c:	83 c4 14             	add    $0x14,%esp
80106f9f:	5b                   	pop    %ebx
80106fa0:	5d                   	pop    %ebp
80106fa1:	c3                   	ret    

80106fa2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106fa2:	55                   	push   %ebp
80106fa3:	89 e5                	mov    %esp,%ebp
80106fa5:	83 ec 08             	sub    $0x8,%esp
80106fa8:	8b 55 08             	mov    0x8(%ebp),%edx
80106fab:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fae:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106fb2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106fb5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106fb9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106fbd:	ee                   	out    %al,(%dx)
}
80106fbe:	c9                   	leave  
80106fbf:	c3                   	ret    

80106fc0 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106fc0:	55                   	push   %ebp
80106fc1:	89 e5                	mov    %esp,%ebp
80106fc3:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106fc6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106fcd:	00 
80106fce:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106fd5:	e8 c8 ff ff ff       	call   80106fa2 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106fda:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106fe1:	00 
80106fe2:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106fe9:	e8 b4 ff ff ff       	call   80106fa2 <outb>
  outb(COM1+0, 115200/9600);
80106fee:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106ff5:	00 
80106ff6:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106ffd:	e8 a0 ff ff ff       	call   80106fa2 <outb>
  outb(COM1+1, 0);
80107002:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107009:	00 
8010700a:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107011:	e8 8c ff ff ff       	call   80106fa2 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107016:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010701d:	00 
8010701e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107025:	e8 78 ff ff ff       	call   80106fa2 <outb>
  outb(COM1+4, 0);
8010702a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107031:	00 
80107032:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107039:	e8 64 ff ff ff       	call   80106fa2 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010703e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107045:	00 
80107046:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010704d:	e8 50 ff ff ff       	call   80106fa2 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107052:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107059:	e8 1a ff ff ff       	call   80106f78 <inb>
8010705e:	3c ff                	cmp    $0xff,%al
80107060:	74 6c                	je     801070ce <uartinit+0x10e>
    return;
  uart = 1;
80107062:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
80107069:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010706c:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107073:	e8 00 ff ff ff       	call   80106f78 <inb>
  inb(COM1+0);
80107078:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010707f:	e8 f4 fe ff ff       	call   80106f78 <inb>
  picenable(IRQ_COM1);
80107084:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010708b:	e8 71 cd ff ff       	call   80103e01 <picenable>
  ioapicenable(IRQ_COM1, 0);
80107090:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107097:	00 
80107098:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010709f:	e8 de b8 ff ff       	call   80102982 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801070a4:	c7 45 f4 4c 90 10 80 	movl   $0x8010904c,-0xc(%ebp)
801070ab:	eb 15                	jmp    801070c2 <uartinit+0x102>
    uartputc(*p);
801070ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b0:	0f b6 00             	movzbl (%eax),%eax
801070b3:	0f be c0             	movsbl %al,%eax
801070b6:	89 04 24             	mov    %eax,(%esp)
801070b9:	e8 13 00 00 00       	call   801070d1 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801070be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801070c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070c5:	0f b6 00             	movzbl (%eax),%eax
801070c8:	84 c0                	test   %al,%al
801070ca:	75 e1                	jne    801070ad <uartinit+0xed>
801070cc:	eb 01                	jmp    801070cf <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801070ce:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801070cf:	c9                   	leave  
801070d0:	c3                   	ret    

801070d1 <uartputc>:

void
uartputc(int c)
{
801070d1:	55                   	push   %ebp
801070d2:	89 e5                	mov    %esp,%ebp
801070d4:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801070d7:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
801070dc:	85 c0                	test   %eax,%eax
801070de:	74 4d                	je     8010712d <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801070e7:	eb 10                	jmp    801070f9 <uartputc+0x28>
    microdelay(10);
801070e9:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801070f0:	e8 4f be ff ff       	call   80102f44 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070f5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801070f9:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801070fd:	7f 16                	jg     80107115 <uartputc+0x44>
801070ff:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107106:	e8 6d fe ff ff       	call   80106f78 <inb>
8010710b:	0f b6 c0             	movzbl %al,%eax
8010710e:	83 e0 20             	and    $0x20,%eax
80107111:	85 c0                	test   %eax,%eax
80107113:	74 d4                	je     801070e9 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107115:	8b 45 08             	mov    0x8(%ebp),%eax
80107118:	0f b6 c0             	movzbl %al,%eax
8010711b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010711f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107126:	e8 77 fe ff ff       	call   80106fa2 <outb>
8010712b:	eb 01                	jmp    8010712e <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
8010712d:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
8010712e:	c9                   	leave  
8010712f:	c3                   	ret    

80107130 <uartgetc>:

static int
uartgetc(void)
{
80107130:	55                   	push   %ebp
80107131:	89 e5                	mov    %esp,%ebp
80107133:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80107136:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
8010713b:	85 c0                	test   %eax,%eax
8010713d:	75 07                	jne    80107146 <uartgetc+0x16>
    return -1;
8010713f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107144:	eb 2c                	jmp    80107172 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107146:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010714d:	e8 26 fe ff ff       	call   80106f78 <inb>
80107152:	0f b6 c0             	movzbl %al,%eax
80107155:	83 e0 01             	and    $0x1,%eax
80107158:	85 c0                	test   %eax,%eax
8010715a:	75 07                	jne    80107163 <uartgetc+0x33>
    return -1;
8010715c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107161:	eb 0f                	jmp    80107172 <uartgetc+0x42>
  return inb(COM1+0);
80107163:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010716a:	e8 09 fe ff ff       	call   80106f78 <inb>
8010716f:	0f b6 c0             	movzbl %al,%eax
}
80107172:	c9                   	leave  
80107173:	c3                   	ret    

80107174 <uartintr>:

void
uartintr(void)
{
80107174:	55                   	push   %ebp
80107175:	89 e5                	mov    %esp,%ebp
80107177:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
8010717a:	c7 04 24 30 71 10 80 	movl   $0x80107130,(%esp)
80107181:	e8 27 96 ff ff       	call   801007ad <consoleintr>
}
80107186:	c9                   	leave  
80107187:	c3                   	ret    

80107188 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107188:	6a 00                	push   $0x0
  pushl $0
8010718a:	6a 00                	push   $0x0
  jmp alltraps
8010718c:	e9 67 f9 ff ff       	jmp    80106af8 <alltraps>

80107191 <vector1>:
.globl vector1
vector1:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $1
80107193:	6a 01                	push   $0x1
  jmp alltraps
80107195:	e9 5e f9 ff ff       	jmp    80106af8 <alltraps>

8010719a <vector2>:
.globl vector2
vector2:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $2
8010719c:	6a 02                	push   $0x2
  jmp alltraps
8010719e:	e9 55 f9 ff ff       	jmp    80106af8 <alltraps>

801071a3 <vector3>:
.globl vector3
vector3:
  pushl $0
801071a3:	6a 00                	push   $0x0
  pushl $3
801071a5:	6a 03                	push   $0x3
  jmp alltraps
801071a7:	e9 4c f9 ff ff       	jmp    80106af8 <alltraps>

801071ac <vector4>:
.globl vector4
vector4:
  pushl $0
801071ac:	6a 00                	push   $0x0
  pushl $4
801071ae:	6a 04                	push   $0x4
  jmp alltraps
801071b0:	e9 43 f9 ff ff       	jmp    80106af8 <alltraps>

801071b5 <vector5>:
.globl vector5
vector5:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $5
801071b7:	6a 05                	push   $0x5
  jmp alltraps
801071b9:	e9 3a f9 ff ff       	jmp    80106af8 <alltraps>

801071be <vector6>:
.globl vector6
vector6:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $6
801071c0:	6a 06                	push   $0x6
  jmp alltraps
801071c2:	e9 31 f9 ff ff       	jmp    80106af8 <alltraps>

801071c7 <vector7>:
.globl vector7
vector7:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $7
801071c9:	6a 07                	push   $0x7
  jmp alltraps
801071cb:	e9 28 f9 ff ff       	jmp    80106af8 <alltraps>

801071d0 <vector8>:
.globl vector8
vector8:
  pushl $8
801071d0:	6a 08                	push   $0x8
  jmp alltraps
801071d2:	e9 21 f9 ff ff       	jmp    80106af8 <alltraps>

801071d7 <vector9>:
.globl vector9
vector9:
  pushl $0
801071d7:	6a 00                	push   $0x0
  pushl $9
801071d9:	6a 09                	push   $0x9
  jmp alltraps
801071db:	e9 18 f9 ff ff       	jmp    80106af8 <alltraps>

801071e0 <vector10>:
.globl vector10
vector10:
  pushl $10
801071e0:	6a 0a                	push   $0xa
  jmp alltraps
801071e2:	e9 11 f9 ff ff       	jmp    80106af8 <alltraps>

801071e7 <vector11>:
.globl vector11
vector11:
  pushl $11
801071e7:	6a 0b                	push   $0xb
  jmp alltraps
801071e9:	e9 0a f9 ff ff       	jmp    80106af8 <alltraps>

801071ee <vector12>:
.globl vector12
vector12:
  pushl $12
801071ee:	6a 0c                	push   $0xc
  jmp alltraps
801071f0:	e9 03 f9 ff ff       	jmp    80106af8 <alltraps>

801071f5 <vector13>:
.globl vector13
vector13:
  pushl $13
801071f5:	6a 0d                	push   $0xd
  jmp alltraps
801071f7:	e9 fc f8 ff ff       	jmp    80106af8 <alltraps>

801071fc <vector14>:
.globl vector14
vector14:
  pushl $14
801071fc:	6a 0e                	push   $0xe
  jmp alltraps
801071fe:	e9 f5 f8 ff ff       	jmp    80106af8 <alltraps>

80107203 <vector15>:
.globl vector15
vector15:
  pushl $0
80107203:	6a 00                	push   $0x0
  pushl $15
80107205:	6a 0f                	push   $0xf
  jmp alltraps
80107207:	e9 ec f8 ff ff       	jmp    80106af8 <alltraps>

8010720c <vector16>:
.globl vector16
vector16:
  pushl $0
8010720c:	6a 00                	push   $0x0
  pushl $16
8010720e:	6a 10                	push   $0x10
  jmp alltraps
80107210:	e9 e3 f8 ff ff       	jmp    80106af8 <alltraps>

80107215 <vector17>:
.globl vector17
vector17:
  pushl $17
80107215:	6a 11                	push   $0x11
  jmp alltraps
80107217:	e9 dc f8 ff ff       	jmp    80106af8 <alltraps>

8010721c <vector18>:
.globl vector18
vector18:
  pushl $0
8010721c:	6a 00                	push   $0x0
  pushl $18
8010721e:	6a 12                	push   $0x12
  jmp alltraps
80107220:	e9 d3 f8 ff ff       	jmp    80106af8 <alltraps>

80107225 <vector19>:
.globl vector19
vector19:
  pushl $0
80107225:	6a 00                	push   $0x0
  pushl $19
80107227:	6a 13                	push   $0x13
  jmp alltraps
80107229:	e9 ca f8 ff ff       	jmp    80106af8 <alltraps>

8010722e <vector20>:
.globl vector20
vector20:
  pushl $0
8010722e:	6a 00                	push   $0x0
  pushl $20
80107230:	6a 14                	push   $0x14
  jmp alltraps
80107232:	e9 c1 f8 ff ff       	jmp    80106af8 <alltraps>

80107237 <vector21>:
.globl vector21
vector21:
  pushl $0
80107237:	6a 00                	push   $0x0
  pushl $21
80107239:	6a 15                	push   $0x15
  jmp alltraps
8010723b:	e9 b8 f8 ff ff       	jmp    80106af8 <alltraps>

80107240 <vector22>:
.globl vector22
vector22:
  pushl $0
80107240:	6a 00                	push   $0x0
  pushl $22
80107242:	6a 16                	push   $0x16
  jmp alltraps
80107244:	e9 af f8 ff ff       	jmp    80106af8 <alltraps>

80107249 <vector23>:
.globl vector23
vector23:
  pushl $0
80107249:	6a 00                	push   $0x0
  pushl $23
8010724b:	6a 17                	push   $0x17
  jmp alltraps
8010724d:	e9 a6 f8 ff ff       	jmp    80106af8 <alltraps>

80107252 <vector24>:
.globl vector24
vector24:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $24
80107254:	6a 18                	push   $0x18
  jmp alltraps
80107256:	e9 9d f8 ff ff       	jmp    80106af8 <alltraps>

8010725b <vector25>:
.globl vector25
vector25:
  pushl $0
8010725b:	6a 00                	push   $0x0
  pushl $25
8010725d:	6a 19                	push   $0x19
  jmp alltraps
8010725f:	e9 94 f8 ff ff       	jmp    80106af8 <alltraps>

80107264 <vector26>:
.globl vector26
vector26:
  pushl $0
80107264:	6a 00                	push   $0x0
  pushl $26
80107266:	6a 1a                	push   $0x1a
  jmp alltraps
80107268:	e9 8b f8 ff ff       	jmp    80106af8 <alltraps>

8010726d <vector27>:
.globl vector27
vector27:
  pushl $0
8010726d:	6a 00                	push   $0x0
  pushl $27
8010726f:	6a 1b                	push   $0x1b
  jmp alltraps
80107271:	e9 82 f8 ff ff       	jmp    80106af8 <alltraps>

80107276 <vector28>:
.globl vector28
vector28:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $28
80107278:	6a 1c                	push   $0x1c
  jmp alltraps
8010727a:	e9 79 f8 ff ff       	jmp    80106af8 <alltraps>

8010727f <vector29>:
.globl vector29
vector29:
  pushl $0
8010727f:	6a 00                	push   $0x0
  pushl $29
80107281:	6a 1d                	push   $0x1d
  jmp alltraps
80107283:	e9 70 f8 ff ff       	jmp    80106af8 <alltraps>

80107288 <vector30>:
.globl vector30
vector30:
  pushl $0
80107288:	6a 00                	push   $0x0
  pushl $30
8010728a:	6a 1e                	push   $0x1e
  jmp alltraps
8010728c:	e9 67 f8 ff ff       	jmp    80106af8 <alltraps>

80107291 <vector31>:
.globl vector31
vector31:
  pushl $0
80107291:	6a 00                	push   $0x0
  pushl $31
80107293:	6a 1f                	push   $0x1f
  jmp alltraps
80107295:	e9 5e f8 ff ff       	jmp    80106af8 <alltraps>

8010729a <vector32>:
.globl vector32
vector32:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $32
8010729c:	6a 20                	push   $0x20
  jmp alltraps
8010729e:	e9 55 f8 ff ff       	jmp    80106af8 <alltraps>

801072a3 <vector33>:
.globl vector33
vector33:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $33
801072a5:	6a 21                	push   $0x21
  jmp alltraps
801072a7:	e9 4c f8 ff ff       	jmp    80106af8 <alltraps>

801072ac <vector34>:
.globl vector34
vector34:
  pushl $0
801072ac:	6a 00                	push   $0x0
  pushl $34
801072ae:	6a 22                	push   $0x22
  jmp alltraps
801072b0:	e9 43 f8 ff ff       	jmp    80106af8 <alltraps>

801072b5 <vector35>:
.globl vector35
vector35:
  pushl $0
801072b5:	6a 00                	push   $0x0
  pushl $35
801072b7:	6a 23                	push   $0x23
  jmp alltraps
801072b9:	e9 3a f8 ff ff       	jmp    80106af8 <alltraps>

801072be <vector36>:
.globl vector36
vector36:
  pushl $0
801072be:	6a 00                	push   $0x0
  pushl $36
801072c0:	6a 24                	push   $0x24
  jmp alltraps
801072c2:	e9 31 f8 ff ff       	jmp    80106af8 <alltraps>

801072c7 <vector37>:
.globl vector37
vector37:
  pushl $0
801072c7:	6a 00                	push   $0x0
  pushl $37
801072c9:	6a 25                	push   $0x25
  jmp alltraps
801072cb:	e9 28 f8 ff ff       	jmp    80106af8 <alltraps>

801072d0 <vector38>:
.globl vector38
vector38:
  pushl $0
801072d0:	6a 00                	push   $0x0
  pushl $38
801072d2:	6a 26                	push   $0x26
  jmp alltraps
801072d4:	e9 1f f8 ff ff       	jmp    80106af8 <alltraps>

801072d9 <vector39>:
.globl vector39
vector39:
  pushl $0
801072d9:	6a 00                	push   $0x0
  pushl $39
801072db:	6a 27                	push   $0x27
  jmp alltraps
801072dd:	e9 16 f8 ff ff       	jmp    80106af8 <alltraps>

801072e2 <vector40>:
.globl vector40
vector40:
  pushl $0
801072e2:	6a 00                	push   $0x0
  pushl $40
801072e4:	6a 28                	push   $0x28
  jmp alltraps
801072e6:	e9 0d f8 ff ff       	jmp    80106af8 <alltraps>

801072eb <vector41>:
.globl vector41
vector41:
  pushl $0
801072eb:	6a 00                	push   $0x0
  pushl $41
801072ed:	6a 29                	push   $0x29
  jmp alltraps
801072ef:	e9 04 f8 ff ff       	jmp    80106af8 <alltraps>

801072f4 <vector42>:
.globl vector42
vector42:
  pushl $0
801072f4:	6a 00                	push   $0x0
  pushl $42
801072f6:	6a 2a                	push   $0x2a
  jmp alltraps
801072f8:	e9 fb f7 ff ff       	jmp    80106af8 <alltraps>

801072fd <vector43>:
.globl vector43
vector43:
  pushl $0
801072fd:	6a 00                	push   $0x0
  pushl $43
801072ff:	6a 2b                	push   $0x2b
  jmp alltraps
80107301:	e9 f2 f7 ff ff       	jmp    80106af8 <alltraps>

80107306 <vector44>:
.globl vector44
vector44:
  pushl $0
80107306:	6a 00                	push   $0x0
  pushl $44
80107308:	6a 2c                	push   $0x2c
  jmp alltraps
8010730a:	e9 e9 f7 ff ff       	jmp    80106af8 <alltraps>

8010730f <vector45>:
.globl vector45
vector45:
  pushl $0
8010730f:	6a 00                	push   $0x0
  pushl $45
80107311:	6a 2d                	push   $0x2d
  jmp alltraps
80107313:	e9 e0 f7 ff ff       	jmp    80106af8 <alltraps>

80107318 <vector46>:
.globl vector46
vector46:
  pushl $0
80107318:	6a 00                	push   $0x0
  pushl $46
8010731a:	6a 2e                	push   $0x2e
  jmp alltraps
8010731c:	e9 d7 f7 ff ff       	jmp    80106af8 <alltraps>

80107321 <vector47>:
.globl vector47
vector47:
  pushl $0
80107321:	6a 00                	push   $0x0
  pushl $47
80107323:	6a 2f                	push   $0x2f
  jmp alltraps
80107325:	e9 ce f7 ff ff       	jmp    80106af8 <alltraps>

8010732a <vector48>:
.globl vector48
vector48:
  pushl $0
8010732a:	6a 00                	push   $0x0
  pushl $48
8010732c:	6a 30                	push   $0x30
  jmp alltraps
8010732e:	e9 c5 f7 ff ff       	jmp    80106af8 <alltraps>

80107333 <vector49>:
.globl vector49
vector49:
  pushl $0
80107333:	6a 00                	push   $0x0
  pushl $49
80107335:	6a 31                	push   $0x31
  jmp alltraps
80107337:	e9 bc f7 ff ff       	jmp    80106af8 <alltraps>

8010733c <vector50>:
.globl vector50
vector50:
  pushl $0
8010733c:	6a 00                	push   $0x0
  pushl $50
8010733e:	6a 32                	push   $0x32
  jmp alltraps
80107340:	e9 b3 f7 ff ff       	jmp    80106af8 <alltraps>

80107345 <vector51>:
.globl vector51
vector51:
  pushl $0
80107345:	6a 00                	push   $0x0
  pushl $51
80107347:	6a 33                	push   $0x33
  jmp alltraps
80107349:	e9 aa f7 ff ff       	jmp    80106af8 <alltraps>

8010734e <vector52>:
.globl vector52
vector52:
  pushl $0
8010734e:	6a 00                	push   $0x0
  pushl $52
80107350:	6a 34                	push   $0x34
  jmp alltraps
80107352:	e9 a1 f7 ff ff       	jmp    80106af8 <alltraps>

80107357 <vector53>:
.globl vector53
vector53:
  pushl $0
80107357:	6a 00                	push   $0x0
  pushl $53
80107359:	6a 35                	push   $0x35
  jmp alltraps
8010735b:	e9 98 f7 ff ff       	jmp    80106af8 <alltraps>

80107360 <vector54>:
.globl vector54
vector54:
  pushl $0
80107360:	6a 00                	push   $0x0
  pushl $54
80107362:	6a 36                	push   $0x36
  jmp alltraps
80107364:	e9 8f f7 ff ff       	jmp    80106af8 <alltraps>

80107369 <vector55>:
.globl vector55
vector55:
  pushl $0
80107369:	6a 00                	push   $0x0
  pushl $55
8010736b:	6a 37                	push   $0x37
  jmp alltraps
8010736d:	e9 86 f7 ff ff       	jmp    80106af8 <alltraps>

80107372 <vector56>:
.globl vector56
vector56:
  pushl $0
80107372:	6a 00                	push   $0x0
  pushl $56
80107374:	6a 38                	push   $0x38
  jmp alltraps
80107376:	e9 7d f7 ff ff       	jmp    80106af8 <alltraps>

8010737b <vector57>:
.globl vector57
vector57:
  pushl $0
8010737b:	6a 00                	push   $0x0
  pushl $57
8010737d:	6a 39                	push   $0x39
  jmp alltraps
8010737f:	e9 74 f7 ff ff       	jmp    80106af8 <alltraps>

80107384 <vector58>:
.globl vector58
vector58:
  pushl $0
80107384:	6a 00                	push   $0x0
  pushl $58
80107386:	6a 3a                	push   $0x3a
  jmp alltraps
80107388:	e9 6b f7 ff ff       	jmp    80106af8 <alltraps>

8010738d <vector59>:
.globl vector59
vector59:
  pushl $0
8010738d:	6a 00                	push   $0x0
  pushl $59
8010738f:	6a 3b                	push   $0x3b
  jmp alltraps
80107391:	e9 62 f7 ff ff       	jmp    80106af8 <alltraps>

80107396 <vector60>:
.globl vector60
vector60:
  pushl $0
80107396:	6a 00                	push   $0x0
  pushl $60
80107398:	6a 3c                	push   $0x3c
  jmp alltraps
8010739a:	e9 59 f7 ff ff       	jmp    80106af8 <alltraps>

8010739f <vector61>:
.globl vector61
vector61:
  pushl $0
8010739f:	6a 00                	push   $0x0
  pushl $61
801073a1:	6a 3d                	push   $0x3d
  jmp alltraps
801073a3:	e9 50 f7 ff ff       	jmp    80106af8 <alltraps>

801073a8 <vector62>:
.globl vector62
vector62:
  pushl $0
801073a8:	6a 00                	push   $0x0
  pushl $62
801073aa:	6a 3e                	push   $0x3e
  jmp alltraps
801073ac:	e9 47 f7 ff ff       	jmp    80106af8 <alltraps>

801073b1 <vector63>:
.globl vector63
vector63:
  pushl $0
801073b1:	6a 00                	push   $0x0
  pushl $63
801073b3:	6a 3f                	push   $0x3f
  jmp alltraps
801073b5:	e9 3e f7 ff ff       	jmp    80106af8 <alltraps>

801073ba <vector64>:
.globl vector64
vector64:
  pushl $0
801073ba:	6a 00                	push   $0x0
  pushl $64
801073bc:	6a 40                	push   $0x40
  jmp alltraps
801073be:	e9 35 f7 ff ff       	jmp    80106af8 <alltraps>

801073c3 <vector65>:
.globl vector65
vector65:
  pushl $0
801073c3:	6a 00                	push   $0x0
  pushl $65
801073c5:	6a 41                	push   $0x41
  jmp alltraps
801073c7:	e9 2c f7 ff ff       	jmp    80106af8 <alltraps>

801073cc <vector66>:
.globl vector66
vector66:
  pushl $0
801073cc:	6a 00                	push   $0x0
  pushl $66
801073ce:	6a 42                	push   $0x42
  jmp alltraps
801073d0:	e9 23 f7 ff ff       	jmp    80106af8 <alltraps>

801073d5 <vector67>:
.globl vector67
vector67:
  pushl $0
801073d5:	6a 00                	push   $0x0
  pushl $67
801073d7:	6a 43                	push   $0x43
  jmp alltraps
801073d9:	e9 1a f7 ff ff       	jmp    80106af8 <alltraps>

801073de <vector68>:
.globl vector68
vector68:
  pushl $0
801073de:	6a 00                	push   $0x0
  pushl $68
801073e0:	6a 44                	push   $0x44
  jmp alltraps
801073e2:	e9 11 f7 ff ff       	jmp    80106af8 <alltraps>

801073e7 <vector69>:
.globl vector69
vector69:
  pushl $0
801073e7:	6a 00                	push   $0x0
  pushl $69
801073e9:	6a 45                	push   $0x45
  jmp alltraps
801073eb:	e9 08 f7 ff ff       	jmp    80106af8 <alltraps>

801073f0 <vector70>:
.globl vector70
vector70:
  pushl $0
801073f0:	6a 00                	push   $0x0
  pushl $70
801073f2:	6a 46                	push   $0x46
  jmp alltraps
801073f4:	e9 ff f6 ff ff       	jmp    80106af8 <alltraps>

801073f9 <vector71>:
.globl vector71
vector71:
  pushl $0
801073f9:	6a 00                	push   $0x0
  pushl $71
801073fb:	6a 47                	push   $0x47
  jmp alltraps
801073fd:	e9 f6 f6 ff ff       	jmp    80106af8 <alltraps>

80107402 <vector72>:
.globl vector72
vector72:
  pushl $0
80107402:	6a 00                	push   $0x0
  pushl $72
80107404:	6a 48                	push   $0x48
  jmp alltraps
80107406:	e9 ed f6 ff ff       	jmp    80106af8 <alltraps>

8010740b <vector73>:
.globl vector73
vector73:
  pushl $0
8010740b:	6a 00                	push   $0x0
  pushl $73
8010740d:	6a 49                	push   $0x49
  jmp alltraps
8010740f:	e9 e4 f6 ff ff       	jmp    80106af8 <alltraps>

80107414 <vector74>:
.globl vector74
vector74:
  pushl $0
80107414:	6a 00                	push   $0x0
  pushl $74
80107416:	6a 4a                	push   $0x4a
  jmp alltraps
80107418:	e9 db f6 ff ff       	jmp    80106af8 <alltraps>

8010741d <vector75>:
.globl vector75
vector75:
  pushl $0
8010741d:	6a 00                	push   $0x0
  pushl $75
8010741f:	6a 4b                	push   $0x4b
  jmp alltraps
80107421:	e9 d2 f6 ff ff       	jmp    80106af8 <alltraps>

80107426 <vector76>:
.globl vector76
vector76:
  pushl $0
80107426:	6a 00                	push   $0x0
  pushl $76
80107428:	6a 4c                	push   $0x4c
  jmp alltraps
8010742a:	e9 c9 f6 ff ff       	jmp    80106af8 <alltraps>

8010742f <vector77>:
.globl vector77
vector77:
  pushl $0
8010742f:	6a 00                	push   $0x0
  pushl $77
80107431:	6a 4d                	push   $0x4d
  jmp alltraps
80107433:	e9 c0 f6 ff ff       	jmp    80106af8 <alltraps>

80107438 <vector78>:
.globl vector78
vector78:
  pushl $0
80107438:	6a 00                	push   $0x0
  pushl $78
8010743a:	6a 4e                	push   $0x4e
  jmp alltraps
8010743c:	e9 b7 f6 ff ff       	jmp    80106af8 <alltraps>

80107441 <vector79>:
.globl vector79
vector79:
  pushl $0
80107441:	6a 00                	push   $0x0
  pushl $79
80107443:	6a 4f                	push   $0x4f
  jmp alltraps
80107445:	e9 ae f6 ff ff       	jmp    80106af8 <alltraps>

8010744a <vector80>:
.globl vector80
vector80:
  pushl $0
8010744a:	6a 00                	push   $0x0
  pushl $80
8010744c:	6a 50                	push   $0x50
  jmp alltraps
8010744e:	e9 a5 f6 ff ff       	jmp    80106af8 <alltraps>

80107453 <vector81>:
.globl vector81
vector81:
  pushl $0
80107453:	6a 00                	push   $0x0
  pushl $81
80107455:	6a 51                	push   $0x51
  jmp alltraps
80107457:	e9 9c f6 ff ff       	jmp    80106af8 <alltraps>

8010745c <vector82>:
.globl vector82
vector82:
  pushl $0
8010745c:	6a 00                	push   $0x0
  pushl $82
8010745e:	6a 52                	push   $0x52
  jmp alltraps
80107460:	e9 93 f6 ff ff       	jmp    80106af8 <alltraps>

80107465 <vector83>:
.globl vector83
vector83:
  pushl $0
80107465:	6a 00                	push   $0x0
  pushl $83
80107467:	6a 53                	push   $0x53
  jmp alltraps
80107469:	e9 8a f6 ff ff       	jmp    80106af8 <alltraps>

8010746e <vector84>:
.globl vector84
vector84:
  pushl $0
8010746e:	6a 00                	push   $0x0
  pushl $84
80107470:	6a 54                	push   $0x54
  jmp alltraps
80107472:	e9 81 f6 ff ff       	jmp    80106af8 <alltraps>

80107477 <vector85>:
.globl vector85
vector85:
  pushl $0
80107477:	6a 00                	push   $0x0
  pushl $85
80107479:	6a 55                	push   $0x55
  jmp alltraps
8010747b:	e9 78 f6 ff ff       	jmp    80106af8 <alltraps>

80107480 <vector86>:
.globl vector86
vector86:
  pushl $0
80107480:	6a 00                	push   $0x0
  pushl $86
80107482:	6a 56                	push   $0x56
  jmp alltraps
80107484:	e9 6f f6 ff ff       	jmp    80106af8 <alltraps>

80107489 <vector87>:
.globl vector87
vector87:
  pushl $0
80107489:	6a 00                	push   $0x0
  pushl $87
8010748b:	6a 57                	push   $0x57
  jmp alltraps
8010748d:	e9 66 f6 ff ff       	jmp    80106af8 <alltraps>

80107492 <vector88>:
.globl vector88
vector88:
  pushl $0
80107492:	6a 00                	push   $0x0
  pushl $88
80107494:	6a 58                	push   $0x58
  jmp alltraps
80107496:	e9 5d f6 ff ff       	jmp    80106af8 <alltraps>

8010749b <vector89>:
.globl vector89
vector89:
  pushl $0
8010749b:	6a 00                	push   $0x0
  pushl $89
8010749d:	6a 59                	push   $0x59
  jmp alltraps
8010749f:	e9 54 f6 ff ff       	jmp    80106af8 <alltraps>

801074a4 <vector90>:
.globl vector90
vector90:
  pushl $0
801074a4:	6a 00                	push   $0x0
  pushl $90
801074a6:	6a 5a                	push   $0x5a
  jmp alltraps
801074a8:	e9 4b f6 ff ff       	jmp    80106af8 <alltraps>

801074ad <vector91>:
.globl vector91
vector91:
  pushl $0
801074ad:	6a 00                	push   $0x0
  pushl $91
801074af:	6a 5b                	push   $0x5b
  jmp alltraps
801074b1:	e9 42 f6 ff ff       	jmp    80106af8 <alltraps>

801074b6 <vector92>:
.globl vector92
vector92:
  pushl $0
801074b6:	6a 00                	push   $0x0
  pushl $92
801074b8:	6a 5c                	push   $0x5c
  jmp alltraps
801074ba:	e9 39 f6 ff ff       	jmp    80106af8 <alltraps>

801074bf <vector93>:
.globl vector93
vector93:
  pushl $0
801074bf:	6a 00                	push   $0x0
  pushl $93
801074c1:	6a 5d                	push   $0x5d
  jmp alltraps
801074c3:	e9 30 f6 ff ff       	jmp    80106af8 <alltraps>

801074c8 <vector94>:
.globl vector94
vector94:
  pushl $0
801074c8:	6a 00                	push   $0x0
  pushl $94
801074ca:	6a 5e                	push   $0x5e
  jmp alltraps
801074cc:	e9 27 f6 ff ff       	jmp    80106af8 <alltraps>

801074d1 <vector95>:
.globl vector95
vector95:
  pushl $0
801074d1:	6a 00                	push   $0x0
  pushl $95
801074d3:	6a 5f                	push   $0x5f
  jmp alltraps
801074d5:	e9 1e f6 ff ff       	jmp    80106af8 <alltraps>

801074da <vector96>:
.globl vector96
vector96:
  pushl $0
801074da:	6a 00                	push   $0x0
  pushl $96
801074dc:	6a 60                	push   $0x60
  jmp alltraps
801074de:	e9 15 f6 ff ff       	jmp    80106af8 <alltraps>

801074e3 <vector97>:
.globl vector97
vector97:
  pushl $0
801074e3:	6a 00                	push   $0x0
  pushl $97
801074e5:	6a 61                	push   $0x61
  jmp alltraps
801074e7:	e9 0c f6 ff ff       	jmp    80106af8 <alltraps>

801074ec <vector98>:
.globl vector98
vector98:
  pushl $0
801074ec:	6a 00                	push   $0x0
  pushl $98
801074ee:	6a 62                	push   $0x62
  jmp alltraps
801074f0:	e9 03 f6 ff ff       	jmp    80106af8 <alltraps>

801074f5 <vector99>:
.globl vector99
vector99:
  pushl $0
801074f5:	6a 00                	push   $0x0
  pushl $99
801074f7:	6a 63                	push   $0x63
  jmp alltraps
801074f9:	e9 fa f5 ff ff       	jmp    80106af8 <alltraps>

801074fe <vector100>:
.globl vector100
vector100:
  pushl $0
801074fe:	6a 00                	push   $0x0
  pushl $100
80107500:	6a 64                	push   $0x64
  jmp alltraps
80107502:	e9 f1 f5 ff ff       	jmp    80106af8 <alltraps>

80107507 <vector101>:
.globl vector101
vector101:
  pushl $0
80107507:	6a 00                	push   $0x0
  pushl $101
80107509:	6a 65                	push   $0x65
  jmp alltraps
8010750b:	e9 e8 f5 ff ff       	jmp    80106af8 <alltraps>

80107510 <vector102>:
.globl vector102
vector102:
  pushl $0
80107510:	6a 00                	push   $0x0
  pushl $102
80107512:	6a 66                	push   $0x66
  jmp alltraps
80107514:	e9 df f5 ff ff       	jmp    80106af8 <alltraps>

80107519 <vector103>:
.globl vector103
vector103:
  pushl $0
80107519:	6a 00                	push   $0x0
  pushl $103
8010751b:	6a 67                	push   $0x67
  jmp alltraps
8010751d:	e9 d6 f5 ff ff       	jmp    80106af8 <alltraps>

80107522 <vector104>:
.globl vector104
vector104:
  pushl $0
80107522:	6a 00                	push   $0x0
  pushl $104
80107524:	6a 68                	push   $0x68
  jmp alltraps
80107526:	e9 cd f5 ff ff       	jmp    80106af8 <alltraps>

8010752b <vector105>:
.globl vector105
vector105:
  pushl $0
8010752b:	6a 00                	push   $0x0
  pushl $105
8010752d:	6a 69                	push   $0x69
  jmp alltraps
8010752f:	e9 c4 f5 ff ff       	jmp    80106af8 <alltraps>

80107534 <vector106>:
.globl vector106
vector106:
  pushl $0
80107534:	6a 00                	push   $0x0
  pushl $106
80107536:	6a 6a                	push   $0x6a
  jmp alltraps
80107538:	e9 bb f5 ff ff       	jmp    80106af8 <alltraps>

8010753d <vector107>:
.globl vector107
vector107:
  pushl $0
8010753d:	6a 00                	push   $0x0
  pushl $107
8010753f:	6a 6b                	push   $0x6b
  jmp alltraps
80107541:	e9 b2 f5 ff ff       	jmp    80106af8 <alltraps>

80107546 <vector108>:
.globl vector108
vector108:
  pushl $0
80107546:	6a 00                	push   $0x0
  pushl $108
80107548:	6a 6c                	push   $0x6c
  jmp alltraps
8010754a:	e9 a9 f5 ff ff       	jmp    80106af8 <alltraps>

8010754f <vector109>:
.globl vector109
vector109:
  pushl $0
8010754f:	6a 00                	push   $0x0
  pushl $109
80107551:	6a 6d                	push   $0x6d
  jmp alltraps
80107553:	e9 a0 f5 ff ff       	jmp    80106af8 <alltraps>

80107558 <vector110>:
.globl vector110
vector110:
  pushl $0
80107558:	6a 00                	push   $0x0
  pushl $110
8010755a:	6a 6e                	push   $0x6e
  jmp alltraps
8010755c:	e9 97 f5 ff ff       	jmp    80106af8 <alltraps>

80107561 <vector111>:
.globl vector111
vector111:
  pushl $0
80107561:	6a 00                	push   $0x0
  pushl $111
80107563:	6a 6f                	push   $0x6f
  jmp alltraps
80107565:	e9 8e f5 ff ff       	jmp    80106af8 <alltraps>

8010756a <vector112>:
.globl vector112
vector112:
  pushl $0
8010756a:	6a 00                	push   $0x0
  pushl $112
8010756c:	6a 70                	push   $0x70
  jmp alltraps
8010756e:	e9 85 f5 ff ff       	jmp    80106af8 <alltraps>

80107573 <vector113>:
.globl vector113
vector113:
  pushl $0
80107573:	6a 00                	push   $0x0
  pushl $113
80107575:	6a 71                	push   $0x71
  jmp alltraps
80107577:	e9 7c f5 ff ff       	jmp    80106af8 <alltraps>

8010757c <vector114>:
.globl vector114
vector114:
  pushl $0
8010757c:	6a 00                	push   $0x0
  pushl $114
8010757e:	6a 72                	push   $0x72
  jmp alltraps
80107580:	e9 73 f5 ff ff       	jmp    80106af8 <alltraps>

80107585 <vector115>:
.globl vector115
vector115:
  pushl $0
80107585:	6a 00                	push   $0x0
  pushl $115
80107587:	6a 73                	push   $0x73
  jmp alltraps
80107589:	e9 6a f5 ff ff       	jmp    80106af8 <alltraps>

8010758e <vector116>:
.globl vector116
vector116:
  pushl $0
8010758e:	6a 00                	push   $0x0
  pushl $116
80107590:	6a 74                	push   $0x74
  jmp alltraps
80107592:	e9 61 f5 ff ff       	jmp    80106af8 <alltraps>

80107597 <vector117>:
.globl vector117
vector117:
  pushl $0
80107597:	6a 00                	push   $0x0
  pushl $117
80107599:	6a 75                	push   $0x75
  jmp alltraps
8010759b:	e9 58 f5 ff ff       	jmp    80106af8 <alltraps>

801075a0 <vector118>:
.globl vector118
vector118:
  pushl $0
801075a0:	6a 00                	push   $0x0
  pushl $118
801075a2:	6a 76                	push   $0x76
  jmp alltraps
801075a4:	e9 4f f5 ff ff       	jmp    80106af8 <alltraps>

801075a9 <vector119>:
.globl vector119
vector119:
  pushl $0
801075a9:	6a 00                	push   $0x0
  pushl $119
801075ab:	6a 77                	push   $0x77
  jmp alltraps
801075ad:	e9 46 f5 ff ff       	jmp    80106af8 <alltraps>

801075b2 <vector120>:
.globl vector120
vector120:
  pushl $0
801075b2:	6a 00                	push   $0x0
  pushl $120
801075b4:	6a 78                	push   $0x78
  jmp alltraps
801075b6:	e9 3d f5 ff ff       	jmp    80106af8 <alltraps>

801075bb <vector121>:
.globl vector121
vector121:
  pushl $0
801075bb:	6a 00                	push   $0x0
  pushl $121
801075bd:	6a 79                	push   $0x79
  jmp alltraps
801075bf:	e9 34 f5 ff ff       	jmp    80106af8 <alltraps>

801075c4 <vector122>:
.globl vector122
vector122:
  pushl $0
801075c4:	6a 00                	push   $0x0
  pushl $122
801075c6:	6a 7a                	push   $0x7a
  jmp alltraps
801075c8:	e9 2b f5 ff ff       	jmp    80106af8 <alltraps>

801075cd <vector123>:
.globl vector123
vector123:
  pushl $0
801075cd:	6a 00                	push   $0x0
  pushl $123
801075cf:	6a 7b                	push   $0x7b
  jmp alltraps
801075d1:	e9 22 f5 ff ff       	jmp    80106af8 <alltraps>

801075d6 <vector124>:
.globl vector124
vector124:
  pushl $0
801075d6:	6a 00                	push   $0x0
  pushl $124
801075d8:	6a 7c                	push   $0x7c
  jmp alltraps
801075da:	e9 19 f5 ff ff       	jmp    80106af8 <alltraps>

801075df <vector125>:
.globl vector125
vector125:
  pushl $0
801075df:	6a 00                	push   $0x0
  pushl $125
801075e1:	6a 7d                	push   $0x7d
  jmp alltraps
801075e3:	e9 10 f5 ff ff       	jmp    80106af8 <alltraps>

801075e8 <vector126>:
.globl vector126
vector126:
  pushl $0
801075e8:	6a 00                	push   $0x0
  pushl $126
801075ea:	6a 7e                	push   $0x7e
  jmp alltraps
801075ec:	e9 07 f5 ff ff       	jmp    80106af8 <alltraps>

801075f1 <vector127>:
.globl vector127
vector127:
  pushl $0
801075f1:	6a 00                	push   $0x0
  pushl $127
801075f3:	6a 7f                	push   $0x7f
  jmp alltraps
801075f5:	e9 fe f4 ff ff       	jmp    80106af8 <alltraps>

801075fa <vector128>:
.globl vector128
vector128:
  pushl $0
801075fa:	6a 00                	push   $0x0
  pushl $128
801075fc:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107601:	e9 f2 f4 ff ff       	jmp    80106af8 <alltraps>

80107606 <vector129>:
.globl vector129
vector129:
  pushl $0
80107606:	6a 00                	push   $0x0
  pushl $129
80107608:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010760d:	e9 e6 f4 ff ff       	jmp    80106af8 <alltraps>

80107612 <vector130>:
.globl vector130
vector130:
  pushl $0
80107612:	6a 00                	push   $0x0
  pushl $130
80107614:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107619:	e9 da f4 ff ff       	jmp    80106af8 <alltraps>

8010761e <vector131>:
.globl vector131
vector131:
  pushl $0
8010761e:	6a 00                	push   $0x0
  pushl $131
80107620:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107625:	e9 ce f4 ff ff       	jmp    80106af8 <alltraps>

8010762a <vector132>:
.globl vector132
vector132:
  pushl $0
8010762a:	6a 00                	push   $0x0
  pushl $132
8010762c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107631:	e9 c2 f4 ff ff       	jmp    80106af8 <alltraps>

80107636 <vector133>:
.globl vector133
vector133:
  pushl $0
80107636:	6a 00                	push   $0x0
  pushl $133
80107638:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010763d:	e9 b6 f4 ff ff       	jmp    80106af8 <alltraps>

80107642 <vector134>:
.globl vector134
vector134:
  pushl $0
80107642:	6a 00                	push   $0x0
  pushl $134
80107644:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107649:	e9 aa f4 ff ff       	jmp    80106af8 <alltraps>

8010764e <vector135>:
.globl vector135
vector135:
  pushl $0
8010764e:	6a 00                	push   $0x0
  pushl $135
80107650:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107655:	e9 9e f4 ff ff       	jmp    80106af8 <alltraps>

8010765a <vector136>:
.globl vector136
vector136:
  pushl $0
8010765a:	6a 00                	push   $0x0
  pushl $136
8010765c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107661:	e9 92 f4 ff ff       	jmp    80106af8 <alltraps>

80107666 <vector137>:
.globl vector137
vector137:
  pushl $0
80107666:	6a 00                	push   $0x0
  pushl $137
80107668:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010766d:	e9 86 f4 ff ff       	jmp    80106af8 <alltraps>

80107672 <vector138>:
.globl vector138
vector138:
  pushl $0
80107672:	6a 00                	push   $0x0
  pushl $138
80107674:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107679:	e9 7a f4 ff ff       	jmp    80106af8 <alltraps>

8010767e <vector139>:
.globl vector139
vector139:
  pushl $0
8010767e:	6a 00                	push   $0x0
  pushl $139
80107680:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107685:	e9 6e f4 ff ff       	jmp    80106af8 <alltraps>

8010768a <vector140>:
.globl vector140
vector140:
  pushl $0
8010768a:	6a 00                	push   $0x0
  pushl $140
8010768c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107691:	e9 62 f4 ff ff       	jmp    80106af8 <alltraps>

80107696 <vector141>:
.globl vector141
vector141:
  pushl $0
80107696:	6a 00                	push   $0x0
  pushl $141
80107698:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010769d:	e9 56 f4 ff ff       	jmp    80106af8 <alltraps>

801076a2 <vector142>:
.globl vector142
vector142:
  pushl $0
801076a2:	6a 00                	push   $0x0
  pushl $142
801076a4:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801076a9:	e9 4a f4 ff ff       	jmp    80106af8 <alltraps>

801076ae <vector143>:
.globl vector143
vector143:
  pushl $0
801076ae:	6a 00                	push   $0x0
  pushl $143
801076b0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801076b5:	e9 3e f4 ff ff       	jmp    80106af8 <alltraps>

801076ba <vector144>:
.globl vector144
vector144:
  pushl $0
801076ba:	6a 00                	push   $0x0
  pushl $144
801076bc:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801076c1:	e9 32 f4 ff ff       	jmp    80106af8 <alltraps>

801076c6 <vector145>:
.globl vector145
vector145:
  pushl $0
801076c6:	6a 00                	push   $0x0
  pushl $145
801076c8:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801076cd:	e9 26 f4 ff ff       	jmp    80106af8 <alltraps>

801076d2 <vector146>:
.globl vector146
vector146:
  pushl $0
801076d2:	6a 00                	push   $0x0
  pushl $146
801076d4:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801076d9:	e9 1a f4 ff ff       	jmp    80106af8 <alltraps>

801076de <vector147>:
.globl vector147
vector147:
  pushl $0
801076de:	6a 00                	push   $0x0
  pushl $147
801076e0:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801076e5:	e9 0e f4 ff ff       	jmp    80106af8 <alltraps>

801076ea <vector148>:
.globl vector148
vector148:
  pushl $0
801076ea:	6a 00                	push   $0x0
  pushl $148
801076ec:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801076f1:	e9 02 f4 ff ff       	jmp    80106af8 <alltraps>

801076f6 <vector149>:
.globl vector149
vector149:
  pushl $0
801076f6:	6a 00                	push   $0x0
  pushl $149
801076f8:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801076fd:	e9 f6 f3 ff ff       	jmp    80106af8 <alltraps>

80107702 <vector150>:
.globl vector150
vector150:
  pushl $0
80107702:	6a 00                	push   $0x0
  pushl $150
80107704:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107709:	e9 ea f3 ff ff       	jmp    80106af8 <alltraps>

8010770e <vector151>:
.globl vector151
vector151:
  pushl $0
8010770e:	6a 00                	push   $0x0
  pushl $151
80107710:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107715:	e9 de f3 ff ff       	jmp    80106af8 <alltraps>

8010771a <vector152>:
.globl vector152
vector152:
  pushl $0
8010771a:	6a 00                	push   $0x0
  pushl $152
8010771c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107721:	e9 d2 f3 ff ff       	jmp    80106af8 <alltraps>

80107726 <vector153>:
.globl vector153
vector153:
  pushl $0
80107726:	6a 00                	push   $0x0
  pushl $153
80107728:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010772d:	e9 c6 f3 ff ff       	jmp    80106af8 <alltraps>

80107732 <vector154>:
.globl vector154
vector154:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $154
80107734:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107739:	e9 ba f3 ff ff       	jmp    80106af8 <alltraps>

8010773e <vector155>:
.globl vector155
vector155:
  pushl $0
8010773e:	6a 00                	push   $0x0
  pushl $155
80107740:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107745:	e9 ae f3 ff ff       	jmp    80106af8 <alltraps>

8010774a <vector156>:
.globl vector156
vector156:
  pushl $0
8010774a:	6a 00                	push   $0x0
  pushl $156
8010774c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107751:	e9 a2 f3 ff ff       	jmp    80106af8 <alltraps>

80107756 <vector157>:
.globl vector157
vector157:
  pushl $0
80107756:	6a 00                	push   $0x0
  pushl $157
80107758:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010775d:	e9 96 f3 ff ff       	jmp    80106af8 <alltraps>

80107762 <vector158>:
.globl vector158
vector158:
  pushl $0
80107762:	6a 00                	push   $0x0
  pushl $158
80107764:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107769:	e9 8a f3 ff ff       	jmp    80106af8 <alltraps>

8010776e <vector159>:
.globl vector159
vector159:
  pushl $0
8010776e:	6a 00                	push   $0x0
  pushl $159
80107770:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107775:	e9 7e f3 ff ff       	jmp    80106af8 <alltraps>

8010777a <vector160>:
.globl vector160
vector160:
  pushl $0
8010777a:	6a 00                	push   $0x0
  pushl $160
8010777c:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107781:	e9 72 f3 ff ff       	jmp    80106af8 <alltraps>

80107786 <vector161>:
.globl vector161
vector161:
  pushl $0
80107786:	6a 00                	push   $0x0
  pushl $161
80107788:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010778d:	e9 66 f3 ff ff       	jmp    80106af8 <alltraps>

80107792 <vector162>:
.globl vector162
vector162:
  pushl $0
80107792:	6a 00                	push   $0x0
  pushl $162
80107794:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107799:	e9 5a f3 ff ff       	jmp    80106af8 <alltraps>

8010779e <vector163>:
.globl vector163
vector163:
  pushl $0
8010779e:	6a 00                	push   $0x0
  pushl $163
801077a0:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801077a5:	e9 4e f3 ff ff       	jmp    80106af8 <alltraps>

801077aa <vector164>:
.globl vector164
vector164:
  pushl $0
801077aa:	6a 00                	push   $0x0
  pushl $164
801077ac:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801077b1:	e9 42 f3 ff ff       	jmp    80106af8 <alltraps>

801077b6 <vector165>:
.globl vector165
vector165:
  pushl $0
801077b6:	6a 00                	push   $0x0
  pushl $165
801077b8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801077bd:	e9 36 f3 ff ff       	jmp    80106af8 <alltraps>

801077c2 <vector166>:
.globl vector166
vector166:
  pushl $0
801077c2:	6a 00                	push   $0x0
  pushl $166
801077c4:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801077c9:	e9 2a f3 ff ff       	jmp    80106af8 <alltraps>

801077ce <vector167>:
.globl vector167
vector167:
  pushl $0
801077ce:	6a 00                	push   $0x0
  pushl $167
801077d0:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801077d5:	e9 1e f3 ff ff       	jmp    80106af8 <alltraps>

801077da <vector168>:
.globl vector168
vector168:
  pushl $0
801077da:	6a 00                	push   $0x0
  pushl $168
801077dc:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801077e1:	e9 12 f3 ff ff       	jmp    80106af8 <alltraps>

801077e6 <vector169>:
.globl vector169
vector169:
  pushl $0
801077e6:	6a 00                	push   $0x0
  pushl $169
801077e8:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801077ed:	e9 06 f3 ff ff       	jmp    80106af8 <alltraps>

801077f2 <vector170>:
.globl vector170
vector170:
  pushl $0
801077f2:	6a 00                	push   $0x0
  pushl $170
801077f4:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801077f9:	e9 fa f2 ff ff       	jmp    80106af8 <alltraps>

801077fe <vector171>:
.globl vector171
vector171:
  pushl $0
801077fe:	6a 00                	push   $0x0
  pushl $171
80107800:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107805:	e9 ee f2 ff ff       	jmp    80106af8 <alltraps>

8010780a <vector172>:
.globl vector172
vector172:
  pushl $0
8010780a:	6a 00                	push   $0x0
  pushl $172
8010780c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107811:	e9 e2 f2 ff ff       	jmp    80106af8 <alltraps>

80107816 <vector173>:
.globl vector173
vector173:
  pushl $0
80107816:	6a 00                	push   $0x0
  pushl $173
80107818:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010781d:	e9 d6 f2 ff ff       	jmp    80106af8 <alltraps>

80107822 <vector174>:
.globl vector174
vector174:
  pushl $0
80107822:	6a 00                	push   $0x0
  pushl $174
80107824:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107829:	e9 ca f2 ff ff       	jmp    80106af8 <alltraps>

8010782e <vector175>:
.globl vector175
vector175:
  pushl $0
8010782e:	6a 00                	push   $0x0
  pushl $175
80107830:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107835:	e9 be f2 ff ff       	jmp    80106af8 <alltraps>

8010783a <vector176>:
.globl vector176
vector176:
  pushl $0
8010783a:	6a 00                	push   $0x0
  pushl $176
8010783c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107841:	e9 b2 f2 ff ff       	jmp    80106af8 <alltraps>

80107846 <vector177>:
.globl vector177
vector177:
  pushl $0
80107846:	6a 00                	push   $0x0
  pushl $177
80107848:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010784d:	e9 a6 f2 ff ff       	jmp    80106af8 <alltraps>

80107852 <vector178>:
.globl vector178
vector178:
  pushl $0
80107852:	6a 00                	push   $0x0
  pushl $178
80107854:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107859:	e9 9a f2 ff ff       	jmp    80106af8 <alltraps>

8010785e <vector179>:
.globl vector179
vector179:
  pushl $0
8010785e:	6a 00                	push   $0x0
  pushl $179
80107860:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107865:	e9 8e f2 ff ff       	jmp    80106af8 <alltraps>

8010786a <vector180>:
.globl vector180
vector180:
  pushl $0
8010786a:	6a 00                	push   $0x0
  pushl $180
8010786c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107871:	e9 82 f2 ff ff       	jmp    80106af8 <alltraps>

80107876 <vector181>:
.globl vector181
vector181:
  pushl $0
80107876:	6a 00                	push   $0x0
  pushl $181
80107878:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010787d:	e9 76 f2 ff ff       	jmp    80106af8 <alltraps>

80107882 <vector182>:
.globl vector182
vector182:
  pushl $0
80107882:	6a 00                	push   $0x0
  pushl $182
80107884:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107889:	e9 6a f2 ff ff       	jmp    80106af8 <alltraps>

8010788e <vector183>:
.globl vector183
vector183:
  pushl $0
8010788e:	6a 00                	push   $0x0
  pushl $183
80107890:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107895:	e9 5e f2 ff ff       	jmp    80106af8 <alltraps>

8010789a <vector184>:
.globl vector184
vector184:
  pushl $0
8010789a:	6a 00                	push   $0x0
  pushl $184
8010789c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801078a1:	e9 52 f2 ff ff       	jmp    80106af8 <alltraps>

801078a6 <vector185>:
.globl vector185
vector185:
  pushl $0
801078a6:	6a 00                	push   $0x0
  pushl $185
801078a8:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801078ad:	e9 46 f2 ff ff       	jmp    80106af8 <alltraps>

801078b2 <vector186>:
.globl vector186
vector186:
  pushl $0
801078b2:	6a 00                	push   $0x0
  pushl $186
801078b4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801078b9:	e9 3a f2 ff ff       	jmp    80106af8 <alltraps>

801078be <vector187>:
.globl vector187
vector187:
  pushl $0
801078be:	6a 00                	push   $0x0
  pushl $187
801078c0:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801078c5:	e9 2e f2 ff ff       	jmp    80106af8 <alltraps>

801078ca <vector188>:
.globl vector188
vector188:
  pushl $0
801078ca:	6a 00                	push   $0x0
  pushl $188
801078cc:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801078d1:	e9 22 f2 ff ff       	jmp    80106af8 <alltraps>

801078d6 <vector189>:
.globl vector189
vector189:
  pushl $0
801078d6:	6a 00                	push   $0x0
  pushl $189
801078d8:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801078dd:	e9 16 f2 ff ff       	jmp    80106af8 <alltraps>

801078e2 <vector190>:
.globl vector190
vector190:
  pushl $0
801078e2:	6a 00                	push   $0x0
  pushl $190
801078e4:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801078e9:	e9 0a f2 ff ff       	jmp    80106af8 <alltraps>

801078ee <vector191>:
.globl vector191
vector191:
  pushl $0
801078ee:	6a 00                	push   $0x0
  pushl $191
801078f0:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801078f5:	e9 fe f1 ff ff       	jmp    80106af8 <alltraps>

801078fa <vector192>:
.globl vector192
vector192:
  pushl $0
801078fa:	6a 00                	push   $0x0
  pushl $192
801078fc:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107901:	e9 f2 f1 ff ff       	jmp    80106af8 <alltraps>

80107906 <vector193>:
.globl vector193
vector193:
  pushl $0
80107906:	6a 00                	push   $0x0
  pushl $193
80107908:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010790d:	e9 e6 f1 ff ff       	jmp    80106af8 <alltraps>

80107912 <vector194>:
.globl vector194
vector194:
  pushl $0
80107912:	6a 00                	push   $0x0
  pushl $194
80107914:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107919:	e9 da f1 ff ff       	jmp    80106af8 <alltraps>

8010791e <vector195>:
.globl vector195
vector195:
  pushl $0
8010791e:	6a 00                	push   $0x0
  pushl $195
80107920:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107925:	e9 ce f1 ff ff       	jmp    80106af8 <alltraps>

8010792a <vector196>:
.globl vector196
vector196:
  pushl $0
8010792a:	6a 00                	push   $0x0
  pushl $196
8010792c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107931:	e9 c2 f1 ff ff       	jmp    80106af8 <alltraps>

80107936 <vector197>:
.globl vector197
vector197:
  pushl $0
80107936:	6a 00                	push   $0x0
  pushl $197
80107938:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010793d:	e9 b6 f1 ff ff       	jmp    80106af8 <alltraps>

80107942 <vector198>:
.globl vector198
vector198:
  pushl $0
80107942:	6a 00                	push   $0x0
  pushl $198
80107944:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107949:	e9 aa f1 ff ff       	jmp    80106af8 <alltraps>

8010794e <vector199>:
.globl vector199
vector199:
  pushl $0
8010794e:	6a 00                	push   $0x0
  pushl $199
80107950:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107955:	e9 9e f1 ff ff       	jmp    80106af8 <alltraps>

8010795a <vector200>:
.globl vector200
vector200:
  pushl $0
8010795a:	6a 00                	push   $0x0
  pushl $200
8010795c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107961:	e9 92 f1 ff ff       	jmp    80106af8 <alltraps>

80107966 <vector201>:
.globl vector201
vector201:
  pushl $0
80107966:	6a 00                	push   $0x0
  pushl $201
80107968:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010796d:	e9 86 f1 ff ff       	jmp    80106af8 <alltraps>

80107972 <vector202>:
.globl vector202
vector202:
  pushl $0
80107972:	6a 00                	push   $0x0
  pushl $202
80107974:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107979:	e9 7a f1 ff ff       	jmp    80106af8 <alltraps>

8010797e <vector203>:
.globl vector203
vector203:
  pushl $0
8010797e:	6a 00                	push   $0x0
  pushl $203
80107980:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107985:	e9 6e f1 ff ff       	jmp    80106af8 <alltraps>

8010798a <vector204>:
.globl vector204
vector204:
  pushl $0
8010798a:	6a 00                	push   $0x0
  pushl $204
8010798c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107991:	e9 62 f1 ff ff       	jmp    80106af8 <alltraps>

80107996 <vector205>:
.globl vector205
vector205:
  pushl $0
80107996:	6a 00                	push   $0x0
  pushl $205
80107998:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010799d:	e9 56 f1 ff ff       	jmp    80106af8 <alltraps>

801079a2 <vector206>:
.globl vector206
vector206:
  pushl $0
801079a2:	6a 00                	push   $0x0
  pushl $206
801079a4:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801079a9:	e9 4a f1 ff ff       	jmp    80106af8 <alltraps>

801079ae <vector207>:
.globl vector207
vector207:
  pushl $0
801079ae:	6a 00                	push   $0x0
  pushl $207
801079b0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801079b5:	e9 3e f1 ff ff       	jmp    80106af8 <alltraps>

801079ba <vector208>:
.globl vector208
vector208:
  pushl $0
801079ba:	6a 00                	push   $0x0
  pushl $208
801079bc:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801079c1:	e9 32 f1 ff ff       	jmp    80106af8 <alltraps>

801079c6 <vector209>:
.globl vector209
vector209:
  pushl $0
801079c6:	6a 00                	push   $0x0
  pushl $209
801079c8:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801079cd:	e9 26 f1 ff ff       	jmp    80106af8 <alltraps>

801079d2 <vector210>:
.globl vector210
vector210:
  pushl $0
801079d2:	6a 00                	push   $0x0
  pushl $210
801079d4:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801079d9:	e9 1a f1 ff ff       	jmp    80106af8 <alltraps>

801079de <vector211>:
.globl vector211
vector211:
  pushl $0
801079de:	6a 00                	push   $0x0
  pushl $211
801079e0:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801079e5:	e9 0e f1 ff ff       	jmp    80106af8 <alltraps>

801079ea <vector212>:
.globl vector212
vector212:
  pushl $0
801079ea:	6a 00                	push   $0x0
  pushl $212
801079ec:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801079f1:	e9 02 f1 ff ff       	jmp    80106af8 <alltraps>

801079f6 <vector213>:
.globl vector213
vector213:
  pushl $0
801079f6:	6a 00                	push   $0x0
  pushl $213
801079f8:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801079fd:	e9 f6 f0 ff ff       	jmp    80106af8 <alltraps>

80107a02 <vector214>:
.globl vector214
vector214:
  pushl $0
80107a02:	6a 00                	push   $0x0
  pushl $214
80107a04:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107a09:	e9 ea f0 ff ff       	jmp    80106af8 <alltraps>

80107a0e <vector215>:
.globl vector215
vector215:
  pushl $0
80107a0e:	6a 00                	push   $0x0
  pushl $215
80107a10:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107a15:	e9 de f0 ff ff       	jmp    80106af8 <alltraps>

80107a1a <vector216>:
.globl vector216
vector216:
  pushl $0
80107a1a:	6a 00                	push   $0x0
  pushl $216
80107a1c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107a21:	e9 d2 f0 ff ff       	jmp    80106af8 <alltraps>

80107a26 <vector217>:
.globl vector217
vector217:
  pushl $0
80107a26:	6a 00                	push   $0x0
  pushl $217
80107a28:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107a2d:	e9 c6 f0 ff ff       	jmp    80106af8 <alltraps>

80107a32 <vector218>:
.globl vector218
vector218:
  pushl $0
80107a32:	6a 00                	push   $0x0
  pushl $218
80107a34:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107a39:	e9 ba f0 ff ff       	jmp    80106af8 <alltraps>

80107a3e <vector219>:
.globl vector219
vector219:
  pushl $0
80107a3e:	6a 00                	push   $0x0
  pushl $219
80107a40:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107a45:	e9 ae f0 ff ff       	jmp    80106af8 <alltraps>

80107a4a <vector220>:
.globl vector220
vector220:
  pushl $0
80107a4a:	6a 00                	push   $0x0
  pushl $220
80107a4c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107a51:	e9 a2 f0 ff ff       	jmp    80106af8 <alltraps>

80107a56 <vector221>:
.globl vector221
vector221:
  pushl $0
80107a56:	6a 00                	push   $0x0
  pushl $221
80107a58:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107a5d:	e9 96 f0 ff ff       	jmp    80106af8 <alltraps>

80107a62 <vector222>:
.globl vector222
vector222:
  pushl $0
80107a62:	6a 00                	push   $0x0
  pushl $222
80107a64:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a69:	e9 8a f0 ff ff       	jmp    80106af8 <alltraps>

80107a6e <vector223>:
.globl vector223
vector223:
  pushl $0
80107a6e:	6a 00                	push   $0x0
  pushl $223
80107a70:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a75:	e9 7e f0 ff ff       	jmp    80106af8 <alltraps>

80107a7a <vector224>:
.globl vector224
vector224:
  pushl $0
80107a7a:	6a 00                	push   $0x0
  pushl $224
80107a7c:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a81:	e9 72 f0 ff ff       	jmp    80106af8 <alltraps>

80107a86 <vector225>:
.globl vector225
vector225:
  pushl $0
80107a86:	6a 00                	push   $0x0
  pushl $225
80107a88:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a8d:	e9 66 f0 ff ff       	jmp    80106af8 <alltraps>

80107a92 <vector226>:
.globl vector226
vector226:
  pushl $0
80107a92:	6a 00                	push   $0x0
  pushl $226
80107a94:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a99:	e9 5a f0 ff ff       	jmp    80106af8 <alltraps>

80107a9e <vector227>:
.globl vector227
vector227:
  pushl $0
80107a9e:	6a 00                	push   $0x0
  pushl $227
80107aa0:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107aa5:	e9 4e f0 ff ff       	jmp    80106af8 <alltraps>

80107aaa <vector228>:
.globl vector228
vector228:
  pushl $0
80107aaa:	6a 00                	push   $0x0
  pushl $228
80107aac:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107ab1:	e9 42 f0 ff ff       	jmp    80106af8 <alltraps>

80107ab6 <vector229>:
.globl vector229
vector229:
  pushl $0
80107ab6:	6a 00                	push   $0x0
  pushl $229
80107ab8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107abd:	e9 36 f0 ff ff       	jmp    80106af8 <alltraps>

80107ac2 <vector230>:
.globl vector230
vector230:
  pushl $0
80107ac2:	6a 00                	push   $0x0
  pushl $230
80107ac4:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107ac9:	e9 2a f0 ff ff       	jmp    80106af8 <alltraps>

80107ace <vector231>:
.globl vector231
vector231:
  pushl $0
80107ace:	6a 00                	push   $0x0
  pushl $231
80107ad0:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107ad5:	e9 1e f0 ff ff       	jmp    80106af8 <alltraps>

80107ada <vector232>:
.globl vector232
vector232:
  pushl $0
80107ada:	6a 00                	push   $0x0
  pushl $232
80107adc:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107ae1:	e9 12 f0 ff ff       	jmp    80106af8 <alltraps>

80107ae6 <vector233>:
.globl vector233
vector233:
  pushl $0
80107ae6:	6a 00                	push   $0x0
  pushl $233
80107ae8:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107aed:	e9 06 f0 ff ff       	jmp    80106af8 <alltraps>

80107af2 <vector234>:
.globl vector234
vector234:
  pushl $0
80107af2:	6a 00                	push   $0x0
  pushl $234
80107af4:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107af9:	e9 fa ef ff ff       	jmp    80106af8 <alltraps>

80107afe <vector235>:
.globl vector235
vector235:
  pushl $0
80107afe:	6a 00                	push   $0x0
  pushl $235
80107b00:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107b05:	e9 ee ef ff ff       	jmp    80106af8 <alltraps>

80107b0a <vector236>:
.globl vector236
vector236:
  pushl $0
80107b0a:	6a 00                	push   $0x0
  pushl $236
80107b0c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107b11:	e9 e2 ef ff ff       	jmp    80106af8 <alltraps>

80107b16 <vector237>:
.globl vector237
vector237:
  pushl $0
80107b16:	6a 00                	push   $0x0
  pushl $237
80107b18:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107b1d:	e9 d6 ef ff ff       	jmp    80106af8 <alltraps>

80107b22 <vector238>:
.globl vector238
vector238:
  pushl $0
80107b22:	6a 00                	push   $0x0
  pushl $238
80107b24:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107b29:	e9 ca ef ff ff       	jmp    80106af8 <alltraps>

80107b2e <vector239>:
.globl vector239
vector239:
  pushl $0
80107b2e:	6a 00                	push   $0x0
  pushl $239
80107b30:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107b35:	e9 be ef ff ff       	jmp    80106af8 <alltraps>

80107b3a <vector240>:
.globl vector240
vector240:
  pushl $0
80107b3a:	6a 00                	push   $0x0
  pushl $240
80107b3c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107b41:	e9 b2 ef ff ff       	jmp    80106af8 <alltraps>

80107b46 <vector241>:
.globl vector241
vector241:
  pushl $0
80107b46:	6a 00                	push   $0x0
  pushl $241
80107b48:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107b4d:	e9 a6 ef ff ff       	jmp    80106af8 <alltraps>

80107b52 <vector242>:
.globl vector242
vector242:
  pushl $0
80107b52:	6a 00                	push   $0x0
  pushl $242
80107b54:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107b59:	e9 9a ef ff ff       	jmp    80106af8 <alltraps>

80107b5e <vector243>:
.globl vector243
vector243:
  pushl $0
80107b5e:	6a 00                	push   $0x0
  pushl $243
80107b60:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b65:	e9 8e ef ff ff       	jmp    80106af8 <alltraps>

80107b6a <vector244>:
.globl vector244
vector244:
  pushl $0
80107b6a:	6a 00                	push   $0x0
  pushl $244
80107b6c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b71:	e9 82 ef ff ff       	jmp    80106af8 <alltraps>

80107b76 <vector245>:
.globl vector245
vector245:
  pushl $0
80107b76:	6a 00                	push   $0x0
  pushl $245
80107b78:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b7d:	e9 76 ef ff ff       	jmp    80106af8 <alltraps>

80107b82 <vector246>:
.globl vector246
vector246:
  pushl $0
80107b82:	6a 00                	push   $0x0
  pushl $246
80107b84:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b89:	e9 6a ef ff ff       	jmp    80106af8 <alltraps>

80107b8e <vector247>:
.globl vector247
vector247:
  pushl $0
80107b8e:	6a 00                	push   $0x0
  pushl $247
80107b90:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b95:	e9 5e ef ff ff       	jmp    80106af8 <alltraps>

80107b9a <vector248>:
.globl vector248
vector248:
  pushl $0
80107b9a:	6a 00                	push   $0x0
  pushl $248
80107b9c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107ba1:	e9 52 ef ff ff       	jmp    80106af8 <alltraps>

80107ba6 <vector249>:
.globl vector249
vector249:
  pushl $0
80107ba6:	6a 00                	push   $0x0
  pushl $249
80107ba8:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107bad:	e9 46 ef ff ff       	jmp    80106af8 <alltraps>

80107bb2 <vector250>:
.globl vector250
vector250:
  pushl $0
80107bb2:	6a 00                	push   $0x0
  pushl $250
80107bb4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107bb9:	e9 3a ef ff ff       	jmp    80106af8 <alltraps>

80107bbe <vector251>:
.globl vector251
vector251:
  pushl $0
80107bbe:	6a 00                	push   $0x0
  pushl $251
80107bc0:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107bc5:	e9 2e ef ff ff       	jmp    80106af8 <alltraps>

80107bca <vector252>:
.globl vector252
vector252:
  pushl $0
80107bca:	6a 00                	push   $0x0
  pushl $252
80107bcc:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107bd1:	e9 22 ef ff ff       	jmp    80106af8 <alltraps>

80107bd6 <vector253>:
.globl vector253
vector253:
  pushl $0
80107bd6:	6a 00                	push   $0x0
  pushl $253
80107bd8:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107bdd:	e9 16 ef ff ff       	jmp    80106af8 <alltraps>

80107be2 <vector254>:
.globl vector254
vector254:
  pushl $0
80107be2:	6a 00                	push   $0x0
  pushl $254
80107be4:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107be9:	e9 0a ef ff ff       	jmp    80106af8 <alltraps>

80107bee <vector255>:
.globl vector255
vector255:
  pushl $0
80107bee:	6a 00                	push   $0x0
  pushl $255
80107bf0:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107bf5:	e9 fe ee ff ff       	jmp    80106af8 <alltraps>
	...

80107bfc <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107bfc:	55                   	push   %ebp
80107bfd:	89 e5                	mov    %esp,%ebp
80107bff:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107c02:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c05:	83 e8 01             	sub    $0x1,%eax
80107c08:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80107c0f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107c13:	8b 45 08             	mov    0x8(%ebp),%eax
80107c16:	c1 e8 10             	shr    $0x10,%eax
80107c19:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107c1d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107c20:	0f 01 10             	lgdtl  (%eax)
}
80107c23:	c9                   	leave  
80107c24:	c3                   	ret    

80107c25 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107c25:	55                   	push   %ebp
80107c26:	89 e5                	mov    %esp,%ebp
80107c28:	83 ec 04             	sub    $0x4,%esp
80107c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80107c2e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107c32:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107c36:	0f 00 d8             	ltr    %ax
}
80107c39:	c9                   	leave  
80107c3a:	c3                   	ret    

80107c3b <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107c3b:	55                   	push   %ebp
80107c3c:	89 e5                	mov    %esp,%ebp
80107c3e:	83 ec 04             	sub    $0x4,%esp
80107c41:	8b 45 08             	mov    0x8(%ebp),%eax
80107c44:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107c48:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107c4c:	8e e8                	mov    %eax,%gs
}
80107c4e:	c9                   	leave  
80107c4f:	c3                   	ret    

80107c50 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107c50:	55                   	push   %ebp
80107c51:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107c53:	8b 45 08             	mov    0x8(%ebp),%eax
80107c56:	0f 22 d8             	mov    %eax,%cr3
}
80107c59:	5d                   	pop    %ebp
80107c5a:	c3                   	ret    

80107c5b <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107c5b:	55                   	push   %ebp
80107c5c:	89 e5                	mov    %esp,%ebp
80107c5e:	8b 45 08             	mov    0x8(%ebp),%eax
80107c61:	05 00 00 00 80       	add    $0x80000000,%eax
80107c66:	5d                   	pop    %ebp
80107c67:	c3                   	ret    

80107c68 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107c68:	55                   	push   %ebp
80107c69:	89 e5                	mov    %esp,%ebp
80107c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80107c6e:	05 00 00 00 80       	add    $0x80000000,%eax
80107c73:	5d                   	pop    %ebp
80107c74:	c3                   	ret    

80107c75 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107c75:	55                   	push   %ebp
80107c76:	89 e5                	mov    %esp,%ebp
80107c78:	53                   	push   %ebx
80107c79:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107c7c:	e8 42 b2 ff ff       	call   80102ec3 <cpunum>
80107c81:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107c87:	05 80 33 11 80       	add    $0x80113380,%eax
80107c8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c92:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca4:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cab:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107caf:	83 e2 f0             	and    $0xfffffff0,%edx
80107cb2:	83 ca 0a             	or     $0xa,%edx
80107cb5:	88 50 7d             	mov    %dl,0x7d(%eax)
80107cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107cbf:	83 ca 10             	or     $0x10,%edx
80107cc2:	88 50 7d             	mov    %dl,0x7d(%eax)
80107cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ccc:	83 e2 9f             	and    $0xffffff9f,%edx
80107ccf:	88 50 7d             	mov    %dl,0x7d(%eax)
80107cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107cd9:	83 ca 80             	or     $0xffffff80,%edx
80107cdc:	88 50 7d             	mov    %dl,0x7d(%eax)
80107cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ce6:	83 ca 0f             	or     $0xf,%edx
80107ce9:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cef:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cf3:	83 e2 ef             	and    $0xffffffef,%edx
80107cf6:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d00:	83 e2 df             	and    $0xffffffdf,%edx
80107d03:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d09:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d0d:	83 ca 40             	or     $0x40,%edx
80107d10:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d16:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d1a:	83 ca 80             	or     $0xffffff80,%edx
80107d1d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d23:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107d31:	ff ff 
80107d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d36:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107d3d:	00 00 
80107d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d42:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d53:	83 e2 f0             	and    $0xfffffff0,%edx
80107d56:	83 ca 02             	or     $0x2,%edx
80107d59:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d62:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d69:	83 ca 10             	or     $0x10,%edx
80107d6c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d75:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d7c:	83 e2 9f             	and    $0xffffff9f,%edx
80107d7f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d88:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d8f:	83 ca 80             	or     $0xffffff80,%edx
80107d92:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107da2:	83 ca 0f             	or     $0xf,%edx
80107da5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dae:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107db5:	83 e2 ef             	and    $0xffffffef,%edx
80107db8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107dc8:	83 e2 df             	and    $0xffffffdf,%edx
80107dcb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ddb:	83 ca 40             	or     $0x40,%edx
80107dde:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107dee:	83 ca 80             	or     $0xffffff80,%edx
80107df1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfa:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e04:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107e0b:	ff ff 
80107e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e10:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107e17:	00 00 
80107e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e26:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e2d:	83 e2 f0             	and    $0xfffffff0,%edx
80107e30:	83 ca 0a             	or     $0xa,%edx
80107e33:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e43:	83 ca 10             	or     $0x10,%edx
80107e46:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e56:	83 ca 60             	or     $0x60,%edx
80107e59:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e62:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e69:	83 ca 80             	or     $0xffffff80,%edx
80107e6c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e75:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e7c:	83 ca 0f             	or     $0xf,%edx
80107e7f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e88:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e8f:	83 e2 ef             	and    $0xffffffef,%edx
80107e92:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ea2:	83 e2 df             	and    $0xffffffdf,%edx
80107ea5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eae:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107eb5:	83 ca 40             	or     $0x40,%edx
80107eb8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ec8:	83 ca 80             	or     $0xffffff80,%edx
80107ecb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed4:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ede:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107ee5:	ff ff 
80107ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eea:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107ef1:	00 00 
80107ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef6:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f00:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f07:	83 e2 f0             	and    $0xfffffff0,%edx
80107f0a:	83 ca 02             	or     $0x2,%edx
80107f0d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f16:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f1d:	83 ca 10             	or     $0x10,%edx
80107f20:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f29:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f30:	83 ca 60             	or     $0x60,%edx
80107f33:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f3c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f43:	83 ca 80             	or     $0xffffff80,%edx
80107f46:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f56:	83 ca 0f             	or     $0xf,%edx
80107f59:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f62:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f69:	83 e2 ef             	and    $0xffffffef,%edx
80107f6c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f75:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f7c:	83 e2 df             	and    $0xffffffdf,%edx
80107f7f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f88:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f8f:	83 ca 40             	or     $0x40,%edx
80107f92:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107fa2:	83 ca 80             	or     $0xffffff80,%edx
80107fa5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fae:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb8:	05 b4 00 00 00       	add    $0xb4,%eax
80107fbd:	89 c3                	mov    %eax,%ebx
80107fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc2:	05 b4 00 00 00       	add    $0xb4,%eax
80107fc7:	c1 e8 10             	shr    $0x10,%eax
80107fca:	89 c1                	mov    %eax,%ecx
80107fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcf:	05 b4 00 00 00       	add    $0xb4,%eax
80107fd4:	c1 e8 18             	shr    $0x18,%eax
80107fd7:	89 c2                	mov    %eax,%edx
80107fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fdc:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107fe3:	00 00 
80107fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe8:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff2:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffb:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108002:	83 e1 f0             	and    $0xfffffff0,%ecx
80108005:	83 c9 02             	or     $0x2,%ecx
80108008:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010800e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108011:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108018:	83 c9 10             	or     $0x10,%ecx
8010801b:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108024:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010802b:	83 e1 9f             	and    $0xffffff9f,%ecx
8010802e:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108034:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108037:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010803e:	83 c9 80             	or     $0xffffff80,%ecx
80108041:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108047:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804a:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108051:	83 e1 f0             	and    $0xfffffff0,%ecx
80108054:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010805a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010805d:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108064:	83 e1 ef             	and    $0xffffffef,%ecx
80108067:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010806d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108070:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108077:	83 e1 df             	and    $0xffffffdf,%ecx
8010807a:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108083:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010808a:	83 c9 40             	or     $0x40,%ecx
8010808d:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108093:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108096:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010809d:	83 c9 80             	or     $0xffffff80,%ecx
801080a0:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801080a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a9:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801080af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b2:	83 c0 70             	add    $0x70,%eax
801080b5:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
801080bc:	00 
801080bd:	89 04 24             	mov    %eax,(%esp)
801080c0:	e8 37 fb ff ff       	call   80107bfc <lgdt>
  loadgs(SEG_KCPU << 3);
801080c5:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
801080cc:	e8 6a fb ff ff       	call   80107c3b <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
801080d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d4:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801080da:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801080e1:	00 00 00 00 
}
801080e5:	83 c4 24             	add    $0x24,%esp
801080e8:	5b                   	pop    %ebx
801080e9:	5d                   	pop    %ebp
801080ea:	c3                   	ret    

801080eb <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801080eb:	55                   	push   %ebp
801080ec:	89 e5                	mov    %esp,%ebp
801080ee:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801080f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801080f4:	c1 e8 16             	shr    $0x16,%eax
801080f7:	c1 e0 02             	shl    $0x2,%eax
801080fa:	03 45 08             	add    0x8(%ebp),%eax
801080fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108100:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108103:	8b 00                	mov    (%eax),%eax
80108105:	83 e0 01             	and    $0x1,%eax
80108108:	84 c0                	test   %al,%al
8010810a:	74 17                	je     80108123 <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
8010810c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010810f:	8b 00                	mov    (%eax),%eax
80108111:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108116:	89 04 24             	mov    %eax,(%esp)
80108119:	e8 4a fb ff ff       	call   80107c68 <p2v>
8010811e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108121:	eb 4b                	jmp    8010816e <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108123:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108127:	74 0e                	je     80108137 <walkpgdir+0x4c>
80108129:	e8 dd a9 ff ff       	call   80102b0b <kalloc>
8010812e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108131:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108135:	75 07                	jne    8010813e <walkpgdir+0x53>
      return 0;
80108137:	b8 00 00 00 00       	mov    $0x0,%eax
8010813c:	eb 41                	jmp    8010817f <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010813e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108145:	00 
80108146:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010814d:	00 
8010814e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108151:	89 04 24             	mov    %eax,(%esp)
80108154:	e8 1d d4 ff ff       	call   80105576 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010815c:	89 04 24             	mov    %eax,(%esp)
8010815f:	e8 f7 fa ff ff       	call   80107c5b <v2p>
80108164:	89 c2                	mov    %eax,%edx
80108166:	83 ca 07             	or     $0x7,%edx
80108169:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010816c:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010816e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108171:	c1 e8 0c             	shr    $0xc,%eax
80108174:	25 ff 03 00 00       	and    $0x3ff,%eax
80108179:	c1 e0 02             	shl    $0x2,%eax
8010817c:	03 45 f4             	add    -0xc(%ebp),%eax
}
8010817f:	c9                   	leave  
80108180:	c3                   	ret    

80108181 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108181:	55                   	push   %ebp
80108182:	89 e5                	mov    %esp,%ebp
80108184:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108187:	8b 45 0c             	mov    0xc(%ebp),%eax
8010818a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010818f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108192:	8b 45 0c             	mov    0xc(%ebp),%eax
80108195:	03 45 10             	add    0x10(%ebp),%eax
80108198:	83 e8 01             	sub    $0x1,%eax
8010819b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801081a3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801081aa:	00 
801081ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801081b2:	8b 45 08             	mov    0x8(%ebp),%eax
801081b5:	89 04 24             	mov    %eax,(%esp)
801081b8:	e8 2e ff ff ff       	call   801080eb <walkpgdir>
801081bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
801081c0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081c4:	75 07                	jne    801081cd <mappages+0x4c>
      return -1;
801081c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081cb:	eb 46                	jmp    80108213 <mappages+0x92>
    if(*pte & PTE_P)
801081cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081d0:	8b 00                	mov    (%eax),%eax
801081d2:	83 e0 01             	and    $0x1,%eax
801081d5:	84 c0                	test   %al,%al
801081d7:	74 0c                	je     801081e5 <mappages+0x64>
      panic("remap");
801081d9:	c7 04 24 54 90 10 80 	movl   $0x80109054,(%esp)
801081e0:	e8 58 83 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
801081e5:	8b 45 18             	mov    0x18(%ebp),%eax
801081e8:	0b 45 14             	or     0x14(%ebp),%eax
801081eb:	89 c2                	mov    %eax,%edx
801081ed:	83 ca 01             	or     $0x1,%edx
801081f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081f3:	89 10                	mov    %edx,(%eax)
    if(a == last)
801081f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801081fb:	74 10                	je     8010820d <mappages+0x8c>
      break;
    a += PGSIZE;
801081fd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108204:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010820b:	eb 96                	jmp    801081a3 <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
8010820d:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
8010820e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108213:	c9                   	leave  
80108214:	c3                   	ret    

80108215 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108215:	55                   	push   %ebp
80108216:	89 e5                	mov    %esp,%ebp
80108218:	53                   	push   %ebx
80108219:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010821c:	e8 ea a8 ff ff       	call   80102b0b <kalloc>
80108221:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108224:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108228:	75 0a                	jne    80108234 <setupkvm+0x1f>
    return 0;
8010822a:	b8 00 00 00 00       	mov    $0x0,%eax
8010822f:	e9 98 00 00 00       	jmp    801082cc <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108234:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010823b:	00 
8010823c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108243:	00 
80108244:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108247:	89 04 24             	mov    %eax,(%esp)
8010824a:	e8 27 d3 ff ff       	call   80105576 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
8010824f:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108256:	e8 0d fa ff ff       	call   80107c68 <p2v>
8010825b:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108260:	76 0c                	jbe    8010826e <setupkvm+0x59>
    panic("PHYSTOP too high");
80108262:	c7 04 24 5a 90 10 80 	movl   $0x8010905a,(%esp)
80108269:	e8 cf 82 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010826e:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108275:	eb 49                	jmp    801082c0 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80108277:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010827a:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
8010827d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108280:	8b 50 04             	mov    0x4(%eax),%edx
80108283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108286:	8b 58 08             	mov    0x8(%eax),%ebx
80108289:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010828c:	8b 40 04             	mov    0x4(%eax),%eax
8010828f:	29 c3                	sub    %eax,%ebx
80108291:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108294:	8b 00                	mov    (%eax),%eax
80108296:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010829a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010829e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801082a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801082a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082a9:	89 04 24             	mov    %eax,(%esp)
801082ac:	e8 d0 fe ff ff       	call   80108181 <mappages>
801082b1:	85 c0                	test   %eax,%eax
801082b3:	79 07                	jns    801082bc <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801082b5:	b8 00 00 00 00       	mov    $0x0,%eax
801082ba:	eb 10                	jmp    801082cc <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801082bc:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801082c0:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
801082c7:	72 ae                	jb     80108277 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801082c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801082cc:	83 c4 34             	add    $0x34,%esp
801082cf:	5b                   	pop    %ebx
801082d0:	5d                   	pop    %ebp
801082d1:	c3                   	ret    

801082d2 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801082d2:	55                   	push   %ebp
801082d3:	89 e5                	mov    %esp,%ebp
801082d5:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801082d8:	e8 38 ff ff ff       	call   80108215 <setupkvm>
801082dd:	a3 58 63 11 80       	mov    %eax,0x80116358
  switchkvm();
801082e2:	e8 02 00 00 00       	call   801082e9 <switchkvm>
}
801082e7:	c9                   	leave  
801082e8:	c3                   	ret    

801082e9 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801082e9:	55                   	push   %ebp
801082ea:	89 e5                	mov    %esp,%ebp
801082ec:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801082ef:	a1 58 63 11 80       	mov    0x80116358,%eax
801082f4:	89 04 24             	mov    %eax,(%esp)
801082f7:	e8 5f f9 ff ff       	call   80107c5b <v2p>
801082fc:	89 04 24             	mov    %eax,(%esp)
801082ff:	e8 4c f9 ff ff       	call   80107c50 <lcr3>
}
80108304:	c9                   	leave  
80108305:	c3                   	ret    

80108306 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108306:	55                   	push   %ebp
80108307:	89 e5                	mov    %esp,%ebp
80108309:	53                   	push   %ebx
8010830a:	83 ec 14             	sub    $0x14,%esp
  pushcli();
8010830d:	e8 5d d1 ff ff       	call   8010546f <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108312:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108318:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010831f:	83 c2 08             	add    $0x8,%edx
80108322:	89 d3                	mov    %edx,%ebx
80108324:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010832b:	83 c2 08             	add    $0x8,%edx
8010832e:	c1 ea 10             	shr    $0x10,%edx
80108331:	89 d1                	mov    %edx,%ecx
80108333:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010833a:	83 c2 08             	add    $0x8,%edx
8010833d:	c1 ea 18             	shr    $0x18,%edx
80108340:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108347:	67 00 
80108349:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108350:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108356:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010835d:	83 e1 f0             	and    $0xfffffff0,%ecx
80108360:	83 c9 09             	or     $0x9,%ecx
80108363:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108369:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108370:	83 c9 10             	or     $0x10,%ecx
80108373:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108379:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108380:	83 e1 9f             	and    $0xffffff9f,%ecx
80108383:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108389:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108390:	83 c9 80             	or     $0xffffff80,%ecx
80108393:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108399:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801083a0:	83 e1 f0             	and    $0xfffffff0,%ecx
801083a3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801083a9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801083b0:	83 e1 ef             	and    $0xffffffef,%ecx
801083b3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801083b9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801083c0:	83 e1 df             	and    $0xffffffdf,%ecx
801083c3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801083c9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801083d0:	83 c9 40             	or     $0x40,%ecx
801083d3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801083d9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801083e0:	83 e1 7f             	and    $0x7f,%ecx
801083e3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801083e9:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801083ef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801083f5:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801083fc:	83 e2 ef             	and    $0xffffffef,%edx
801083ff:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108405:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010840b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108411:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108417:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010841e:	8b 52 08             	mov    0x8(%edx),%edx
80108421:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108427:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
8010842a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108431:	e8 ef f7 ff ff       	call   80107c25 <ltr>
  if(p->pgdir == 0)
80108436:	8b 45 08             	mov    0x8(%ebp),%eax
80108439:	8b 40 04             	mov    0x4(%eax),%eax
8010843c:	85 c0                	test   %eax,%eax
8010843e:	75 0c                	jne    8010844c <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108440:	c7 04 24 6b 90 10 80 	movl   $0x8010906b,(%esp)
80108447:	e8 f1 80 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010844c:	8b 45 08             	mov    0x8(%ebp),%eax
8010844f:	8b 40 04             	mov    0x4(%eax),%eax
80108452:	89 04 24             	mov    %eax,(%esp)
80108455:	e8 01 f8 ff ff       	call   80107c5b <v2p>
8010845a:	89 04 24             	mov    %eax,(%esp)
8010845d:	e8 ee f7 ff ff       	call   80107c50 <lcr3>
  popcli();
80108462:	e8 50 d0 ff ff       	call   801054b7 <popcli>
}
80108467:	83 c4 14             	add    $0x14,%esp
8010846a:	5b                   	pop    %ebx
8010846b:	5d                   	pop    %ebp
8010846c:	c3                   	ret    

8010846d <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010846d:	55                   	push   %ebp
8010846e:	89 e5                	mov    %esp,%ebp
80108470:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108473:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010847a:	76 0c                	jbe    80108488 <inituvm+0x1b>
    panic("inituvm: more than a page");
8010847c:	c7 04 24 7f 90 10 80 	movl   $0x8010907f,(%esp)
80108483:	e8 b5 80 ff ff       	call   8010053d <panic>
  mem = kalloc();
80108488:	e8 7e a6 ff ff       	call   80102b0b <kalloc>
8010848d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108490:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108497:	00 
80108498:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010849f:	00 
801084a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a3:	89 04 24             	mov    %eax,(%esp)
801084a6:	e8 cb d0 ff ff       	call   80105576 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801084ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ae:	89 04 24             	mov    %eax,(%esp)
801084b1:	e8 a5 f7 ff ff       	call   80107c5b <v2p>
801084b6:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801084bd:	00 
801084be:	89 44 24 0c          	mov    %eax,0xc(%esp)
801084c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084c9:	00 
801084ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801084d1:	00 
801084d2:	8b 45 08             	mov    0x8(%ebp),%eax
801084d5:	89 04 24             	mov    %eax,(%esp)
801084d8:	e8 a4 fc ff ff       	call   80108181 <mappages>
  memmove(mem, init, sz);
801084dd:	8b 45 10             	mov    0x10(%ebp),%eax
801084e0:	89 44 24 08          	mov    %eax,0x8(%esp)
801084e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801084e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801084eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ee:	89 04 24             	mov    %eax,(%esp)
801084f1:	e8 53 d1 ff ff       	call   80105649 <memmove>
}
801084f6:	c9                   	leave  
801084f7:	c3                   	ret    

801084f8 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801084f8:	55                   	push   %ebp
801084f9:	89 e5                	mov    %esp,%ebp
801084fb:	53                   	push   %ebx
801084fc:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801084ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80108502:	25 ff 0f 00 00       	and    $0xfff,%eax
80108507:	85 c0                	test   %eax,%eax
80108509:	74 0c                	je     80108517 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010850b:	c7 04 24 9c 90 10 80 	movl   $0x8010909c,(%esp)
80108512:	e8 26 80 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108517:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010851e:	e9 ad 00 00 00       	jmp    801085d0 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108523:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108526:	8b 55 0c             	mov    0xc(%ebp),%edx
80108529:	01 d0                	add    %edx,%eax
8010852b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108532:	00 
80108533:	89 44 24 04          	mov    %eax,0x4(%esp)
80108537:	8b 45 08             	mov    0x8(%ebp),%eax
8010853a:	89 04 24             	mov    %eax,(%esp)
8010853d:	e8 a9 fb ff ff       	call   801080eb <walkpgdir>
80108542:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108545:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108549:	75 0c                	jne    80108557 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
8010854b:	c7 04 24 bf 90 10 80 	movl   $0x801090bf,(%esp)
80108552:	e8 e6 7f ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108557:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010855a:	8b 00                	mov    (%eax),%eax
8010855c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108561:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108567:	8b 55 18             	mov    0x18(%ebp),%edx
8010856a:	89 d1                	mov    %edx,%ecx
8010856c:	29 c1                	sub    %eax,%ecx
8010856e:	89 c8                	mov    %ecx,%eax
80108570:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108575:	77 11                	ja     80108588 <loaduvm+0x90>
      n = sz - i;
80108577:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010857a:	8b 55 18             	mov    0x18(%ebp),%edx
8010857d:	89 d1                	mov    %edx,%ecx
8010857f:	29 c1                	sub    %eax,%ecx
80108581:	89 c8                	mov    %ecx,%eax
80108583:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108586:	eb 07                	jmp    8010858f <loaduvm+0x97>
    else
      n = PGSIZE;
80108588:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010858f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108592:	8b 55 14             	mov    0x14(%ebp),%edx
80108595:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108598:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010859b:	89 04 24             	mov    %eax,(%esp)
8010859e:	e8 c5 f6 ff ff       	call   80107c68 <p2v>
801085a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801085a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
801085aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801085ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801085b2:	8b 45 10             	mov    0x10(%ebp),%eax
801085b5:	89 04 24             	mov    %eax,(%esp)
801085b8:	e8 ad 97 ff ff       	call   80101d6a <readi>
801085bd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801085c0:	74 07                	je     801085c9 <loaduvm+0xd1>
      return -1;
801085c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801085c7:	eb 18                	jmp    801085e1 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801085c9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d3:	3b 45 18             	cmp    0x18(%ebp),%eax
801085d6:	0f 82 47 ff ff ff    	jb     80108523 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801085dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085e1:	83 c4 24             	add    $0x24,%esp
801085e4:	5b                   	pop    %ebx
801085e5:	5d                   	pop    %ebp
801085e6:	c3                   	ret    

801085e7 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801085e7:	55                   	push   %ebp
801085e8:	89 e5                	mov    %esp,%ebp
801085ea:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801085ed:	8b 45 10             	mov    0x10(%ebp),%eax
801085f0:	85 c0                	test   %eax,%eax
801085f2:	79 0a                	jns    801085fe <allocuvm+0x17>
    return 0;
801085f4:	b8 00 00 00 00       	mov    $0x0,%eax
801085f9:	e9 c1 00 00 00       	jmp    801086bf <allocuvm+0xd8>
  if(newsz < oldsz)
801085fe:	8b 45 10             	mov    0x10(%ebp),%eax
80108601:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108604:	73 08                	jae    8010860e <allocuvm+0x27>
    return oldsz;
80108606:	8b 45 0c             	mov    0xc(%ebp),%eax
80108609:	e9 b1 00 00 00       	jmp    801086bf <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
8010860e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108611:	05 ff 0f 00 00       	add    $0xfff,%eax
80108616:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010861b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010861e:	e9 8d 00 00 00       	jmp    801086b0 <allocuvm+0xc9>
    mem = kalloc();
80108623:	e8 e3 a4 ff ff       	call   80102b0b <kalloc>
80108628:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010862b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010862f:	75 2c                	jne    8010865d <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108631:	c7 04 24 dd 90 10 80 	movl   $0x801090dd,(%esp)
80108638:	e8 64 7d ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010863d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108640:	89 44 24 08          	mov    %eax,0x8(%esp)
80108644:	8b 45 10             	mov    0x10(%ebp),%eax
80108647:	89 44 24 04          	mov    %eax,0x4(%esp)
8010864b:	8b 45 08             	mov    0x8(%ebp),%eax
8010864e:	89 04 24             	mov    %eax,(%esp)
80108651:	e8 6b 00 00 00       	call   801086c1 <deallocuvm>
      return 0;
80108656:	b8 00 00 00 00       	mov    $0x0,%eax
8010865b:	eb 62                	jmp    801086bf <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
8010865d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108664:	00 
80108665:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010866c:	00 
8010866d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108670:	89 04 24             	mov    %eax,(%esp)
80108673:	e8 fe ce ff ff       	call   80105576 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108678:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010867b:	89 04 24             	mov    %eax,(%esp)
8010867e:	e8 d8 f5 ff ff       	call   80107c5b <v2p>
80108683:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108686:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010868d:	00 
8010868e:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108692:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108699:	00 
8010869a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010869e:	8b 45 08             	mov    0x8(%ebp),%eax
801086a1:	89 04 24             	mov    %eax,(%esp)
801086a4:	e8 d8 fa ff ff       	call   80108181 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801086a9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801086b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b3:	3b 45 10             	cmp    0x10(%ebp),%eax
801086b6:	0f 82 67 ff ff ff    	jb     80108623 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801086bc:	8b 45 10             	mov    0x10(%ebp),%eax
}
801086bf:	c9                   	leave  
801086c0:	c3                   	ret    

801086c1 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801086c1:	55                   	push   %ebp
801086c2:	89 e5                	mov    %esp,%ebp
801086c4:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801086c7:	8b 45 10             	mov    0x10(%ebp),%eax
801086ca:	3b 45 0c             	cmp    0xc(%ebp),%eax
801086cd:	72 08                	jb     801086d7 <deallocuvm+0x16>
    return oldsz;
801086cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801086d2:	e9 a4 00 00 00       	jmp    8010877b <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
801086d7:	8b 45 10             	mov    0x10(%ebp),%eax
801086da:	05 ff 0f 00 00       	add    $0xfff,%eax
801086df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801086e7:	e9 80 00 00 00       	jmp    8010876c <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801086ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086f6:	00 
801086f7:	89 44 24 04          	mov    %eax,0x4(%esp)
801086fb:	8b 45 08             	mov    0x8(%ebp),%eax
801086fe:	89 04 24             	mov    %eax,(%esp)
80108701:	e8 e5 f9 ff ff       	call   801080eb <walkpgdir>
80108706:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108709:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010870d:	75 09                	jne    80108718 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
8010870f:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108716:	eb 4d                	jmp    80108765 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108718:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010871b:	8b 00                	mov    (%eax),%eax
8010871d:	83 e0 01             	and    $0x1,%eax
80108720:	84 c0                	test   %al,%al
80108722:	74 41                	je     80108765 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108724:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108727:	8b 00                	mov    (%eax),%eax
80108729:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010872e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108731:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108735:	75 0c                	jne    80108743 <deallocuvm+0x82>
        panic("kfree");
80108737:	c7 04 24 f5 90 10 80 	movl   $0x801090f5,(%esp)
8010873e:	e8 fa 7d ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
80108743:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108746:	89 04 24             	mov    %eax,(%esp)
80108749:	e8 1a f5 ff ff       	call   80107c68 <p2v>
8010874e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108751:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108754:	89 04 24             	mov    %eax,(%esp)
80108757:	e8 16 a3 ff ff       	call   80102a72 <kfree>
      *pte = 0;
8010875c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010875f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108765:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010876c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108772:	0f 82 74 ff ff ff    	jb     801086ec <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108778:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010877b:	c9                   	leave  
8010877c:	c3                   	ret    

8010877d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010877d:	55                   	push   %ebp
8010877e:	89 e5                	mov    %esp,%ebp
80108780:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108783:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108787:	75 0c                	jne    80108795 <freevm+0x18>
    panic("freevm: no pgdir");
80108789:	c7 04 24 fb 90 10 80 	movl   $0x801090fb,(%esp)
80108790:	e8 a8 7d ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108795:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010879c:	00 
8010879d:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801087a4:	80 
801087a5:	8b 45 08             	mov    0x8(%ebp),%eax
801087a8:	89 04 24             	mov    %eax,(%esp)
801087ab:	e8 11 ff ff ff       	call   801086c1 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801087b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801087b7:	eb 3c                	jmp    801087f5 <freevm+0x78>
    if(pgdir[i] & PTE_P){
801087b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087bc:	c1 e0 02             	shl    $0x2,%eax
801087bf:	03 45 08             	add    0x8(%ebp),%eax
801087c2:	8b 00                	mov    (%eax),%eax
801087c4:	83 e0 01             	and    $0x1,%eax
801087c7:	84 c0                	test   %al,%al
801087c9:	74 26                	je     801087f1 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801087cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ce:	c1 e0 02             	shl    $0x2,%eax
801087d1:	03 45 08             	add    0x8(%ebp),%eax
801087d4:	8b 00                	mov    (%eax),%eax
801087d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087db:	89 04 24             	mov    %eax,(%esp)
801087de:	e8 85 f4 ff ff       	call   80107c68 <p2v>
801087e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801087e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087e9:	89 04 24             	mov    %eax,(%esp)
801087ec:	e8 81 a2 ff ff       	call   80102a72 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801087f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801087f5:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801087fc:	76 bb                	jbe    801087b9 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801087fe:	8b 45 08             	mov    0x8(%ebp),%eax
80108801:	89 04 24             	mov    %eax,(%esp)
80108804:	e8 69 a2 ff ff       	call   80102a72 <kfree>
}
80108809:	c9                   	leave  
8010880a:	c3                   	ret    

8010880b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010880b:	55                   	push   %ebp
8010880c:	89 e5                	mov    %esp,%ebp
8010880e:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108811:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108818:	00 
80108819:	8b 45 0c             	mov    0xc(%ebp),%eax
8010881c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108820:	8b 45 08             	mov    0x8(%ebp),%eax
80108823:	89 04 24             	mov    %eax,(%esp)
80108826:	e8 c0 f8 ff ff       	call   801080eb <walkpgdir>
8010882b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010882e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108832:	75 0c                	jne    80108840 <clearpteu+0x35>
    panic("clearpteu");
80108834:	c7 04 24 0c 91 10 80 	movl   $0x8010910c,(%esp)
8010883b:	e8 fd 7c ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80108840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108843:	8b 00                	mov    (%eax),%eax
80108845:	89 c2                	mov    %eax,%edx
80108847:	83 e2 fb             	and    $0xfffffffb,%edx
8010884a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884d:	89 10                	mov    %edx,(%eax)
}
8010884f:	c9                   	leave  
80108850:	c3                   	ret    

80108851 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108851:	55                   	push   %ebp
80108852:	89 e5                	mov    %esp,%ebp
80108854:	53                   	push   %ebx
80108855:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108858:	e8 b8 f9 ff ff       	call   80108215 <setupkvm>
8010885d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108860:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108864:	75 0a                	jne    80108870 <copyuvm+0x1f>
    return 0;
80108866:	b8 00 00 00 00       	mov    $0x0,%eax
8010886b:	e9 fd 00 00 00       	jmp    8010896d <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108870:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108877:	e9 cc 00 00 00       	jmp    80108948 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010887c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108886:	00 
80108887:	89 44 24 04          	mov    %eax,0x4(%esp)
8010888b:	8b 45 08             	mov    0x8(%ebp),%eax
8010888e:	89 04 24             	mov    %eax,(%esp)
80108891:	e8 55 f8 ff ff       	call   801080eb <walkpgdir>
80108896:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108899:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010889d:	75 0c                	jne    801088ab <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
8010889f:	c7 04 24 16 91 10 80 	movl   $0x80109116,(%esp)
801088a6:	e8 92 7c ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
801088ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088ae:	8b 00                	mov    (%eax),%eax
801088b0:	83 e0 01             	and    $0x1,%eax
801088b3:	85 c0                	test   %eax,%eax
801088b5:	75 0c                	jne    801088c3 <copyuvm+0x72>
      panic("copyuvm: page not present");
801088b7:	c7 04 24 30 91 10 80 	movl   $0x80109130,(%esp)
801088be:	e8 7a 7c ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801088c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088c6:	8b 00                	mov    (%eax),%eax
801088c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801088d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088d3:	8b 00                	mov    (%eax),%eax
801088d5:	25 ff 0f 00 00       	and    $0xfff,%eax
801088da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801088dd:	e8 29 a2 ff ff       	call   80102b0b <kalloc>
801088e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
801088e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801088e9:	74 6e                	je     80108959 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801088eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088ee:	89 04 24             	mov    %eax,(%esp)
801088f1:	e8 72 f3 ff ff       	call   80107c68 <p2v>
801088f6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801088fd:	00 
801088fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80108902:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108905:	89 04 24             	mov    %eax,(%esp)
80108908:	e8 3c cd ff ff       	call   80105649 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010890d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108910:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108913:	89 04 24             	mov    %eax,(%esp)
80108916:	e8 40 f3 ff ff       	call   80107c5b <v2p>
8010891b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010891e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80108922:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108926:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010892d:	00 
8010892e:	89 54 24 04          	mov    %edx,0x4(%esp)
80108932:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108935:	89 04 24             	mov    %eax,(%esp)
80108938:	e8 44 f8 ff ff       	call   80108181 <mappages>
8010893d:	85 c0                	test   %eax,%eax
8010893f:	78 1b                	js     8010895c <copyuvm+0x10b>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108941:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010894b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010894e:	0f 82 28 ff ff ff    	jb     8010887c <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108957:	eb 14                	jmp    8010896d <copyuvm+0x11c>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108959:	90                   	nop
8010895a:	eb 01                	jmp    8010895d <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
8010895c:	90                   	nop
  }
  return d;

bad:
  freevm(d);
8010895d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108960:	89 04 24             	mov    %eax,(%esp)
80108963:	e8 15 fe ff ff       	call   8010877d <freevm>
  return 0;
80108968:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010896d:	83 c4 44             	add    $0x44,%esp
80108970:	5b                   	pop    %ebx
80108971:	5d                   	pop    %ebp
80108972:	c3                   	ret    

80108973 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108973:	55                   	push   %ebp
80108974:	89 e5                	mov    %esp,%ebp
80108976:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108979:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108980:	00 
80108981:	8b 45 0c             	mov    0xc(%ebp),%eax
80108984:	89 44 24 04          	mov    %eax,0x4(%esp)
80108988:	8b 45 08             	mov    0x8(%ebp),%eax
8010898b:	89 04 24             	mov    %eax,(%esp)
8010898e:	e8 58 f7 ff ff       	call   801080eb <walkpgdir>
80108993:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108999:	8b 00                	mov    (%eax),%eax
8010899b:	83 e0 01             	and    $0x1,%eax
8010899e:	85 c0                	test   %eax,%eax
801089a0:	75 07                	jne    801089a9 <uva2ka+0x36>
    return 0;
801089a2:	b8 00 00 00 00       	mov    $0x0,%eax
801089a7:	eb 25                	jmp    801089ce <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801089a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ac:	8b 00                	mov    (%eax),%eax
801089ae:	83 e0 04             	and    $0x4,%eax
801089b1:	85 c0                	test   %eax,%eax
801089b3:	75 07                	jne    801089bc <uva2ka+0x49>
    return 0;
801089b5:	b8 00 00 00 00       	mov    $0x0,%eax
801089ba:	eb 12                	jmp    801089ce <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801089bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089bf:	8b 00                	mov    (%eax),%eax
801089c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089c6:	89 04 24             	mov    %eax,(%esp)
801089c9:	e8 9a f2 ff ff       	call   80107c68 <p2v>
}
801089ce:	c9                   	leave  
801089cf:	c3                   	ret    

801089d0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801089d0:	55                   	push   %ebp
801089d1:	89 e5                	mov    %esp,%ebp
801089d3:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801089d6:	8b 45 10             	mov    0x10(%ebp),%eax
801089d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801089dc:	e9 8b 00 00 00       	jmp    80108a6c <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
801089e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801089e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801089ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801089f3:	8b 45 08             	mov    0x8(%ebp),%eax
801089f6:	89 04 24             	mov    %eax,(%esp)
801089f9:	e8 75 ff ff ff       	call   80108973 <uva2ka>
801089fe:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108a01:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108a05:	75 07                	jne    80108a0e <copyout+0x3e>
      return -1;
80108a07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108a0c:	eb 6d                	jmp    80108a7b <copyout+0xab>
    n = PGSIZE - (va - va0);
80108a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a11:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108a14:	89 d1                	mov    %edx,%ecx
80108a16:	29 c1                	sub    %eax,%ecx
80108a18:	89 c8                	mov    %ecx,%eax
80108a1a:	05 00 10 00 00       	add    $0x1000,%eax
80108a1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108a22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a25:	3b 45 14             	cmp    0x14(%ebp),%eax
80108a28:	76 06                	jbe    80108a30 <copyout+0x60>
      n = len;
80108a2a:	8b 45 14             	mov    0x14(%ebp),%eax
80108a2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108a30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a33:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a36:	89 d1                	mov    %edx,%ecx
80108a38:	29 c1                	sub    %eax,%ecx
80108a3a:	89 c8                	mov    %ecx,%eax
80108a3c:	03 45 e8             	add    -0x18(%ebp),%eax
80108a3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108a42:	89 54 24 08          	mov    %edx,0x8(%esp)
80108a46:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a49:	89 54 24 04          	mov    %edx,0x4(%esp)
80108a4d:	89 04 24             	mov    %eax,(%esp)
80108a50:	e8 f4 cb ff ff       	call   80105649 <memmove>
    len -= n;
80108a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a58:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108a5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a5e:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108a61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a64:	05 00 10 00 00       	add    $0x1000,%eax
80108a69:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108a6c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108a70:	0f 85 6b ff ff ff    	jne    801089e1 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108a76:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a7b:	c9                   	leave  
80108a7c:	c3                   	ret    
