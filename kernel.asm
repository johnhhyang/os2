
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
8010003a:	c7 44 24 04 00 8b 10 	movl   $0x80108b00,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
80100049:	e8 84 52 00 00       	call   801052d2 <initlock>

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
801000bd:	e8 31 52 00 00       	call   801052f3 <acquire>

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
80100104:	e8 4c 52 00 00       	call   80105355 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 80 d6 10 	movl   $0x8010d680,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 c9 4b 00 00       	call   80104ced <sleep>
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
8010017c:	e8 d4 51 00 00       	call   80105355 <release>
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
80100198:	c7 04 24 07 8b 10 80 	movl   $0x80108b07,(%esp)
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
801001ef:	c7 04 24 18 8b 10 80 	movl   $0x80108b18,(%esp)
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
80100229:	c7 04 24 1f 8b 10 80 	movl   $0x80108b1f,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
8010023c:	e8 b2 50 00 00       	call   801052f3 <acquire>

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
8010029d:	e8 27 4b 00 00       	call   80104dc9 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
801002a9:	e8 a7 50 00 00       	call   80105355 <release>
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
801003bc:	e8 32 4f 00 00       	call   801052f3 <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 26 8b 10 80 	movl   $0x80108b26,(%esp)
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
801004af:	c7 45 ec 2f 8b 10 80 	movl   $0x80108b2f,-0x14(%ebp)
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
80100536:	e8 1a 4e 00 00       	call   80105355 <release>
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
80100562:	c7 04 24 36 8b 10 80 	movl   $0x80108b36,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 45 8b 10 80 	movl   $0x80108b45,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 0d 4e 00 00       	call   801053a4 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 47 8b 10 80 	movl   $0x80108b47,(%esp)
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
801006b2:	e8 5e 4f 00 00       	call   80105615 <memmove>
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
801006e1:	e8 5c 4e 00 00       	call   80105542 <memset>
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
80100776:	e8 d6 69 00 00       	call   80107151 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 ca 69 00 00       	call   80107151 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 be 69 00 00       	call   80107151 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 b1 69 00 00       	call   80107151 <uartputc>
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
801007ba:	e8 34 4b 00 00       	call   801052f3 <acquire>
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
801007ea:	e8 80 46 00 00       	call   80104e6f <procdump>
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
801008f7:	e8 cd 44 00 00       	call   80104dc9 <wakeup>
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
8010091e:	e8 32 4a 00 00       	call   80105355 <release>
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
80100943:	e8 ab 49 00 00       	call   801052f3 <acquire>
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
80100961:	e8 ef 49 00 00       	call   80105355 <release>
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
8010098a:	e8 5e 43 00 00       	call   80104ced <sleep>
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
80100a08:	e8 48 49 00 00       	call   80105355 <release>
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
80100a3e:	e8 b0 48 00 00       	call   801052f3 <acquire>
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
80100a78:	e8 d8 48 00 00       	call   80105355 <release>
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
80100a93:	c7 44 24 04 4b 8b 10 	movl   $0x80108b4b,0x4(%esp)
80100a9a:	80 
80100a9b:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100aa2:	e8 2b 48 00 00       	call   801052d2 <initlock>
  initlock(&input.lock, "input");
80100aa7:	c7 44 24 04 53 8b 10 	movl   $0x80108b53,0x4(%esp)
80100aae:	80 
80100aaf:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100ab6:	e8 17 48 00 00       	call   801052d2 <initlock>

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
80100b7e:	e8 12 77 00 00       	call   80108295 <setupkvm>
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
80100c17:	e8 4b 7a 00 00       	call   80108667 <allocuvm>
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
80100c54:	e8 1f 79 00 00       	call   80108578 <loaduvm>
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
80100cc4:	e8 9e 79 00 00       	call   80108667 <allocuvm>
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
80100ce8:	e8 9e 7b 00 00       	call   8010888b <clearpteu>
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
80100d17:	e8 a4 4a 00 00       	call   801057c0 <strlen>
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
80100d35:	e8 86 4a 00 00       	call   801057c0 <strlen>
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
80100d5f:	e8 ec 7c 00 00       	call   80108a50 <copyout>
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
80100dff:	e8 4c 7c 00 00       	call   80108a50 <copyout>
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
80100e56:	e8 17 49 00 00       	call   80105772 <safestrcpy>

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
80100ea8:	e8 d9 74 00 00       	call   80108386 <switchuvm>
  freevm(oldpgdir);
80100ead:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100eb0:	89 04 24             	mov    %eax,(%esp)
80100eb3:	e8 45 79 00 00       	call   801087fd <freevm>
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
80100eea:	e8 0e 79 00 00       	call   801087fd <freevm>
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
80100f12:	c7 44 24 04 59 8b 10 	movl   $0x80108b59,0x4(%esp)
80100f19:	80 
80100f1a:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f21:	e8 ac 43 00 00       	call   801052d2 <initlock>
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
80100f35:	e8 b9 43 00 00       	call   801052f3 <acquire>
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
80100f5e:	e8 f2 43 00 00       	call   80105355 <release>
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
80100f7c:	e8 d4 43 00 00       	call   80105355 <release>
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
80100f95:	e8 59 43 00 00       	call   801052f3 <acquire>
  if(f->ref < 1)
80100f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9d:	8b 40 04             	mov    0x4(%eax),%eax
80100fa0:	85 c0                	test   %eax,%eax
80100fa2:	7f 0c                	jg     80100fb0 <filedup+0x28>
    panic("filedup");
80100fa4:	c7 04 24 60 8b 10 80 	movl   $0x80108b60,(%esp)
80100fab:	e8 8d f5 ff ff       	call   8010053d <panic>
  f->ref++;
80100fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb3:	8b 40 04             	mov    0x4(%eax),%eax
80100fb6:	8d 50 01             	lea    0x1(%eax),%edx
80100fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fbc:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fbf:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100fc6:	e8 8a 43 00 00       	call   80105355 <release>
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
80100fdd:	e8 11 43 00 00       	call   801052f3 <acquire>
  if(f->ref < 1)
80100fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe5:	8b 40 04             	mov    0x4(%eax),%eax
80100fe8:	85 c0                	test   %eax,%eax
80100fea:	7f 0c                	jg     80100ff8 <fileclose+0x28>
    panic("fileclose");
80100fec:	c7 04 24 68 8b 10 80 	movl   $0x80108b68,(%esp)
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
80101018:	e8 38 43 00 00       	call   80105355 <release>
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
80101062:	e8 ee 42 00 00       	call   80105355 <release>
  
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
801011a3:	c7 04 24 72 8b 10 80 	movl   $0x80108b72,(%esp)
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
801012af:	c7 04 24 7b 8b 10 80 	movl   $0x80108b7b,(%esp)
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
801012e4:	c7 04 24 8b 8b 10 80 	movl   $0x80108b8b,(%esp)
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
8010132c:	e8 e4 42 00 00       	call   80105615 <memmove>
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
80101372:	e8 cb 41 00 00       	call   80105542 <memset>
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
801014da:	c7 04 24 95 8b 10 80 	movl   $0x80108b95,(%esp)
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
80101571:	c7 04 24 ab 8b 10 80 	movl   $0x80108bab,(%esp)
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
801015c5:	c7 44 24 04 be 8b 10 	movl   $0x80108bbe,0x4(%esp)
801015cc:	80 
801015cd:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801015d4:	e8 f9 3c 00 00       	call   801052d2 <initlock>
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
80101656:	e8 e7 3e 00 00       	call   80105542 <memset>
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
801016ac:	c7 04 24 c5 8b 10 80 	movl   $0x80108bc5,(%esp)
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
80101753:	e8 bd 3e 00 00       	call   80105615 <memmove>
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
8010177d:	e8 71 3b 00 00       	call   801052f3 <acquire>

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
801017c7:	e8 89 3b 00 00       	call   80105355 <release>
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
801017fa:	c7 04 24 d7 8b 10 80 	movl   $0x80108bd7,(%esp)
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
80101838:	e8 18 3b 00 00       	call   80105355 <release>

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
8010184f:	e8 9f 3a 00 00       	call   801052f3 <acquire>
  ip->ref++;
80101854:	8b 45 08             	mov    0x8(%ebp),%eax
80101857:	8b 40 08             	mov    0x8(%eax),%eax
8010185a:	8d 50 01             	lea    0x1(%eax),%edx
8010185d:	8b 45 08             	mov    0x8(%ebp),%eax
80101860:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101863:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010186a:	e8 e6 3a 00 00       	call   80105355 <release>
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
8010188a:	c7 04 24 e7 8b 10 80 	movl   $0x80108be7,(%esp)
80101891:	e8 a7 ec ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101896:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010189d:	e8 51 3a 00 00       	call   801052f3 <acquire>
  while(ip->flags & I_BUSY)
801018a2:	eb 13                	jmp    801018b7 <ilock+0x43>
    sleep(ip, &icache.lock);
801018a4:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
801018ab:	80 
801018ac:	8b 45 08             	mov    0x8(%ebp),%eax
801018af:	89 04 24             	mov    %eax,(%esp)
801018b2:	e8 36 34 00 00       	call   80104ced <sleep>

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
801018dc:	e8 74 3a 00 00       	call   80105355 <release>

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
80101987:	e8 89 3c 00 00       	call   80105615 <memmove>
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
801019b4:	c7 04 24 ed 8b 10 80 	movl   $0x80108bed,(%esp)
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
801019e5:	c7 04 24 fc 8b 10 80 	movl   $0x80108bfc,(%esp)
801019ec:	e8 4c eb ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
801019f1:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801019f8:	e8 f6 38 00 00       	call   801052f3 <acquire>
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
80101a14:	e8 b0 33 00 00       	call   80104dc9 <wakeup>
  release(&icache.lock);
80101a19:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a20:	e8 30 39 00 00       	call   80105355 <release>
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
80101a34:	e8 ba 38 00 00       	call   801052f3 <acquire>
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
80101a72:	c7 04 24 04 8c 10 80 	movl   $0x80108c04,(%esp)
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
80101a96:	e8 ba 38 00 00       	call   80105355 <release>
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
80101ac1:	e8 2d 38 00 00       	call   801052f3 <acquire>
    ip->flags = 0;
80101ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad3:	89 04 24             	mov    %eax,(%esp)
80101ad6:	e8 ee 32 00 00       	call   80104dc9 <wakeup>
  }
  ip->ref--;
80101adb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ade:	8b 40 08             	mov    0x8(%eax),%eax
80101ae1:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101aea:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101af1:	e8 5f 38 00 00       	call   80105355 <release>
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
80101c06:	c7 04 24 0e 8c 10 80 	movl   $0x80108c0e,(%esp)
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
80101e9e:	e8 72 37 00 00       	call   80105615 <memmove>
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
80102004:	e8 0c 36 00 00       	call   80105615 <memmove>
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
80102086:	e8 2e 36 00 00       	call   801056b9 <strncmp>
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
801020a0:	c7 04 24 21 8c 10 80 	movl   $0x80108c21,(%esp)
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
801020de:	c7 04 24 33 8c 10 80 	movl   $0x80108c33,(%esp)
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
801021c2:	c7 04 24 33 8c 10 80 	movl   $0x80108c33,(%esp)
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
80102208:	e8 04 35 00 00       	call   80105711 <strncpy>
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
8010223a:	c7 04 24 40 8c 10 80 	movl   $0x80108c40,(%esp)
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
801022c1:	e8 4f 33 00 00       	call   80105615 <memmove>
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
801022dc:	e8 34 33 00 00       	call   80105615 <memmove>
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
80102538:	c7 44 24 04 48 8c 10 	movl   $0x80108c48,0x4(%esp)
8010253f:	80 
80102540:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102547:	e8 86 2d 00 00       	call   801052d2 <initlock>
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
801025e4:	c7 04 24 4c 8c 10 80 	movl   $0x80108c4c,(%esp)
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
8010270a:	e8 e4 2b 00 00       	call   801052f3 <acquire>
  if((b = idequeue) == 0){
8010270f:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102714:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102717:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010271b:	75 11                	jne    8010272e <ideintr+0x31>
    release(&idelock);
8010271d:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102724:	e8 2c 2c 00 00       	call   80105355 <release>
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
80102797:	e8 2d 26 00 00       	call   80104dc9 <wakeup>
  
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
801027b9:	e8 97 2b 00 00       	call   80105355 <release>
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
801027d2:	c7 04 24 55 8c 10 80 	movl   $0x80108c55,(%esp)
801027d9:	e8 5f dd ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027de:	8b 45 08             	mov    0x8(%ebp),%eax
801027e1:	8b 00                	mov    (%eax),%eax
801027e3:	83 e0 06             	and    $0x6,%eax
801027e6:	83 f8 02             	cmp    $0x2,%eax
801027e9:	75 0c                	jne    801027f7 <iderw+0x37>
    panic("iderw: nothing to do");
801027eb:	c7 04 24 69 8c 10 80 	movl   $0x80108c69,(%esp)
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
8010280a:	c7 04 24 7e 8c 10 80 	movl   $0x80108c7e,(%esp)
80102811:	e8 27 dd ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102816:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
8010281d:	e8 d1 2a 00 00       	call   801052f3 <acquire>

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
80102876:	e8 72 24 00 00       	call   80104ced <sleep>
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
80102892:	e8 be 2a 00 00       	call   80105355 <release>
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
80102922:	c7 04 24 9c 8c 10 80 	movl   $0x80108c9c,(%esp)
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
801029e3:	c7 44 24 04 ce 8c 10 	movl   $0x80108cce,0x4(%esp)
801029ea:	80 
801029eb:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
801029f2:	e8 db 28 00 00       	call   801052d2 <initlock>
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
80102a84:	81 7d 08 5c 64 11 80 	cmpl   $0x8011645c,0x8(%ebp)
80102a8b:	72 12                	jb     80102a9f <kfree+0x2d>
80102a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a90:	89 04 24             	mov    %eax,(%esp)
80102a93:	e8 38 ff ff ff       	call   801029d0 <v2p>
80102a98:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a9d:	76 0c                	jbe    80102aab <kfree+0x39>
    panic("kfree");
80102a9f:	c7 04 24 d3 8c 10 80 	movl   $0x80108cd3,(%esp)
80102aa6:	e8 92 da ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102aab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102ab2:	00 
80102ab3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102aba:	00 
80102abb:	8b 45 08             	mov    0x8(%ebp),%eax
80102abe:	89 04 24             	mov    %eax,(%esp)
80102ac1:	e8 7c 2a 00 00       	call   80105542 <memset>

  if(kmem.use_lock)
80102ac6:	a1 74 32 11 80       	mov    0x80113274,%eax
80102acb:	85 c0                	test   %eax,%eax
80102acd:	74 0c                	je     80102adb <kfree+0x69>
    acquire(&kmem.lock);
80102acf:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102ad6:	e8 18 28 00 00       	call   801052f3 <acquire>
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
80102b04:	e8 4c 28 00 00       	call   80105355 <release>
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
80102b21:	e8 cd 27 00 00       	call   801052f3 <acquire>
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
80102b4e:	e8 02 28 00 00       	call   80105355 <release>
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
80102ef4:	c7 04 24 dc 8c 10 80 	movl   $0x80108cdc,(%esp)
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
80103158:	e8 5c 24 00 00       	call   801055b9 <memcmp>
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
8010325a:	c7 44 24 04 08 8d 10 	movl   $0x80108d08,0x4(%esp)
80103261:	80 
80103262:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103269:	e8 64 20 00 00       	call   801052d2 <initlock>
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
8010331c:	e8 f4 22 00 00       	call   80105615 <memmove>
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
8010346e:	e8 80 1e 00 00       	call   801052f3 <acquire>
  while(1){
    if(log.committing){
80103473:	a1 c0 32 11 80       	mov    0x801132c0,%eax
80103478:	85 c0                	test   %eax,%eax
8010347a:	74 16                	je     80103492 <begin_op+0x31>
      sleep(&log, &log.lock);
8010347c:	c7 44 24 04 80 32 11 	movl   $0x80113280,0x4(%esp)
80103483:	80 
80103484:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010348b:	e8 5d 18 00 00       	call   80104ced <sleep>
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
801034bf:	e8 29 18 00 00       	call   80104ced <sleep>
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
801034da:	e8 76 1e 00 00       	call   80105355 <release>
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
801034f6:	e8 f8 1d 00 00       	call   801052f3 <acquire>
  log.outstanding -= 1;
801034fb:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103500:	83 e8 01             	sub    $0x1,%eax
80103503:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
80103508:	a1 c0 32 11 80       	mov    0x801132c0,%eax
8010350d:	85 c0                	test   %eax,%eax
8010350f:	74 0c                	je     8010351d <end_op+0x3b>
    panic("log.committing");
80103511:	c7 04 24 0c 8d 10 80 	movl   $0x80108d0c,(%esp)
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
80103540:	e8 84 18 00 00       	call   80104dc9 <wakeup>
  }
  release(&log.lock);
80103545:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010354c:	e8 04 1e 00 00       	call   80105355 <release>

  if(do_commit){
80103551:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103555:	74 33                	je     8010358a <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103557:	e8 db 00 00 00       	call   80103637 <commit>
    acquire(&log.lock);
8010355c:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103563:	e8 8b 1d 00 00       	call   801052f3 <acquire>
    log.committing = 0;
80103568:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
8010356f:	00 00 00 
    wakeup(&log);
80103572:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103579:	e8 4b 18 00 00       	call   80104dc9 <wakeup>
    release(&log.lock);
8010357e:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103585:	e8 cb 1d 00 00       	call   80105355 <release>
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
801035fd:	e8 13 20 00 00       	call   80105615 <memmove>
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
80103688:	c7 04 24 1b 8d 10 80 	movl   $0x80108d1b,(%esp)
8010368f:	e8 a9 ce ff ff       	call   8010053d <panic>
  if (log.outstanding < 1)
80103694:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103699:	85 c0                	test   %eax,%eax
8010369b:	7f 0c                	jg     801036a9 <log_write+0x43>
    panic("log_write outside of trans");
8010369d:	c7 04 24 31 8d 10 80 	movl   $0x80108d31,(%esp)
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
80103768:	c7 04 24 5c 64 11 80 	movl   $0x8011645c,(%esp)
8010376f:	e8 69 f2 ff ff       	call   801029dd <kinit1>
  kvmalloc();      // kernel page table
80103774:	e8 d9 4b 00 00       	call   80108352 <kvmalloc>
  mpinit();        // collect info about this machine
80103779:	e8 53 04 00 00       	call   80103bd1 <mpinit>
  lapicinit();
8010377e:	e8 e3 f5 ff ff       	call   80102d66 <lapicinit>
  seginit();       // set up segments
80103783:	e8 6d 45 00 00       	call   80107cf5 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103788:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010378e:	0f b6 00             	movzbl (%eax),%eax
80103791:	0f b6 c0             	movzbl %al,%eax
80103794:	89 44 24 04          	mov    %eax,0x4(%esp)
80103798:	c7 04 24 4c 8d 10 80 	movl   $0x80108d4c,(%esp)
8010379f:	e8 fd cb ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
801037a4:	e8 8d 06 00 00       	call   80103e36 <picinit>
  ioapicinit();    // another interrupt controller
801037a9:	e8 1f f1 ff ff       	call   801028cd <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801037ae:	e8 da d2 ff ff       	call   80100a8d <consoleinit>
  uartinit();      // serial port
801037b3:	e8 88 38 00 00       	call   80107040 <uartinit>
  pinit();         // process table
801037b8:	e8 8e 0b 00 00       	call   8010434b <pinit>
  tvinit();        // trap vectors
801037bd:	e8 21 34 00 00       	call   80106be3 <tvinit>
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
801037df:	e8 42 33 00 00       	call   80106b26 <timerinit>
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
8010380d:	e8 57 4b 00 00       	call   80108369 <switchkvm>
  seginit();
80103812:	e8 de 44 00 00       	call   80107cf5 <seginit>
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
80103837:	c7 04 24 63 8d 10 80 	movl   $0x80108d63,(%esp)
8010383e:	e8 5e cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80103843:	e8 0f 35 00 00       	call   80106d57 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103848:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010384e:	05 a8 00 00 00       	add    $0xa8,%eax
80103853:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010385a:	00 
8010385b:	89 04 24             	mov    %eax,(%esp)
8010385e:	e8 cf fe ff ff       	call   80103732 <xchg>
  scheduler();     // start running processes
80103863:	e8 d9 12 00 00       	call   80104b41 <scheduler>

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
80103895:	e8 7b 1d 00 00       	call   80105615 <memmove>

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
80103a24:	c7 44 24 04 74 8d 10 	movl   $0x80108d74,0x4(%esp)
80103a2b:	80 
80103a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a2f:	89 04 24             	mov    %eax,(%esp)
80103a32:	e8 82 1b 00 00       	call   801055b9 <memcmp>
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
80103b65:	c7 44 24 04 79 8d 10 	movl   $0x80108d79,0x4(%esp)
80103b6c:	80 
80103b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b70:	89 04 24             	mov    %eax,(%esp)
80103b73:	e8 41 1a 00 00       	call   801055b9 <memcmp>
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
80103c3e:	8b 04 85 bc 8d 10 80 	mov    -0x7fef7244(,%eax,4),%eax
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
80103c77:	c7 04 24 7e 8d 10 80 	movl   $0x80108d7e,(%esp)
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
80103d0a:	c7 04 24 9c 8d 10 80 	movl   $0x80108d9c,(%esp)
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
8010400f:	c7 44 24 04 d0 8d 10 	movl   $0x80108dd0,0x4(%esp)
80104016:	80 
80104017:	89 04 24             	mov    %eax,(%esp)
8010401a:	e8 b3 12 00 00       	call   801052d2 <initlock>
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
801040c7:	e8 27 12 00 00       	call   801052f3 <acquire>
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
801040ea:	e8 da 0c 00 00       	call   80104dc9 <wakeup>
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
80104109:	e8 bb 0c 00 00       	call   80104dc9 <wakeup>
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
8010412e:	e8 22 12 00 00       	call   80105355 <release>
    kfree((char*)p);
80104133:	8b 45 08             	mov    0x8(%ebp),%eax
80104136:	89 04 24             	mov    %eax,(%esp)
80104139:	e8 34 e9 ff ff       	call   80102a72 <kfree>
8010413e:	eb 0b                	jmp    8010414b <pipeclose+0x90>
  } else
    release(&p->lock);
80104140:	8b 45 08             	mov    0x8(%ebp),%eax
80104143:	89 04 24             	mov    %eax,(%esp)
80104146:	e8 0a 12 00 00       	call   80105355 <release>
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
8010415a:	e8 94 11 00 00       	call   801052f3 <acquire>
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
8010418b:	e8 c5 11 00 00       	call   80105355 <release>
        return -1;
80104190:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104195:	e9 9d 00 00 00       	jmp    80104237 <pipewrite+0xea>
      }
      wakeup(&p->nread);
8010419a:	8b 45 08             	mov    0x8(%ebp),%eax
8010419d:	05 34 02 00 00       	add    $0x234,%eax
801041a2:	89 04 24             	mov    %eax,(%esp)
801041a5:	e8 1f 0c 00 00       	call   80104dc9 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041aa:	8b 45 08             	mov    0x8(%ebp),%eax
801041ad:	8b 55 08             	mov    0x8(%ebp),%edx
801041b0:	81 c2 38 02 00 00    	add    $0x238,%edx
801041b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801041ba:	89 14 24             	mov    %edx,(%esp)
801041bd:	e8 2b 0b 00 00       	call   80104ced <sleep>
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
80104224:	e8 a0 0b 00 00       	call   80104dc9 <wakeup>
  release(&p->lock);
80104229:	8b 45 08             	mov    0x8(%ebp),%eax
8010422c:	89 04 24             	mov    %eax,(%esp)
8010422f:	e8 21 11 00 00       	call   80105355 <release>
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
8010424a:	e8 a4 10 00 00       	call   801052f3 <acquire>
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
80104264:	e8 ec 10 00 00       	call   80105355 <release>
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
80104286:	e8 62 0a 00 00       	call   80104ced <sleep>
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
80104316:	e8 ae 0a 00 00       	call   80104dc9 <wakeup>
  release(&p->lock);
8010431b:	8b 45 08             	mov    0x8(%ebp),%eax
8010431e:	89 04 24             	mov    %eax,(%esp)
80104321:	e8 2f 10 00 00       	call   80105355 <release>
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
80104351:	c7 44 24 04 d5 8d 10 	movl   $0x80108dd5,0x4(%esp)
80104358:	80 
80104359:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104360:	e8 6d 0f 00 00       	call   801052d2 <initlock>
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
80104374:	e8 7a 0f 00 00       	call   801052f3 <acquire>
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
8010438c:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104393:	81 7d f4 b4 5b 11 80 	cmpl   $0x80115bb4,-0xc(%ebp)
8010439a:	72 e6                	jb     80104382 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010439c:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801043a3:	e8 ad 0f 00 00       	call   80105355 <release>
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
801043d7:	e8 79 0f 00 00       	call   80105355 <release>

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
80104421:	ba 98 6b 10 80       	mov    $0x80106b98,%edx
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
80104451:	e8 ec 10 00 00       	call   80105542 <memset>
  p->context->eip = (uint)forkret;
80104456:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104459:	8b 40 1c             	mov    0x1c(%eax),%eax
8010445c:	ba c1 4c 10 80       	mov    $0x80104cc1,%edx
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
8010447f:	e8 11 3e 00 00       	call   80108295 <setupkvm>
80104484:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104487:	89 42 04             	mov    %eax,0x4(%edx)
8010448a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448d:	8b 40 04             	mov    0x4(%eax),%eax
80104490:	85 c0                	test   %eax,%eax
80104492:	75 0c                	jne    801044a0 <userinit+0x37>
    panic("userinit: out of memory?");
80104494:	c7 04 24 dc 8d 10 80 	movl   $0x80108ddc,(%esp)
8010449b:	e8 9d c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044a0:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a8:	8b 40 04             	mov    0x4(%eax),%eax
801044ab:	89 54 24 08          	mov    %edx,0x8(%esp)
801044af:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
801044b6:	80 
801044b7:	89 04 24             	mov    %eax,(%esp)
801044ba:	e8 2e 40 00 00       	call   801084ed <inituvm>
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
801044e1:	e8 5c 10 00 00       	call   80105542 <memset>
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
8010455b:	c7 44 24 04 f5 8d 10 	movl   $0x80108df5,0x4(%esp)
80104562:	80 
80104563:	89 04 24             	mov    %eax,(%esp)
80104566:	e8 07 12 00 00       	call   80105772 <safestrcpy>
  p->cwd = namei("/");
8010456b:	c7 04 24 fe 8d 10 80 	movl   $0x80108dfe,(%esp)
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
801045bf:	e8 a3 40 00 00       	call   80108667 <allocuvm>
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
801045f9:	e8 43 41 00 00       	call   80108741 <deallocuvm>
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
80104622:	e8 5f 3d 00 00       	call   80108386 <switchuvm>
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
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104637:	e8 2b fd ff ff       	call   80104367 <allocproc>
8010463c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010463f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104643:	75 0a                	jne    8010464f <fork+0x21>
    return -1;
80104645:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010464a:	e9 52 01 00 00       	jmp    801047a1 <fork+0x173>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010464f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104655:	8b 10                	mov    (%eax),%edx
80104657:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010465d:	8b 40 04             	mov    0x4(%eax),%eax
80104660:	89 54 24 04          	mov    %edx,0x4(%esp)
80104664:	89 04 24             	mov    %eax,(%esp)
80104667:	e8 65 42 00 00       	call   801088d1 <copyuvm>
8010466c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010466f:	89 42 04             	mov    %eax,0x4(%edx)
80104672:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104675:	8b 40 04             	mov    0x4(%eax),%eax
80104678:	85 c0                	test   %eax,%eax
8010467a:	75 2c                	jne    801046a8 <fork+0x7a>
    kfree(np->kstack);
8010467c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010467f:	8b 40 08             	mov    0x8(%eax),%eax
80104682:	89 04 24             	mov    %eax,(%esp)
80104685:	e8 e8 e3 ff ff       	call   80102a72 <kfree>
    np->kstack = 0;
8010468a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010468d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104694:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104697:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010469e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046a3:	e9 f9 00 00 00       	jmp    801047a1 <fork+0x173>
  }
  np->sz = proc->sz;
801046a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046ae:	8b 10                	mov    (%eax),%edx
801046b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046b3:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046b5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046bf:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c5:	8b 50 18             	mov    0x18(%eax),%edx
801046c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046ce:	8b 40 18             	mov    0x18(%eax),%eax
801046d1:	89 c3                	mov    %eax,%ebx
801046d3:	b8 13 00 00 00       	mov    $0x13,%eax
801046d8:	89 d7                	mov    %edx,%edi
801046da:	89 de                	mov    %ebx,%esi
801046dc:	89 c1                	mov    %eax,%ecx
801046de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e3:	8b 40 18             	mov    0x18(%eax),%eax
801046e6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801046ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801046f4:	eb 3d                	jmp    80104733 <fork+0x105>
    if(proc->ofile[i])
801046f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046ff:	83 c2 08             	add    $0x8,%edx
80104702:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104706:	85 c0                	test   %eax,%eax
80104708:	74 25                	je     8010472f <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
8010470a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104710:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104713:	83 c2 08             	add    $0x8,%edx
80104716:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010471a:	89 04 24             	mov    %eax,(%esp)
8010471d:	e8 66 c8 ff ff       	call   80100f88 <filedup>
80104722:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104725:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104728:	83 c1 08             	add    $0x8,%ecx
8010472b:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010472f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104733:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104737:	7e bd                	jle    801046f6 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104739:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010473f:	8b 40 68             	mov    0x68(%eax),%eax
80104742:	89 04 24             	mov    %eax,(%esp)
80104745:	e8 f8 d0 ff ff       	call   80101842 <idup>
8010474a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010474d:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104750:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104756:	8d 50 6c             	lea    0x6c(%eax),%edx
80104759:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010475c:	83 c0 6c             	add    $0x6c,%eax
8010475f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104766:	00 
80104767:	89 54 24 04          	mov    %edx,0x4(%esp)
8010476b:	89 04 24             	mov    %eax,(%esp)
8010476e:	e8 ff 0f 00 00       	call   80105772 <safestrcpy>
 
  pid = np->pid;
80104773:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104776:	8b 40 10             	mov    0x10(%eax),%eax
80104779:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
8010477c:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104783:	e8 6b 0b 00 00       	call   801052f3 <acquire>
  np->state = RUNNABLE;
80104788:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80104792:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104799:	e8 b7 0b 00 00       	call   80105355 <release>
  
  return pid;
8010479e:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047a1:	83 c4 2c             	add    $0x2c,%esp
801047a4:	5b                   	pop    %ebx
801047a5:	5e                   	pop    %esi
801047a6:	5f                   	pop    %edi
801047a7:	5d                   	pop    %ebp
801047a8:	c3                   	ret    

801047a9 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047a9:	55                   	push   %ebp
801047aa:	89 e5                	mov    %esp,%ebp
801047ac:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801047af:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047b6:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801047bb:	39 c2                	cmp    %eax,%edx
801047bd:	75 0c                	jne    801047cb <exit+0x22>
    panic("init exiting");
801047bf:	c7 04 24 00 8e 10 80 	movl   $0x80108e00,(%esp)
801047c6:	e8 72 bd ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047cb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047d2:	eb 44                	jmp    80104818 <exit+0x6f>
    if(proc->ofile[fd]){
801047d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047da:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047dd:	83 c2 08             	add    $0x8,%edx
801047e0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047e4:	85 c0                	test   %eax,%eax
801047e6:	74 2c                	je     80104814 <exit+0x6b>
      fileclose(proc->ofile[fd]);
801047e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047f1:	83 c2 08             	add    $0x8,%edx
801047f4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047f8:	89 04 24             	mov    %eax,(%esp)
801047fb:	e8 d0 c7 ff ff       	call   80100fd0 <fileclose>
      proc->ofile[fd] = 0;
80104800:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104806:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104809:	83 c2 08             	add    $0x8,%edx
8010480c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104813:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104814:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104818:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010481c:	7e b6                	jle    801047d4 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
8010481e:	e8 3e ec ff ff       	call   80103461 <begin_op>
  iput(proc->cwd);
80104823:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104829:	8b 40 68             	mov    0x68(%eax),%eax
8010482c:	89 04 24             	mov    %eax,(%esp)
8010482f:	e8 f3 d1 ff ff       	call   80101a27 <iput>
  end_op();
80104834:	e8 a9 ec ff ff       	call   801034e2 <end_op>
  proc->cwd = 0;
80104839:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483f:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104846:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
8010484d:	e8 a1 0a 00 00       	call   801052f3 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104852:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104858:	8b 40 14             	mov    0x14(%eax),%eax
8010485b:	89 04 24             	mov    %eax,(%esp)
8010485e:	e8 25 05 00 00       	call   80104d88 <wakeup1>

  // Pass abandoned children to init.
  // And kill the child threads and free their stacks
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104863:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
8010486a:	eb 3b                	jmp    801048a7 <exit+0xfe>
    if(p->parent == proc){
8010486c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010486f:	8b 50 14             	mov    0x14(%eax),%edx
80104872:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104878:	39 c2                	cmp    %eax,%edx
8010487a:	75 24                	jne    801048a0 <exit+0xf7>
      p->parent = initproc;
8010487c:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104885:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010488b:	8b 40 0c             	mov    0xc(%eax),%eax
8010488e:	83 f8 05             	cmp    $0x5,%eax
80104891:	75 0d                	jne    801048a0 <exit+0xf7>
        wakeup1(initproc);
80104893:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104898:	89 04 24             	mov    %eax,(%esp)
8010489b:	e8 e8 04 00 00       	call   80104d88 <wakeup1>
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  // And kill the child threads and free their stacks
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048a0:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801048a7:	81 7d f4 b4 5b 11 80 	cmpl   $0x80115bb4,-0xc(%ebp)
801048ae:	72 bc                	jb     8010486c <exit+0xc3>
        wakeup1(initproc);
    }
  }   

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801048b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b6:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801048bd:	e8 1b 03 00 00       	call   80104bdd <sched>
  panic("zombie exit");
801048c2:	c7 04 24 0d 8e 10 80 	movl   $0x80108e0d,(%esp)
801048c9:	e8 6f bc ff ff       	call   8010053d <panic>

801048ce <texit>:
}


void
texit(void *retval)
{
801048ce:	55                   	push   %ebp
801048cf:	89 e5                	mov    %esp,%ebp
801048d1:	83 ec 28             	sub    $0x28,%esp
  //cprintf("texit's retval parameter contains [%d]\n", retval);
  struct proc *p;
  int fd;

  if(proc == initproc)
801048d4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801048db:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801048e0:	39 c2                	cmp    %eax,%edx
801048e2:	75 0c                	jne    801048f0 <texit+0x22>
    panic("init exiting");
801048e4:	c7 04 24 00 8e 10 80 	movl   $0x80108e00,(%esp)
801048eb:	e8 4d bc ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801048f0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801048f7:	eb 44                	jmp    8010493d <texit+0x6f>
    if(proc->ofile[fd]){
801048f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104902:	83 c2 08             	add    $0x8,%edx
80104905:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104909:	85 c0                	test   %eax,%eax
8010490b:	74 2c                	je     80104939 <texit+0x6b>
      fileclose(proc->ofile[fd]);
8010490d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104913:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104916:	83 c2 08             	add    $0x8,%edx
80104919:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010491d:	89 04 24             	mov    %eax,(%esp)
80104920:	e8 ab c6 ff ff       	call   80100fd0 <fileclose>
      proc->ofile[fd] = 0;
80104925:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010492b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010492e:	83 c2 08             	add    $0x8,%edx
80104931:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104938:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104939:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010493d:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104941:	7e b6                	jle    801048f9 <texit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104943:	e8 19 eb ff ff       	call   80103461 <begin_op>
  iput(proc->cwd);
80104948:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010494e:	8b 40 68             	mov    0x68(%eax),%eax
80104951:	89 04 24             	mov    %eax,(%esp)
80104954:	e8 ce d0 ff ff       	call   80101a27 <iput>
  end_op();
80104959:	e8 84 eb ff ff       	call   801034e2 <end_op>
  proc->cwd = 0;
8010495e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104964:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010496b:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104972:	e8 7c 09 00 00       	call   801052f3 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104977:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010497d:	8b 40 14             	mov    0x14(%eax),%eax
80104980:	89 04 24             	mov    %eax,(%esp)
80104983:	e8 00 04 00 00       	call   80104d88 <wakeup1>

  // Pass abandoned children to init.
  // And kill the child threads and free their stacks
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104988:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
8010498f:	eb 6b                	jmp    801049fc <texit+0x12e>
    if(p->parent == proc){
80104991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104994:	8b 50 14             	mov    0x14(%eax),%edx
80104997:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010499d:	39 c2                	cmp    %eax,%edx
8010499f:	75 54                	jne    801049f5 <texit+0x127>
      p->parent = initproc;
801049a1:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
801049a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049aa:	89 50 14             	mov    %edx,0x14(%eax)
      // clean up the kernel stack of child threads
      if(p->isthread == 1){
801049ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801049b6:	83 f8 01             	cmp    $0x1,%eax
801049b9:	75 22                	jne    801049dd <texit+0x10f>
        p->state = UNUSED;
801049bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049be:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        kfree(p->kstack);
801049c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c8:	8b 40 08             	mov    0x8(%eax),%eax
801049cb:	89 04 24             	mov    %eax,(%esp)
801049ce:	e8 9f e0 ff ff       	call   80102a72 <kfree>
        p->kstack = 0;
801049d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
      }
      if(p->state == ZOMBIE)
801049dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e0:	8b 40 0c             	mov    0xc(%eax),%eax
801049e3:	83 f8 05             	cmp    $0x5,%eax
801049e6:	75 0d                	jne    801049f5 <texit+0x127>
        wakeup1(initproc);
801049e8:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801049ed:	89 04 24             	mov    %eax,(%esp)
801049f0:	e8 93 03 00 00       	call   80104d88 <wakeup1>
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  // And kill the child threads and free their stacks
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049f5:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801049fc:	81 7d f4 b4 5b 11 80 	cmpl   $0x80115bb4,-0xc(%ebp)
80104a03:	72 8c                	jb     80104991 <texit+0xc3>
    }
  }   

  // Jump into the scheduler, never to return.
  // Save the value of retval into proc so join can retrieve it later
  proc->retval = (int)retval;
80104a05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a0b:	8b 55 08             	mov    0x8(%ebp),%edx
80104a0e:	89 50 7c             	mov    %edx,0x7c(%eax)
  proc->state = ZOMBIE;
80104a11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a17:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a1e:	e8 ba 01 00 00       	call   80104bdd <sched>
  panic("zombie exit");
80104a23:	c7 04 24 0d 8e 10 80 	movl   $0x80108e0d,(%esp)
80104a2a:	e8 0e bb ff ff       	call   8010053d <panic>

80104a2f <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a2f:	55                   	push   %ebp
80104a30:	89 e5                	mov    %esp,%ebp
80104a32:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a35:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104a3c:	e8 b2 08 00 00       	call   801052f3 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a41:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a48:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104a4f:	e9 9d 00 00 00       	jmp    80104af1 <wait+0xc2>
      if(p->parent != proc)
80104a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a57:	8b 50 14             	mov    0x14(%eax),%edx
80104a5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a60:	39 c2                	cmp    %eax,%edx
80104a62:	0f 85 81 00 00 00    	jne    80104ae9 <wait+0xba>
        continue;
      havekids = 1;
80104a68:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a72:	8b 40 0c             	mov    0xc(%eax),%eax
80104a75:	83 f8 05             	cmp    $0x5,%eax
80104a78:	75 70                	jne    80104aea <wait+0xbb>
        // Found one.
        pid = p->pid;
80104a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7d:	8b 40 10             	mov    0x10(%eax),%eax
80104a80:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a86:	8b 40 08             	mov    0x8(%eax),%eax
80104a89:	89 04 24             	mov    %eax,(%esp)
80104a8c:	e8 e1 df ff ff       	call   80102a72 <kfree>
        p->kstack = 0;
80104a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a94:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9e:	8b 40 04             	mov    0x4(%eax),%eax
80104aa1:	89 04 24             	mov    %eax,(%esp)
80104aa4:	e8 54 3d 00 00       	call   801087fd <freevm>
        p->state = UNUSED;
80104aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aac:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab6:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aca:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad1:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104ad8:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104adf:	e8 71 08 00 00       	call   80105355 <release>
        return pid;
80104ae4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ae7:	eb 56                	jmp    80104b3f <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104ae9:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aea:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104af1:	81 7d f4 b4 5b 11 80 	cmpl   $0x80115bb4,-0xc(%ebp)
80104af8:	0f 82 56 ff ff ff    	jb     80104a54 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104afe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b02:	74 0d                	je     80104b11 <wait+0xe2>
80104b04:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b0a:	8b 40 24             	mov    0x24(%eax),%eax
80104b0d:	85 c0                	test   %eax,%eax
80104b0f:	74 13                	je     80104b24 <wait+0xf5>
      release(&ptable.lock);
80104b11:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104b18:	e8 38 08 00 00       	call   80105355 <release>
      return -1;
80104b1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b22:	eb 1b                	jmp    80104b3f <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b24:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b2a:	c7 44 24 04 80 39 11 	movl   $0x80113980,0x4(%esp)
80104b31:	80 
80104b32:	89 04 24             	mov    %eax,(%esp)
80104b35:	e8 b3 01 00 00       	call   80104ced <sleep>
  }
80104b3a:	e9 02 ff ff ff       	jmp    80104a41 <wait+0x12>
}
80104b3f:	c9                   	leave  
80104b40:	c3                   	ret    

80104b41 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b41:	55                   	push   %ebp
80104b42:	89 e5                	mov    %esp,%ebp
80104b44:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b47:	e8 f9 f7 ff ff       	call   80104345 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b4c:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104b53:	e8 9b 07 00 00       	call   801052f3 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b58:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104b5f:	eb 62                	jmp    80104bc3 <scheduler+0x82>
      if(p->state != RUNNABLE)
80104b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b64:	8b 40 0c             	mov    0xc(%eax),%eax
80104b67:	83 f8 03             	cmp    $0x3,%eax
80104b6a:	75 4f                	jne    80104bbb <scheduler+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b6f:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b78:	89 04 24             	mov    %eax,(%esp)
80104b7b:	e8 06 38 00 00       	call   80108386 <switchuvm>
      p->state = RUNNING;
80104b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b83:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104b8a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b90:	8b 40 1c             	mov    0x1c(%eax),%eax
80104b93:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104b9a:	83 c2 04             	add    $0x4,%edx
80104b9d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ba1:	89 14 24             	mov    %edx,(%esp)
80104ba4:	e8 3f 0c 00 00       	call   801057e8 <swtch>
      switchkvm();
80104ba9:	e8 bb 37 00 00       	call   80108369 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104bae:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104bb5:	00 00 00 00 
80104bb9:	eb 01                	jmp    80104bbc <scheduler+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104bbb:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bbc:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104bc3:	81 7d f4 b4 5b 11 80 	cmpl   $0x80115bb4,-0xc(%ebp)
80104bca:	72 95                	jb     80104b61 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104bcc:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104bd3:	e8 7d 07 00 00       	call   80105355 <release>

  }
80104bd8:	e9 6a ff ff ff       	jmp    80104b47 <scheduler+0x6>

80104bdd <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104bdd:	55                   	push   %ebp
80104bde:	89 e5                	mov    %esp,%ebp
80104be0:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104be3:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104bea:	e8 22 08 00 00       	call   80105411 <holding>
80104bef:	85 c0                	test   %eax,%eax
80104bf1:	75 0c                	jne    80104bff <sched+0x22>
    panic("sched ptable.lock");
80104bf3:	c7 04 24 19 8e 10 80 	movl   $0x80108e19,(%esp)
80104bfa:	e8 3e b9 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104bff:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c05:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c0b:	83 f8 01             	cmp    $0x1,%eax
80104c0e:	74 0c                	je     80104c1c <sched+0x3f>
    panic("sched locks");
80104c10:	c7 04 24 2b 8e 10 80 	movl   $0x80108e2b,(%esp)
80104c17:	e8 21 b9 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104c1c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c22:	8b 40 0c             	mov    0xc(%eax),%eax
80104c25:	83 f8 04             	cmp    $0x4,%eax
80104c28:	75 0c                	jne    80104c36 <sched+0x59>
    panic("sched running");
80104c2a:	c7 04 24 37 8e 10 80 	movl   $0x80108e37,(%esp)
80104c31:	e8 07 b9 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104c36:	e8 f5 f6 ff ff       	call   80104330 <readeflags>
80104c3b:	25 00 02 00 00       	and    $0x200,%eax
80104c40:	85 c0                	test   %eax,%eax
80104c42:	74 0c                	je     80104c50 <sched+0x73>
    panic("sched interruptible");
80104c44:	c7 04 24 45 8e 10 80 	movl   $0x80108e45,(%esp)
80104c4b:	e8 ed b8 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104c50:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c56:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104c5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104c5f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c65:	8b 40 04             	mov    0x4(%eax),%eax
80104c68:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104c6f:	83 c2 1c             	add    $0x1c,%edx
80104c72:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c76:	89 14 24             	mov    %edx,(%esp)
80104c79:	e8 6a 0b 00 00       	call   801057e8 <swtch>
  cpu->intena = intena;
80104c7e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c87:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104c8d:	c9                   	leave  
80104c8e:	c3                   	ret    

80104c8f <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104c8f:	55                   	push   %ebp
80104c90:	89 e5                	mov    %esp,%ebp
80104c92:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104c95:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104c9c:	e8 52 06 00 00       	call   801052f3 <acquire>
  proc->state = RUNNABLE;
80104ca1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ca7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104cae:	e8 2a ff ff ff       	call   80104bdd <sched>
  release(&ptable.lock);
80104cb3:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104cba:	e8 96 06 00 00       	call   80105355 <release>
}
80104cbf:	c9                   	leave  
80104cc0:	c3                   	ret    

80104cc1 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104cc1:	55                   	push   %ebp
80104cc2:	89 e5                	mov    %esp,%ebp
80104cc4:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104cc7:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104cce:	e8 82 06 00 00       	call   80105355 <release>

  if (first) {
80104cd3:	a1 20 c0 10 80       	mov    0x8010c020,%eax
80104cd8:	85 c0                	test   %eax,%eax
80104cda:	74 0f                	je     80104ceb <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104cdc:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
80104ce3:	00 00 00 
    initlog();
80104ce6:	e8 69 e5 ff ff       	call   80103254 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104ceb:	c9                   	leave  
80104cec:	c3                   	ret    

80104ced <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104ced:	55                   	push   %ebp
80104cee:	89 e5                	mov    %esp,%ebp
80104cf0:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104cf3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cf9:	85 c0                	test   %eax,%eax
80104cfb:	75 0c                	jne    80104d09 <sleep+0x1c>
    panic("sleep");
80104cfd:	c7 04 24 59 8e 10 80 	movl   $0x80108e59,(%esp)
80104d04:	e8 34 b8 ff ff       	call   8010053d <panic>

  if(lk == 0)
80104d09:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d0d:	75 0c                	jne    80104d1b <sleep+0x2e>
    panic("sleep without lk");
80104d0f:	c7 04 24 5f 8e 10 80 	movl   $0x80108e5f,(%esp)
80104d16:	e8 22 b8 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104d1b:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80104d22:	74 17                	je     80104d3b <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104d24:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104d2b:	e8 c3 05 00 00       	call   801052f3 <acquire>
    release(lk);
80104d30:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d33:	89 04 24             	mov    %eax,(%esp)
80104d36:	e8 1a 06 00 00       	call   80105355 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104d3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d41:	8b 55 08             	mov    0x8(%ebp),%edx
80104d44:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104d47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d4d:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104d54:	e8 84 fe ff ff       	call   80104bdd <sched>

  // Tidy up.
  proc->chan = 0;
80104d59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d5f:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104d66:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80104d6d:	74 17                	je     80104d86 <sleep+0x99>
    release(&ptable.lock);
80104d6f:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104d76:	e8 da 05 00 00       	call   80105355 <release>
    acquire(lk);
80104d7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d7e:	89 04 24             	mov    %eax,(%esp)
80104d81:	e8 6d 05 00 00       	call   801052f3 <acquire>
  }
}
80104d86:	c9                   	leave  
80104d87:	c3                   	ret    

80104d88 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104d88:	55                   	push   %ebp
80104d89:	89 e5                	mov    %esp,%ebp
80104d8b:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104d8e:	c7 45 fc b4 39 11 80 	movl   $0x801139b4,-0x4(%ebp)
80104d95:	eb 27                	jmp    80104dbe <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104d97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d9a:	8b 40 0c             	mov    0xc(%eax),%eax
80104d9d:	83 f8 02             	cmp    $0x2,%eax
80104da0:	75 15                	jne    80104db7 <wakeup1+0x2f>
80104da2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104da5:	8b 40 20             	mov    0x20(%eax),%eax
80104da8:	3b 45 08             	cmp    0x8(%ebp),%eax
80104dab:	75 0a                	jne    80104db7 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104dad:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104db0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104db7:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80104dbe:	81 7d fc b4 5b 11 80 	cmpl   $0x80115bb4,-0x4(%ebp)
80104dc5:	72 d0                	jb     80104d97 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104dc7:	c9                   	leave  
80104dc8:	c3                   	ret    

80104dc9 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104dc9:	55                   	push   %ebp
80104dca:	89 e5                	mov    %esp,%ebp
80104dcc:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104dcf:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104dd6:	e8 18 05 00 00       	call   801052f3 <acquire>
  wakeup1(chan);
80104ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80104dde:	89 04 24             	mov    %eax,(%esp)
80104de1:	e8 a2 ff ff ff       	call   80104d88 <wakeup1>
  release(&ptable.lock);
80104de6:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104ded:	e8 63 05 00 00       	call   80105355 <release>
}
80104df2:	c9                   	leave  
80104df3:	c3                   	ret    

80104df4 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104df4:	55                   	push   %ebp
80104df5:	89 e5                	mov    %esp,%ebp
80104df7:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104dfa:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104e01:	e8 ed 04 00 00       	call   801052f3 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e06:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104e0d:	eb 44                	jmp    80104e53 <kill+0x5f>
    if(p->pid == pid){
80104e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e12:	8b 40 10             	mov    0x10(%eax),%eax
80104e15:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e18:	75 32                	jne    80104e4c <kill+0x58>
      p->killed = 1;
80104e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e1d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e27:	8b 40 0c             	mov    0xc(%eax),%eax
80104e2a:	83 f8 02             	cmp    $0x2,%eax
80104e2d:	75 0a                	jne    80104e39 <kill+0x45>
        p->state = RUNNABLE;
80104e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e32:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104e39:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104e40:	e8 10 05 00 00       	call   80105355 <release>
      return 0;
80104e45:	b8 00 00 00 00       	mov    $0x0,%eax
80104e4a:	eb 21                	jmp    80104e6d <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e4c:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104e53:	81 7d f4 b4 5b 11 80 	cmpl   $0x80115bb4,-0xc(%ebp)
80104e5a:	72 b3                	jb     80104e0f <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104e5c:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104e63:	e8 ed 04 00 00       	call   80105355 <release>
  return -1;
80104e68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104e6d:	c9                   	leave  
80104e6e:	c3                   	ret    

80104e6f <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104e6f:	55                   	push   %ebp
80104e70:	89 e5                	mov    %esp,%ebp
80104e72:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e75:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
80104e7c:	e9 db 00 00 00       	jmp    80104f5c <procdump+0xed>
    if(p->state == UNUSED)
80104e81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e84:	8b 40 0c             	mov    0xc(%eax),%eax
80104e87:	85 c0                	test   %eax,%eax
80104e89:	0f 84 c5 00 00 00    	je     80104f54 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104e8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e92:	8b 40 0c             	mov    0xc(%eax),%eax
80104e95:	83 f8 05             	cmp    $0x5,%eax
80104e98:	77 23                	ja     80104ebd <procdump+0x4e>
80104e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e9d:	8b 40 0c             	mov    0xc(%eax),%eax
80104ea0:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104ea7:	85 c0                	test   %eax,%eax
80104ea9:	74 12                	je     80104ebd <procdump+0x4e>
      state = states[p->state];
80104eab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eae:	8b 40 0c             	mov    0xc(%eax),%eax
80104eb1:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104eb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104ebb:	eb 07                	jmp    80104ec4 <procdump+0x55>
    else
      state = "???";
80104ebd:	c7 45 ec 70 8e 10 80 	movl   $0x80108e70,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104ec4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ec7:	8d 50 6c             	lea    0x6c(%eax),%edx
80104eca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ecd:	8b 40 10             	mov    0x10(%eax),%eax
80104ed0:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104ed4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104ed7:	89 54 24 08          	mov    %edx,0x8(%esp)
80104edb:	89 44 24 04          	mov    %eax,0x4(%esp)
80104edf:	c7 04 24 74 8e 10 80 	movl   $0x80108e74,(%esp)
80104ee6:	e8 b6 b4 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80104eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eee:	8b 40 0c             	mov    0xc(%eax),%eax
80104ef1:	83 f8 02             	cmp    $0x2,%eax
80104ef4:	75 50                	jne    80104f46 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ef9:	8b 40 1c             	mov    0x1c(%eax),%eax
80104efc:	8b 40 0c             	mov    0xc(%eax),%eax
80104eff:	83 c0 08             	add    $0x8,%eax
80104f02:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104f05:	89 54 24 04          	mov    %edx,0x4(%esp)
80104f09:	89 04 24             	mov    %eax,(%esp)
80104f0c:	e8 93 04 00 00       	call   801053a4 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104f11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f18:	eb 1b                	jmp    80104f35 <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f1d:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f21:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f25:	c7 04 24 7d 8e 10 80 	movl   $0x80108e7d,(%esp)
80104f2c:	e8 70 b4 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104f31:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f35:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104f39:	7f 0b                	jg     80104f46 <procdump+0xd7>
80104f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f3e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f42:	85 c0                	test   %eax,%eax
80104f44:	75 d4                	jne    80104f1a <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104f46:	c7 04 24 81 8e 10 80 	movl   $0x80108e81,(%esp)
80104f4d:	e8 4f b4 ff ff       	call   801003a1 <cprintf>
80104f52:	eb 01                	jmp    80104f55 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104f54:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f55:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
80104f5c:	81 7d f0 b4 5b 11 80 	cmpl   $0x80115bb4,-0x10(%ebp)
80104f63:	0f 82 18 ff ff ff    	jb     80104e81 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104f69:	c9                   	leave  
80104f6a:	c3                   	ret    

80104f6b <clone>:

int
clone(void* function, void *arg, void *stack)
{
80104f6b:	55                   	push   %ebp
80104f6c:	89 e5                	mov    %esp,%ebp
80104f6e:	57                   	push   %edi
80104f6f:	56                   	push   %esi
80104f70:	53                   	push   %ebx
80104f71:	83 ec 2c             	sub    $0x2c,%esp
  int i;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104f74:	e8 ee f3 ff ff       	call   80104367 <allocproc>
80104f79:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104f7c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104f80:	75 0a                	jne    80104f8c <clone+0x21>
    return -1;
80104f82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f87:	e9 8f 01 00 00       	jmp    8010511b <clone+0x1b0>

  // reallocate old process's page table to new process
  np->pgdir = proc->pgdir;  
80104f8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f92:	8b 50 04             	mov    0x4(%eax),%edx
80104f95:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f98:	89 50 04             	mov    %edx,0x4(%eax)
  // set size of process memory
  np->sz = proc->sz;
80104f9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fa1:	8b 10                	mov    (%eax),%edx
80104fa3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fa6:	89 10                	mov    %edx,(%eax)

  // set parent of new process
  if(proc->isthread == 0){
80104fa8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fae:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104fb4:	85 c0                	test   %eax,%eax
80104fb6:	75 0f                	jne    80104fc7 <clone+0x5c>
  	np->parent = proc;
80104fb8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104fbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fc2:	89 50 14             	mov    %edx,0x14(%eax)
80104fc5:	eb 0f                	jmp    80104fd6 <clone+0x6b>
  }
  else{
  	np->parent = proc->parent;
80104fc7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fcd:	8b 50 14             	mov    0x14(%eax),%edx
80104fd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fd3:	89 50 14             	mov    %edx,0x14(%eax)
  }

  // copy the trapframe
  *np->tf = *proc->tf;
80104fd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fd9:	8b 50 18             	mov    0x18(%eax),%edx
80104fdc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fe2:	8b 40 18             	mov    0x18(%eax),%eax
80104fe5:	89 c3                	mov    %eax,%ebx
80104fe7:	b8 13 00 00 00       	mov    $0x13,%eax
80104fec:	89 d7                	mov    %edx,%edi
80104fee:	89 de                	mov    %ebx,%esi
80104ff0:	89 c1                	mov    %eax,%ecx
80104ff2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104ff4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ff7:	8b 40 18             	mov    0x18(%eax),%eax
80104ffa:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  // modified the return ip to the given function parameter
  np->tf->eip = (int)function;
80105001:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105004:	8b 40 18             	mov    0x18(%eax),%eax
80105007:	8b 55 08             	mov    0x8(%ebp),%edx
8010500a:	89 50 38             	mov    %edx,0x38(%eax)
  // modified the thread indicator's value
  np->isthread = 1;
8010500d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105010:	c7 80 80 00 00 00 01 	movl   $0x1,0x80(%eax)
80105017:	00 00 00 
  // modified the stack to the given stack parameter 
  np->stack = (int)stack;
8010501a:	8b 55 10             	mov    0x10(%ebp),%edx
8010501d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105020:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
  // move esp to the top of the new stack
  np->tf->esp = (int)stack + 4092; 
80105026:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105029:	8b 40 18             	mov    0x18(%eax),%eax
8010502c:	8b 55 10             	mov    0x10(%ebp),%edx
8010502f:	81 c2 fc 0f 00 00    	add    $0xffc,%edx
80105035:	89 50 44             	mov    %edx,0x44(%eax)
  // push the argument
  *((int *)(np->tf->esp)) = (int)arg; 
80105038:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010503b:	8b 40 18             	mov    0x18(%eax),%eax
8010503e:	8b 40 44             	mov    0x44(%eax),%eax
80105041:	8b 55 0c             	mov    0xc(%ebp),%edx
80105044:	89 10                	mov    %edx,(%eax)
  // push the return address
  *((int *)(np->tf->esp - 4)) = 0xFFFFFFFF; 
80105046:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105049:	8b 40 18             	mov    0x18(%eax),%eax
8010504c:	8b 40 44             	mov    0x44(%eax),%eax
8010504f:	83 e8 04             	sub    $0x4,%eax
80105052:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  // modify esp for the return address push
  np->tf->esp -= 4;
80105058:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010505b:	8b 40 18             	mov    0x18(%eax),%eax
8010505e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80105061:	8b 52 18             	mov    0x18(%edx),%edx
80105064:	8b 52 44             	mov    0x44(%edx),%edx
80105067:	83 ea 04             	sub    $0x4,%edx
8010506a:	89 50 44             	mov    %edx,0x44(%eax)

  for(i = 0; i < NOFILE; i++)
8010506d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80105074:	eb 3d                	jmp    801050b3 <clone+0x148>
    if(proc->ofile[i])
80105076:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010507c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010507f:	83 c2 08             	add    $0x8,%edx
80105082:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105086:	85 c0                	test   %eax,%eax
80105088:	74 25                	je     801050af <clone+0x144>
      np->ofile[i] = filedup(proc->ofile[i]);
8010508a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105090:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105093:	83 c2 08             	add    $0x8,%edx
80105096:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010509a:	89 04 24             	mov    %eax,(%esp)
8010509d:	e8 e6 be ff ff       	call   80100f88 <filedup>
801050a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
801050a5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801050a8:	83 c1 08             	add    $0x8,%ecx
801050ab:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  // push the return address
  *((int *)(np->tf->esp - 4)) = 0xFFFFFFFF; 
  // modify esp for the return address push
  np->tf->esp -= 4;

  for(i = 0; i < NOFILE; i++)
801050af:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801050b3:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801050b7:	7e bd                	jle    80105076 <clone+0x10b>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801050b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050bf:	8b 40 68             	mov    0x68(%eax),%eax
801050c2:	89 04 24             	mov    %eax,(%esp)
801050c5:	e8 78 c7 ff ff       	call   80101842 <idup>
801050ca:	8b 55 e0             	mov    -0x20(%ebp),%edx
801050cd:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801050d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050d6:	8d 50 6c             	lea    0x6c(%eax),%edx
801050d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801050dc:	83 c0 6c             	add    $0x6c,%eax
801050df:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801050e6:	00 
801050e7:	89 54 24 04          	mov    %edx,0x4(%esp)
801050eb:	89 04 24             	mov    %eax,(%esp)
801050ee:	e8 7f 06 00 00       	call   80105772 <safestrcpy>
 
  //pid = np->pid;

  acquire(&ptable.lock);
801050f3:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801050fa:	e8 f4 01 00 00       	call   801052f3 <acquire>
  np->state = RUNNABLE;
801050ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105102:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80105109:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80105110:	e8 40 02 00 00       	call   80105355 <release>

  // exit();
  return np->pid;
80105115:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105118:	8b 40 10             	mov    0x10(%eax),%eax
}
8010511b:	83 c4 2c             	add    $0x2c,%esp
8010511e:	5b                   	pop    %ebx
8010511f:	5e                   	pop    %esi
80105120:	5f                   	pop    %edi
80105121:	5d                   	pop    %ebp
80105122:	c3                   	ret    

80105123 <join>:


int
join(int passedPid, void **stack, void **retval)
{
80105123:	55                   	push   %ebp
80105124:	89 e5                	mov    %esp,%ebp
80105126:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80105129:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80105130:	e8 be 01 00 00       	call   801052f3 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80105135:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010513c:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80105143:	e9 c9 00 00 00       	jmp    80105211 <join+0xee>
      // only wait for the child thread, but not the child process
      if(p->parent != proc || p->isthread != 1 || p->pid != passedPid)
80105148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010514b:	8b 50 14             	mov    0x14(%eax),%edx
8010514e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105154:	39 c2                	cmp    %eax,%edx
80105156:	0f 85 ad 00 00 00    	jne    80105209 <join+0xe6>
8010515c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010515f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105165:	83 f8 01             	cmp    $0x1,%eax
80105168:	0f 85 9b 00 00 00    	jne    80105209 <join+0xe6>
8010516e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105171:	8b 40 10             	mov    0x10(%eax),%eax
80105174:	3b 45 08             	cmp    0x8(%ebp),%eax
80105177:	0f 85 8c 00 00 00    	jne    80105209 <join+0xe6>
        continue;
      havekids = 1;
8010517d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80105184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105187:	8b 40 0c             	mov    0xc(%eax),%eax
8010518a:	83 f8 05             	cmp    $0x5,%eax
8010518d:	75 7b                	jne    8010520a <join+0xe7>
        // Found one.
        pid = p->pid;
8010518f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105192:	8b 40 10             	mov    0x10(%eax),%eax
80105195:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80105198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010519b:	8b 40 08             	mov    0x8(%eax),%eax
8010519e:	89 04 24             	mov    %eax,(%esp)
801051a1:	e8 cc d8 ff ff       	call   80102a72 <kfree>
        p->kstack = 0;
801051a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        p->state = UNUSED;
801051b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801051ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051bd:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801051c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051c7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801051ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d1:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801051d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d8:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801051df:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801051e6:	e8 6a 01 00 00       	call   80105355 <release>
        *(int*)retval = p->retval;
801051eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ee:	8b 50 7c             	mov    0x7c(%eax),%edx
801051f1:	8b 45 10             	mov    0x10(%ebp),%eax
801051f4:	89 10                	mov    %edx,(%eax)
        *(int*)stack = p->stack;
801051f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f9:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
801051ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105202:	89 10                	mov    %edx,(%eax)
        return pid;
80105204:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105207:	eb 56                	jmp    8010525f <join+0x13c>
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      // only wait for the child thread, but not the child process
      if(p->parent != proc || p->isthread != 1 || p->pid != passedPid)
        continue;
80105209:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010520a:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80105211:	81 7d f4 b4 5b 11 80 	cmpl   $0x80115bb4,-0xc(%ebp)
80105218:	0f 82 2a ff ff ff    	jb     80105148 <join+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children thread.
    if(!havekids || proc->killed){
8010521e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105222:	74 0d                	je     80105231 <join+0x10e>
80105224:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010522a:	8b 40 24             	mov    0x24(%eax),%eax
8010522d:	85 c0                	test   %eax,%eax
8010522f:	74 13                	je     80105244 <join+0x121>
      release(&ptable.lock);
80105231:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80105238:	e8 18 01 00 00       	call   80105355 <release>
      return -1;
8010523d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105242:	eb 1b                	jmp    8010525f <join+0x13c>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80105244:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010524a:	c7 44 24 04 80 39 11 	movl   $0x80113980,0x4(%esp)
80105251:	80 
80105252:	89 04 24             	mov    %eax,(%esp)
80105255:	e8 93 fa ff ff       	call   80104ced <sleep>
  }
8010525a:	e9 d6 fe ff ff       	jmp    80105135 <join+0x12>
}
8010525f:	c9                   	leave  
80105260:	c3                   	ret    

80105261 <mutex_init>:


int mutex_init()
{
80105261:	55                   	push   %ebp
80105262:	89 e5                	mov    %esp,%ebp
	return 0;
80105264:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105269:	5d                   	pop    %ebp
8010526a:	c3                   	ret    

8010526b <mutex_destroy>:


int mutex_destroy(int mutex_id)
{
8010526b:	55                   	push   %ebp
8010526c:	89 e5                	mov    %esp,%ebp
	return 0;
8010526e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105273:	5d                   	pop    %ebp
80105274:	c3                   	ret    

80105275 <mutex_lock>:


int mutex_lock(int mutex_id)
{
80105275:	55                   	push   %ebp
80105276:	89 e5                	mov    %esp,%ebp
	return 0;
80105278:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010527d:	5d                   	pop    %ebp
8010527e:	c3                   	ret    

8010527f <mutex_unlock>:


int mutex_unlock(int mutex_id)
{
8010527f:	55                   	push   %ebp
80105280:	89 e5                	mov    %esp,%ebp
	return 0;
80105282:	b8 00 00 00 00       	mov    $0x0,%eax
80105287:	5d                   	pop    %ebp
80105288:	c3                   	ret    
80105289:	00 00                	add    %al,(%eax)
	...

8010528c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010528c:	55                   	push   %ebp
8010528d:	89 e5                	mov    %esp,%ebp
8010528f:	53                   	push   %ebx
80105290:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105293:	9c                   	pushf  
80105294:	5b                   	pop    %ebx
80105295:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80105298:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010529b:	83 c4 10             	add    $0x10,%esp
8010529e:	5b                   	pop    %ebx
8010529f:	5d                   	pop    %ebp
801052a0:	c3                   	ret    

801052a1 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801052a1:	55                   	push   %ebp
801052a2:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801052a4:	fa                   	cli    
}
801052a5:	5d                   	pop    %ebp
801052a6:	c3                   	ret    

801052a7 <sti>:

static inline void
sti(void)
{
801052a7:	55                   	push   %ebp
801052a8:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801052aa:	fb                   	sti    
}
801052ab:	5d                   	pop    %ebp
801052ac:	c3                   	ret    

801052ad <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801052ad:	55                   	push   %ebp
801052ae:	89 e5                	mov    %esp,%ebp
801052b0:	53                   	push   %ebx
801052b1:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
801052b4:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801052b7:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
801052ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801052bd:	89 c3                	mov    %eax,%ebx
801052bf:	89 d8                	mov    %ebx,%eax
801052c1:	f0 87 02             	lock xchg %eax,(%edx)
801052c4:	89 c3                	mov    %eax,%ebx
801052c6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801052c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801052cc:	83 c4 10             	add    $0x10,%esp
801052cf:	5b                   	pop    %ebx
801052d0:	5d                   	pop    %ebp
801052d1:	c3                   	ret    

801052d2 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801052d2:	55                   	push   %ebp
801052d3:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801052d5:	8b 45 08             	mov    0x8(%ebp),%eax
801052d8:	8b 55 0c             	mov    0xc(%ebp),%edx
801052db:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801052de:	8b 45 08             	mov    0x8(%ebp),%eax
801052e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801052e7:	8b 45 08             	mov    0x8(%ebp),%eax
801052ea:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801052f1:	5d                   	pop    %ebp
801052f2:	c3                   	ret    

801052f3 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801052f3:	55                   	push   %ebp
801052f4:	89 e5                	mov    %esp,%ebp
801052f6:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801052f9:	e8 3d 01 00 00       	call   8010543b <pushcli>
  if(holding(lk))
801052fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105301:	89 04 24             	mov    %eax,(%esp)
80105304:	e8 08 01 00 00       	call   80105411 <holding>
80105309:	85 c0                	test   %eax,%eax
8010530b:	74 0c                	je     80105319 <acquire+0x26>
    panic("acquire");
8010530d:	c7 04 24 ad 8e 10 80 	movl   $0x80108ead,(%esp)
80105314:	e8 24 b2 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105319:	90                   	nop
8010531a:	8b 45 08             	mov    0x8(%ebp),%eax
8010531d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105324:	00 
80105325:	89 04 24             	mov    %eax,(%esp)
80105328:	e8 80 ff ff ff       	call   801052ad <xchg>
8010532d:	85 c0                	test   %eax,%eax
8010532f:	75 e9                	jne    8010531a <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105331:	8b 45 08             	mov    0x8(%ebp),%eax
80105334:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010533b:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010533e:	8b 45 08             	mov    0x8(%ebp),%eax
80105341:	83 c0 0c             	add    $0xc,%eax
80105344:	89 44 24 04          	mov    %eax,0x4(%esp)
80105348:	8d 45 08             	lea    0x8(%ebp),%eax
8010534b:	89 04 24             	mov    %eax,(%esp)
8010534e:	e8 51 00 00 00       	call   801053a4 <getcallerpcs>
}
80105353:	c9                   	leave  
80105354:	c3                   	ret    

80105355 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105355:	55                   	push   %ebp
80105356:	89 e5                	mov    %esp,%ebp
80105358:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
8010535b:	8b 45 08             	mov    0x8(%ebp),%eax
8010535e:	89 04 24             	mov    %eax,(%esp)
80105361:	e8 ab 00 00 00       	call   80105411 <holding>
80105366:	85 c0                	test   %eax,%eax
80105368:	75 0c                	jne    80105376 <release+0x21>
    panic("release");
8010536a:	c7 04 24 b5 8e 10 80 	movl   $0x80108eb5,(%esp)
80105371:	e8 c7 b1 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80105376:	8b 45 08             	mov    0x8(%ebp),%eax
80105379:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105380:	8b 45 08             	mov    0x8(%ebp),%eax
80105383:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
8010538a:	8b 45 08             	mov    0x8(%ebp),%eax
8010538d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105394:	00 
80105395:	89 04 24             	mov    %eax,(%esp)
80105398:	e8 10 ff ff ff       	call   801052ad <xchg>

  popcli();
8010539d:	e8 e1 00 00 00       	call   80105483 <popcli>
}
801053a2:	c9                   	leave  
801053a3:	c3                   	ret    

801053a4 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801053a4:	55                   	push   %ebp
801053a5:	89 e5                	mov    %esp,%ebp
801053a7:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801053aa:	8b 45 08             	mov    0x8(%ebp),%eax
801053ad:	83 e8 08             	sub    $0x8,%eax
801053b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053b3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801053ba:	eb 32                	jmp    801053ee <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801053bc:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801053c0:	74 47                	je     80105409 <getcallerpcs+0x65>
801053c2:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801053c9:	76 3e                	jbe    80105409 <getcallerpcs+0x65>
801053cb:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801053cf:	74 38                	je     80105409 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
801053d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053d4:	c1 e0 02             	shl    $0x2,%eax
801053d7:	03 45 0c             	add    0xc(%ebp),%eax
801053da:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053dd:	8b 52 04             	mov    0x4(%edx),%edx
801053e0:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
801053e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053e5:	8b 00                	mov    (%eax),%eax
801053e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801053ea:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053ee:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053f2:	7e c8                	jle    801053bc <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801053f4:	eb 13                	jmp    80105409 <getcallerpcs+0x65>
    pcs[i] = 0;
801053f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053f9:	c1 e0 02             	shl    $0x2,%eax
801053fc:	03 45 0c             	add    0xc(%ebp),%eax
801053ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105405:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105409:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010540d:	7e e7                	jle    801053f6 <getcallerpcs+0x52>
    pcs[i] = 0;
}
8010540f:	c9                   	leave  
80105410:	c3                   	ret    

80105411 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105411:	55                   	push   %ebp
80105412:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105414:	8b 45 08             	mov    0x8(%ebp),%eax
80105417:	8b 00                	mov    (%eax),%eax
80105419:	85 c0                	test   %eax,%eax
8010541b:	74 17                	je     80105434 <holding+0x23>
8010541d:	8b 45 08             	mov    0x8(%ebp),%eax
80105420:	8b 50 08             	mov    0x8(%eax),%edx
80105423:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105429:	39 c2                	cmp    %eax,%edx
8010542b:	75 07                	jne    80105434 <holding+0x23>
8010542d:	b8 01 00 00 00       	mov    $0x1,%eax
80105432:	eb 05                	jmp    80105439 <holding+0x28>
80105434:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105439:	5d                   	pop    %ebp
8010543a:	c3                   	ret    

8010543b <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010543b:	55                   	push   %ebp
8010543c:	89 e5                	mov    %esp,%ebp
8010543e:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105441:	e8 46 fe ff ff       	call   8010528c <readeflags>
80105446:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105449:	e8 53 fe ff ff       	call   801052a1 <cli>
  if(cpu->ncli++ == 0)
8010544e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105454:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010545a:	85 d2                	test   %edx,%edx
8010545c:	0f 94 c1             	sete   %cl
8010545f:	83 c2 01             	add    $0x1,%edx
80105462:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105468:	84 c9                	test   %cl,%cl
8010546a:	74 15                	je     80105481 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
8010546c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105472:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105475:	81 e2 00 02 00 00    	and    $0x200,%edx
8010547b:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105481:	c9                   	leave  
80105482:	c3                   	ret    

80105483 <popcli>:

void
popcli(void)
{
80105483:	55                   	push   %ebp
80105484:	89 e5                	mov    %esp,%ebp
80105486:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105489:	e8 fe fd ff ff       	call   8010528c <readeflags>
8010548e:	25 00 02 00 00       	and    $0x200,%eax
80105493:	85 c0                	test   %eax,%eax
80105495:	74 0c                	je     801054a3 <popcli+0x20>
    panic("popcli - interruptible");
80105497:	c7 04 24 bd 8e 10 80 	movl   $0x80108ebd,(%esp)
8010549e:	e8 9a b0 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
801054a3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054a9:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801054af:	83 ea 01             	sub    $0x1,%edx
801054b2:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801054b8:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801054be:	85 c0                	test   %eax,%eax
801054c0:	79 0c                	jns    801054ce <popcli+0x4b>
    panic("popcli");
801054c2:	c7 04 24 d4 8e 10 80 	movl   $0x80108ed4,(%esp)
801054c9:	e8 6f b0 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
801054ce:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054d4:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801054da:	85 c0                	test   %eax,%eax
801054dc:	75 15                	jne    801054f3 <popcli+0x70>
801054de:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054e4:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801054ea:	85 c0                	test   %eax,%eax
801054ec:	74 05                	je     801054f3 <popcli+0x70>
    sti();
801054ee:	e8 b4 fd ff ff       	call   801052a7 <sti>
}
801054f3:	c9                   	leave  
801054f4:	c3                   	ret    
801054f5:	00 00                	add    %al,(%eax)
	...

801054f8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801054f8:	55                   	push   %ebp
801054f9:	89 e5                	mov    %esp,%ebp
801054fb:	57                   	push   %edi
801054fc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801054fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105500:	8b 55 10             	mov    0x10(%ebp),%edx
80105503:	8b 45 0c             	mov    0xc(%ebp),%eax
80105506:	89 cb                	mov    %ecx,%ebx
80105508:	89 df                	mov    %ebx,%edi
8010550a:	89 d1                	mov    %edx,%ecx
8010550c:	fc                   	cld    
8010550d:	f3 aa                	rep stos %al,%es:(%edi)
8010550f:	89 ca                	mov    %ecx,%edx
80105511:	89 fb                	mov    %edi,%ebx
80105513:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105516:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105519:	5b                   	pop    %ebx
8010551a:	5f                   	pop    %edi
8010551b:	5d                   	pop    %ebp
8010551c:	c3                   	ret    

8010551d <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010551d:	55                   	push   %ebp
8010551e:	89 e5                	mov    %esp,%ebp
80105520:	57                   	push   %edi
80105521:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105522:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105525:	8b 55 10             	mov    0x10(%ebp),%edx
80105528:	8b 45 0c             	mov    0xc(%ebp),%eax
8010552b:	89 cb                	mov    %ecx,%ebx
8010552d:	89 df                	mov    %ebx,%edi
8010552f:	89 d1                	mov    %edx,%ecx
80105531:	fc                   	cld    
80105532:	f3 ab                	rep stos %eax,%es:(%edi)
80105534:	89 ca                	mov    %ecx,%edx
80105536:	89 fb                	mov    %edi,%ebx
80105538:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010553b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010553e:	5b                   	pop    %ebx
8010553f:	5f                   	pop    %edi
80105540:	5d                   	pop    %ebp
80105541:	c3                   	ret    

80105542 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105542:	55                   	push   %ebp
80105543:	89 e5                	mov    %esp,%ebp
80105545:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105548:	8b 45 08             	mov    0x8(%ebp),%eax
8010554b:	83 e0 03             	and    $0x3,%eax
8010554e:	85 c0                	test   %eax,%eax
80105550:	75 49                	jne    8010559b <memset+0x59>
80105552:	8b 45 10             	mov    0x10(%ebp),%eax
80105555:	83 e0 03             	and    $0x3,%eax
80105558:	85 c0                	test   %eax,%eax
8010555a:	75 3f                	jne    8010559b <memset+0x59>
    c &= 0xFF;
8010555c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105563:	8b 45 10             	mov    0x10(%ebp),%eax
80105566:	c1 e8 02             	shr    $0x2,%eax
80105569:	89 c2                	mov    %eax,%edx
8010556b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010556e:	89 c1                	mov    %eax,%ecx
80105570:	c1 e1 18             	shl    $0x18,%ecx
80105573:	8b 45 0c             	mov    0xc(%ebp),%eax
80105576:	c1 e0 10             	shl    $0x10,%eax
80105579:	09 c1                	or     %eax,%ecx
8010557b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010557e:	c1 e0 08             	shl    $0x8,%eax
80105581:	09 c8                	or     %ecx,%eax
80105583:	0b 45 0c             	or     0xc(%ebp),%eax
80105586:	89 54 24 08          	mov    %edx,0x8(%esp)
8010558a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010558e:	8b 45 08             	mov    0x8(%ebp),%eax
80105591:	89 04 24             	mov    %eax,(%esp)
80105594:	e8 84 ff ff ff       	call   8010551d <stosl>
80105599:	eb 19                	jmp    801055b4 <memset+0x72>
  } else
    stosb(dst, c, n);
8010559b:	8b 45 10             	mov    0x10(%ebp),%eax
8010559e:	89 44 24 08          	mov    %eax,0x8(%esp)
801055a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801055a9:	8b 45 08             	mov    0x8(%ebp),%eax
801055ac:	89 04 24             	mov    %eax,(%esp)
801055af:	e8 44 ff ff ff       	call   801054f8 <stosb>
  return dst;
801055b4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801055b7:	c9                   	leave  
801055b8:	c3                   	ret    

801055b9 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801055b9:	55                   	push   %ebp
801055ba:	89 e5                	mov    %esp,%ebp
801055bc:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801055bf:	8b 45 08             	mov    0x8(%ebp),%eax
801055c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801055c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801055c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801055cb:	eb 32                	jmp    801055ff <memcmp+0x46>
    if(*s1 != *s2)
801055cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055d0:	0f b6 10             	movzbl (%eax),%edx
801055d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055d6:	0f b6 00             	movzbl (%eax),%eax
801055d9:	38 c2                	cmp    %al,%dl
801055db:	74 1a                	je     801055f7 <memcmp+0x3e>
      return *s1 - *s2;
801055dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055e0:	0f b6 00             	movzbl (%eax),%eax
801055e3:	0f b6 d0             	movzbl %al,%edx
801055e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055e9:	0f b6 00             	movzbl (%eax),%eax
801055ec:	0f b6 c0             	movzbl %al,%eax
801055ef:	89 d1                	mov    %edx,%ecx
801055f1:	29 c1                	sub    %eax,%ecx
801055f3:	89 c8                	mov    %ecx,%eax
801055f5:	eb 1c                	jmp    80105613 <memcmp+0x5a>
    s1++, s2++;
801055f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055fb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801055ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105603:	0f 95 c0             	setne  %al
80105606:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010560a:	84 c0                	test   %al,%al
8010560c:	75 bf                	jne    801055cd <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010560e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105613:	c9                   	leave  
80105614:	c3                   	ret    

80105615 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105615:	55                   	push   %ebp
80105616:	89 e5                	mov    %esp,%ebp
80105618:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010561b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010561e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105621:	8b 45 08             	mov    0x8(%ebp),%eax
80105624:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105627:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010562a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010562d:	73 54                	jae    80105683 <memmove+0x6e>
8010562f:	8b 45 10             	mov    0x10(%ebp),%eax
80105632:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105635:	01 d0                	add    %edx,%eax
80105637:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010563a:	76 47                	jbe    80105683 <memmove+0x6e>
    s += n;
8010563c:	8b 45 10             	mov    0x10(%ebp),%eax
8010563f:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105642:	8b 45 10             	mov    0x10(%ebp),%eax
80105645:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105648:	eb 13                	jmp    8010565d <memmove+0x48>
      *--d = *--s;
8010564a:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010564e:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105652:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105655:	0f b6 10             	movzbl (%eax),%edx
80105658:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010565b:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010565d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105661:	0f 95 c0             	setne  %al
80105664:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105668:	84 c0                	test   %al,%al
8010566a:	75 de                	jne    8010564a <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010566c:	eb 25                	jmp    80105693 <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010566e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105671:	0f b6 10             	movzbl (%eax),%edx
80105674:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105677:	88 10                	mov    %dl,(%eax)
80105679:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010567d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105681:	eb 01                	jmp    80105684 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105683:	90                   	nop
80105684:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105688:	0f 95 c0             	setne  %al
8010568b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010568f:	84 c0                	test   %al,%al
80105691:	75 db                	jne    8010566e <memmove+0x59>
      *d++ = *s++;

  return dst;
80105693:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105696:	c9                   	leave  
80105697:	c3                   	ret    

80105698 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105698:	55                   	push   %ebp
80105699:	89 e5                	mov    %esp,%ebp
8010569b:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010569e:	8b 45 10             	mov    0x10(%ebp),%eax
801056a1:	89 44 24 08          	mov    %eax,0x8(%esp)
801056a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801056a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801056ac:	8b 45 08             	mov    0x8(%ebp),%eax
801056af:	89 04 24             	mov    %eax,(%esp)
801056b2:	e8 5e ff ff ff       	call   80105615 <memmove>
}
801056b7:	c9                   	leave  
801056b8:	c3                   	ret    

801056b9 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801056b9:	55                   	push   %ebp
801056ba:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801056bc:	eb 0c                	jmp    801056ca <strncmp+0x11>
    n--, p++, q++;
801056be:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801056c6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801056ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056ce:	74 1a                	je     801056ea <strncmp+0x31>
801056d0:	8b 45 08             	mov    0x8(%ebp),%eax
801056d3:	0f b6 00             	movzbl (%eax),%eax
801056d6:	84 c0                	test   %al,%al
801056d8:	74 10                	je     801056ea <strncmp+0x31>
801056da:	8b 45 08             	mov    0x8(%ebp),%eax
801056dd:	0f b6 10             	movzbl (%eax),%edx
801056e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801056e3:	0f b6 00             	movzbl (%eax),%eax
801056e6:	38 c2                	cmp    %al,%dl
801056e8:	74 d4                	je     801056be <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801056ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056ee:	75 07                	jne    801056f7 <strncmp+0x3e>
    return 0;
801056f0:	b8 00 00 00 00       	mov    $0x0,%eax
801056f5:	eb 18                	jmp    8010570f <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
801056f7:	8b 45 08             	mov    0x8(%ebp),%eax
801056fa:	0f b6 00             	movzbl (%eax),%eax
801056fd:	0f b6 d0             	movzbl %al,%edx
80105700:	8b 45 0c             	mov    0xc(%ebp),%eax
80105703:	0f b6 00             	movzbl (%eax),%eax
80105706:	0f b6 c0             	movzbl %al,%eax
80105709:	89 d1                	mov    %edx,%ecx
8010570b:	29 c1                	sub    %eax,%ecx
8010570d:	89 c8                	mov    %ecx,%eax
}
8010570f:	5d                   	pop    %ebp
80105710:	c3                   	ret    

80105711 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105711:	55                   	push   %ebp
80105712:	89 e5                	mov    %esp,%ebp
80105714:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105717:	8b 45 08             	mov    0x8(%ebp),%eax
8010571a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010571d:	90                   	nop
8010571e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105722:	0f 9f c0             	setg   %al
80105725:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105729:	84 c0                	test   %al,%al
8010572b:	74 30                	je     8010575d <strncpy+0x4c>
8010572d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105730:	0f b6 10             	movzbl (%eax),%edx
80105733:	8b 45 08             	mov    0x8(%ebp),%eax
80105736:	88 10                	mov    %dl,(%eax)
80105738:	8b 45 08             	mov    0x8(%ebp),%eax
8010573b:	0f b6 00             	movzbl (%eax),%eax
8010573e:	84 c0                	test   %al,%al
80105740:	0f 95 c0             	setne  %al
80105743:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105747:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010574b:	84 c0                	test   %al,%al
8010574d:	75 cf                	jne    8010571e <strncpy+0xd>
    ;
  while(n-- > 0)
8010574f:	eb 0c                	jmp    8010575d <strncpy+0x4c>
    *s++ = 0;
80105751:	8b 45 08             	mov    0x8(%ebp),%eax
80105754:	c6 00 00             	movb   $0x0,(%eax)
80105757:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010575b:	eb 01                	jmp    8010575e <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010575d:	90                   	nop
8010575e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105762:	0f 9f c0             	setg   %al
80105765:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105769:	84 c0                	test   %al,%al
8010576b:	75 e4                	jne    80105751 <strncpy+0x40>
    *s++ = 0;
  return os;
8010576d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105770:	c9                   	leave  
80105771:	c3                   	ret    

80105772 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105772:	55                   	push   %ebp
80105773:	89 e5                	mov    %esp,%ebp
80105775:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105778:	8b 45 08             	mov    0x8(%ebp),%eax
8010577b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010577e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105782:	7f 05                	jg     80105789 <safestrcpy+0x17>
    return os;
80105784:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105787:	eb 35                	jmp    801057be <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105789:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010578d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105791:	7e 22                	jle    801057b5 <safestrcpy+0x43>
80105793:	8b 45 0c             	mov    0xc(%ebp),%eax
80105796:	0f b6 10             	movzbl (%eax),%edx
80105799:	8b 45 08             	mov    0x8(%ebp),%eax
8010579c:	88 10                	mov    %dl,(%eax)
8010579e:	8b 45 08             	mov    0x8(%ebp),%eax
801057a1:	0f b6 00             	movzbl (%eax),%eax
801057a4:	84 c0                	test   %al,%al
801057a6:	0f 95 c0             	setne  %al
801057a9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801057ad:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801057b1:	84 c0                	test   %al,%al
801057b3:	75 d4                	jne    80105789 <safestrcpy+0x17>
    ;
  *s = 0;
801057b5:	8b 45 08             	mov    0x8(%ebp),%eax
801057b8:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801057bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057be:	c9                   	leave  
801057bf:	c3                   	ret    

801057c0 <strlen>:

int
strlen(const char *s)
{
801057c0:	55                   	push   %ebp
801057c1:	89 e5                	mov    %esp,%ebp
801057c3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801057c6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057cd:	eb 04                	jmp    801057d3 <strlen+0x13>
801057cf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057d6:	03 45 08             	add    0x8(%ebp),%eax
801057d9:	0f b6 00             	movzbl (%eax),%eax
801057dc:	84 c0                	test   %al,%al
801057de:	75 ef                	jne    801057cf <strlen+0xf>
    ;
  return n;
801057e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057e3:	c9                   	leave  
801057e4:	c3                   	ret    
801057e5:	00 00                	add    %al,(%eax)
	...

801057e8 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801057e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801057ec:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801057f0:	55                   	push   %ebp
  pushl %ebx
801057f1:	53                   	push   %ebx
  pushl %esi
801057f2:	56                   	push   %esi
  pushl %edi
801057f3:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801057f4:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801057f6:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801057f8:	5f                   	pop    %edi
  popl %esi
801057f9:	5e                   	pop    %esi
  popl %ebx
801057fa:	5b                   	pop    %ebx
  popl %ebp
801057fb:	5d                   	pop    %ebp
  ret
801057fc:	c3                   	ret    
801057fd:	00 00                	add    %al,(%eax)
	...

80105800 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105800:	55                   	push   %ebp
80105801:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105803:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105809:	8b 00                	mov    (%eax),%eax
8010580b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010580e:	76 12                	jbe    80105822 <fetchint+0x22>
80105810:	8b 45 08             	mov    0x8(%ebp),%eax
80105813:	8d 50 04             	lea    0x4(%eax),%edx
80105816:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010581c:	8b 00                	mov    (%eax),%eax
8010581e:	39 c2                	cmp    %eax,%edx
80105820:	76 07                	jbe    80105829 <fetchint+0x29>
    return -1;
80105822:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105827:	eb 0f                	jmp    80105838 <fetchint+0x38>
  *ip = *(int*)(addr);
80105829:	8b 45 08             	mov    0x8(%ebp),%eax
8010582c:	8b 10                	mov    (%eax),%edx
8010582e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105831:	89 10                	mov    %edx,(%eax)
  return 0;
80105833:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105838:	5d                   	pop    %ebp
80105839:	c3                   	ret    

8010583a <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010583a:	55                   	push   %ebp
8010583b:	89 e5                	mov    %esp,%ebp
8010583d:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105840:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105846:	8b 00                	mov    (%eax),%eax
80105848:	3b 45 08             	cmp    0x8(%ebp),%eax
8010584b:	77 07                	ja     80105854 <fetchstr+0x1a>
    return -1;
8010584d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105852:	eb 48                	jmp    8010589c <fetchstr+0x62>
  *pp = (char*)addr;
80105854:	8b 55 08             	mov    0x8(%ebp),%edx
80105857:	8b 45 0c             	mov    0xc(%ebp),%eax
8010585a:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
8010585c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105862:	8b 00                	mov    (%eax),%eax
80105864:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105867:	8b 45 0c             	mov    0xc(%ebp),%eax
8010586a:	8b 00                	mov    (%eax),%eax
8010586c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010586f:	eb 1e                	jmp    8010588f <fetchstr+0x55>
    if(*s == 0)
80105871:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105874:	0f b6 00             	movzbl (%eax),%eax
80105877:	84 c0                	test   %al,%al
80105879:	75 10                	jne    8010588b <fetchstr+0x51>
      return s - *pp;
8010587b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010587e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105881:	8b 00                	mov    (%eax),%eax
80105883:	89 d1                	mov    %edx,%ecx
80105885:	29 c1                	sub    %eax,%ecx
80105887:	89 c8                	mov    %ecx,%eax
80105889:	eb 11                	jmp    8010589c <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010588b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010588f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105892:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105895:	72 da                	jb     80105871 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105897:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010589c:	c9                   	leave  
8010589d:	c3                   	ret    

8010589e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010589e:	55                   	push   %ebp
8010589f:	89 e5                	mov    %esp,%ebp
801058a1:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801058a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058aa:	8b 40 18             	mov    0x18(%eax),%eax
801058ad:	8b 50 44             	mov    0x44(%eax),%edx
801058b0:	8b 45 08             	mov    0x8(%ebp),%eax
801058b3:	c1 e0 02             	shl    $0x2,%eax
801058b6:	01 d0                	add    %edx,%eax
801058b8:	8d 50 04             	lea    0x4(%eax),%edx
801058bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801058be:	89 44 24 04          	mov    %eax,0x4(%esp)
801058c2:	89 14 24             	mov    %edx,(%esp)
801058c5:	e8 36 ff ff ff       	call   80105800 <fetchint>
}
801058ca:	c9                   	leave  
801058cb:	c3                   	ret    

801058cc <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801058cc:	55                   	push   %ebp
801058cd:	89 e5                	mov    %esp,%ebp
801058cf:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801058d2:	8d 45 fc             	lea    -0x4(%ebp),%eax
801058d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801058d9:	8b 45 08             	mov    0x8(%ebp),%eax
801058dc:	89 04 24             	mov    %eax,(%esp)
801058df:	e8 ba ff ff ff       	call   8010589e <argint>
801058e4:	85 c0                	test   %eax,%eax
801058e6:	79 07                	jns    801058ef <argptr+0x23>
    return -1;
801058e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ed:	eb 3d                	jmp    8010592c <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801058ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058f2:	89 c2                	mov    %eax,%edx
801058f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058fa:	8b 00                	mov    (%eax),%eax
801058fc:	39 c2                	cmp    %eax,%edx
801058fe:	73 16                	jae    80105916 <argptr+0x4a>
80105900:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105903:	89 c2                	mov    %eax,%edx
80105905:	8b 45 10             	mov    0x10(%ebp),%eax
80105908:	01 c2                	add    %eax,%edx
8010590a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105910:	8b 00                	mov    (%eax),%eax
80105912:	39 c2                	cmp    %eax,%edx
80105914:	76 07                	jbe    8010591d <argptr+0x51>
    return -1;
80105916:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591b:	eb 0f                	jmp    8010592c <argptr+0x60>
  *pp = (char*)i;
8010591d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105920:	89 c2                	mov    %eax,%edx
80105922:	8b 45 0c             	mov    0xc(%ebp),%eax
80105925:	89 10                	mov    %edx,(%eax)
  return 0;
80105927:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010592c:	c9                   	leave  
8010592d:	c3                   	ret    

8010592e <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010592e:	55                   	push   %ebp
8010592f:	89 e5                	mov    %esp,%ebp
80105931:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105934:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105937:	89 44 24 04          	mov    %eax,0x4(%esp)
8010593b:	8b 45 08             	mov    0x8(%ebp),%eax
8010593e:	89 04 24             	mov    %eax,(%esp)
80105941:	e8 58 ff ff ff       	call   8010589e <argint>
80105946:	85 c0                	test   %eax,%eax
80105948:	79 07                	jns    80105951 <argstr+0x23>
    return -1;
8010594a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010594f:	eb 12                	jmp    80105963 <argstr+0x35>
  return fetchstr(addr, pp);
80105951:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105954:	8b 55 0c             	mov    0xc(%ebp),%edx
80105957:	89 54 24 04          	mov    %edx,0x4(%esp)
8010595b:	89 04 24             	mov    %eax,(%esp)
8010595e:	e8 d7 fe ff ff       	call   8010583a <fetchstr>
}
80105963:	c9                   	leave  
80105964:	c3                   	ret    

80105965 <syscall>:
[SYS_mutex_unlock]    sys_mutex_unlock,
};

void
syscall(void)
{
80105965:	55                   	push   %ebp
80105966:	89 e5                	mov    %esp,%ebp
80105968:	53                   	push   %ebx
80105969:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
8010596c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105972:	8b 40 18             	mov    0x18(%eax),%eax
80105975:	8b 40 1c             	mov    0x1c(%eax),%eax
80105978:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010597b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010597f:	7e 30                	jle    801059b1 <syscall+0x4c>
80105981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105984:	83 f8 1f             	cmp    $0x1f,%eax
80105987:	77 28                	ja     801059b1 <syscall+0x4c>
80105989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010598c:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105993:	85 c0                	test   %eax,%eax
80105995:	74 1a                	je     801059b1 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105997:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010599d:	8b 58 18             	mov    0x18(%eax),%ebx
801059a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a3:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801059aa:	ff d0                	call   *%eax
801059ac:	89 43 1c             	mov    %eax,0x1c(%ebx)
801059af:	eb 3d                	jmp    801059ee <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801059b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059b7:	8d 48 6c             	lea    0x6c(%eax),%ecx
801059ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801059c0:	8b 40 10             	mov    0x10(%eax),%eax
801059c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
801059ca:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801059ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801059d2:	c7 04 24 db 8e 10 80 	movl   $0x80108edb,(%esp)
801059d9:	e8 c3 a9 ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801059de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059e4:	8b 40 18             	mov    0x18(%eax),%eax
801059e7:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801059ee:	83 c4 24             	add    $0x24,%esp
801059f1:	5b                   	pop    %ebx
801059f2:	5d                   	pop    %ebp
801059f3:	c3                   	ret    

801059f4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801059f4:	55                   	push   %ebp
801059f5:	89 e5                	mov    %esp,%ebp
801059f7:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801059fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a01:	8b 45 08             	mov    0x8(%ebp),%eax
80105a04:	89 04 24             	mov    %eax,(%esp)
80105a07:	e8 92 fe ff ff       	call   8010589e <argint>
80105a0c:	85 c0                	test   %eax,%eax
80105a0e:	79 07                	jns    80105a17 <argfd+0x23>
    return -1;
80105a10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a15:	eb 50                	jmp    80105a67 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a1a:	85 c0                	test   %eax,%eax
80105a1c:	78 21                	js     80105a3f <argfd+0x4b>
80105a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a21:	83 f8 0f             	cmp    $0xf,%eax
80105a24:	7f 19                	jg     80105a3f <argfd+0x4b>
80105a26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a2f:	83 c2 08             	add    $0x8,%edx
80105a32:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a36:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a3d:	75 07                	jne    80105a46 <argfd+0x52>
    return -1;
80105a3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a44:	eb 21                	jmp    80105a67 <argfd+0x73>
  if(pfd)
80105a46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a4a:	74 08                	je     80105a54 <argfd+0x60>
    *pfd = fd;
80105a4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a52:	89 10                	mov    %edx,(%eax)
  if(pf)
80105a54:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a58:	74 08                	je     80105a62 <argfd+0x6e>
    *pf = f;
80105a5a:	8b 45 10             	mov    0x10(%ebp),%eax
80105a5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a60:	89 10                	mov    %edx,(%eax)
  return 0;
80105a62:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a67:	c9                   	leave  
80105a68:	c3                   	ret    

80105a69 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105a69:	55                   	push   %ebp
80105a6a:	89 e5                	mov    %esp,%ebp
80105a6c:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105a6f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105a76:	eb 30                	jmp    80105aa8 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105a78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a7e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a81:	83 c2 08             	add    $0x8,%edx
80105a84:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a88:	85 c0                	test   %eax,%eax
80105a8a:	75 18                	jne    80105aa4 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105a8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a92:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a95:	8d 4a 08             	lea    0x8(%edx),%ecx
80105a98:	8b 55 08             	mov    0x8(%ebp),%edx
80105a9b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105a9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105aa2:	eb 0f                	jmp    80105ab3 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105aa4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105aa8:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105aac:	7e ca                	jle    80105a78 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105aae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ab3:	c9                   	leave  
80105ab4:	c3                   	ret    

80105ab5 <sys_dup>:

int
sys_dup(void)
{
80105ab5:	55                   	push   %ebp
80105ab6:	89 e5                	mov    %esp,%ebp
80105ab8:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105abb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105abe:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ac2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ac9:	00 
80105aca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ad1:	e8 1e ff ff ff       	call   801059f4 <argfd>
80105ad6:	85 c0                	test   %eax,%eax
80105ad8:	79 07                	jns    80105ae1 <sys_dup+0x2c>
    return -1;
80105ada:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105adf:	eb 29                	jmp    80105b0a <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105ae1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae4:	89 04 24             	mov    %eax,(%esp)
80105ae7:	e8 7d ff ff ff       	call   80105a69 <fdalloc>
80105aec:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105af3:	79 07                	jns    80105afc <sys_dup+0x47>
    return -1;
80105af5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105afa:	eb 0e                	jmp    80105b0a <sys_dup+0x55>
  filedup(f);
80105afc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aff:	89 04 24             	mov    %eax,(%esp)
80105b02:	e8 81 b4 ff ff       	call   80100f88 <filedup>
  return fd;
80105b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b0a:	c9                   	leave  
80105b0b:	c3                   	ret    

80105b0c <sys_read>:

int
sys_read(void)
{
80105b0c:	55                   	push   %ebp
80105b0d:	89 e5                	mov    %esp,%ebp
80105b0f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b12:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b15:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b19:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b20:	00 
80105b21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b28:	e8 c7 fe ff ff       	call   801059f4 <argfd>
80105b2d:	85 c0                	test   %eax,%eax
80105b2f:	78 35                	js     80105b66 <sys_read+0x5a>
80105b31:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b34:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b38:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105b3f:	e8 5a fd ff ff       	call   8010589e <argint>
80105b44:	85 c0                	test   %eax,%eax
80105b46:	78 1e                	js     80105b66 <sys_read+0x5a>
80105b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b4f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b52:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b5d:	e8 6a fd ff ff       	call   801058cc <argptr>
80105b62:	85 c0                	test   %eax,%eax
80105b64:	79 07                	jns    80105b6d <sys_read+0x61>
    return -1;
80105b66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b6b:	eb 19                	jmp    80105b86 <sys_read+0x7a>
  return fileread(f, p, n);
80105b6d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b70:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b76:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105b7a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b7e:	89 04 24             	mov    %eax,(%esp)
80105b81:	e8 6f b5 ff ff       	call   801010f5 <fileread>
}
80105b86:	c9                   	leave  
80105b87:	c3                   	ret    

80105b88 <sys_write>:

int
sys_write(void)
{
80105b88:	55                   	push   %ebp
80105b89:	89 e5                	mov    %esp,%ebp
80105b8b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b91:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b9c:	00 
80105b9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ba4:	e8 4b fe ff ff       	call   801059f4 <argfd>
80105ba9:	85 c0                	test   %eax,%eax
80105bab:	78 35                	js     80105be2 <sys_write+0x5a>
80105bad:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bb4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105bbb:	e8 de fc ff ff       	call   8010589e <argint>
80105bc0:	85 c0                	test   %eax,%eax
80105bc2:	78 1e                	js     80105be2 <sys_write+0x5a>
80105bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bcb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bce:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bd2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105bd9:	e8 ee fc ff ff       	call   801058cc <argptr>
80105bde:	85 c0                	test   %eax,%eax
80105be0:	79 07                	jns    80105be9 <sys_write+0x61>
    return -1;
80105be2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be7:	eb 19                	jmp    80105c02 <sys_write+0x7a>
  return filewrite(f, p, n);
80105be9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105bec:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105bf6:	89 54 24 04          	mov    %edx,0x4(%esp)
80105bfa:	89 04 24             	mov    %eax,(%esp)
80105bfd:	e8 af b5 ff ff       	call   801011b1 <filewrite>
}
80105c02:	c9                   	leave  
80105c03:	c3                   	ret    

80105c04 <sys_close>:

int
sys_close(void)
{
80105c04:	55                   	push   %ebp
80105c05:	89 e5                	mov    %esp,%ebp
80105c07:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105c0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c0d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c11:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c14:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c1f:	e8 d0 fd ff ff       	call   801059f4 <argfd>
80105c24:	85 c0                	test   %eax,%eax
80105c26:	79 07                	jns    80105c2f <sys_close+0x2b>
    return -1;
80105c28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c2d:	eb 24                	jmp    80105c53 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105c2f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c38:	83 c2 08             	add    $0x8,%edx
80105c3b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c42:	00 
  fileclose(f);
80105c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c46:	89 04 24             	mov    %eax,(%esp)
80105c49:	e8 82 b3 ff ff       	call   80100fd0 <fileclose>
  return 0;
80105c4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c53:	c9                   	leave  
80105c54:	c3                   	ret    

80105c55 <sys_fstat>:

int
sys_fstat(void)
{
80105c55:	55                   	push   %ebp
80105c56:	89 e5                	mov    %esp,%ebp
80105c58:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105c5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c5e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c62:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c69:	00 
80105c6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c71:	e8 7e fd ff ff       	call   801059f4 <argfd>
80105c76:	85 c0                	test   %eax,%eax
80105c78:	78 1f                	js     80105c99 <sys_fstat+0x44>
80105c7a:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105c81:	00 
80105c82:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c85:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c89:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c90:	e8 37 fc ff ff       	call   801058cc <argptr>
80105c95:	85 c0                	test   %eax,%eax
80105c97:	79 07                	jns    80105ca0 <sys_fstat+0x4b>
    return -1;
80105c99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c9e:	eb 12                	jmp    80105cb2 <sys_fstat+0x5d>
  return filestat(f, st);
80105ca0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca6:	89 54 24 04          	mov    %edx,0x4(%esp)
80105caa:	89 04 24             	mov    %eax,(%esp)
80105cad:	e8 f4 b3 ff ff       	call   801010a6 <filestat>
}
80105cb2:	c9                   	leave  
80105cb3:	c3                   	ret    

80105cb4 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105cb4:	55                   	push   %ebp
80105cb5:	89 e5                	mov    %esp,%ebp
80105cb7:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105cba:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105cc8:	e8 61 fc ff ff       	call   8010592e <argstr>
80105ccd:	85 c0                	test   %eax,%eax
80105ccf:	78 17                	js     80105ce8 <sys_link+0x34>
80105cd1:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105cd4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cd8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105cdf:	e8 4a fc ff ff       	call   8010592e <argstr>
80105ce4:	85 c0                	test   %eax,%eax
80105ce6:	79 0a                	jns    80105cf2 <sys_link+0x3e>
    return -1;
80105ce8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ced:	e9 41 01 00 00       	jmp    80105e33 <sys_link+0x17f>

  begin_op();
80105cf2:	e8 6a d7 ff ff       	call   80103461 <begin_op>
  if((ip = namei(old)) == 0){
80105cf7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105cfa:	89 04 24             	mov    %eax,(%esp)
80105cfd:	e8 14 c7 ff ff       	call   80102416 <namei>
80105d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d09:	75 0f                	jne    80105d1a <sys_link+0x66>
    end_op();
80105d0b:	e8 d2 d7 ff ff       	call   801034e2 <end_op>
    return -1;
80105d10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d15:	e9 19 01 00 00       	jmp    80105e33 <sys_link+0x17f>
  }

  ilock(ip);
80105d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1d:	89 04 24             	mov    %eax,(%esp)
80105d20:	e8 4f bb ff ff       	call   80101874 <ilock>
  if(ip->type == T_DIR){
80105d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d28:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d2c:	66 83 f8 01          	cmp    $0x1,%ax
80105d30:	75 1a                	jne    80105d4c <sys_link+0x98>
    iunlockput(ip);
80105d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d35:	89 04 24             	mov    %eax,(%esp)
80105d38:	e8 bb bd ff ff       	call   80101af8 <iunlockput>
    end_op();
80105d3d:	e8 a0 d7 ff ff       	call   801034e2 <end_op>
    return -1;
80105d42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d47:	e9 e7 00 00 00       	jmp    80105e33 <sys_link+0x17f>
  }

  ip->nlink++;
80105d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d53:	8d 50 01             	lea    0x1(%eax),%edx
80105d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d59:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d60:	89 04 24             	mov    %eax,(%esp)
80105d63:	e8 50 b9 ff ff       	call   801016b8 <iupdate>
  iunlock(ip);
80105d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d6b:	89 04 24             	mov    %eax,(%esp)
80105d6e:	e8 4f bc ff ff       	call   801019c2 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105d73:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105d76:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105d79:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d7d:	89 04 24             	mov    %eax,(%esp)
80105d80:	e8 b3 c6 ff ff       	call   80102438 <nameiparent>
80105d85:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d88:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d8c:	74 68                	je     80105df6 <sys_link+0x142>
    goto bad;
  ilock(dp);
80105d8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d91:	89 04 24             	mov    %eax,(%esp)
80105d94:	e8 db ba ff ff       	call   80101874 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105d99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d9c:	8b 10                	mov    (%eax),%edx
80105d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da1:	8b 00                	mov    (%eax),%eax
80105da3:	39 c2                	cmp    %eax,%edx
80105da5:	75 20                	jne    80105dc7 <sys_link+0x113>
80105da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105daa:	8b 40 04             	mov    0x4(%eax),%eax
80105dad:	89 44 24 08          	mov    %eax,0x8(%esp)
80105db1:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105db4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105db8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dbb:	89 04 24             	mov    %eax,(%esp)
80105dbe:	e8 92 c3 ff ff       	call   80102155 <dirlink>
80105dc3:	85 c0                	test   %eax,%eax
80105dc5:	79 0d                	jns    80105dd4 <sys_link+0x120>
    iunlockput(dp);
80105dc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dca:	89 04 24             	mov    %eax,(%esp)
80105dcd:	e8 26 bd ff ff       	call   80101af8 <iunlockput>
    goto bad;
80105dd2:	eb 23                	jmp    80105df7 <sys_link+0x143>
  }
  iunlockput(dp);
80105dd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd7:	89 04 24             	mov    %eax,(%esp)
80105dda:	e8 19 bd ff ff       	call   80101af8 <iunlockput>
  iput(ip);
80105ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de2:	89 04 24             	mov    %eax,(%esp)
80105de5:	e8 3d bc ff ff       	call   80101a27 <iput>

  end_op();
80105dea:	e8 f3 d6 ff ff       	call   801034e2 <end_op>

  return 0;
80105def:	b8 00 00 00 00       	mov    $0x0,%eax
80105df4:	eb 3d                	jmp    80105e33 <sys_link+0x17f>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105df6:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dfa:	89 04 24             	mov    %eax,(%esp)
80105dfd:	e8 72 ba ff ff       	call   80101874 <ilock>
  ip->nlink--;
80105e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e05:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e09:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e16:	89 04 24             	mov    %eax,(%esp)
80105e19:	e8 9a b8 ff ff       	call   801016b8 <iupdate>
  iunlockput(ip);
80105e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e21:	89 04 24             	mov    %eax,(%esp)
80105e24:	e8 cf bc ff ff       	call   80101af8 <iunlockput>
  end_op();
80105e29:	e8 b4 d6 ff ff       	call   801034e2 <end_op>
  return -1;
80105e2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e33:	c9                   	leave  
80105e34:	c3                   	ret    

80105e35 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105e35:	55                   	push   %ebp
80105e36:	89 e5                	mov    %esp,%ebp
80105e38:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e3b:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105e42:	eb 4b                	jmp    80105e8f <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e47:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105e4e:	00 
80105e4f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e53:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e56:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80105e5d:	89 04 24             	mov    %eax,(%esp)
80105e60:	e8 05 bf ff ff       	call   80101d6a <readi>
80105e65:	83 f8 10             	cmp    $0x10,%eax
80105e68:	74 0c                	je     80105e76 <isdirempty+0x41>
      panic("isdirempty: readi");
80105e6a:	c7 04 24 f7 8e 10 80 	movl   $0x80108ef7,(%esp)
80105e71:	e8 c7 a6 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105e76:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105e7a:	66 85 c0             	test   %ax,%ax
80105e7d:	74 07                	je     80105e86 <isdirempty+0x51>
      return 0;
80105e7f:	b8 00 00 00 00       	mov    $0x0,%eax
80105e84:	eb 1b                	jmp    80105ea1 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e89:	83 c0 10             	add    $0x10,%eax
80105e8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e92:	8b 45 08             	mov    0x8(%ebp),%eax
80105e95:	8b 40 18             	mov    0x18(%eax),%eax
80105e98:	39 c2                	cmp    %eax,%edx
80105e9a:	72 a8                	jb     80105e44 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105e9c:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105ea1:	c9                   	leave  
80105ea2:	c3                   	ret    

80105ea3 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105ea3:	55                   	push   %ebp
80105ea4:	89 e5                	mov    %esp,%ebp
80105ea6:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105ea9:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105eac:	89 44 24 04          	mov    %eax,0x4(%esp)
80105eb0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105eb7:	e8 72 fa ff ff       	call   8010592e <argstr>
80105ebc:	85 c0                	test   %eax,%eax
80105ebe:	79 0a                	jns    80105eca <sys_unlink+0x27>
    return -1;
80105ec0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ec5:	e9 af 01 00 00       	jmp    80106079 <sys_unlink+0x1d6>

  begin_op();
80105eca:	e8 92 d5 ff ff       	call   80103461 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105ecf:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105ed2:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105ed5:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ed9:	89 04 24             	mov    %eax,(%esp)
80105edc:	e8 57 c5 ff ff       	call   80102438 <nameiparent>
80105ee1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ee4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ee8:	75 0f                	jne    80105ef9 <sys_unlink+0x56>
    end_op();
80105eea:	e8 f3 d5 ff ff       	call   801034e2 <end_op>
    return -1;
80105eef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef4:	e9 80 01 00 00       	jmp    80106079 <sys_unlink+0x1d6>
  }

  ilock(dp);
80105ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105efc:	89 04 24             	mov    %eax,(%esp)
80105eff:	e8 70 b9 ff ff       	call   80101874 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f04:	c7 44 24 04 09 8f 10 	movl   $0x80108f09,0x4(%esp)
80105f0b:	80 
80105f0c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f0f:	89 04 24             	mov    %eax,(%esp)
80105f12:	e8 54 c1 ff ff       	call   8010206b <namecmp>
80105f17:	85 c0                	test   %eax,%eax
80105f19:	0f 84 45 01 00 00    	je     80106064 <sys_unlink+0x1c1>
80105f1f:	c7 44 24 04 0b 8f 10 	movl   $0x80108f0b,0x4(%esp)
80105f26:	80 
80105f27:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f2a:	89 04 24             	mov    %eax,(%esp)
80105f2d:	e8 39 c1 ff ff       	call   8010206b <namecmp>
80105f32:	85 c0                	test   %eax,%eax
80105f34:	0f 84 2a 01 00 00    	je     80106064 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105f3a:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105f3d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f41:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f44:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4b:	89 04 24             	mov    %eax,(%esp)
80105f4e:	e8 3a c1 ff ff       	call   8010208d <dirlookup>
80105f53:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f56:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f5a:	0f 84 03 01 00 00    	je     80106063 <sys_unlink+0x1c0>
    goto bad;
  ilock(ip);
80105f60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f63:	89 04 24             	mov    %eax,(%esp)
80105f66:	e8 09 b9 ff ff       	call   80101874 <ilock>

  if(ip->nlink < 1)
80105f6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f72:	66 85 c0             	test   %ax,%ax
80105f75:	7f 0c                	jg     80105f83 <sys_unlink+0xe0>
    panic("unlink: nlink < 1");
80105f77:	c7 04 24 0e 8f 10 80 	movl   $0x80108f0e,(%esp)
80105f7e:	e8 ba a5 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105f83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f86:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f8a:	66 83 f8 01          	cmp    $0x1,%ax
80105f8e:	75 1f                	jne    80105faf <sys_unlink+0x10c>
80105f90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f93:	89 04 24             	mov    %eax,(%esp)
80105f96:	e8 9a fe ff ff       	call   80105e35 <isdirempty>
80105f9b:	85 c0                	test   %eax,%eax
80105f9d:	75 10                	jne    80105faf <sys_unlink+0x10c>
    iunlockput(ip);
80105f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa2:	89 04 24             	mov    %eax,(%esp)
80105fa5:	e8 4e bb ff ff       	call   80101af8 <iunlockput>
    goto bad;
80105faa:	e9 b5 00 00 00       	jmp    80106064 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105faf:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105fb6:	00 
80105fb7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105fbe:	00 
80105fbf:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105fc2:	89 04 24             	mov    %eax,(%esp)
80105fc5:	e8 78 f5 ff ff       	call   80105542 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105fca:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105fcd:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105fd4:	00 
80105fd5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fd9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105fdc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe3:	89 04 24             	mov    %eax,(%esp)
80105fe6:	e8 ea be ff ff       	call   80101ed5 <writei>
80105feb:	83 f8 10             	cmp    $0x10,%eax
80105fee:	74 0c                	je     80105ffc <sys_unlink+0x159>
    panic("unlink: writei");
80105ff0:	c7 04 24 20 8f 10 80 	movl   $0x80108f20,(%esp)
80105ff7:	e8 41 a5 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fff:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106003:	66 83 f8 01          	cmp    $0x1,%ax
80106007:	75 1c                	jne    80106025 <sys_unlink+0x182>
    dp->nlink--;
80106009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106010:	8d 50 ff             	lea    -0x1(%eax),%edx
80106013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106016:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010601a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010601d:	89 04 24             	mov    %eax,(%esp)
80106020:	e8 93 b6 ff ff       	call   801016b8 <iupdate>
  }
  iunlockput(dp);
80106025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106028:	89 04 24             	mov    %eax,(%esp)
8010602b:	e8 c8 ba ff ff       	call   80101af8 <iunlockput>

  ip->nlink--;
80106030:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106033:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106037:	8d 50 ff             	lea    -0x1(%eax),%edx
8010603a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603d:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106041:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106044:	89 04 24             	mov    %eax,(%esp)
80106047:	e8 6c b6 ff ff       	call   801016b8 <iupdate>
  iunlockput(ip);
8010604c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010604f:	89 04 24             	mov    %eax,(%esp)
80106052:	e8 a1 ba ff ff       	call   80101af8 <iunlockput>

  end_op();
80106057:	e8 86 d4 ff ff       	call   801034e2 <end_op>

  return 0;
8010605c:	b8 00 00 00 00       	mov    $0x0,%eax
80106061:	eb 16                	jmp    80106079 <sys_unlink+0x1d6>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106063:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80106064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106067:	89 04 24             	mov    %eax,(%esp)
8010606a:	e8 89 ba ff ff       	call   80101af8 <iunlockput>
  end_op();
8010606f:	e8 6e d4 ff ff       	call   801034e2 <end_op>
  return -1;
80106074:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106079:	c9                   	leave  
8010607a:	c3                   	ret    

8010607b <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010607b:	55                   	push   %ebp
8010607c:	89 e5                	mov    %esp,%ebp
8010607e:	83 ec 48             	sub    $0x48,%esp
80106081:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106084:	8b 55 10             	mov    0x10(%ebp),%edx
80106087:	8b 45 14             	mov    0x14(%ebp),%eax
8010608a:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010608e:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106092:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106096:	8d 45 de             	lea    -0x22(%ebp),%eax
80106099:	89 44 24 04          	mov    %eax,0x4(%esp)
8010609d:	8b 45 08             	mov    0x8(%ebp),%eax
801060a0:	89 04 24             	mov    %eax,(%esp)
801060a3:	e8 90 c3 ff ff       	call   80102438 <nameiparent>
801060a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060af:	75 0a                	jne    801060bb <create+0x40>
    return 0;
801060b1:	b8 00 00 00 00       	mov    $0x0,%eax
801060b6:	e9 7e 01 00 00       	jmp    80106239 <create+0x1be>
  ilock(dp);
801060bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060be:	89 04 24             	mov    %eax,(%esp)
801060c1:	e8 ae b7 ff ff       	call   80101874 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801060c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801060c9:	89 44 24 08          	mov    %eax,0x8(%esp)
801060cd:	8d 45 de             	lea    -0x22(%ebp),%eax
801060d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801060d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d7:	89 04 24             	mov    %eax,(%esp)
801060da:	e8 ae bf ff ff       	call   8010208d <dirlookup>
801060df:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060e6:	74 47                	je     8010612f <create+0xb4>
    iunlockput(dp);
801060e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060eb:	89 04 24             	mov    %eax,(%esp)
801060ee:	e8 05 ba ff ff       	call   80101af8 <iunlockput>
    ilock(ip);
801060f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f6:	89 04 24             	mov    %eax,(%esp)
801060f9:	e8 76 b7 ff ff       	call   80101874 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801060fe:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106103:	75 15                	jne    8010611a <create+0x9f>
80106105:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106108:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010610c:	66 83 f8 02          	cmp    $0x2,%ax
80106110:	75 08                	jne    8010611a <create+0x9f>
      return ip;
80106112:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106115:	e9 1f 01 00 00       	jmp    80106239 <create+0x1be>
    iunlockput(ip);
8010611a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010611d:	89 04 24             	mov    %eax,(%esp)
80106120:	e8 d3 b9 ff ff       	call   80101af8 <iunlockput>
    return 0;
80106125:	b8 00 00 00 00       	mov    $0x0,%eax
8010612a:	e9 0a 01 00 00       	jmp    80106239 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010612f:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106136:	8b 00                	mov    (%eax),%eax
80106138:	89 54 24 04          	mov    %edx,0x4(%esp)
8010613c:	89 04 24             	mov    %eax,(%esp)
8010613f:	e8 97 b4 ff ff       	call   801015db <ialloc>
80106144:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106147:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010614b:	75 0c                	jne    80106159 <create+0xde>
    panic("create: ialloc");
8010614d:	c7 04 24 2f 8f 10 80 	movl   $0x80108f2f,(%esp)
80106154:	e8 e4 a3 ff ff       	call   8010053d <panic>

  ilock(ip);
80106159:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010615c:	89 04 24             	mov    %eax,(%esp)
8010615f:	e8 10 b7 ff ff       	call   80101874 <ilock>
  ip->major = major;
80106164:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106167:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010616b:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
8010616f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106172:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106176:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
8010617a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617d:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106183:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106186:	89 04 24             	mov    %eax,(%esp)
80106189:	e8 2a b5 ff ff       	call   801016b8 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
8010618e:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106193:	75 6a                	jne    801061ff <create+0x184>
    dp->nlink++;  // for ".."
80106195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106198:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010619c:	8d 50 01             	lea    0x1(%eax),%edx
8010619f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a2:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801061a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a9:	89 04 24             	mov    %eax,(%esp)
801061ac:	e8 07 b5 ff ff       	call   801016b8 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801061b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b4:	8b 40 04             	mov    0x4(%eax),%eax
801061b7:	89 44 24 08          	mov    %eax,0x8(%esp)
801061bb:	c7 44 24 04 09 8f 10 	movl   $0x80108f09,0x4(%esp)
801061c2:	80 
801061c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c6:	89 04 24             	mov    %eax,(%esp)
801061c9:	e8 87 bf ff ff       	call   80102155 <dirlink>
801061ce:	85 c0                	test   %eax,%eax
801061d0:	78 21                	js     801061f3 <create+0x178>
801061d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d5:	8b 40 04             	mov    0x4(%eax),%eax
801061d8:	89 44 24 08          	mov    %eax,0x8(%esp)
801061dc:	c7 44 24 04 0b 8f 10 	movl   $0x80108f0b,0x4(%esp)
801061e3:	80 
801061e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e7:	89 04 24             	mov    %eax,(%esp)
801061ea:	e8 66 bf ff ff       	call   80102155 <dirlink>
801061ef:	85 c0                	test   %eax,%eax
801061f1:	79 0c                	jns    801061ff <create+0x184>
      panic("create dots");
801061f3:	c7 04 24 3e 8f 10 80 	movl   $0x80108f3e,(%esp)
801061fa:	e8 3e a3 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801061ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106202:	8b 40 04             	mov    0x4(%eax),%eax
80106205:	89 44 24 08          	mov    %eax,0x8(%esp)
80106209:	8d 45 de             	lea    -0x22(%ebp),%eax
8010620c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106213:	89 04 24             	mov    %eax,(%esp)
80106216:	e8 3a bf ff ff       	call   80102155 <dirlink>
8010621b:	85 c0                	test   %eax,%eax
8010621d:	79 0c                	jns    8010622b <create+0x1b0>
    panic("create: dirlink");
8010621f:	c7 04 24 4a 8f 10 80 	movl   $0x80108f4a,(%esp)
80106226:	e8 12 a3 ff ff       	call   8010053d <panic>

  iunlockput(dp);
8010622b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622e:	89 04 24             	mov    %eax,(%esp)
80106231:	e8 c2 b8 ff ff       	call   80101af8 <iunlockput>

  return ip;
80106236:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106239:	c9                   	leave  
8010623a:	c3                   	ret    

8010623b <sys_open>:

int
sys_open(void)
{
8010623b:	55                   	push   %ebp
8010623c:	89 e5                	mov    %esp,%ebp
8010623e:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106241:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106244:	89 44 24 04          	mov    %eax,0x4(%esp)
80106248:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010624f:	e8 da f6 ff ff       	call   8010592e <argstr>
80106254:	85 c0                	test   %eax,%eax
80106256:	78 17                	js     8010626f <sys_open+0x34>
80106258:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010625b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010625f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106266:	e8 33 f6 ff ff       	call   8010589e <argint>
8010626b:	85 c0                	test   %eax,%eax
8010626d:	79 0a                	jns    80106279 <sys_open+0x3e>
    return -1;
8010626f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106274:	e9 5a 01 00 00       	jmp    801063d3 <sys_open+0x198>

  begin_op();
80106279:	e8 e3 d1 ff ff       	call   80103461 <begin_op>

  if(omode & O_CREATE){
8010627e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106281:	25 00 02 00 00       	and    $0x200,%eax
80106286:	85 c0                	test   %eax,%eax
80106288:	74 3b                	je     801062c5 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
8010628a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010628d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106294:	00 
80106295:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010629c:	00 
8010629d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801062a4:	00 
801062a5:	89 04 24             	mov    %eax,(%esp)
801062a8:	e8 ce fd ff ff       	call   8010607b <create>
801062ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801062b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062b4:	75 6b                	jne    80106321 <sys_open+0xe6>
      end_op();
801062b6:	e8 27 d2 ff ff       	call   801034e2 <end_op>
      return -1;
801062bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c0:	e9 0e 01 00 00       	jmp    801063d3 <sys_open+0x198>
    }
  } else {
    if((ip = namei(path)) == 0){
801062c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062c8:	89 04 24             	mov    %eax,(%esp)
801062cb:	e8 46 c1 ff ff       	call   80102416 <namei>
801062d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062d7:	75 0f                	jne    801062e8 <sys_open+0xad>
      end_op();
801062d9:	e8 04 d2 ff ff       	call   801034e2 <end_op>
      return -1;
801062de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e3:	e9 eb 00 00 00       	jmp    801063d3 <sys_open+0x198>
    }
    ilock(ip);
801062e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062eb:	89 04 24             	mov    %eax,(%esp)
801062ee:	e8 81 b5 ff ff       	call   80101874 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801062f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801062fa:	66 83 f8 01          	cmp    $0x1,%ax
801062fe:	75 21                	jne    80106321 <sys_open+0xe6>
80106300:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106303:	85 c0                	test   %eax,%eax
80106305:	74 1a                	je     80106321 <sys_open+0xe6>
      iunlockput(ip);
80106307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010630a:	89 04 24             	mov    %eax,(%esp)
8010630d:	e8 e6 b7 ff ff       	call   80101af8 <iunlockput>
      end_op();
80106312:	e8 cb d1 ff ff       	call   801034e2 <end_op>
      return -1;
80106317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010631c:	e9 b2 00 00 00       	jmp    801063d3 <sys_open+0x198>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106321:	e8 02 ac ff ff       	call   80100f28 <filealloc>
80106326:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106329:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010632d:	74 14                	je     80106343 <sys_open+0x108>
8010632f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106332:	89 04 24             	mov    %eax,(%esp)
80106335:	e8 2f f7 ff ff       	call   80105a69 <fdalloc>
8010633a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010633d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106341:	79 28                	jns    8010636b <sys_open+0x130>
    if(f)
80106343:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106347:	74 0b                	je     80106354 <sys_open+0x119>
      fileclose(f);
80106349:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010634c:	89 04 24             	mov    %eax,(%esp)
8010634f:	e8 7c ac ff ff       	call   80100fd0 <fileclose>
    iunlockput(ip);
80106354:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106357:	89 04 24             	mov    %eax,(%esp)
8010635a:	e8 99 b7 ff ff       	call   80101af8 <iunlockput>
    end_op();
8010635f:	e8 7e d1 ff ff       	call   801034e2 <end_op>
    return -1;
80106364:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106369:	eb 68                	jmp    801063d3 <sys_open+0x198>
  }
  iunlock(ip);
8010636b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010636e:	89 04 24             	mov    %eax,(%esp)
80106371:	e8 4c b6 ff ff       	call   801019c2 <iunlock>
  end_op();
80106376:	e8 67 d1 ff ff       	call   801034e2 <end_op>

  f->type = FD_INODE;
8010637b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010637e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106384:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106387:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010638a:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010638d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106390:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106397:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010639a:	83 e0 01             	and    $0x1,%eax
8010639d:	85 c0                	test   %eax,%eax
8010639f:	0f 94 c2             	sete   %dl
801063a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a5:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801063a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063ab:	83 e0 01             	and    $0x1,%eax
801063ae:	84 c0                	test   %al,%al
801063b0:	75 0a                	jne    801063bc <sys_open+0x181>
801063b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063b5:	83 e0 02             	and    $0x2,%eax
801063b8:	85 c0                	test   %eax,%eax
801063ba:	74 07                	je     801063c3 <sys_open+0x188>
801063bc:	b8 01 00 00 00       	mov    $0x1,%eax
801063c1:	eb 05                	jmp    801063c8 <sys_open+0x18d>
801063c3:	b8 00 00 00 00       	mov    $0x0,%eax
801063c8:	89 c2                	mov    %eax,%edx
801063ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063cd:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801063d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801063d3:	c9                   	leave  
801063d4:	c3                   	ret    

801063d5 <sys_mkdir>:

int
sys_mkdir(void)
{
801063d5:	55                   	push   %ebp
801063d6:	89 e5                	mov    %esp,%ebp
801063d8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801063db:	e8 81 d0 ff ff       	call   80103461 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801063e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801063e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063ee:	e8 3b f5 ff ff       	call   8010592e <argstr>
801063f3:	85 c0                	test   %eax,%eax
801063f5:	78 2c                	js     80106423 <sys_mkdir+0x4e>
801063f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106401:	00 
80106402:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106409:	00 
8010640a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106411:	00 
80106412:	89 04 24             	mov    %eax,(%esp)
80106415:	e8 61 fc ff ff       	call   8010607b <create>
8010641a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010641d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106421:	75 0c                	jne    8010642f <sys_mkdir+0x5a>
    end_op();
80106423:	e8 ba d0 ff ff       	call   801034e2 <end_op>
    return -1;
80106428:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010642d:	eb 15                	jmp    80106444 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
8010642f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106432:	89 04 24             	mov    %eax,(%esp)
80106435:	e8 be b6 ff ff       	call   80101af8 <iunlockput>
  end_op();
8010643a:	e8 a3 d0 ff ff       	call   801034e2 <end_op>
  return 0;
8010643f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106444:	c9                   	leave  
80106445:	c3                   	ret    

80106446 <sys_mknod>:

int
sys_mknod(void)
{
80106446:	55                   	push   %ebp
80106447:	89 e5                	mov    %esp,%ebp
80106449:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
8010644c:	e8 10 d0 ff ff       	call   80103461 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106451:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106454:	89 44 24 04          	mov    %eax,0x4(%esp)
80106458:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010645f:	e8 ca f4 ff ff       	call   8010592e <argstr>
80106464:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106467:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010646b:	78 5e                	js     801064cb <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010646d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106470:	89 44 24 04          	mov    %eax,0x4(%esp)
80106474:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010647b:	e8 1e f4 ff ff       	call   8010589e <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106480:	85 c0                	test   %eax,%eax
80106482:	78 47                	js     801064cb <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106484:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106487:	89 44 24 04          	mov    %eax,0x4(%esp)
8010648b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106492:	e8 07 f4 ff ff       	call   8010589e <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106497:	85 c0                	test   %eax,%eax
80106499:	78 30                	js     801064cb <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010649b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010649e:	0f bf c8             	movswl %ax,%ecx
801064a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064a4:	0f bf d0             	movswl %ax,%edx
801064a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801064aa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801064ae:	89 54 24 08          	mov    %edx,0x8(%esp)
801064b2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801064b9:	00 
801064ba:	89 04 24             	mov    %eax,(%esp)
801064bd:	e8 b9 fb ff ff       	call   8010607b <create>
801064c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064c9:	75 0c                	jne    801064d7 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801064cb:	e8 12 d0 ff ff       	call   801034e2 <end_op>
    return -1;
801064d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064d5:	eb 15                	jmp    801064ec <sys_mknod+0xa6>
  }
  iunlockput(ip);
801064d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064da:	89 04 24             	mov    %eax,(%esp)
801064dd:	e8 16 b6 ff ff       	call   80101af8 <iunlockput>
  end_op();
801064e2:	e8 fb cf ff ff       	call   801034e2 <end_op>
  return 0;
801064e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064ec:	c9                   	leave  
801064ed:	c3                   	ret    

801064ee <sys_chdir>:

int
sys_chdir(void)
{
801064ee:	55                   	push   %ebp
801064ef:	89 e5                	mov    %esp,%ebp
801064f1:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801064f4:	e8 68 cf ff ff       	call   80103461 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801064f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106500:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106507:	e8 22 f4 ff ff       	call   8010592e <argstr>
8010650c:	85 c0                	test   %eax,%eax
8010650e:	78 14                	js     80106524 <sys_chdir+0x36>
80106510:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106513:	89 04 24             	mov    %eax,(%esp)
80106516:	e8 fb be ff ff       	call   80102416 <namei>
8010651b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010651e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106522:	75 0c                	jne    80106530 <sys_chdir+0x42>
    end_op();
80106524:	e8 b9 cf ff ff       	call   801034e2 <end_op>
    return -1;
80106529:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010652e:	eb 61                	jmp    80106591 <sys_chdir+0xa3>
  }
  ilock(ip);
80106530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106533:	89 04 24             	mov    %eax,(%esp)
80106536:	e8 39 b3 ff ff       	call   80101874 <ilock>
  if(ip->type != T_DIR){
8010653b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010653e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106542:	66 83 f8 01          	cmp    $0x1,%ax
80106546:	74 17                	je     8010655f <sys_chdir+0x71>
    iunlockput(ip);
80106548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010654b:	89 04 24             	mov    %eax,(%esp)
8010654e:	e8 a5 b5 ff ff       	call   80101af8 <iunlockput>
    end_op();
80106553:	e8 8a cf ff ff       	call   801034e2 <end_op>
    return -1;
80106558:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010655d:	eb 32                	jmp    80106591 <sys_chdir+0xa3>
  }
  iunlock(ip);
8010655f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106562:	89 04 24             	mov    %eax,(%esp)
80106565:	e8 58 b4 ff ff       	call   801019c2 <iunlock>
  iput(proc->cwd);
8010656a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106570:	8b 40 68             	mov    0x68(%eax),%eax
80106573:	89 04 24             	mov    %eax,(%esp)
80106576:	e8 ac b4 ff ff       	call   80101a27 <iput>
  end_op();
8010657b:	e8 62 cf ff ff       	call   801034e2 <end_op>
  proc->cwd = ip;
80106580:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106586:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106589:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010658c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106591:	c9                   	leave  
80106592:	c3                   	ret    

80106593 <sys_exec>:

int
sys_exec(void)
{
80106593:	55                   	push   %ebp
80106594:	89 e5                	mov    %esp,%ebp
80106596:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010659c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010659f:	89 44 24 04          	mov    %eax,0x4(%esp)
801065a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065aa:	e8 7f f3 ff ff       	call   8010592e <argstr>
801065af:	85 c0                	test   %eax,%eax
801065b1:	78 1a                	js     801065cd <sys_exec+0x3a>
801065b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801065b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801065bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801065c4:	e8 d5 f2 ff ff       	call   8010589e <argint>
801065c9:	85 c0                	test   %eax,%eax
801065cb:	79 0a                	jns    801065d7 <sys_exec+0x44>
    return -1;
801065cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065d2:	e9 cc 00 00 00       	jmp    801066a3 <sys_exec+0x110>
  }
  memset(argv, 0, sizeof(argv));
801065d7:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801065de:	00 
801065df:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801065e6:	00 
801065e7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801065ed:	89 04 24             	mov    %eax,(%esp)
801065f0:	e8 4d ef ff ff       	call   80105542 <memset>
  for(i=0;; i++){
801065f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801065fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ff:	83 f8 1f             	cmp    $0x1f,%eax
80106602:	76 0a                	jbe    8010660e <sys_exec+0x7b>
      return -1;
80106604:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106609:	e9 95 00 00 00       	jmp    801066a3 <sys_exec+0x110>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010660e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106611:	c1 e0 02             	shl    $0x2,%eax
80106614:	89 c2                	mov    %eax,%edx
80106616:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010661c:	01 c2                	add    %eax,%edx
8010661e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106624:	89 44 24 04          	mov    %eax,0x4(%esp)
80106628:	89 14 24             	mov    %edx,(%esp)
8010662b:	e8 d0 f1 ff ff       	call   80105800 <fetchint>
80106630:	85 c0                	test   %eax,%eax
80106632:	79 07                	jns    8010663b <sys_exec+0xa8>
      return -1;
80106634:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106639:	eb 68                	jmp    801066a3 <sys_exec+0x110>
    if(uarg == 0){
8010663b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106641:	85 c0                	test   %eax,%eax
80106643:	75 26                	jne    8010666b <sys_exec+0xd8>
      argv[i] = 0;
80106645:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106648:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010664f:	00 00 00 00 
      break;
80106653:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106654:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106657:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010665d:	89 54 24 04          	mov    %edx,0x4(%esp)
80106661:	89 04 24             	mov    %eax,(%esp)
80106664:	e8 93 a4 ff ff       	call   80100afc <exec>
80106669:	eb 38                	jmp    801066a3 <sys_exec+0x110>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010666b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010666e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106675:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010667b:	01 c2                	add    %eax,%edx
8010667d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106683:	89 54 24 04          	mov    %edx,0x4(%esp)
80106687:	89 04 24             	mov    %eax,(%esp)
8010668a:	e8 ab f1 ff ff       	call   8010583a <fetchstr>
8010668f:	85 c0                	test   %eax,%eax
80106691:	79 07                	jns    8010669a <sys_exec+0x107>
      return -1;
80106693:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106698:	eb 09                	jmp    801066a3 <sys_exec+0x110>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010669a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010669e:	e9 59 ff ff ff       	jmp    801065fc <sys_exec+0x69>
  return exec(path, argv);
}
801066a3:	c9                   	leave  
801066a4:	c3                   	ret    

801066a5 <sys_pipe>:

int
sys_pipe(void)
{
801066a5:	55                   	push   %ebp
801066a6:	89 e5                	mov    %esp,%ebp
801066a8:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801066ab:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801066b2:	00 
801066b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801066ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066c1:	e8 06 f2 ff ff       	call   801058cc <argptr>
801066c6:	85 c0                	test   %eax,%eax
801066c8:	79 0a                	jns    801066d4 <sys_pipe+0x2f>
    return -1;
801066ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066cf:	e9 9b 00 00 00       	jmp    8010676f <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801066d4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801066d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801066db:	8d 45 e8             	lea    -0x18(%ebp),%eax
801066de:	89 04 24             	mov    %eax,(%esp)
801066e1:	e8 92 d8 ff ff       	call   80103f78 <pipealloc>
801066e6:	85 c0                	test   %eax,%eax
801066e8:	79 07                	jns    801066f1 <sys_pipe+0x4c>
    return -1;
801066ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ef:	eb 7e                	jmp    8010676f <sys_pipe+0xca>
  fd0 = -1;
801066f1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801066f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066fb:	89 04 24             	mov    %eax,(%esp)
801066fe:	e8 66 f3 ff ff       	call   80105a69 <fdalloc>
80106703:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106706:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010670a:	78 14                	js     80106720 <sys_pipe+0x7b>
8010670c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010670f:	89 04 24             	mov    %eax,(%esp)
80106712:	e8 52 f3 ff ff       	call   80105a69 <fdalloc>
80106717:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010671a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010671e:	79 37                	jns    80106757 <sys_pipe+0xb2>
    if(fd0 >= 0)
80106720:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106724:	78 14                	js     8010673a <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106726:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010672c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010672f:	83 c2 08             	add    $0x8,%edx
80106732:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106739:	00 
    fileclose(rf);
8010673a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010673d:	89 04 24             	mov    %eax,(%esp)
80106740:	e8 8b a8 ff ff       	call   80100fd0 <fileclose>
    fileclose(wf);
80106745:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106748:	89 04 24             	mov    %eax,(%esp)
8010674b:	e8 80 a8 ff ff       	call   80100fd0 <fileclose>
    return -1;
80106750:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106755:	eb 18                	jmp    8010676f <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106757:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010675a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010675d:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010675f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106762:	8d 50 04             	lea    0x4(%eax),%edx
80106765:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106768:	89 02                	mov    %eax,(%edx)
  return 0;
8010676a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010676f:	c9                   	leave  
80106770:	c3                   	ret    
80106771:	00 00                	add    %al,(%eax)
	...

80106774 <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
80106774:	55                   	push   %ebp
80106775:	89 e5                	mov    %esp,%ebp
80106777:	83 ec 08             	sub    $0x8,%esp
8010677a:	8b 55 08             	mov    0x8(%ebp),%edx
8010677d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106780:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106784:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106788:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
8010678c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106790:	66 ef                	out    %ax,(%dx)
}
80106792:	c9                   	leave  
80106793:	c3                   	ret    

80106794 <sys_fork>:
#include "proc.h"
#include "pthread.h"

int
sys_fork(void)
{
80106794:	55                   	push   %ebp
80106795:	89 e5                	mov    %esp,%ebp
80106797:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010679a:	e8 8f de ff ff       	call   8010462e <fork>
}
8010679f:	c9                   	leave  
801067a0:	c3                   	ret    

801067a1 <sys_exit>:

int
sys_exit(void)
{
801067a1:	55                   	push   %ebp
801067a2:	89 e5                	mov    %esp,%ebp
801067a4:	83 ec 08             	sub    $0x8,%esp
  exit();
801067a7:	e8 fd df ff ff       	call   801047a9 <exit>
  return 0;  // not reached
801067ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067b1:	c9                   	leave  
801067b2:	c3                   	ret    

801067b3 <sys_wait>:

int
sys_wait(void)
{
801067b3:	55                   	push   %ebp
801067b4:	89 e5                	mov    %esp,%ebp
801067b6:	83 ec 08             	sub    $0x8,%esp
  return wait();
801067b9:	e8 71 e2 ff ff       	call   80104a2f <wait>
}
801067be:	c9                   	leave  
801067bf:	c3                   	ret    

801067c0 <sys_kill>:

int
sys_kill(void)
{
801067c0:	55                   	push   %ebp
801067c1:	89 e5                	mov    %esp,%ebp
801067c3:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801067c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801067cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067d4:	e8 c5 f0 ff ff       	call   8010589e <argint>
801067d9:	85 c0                	test   %eax,%eax
801067db:	79 07                	jns    801067e4 <sys_kill+0x24>
    return -1;
801067dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067e2:	eb 0b                	jmp    801067ef <sys_kill+0x2f>
  return kill(pid);
801067e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e7:	89 04 24             	mov    %eax,(%esp)
801067ea:	e8 05 e6 ff ff       	call   80104df4 <kill>
}
801067ef:	c9                   	leave  
801067f0:	c3                   	ret    

801067f1 <sys_getpid>:

int
sys_getpid(void)
{
801067f1:	55                   	push   %ebp
801067f2:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801067f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067fa:	8b 40 10             	mov    0x10(%eax),%eax
}
801067fd:	5d                   	pop    %ebp
801067fe:	c3                   	ret    

801067ff <sys_sbrk>:

int
sys_sbrk(void)
{
801067ff:	55                   	push   %ebp
80106800:	89 e5                	mov    %esp,%ebp
80106802:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106805:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106808:	89 44 24 04          	mov    %eax,0x4(%esp)
8010680c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106813:	e8 86 f0 ff ff       	call   8010589e <argint>
80106818:	85 c0                	test   %eax,%eax
8010681a:	79 07                	jns    80106823 <sys_sbrk+0x24>
    return -1;
8010681c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106821:	eb 24                	jmp    80106847 <sys_sbrk+0x48>
  addr = proc->sz;
80106823:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106829:	8b 00                	mov    (%eax),%eax
8010682b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010682e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106831:	89 04 24             	mov    %eax,(%esp)
80106834:	e8 50 dd ff ff       	call   80104589 <growproc>
80106839:	85 c0                	test   %eax,%eax
8010683b:	79 07                	jns    80106844 <sys_sbrk+0x45>
    return -1;
8010683d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106842:	eb 03                	jmp    80106847 <sys_sbrk+0x48>
  return addr;
80106844:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106847:	c9                   	leave  
80106848:	c3                   	ret    

80106849 <sys_sleep>:

int
sys_sleep(void)
{
80106849:	55                   	push   %ebp
8010684a:	89 e5                	mov    %esp,%ebp
8010684c:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010684f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106852:	89 44 24 04          	mov    %eax,0x4(%esp)
80106856:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010685d:	e8 3c f0 ff ff       	call   8010589e <argint>
80106862:	85 c0                	test   %eax,%eax
80106864:	79 07                	jns    8010686d <sys_sleep+0x24>
    return -1;
80106866:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010686b:	eb 6c                	jmp    801068d9 <sys_sleep+0x90>
  acquire(&tickslock);
8010686d:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80106874:	e8 7a ea ff ff       	call   801052f3 <acquire>
  ticks0 = ticks;
80106879:	a1 00 64 11 80       	mov    0x80116400,%eax
8010687e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106881:	eb 34                	jmp    801068b7 <sys_sleep+0x6e>
    if(proc->killed){
80106883:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106889:	8b 40 24             	mov    0x24(%eax),%eax
8010688c:	85 c0                	test   %eax,%eax
8010688e:	74 13                	je     801068a3 <sys_sleep+0x5a>
      release(&tickslock);
80106890:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80106897:	e8 b9 ea ff ff       	call   80105355 <release>
      return -1;
8010689c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068a1:	eb 36                	jmp    801068d9 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
801068a3:	c7 44 24 04 c0 5b 11 	movl   $0x80115bc0,0x4(%esp)
801068aa:	80 
801068ab:	c7 04 24 00 64 11 80 	movl   $0x80116400,(%esp)
801068b2:	e8 36 e4 ff ff       	call   80104ced <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801068b7:	a1 00 64 11 80       	mov    0x80116400,%eax
801068bc:	89 c2                	mov    %eax,%edx
801068be:	2b 55 f4             	sub    -0xc(%ebp),%edx
801068c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068c4:	39 c2                	cmp    %eax,%edx
801068c6:	72 bb                	jb     80106883 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801068c8:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
801068cf:	e8 81 ea ff ff       	call   80105355 <release>
  return 0;
801068d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068d9:	c9                   	leave  
801068da:	c3                   	ret    

801068db <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801068db:	55                   	push   %ebp
801068dc:	89 e5                	mov    %esp,%ebp
801068de:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801068e1:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
801068e8:	e8 06 ea ff ff       	call   801052f3 <acquire>
  xticks = ticks;
801068ed:	a1 00 64 11 80       	mov    0x80116400,%eax
801068f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801068f5:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
801068fc:	e8 54 ea ff ff       	call   80105355 <release>
  return xticks;
80106901:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106904:	c9                   	leave  
80106905:	c3                   	ret    

80106906 <sys_halt>:
// signal to QEMU.
// Based on: http://pdos.csail.mit.edu/6.828/2012/homework/xv6-syscall.html
// and: https://github.com/t3rm1n4l/pintos/blob/master/devices/shutdown.c
int
sys_halt(void)
{
80106906:	55                   	push   %ebp
80106907:	89 e5                	mov    %esp,%ebp
80106909:	83 ec 18             	sub    $0x18,%esp
  char *p = "Shutdown";
8010690c:	c7 45 fc 5a 8f 10 80 	movl   $0x80108f5a,-0x4(%ebp)
  for( ; *p; p++)
80106913:	eb 18                	jmp    8010692d <sys_halt+0x27>
    outw(0xB004, 0x2000);
80106915:	c7 44 24 04 00 20 00 	movl   $0x2000,0x4(%esp)
8010691c:	00 
8010691d:	c7 04 24 04 b0 00 00 	movl   $0xb004,(%esp)
80106924:	e8 4b fe ff ff       	call   80106774 <outw>
// and: https://github.com/t3rm1n4l/pintos/blob/master/devices/shutdown.c
int
sys_halt(void)
{
  char *p = "Shutdown";
  for( ; *p; p++)
80106929:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010692d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106930:	0f b6 00             	movzbl (%eax),%eax
80106933:	84 c0                	test   %al,%al
80106935:	75 de                	jne    80106915 <sys_halt+0xf>
    outw(0xB004, 0x2000);
  return 0;
80106937:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010693c:	c9                   	leave  
8010693d:	c3                   	ret    

8010693e <sys_clone>:


//For project 2
int
sys_clone(void)
{
8010693e:	55                   	push   %ebp
8010693f:	89 e5                	mov    %esp,%ebp
80106941:	83 ec 28             	sub    $0x28,%esp

int myFunction, myArgument, myStack;

if(argint(0, &myFunction) < 0 || argint(1, &myArgument) < 0 || argint(2, &myStack) < 0){
80106944:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106947:	89 44 24 04          	mov    %eax,0x4(%esp)
8010694b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106952:	e8 47 ef ff ff       	call   8010589e <argint>
80106957:	85 c0                	test   %eax,%eax
80106959:	78 2e                	js     80106989 <sys_clone+0x4b>
8010695b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010695e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106962:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106969:	e8 30 ef ff ff       	call   8010589e <argint>
8010696e:	85 c0                	test   %eax,%eax
80106970:	78 17                	js     80106989 <sys_clone+0x4b>
80106972:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106975:	89 44 24 04          	mov    %eax,0x4(%esp)
80106979:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106980:	e8 19 ef ff ff       	call   8010589e <argint>
80106985:	85 c0                	test   %eax,%eax
80106987:	79 07                	jns    80106990 <sys_clone+0x52>
  return -1;
80106989:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010698e:	eb 1d                	jmp    801069ad <sys_clone+0x6f>
}

return clone((void*)myFunction, (void*)myArgument, (void*)myStack);
80106990:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106993:	89 c1                	mov    %eax,%ecx
80106995:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106998:	89 c2                	mov    %eax,%edx
8010699a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010699d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801069a1:	89 54 24 04          	mov    %edx,0x4(%esp)
801069a5:	89 04 24             	mov    %eax,(%esp)
801069a8:	e8 be e5 ff ff       	call   80104f6b <clone>

}
801069ad:	c9                   	leave  
801069ae:	c3                   	ret    

801069af <sys_join>:

int
sys_join(void)
{
801069af:	55                   	push   %ebp
801069b0:	89 e5                	mov    %esp,%ebp
801069b2:	83 ec 28             	sub    $0x28,%esp

int myPid, myStack, myRetval;

if(argint(0, &myPid) < 0 || argint(1, &myStack) < 0 || argint(2, &myRetval)){
801069b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801069bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069c3:	e8 d6 ee ff ff       	call   8010589e <argint>
801069c8:	85 c0                	test   %eax,%eax
801069ca:	78 2e                	js     801069fa <sys_join+0x4b>
801069cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801069d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801069da:	e8 bf ee ff ff       	call   8010589e <argint>
801069df:	85 c0                	test   %eax,%eax
801069e1:	78 17                	js     801069fa <sys_join+0x4b>
801069e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801069e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801069ea:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801069f1:	e8 a8 ee ff ff       	call   8010589e <argint>
801069f6:	85 c0                	test   %eax,%eax
801069f8:	74 07                	je     80106a01 <sys_join+0x52>
  return -1;
801069fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069ff:	eb 1d                	jmp    80106a1e <sys_join+0x6f>
}

return join((int)myPid, (void**)myStack, (void**)myRetval);
80106a01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106a04:	89 c1                	mov    %eax,%ecx
80106a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a09:	89 c2                	mov    %eax,%edx
80106a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a0e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106a12:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a16:	89 04 24             	mov    %eax,(%esp)
80106a19:	e8 05 e7 ff ff       	call   80105123 <join>

}
80106a1e:	c9                   	leave  
80106a1f:	c3                   	ret    

80106a20 <sys_texit>:

int 
sys_texit(void)
{
80106a20:	55                   	push   %ebp
80106a21:	89 e5                	mov    %esp,%ebp
80106a23:	83 ec 28             	sub    $0x28,%esp

int myRetval;

if(argint(0, &myRetval) < 0)
80106a26:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a29:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a34:	e8 65 ee ff ff       	call   8010589e <argint>
80106a39:	85 c0                	test   %eax,%eax
80106a3b:	79 07                	jns    80106a44 <sys_texit+0x24>
  return -1;
80106a3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a42:	eb 0b                	jmp    80106a4f <sys_texit+0x2f>

texit((void*)myRetval);
80106a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a47:	89 04 24             	mov    %eax,(%esp)
80106a4a:	e8 7f de ff ff       	call   801048ce <texit>
return;

}
80106a4f:	c9                   	leave  
80106a50:	c3                   	ret    

80106a51 <sys_mutex_init>:


int 
sys_mutex_init(void)
{
80106a51:	55                   	push   %ebp
80106a52:	89 e5                	mov    %esp,%ebp
80106a54:	83 ec 08             	sub    $0x8,%esp

mutex_init();
80106a57:	e8 05 e8 ff ff       	call   80105261 <mutex_init>
return 0;
80106a5c:	b8 00 00 00 00       	mov    $0x0,%eax

}
80106a61:	c9                   	leave  
80106a62:	c3                   	ret    

80106a63 <sys_mutex_destroy>:


int 
sys_mutex_destroy(void)
{
80106a63:	55                   	push   %ebp
80106a64:	89 e5                	mov    %esp,%ebp
80106a66:	83 ec 28             	sub    $0x28,%esp
  int myMutexID;

  if(argint(0, &myMutexID) < 0)
80106a69:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a77:	e8 22 ee ff ff       	call   8010589e <argint>
80106a7c:	85 c0                	test   %eax,%eax
80106a7e:	79 07                	jns    80106a87 <sys_mutex_destroy+0x24>
    return -1;
80106a80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a85:	eb 10                	jmp    80106a97 <sys_mutex_destroy+0x34>

  mutex_destroy((int)myMutexID);
80106a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a8a:	89 04 24             	mov    %eax,(%esp)
80106a8d:	e8 d9 e7 ff ff       	call   8010526b <mutex_destroy>
  return 0;
80106a92:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a97:	c9                   	leave  
80106a98:	c3                   	ret    

80106a99 <sys_mutex_lock>:


int 
sys_mutex_lock(void)
{
80106a99:	55                   	push   %ebp
80106a9a:	89 e5                	mov    %esp,%ebp
80106a9c:	83 ec 28             	sub    $0x28,%esp
  int myMutexID;

  if(argint(0, &myMutexID) < 0)
80106a9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
80106aa6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106aad:	e8 ec ed ff ff       	call   8010589e <argint>
80106ab2:	85 c0                	test   %eax,%eax
80106ab4:	79 07                	jns    80106abd <sys_mutex_lock+0x24>
    return -1;
80106ab6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106abb:	eb 10                	jmp    80106acd <sys_mutex_lock+0x34>

  mutex_lock((int)myMutexID);
80106abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ac0:	89 04 24             	mov    %eax,(%esp)
80106ac3:	e8 ad e7 ff ff       	call   80105275 <mutex_lock>
  return 0;
80106ac8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106acd:	c9                   	leave  
80106ace:	c3                   	ret    

80106acf <sys_mutex_unlock>:


int 
sys_mutex_unlock(void)
{
80106acf:	55                   	push   %ebp
80106ad0:	89 e5                	mov    %esp,%ebp
80106ad2:	83 ec 28             	sub    $0x28,%esp
  int myMutexID;

  if(argint(0, &myMutexID) < 0)
80106ad5:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
80106adc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ae3:	e8 b6 ed ff ff       	call   8010589e <argint>
80106ae8:	85 c0                	test   %eax,%eax
80106aea:	79 07                	jns    80106af3 <sys_mutex_unlock+0x24>
    return -1;
80106aec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106af1:	eb 10                	jmp    80106b03 <sys_mutex_unlock+0x34>

  mutex_unlock((int)myMutexID);
80106af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af6:	89 04 24             	mov    %eax,(%esp)
80106af9:	e8 81 e7 ff ff       	call   8010527f <mutex_unlock>
  return 0;
80106afe:	b8 00 00 00 00       	mov    $0x0,%eax
80106b03:	c9                   	leave  
80106b04:	c3                   	ret    
80106b05:	00 00                	add    %al,(%eax)
	...

80106b08 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106b08:	55                   	push   %ebp
80106b09:	89 e5                	mov    %esp,%ebp
80106b0b:	83 ec 08             	sub    $0x8,%esp
80106b0e:	8b 55 08             	mov    0x8(%ebp),%edx
80106b11:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b14:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106b18:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b1b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106b1f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106b23:	ee                   	out    %al,(%dx)
}
80106b24:	c9                   	leave  
80106b25:	c3                   	ret    

80106b26 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106b26:	55                   	push   %ebp
80106b27:	89 e5                	mov    %esp,%ebp
80106b29:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106b2c:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106b33:	00 
80106b34:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106b3b:	e8 c8 ff ff ff       	call   80106b08 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106b40:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106b47:	00 
80106b48:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106b4f:	e8 b4 ff ff ff       	call   80106b08 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106b54:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106b5b:	00 
80106b5c:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106b63:	e8 a0 ff ff ff       	call   80106b08 <outb>
  picenable(IRQ_TIMER);
80106b68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b6f:	e8 8d d2 ff ff       	call   80103e01 <picenable>
}
80106b74:	c9                   	leave  
80106b75:	c3                   	ret    
	...

80106b78 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106b78:	1e                   	push   %ds
  pushl %es
80106b79:	06                   	push   %es
  pushl %fs
80106b7a:	0f a0                	push   %fs
  pushl %gs
80106b7c:	0f a8                	push   %gs
  pushal
80106b7e:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106b7f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106b83:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106b85:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106b87:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106b8b:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106b8d:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106b8f:	54                   	push   %esp
  call trap
80106b90:	e8 de 01 00 00       	call   80106d73 <trap>
  addl $4, %esp
80106b95:	83 c4 04             	add    $0x4,%esp

80106b98 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106b98:	61                   	popa   
  popl %gs
80106b99:	0f a9                	pop    %gs
  popl %fs
80106b9b:	0f a1                	pop    %fs
  popl %es
80106b9d:	07                   	pop    %es
  popl %ds
80106b9e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106b9f:	83 c4 08             	add    $0x8,%esp
  iret
80106ba2:	cf                   	iret   
	...

80106ba4 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106ba4:	55                   	push   %ebp
80106ba5:	89 e5                	mov    %esp,%ebp
80106ba7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106baa:	8b 45 0c             	mov    0xc(%ebp),%eax
80106bad:	83 e8 01             	sub    $0x1,%eax
80106bb0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80106bb7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80106bbe:	c1 e8 10             	shr    $0x10,%eax
80106bc1:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106bc5:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106bc8:	0f 01 18             	lidtl  (%eax)
}
80106bcb:	c9                   	leave  
80106bcc:	c3                   	ret    

80106bcd <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106bcd:	55                   	push   %ebp
80106bce:	89 e5                	mov    %esp,%ebp
80106bd0:	53                   	push   %ebx
80106bd1:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106bd4:	0f 20 d3             	mov    %cr2,%ebx
80106bd7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106bda:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106bdd:	83 c4 10             	add    $0x10,%esp
80106be0:	5b                   	pop    %ebx
80106be1:	5d                   	pop    %ebp
80106be2:	c3                   	ret    

80106be3 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106be3:	55                   	push   %ebp
80106be4:	89 e5                	mov    %esp,%ebp
80106be6:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106be9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106bf0:	e9 c3 00 00 00       	jmp    80106cb8 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bf8:	8b 04 85 c0 c0 10 80 	mov    -0x7fef3f40(,%eax,4),%eax
80106bff:	89 c2                	mov    %eax,%edx
80106c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c04:	66 89 14 c5 00 5c 11 	mov    %dx,-0x7feea400(,%eax,8)
80106c0b:	80 
80106c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c0f:	66 c7 04 c5 02 5c 11 	movw   $0x8,-0x7feea3fe(,%eax,8)
80106c16:	80 08 00 
80106c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c1c:	0f b6 14 c5 04 5c 11 	movzbl -0x7feea3fc(,%eax,8),%edx
80106c23:	80 
80106c24:	83 e2 e0             	and    $0xffffffe0,%edx
80106c27:	88 14 c5 04 5c 11 80 	mov    %dl,-0x7feea3fc(,%eax,8)
80106c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c31:	0f b6 14 c5 04 5c 11 	movzbl -0x7feea3fc(,%eax,8),%edx
80106c38:	80 
80106c39:	83 e2 1f             	and    $0x1f,%edx
80106c3c:	88 14 c5 04 5c 11 80 	mov    %dl,-0x7feea3fc(,%eax,8)
80106c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c46:	0f b6 14 c5 05 5c 11 	movzbl -0x7feea3fb(,%eax,8),%edx
80106c4d:	80 
80106c4e:	83 e2 f0             	and    $0xfffffff0,%edx
80106c51:	83 ca 0e             	or     $0xe,%edx
80106c54:	88 14 c5 05 5c 11 80 	mov    %dl,-0x7feea3fb(,%eax,8)
80106c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c5e:	0f b6 14 c5 05 5c 11 	movzbl -0x7feea3fb(,%eax,8),%edx
80106c65:	80 
80106c66:	83 e2 ef             	and    $0xffffffef,%edx
80106c69:	88 14 c5 05 5c 11 80 	mov    %dl,-0x7feea3fb(,%eax,8)
80106c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c73:	0f b6 14 c5 05 5c 11 	movzbl -0x7feea3fb(,%eax,8),%edx
80106c7a:	80 
80106c7b:	83 e2 9f             	and    $0xffffff9f,%edx
80106c7e:	88 14 c5 05 5c 11 80 	mov    %dl,-0x7feea3fb(,%eax,8)
80106c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c88:	0f b6 14 c5 05 5c 11 	movzbl -0x7feea3fb(,%eax,8),%edx
80106c8f:	80 
80106c90:	83 ca 80             	or     $0xffffff80,%edx
80106c93:	88 14 c5 05 5c 11 80 	mov    %dl,-0x7feea3fb(,%eax,8)
80106c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c9d:	8b 04 85 c0 c0 10 80 	mov    -0x7fef3f40(,%eax,4),%eax
80106ca4:	c1 e8 10             	shr    $0x10,%eax
80106ca7:	89 c2                	mov    %eax,%edx
80106ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cac:	66 89 14 c5 06 5c 11 	mov    %dx,-0x7feea3fa(,%eax,8)
80106cb3:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106cb4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106cb8:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106cbf:	0f 8e 30 ff ff ff    	jle    80106bf5 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106cc5:	a1 c0 c1 10 80       	mov    0x8010c1c0,%eax
80106cca:	66 a3 00 5e 11 80    	mov    %ax,0x80115e00
80106cd0:	66 c7 05 02 5e 11 80 	movw   $0x8,0x80115e02
80106cd7:	08 00 
80106cd9:	0f b6 05 04 5e 11 80 	movzbl 0x80115e04,%eax
80106ce0:	83 e0 e0             	and    $0xffffffe0,%eax
80106ce3:	a2 04 5e 11 80       	mov    %al,0x80115e04
80106ce8:	0f b6 05 04 5e 11 80 	movzbl 0x80115e04,%eax
80106cef:	83 e0 1f             	and    $0x1f,%eax
80106cf2:	a2 04 5e 11 80       	mov    %al,0x80115e04
80106cf7:	0f b6 05 05 5e 11 80 	movzbl 0x80115e05,%eax
80106cfe:	83 c8 0f             	or     $0xf,%eax
80106d01:	a2 05 5e 11 80       	mov    %al,0x80115e05
80106d06:	0f b6 05 05 5e 11 80 	movzbl 0x80115e05,%eax
80106d0d:	83 e0 ef             	and    $0xffffffef,%eax
80106d10:	a2 05 5e 11 80       	mov    %al,0x80115e05
80106d15:	0f b6 05 05 5e 11 80 	movzbl 0x80115e05,%eax
80106d1c:	83 c8 60             	or     $0x60,%eax
80106d1f:	a2 05 5e 11 80       	mov    %al,0x80115e05
80106d24:	0f b6 05 05 5e 11 80 	movzbl 0x80115e05,%eax
80106d2b:	83 c8 80             	or     $0xffffff80,%eax
80106d2e:	a2 05 5e 11 80       	mov    %al,0x80115e05
80106d33:	a1 c0 c1 10 80       	mov    0x8010c1c0,%eax
80106d38:	c1 e8 10             	shr    $0x10,%eax
80106d3b:	66 a3 06 5e 11 80    	mov    %ax,0x80115e06
  
  initlock(&tickslock, "time");
80106d41:	c7 44 24 04 64 8f 10 	movl   $0x80108f64,0x4(%esp)
80106d48:	80 
80106d49:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80106d50:	e8 7d e5 ff ff       	call   801052d2 <initlock>
}
80106d55:	c9                   	leave  
80106d56:	c3                   	ret    

80106d57 <idtinit>:

void
idtinit(void)
{
80106d57:	55                   	push   %ebp
80106d58:	89 e5                	mov    %esp,%ebp
80106d5a:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106d5d:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106d64:	00 
80106d65:	c7 04 24 00 5c 11 80 	movl   $0x80115c00,(%esp)
80106d6c:	e8 33 fe ff ff       	call   80106ba4 <lidt>
}
80106d71:	c9                   	leave  
80106d72:	c3                   	ret    

80106d73 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106d73:	55                   	push   %ebp
80106d74:	89 e5                	mov    %esp,%ebp
80106d76:	57                   	push   %edi
80106d77:	56                   	push   %esi
80106d78:	53                   	push   %ebx
80106d79:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106d7c:	8b 45 08             	mov    0x8(%ebp),%eax
80106d7f:	8b 40 30             	mov    0x30(%eax),%eax
80106d82:	83 f8 40             	cmp    $0x40,%eax
80106d85:	75 3e                	jne    80106dc5 <trap+0x52>
    if(proc->killed)
80106d87:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d8d:	8b 40 24             	mov    0x24(%eax),%eax
80106d90:	85 c0                	test   %eax,%eax
80106d92:	74 05                	je     80106d99 <trap+0x26>
      exit();
80106d94:	e8 10 da ff ff       	call   801047a9 <exit>
    proc->tf = tf;
80106d99:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d9f:	8b 55 08             	mov    0x8(%ebp),%edx
80106da2:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106da5:	e8 bb eb ff ff       	call   80105965 <syscall>
    if(proc->killed)
80106daa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106db0:	8b 40 24             	mov    0x24(%eax),%eax
80106db3:	85 c0                	test   %eax,%eax
80106db5:	0f 84 34 02 00 00    	je     80106fef <trap+0x27c>
      exit();
80106dbb:	e8 e9 d9 ff ff       	call   801047a9 <exit>
    return;
80106dc0:	e9 2a 02 00 00       	jmp    80106fef <trap+0x27c>
  }

  switch(tf->trapno){
80106dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80106dc8:	8b 40 30             	mov    0x30(%eax),%eax
80106dcb:	83 e8 20             	sub    $0x20,%eax
80106dce:	83 f8 1f             	cmp    $0x1f,%eax
80106dd1:	0f 87 bc 00 00 00    	ja     80106e93 <trap+0x120>
80106dd7:	8b 04 85 0c 90 10 80 	mov    -0x7fef6ff4(,%eax,4),%eax
80106dde:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106de0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106de6:	0f b6 00             	movzbl (%eax),%eax
80106de9:	84 c0                	test   %al,%al
80106deb:	75 31                	jne    80106e1e <trap+0xab>
      acquire(&tickslock);
80106ded:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80106df4:	e8 fa e4 ff ff       	call   801052f3 <acquire>
      ticks++;
80106df9:	a1 00 64 11 80       	mov    0x80116400,%eax
80106dfe:	83 c0 01             	add    $0x1,%eax
80106e01:	a3 00 64 11 80       	mov    %eax,0x80116400
      wakeup(&ticks);
80106e06:	c7 04 24 00 64 11 80 	movl   $0x80116400,(%esp)
80106e0d:	e8 b7 df ff ff       	call   80104dc9 <wakeup>
      release(&tickslock);
80106e12:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80106e19:	e8 37 e5 ff ff       	call   80105355 <release>
    }
    lapiceoi();
80106e1e:	e8 fc c0 ff ff       	call   80102f1f <lapiceoi>
    break;
80106e23:	e9 41 01 00 00       	jmp    80106f69 <trap+0x1f6>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106e28:	e8 d0 b8 ff ff       	call   801026fd <ideintr>
    lapiceoi();
80106e2d:	e8 ed c0 ff ff       	call   80102f1f <lapiceoi>
    break;
80106e32:	e9 32 01 00 00       	jmp    80106f69 <trap+0x1f6>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106e37:	e8 97 be ff ff       	call   80102cd3 <kbdintr>
    lapiceoi();
80106e3c:	e8 de c0 ff ff       	call   80102f1f <lapiceoi>
    break;
80106e41:	e9 23 01 00 00       	jmp    80106f69 <trap+0x1f6>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106e46:	e8 a9 03 00 00       	call   801071f4 <uartintr>
    lapiceoi();
80106e4b:	e8 cf c0 ff ff       	call   80102f1f <lapiceoi>
    break;
80106e50:	e9 14 01 00 00       	jmp    80106f69 <trap+0x1f6>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106e55:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106e58:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80106e5e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106e62:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106e65:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106e6b:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106e6e:	0f b6 c0             	movzbl %al,%eax
80106e71:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106e75:	89 54 24 08          	mov    %edx,0x8(%esp)
80106e79:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e7d:	c7 04 24 6c 8f 10 80 	movl   $0x80108f6c,(%esp)
80106e84:	e8 18 95 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106e89:	e8 91 c0 ff ff       	call   80102f1f <lapiceoi>
    break;
80106e8e:	e9 d6 00 00 00       	jmp    80106f69 <trap+0x1f6>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106e93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e99:	85 c0                	test   %eax,%eax
80106e9b:	74 11                	je     80106eae <trap+0x13b>
80106e9d:	8b 45 08             	mov    0x8(%ebp),%eax
80106ea0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ea4:	0f b7 c0             	movzwl %ax,%eax
80106ea7:	83 e0 03             	and    $0x3,%eax
80106eaa:	85 c0                	test   %eax,%eax
80106eac:	75 46                	jne    80106ef4 <trap+0x181>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106eae:	e8 1a fd ff ff       	call   80106bcd <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106eb3:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106eb6:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106eb9:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106ec0:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106ec3:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106ec6:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106ec9:	8b 52 30             	mov    0x30(%edx),%edx
80106ecc:	89 44 24 10          	mov    %eax,0x10(%esp)
80106ed0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106ed4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106ed8:	89 54 24 04          	mov    %edx,0x4(%esp)
80106edc:	c7 04 24 90 8f 10 80 	movl   $0x80108f90,(%esp)
80106ee3:	e8 b9 94 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106ee8:	c7 04 24 c2 8f 10 80 	movl   $0x80108fc2,(%esp)
80106eef:	e8 49 96 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ef4:	e8 d4 fc ff ff       	call   80106bcd <rcr2>
80106ef9:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106efb:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106efe:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106f01:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106f07:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f0a:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106f0d:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f10:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106f13:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f16:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106f19:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f1f:	83 c0 6c             	add    $0x6c,%eax
80106f22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106f25:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f2b:	8b 40 10             	mov    0x10(%eax),%eax
80106f2e:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106f32:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106f36:	89 74 24 14          	mov    %esi,0x14(%esp)
80106f3a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106f3e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106f42:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106f45:	89 54 24 08          	mov    %edx,0x8(%esp)
80106f49:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f4d:	c7 04 24 c8 8f 10 80 	movl   $0x80108fc8,(%esp)
80106f54:	e8 48 94 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106f59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f5f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106f66:	eb 01                	jmp    80106f69 <trap+0x1f6>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106f68:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106f69:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f6f:	85 c0                	test   %eax,%eax
80106f71:	74 24                	je     80106f97 <trap+0x224>
80106f73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f79:	8b 40 24             	mov    0x24(%eax),%eax
80106f7c:	85 c0                	test   %eax,%eax
80106f7e:	74 17                	je     80106f97 <trap+0x224>
80106f80:	8b 45 08             	mov    0x8(%ebp),%eax
80106f83:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f87:	0f b7 c0             	movzwl %ax,%eax
80106f8a:	83 e0 03             	and    $0x3,%eax
80106f8d:	83 f8 03             	cmp    $0x3,%eax
80106f90:	75 05                	jne    80106f97 <trap+0x224>
    exit();
80106f92:	e8 12 d8 ff ff       	call   801047a9 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106f97:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f9d:	85 c0                	test   %eax,%eax
80106f9f:	74 1e                	je     80106fbf <trap+0x24c>
80106fa1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fa7:	8b 40 0c             	mov    0xc(%eax),%eax
80106faa:	83 f8 04             	cmp    $0x4,%eax
80106fad:	75 10                	jne    80106fbf <trap+0x24c>
80106faf:	8b 45 08             	mov    0x8(%ebp),%eax
80106fb2:	8b 40 30             	mov    0x30(%eax),%eax
80106fb5:	83 f8 20             	cmp    $0x20,%eax
80106fb8:	75 05                	jne    80106fbf <trap+0x24c>
    yield();
80106fba:	e8 d0 dc ff ff       	call   80104c8f <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106fbf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fc5:	85 c0                	test   %eax,%eax
80106fc7:	74 27                	je     80106ff0 <trap+0x27d>
80106fc9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fcf:	8b 40 24             	mov    0x24(%eax),%eax
80106fd2:	85 c0                	test   %eax,%eax
80106fd4:	74 1a                	je     80106ff0 <trap+0x27d>
80106fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80106fd9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106fdd:	0f b7 c0             	movzwl %ax,%eax
80106fe0:	83 e0 03             	and    $0x3,%eax
80106fe3:	83 f8 03             	cmp    $0x3,%eax
80106fe6:	75 08                	jne    80106ff0 <trap+0x27d>
    exit();
80106fe8:	e8 bc d7 ff ff       	call   801047a9 <exit>
80106fed:	eb 01                	jmp    80106ff0 <trap+0x27d>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106fef:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106ff0:	83 c4 3c             	add    $0x3c,%esp
80106ff3:	5b                   	pop    %ebx
80106ff4:	5e                   	pop    %esi
80106ff5:	5f                   	pop    %edi
80106ff6:	5d                   	pop    %ebp
80106ff7:	c3                   	ret    

80106ff8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106ff8:	55                   	push   %ebp
80106ff9:	89 e5                	mov    %esp,%ebp
80106ffb:	53                   	push   %ebx
80106ffc:	83 ec 14             	sub    $0x14,%esp
80106fff:	8b 45 08             	mov    0x8(%ebp),%eax
80107002:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107006:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010700a:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010700e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80107012:	ec                   	in     (%dx),%al
80107013:	89 c3                	mov    %eax,%ebx
80107015:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80107018:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
8010701c:	83 c4 14             	add    $0x14,%esp
8010701f:	5b                   	pop    %ebx
80107020:	5d                   	pop    %ebp
80107021:	c3                   	ret    

80107022 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107022:	55                   	push   %ebp
80107023:	89 e5                	mov    %esp,%ebp
80107025:	83 ec 08             	sub    $0x8,%esp
80107028:	8b 55 08             	mov    0x8(%ebp),%edx
8010702b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010702e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107032:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107035:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107039:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010703d:	ee                   	out    %al,(%dx)
}
8010703e:	c9                   	leave  
8010703f:	c3                   	ret    

80107040 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107040:	55                   	push   %ebp
80107041:	89 e5                	mov    %esp,%ebp
80107043:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107046:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010704d:	00 
8010704e:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107055:	e8 c8 ff ff ff       	call   80107022 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010705a:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80107061:	00 
80107062:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107069:	e8 b4 ff ff ff       	call   80107022 <outb>
  outb(COM1+0, 115200/9600);
8010706e:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80107075:	00 
80107076:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010707d:	e8 a0 ff ff ff       	call   80107022 <outb>
  outb(COM1+1, 0);
80107082:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107089:	00 
8010708a:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107091:	e8 8c ff ff ff       	call   80107022 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107096:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010709d:	00 
8010709e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801070a5:	e8 78 ff ff ff       	call   80107022 <outb>
  outb(COM1+4, 0);
801070aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801070b1:	00 
801070b2:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
801070b9:	e8 64 ff ff ff       	call   80107022 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801070be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801070c5:	00 
801070c6:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801070cd:	e8 50 ff ff ff       	call   80107022 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801070d2:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801070d9:	e8 1a ff ff ff       	call   80106ff8 <inb>
801070de:	3c ff                	cmp    $0xff,%al
801070e0:	74 6c                	je     8010714e <uartinit+0x10e>
    return;
  uart = 1;
801070e2:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
801070e9:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801070ec:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801070f3:	e8 00 ff ff ff       	call   80106ff8 <inb>
  inb(COM1+0);
801070f8:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801070ff:	e8 f4 fe ff ff       	call   80106ff8 <inb>
  picenable(IRQ_COM1);
80107104:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010710b:	e8 f1 cc ff ff       	call   80103e01 <picenable>
  ioapicenable(IRQ_COM1, 0);
80107110:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107117:	00 
80107118:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010711f:	e8 5e b8 ff ff       	call   80102982 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107124:	c7 45 f4 8c 90 10 80 	movl   $0x8010908c,-0xc(%ebp)
8010712b:	eb 15                	jmp    80107142 <uartinit+0x102>
    uartputc(*p);
8010712d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107130:	0f b6 00             	movzbl (%eax),%eax
80107133:	0f be c0             	movsbl %al,%eax
80107136:	89 04 24             	mov    %eax,(%esp)
80107139:	e8 13 00 00 00       	call   80107151 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010713e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107145:	0f b6 00             	movzbl (%eax),%eax
80107148:	84 c0                	test   %al,%al
8010714a:	75 e1                	jne    8010712d <uartinit+0xed>
8010714c:	eb 01                	jmp    8010714f <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
8010714e:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
8010714f:	c9                   	leave  
80107150:	c3                   	ret    

80107151 <uartputc>:

void
uartputc(int c)
{
80107151:	55                   	push   %ebp
80107152:	89 e5                	mov    %esp,%ebp
80107154:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80107157:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
8010715c:	85 c0                	test   %eax,%eax
8010715e:	74 4d                	je     801071ad <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107160:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107167:	eb 10                	jmp    80107179 <uartputc+0x28>
    microdelay(10);
80107169:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80107170:	e8 cf bd ff ff       	call   80102f44 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107175:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107179:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010717d:	7f 16                	jg     80107195 <uartputc+0x44>
8010717f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107186:	e8 6d fe ff ff       	call   80106ff8 <inb>
8010718b:	0f b6 c0             	movzbl %al,%eax
8010718e:	83 e0 20             	and    $0x20,%eax
80107191:	85 c0                	test   %eax,%eax
80107193:	74 d4                	je     80107169 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107195:	8b 45 08             	mov    0x8(%ebp),%eax
80107198:	0f b6 c0             	movzbl %al,%eax
8010719b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010719f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801071a6:	e8 77 fe ff ff       	call   80107022 <outb>
801071ab:	eb 01                	jmp    801071ae <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
801071ad:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
801071ae:	c9                   	leave  
801071af:	c3                   	ret    

801071b0 <uartgetc>:

static int
uartgetc(void)
{
801071b0:	55                   	push   %ebp
801071b1:	89 e5                	mov    %esp,%ebp
801071b3:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
801071b6:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
801071bb:	85 c0                	test   %eax,%eax
801071bd:	75 07                	jne    801071c6 <uartgetc+0x16>
    return -1;
801071bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071c4:	eb 2c                	jmp    801071f2 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
801071c6:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801071cd:	e8 26 fe ff ff       	call   80106ff8 <inb>
801071d2:	0f b6 c0             	movzbl %al,%eax
801071d5:	83 e0 01             	and    $0x1,%eax
801071d8:	85 c0                	test   %eax,%eax
801071da:	75 07                	jne    801071e3 <uartgetc+0x33>
    return -1;
801071dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071e1:	eb 0f                	jmp    801071f2 <uartgetc+0x42>
  return inb(COM1+0);
801071e3:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801071ea:	e8 09 fe ff ff       	call   80106ff8 <inb>
801071ef:	0f b6 c0             	movzbl %al,%eax
}
801071f2:	c9                   	leave  
801071f3:	c3                   	ret    

801071f4 <uartintr>:

void
uartintr(void)
{
801071f4:	55                   	push   %ebp
801071f5:	89 e5                	mov    %esp,%ebp
801071f7:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
801071fa:	c7 04 24 b0 71 10 80 	movl   $0x801071b0,(%esp)
80107201:	e8 a7 95 ff ff       	call   801007ad <consoleintr>
}
80107206:	c9                   	leave  
80107207:	c3                   	ret    

80107208 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107208:	6a 00                	push   $0x0
  pushl $0
8010720a:	6a 00                	push   $0x0
  jmp alltraps
8010720c:	e9 67 f9 ff ff       	jmp    80106b78 <alltraps>

80107211 <vector1>:
.globl vector1
vector1:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $1
80107213:	6a 01                	push   $0x1
  jmp alltraps
80107215:	e9 5e f9 ff ff       	jmp    80106b78 <alltraps>

8010721a <vector2>:
.globl vector2
vector2:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $2
8010721c:	6a 02                	push   $0x2
  jmp alltraps
8010721e:	e9 55 f9 ff ff       	jmp    80106b78 <alltraps>

80107223 <vector3>:
.globl vector3
vector3:
  pushl $0
80107223:	6a 00                	push   $0x0
  pushl $3
80107225:	6a 03                	push   $0x3
  jmp alltraps
80107227:	e9 4c f9 ff ff       	jmp    80106b78 <alltraps>

8010722c <vector4>:
.globl vector4
vector4:
  pushl $0
8010722c:	6a 00                	push   $0x0
  pushl $4
8010722e:	6a 04                	push   $0x4
  jmp alltraps
80107230:	e9 43 f9 ff ff       	jmp    80106b78 <alltraps>

80107235 <vector5>:
.globl vector5
vector5:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $5
80107237:	6a 05                	push   $0x5
  jmp alltraps
80107239:	e9 3a f9 ff ff       	jmp    80106b78 <alltraps>

8010723e <vector6>:
.globl vector6
vector6:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $6
80107240:	6a 06                	push   $0x6
  jmp alltraps
80107242:	e9 31 f9 ff ff       	jmp    80106b78 <alltraps>

80107247 <vector7>:
.globl vector7
vector7:
  pushl $0
80107247:	6a 00                	push   $0x0
  pushl $7
80107249:	6a 07                	push   $0x7
  jmp alltraps
8010724b:	e9 28 f9 ff ff       	jmp    80106b78 <alltraps>

80107250 <vector8>:
.globl vector8
vector8:
  pushl $8
80107250:	6a 08                	push   $0x8
  jmp alltraps
80107252:	e9 21 f9 ff ff       	jmp    80106b78 <alltraps>

80107257 <vector9>:
.globl vector9
vector9:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $9
80107259:	6a 09                	push   $0x9
  jmp alltraps
8010725b:	e9 18 f9 ff ff       	jmp    80106b78 <alltraps>

80107260 <vector10>:
.globl vector10
vector10:
  pushl $10
80107260:	6a 0a                	push   $0xa
  jmp alltraps
80107262:	e9 11 f9 ff ff       	jmp    80106b78 <alltraps>

80107267 <vector11>:
.globl vector11
vector11:
  pushl $11
80107267:	6a 0b                	push   $0xb
  jmp alltraps
80107269:	e9 0a f9 ff ff       	jmp    80106b78 <alltraps>

8010726e <vector12>:
.globl vector12
vector12:
  pushl $12
8010726e:	6a 0c                	push   $0xc
  jmp alltraps
80107270:	e9 03 f9 ff ff       	jmp    80106b78 <alltraps>

80107275 <vector13>:
.globl vector13
vector13:
  pushl $13
80107275:	6a 0d                	push   $0xd
  jmp alltraps
80107277:	e9 fc f8 ff ff       	jmp    80106b78 <alltraps>

8010727c <vector14>:
.globl vector14
vector14:
  pushl $14
8010727c:	6a 0e                	push   $0xe
  jmp alltraps
8010727e:	e9 f5 f8 ff ff       	jmp    80106b78 <alltraps>

80107283 <vector15>:
.globl vector15
vector15:
  pushl $0
80107283:	6a 00                	push   $0x0
  pushl $15
80107285:	6a 0f                	push   $0xf
  jmp alltraps
80107287:	e9 ec f8 ff ff       	jmp    80106b78 <alltraps>

8010728c <vector16>:
.globl vector16
vector16:
  pushl $0
8010728c:	6a 00                	push   $0x0
  pushl $16
8010728e:	6a 10                	push   $0x10
  jmp alltraps
80107290:	e9 e3 f8 ff ff       	jmp    80106b78 <alltraps>

80107295 <vector17>:
.globl vector17
vector17:
  pushl $17
80107295:	6a 11                	push   $0x11
  jmp alltraps
80107297:	e9 dc f8 ff ff       	jmp    80106b78 <alltraps>

8010729c <vector18>:
.globl vector18
vector18:
  pushl $0
8010729c:	6a 00                	push   $0x0
  pushl $18
8010729e:	6a 12                	push   $0x12
  jmp alltraps
801072a0:	e9 d3 f8 ff ff       	jmp    80106b78 <alltraps>

801072a5 <vector19>:
.globl vector19
vector19:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $19
801072a7:	6a 13                	push   $0x13
  jmp alltraps
801072a9:	e9 ca f8 ff ff       	jmp    80106b78 <alltraps>

801072ae <vector20>:
.globl vector20
vector20:
  pushl $0
801072ae:	6a 00                	push   $0x0
  pushl $20
801072b0:	6a 14                	push   $0x14
  jmp alltraps
801072b2:	e9 c1 f8 ff ff       	jmp    80106b78 <alltraps>

801072b7 <vector21>:
.globl vector21
vector21:
  pushl $0
801072b7:	6a 00                	push   $0x0
  pushl $21
801072b9:	6a 15                	push   $0x15
  jmp alltraps
801072bb:	e9 b8 f8 ff ff       	jmp    80106b78 <alltraps>

801072c0 <vector22>:
.globl vector22
vector22:
  pushl $0
801072c0:	6a 00                	push   $0x0
  pushl $22
801072c2:	6a 16                	push   $0x16
  jmp alltraps
801072c4:	e9 af f8 ff ff       	jmp    80106b78 <alltraps>

801072c9 <vector23>:
.globl vector23
vector23:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $23
801072cb:	6a 17                	push   $0x17
  jmp alltraps
801072cd:	e9 a6 f8 ff ff       	jmp    80106b78 <alltraps>

801072d2 <vector24>:
.globl vector24
vector24:
  pushl $0
801072d2:	6a 00                	push   $0x0
  pushl $24
801072d4:	6a 18                	push   $0x18
  jmp alltraps
801072d6:	e9 9d f8 ff ff       	jmp    80106b78 <alltraps>

801072db <vector25>:
.globl vector25
vector25:
  pushl $0
801072db:	6a 00                	push   $0x0
  pushl $25
801072dd:	6a 19                	push   $0x19
  jmp alltraps
801072df:	e9 94 f8 ff ff       	jmp    80106b78 <alltraps>

801072e4 <vector26>:
.globl vector26
vector26:
  pushl $0
801072e4:	6a 00                	push   $0x0
  pushl $26
801072e6:	6a 1a                	push   $0x1a
  jmp alltraps
801072e8:	e9 8b f8 ff ff       	jmp    80106b78 <alltraps>

801072ed <vector27>:
.globl vector27
vector27:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $27
801072ef:	6a 1b                	push   $0x1b
  jmp alltraps
801072f1:	e9 82 f8 ff ff       	jmp    80106b78 <alltraps>

801072f6 <vector28>:
.globl vector28
vector28:
  pushl $0
801072f6:	6a 00                	push   $0x0
  pushl $28
801072f8:	6a 1c                	push   $0x1c
  jmp alltraps
801072fa:	e9 79 f8 ff ff       	jmp    80106b78 <alltraps>

801072ff <vector29>:
.globl vector29
vector29:
  pushl $0
801072ff:	6a 00                	push   $0x0
  pushl $29
80107301:	6a 1d                	push   $0x1d
  jmp alltraps
80107303:	e9 70 f8 ff ff       	jmp    80106b78 <alltraps>

80107308 <vector30>:
.globl vector30
vector30:
  pushl $0
80107308:	6a 00                	push   $0x0
  pushl $30
8010730a:	6a 1e                	push   $0x1e
  jmp alltraps
8010730c:	e9 67 f8 ff ff       	jmp    80106b78 <alltraps>

80107311 <vector31>:
.globl vector31
vector31:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $31
80107313:	6a 1f                	push   $0x1f
  jmp alltraps
80107315:	e9 5e f8 ff ff       	jmp    80106b78 <alltraps>

8010731a <vector32>:
.globl vector32
vector32:
  pushl $0
8010731a:	6a 00                	push   $0x0
  pushl $32
8010731c:	6a 20                	push   $0x20
  jmp alltraps
8010731e:	e9 55 f8 ff ff       	jmp    80106b78 <alltraps>

80107323 <vector33>:
.globl vector33
vector33:
  pushl $0
80107323:	6a 00                	push   $0x0
  pushl $33
80107325:	6a 21                	push   $0x21
  jmp alltraps
80107327:	e9 4c f8 ff ff       	jmp    80106b78 <alltraps>

8010732c <vector34>:
.globl vector34
vector34:
  pushl $0
8010732c:	6a 00                	push   $0x0
  pushl $34
8010732e:	6a 22                	push   $0x22
  jmp alltraps
80107330:	e9 43 f8 ff ff       	jmp    80106b78 <alltraps>

80107335 <vector35>:
.globl vector35
vector35:
  pushl $0
80107335:	6a 00                	push   $0x0
  pushl $35
80107337:	6a 23                	push   $0x23
  jmp alltraps
80107339:	e9 3a f8 ff ff       	jmp    80106b78 <alltraps>

8010733e <vector36>:
.globl vector36
vector36:
  pushl $0
8010733e:	6a 00                	push   $0x0
  pushl $36
80107340:	6a 24                	push   $0x24
  jmp alltraps
80107342:	e9 31 f8 ff ff       	jmp    80106b78 <alltraps>

80107347 <vector37>:
.globl vector37
vector37:
  pushl $0
80107347:	6a 00                	push   $0x0
  pushl $37
80107349:	6a 25                	push   $0x25
  jmp alltraps
8010734b:	e9 28 f8 ff ff       	jmp    80106b78 <alltraps>

80107350 <vector38>:
.globl vector38
vector38:
  pushl $0
80107350:	6a 00                	push   $0x0
  pushl $38
80107352:	6a 26                	push   $0x26
  jmp alltraps
80107354:	e9 1f f8 ff ff       	jmp    80106b78 <alltraps>

80107359 <vector39>:
.globl vector39
vector39:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $39
8010735b:	6a 27                	push   $0x27
  jmp alltraps
8010735d:	e9 16 f8 ff ff       	jmp    80106b78 <alltraps>

80107362 <vector40>:
.globl vector40
vector40:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $40
80107364:	6a 28                	push   $0x28
  jmp alltraps
80107366:	e9 0d f8 ff ff       	jmp    80106b78 <alltraps>

8010736b <vector41>:
.globl vector41
vector41:
  pushl $0
8010736b:	6a 00                	push   $0x0
  pushl $41
8010736d:	6a 29                	push   $0x29
  jmp alltraps
8010736f:	e9 04 f8 ff ff       	jmp    80106b78 <alltraps>

80107374 <vector42>:
.globl vector42
vector42:
  pushl $0
80107374:	6a 00                	push   $0x0
  pushl $42
80107376:	6a 2a                	push   $0x2a
  jmp alltraps
80107378:	e9 fb f7 ff ff       	jmp    80106b78 <alltraps>

8010737d <vector43>:
.globl vector43
vector43:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $43
8010737f:	6a 2b                	push   $0x2b
  jmp alltraps
80107381:	e9 f2 f7 ff ff       	jmp    80106b78 <alltraps>

80107386 <vector44>:
.globl vector44
vector44:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $44
80107388:	6a 2c                	push   $0x2c
  jmp alltraps
8010738a:	e9 e9 f7 ff ff       	jmp    80106b78 <alltraps>

8010738f <vector45>:
.globl vector45
vector45:
  pushl $0
8010738f:	6a 00                	push   $0x0
  pushl $45
80107391:	6a 2d                	push   $0x2d
  jmp alltraps
80107393:	e9 e0 f7 ff ff       	jmp    80106b78 <alltraps>

80107398 <vector46>:
.globl vector46
vector46:
  pushl $0
80107398:	6a 00                	push   $0x0
  pushl $46
8010739a:	6a 2e                	push   $0x2e
  jmp alltraps
8010739c:	e9 d7 f7 ff ff       	jmp    80106b78 <alltraps>

801073a1 <vector47>:
.globl vector47
vector47:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $47
801073a3:	6a 2f                	push   $0x2f
  jmp alltraps
801073a5:	e9 ce f7 ff ff       	jmp    80106b78 <alltraps>

801073aa <vector48>:
.globl vector48
vector48:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $48
801073ac:	6a 30                	push   $0x30
  jmp alltraps
801073ae:	e9 c5 f7 ff ff       	jmp    80106b78 <alltraps>

801073b3 <vector49>:
.globl vector49
vector49:
  pushl $0
801073b3:	6a 00                	push   $0x0
  pushl $49
801073b5:	6a 31                	push   $0x31
  jmp alltraps
801073b7:	e9 bc f7 ff ff       	jmp    80106b78 <alltraps>

801073bc <vector50>:
.globl vector50
vector50:
  pushl $0
801073bc:	6a 00                	push   $0x0
  pushl $50
801073be:	6a 32                	push   $0x32
  jmp alltraps
801073c0:	e9 b3 f7 ff ff       	jmp    80106b78 <alltraps>

801073c5 <vector51>:
.globl vector51
vector51:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $51
801073c7:	6a 33                	push   $0x33
  jmp alltraps
801073c9:	e9 aa f7 ff ff       	jmp    80106b78 <alltraps>

801073ce <vector52>:
.globl vector52
vector52:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $52
801073d0:	6a 34                	push   $0x34
  jmp alltraps
801073d2:	e9 a1 f7 ff ff       	jmp    80106b78 <alltraps>

801073d7 <vector53>:
.globl vector53
vector53:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $53
801073d9:	6a 35                	push   $0x35
  jmp alltraps
801073db:	e9 98 f7 ff ff       	jmp    80106b78 <alltraps>

801073e0 <vector54>:
.globl vector54
vector54:
  pushl $0
801073e0:	6a 00                	push   $0x0
  pushl $54
801073e2:	6a 36                	push   $0x36
  jmp alltraps
801073e4:	e9 8f f7 ff ff       	jmp    80106b78 <alltraps>

801073e9 <vector55>:
.globl vector55
vector55:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $55
801073eb:	6a 37                	push   $0x37
  jmp alltraps
801073ed:	e9 86 f7 ff ff       	jmp    80106b78 <alltraps>

801073f2 <vector56>:
.globl vector56
vector56:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $56
801073f4:	6a 38                	push   $0x38
  jmp alltraps
801073f6:	e9 7d f7 ff ff       	jmp    80106b78 <alltraps>

801073fb <vector57>:
.globl vector57
vector57:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $57
801073fd:	6a 39                	push   $0x39
  jmp alltraps
801073ff:	e9 74 f7 ff ff       	jmp    80106b78 <alltraps>

80107404 <vector58>:
.globl vector58
vector58:
  pushl $0
80107404:	6a 00                	push   $0x0
  pushl $58
80107406:	6a 3a                	push   $0x3a
  jmp alltraps
80107408:	e9 6b f7 ff ff       	jmp    80106b78 <alltraps>

8010740d <vector59>:
.globl vector59
vector59:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $59
8010740f:	6a 3b                	push   $0x3b
  jmp alltraps
80107411:	e9 62 f7 ff ff       	jmp    80106b78 <alltraps>

80107416 <vector60>:
.globl vector60
vector60:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $60
80107418:	6a 3c                	push   $0x3c
  jmp alltraps
8010741a:	e9 59 f7 ff ff       	jmp    80106b78 <alltraps>

8010741f <vector61>:
.globl vector61
vector61:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $61
80107421:	6a 3d                	push   $0x3d
  jmp alltraps
80107423:	e9 50 f7 ff ff       	jmp    80106b78 <alltraps>

80107428 <vector62>:
.globl vector62
vector62:
  pushl $0
80107428:	6a 00                	push   $0x0
  pushl $62
8010742a:	6a 3e                	push   $0x3e
  jmp alltraps
8010742c:	e9 47 f7 ff ff       	jmp    80106b78 <alltraps>

80107431 <vector63>:
.globl vector63
vector63:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $63
80107433:	6a 3f                	push   $0x3f
  jmp alltraps
80107435:	e9 3e f7 ff ff       	jmp    80106b78 <alltraps>

8010743a <vector64>:
.globl vector64
vector64:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $64
8010743c:	6a 40                	push   $0x40
  jmp alltraps
8010743e:	e9 35 f7 ff ff       	jmp    80106b78 <alltraps>

80107443 <vector65>:
.globl vector65
vector65:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $65
80107445:	6a 41                	push   $0x41
  jmp alltraps
80107447:	e9 2c f7 ff ff       	jmp    80106b78 <alltraps>

8010744c <vector66>:
.globl vector66
vector66:
  pushl $0
8010744c:	6a 00                	push   $0x0
  pushl $66
8010744e:	6a 42                	push   $0x42
  jmp alltraps
80107450:	e9 23 f7 ff ff       	jmp    80106b78 <alltraps>

80107455 <vector67>:
.globl vector67
vector67:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $67
80107457:	6a 43                	push   $0x43
  jmp alltraps
80107459:	e9 1a f7 ff ff       	jmp    80106b78 <alltraps>

8010745e <vector68>:
.globl vector68
vector68:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $68
80107460:	6a 44                	push   $0x44
  jmp alltraps
80107462:	e9 11 f7 ff ff       	jmp    80106b78 <alltraps>

80107467 <vector69>:
.globl vector69
vector69:
  pushl $0
80107467:	6a 00                	push   $0x0
  pushl $69
80107469:	6a 45                	push   $0x45
  jmp alltraps
8010746b:	e9 08 f7 ff ff       	jmp    80106b78 <alltraps>

80107470 <vector70>:
.globl vector70
vector70:
  pushl $0
80107470:	6a 00                	push   $0x0
  pushl $70
80107472:	6a 46                	push   $0x46
  jmp alltraps
80107474:	e9 ff f6 ff ff       	jmp    80106b78 <alltraps>

80107479 <vector71>:
.globl vector71
vector71:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $71
8010747b:	6a 47                	push   $0x47
  jmp alltraps
8010747d:	e9 f6 f6 ff ff       	jmp    80106b78 <alltraps>

80107482 <vector72>:
.globl vector72
vector72:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $72
80107484:	6a 48                	push   $0x48
  jmp alltraps
80107486:	e9 ed f6 ff ff       	jmp    80106b78 <alltraps>

8010748b <vector73>:
.globl vector73
vector73:
  pushl $0
8010748b:	6a 00                	push   $0x0
  pushl $73
8010748d:	6a 49                	push   $0x49
  jmp alltraps
8010748f:	e9 e4 f6 ff ff       	jmp    80106b78 <alltraps>

80107494 <vector74>:
.globl vector74
vector74:
  pushl $0
80107494:	6a 00                	push   $0x0
  pushl $74
80107496:	6a 4a                	push   $0x4a
  jmp alltraps
80107498:	e9 db f6 ff ff       	jmp    80106b78 <alltraps>

8010749d <vector75>:
.globl vector75
vector75:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $75
8010749f:	6a 4b                	push   $0x4b
  jmp alltraps
801074a1:	e9 d2 f6 ff ff       	jmp    80106b78 <alltraps>

801074a6 <vector76>:
.globl vector76
vector76:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $76
801074a8:	6a 4c                	push   $0x4c
  jmp alltraps
801074aa:	e9 c9 f6 ff ff       	jmp    80106b78 <alltraps>

801074af <vector77>:
.globl vector77
vector77:
  pushl $0
801074af:	6a 00                	push   $0x0
  pushl $77
801074b1:	6a 4d                	push   $0x4d
  jmp alltraps
801074b3:	e9 c0 f6 ff ff       	jmp    80106b78 <alltraps>

801074b8 <vector78>:
.globl vector78
vector78:
  pushl $0
801074b8:	6a 00                	push   $0x0
  pushl $78
801074ba:	6a 4e                	push   $0x4e
  jmp alltraps
801074bc:	e9 b7 f6 ff ff       	jmp    80106b78 <alltraps>

801074c1 <vector79>:
.globl vector79
vector79:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $79
801074c3:	6a 4f                	push   $0x4f
  jmp alltraps
801074c5:	e9 ae f6 ff ff       	jmp    80106b78 <alltraps>

801074ca <vector80>:
.globl vector80
vector80:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $80
801074cc:	6a 50                	push   $0x50
  jmp alltraps
801074ce:	e9 a5 f6 ff ff       	jmp    80106b78 <alltraps>

801074d3 <vector81>:
.globl vector81
vector81:
  pushl $0
801074d3:	6a 00                	push   $0x0
  pushl $81
801074d5:	6a 51                	push   $0x51
  jmp alltraps
801074d7:	e9 9c f6 ff ff       	jmp    80106b78 <alltraps>

801074dc <vector82>:
.globl vector82
vector82:
  pushl $0
801074dc:	6a 00                	push   $0x0
  pushl $82
801074de:	6a 52                	push   $0x52
  jmp alltraps
801074e0:	e9 93 f6 ff ff       	jmp    80106b78 <alltraps>

801074e5 <vector83>:
.globl vector83
vector83:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $83
801074e7:	6a 53                	push   $0x53
  jmp alltraps
801074e9:	e9 8a f6 ff ff       	jmp    80106b78 <alltraps>

801074ee <vector84>:
.globl vector84
vector84:
  pushl $0
801074ee:	6a 00                	push   $0x0
  pushl $84
801074f0:	6a 54                	push   $0x54
  jmp alltraps
801074f2:	e9 81 f6 ff ff       	jmp    80106b78 <alltraps>

801074f7 <vector85>:
.globl vector85
vector85:
  pushl $0
801074f7:	6a 00                	push   $0x0
  pushl $85
801074f9:	6a 55                	push   $0x55
  jmp alltraps
801074fb:	e9 78 f6 ff ff       	jmp    80106b78 <alltraps>

80107500 <vector86>:
.globl vector86
vector86:
  pushl $0
80107500:	6a 00                	push   $0x0
  pushl $86
80107502:	6a 56                	push   $0x56
  jmp alltraps
80107504:	e9 6f f6 ff ff       	jmp    80106b78 <alltraps>

80107509 <vector87>:
.globl vector87
vector87:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $87
8010750b:	6a 57                	push   $0x57
  jmp alltraps
8010750d:	e9 66 f6 ff ff       	jmp    80106b78 <alltraps>

80107512 <vector88>:
.globl vector88
vector88:
  pushl $0
80107512:	6a 00                	push   $0x0
  pushl $88
80107514:	6a 58                	push   $0x58
  jmp alltraps
80107516:	e9 5d f6 ff ff       	jmp    80106b78 <alltraps>

8010751b <vector89>:
.globl vector89
vector89:
  pushl $0
8010751b:	6a 00                	push   $0x0
  pushl $89
8010751d:	6a 59                	push   $0x59
  jmp alltraps
8010751f:	e9 54 f6 ff ff       	jmp    80106b78 <alltraps>

80107524 <vector90>:
.globl vector90
vector90:
  pushl $0
80107524:	6a 00                	push   $0x0
  pushl $90
80107526:	6a 5a                	push   $0x5a
  jmp alltraps
80107528:	e9 4b f6 ff ff       	jmp    80106b78 <alltraps>

8010752d <vector91>:
.globl vector91
vector91:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $91
8010752f:	6a 5b                	push   $0x5b
  jmp alltraps
80107531:	e9 42 f6 ff ff       	jmp    80106b78 <alltraps>

80107536 <vector92>:
.globl vector92
vector92:
  pushl $0
80107536:	6a 00                	push   $0x0
  pushl $92
80107538:	6a 5c                	push   $0x5c
  jmp alltraps
8010753a:	e9 39 f6 ff ff       	jmp    80106b78 <alltraps>

8010753f <vector93>:
.globl vector93
vector93:
  pushl $0
8010753f:	6a 00                	push   $0x0
  pushl $93
80107541:	6a 5d                	push   $0x5d
  jmp alltraps
80107543:	e9 30 f6 ff ff       	jmp    80106b78 <alltraps>

80107548 <vector94>:
.globl vector94
vector94:
  pushl $0
80107548:	6a 00                	push   $0x0
  pushl $94
8010754a:	6a 5e                	push   $0x5e
  jmp alltraps
8010754c:	e9 27 f6 ff ff       	jmp    80106b78 <alltraps>

80107551 <vector95>:
.globl vector95
vector95:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $95
80107553:	6a 5f                	push   $0x5f
  jmp alltraps
80107555:	e9 1e f6 ff ff       	jmp    80106b78 <alltraps>

8010755a <vector96>:
.globl vector96
vector96:
  pushl $0
8010755a:	6a 00                	push   $0x0
  pushl $96
8010755c:	6a 60                	push   $0x60
  jmp alltraps
8010755e:	e9 15 f6 ff ff       	jmp    80106b78 <alltraps>

80107563 <vector97>:
.globl vector97
vector97:
  pushl $0
80107563:	6a 00                	push   $0x0
  pushl $97
80107565:	6a 61                	push   $0x61
  jmp alltraps
80107567:	e9 0c f6 ff ff       	jmp    80106b78 <alltraps>

8010756c <vector98>:
.globl vector98
vector98:
  pushl $0
8010756c:	6a 00                	push   $0x0
  pushl $98
8010756e:	6a 62                	push   $0x62
  jmp alltraps
80107570:	e9 03 f6 ff ff       	jmp    80106b78 <alltraps>

80107575 <vector99>:
.globl vector99
vector99:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $99
80107577:	6a 63                	push   $0x63
  jmp alltraps
80107579:	e9 fa f5 ff ff       	jmp    80106b78 <alltraps>

8010757e <vector100>:
.globl vector100
vector100:
  pushl $0
8010757e:	6a 00                	push   $0x0
  pushl $100
80107580:	6a 64                	push   $0x64
  jmp alltraps
80107582:	e9 f1 f5 ff ff       	jmp    80106b78 <alltraps>

80107587 <vector101>:
.globl vector101
vector101:
  pushl $0
80107587:	6a 00                	push   $0x0
  pushl $101
80107589:	6a 65                	push   $0x65
  jmp alltraps
8010758b:	e9 e8 f5 ff ff       	jmp    80106b78 <alltraps>

80107590 <vector102>:
.globl vector102
vector102:
  pushl $0
80107590:	6a 00                	push   $0x0
  pushl $102
80107592:	6a 66                	push   $0x66
  jmp alltraps
80107594:	e9 df f5 ff ff       	jmp    80106b78 <alltraps>

80107599 <vector103>:
.globl vector103
vector103:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $103
8010759b:	6a 67                	push   $0x67
  jmp alltraps
8010759d:	e9 d6 f5 ff ff       	jmp    80106b78 <alltraps>

801075a2 <vector104>:
.globl vector104
vector104:
  pushl $0
801075a2:	6a 00                	push   $0x0
  pushl $104
801075a4:	6a 68                	push   $0x68
  jmp alltraps
801075a6:	e9 cd f5 ff ff       	jmp    80106b78 <alltraps>

801075ab <vector105>:
.globl vector105
vector105:
  pushl $0
801075ab:	6a 00                	push   $0x0
  pushl $105
801075ad:	6a 69                	push   $0x69
  jmp alltraps
801075af:	e9 c4 f5 ff ff       	jmp    80106b78 <alltraps>

801075b4 <vector106>:
.globl vector106
vector106:
  pushl $0
801075b4:	6a 00                	push   $0x0
  pushl $106
801075b6:	6a 6a                	push   $0x6a
  jmp alltraps
801075b8:	e9 bb f5 ff ff       	jmp    80106b78 <alltraps>

801075bd <vector107>:
.globl vector107
vector107:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $107
801075bf:	6a 6b                	push   $0x6b
  jmp alltraps
801075c1:	e9 b2 f5 ff ff       	jmp    80106b78 <alltraps>

801075c6 <vector108>:
.globl vector108
vector108:
  pushl $0
801075c6:	6a 00                	push   $0x0
  pushl $108
801075c8:	6a 6c                	push   $0x6c
  jmp alltraps
801075ca:	e9 a9 f5 ff ff       	jmp    80106b78 <alltraps>

801075cf <vector109>:
.globl vector109
vector109:
  pushl $0
801075cf:	6a 00                	push   $0x0
  pushl $109
801075d1:	6a 6d                	push   $0x6d
  jmp alltraps
801075d3:	e9 a0 f5 ff ff       	jmp    80106b78 <alltraps>

801075d8 <vector110>:
.globl vector110
vector110:
  pushl $0
801075d8:	6a 00                	push   $0x0
  pushl $110
801075da:	6a 6e                	push   $0x6e
  jmp alltraps
801075dc:	e9 97 f5 ff ff       	jmp    80106b78 <alltraps>

801075e1 <vector111>:
.globl vector111
vector111:
  pushl $0
801075e1:	6a 00                	push   $0x0
  pushl $111
801075e3:	6a 6f                	push   $0x6f
  jmp alltraps
801075e5:	e9 8e f5 ff ff       	jmp    80106b78 <alltraps>

801075ea <vector112>:
.globl vector112
vector112:
  pushl $0
801075ea:	6a 00                	push   $0x0
  pushl $112
801075ec:	6a 70                	push   $0x70
  jmp alltraps
801075ee:	e9 85 f5 ff ff       	jmp    80106b78 <alltraps>

801075f3 <vector113>:
.globl vector113
vector113:
  pushl $0
801075f3:	6a 00                	push   $0x0
  pushl $113
801075f5:	6a 71                	push   $0x71
  jmp alltraps
801075f7:	e9 7c f5 ff ff       	jmp    80106b78 <alltraps>

801075fc <vector114>:
.globl vector114
vector114:
  pushl $0
801075fc:	6a 00                	push   $0x0
  pushl $114
801075fe:	6a 72                	push   $0x72
  jmp alltraps
80107600:	e9 73 f5 ff ff       	jmp    80106b78 <alltraps>

80107605 <vector115>:
.globl vector115
vector115:
  pushl $0
80107605:	6a 00                	push   $0x0
  pushl $115
80107607:	6a 73                	push   $0x73
  jmp alltraps
80107609:	e9 6a f5 ff ff       	jmp    80106b78 <alltraps>

8010760e <vector116>:
.globl vector116
vector116:
  pushl $0
8010760e:	6a 00                	push   $0x0
  pushl $116
80107610:	6a 74                	push   $0x74
  jmp alltraps
80107612:	e9 61 f5 ff ff       	jmp    80106b78 <alltraps>

80107617 <vector117>:
.globl vector117
vector117:
  pushl $0
80107617:	6a 00                	push   $0x0
  pushl $117
80107619:	6a 75                	push   $0x75
  jmp alltraps
8010761b:	e9 58 f5 ff ff       	jmp    80106b78 <alltraps>

80107620 <vector118>:
.globl vector118
vector118:
  pushl $0
80107620:	6a 00                	push   $0x0
  pushl $118
80107622:	6a 76                	push   $0x76
  jmp alltraps
80107624:	e9 4f f5 ff ff       	jmp    80106b78 <alltraps>

80107629 <vector119>:
.globl vector119
vector119:
  pushl $0
80107629:	6a 00                	push   $0x0
  pushl $119
8010762b:	6a 77                	push   $0x77
  jmp alltraps
8010762d:	e9 46 f5 ff ff       	jmp    80106b78 <alltraps>

80107632 <vector120>:
.globl vector120
vector120:
  pushl $0
80107632:	6a 00                	push   $0x0
  pushl $120
80107634:	6a 78                	push   $0x78
  jmp alltraps
80107636:	e9 3d f5 ff ff       	jmp    80106b78 <alltraps>

8010763b <vector121>:
.globl vector121
vector121:
  pushl $0
8010763b:	6a 00                	push   $0x0
  pushl $121
8010763d:	6a 79                	push   $0x79
  jmp alltraps
8010763f:	e9 34 f5 ff ff       	jmp    80106b78 <alltraps>

80107644 <vector122>:
.globl vector122
vector122:
  pushl $0
80107644:	6a 00                	push   $0x0
  pushl $122
80107646:	6a 7a                	push   $0x7a
  jmp alltraps
80107648:	e9 2b f5 ff ff       	jmp    80106b78 <alltraps>

8010764d <vector123>:
.globl vector123
vector123:
  pushl $0
8010764d:	6a 00                	push   $0x0
  pushl $123
8010764f:	6a 7b                	push   $0x7b
  jmp alltraps
80107651:	e9 22 f5 ff ff       	jmp    80106b78 <alltraps>

80107656 <vector124>:
.globl vector124
vector124:
  pushl $0
80107656:	6a 00                	push   $0x0
  pushl $124
80107658:	6a 7c                	push   $0x7c
  jmp alltraps
8010765a:	e9 19 f5 ff ff       	jmp    80106b78 <alltraps>

8010765f <vector125>:
.globl vector125
vector125:
  pushl $0
8010765f:	6a 00                	push   $0x0
  pushl $125
80107661:	6a 7d                	push   $0x7d
  jmp alltraps
80107663:	e9 10 f5 ff ff       	jmp    80106b78 <alltraps>

80107668 <vector126>:
.globl vector126
vector126:
  pushl $0
80107668:	6a 00                	push   $0x0
  pushl $126
8010766a:	6a 7e                	push   $0x7e
  jmp alltraps
8010766c:	e9 07 f5 ff ff       	jmp    80106b78 <alltraps>

80107671 <vector127>:
.globl vector127
vector127:
  pushl $0
80107671:	6a 00                	push   $0x0
  pushl $127
80107673:	6a 7f                	push   $0x7f
  jmp alltraps
80107675:	e9 fe f4 ff ff       	jmp    80106b78 <alltraps>

8010767a <vector128>:
.globl vector128
vector128:
  pushl $0
8010767a:	6a 00                	push   $0x0
  pushl $128
8010767c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107681:	e9 f2 f4 ff ff       	jmp    80106b78 <alltraps>

80107686 <vector129>:
.globl vector129
vector129:
  pushl $0
80107686:	6a 00                	push   $0x0
  pushl $129
80107688:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010768d:	e9 e6 f4 ff ff       	jmp    80106b78 <alltraps>

80107692 <vector130>:
.globl vector130
vector130:
  pushl $0
80107692:	6a 00                	push   $0x0
  pushl $130
80107694:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107699:	e9 da f4 ff ff       	jmp    80106b78 <alltraps>

8010769e <vector131>:
.globl vector131
vector131:
  pushl $0
8010769e:	6a 00                	push   $0x0
  pushl $131
801076a0:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801076a5:	e9 ce f4 ff ff       	jmp    80106b78 <alltraps>

801076aa <vector132>:
.globl vector132
vector132:
  pushl $0
801076aa:	6a 00                	push   $0x0
  pushl $132
801076ac:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801076b1:	e9 c2 f4 ff ff       	jmp    80106b78 <alltraps>

801076b6 <vector133>:
.globl vector133
vector133:
  pushl $0
801076b6:	6a 00                	push   $0x0
  pushl $133
801076b8:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801076bd:	e9 b6 f4 ff ff       	jmp    80106b78 <alltraps>

801076c2 <vector134>:
.globl vector134
vector134:
  pushl $0
801076c2:	6a 00                	push   $0x0
  pushl $134
801076c4:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801076c9:	e9 aa f4 ff ff       	jmp    80106b78 <alltraps>

801076ce <vector135>:
.globl vector135
vector135:
  pushl $0
801076ce:	6a 00                	push   $0x0
  pushl $135
801076d0:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801076d5:	e9 9e f4 ff ff       	jmp    80106b78 <alltraps>

801076da <vector136>:
.globl vector136
vector136:
  pushl $0
801076da:	6a 00                	push   $0x0
  pushl $136
801076dc:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801076e1:	e9 92 f4 ff ff       	jmp    80106b78 <alltraps>

801076e6 <vector137>:
.globl vector137
vector137:
  pushl $0
801076e6:	6a 00                	push   $0x0
  pushl $137
801076e8:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801076ed:	e9 86 f4 ff ff       	jmp    80106b78 <alltraps>

801076f2 <vector138>:
.globl vector138
vector138:
  pushl $0
801076f2:	6a 00                	push   $0x0
  pushl $138
801076f4:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801076f9:	e9 7a f4 ff ff       	jmp    80106b78 <alltraps>

801076fe <vector139>:
.globl vector139
vector139:
  pushl $0
801076fe:	6a 00                	push   $0x0
  pushl $139
80107700:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107705:	e9 6e f4 ff ff       	jmp    80106b78 <alltraps>

8010770a <vector140>:
.globl vector140
vector140:
  pushl $0
8010770a:	6a 00                	push   $0x0
  pushl $140
8010770c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107711:	e9 62 f4 ff ff       	jmp    80106b78 <alltraps>

80107716 <vector141>:
.globl vector141
vector141:
  pushl $0
80107716:	6a 00                	push   $0x0
  pushl $141
80107718:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010771d:	e9 56 f4 ff ff       	jmp    80106b78 <alltraps>

80107722 <vector142>:
.globl vector142
vector142:
  pushl $0
80107722:	6a 00                	push   $0x0
  pushl $142
80107724:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107729:	e9 4a f4 ff ff       	jmp    80106b78 <alltraps>

8010772e <vector143>:
.globl vector143
vector143:
  pushl $0
8010772e:	6a 00                	push   $0x0
  pushl $143
80107730:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107735:	e9 3e f4 ff ff       	jmp    80106b78 <alltraps>

8010773a <vector144>:
.globl vector144
vector144:
  pushl $0
8010773a:	6a 00                	push   $0x0
  pushl $144
8010773c:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107741:	e9 32 f4 ff ff       	jmp    80106b78 <alltraps>

80107746 <vector145>:
.globl vector145
vector145:
  pushl $0
80107746:	6a 00                	push   $0x0
  pushl $145
80107748:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010774d:	e9 26 f4 ff ff       	jmp    80106b78 <alltraps>

80107752 <vector146>:
.globl vector146
vector146:
  pushl $0
80107752:	6a 00                	push   $0x0
  pushl $146
80107754:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107759:	e9 1a f4 ff ff       	jmp    80106b78 <alltraps>

8010775e <vector147>:
.globl vector147
vector147:
  pushl $0
8010775e:	6a 00                	push   $0x0
  pushl $147
80107760:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107765:	e9 0e f4 ff ff       	jmp    80106b78 <alltraps>

8010776a <vector148>:
.globl vector148
vector148:
  pushl $0
8010776a:	6a 00                	push   $0x0
  pushl $148
8010776c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107771:	e9 02 f4 ff ff       	jmp    80106b78 <alltraps>

80107776 <vector149>:
.globl vector149
vector149:
  pushl $0
80107776:	6a 00                	push   $0x0
  pushl $149
80107778:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010777d:	e9 f6 f3 ff ff       	jmp    80106b78 <alltraps>

80107782 <vector150>:
.globl vector150
vector150:
  pushl $0
80107782:	6a 00                	push   $0x0
  pushl $150
80107784:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107789:	e9 ea f3 ff ff       	jmp    80106b78 <alltraps>

8010778e <vector151>:
.globl vector151
vector151:
  pushl $0
8010778e:	6a 00                	push   $0x0
  pushl $151
80107790:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107795:	e9 de f3 ff ff       	jmp    80106b78 <alltraps>

8010779a <vector152>:
.globl vector152
vector152:
  pushl $0
8010779a:	6a 00                	push   $0x0
  pushl $152
8010779c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801077a1:	e9 d2 f3 ff ff       	jmp    80106b78 <alltraps>

801077a6 <vector153>:
.globl vector153
vector153:
  pushl $0
801077a6:	6a 00                	push   $0x0
  pushl $153
801077a8:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801077ad:	e9 c6 f3 ff ff       	jmp    80106b78 <alltraps>

801077b2 <vector154>:
.globl vector154
vector154:
  pushl $0
801077b2:	6a 00                	push   $0x0
  pushl $154
801077b4:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801077b9:	e9 ba f3 ff ff       	jmp    80106b78 <alltraps>

801077be <vector155>:
.globl vector155
vector155:
  pushl $0
801077be:	6a 00                	push   $0x0
  pushl $155
801077c0:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801077c5:	e9 ae f3 ff ff       	jmp    80106b78 <alltraps>

801077ca <vector156>:
.globl vector156
vector156:
  pushl $0
801077ca:	6a 00                	push   $0x0
  pushl $156
801077cc:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801077d1:	e9 a2 f3 ff ff       	jmp    80106b78 <alltraps>

801077d6 <vector157>:
.globl vector157
vector157:
  pushl $0
801077d6:	6a 00                	push   $0x0
  pushl $157
801077d8:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801077dd:	e9 96 f3 ff ff       	jmp    80106b78 <alltraps>

801077e2 <vector158>:
.globl vector158
vector158:
  pushl $0
801077e2:	6a 00                	push   $0x0
  pushl $158
801077e4:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801077e9:	e9 8a f3 ff ff       	jmp    80106b78 <alltraps>

801077ee <vector159>:
.globl vector159
vector159:
  pushl $0
801077ee:	6a 00                	push   $0x0
  pushl $159
801077f0:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801077f5:	e9 7e f3 ff ff       	jmp    80106b78 <alltraps>

801077fa <vector160>:
.globl vector160
vector160:
  pushl $0
801077fa:	6a 00                	push   $0x0
  pushl $160
801077fc:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107801:	e9 72 f3 ff ff       	jmp    80106b78 <alltraps>

80107806 <vector161>:
.globl vector161
vector161:
  pushl $0
80107806:	6a 00                	push   $0x0
  pushl $161
80107808:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010780d:	e9 66 f3 ff ff       	jmp    80106b78 <alltraps>

80107812 <vector162>:
.globl vector162
vector162:
  pushl $0
80107812:	6a 00                	push   $0x0
  pushl $162
80107814:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107819:	e9 5a f3 ff ff       	jmp    80106b78 <alltraps>

8010781e <vector163>:
.globl vector163
vector163:
  pushl $0
8010781e:	6a 00                	push   $0x0
  pushl $163
80107820:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107825:	e9 4e f3 ff ff       	jmp    80106b78 <alltraps>

8010782a <vector164>:
.globl vector164
vector164:
  pushl $0
8010782a:	6a 00                	push   $0x0
  pushl $164
8010782c:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107831:	e9 42 f3 ff ff       	jmp    80106b78 <alltraps>

80107836 <vector165>:
.globl vector165
vector165:
  pushl $0
80107836:	6a 00                	push   $0x0
  pushl $165
80107838:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010783d:	e9 36 f3 ff ff       	jmp    80106b78 <alltraps>

80107842 <vector166>:
.globl vector166
vector166:
  pushl $0
80107842:	6a 00                	push   $0x0
  pushl $166
80107844:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107849:	e9 2a f3 ff ff       	jmp    80106b78 <alltraps>

8010784e <vector167>:
.globl vector167
vector167:
  pushl $0
8010784e:	6a 00                	push   $0x0
  pushl $167
80107850:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107855:	e9 1e f3 ff ff       	jmp    80106b78 <alltraps>

8010785a <vector168>:
.globl vector168
vector168:
  pushl $0
8010785a:	6a 00                	push   $0x0
  pushl $168
8010785c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107861:	e9 12 f3 ff ff       	jmp    80106b78 <alltraps>

80107866 <vector169>:
.globl vector169
vector169:
  pushl $0
80107866:	6a 00                	push   $0x0
  pushl $169
80107868:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010786d:	e9 06 f3 ff ff       	jmp    80106b78 <alltraps>

80107872 <vector170>:
.globl vector170
vector170:
  pushl $0
80107872:	6a 00                	push   $0x0
  pushl $170
80107874:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107879:	e9 fa f2 ff ff       	jmp    80106b78 <alltraps>

8010787e <vector171>:
.globl vector171
vector171:
  pushl $0
8010787e:	6a 00                	push   $0x0
  pushl $171
80107880:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107885:	e9 ee f2 ff ff       	jmp    80106b78 <alltraps>

8010788a <vector172>:
.globl vector172
vector172:
  pushl $0
8010788a:	6a 00                	push   $0x0
  pushl $172
8010788c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107891:	e9 e2 f2 ff ff       	jmp    80106b78 <alltraps>

80107896 <vector173>:
.globl vector173
vector173:
  pushl $0
80107896:	6a 00                	push   $0x0
  pushl $173
80107898:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010789d:	e9 d6 f2 ff ff       	jmp    80106b78 <alltraps>

801078a2 <vector174>:
.globl vector174
vector174:
  pushl $0
801078a2:	6a 00                	push   $0x0
  pushl $174
801078a4:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801078a9:	e9 ca f2 ff ff       	jmp    80106b78 <alltraps>

801078ae <vector175>:
.globl vector175
vector175:
  pushl $0
801078ae:	6a 00                	push   $0x0
  pushl $175
801078b0:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801078b5:	e9 be f2 ff ff       	jmp    80106b78 <alltraps>

801078ba <vector176>:
.globl vector176
vector176:
  pushl $0
801078ba:	6a 00                	push   $0x0
  pushl $176
801078bc:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801078c1:	e9 b2 f2 ff ff       	jmp    80106b78 <alltraps>

801078c6 <vector177>:
.globl vector177
vector177:
  pushl $0
801078c6:	6a 00                	push   $0x0
  pushl $177
801078c8:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801078cd:	e9 a6 f2 ff ff       	jmp    80106b78 <alltraps>

801078d2 <vector178>:
.globl vector178
vector178:
  pushl $0
801078d2:	6a 00                	push   $0x0
  pushl $178
801078d4:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801078d9:	e9 9a f2 ff ff       	jmp    80106b78 <alltraps>

801078de <vector179>:
.globl vector179
vector179:
  pushl $0
801078de:	6a 00                	push   $0x0
  pushl $179
801078e0:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801078e5:	e9 8e f2 ff ff       	jmp    80106b78 <alltraps>

801078ea <vector180>:
.globl vector180
vector180:
  pushl $0
801078ea:	6a 00                	push   $0x0
  pushl $180
801078ec:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801078f1:	e9 82 f2 ff ff       	jmp    80106b78 <alltraps>

801078f6 <vector181>:
.globl vector181
vector181:
  pushl $0
801078f6:	6a 00                	push   $0x0
  pushl $181
801078f8:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801078fd:	e9 76 f2 ff ff       	jmp    80106b78 <alltraps>

80107902 <vector182>:
.globl vector182
vector182:
  pushl $0
80107902:	6a 00                	push   $0x0
  pushl $182
80107904:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107909:	e9 6a f2 ff ff       	jmp    80106b78 <alltraps>

8010790e <vector183>:
.globl vector183
vector183:
  pushl $0
8010790e:	6a 00                	push   $0x0
  pushl $183
80107910:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107915:	e9 5e f2 ff ff       	jmp    80106b78 <alltraps>

8010791a <vector184>:
.globl vector184
vector184:
  pushl $0
8010791a:	6a 00                	push   $0x0
  pushl $184
8010791c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107921:	e9 52 f2 ff ff       	jmp    80106b78 <alltraps>

80107926 <vector185>:
.globl vector185
vector185:
  pushl $0
80107926:	6a 00                	push   $0x0
  pushl $185
80107928:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010792d:	e9 46 f2 ff ff       	jmp    80106b78 <alltraps>

80107932 <vector186>:
.globl vector186
vector186:
  pushl $0
80107932:	6a 00                	push   $0x0
  pushl $186
80107934:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107939:	e9 3a f2 ff ff       	jmp    80106b78 <alltraps>

8010793e <vector187>:
.globl vector187
vector187:
  pushl $0
8010793e:	6a 00                	push   $0x0
  pushl $187
80107940:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107945:	e9 2e f2 ff ff       	jmp    80106b78 <alltraps>

8010794a <vector188>:
.globl vector188
vector188:
  pushl $0
8010794a:	6a 00                	push   $0x0
  pushl $188
8010794c:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107951:	e9 22 f2 ff ff       	jmp    80106b78 <alltraps>

80107956 <vector189>:
.globl vector189
vector189:
  pushl $0
80107956:	6a 00                	push   $0x0
  pushl $189
80107958:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010795d:	e9 16 f2 ff ff       	jmp    80106b78 <alltraps>

80107962 <vector190>:
.globl vector190
vector190:
  pushl $0
80107962:	6a 00                	push   $0x0
  pushl $190
80107964:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107969:	e9 0a f2 ff ff       	jmp    80106b78 <alltraps>

8010796e <vector191>:
.globl vector191
vector191:
  pushl $0
8010796e:	6a 00                	push   $0x0
  pushl $191
80107970:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107975:	e9 fe f1 ff ff       	jmp    80106b78 <alltraps>

8010797a <vector192>:
.globl vector192
vector192:
  pushl $0
8010797a:	6a 00                	push   $0x0
  pushl $192
8010797c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107981:	e9 f2 f1 ff ff       	jmp    80106b78 <alltraps>

80107986 <vector193>:
.globl vector193
vector193:
  pushl $0
80107986:	6a 00                	push   $0x0
  pushl $193
80107988:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010798d:	e9 e6 f1 ff ff       	jmp    80106b78 <alltraps>

80107992 <vector194>:
.globl vector194
vector194:
  pushl $0
80107992:	6a 00                	push   $0x0
  pushl $194
80107994:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107999:	e9 da f1 ff ff       	jmp    80106b78 <alltraps>

8010799e <vector195>:
.globl vector195
vector195:
  pushl $0
8010799e:	6a 00                	push   $0x0
  pushl $195
801079a0:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801079a5:	e9 ce f1 ff ff       	jmp    80106b78 <alltraps>

801079aa <vector196>:
.globl vector196
vector196:
  pushl $0
801079aa:	6a 00                	push   $0x0
  pushl $196
801079ac:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801079b1:	e9 c2 f1 ff ff       	jmp    80106b78 <alltraps>

801079b6 <vector197>:
.globl vector197
vector197:
  pushl $0
801079b6:	6a 00                	push   $0x0
  pushl $197
801079b8:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801079bd:	e9 b6 f1 ff ff       	jmp    80106b78 <alltraps>

801079c2 <vector198>:
.globl vector198
vector198:
  pushl $0
801079c2:	6a 00                	push   $0x0
  pushl $198
801079c4:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801079c9:	e9 aa f1 ff ff       	jmp    80106b78 <alltraps>

801079ce <vector199>:
.globl vector199
vector199:
  pushl $0
801079ce:	6a 00                	push   $0x0
  pushl $199
801079d0:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801079d5:	e9 9e f1 ff ff       	jmp    80106b78 <alltraps>

801079da <vector200>:
.globl vector200
vector200:
  pushl $0
801079da:	6a 00                	push   $0x0
  pushl $200
801079dc:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801079e1:	e9 92 f1 ff ff       	jmp    80106b78 <alltraps>

801079e6 <vector201>:
.globl vector201
vector201:
  pushl $0
801079e6:	6a 00                	push   $0x0
  pushl $201
801079e8:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801079ed:	e9 86 f1 ff ff       	jmp    80106b78 <alltraps>

801079f2 <vector202>:
.globl vector202
vector202:
  pushl $0
801079f2:	6a 00                	push   $0x0
  pushl $202
801079f4:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801079f9:	e9 7a f1 ff ff       	jmp    80106b78 <alltraps>

801079fe <vector203>:
.globl vector203
vector203:
  pushl $0
801079fe:	6a 00                	push   $0x0
  pushl $203
80107a00:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107a05:	e9 6e f1 ff ff       	jmp    80106b78 <alltraps>

80107a0a <vector204>:
.globl vector204
vector204:
  pushl $0
80107a0a:	6a 00                	push   $0x0
  pushl $204
80107a0c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107a11:	e9 62 f1 ff ff       	jmp    80106b78 <alltraps>

80107a16 <vector205>:
.globl vector205
vector205:
  pushl $0
80107a16:	6a 00                	push   $0x0
  pushl $205
80107a18:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107a1d:	e9 56 f1 ff ff       	jmp    80106b78 <alltraps>

80107a22 <vector206>:
.globl vector206
vector206:
  pushl $0
80107a22:	6a 00                	push   $0x0
  pushl $206
80107a24:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107a29:	e9 4a f1 ff ff       	jmp    80106b78 <alltraps>

80107a2e <vector207>:
.globl vector207
vector207:
  pushl $0
80107a2e:	6a 00                	push   $0x0
  pushl $207
80107a30:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107a35:	e9 3e f1 ff ff       	jmp    80106b78 <alltraps>

80107a3a <vector208>:
.globl vector208
vector208:
  pushl $0
80107a3a:	6a 00                	push   $0x0
  pushl $208
80107a3c:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107a41:	e9 32 f1 ff ff       	jmp    80106b78 <alltraps>

80107a46 <vector209>:
.globl vector209
vector209:
  pushl $0
80107a46:	6a 00                	push   $0x0
  pushl $209
80107a48:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107a4d:	e9 26 f1 ff ff       	jmp    80106b78 <alltraps>

80107a52 <vector210>:
.globl vector210
vector210:
  pushl $0
80107a52:	6a 00                	push   $0x0
  pushl $210
80107a54:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107a59:	e9 1a f1 ff ff       	jmp    80106b78 <alltraps>

80107a5e <vector211>:
.globl vector211
vector211:
  pushl $0
80107a5e:	6a 00                	push   $0x0
  pushl $211
80107a60:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107a65:	e9 0e f1 ff ff       	jmp    80106b78 <alltraps>

80107a6a <vector212>:
.globl vector212
vector212:
  pushl $0
80107a6a:	6a 00                	push   $0x0
  pushl $212
80107a6c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107a71:	e9 02 f1 ff ff       	jmp    80106b78 <alltraps>

80107a76 <vector213>:
.globl vector213
vector213:
  pushl $0
80107a76:	6a 00                	push   $0x0
  pushl $213
80107a78:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107a7d:	e9 f6 f0 ff ff       	jmp    80106b78 <alltraps>

80107a82 <vector214>:
.globl vector214
vector214:
  pushl $0
80107a82:	6a 00                	push   $0x0
  pushl $214
80107a84:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107a89:	e9 ea f0 ff ff       	jmp    80106b78 <alltraps>

80107a8e <vector215>:
.globl vector215
vector215:
  pushl $0
80107a8e:	6a 00                	push   $0x0
  pushl $215
80107a90:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107a95:	e9 de f0 ff ff       	jmp    80106b78 <alltraps>

80107a9a <vector216>:
.globl vector216
vector216:
  pushl $0
80107a9a:	6a 00                	push   $0x0
  pushl $216
80107a9c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107aa1:	e9 d2 f0 ff ff       	jmp    80106b78 <alltraps>

80107aa6 <vector217>:
.globl vector217
vector217:
  pushl $0
80107aa6:	6a 00                	push   $0x0
  pushl $217
80107aa8:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107aad:	e9 c6 f0 ff ff       	jmp    80106b78 <alltraps>

80107ab2 <vector218>:
.globl vector218
vector218:
  pushl $0
80107ab2:	6a 00                	push   $0x0
  pushl $218
80107ab4:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107ab9:	e9 ba f0 ff ff       	jmp    80106b78 <alltraps>

80107abe <vector219>:
.globl vector219
vector219:
  pushl $0
80107abe:	6a 00                	push   $0x0
  pushl $219
80107ac0:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107ac5:	e9 ae f0 ff ff       	jmp    80106b78 <alltraps>

80107aca <vector220>:
.globl vector220
vector220:
  pushl $0
80107aca:	6a 00                	push   $0x0
  pushl $220
80107acc:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107ad1:	e9 a2 f0 ff ff       	jmp    80106b78 <alltraps>

80107ad6 <vector221>:
.globl vector221
vector221:
  pushl $0
80107ad6:	6a 00                	push   $0x0
  pushl $221
80107ad8:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107add:	e9 96 f0 ff ff       	jmp    80106b78 <alltraps>

80107ae2 <vector222>:
.globl vector222
vector222:
  pushl $0
80107ae2:	6a 00                	push   $0x0
  pushl $222
80107ae4:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107ae9:	e9 8a f0 ff ff       	jmp    80106b78 <alltraps>

80107aee <vector223>:
.globl vector223
vector223:
  pushl $0
80107aee:	6a 00                	push   $0x0
  pushl $223
80107af0:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107af5:	e9 7e f0 ff ff       	jmp    80106b78 <alltraps>

80107afa <vector224>:
.globl vector224
vector224:
  pushl $0
80107afa:	6a 00                	push   $0x0
  pushl $224
80107afc:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107b01:	e9 72 f0 ff ff       	jmp    80106b78 <alltraps>

80107b06 <vector225>:
.globl vector225
vector225:
  pushl $0
80107b06:	6a 00                	push   $0x0
  pushl $225
80107b08:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107b0d:	e9 66 f0 ff ff       	jmp    80106b78 <alltraps>

80107b12 <vector226>:
.globl vector226
vector226:
  pushl $0
80107b12:	6a 00                	push   $0x0
  pushl $226
80107b14:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107b19:	e9 5a f0 ff ff       	jmp    80106b78 <alltraps>

80107b1e <vector227>:
.globl vector227
vector227:
  pushl $0
80107b1e:	6a 00                	push   $0x0
  pushl $227
80107b20:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107b25:	e9 4e f0 ff ff       	jmp    80106b78 <alltraps>

80107b2a <vector228>:
.globl vector228
vector228:
  pushl $0
80107b2a:	6a 00                	push   $0x0
  pushl $228
80107b2c:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107b31:	e9 42 f0 ff ff       	jmp    80106b78 <alltraps>

80107b36 <vector229>:
.globl vector229
vector229:
  pushl $0
80107b36:	6a 00                	push   $0x0
  pushl $229
80107b38:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107b3d:	e9 36 f0 ff ff       	jmp    80106b78 <alltraps>

80107b42 <vector230>:
.globl vector230
vector230:
  pushl $0
80107b42:	6a 00                	push   $0x0
  pushl $230
80107b44:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107b49:	e9 2a f0 ff ff       	jmp    80106b78 <alltraps>

80107b4e <vector231>:
.globl vector231
vector231:
  pushl $0
80107b4e:	6a 00                	push   $0x0
  pushl $231
80107b50:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107b55:	e9 1e f0 ff ff       	jmp    80106b78 <alltraps>

80107b5a <vector232>:
.globl vector232
vector232:
  pushl $0
80107b5a:	6a 00                	push   $0x0
  pushl $232
80107b5c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107b61:	e9 12 f0 ff ff       	jmp    80106b78 <alltraps>

80107b66 <vector233>:
.globl vector233
vector233:
  pushl $0
80107b66:	6a 00                	push   $0x0
  pushl $233
80107b68:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107b6d:	e9 06 f0 ff ff       	jmp    80106b78 <alltraps>

80107b72 <vector234>:
.globl vector234
vector234:
  pushl $0
80107b72:	6a 00                	push   $0x0
  pushl $234
80107b74:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107b79:	e9 fa ef ff ff       	jmp    80106b78 <alltraps>

80107b7e <vector235>:
.globl vector235
vector235:
  pushl $0
80107b7e:	6a 00                	push   $0x0
  pushl $235
80107b80:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107b85:	e9 ee ef ff ff       	jmp    80106b78 <alltraps>

80107b8a <vector236>:
.globl vector236
vector236:
  pushl $0
80107b8a:	6a 00                	push   $0x0
  pushl $236
80107b8c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107b91:	e9 e2 ef ff ff       	jmp    80106b78 <alltraps>

80107b96 <vector237>:
.globl vector237
vector237:
  pushl $0
80107b96:	6a 00                	push   $0x0
  pushl $237
80107b98:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107b9d:	e9 d6 ef ff ff       	jmp    80106b78 <alltraps>

80107ba2 <vector238>:
.globl vector238
vector238:
  pushl $0
80107ba2:	6a 00                	push   $0x0
  pushl $238
80107ba4:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107ba9:	e9 ca ef ff ff       	jmp    80106b78 <alltraps>

80107bae <vector239>:
.globl vector239
vector239:
  pushl $0
80107bae:	6a 00                	push   $0x0
  pushl $239
80107bb0:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107bb5:	e9 be ef ff ff       	jmp    80106b78 <alltraps>

80107bba <vector240>:
.globl vector240
vector240:
  pushl $0
80107bba:	6a 00                	push   $0x0
  pushl $240
80107bbc:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107bc1:	e9 b2 ef ff ff       	jmp    80106b78 <alltraps>

80107bc6 <vector241>:
.globl vector241
vector241:
  pushl $0
80107bc6:	6a 00                	push   $0x0
  pushl $241
80107bc8:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107bcd:	e9 a6 ef ff ff       	jmp    80106b78 <alltraps>

80107bd2 <vector242>:
.globl vector242
vector242:
  pushl $0
80107bd2:	6a 00                	push   $0x0
  pushl $242
80107bd4:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107bd9:	e9 9a ef ff ff       	jmp    80106b78 <alltraps>

80107bde <vector243>:
.globl vector243
vector243:
  pushl $0
80107bde:	6a 00                	push   $0x0
  pushl $243
80107be0:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107be5:	e9 8e ef ff ff       	jmp    80106b78 <alltraps>

80107bea <vector244>:
.globl vector244
vector244:
  pushl $0
80107bea:	6a 00                	push   $0x0
  pushl $244
80107bec:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107bf1:	e9 82 ef ff ff       	jmp    80106b78 <alltraps>

80107bf6 <vector245>:
.globl vector245
vector245:
  pushl $0
80107bf6:	6a 00                	push   $0x0
  pushl $245
80107bf8:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107bfd:	e9 76 ef ff ff       	jmp    80106b78 <alltraps>

80107c02 <vector246>:
.globl vector246
vector246:
  pushl $0
80107c02:	6a 00                	push   $0x0
  pushl $246
80107c04:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107c09:	e9 6a ef ff ff       	jmp    80106b78 <alltraps>

80107c0e <vector247>:
.globl vector247
vector247:
  pushl $0
80107c0e:	6a 00                	push   $0x0
  pushl $247
80107c10:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107c15:	e9 5e ef ff ff       	jmp    80106b78 <alltraps>

80107c1a <vector248>:
.globl vector248
vector248:
  pushl $0
80107c1a:	6a 00                	push   $0x0
  pushl $248
80107c1c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107c21:	e9 52 ef ff ff       	jmp    80106b78 <alltraps>

80107c26 <vector249>:
.globl vector249
vector249:
  pushl $0
80107c26:	6a 00                	push   $0x0
  pushl $249
80107c28:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107c2d:	e9 46 ef ff ff       	jmp    80106b78 <alltraps>

80107c32 <vector250>:
.globl vector250
vector250:
  pushl $0
80107c32:	6a 00                	push   $0x0
  pushl $250
80107c34:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107c39:	e9 3a ef ff ff       	jmp    80106b78 <alltraps>

80107c3e <vector251>:
.globl vector251
vector251:
  pushl $0
80107c3e:	6a 00                	push   $0x0
  pushl $251
80107c40:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107c45:	e9 2e ef ff ff       	jmp    80106b78 <alltraps>

80107c4a <vector252>:
.globl vector252
vector252:
  pushl $0
80107c4a:	6a 00                	push   $0x0
  pushl $252
80107c4c:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107c51:	e9 22 ef ff ff       	jmp    80106b78 <alltraps>

80107c56 <vector253>:
.globl vector253
vector253:
  pushl $0
80107c56:	6a 00                	push   $0x0
  pushl $253
80107c58:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107c5d:	e9 16 ef ff ff       	jmp    80106b78 <alltraps>

80107c62 <vector254>:
.globl vector254
vector254:
  pushl $0
80107c62:	6a 00                	push   $0x0
  pushl $254
80107c64:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107c69:	e9 0a ef ff ff       	jmp    80106b78 <alltraps>

80107c6e <vector255>:
.globl vector255
vector255:
  pushl $0
80107c6e:	6a 00                	push   $0x0
  pushl $255
80107c70:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107c75:	e9 fe ee ff ff       	jmp    80106b78 <alltraps>
	...

80107c7c <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107c7c:	55                   	push   %ebp
80107c7d:	89 e5                	mov    %esp,%ebp
80107c7f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107c82:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c85:	83 e8 01             	sub    $0x1,%eax
80107c88:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80107c8f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107c93:	8b 45 08             	mov    0x8(%ebp),%eax
80107c96:	c1 e8 10             	shr    $0x10,%eax
80107c99:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107c9d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107ca0:	0f 01 10             	lgdtl  (%eax)
}
80107ca3:	c9                   	leave  
80107ca4:	c3                   	ret    

80107ca5 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107ca5:	55                   	push   %ebp
80107ca6:	89 e5                	mov    %esp,%ebp
80107ca8:	83 ec 04             	sub    $0x4,%esp
80107cab:	8b 45 08             	mov    0x8(%ebp),%eax
80107cae:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107cb2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107cb6:	0f 00 d8             	ltr    %ax
}
80107cb9:	c9                   	leave  
80107cba:	c3                   	ret    

80107cbb <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107cbb:	55                   	push   %ebp
80107cbc:	89 e5                	mov    %esp,%ebp
80107cbe:	83 ec 04             	sub    $0x4,%esp
80107cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80107cc4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107cc8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107ccc:	8e e8                	mov    %eax,%gs
}
80107cce:	c9                   	leave  
80107ccf:	c3                   	ret    

80107cd0 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107cd0:	55                   	push   %ebp
80107cd1:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80107cd6:	0f 22 d8             	mov    %eax,%cr3
}
80107cd9:	5d                   	pop    %ebp
80107cda:	c3                   	ret    

80107cdb <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107cdb:	55                   	push   %ebp
80107cdc:	89 e5                	mov    %esp,%ebp
80107cde:	8b 45 08             	mov    0x8(%ebp),%eax
80107ce1:	05 00 00 00 80       	add    $0x80000000,%eax
80107ce6:	5d                   	pop    %ebp
80107ce7:	c3                   	ret    

80107ce8 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107ce8:	55                   	push   %ebp
80107ce9:	89 e5                	mov    %esp,%ebp
80107ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80107cee:	05 00 00 00 80       	add    $0x80000000,%eax
80107cf3:	5d                   	pop    %ebp
80107cf4:	c3                   	ret    

80107cf5 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107cf5:	55                   	push   %ebp
80107cf6:	89 e5                	mov    %esp,%ebp
80107cf8:	53                   	push   %ebx
80107cf9:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107cfc:	e8 c2 b1 ff ff       	call   80102ec3 <cpunum>
80107d01:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107d07:	05 80 33 11 80       	add    $0x80113380,%eax
80107d0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d12:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d24:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d2f:	83 e2 f0             	and    $0xfffffff0,%edx
80107d32:	83 ca 0a             	or     $0xa,%edx
80107d35:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d3f:	83 ca 10             	or     $0x10,%edx
80107d42:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d48:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d4c:	83 e2 9f             	and    $0xffffff9f,%edx
80107d4f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d55:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d59:	83 ca 80             	or     $0xffffff80,%edx
80107d5c:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d62:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d66:	83 ca 0f             	or     $0xf,%edx
80107d69:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d73:	83 e2 ef             	and    $0xffffffef,%edx
80107d76:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d80:	83 e2 df             	and    $0xffffffdf,%edx
80107d83:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d89:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d8d:	83 ca 40             	or     $0x40,%edx
80107d90:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d96:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d9a:	83 ca 80             	or     $0xffffff80,%edx
80107d9d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da3:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107daa:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107db1:	ff ff 
80107db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db6:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107dbd:	00 00 
80107dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc2:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107dd3:	83 e2 f0             	and    $0xfffffff0,%edx
80107dd6:	83 ca 02             	or     $0x2,%edx
80107dd9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107de9:	83 ca 10             	or     $0x10,%edx
80107dec:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107dfc:	83 e2 9f             	and    $0xffffff9f,%edx
80107dff:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e08:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107e0f:	83 ca 80             	or     $0xffffff80,%edx
80107e12:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e22:	83 ca 0f             	or     $0xf,%edx
80107e25:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e35:	83 e2 ef             	and    $0xffffffef,%edx
80107e38:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e41:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e48:	83 e2 df             	and    $0xffffffdf,%edx
80107e4b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e54:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e5b:	83 ca 40             	or     $0x40,%edx
80107e5e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e67:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e6e:	83 ca 80             	or     $0xffffff80,%edx
80107e71:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e84:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107e8b:	ff ff 
80107e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e90:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107e97:	00 00 
80107e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ead:	83 e2 f0             	and    $0xfffffff0,%edx
80107eb0:	83 ca 0a             	or     $0xa,%edx
80107eb3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ec3:	83 ca 10             	or     $0x10,%edx
80107ec6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecf:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ed6:	83 ca 60             	or     $0x60,%edx
80107ed9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ee9:	83 ca 80             	or     $0xffffff80,%edx
80107eec:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107efc:	83 ca 0f             	or     $0xf,%edx
80107eff:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f08:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f0f:	83 e2 ef             	and    $0xffffffef,%edx
80107f12:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f22:	83 e2 df             	and    $0xffffffdf,%edx
80107f25:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f35:	83 ca 40             	or     $0x40,%edx
80107f38:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f41:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f48:	83 ca 80             	or     $0xffffff80,%edx
80107f4b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f54:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5e:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107f65:	ff ff 
80107f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6a:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107f71:	00 00 
80107f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f76:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f80:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f87:	83 e2 f0             	and    $0xfffffff0,%edx
80107f8a:	83 ca 02             	or     $0x2,%edx
80107f8d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f96:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f9d:	83 ca 10             	or     $0x10,%edx
80107fa0:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107fb0:	83 ca 60             	or     $0x60,%edx
80107fb3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbc:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107fc3:	83 ca 80             	or     $0xffffff80,%edx
80107fc6:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcf:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107fd6:	83 ca 0f             	or     $0xf,%edx
80107fd9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe2:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107fe9:	83 e2 ef             	and    $0xffffffef,%edx
80107fec:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff5:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ffc:	83 e2 df             	and    $0xffffffdf,%edx
80107fff:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108005:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108008:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010800f:	83 ca 40             	or     $0x40,%edx
80108012:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108022:	83 ca 80             	or     $0xffffff80,%edx
80108025:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010802b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802e:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108038:	05 b4 00 00 00       	add    $0xb4,%eax
8010803d:	89 c3                	mov    %eax,%ebx
8010803f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108042:	05 b4 00 00 00       	add    $0xb4,%eax
80108047:	c1 e8 10             	shr    $0x10,%eax
8010804a:	89 c1                	mov    %eax,%ecx
8010804c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804f:	05 b4 00 00 00       	add    $0xb4,%eax
80108054:	c1 e8 18             	shr    $0x18,%eax
80108057:	89 c2                	mov    %eax,%edx
80108059:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010805c:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108063:	00 00 
80108065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108068:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
8010806f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108072:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80108078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010807b:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108082:	83 e1 f0             	and    $0xfffffff0,%ecx
80108085:	83 c9 02             	or     $0x2,%ecx
80108088:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010808e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108091:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108098:	83 c9 10             	or     $0x10,%ecx
8010809b:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801080a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a4:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801080ab:	83 e1 9f             	and    $0xffffff9f,%ecx
801080ae:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801080b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b7:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801080be:	83 c9 80             	or     $0xffffff80,%ecx
801080c1:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801080c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ca:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801080d1:	83 e1 f0             	and    $0xfffffff0,%ecx
801080d4:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801080da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080dd:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801080e4:	83 e1 ef             	and    $0xffffffef,%ecx
801080e7:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801080ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f0:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801080f7:	83 e1 df             	and    $0xffffffdf,%ecx
801080fa:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108103:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010810a:	83 c9 40             	or     $0x40,%ecx
8010810d:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108116:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010811d:	83 c9 80             	or     $0xffffff80,%ecx
80108120:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108129:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010812f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108132:	83 c0 70             	add    $0x70,%eax
80108135:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
8010813c:	00 
8010813d:	89 04 24             	mov    %eax,(%esp)
80108140:	e8 37 fb ff ff       	call   80107c7c <lgdt>
  loadgs(SEG_KCPU << 3);
80108145:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
8010814c:	e8 6a fb ff ff       	call   80107cbb <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80108151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108154:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
8010815a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108161:	00 00 00 00 
}
80108165:	83 c4 24             	add    $0x24,%esp
80108168:	5b                   	pop    %ebx
80108169:	5d                   	pop    %ebp
8010816a:	c3                   	ret    

8010816b <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010816b:	55                   	push   %ebp
8010816c:	89 e5                	mov    %esp,%ebp
8010816e:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108171:	8b 45 0c             	mov    0xc(%ebp),%eax
80108174:	c1 e8 16             	shr    $0x16,%eax
80108177:	c1 e0 02             	shl    $0x2,%eax
8010817a:	03 45 08             	add    0x8(%ebp),%eax
8010817d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108180:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108183:	8b 00                	mov    (%eax),%eax
80108185:	83 e0 01             	and    $0x1,%eax
80108188:	84 c0                	test   %al,%al
8010818a:	74 17                	je     801081a3 <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
8010818c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010818f:	8b 00                	mov    (%eax),%eax
80108191:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108196:	89 04 24             	mov    %eax,(%esp)
80108199:	e8 4a fb ff ff       	call   80107ce8 <p2v>
8010819e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801081a1:	eb 4b                	jmp    801081ee <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801081a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801081a7:	74 0e                	je     801081b7 <walkpgdir+0x4c>
801081a9:	e8 5d a9 ff ff       	call   80102b0b <kalloc>
801081ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801081b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801081b5:	75 07                	jne    801081be <walkpgdir+0x53>
      return 0;
801081b7:	b8 00 00 00 00       	mov    $0x0,%eax
801081bc:	eb 41                	jmp    801081ff <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801081be:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801081c5:	00 
801081c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801081cd:	00 
801081ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d1:	89 04 24             	mov    %eax,(%esp)
801081d4:	e8 69 d3 ff ff       	call   80105542 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801081d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081dc:	89 04 24             	mov    %eax,(%esp)
801081df:	e8 f7 fa ff ff       	call   80107cdb <v2p>
801081e4:	89 c2                	mov    %eax,%edx
801081e6:	83 ca 07             	or     $0x7,%edx
801081e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ec:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801081ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801081f1:	c1 e8 0c             	shr    $0xc,%eax
801081f4:	25 ff 03 00 00       	and    $0x3ff,%eax
801081f9:	c1 e0 02             	shl    $0x2,%eax
801081fc:	03 45 f4             	add    -0xc(%ebp),%eax
}
801081ff:	c9                   	leave  
80108200:	c3                   	ret    

80108201 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108201:	55                   	push   %ebp
80108202:	89 e5                	mov    %esp,%ebp
80108204:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108207:	8b 45 0c             	mov    0xc(%ebp),%eax
8010820a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010820f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108212:	8b 45 0c             	mov    0xc(%ebp),%eax
80108215:	03 45 10             	add    0x10(%ebp),%eax
80108218:	83 e8 01             	sub    $0x1,%eax
8010821b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108220:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108223:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010822a:	00 
8010822b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108232:	8b 45 08             	mov    0x8(%ebp),%eax
80108235:	89 04 24             	mov    %eax,(%esp)
80108238:	e8 2e ff ff ff       	call   8010816b <walkpgdir>
8010823d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108240:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108244:	75 07                	jne    8010824d <mappages+0x4c>
      return -1;
80108246:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010824b:	eb 46                	jmp    80108293 <mappages+0x92>
    if(*pte & PTE_P)
8010824d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108250:	8b 00                	mov    (%eax),%eax
80108252:	83 e0 01             	and    $0x1,%eax
80108255:	84 c0                	test   %al,%al
80108257:	74 0c                	je     80108265 <mappages+0x64>
      panic("remap");
80108259:	c7 04 24 94 90 10 80 	movl   $0x80109094,(%esp)
80108260:	e8 d8 82 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80108265:	8b 45 18             	mov    0x18(%ebp),%eax
80108268:	0b 45 14             	or     0x14(%ebp),%eax
8010826b:	89 c2                	mov    %eax,%edx
8010826d:	83 ca 01             	or     $0x1,%edx
80108270:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108273:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108275:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108278:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010827b:	74 10                	je     8010828d <mappages+0x8c>
      break;
    a += PGSIZE;
8010827d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108284:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010828b:	eb 96                	jmp    80108223 <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
8010828d:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
8010828e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108293:	c9                   	leave  
80108294:	c3                   	ret    

80108295 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108295:	55                   	push   %ebp
80108296:	89 e5                	mov    %esp,%ebp
80108298:	53                   	push   %ebx
80108299:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010829c:	e8 6a a8 ff ff       	call   80102b0b <kalloc>
801082a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801082a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082a8:	75 0a                	jne    801082b4 <setupkvm+0x1f>
    return 0;
801082aa:	b8 00 00 00 00       	mov    $0x0,%eax
801082af:	e9 98 00 00 00       	jmp    8010834c <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
801082b4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082bb:	00 
801082bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082c3:	00 
801082c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082c7:	89 04 24             	mov    %eax,(%esp)
801082ca:	e8 73 d2 ff ff       	call   80105542 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801082cf:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
801082d6:	e8 0d fa ff ff       	call   80107ce8 <p2v>
801082db:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
801082e0:	76 0c                	jbe    801082ee <setupkvm+0x59>
    panic("PHYSTOP too high");
801082e2:	c7 04 24 9a 90 10 80 	movl   $0x8010909a,(%esp)
801082e9:	e8 4f 82 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801082ee:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
801082f5:	eb 49                	jmp    80108340 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
801082f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801082fa:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
801082fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108300:	8b 50 04             	mov    0x4(%eax),%edx
80108303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108306:	8b 58 08             	mov    0x8(%eax),%ebx
80108309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010830c:	8b 40 04             	mov    0x4(%eax),%eax
8010830f:	29 c3                	sub    %eax,%ebx
80108311:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108314:	8b 00                	mov    (%eax),%eax
80108316:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010831a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010831e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108322:	89 44 24 04          	mov    %eax,0x4(%esp)
80108326:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108329:	89 04 24             	mov    %eax,(%esp)
8010832c:	e8 d0 fe ff ff       	call   80108201 <mappages>
80108331:	85 c0                	test   %eax,%eax
80108333:	79 07                	jns    8010833c <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108335:	b8 00 00 00 00       	mov    $0x0,%eax
8010833a:	eb 10                	jmp    8010834c <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010833c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108340:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80108347:	72 ae                	jb     801082f7 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108349:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010834c:	83 c4 34             	add    $0x34,%esp
8010834f:	5b                   	pop    %ebx
80108350:	5d                   	pop    %ebp
80108351:	c3                   	ret    

80108352 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108352:	55                   	push   %ebp
80108353:	89 e5                	mov    %esp,%ebp
80108355:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108358:	e8 38 ff ff ff       	call   80108295 <setupkvm>
8010835d:	a3 58 64 11 80       	mov    %eax,0x80116458
  switchkvm();
80108362:	e8 02 00 00 00       	call   80108369 <switchkvm>
}
80108367:	c9                   	leave  
80108368:	c3                   	ret    

80108369 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108369:	55                   	push   %ebp
8010836a:	89 e5                	mov    %esp,%ebp
8010836c:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
8010836f:	a1 58 64 11 80       	mov    0x80116458,%eax
80108374:	89 04 24             	mov    %eax,(%esp)
80108377:	e8 5f f9 ff ff       	call   80107cdb <v2p>
8010837c:	89 04 24             	mov    %eax,(%esp)
8010837f:	e8 4c f9 ff ff       	call   80107cd0 <lcr3>
}
80108384:	c9                   	leave  
80108385:	c3                   	ret    

80108386 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108386:	55                   	push   %ebp
80108387:	89 e5                	mov    %esp,%ebp
80108389:	53                   	push   %ebx
8010838a:	83 ec 14             	sub    $0x14,%esp
  pushcli();
8010838d:	e8 a9 d0 ff ff       	call   8010543b <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108392:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108398:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010839f:	83 c2 08             	add    $0x8,%edx
801083a2:	89 d3                	mov    %edx,%ebx
801083a4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801083ab:	83 c2 08             	add    $0x8,%edx
801083ae:	c1 ea 10             	shr    $0x10,%edx
801083b1:	89 d1                	mov    %edx,%ecx
801083b3:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801083ba:	83 c2 08             	add    $0x8,%edx
801083bd:	c1 ea 18             	shr    $0x18,%edx
801083c0:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801083c7:	67 00 
801083c9:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
801083d0:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
801083d6:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801083dd:	83 e1 f0             	and    $0xfffffff0,%ecx
801083e0:	83 c9 09             	or     $0x9,%ecx
801083e3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801083e9:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801083f0:	83 c9 10             	or     $0x10,%ecx
801083f3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801083f9:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108400:	83 e1 9f             	and    $0xffffff9f,%ecx
80108403:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108409:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108410:	83 c9 80             	or     $0xffffff80,%ecx
80108413:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108419:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108420:	83 e1 f0             	and    $0xfffffff0,%ecx
80108423:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108429:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108430:	83 e1 ef             	and    $0xffffffef,%ecx
80108433:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108439:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108440:	83 e1 df             	and    $0xffffffdf,%ecx
80108443:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108449:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108450:	83 c9 40             	or     $0x40,%ecx
80108453:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108459:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108460:	83 e1 7f             	and    $0x7f,%ecx
80108463:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108469:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
8010846f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108475:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010847c:	83 e2 ef             	and    $0xffffffef,%edx
8010847f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108485:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010848b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108491:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108497:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010849e:	8b 52 08             	mov    0x8(%edx),%edx
801084a1:	81 c2 00 10 00 00    	add    $0x1000,%edx
801084a7:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801084aa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801084b1:	e8 ef f7 ff ff       	call   80107ca5 <ltr>
  if(p->pgdir == 0)
801084b6:	8b 45 08             	mov    0x8(%ebp),%eax
801084b9:	8b 40 04             	mov    0x4(%eax),%eax
801084bc:	85 c0                	test   %eax,%eax
801084be:	75 0c                	jne    801084cc <switchuvm+0x146>
    panic("switchuvm: no pgdir");
801084c0:	c7 04 24 ab 90 10 80 	movl   $0x801090ab,(%esp)
801084c7:	e8 71 80 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801084cc:	8b 45 08             	mov    0x8(%ebp),%eax
801084cf:	8b 40 04             	mov    0x4(%eax),%eax
801084d2:	89 04 24             	mov    %eax,(%esp)
801084d5:	e8 01 f8 ff ff       	call   80107cdb <v2p>
801084da:	89 04 24             	mov    %eax,(%esp)
801084dd:	e8 ee f7 ff ff       	call   80107cd0 <lcr3>
  popcli();
801084e2:	e8 9c cf ff ff       	call   80105483 <popcli>
}
801084e7:	83 c4 14             	add    $0x14,%esp
801084ea:	5b                   	pop    %ebx
801084eb:	5d                   	pop    %ebp
801084ec:	c3                   	ret    

801084ed <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801084ed:	55                   	push   %ebp
801084ee:	89 e5                	mov    %esp,%ebp
801084f0:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801084f3:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801084fa:	76 0c                	jbe    80108508 <inituvm+0x1b>
    panic("inituvm: more than a page");
801084fc:	c7 04 24 bf 90 10 80 	movl   $0x801090bf,(%esp)
80108503:	e8 35 80 ff ff       	call   8010053d <panic>
  mem = kalloc();
80108508:	e8 fe a5 ff ff       	call   80102b0b <kalloc>
8010850d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108510:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108517:	00 
80108518:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010851f:	00 
80108520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108523:	89 04 24             	mov    %eax,(%esp)
80108526:	e8 17 d0 ff ff       	call   80105542 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010852b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852e:	89 04 24             	mov    %eax,(%esp)
80108531:	e8 a5 f7 ff ff       	call   80107cdb <v2p>
80108536:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010853d:	00 
8010853e:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108542:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108549:	00 
8010854a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108551:	00 
80108552:	8b 45 08             	mov    0x8(%ebp),%eax
80108555:	89 04 24             	mov    %eax,(%esp)
80108558:	e8 a4 fc ff ff       	call   80108201 <mappages>
  memmove(mem, init, sz);
8010855d:	8b 45 10             	mov    0x10(%ebp),%eax
80108560:	89 44 24 08          	mov    %eax,0x8(%esp)
80108564:	8b 45 0c             	mov    0xc(%ebp),%eax
80108567:	89 44 24 04          	mov    %eax,0x4(%esp)
8010856b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010856e:	89 04 24             	mov    %eax,(%esp)
80108571:	e8 9f d0 ff ff       	call   80105615 <memmove>
}
80108576:	c9                   	leave  
80108577:	c3                   	ret    

80108578 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108578:	55                   	push   %ebp
80108579:	89 e5                	mov    %esp,%ebp
8010857b:	53                   	push   %ebx
8010857c:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010857f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108582:	25 ff 0f 00 00       	and    $0xfff,%eax
80108587:	85 c0                	test   %eax,%eax
80108589:	74 0c                	je     80108597 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010858b:	c7 04 24 dc 90 10 80 	movl   $0x801090dc,(%esp)
80108592:	e8 a6 7f ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010859e:	e9 ad 00 00 00       	jmp    80108650 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801085a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a6:	8b 55 0c             	mov    0xc(%ebp),%edx
801085a9:	01 d0                	add    %edx,%eax
801085ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085b2:	00 
801085b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801085b7:	8b 45 08             	mov    0x8(%ebp),%eax
801085ba:	89 04 24             	mov    %eax,(%esp)
801085bd:	e8 a9 fb ff ff       	call   8010816b <walkpgdir>
801085c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801085c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085c9:	75 0c                	jne    801085d7 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801085cb:	c7 04 24 ff 90 10 80 	movl   $0x801090ff,(%esp)
801085d2:	e8 66 7f ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801085d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085da:	8b 00                	mov    (%eax),%eax
801085dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801085e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e7:	8b 55 18             	mov    0x18(%ebp),%edx
801085ea:	89 d1                	mov    %edx,%ecx
801085ec:	29 c1                	sub    %eax,%ecx
801085ee:	89 c8                	mov    %ecx,%eax
801085f0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801085f5:	77 11                	ja     80108608 <loaduvm+0x90>
      n = sz - i;
801085f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085fa:	8b 55 18             	mov    0x18(%ebp),%edx
801085fd:	89 d1                	mov    %edx,%ecx
801085ff:	29 c1                	sub    %eax,%ecx
80108601:	89 c8                	mov    %ecx,%eax
80108603:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108606:	eb 07                	jmp    8010860f <loaduvm+0x97>
    else
      n = PGSIZE;
80108608:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010860f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108612:	8b 55 14             	mov    0x14(%ebp),%edx
80108615:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108618:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010861b:	89 04 24             	mov    %eax,(%esp)
8010861e:	e8 c5 f6 ff ff       	call   80107ce8 <p2v>
80108623:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108626:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010862a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010862e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108632:	8b 45 10             	mov    0x10(%ebp),%eax
80108635:	89 04 24             	mov    %eax,(%esp)
80108638:	e8 2d 97 ff ff       	call   80101d6a <readi>
8010863d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108640:	74 07                	je     80108649 <loaduvm+0xd1>
      return -1;
80108642:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108647:	eb 18                	jmp    80108661 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108649:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108653:	3b 45 18             	cmp    0x18(%ebp),%eax
80108656:	0f 82 47 ff ff ff    	jb     801085a3 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010865c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108661:	83 c4 24             	add    $0x24,%esp
80108664:	5b                   	pop    %ebx
80108665:	5d                   	pop    %ebp
80108666:	c3                   	ret    

80108667 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108667:	55                   	push   %ebp
80108668:	89 e5                	mov    %esp,%ebp
8010866a:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010866d:	8b 45 10             	mov    0x10(%ebp),%eax
80108670:	85 c0                	test   %eax,%eax
80108672:	79 0a                	jns    8010867e <allocuvm+0x17>
    return 0;
80108674:	b8 00 00 00 00       	mov    $0x0,%eax
80108679:	e9 c1 00 00 00       	jmp    8010873f <allocuvm+0xd8>
  if(newsz < oldsz)
8010867e:	8b 45 10             	mov    0x10(%ebp),%eax
80108681:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108684:	73 08                	jae    8010868e <allocuvm+0x27>
    return oldsz;
80108686:	8b 45 0c             	mov    0xc(%ebp),%eax
80108689:	e9 b1 00 00 00       	jmp    8010873f <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
8010868e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108691:	05 ff 0f 00 00       	add    $0xfff,%eax
80108696:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010869b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010869e:	e9 8d 00 00 00       	jmp    80108730 <allocuvm+0xc9>
    mem = kalloc();
801086a3:	e8 63 a4 ff ff       	call   80102b0b <kalloc>
801086a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801086ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086af:	75 2c                	jne    801086dd <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801086b1:	c7 04 24 1d 91 10 80 	movl   $0x8010911d,(%esp)
801086b8:	e8 e4 7c ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801086bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801086c0:	89 44 24 08          	mov    %eax,0x8(%esp)
801086c4:	8b 45 10             	mov    0x10(%ebp),%eax
801086c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801086cb:	8b 45 08             	mov    0x8(%ebp),%eax
801086ce:	89 04 24             	mov    %eax,(%esp)
801086d1:	e8 6b 00 00 00       	call   80108741 <deallocuvm>
      return 0;
801086d6:	b8 00 00 00 00       	mov    $0x0,%eax
801086db:	eb 62                	jmp    8010873f <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801086dd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801086e4:	00 
801086e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801086ec:	00 
801086ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086f0:	89 04 24             	mov    %eax,(%esp)
801086f3:	e8 4a ce ff ff       	call   80105542 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801086f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086fb:	89 04 24             	mov    %eax,(%esp)
801086fe:	e8 d8 f5 ff ff       	call   80107cdb <v2p>
80108703:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108706:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010870d:	00 
8010870e:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108712:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108719:	00 
8010871a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010871e:	8b 45 08             	mov    0x8(%ebp),%eax
80108721:	89 04 24             	mov    %eax,(%esp)
80108724:	e8 d8 fa ff ff       	call   80108201 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108729:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108733:	3b 45 10             	cmp    0x10(%ebp),%eax
80108736:	0f 82 67 ff ff ff    	jb     801086a3 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010873c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010873f:	c9                   	leave  
80108740:	c3                   	ret    

80108741 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108741:	55                   	push   %ebp
80108742:	89 e5                	mov    %esp,%ebp
80108744:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108747:	8b 45 10             	mov    0x10(%ebp),%eax
8010874a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010874d:	72 08                	jb     80108757 <deallocuvm+0x16>
    return oldsz;
8010874f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108752:	e9 a4 00 00 00       	jmp    801087fb <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108757:	8b 45 10             	mov    0x10(%ebp),%eax
8010875a:	05 ff 0f 00 00       	add    $0xfff,%eax
8010875f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108764:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108767:	e9 80 00 00 00       	jmp    801087ec <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010876c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108776:	00 
80108777:	89 44 24 04          	mov    %eax,0x4(%esp)
8010877b:	8b 45 08             	mov    0x8(%ebp),%eax
8010877e:	89 04 24             	mov    %eax,(%esp)
80108781:	e8 e5 f9 ff ff       	call   8010816b <walkpgdir>
80108786:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108789:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010878d:	75 09                	jne    80108798 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
8010878f:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108796:	eb 4d                	jmp    801087e5 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108798:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010879b:	8b 00                	mov    (%eax),%eax
8010879d:	83 e0 01             	and    $0x1,%eax
801087a0:	84 c0                	test   %al,%al
801087a2:	74 41                	je     801087e5 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801087a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087a7:	8b 00                	mov    (%eax),%eax
801087a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801087b1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801087b5:	75 0c                	jne    801087c3 <deallocuvm+0x82>
        panic("kfree");
801087b7:	c7 04 24 35 91 10 80 	movl   $0x80109135,(%esp)
801087be:	e8 7a 7d ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
801087c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087c6:	89 04 24             	mov    %eax,(%esp)
801087c9:	e8 1a f5 ff ff       	call   80107ce8 <p2v>
801087ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801087d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087d4:	89 04 24             	mov    %eax,(%esp)
801087d7:	e8 96 a2 ff ff       	call   80102a72 <kfree>
      *pte = 0;
801087dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801087e5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801087ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ef:	3b 45 0c             	cmp    0xc(%ebp),%eax
801087f2:	0f 82 74 ff ff ff    	jb     8010876c <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801087f8:	8b 45 10             	mov    0x10(%ebp),%eax
}
801087fb:	c9                   	leave  
801087fc:	c3                   	ret    

801087fd <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801087fd:	55                   	push   %ebp
801087fe:	89 e5                	mov    %esp,%ebp
80108800:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108803:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108807:	75 0c                	jne    80108815 <freevm+0x18>
    panic("freevm: no pgdir");
80108809:	c7 04 24 3b 91 10 80 	movl   $0x8010913b,(%esp)
80108810:	e8 28 7d ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108815:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010881c:	00 
8010881d:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108824:	80 
80108825:	8b 45 08             	mov    0x8(%ebp),%eax
80108828:	89 04 24             	mov    %eax,(%esp)
8010882b:	e8 11 ff ff ff       	call   80108741 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108830:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108837:	eb 3c                	jmp    80108875 <freevm+0x78>
    if(pgdir[i] & PTE_P){
80108839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883c:	c1 e0 02             	shl    $0x2,%eax
8010883f:	03 45 08             	add    0x8(%ebp),%eax
80108842:	8b 00                	mov    (%eax),%eax
80108844:	83 e0 01             	and    $0x1,%eax
80108847:	84 c0                	test   %al,%al
80108849:	74 26                	je     80108871 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010884b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884e:	c1 e0 02             	shl    $0x2,%eax
80108851:	03 45 08             	add    0x8(%ebp),%eax
80108854:	8b 00                	mov    (%eax),%eax
80108856:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010885b:	89 04 24             	mov    %eax,(%esp)
8010885e:	e8 85 f4 ff ff       	call   80107ce8 <p2v>
80108863:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108869:	89 04 24             	mov    %eax,(%esp)
8010886c:	e8 01 a2 ff ff       	call   80102a72 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108871:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108875:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010887c:	76 bb                	jbe    80108839 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010887e:	8b 45 08             	mov    0x8(%ebp),%eax
80108881:	89 04 24             	mov    %eax,(%esp)
80108884:	e8 e9 a1 ff ff       	call   80102a72 <kfree>
}
80108889:	c9                   	leave  
8010888a:	c3                   	ret    

8010888b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010888b:	55                   	push   %ebp
8010888c:	89 e5                	mov    %esp,%ebp
8010888e:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108891:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108898:	00 
80108899:	8b 45 0c             	mov    0xc(%ebp),%eax
8010889c:	89 44 24 04          	mov    %eax,0x4(%esp)
801088a0:	8b 45 08             	mov    0x8(%ebp),%eax
801088a3:	89 04 24             	mov    %eax,(%esp)
801088a6:	e8 c0 f8 ff ff       	call   8010816b <walkpgdir>
801088ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801088ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801088b2:	75 0c                	jne    801088c0 <clearpteu+0x35>
    panic("clearpteu");
801088b4:	c7 04 24 4c 91 10 80 	movl   $0x8010914c,(%esp)
801088bb:	e8 7d 7c ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
801088c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c3:	8b 00                	mov    (%eax),%eax
801088c5:	89 c2                	mov    %eax,%edx
801088c7:	83 e2 fb             	and    $0xfffffffb,%edx
801088ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088cd:	89 10                	mov    %edx,(%eax)
}
801088cf:	c9                   	leave  
801088d0:	c3                   	ret    

801088d1 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801088d1:	55                   	push   %ebp
801088d2:	89 e5                	mov    %esp,%ebp
801088d4:	53                   	push   %ebx
801088d5:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801088d8:	e8 b8 f9 ff ff       	call   80108295 <setupkvm>
801088dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801088e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801088e4:	75 0a                	jne    801088f0 <copyuvm+0x1f>
    return 0;
801088e6:	b8 00 00 00 00       	mov    $0x0,%eax
801088eb:	e9 fd 00 00 00       	jmp    801089ed <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
801088f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801088f7:	e9 cc 00 00 00       	jmp    801089c8 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801088fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108906:	00 
80108907:	89 44 24 04          	mov    %eax,0x4(%esp)
8010890b:	8b 45 08             	mov    0x8(%ebp),%eax
8010890e:	89 04 24             	mov    %eax,(%esp)
80108911:	e8 55 f8 ff ff       	call   8010816b <walkpgdir>
80108916:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108919:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010891d:	75 0c                	jne    8010892b <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
8010891f:	c7 04 24 56 91 10 80 	movl   $0x80109156,(%esp)
80108926:	e8 12 7c ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
8010892b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010892e:	8b 00                	mov    (%eax),%eax
80108930:	83 e0 01             	and    $0x1,%eax
80108933:	85 c0                	test   %eax,%eax
80108935:	75 0c                	jne    80108943 <copyuvm+0x72>
      panic("copyuvm: page not present");
80108937:	c7 04 24 70 91 10 80 	movl   $0x80109170,(%esp)
8010893e:	e8 fa 7b ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108943:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108946:	8b 00                	mov    (%eax),%eax
80108948:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010894d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108950:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108953:	8b 00                	mov    (%eax),%eax
80108955:	25 ff 0f 00 00       	and    $0xfff,%eax
8010895a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010895d:	e8 a9 a1 ff ff       	call   80102b0b <kalloc>
80108962:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108965:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108969:	74 6e                	je     801089d9 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010896b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010896e:	89 04 24             	mov    %eax,(%esp)
80108971:	e8 72 f3 ff ff       	call   80107ce8 <p2v>
80108976:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010897d:	00 
8010897e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108982:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108985:	89 04 24             	mov    %eax,(%esp)
80108988:	e8 88 cc ff ff       	call   80105615 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010898d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108990:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108993:	89 04 24             	mov    %eax,(%esp)
80108996:	e8 40 f3 ff ff       	call   80107cdb <v2p>
8010899b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010899e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801089a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
801089a6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801089ad:	00 
801089ae:	89 54 24 04          	mov    %edx,0x4(%esp)
801089b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089b5:	89 04 24             	mov    %eax,(%esp)
801089b8:	e8 44 f8 ff ff       	call   80108201 <mappages>
801089bd:	85 c0                	test   %eax,%eax
801089bf:	78 1b                	js     801089dc <copyuvm+0x10b>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801089c1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801089c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089cb:	3b 45 0c             	cmp    0xc(%ebp),%eax
801089ce:	0f 82 28 ff ff ff    	jb     801088fc <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801089d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089d7:	eb 14                	jmp    801089ed <copyuvm+0x11c>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801089d9:	90                   	nop
801089da:	eb 01                	jmp    801089dd <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801089dc:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801089dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089e0:	89 04 24             	mov    %eax,(%esp)
801089e3:	e8 15 fe ff ff       	call   801087fd <freevm>
  return 0;
801089e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801089ed:	83 c4 44             	add    $0x44,%esp
801089f0:	5b                   	pop    %ebx
801089f1:	5d                   	pop    %ebp
801089f2:	c3                   	ret    

801089f3 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801089f3:	55                   	push   %ebp
801089f4:	89 e5                	mov    %esp,%ebp
801089f6:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801089f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108a00:	00 
80108a01:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a04:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a08:	8b 45 08             	mov    0x8(%ebp),%eax
80108a0b:	89 04 24             	mov    %eax,(%esp)
80108a0e:	e8 58 f7 ff ff       	call   8010816b <walkpgdir>
80108a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a19:	8b 00                	mov    (%eax),%eax
80108a1b:	83 e0 01             	and    $0x1,%eax
80108a1e:	85 c0                	test   %eax,%eax
80108a20:	75 07                	jne    80108a29 <uva2ka+0x36>
    return 0;
80108a22:	b8 00 00 00 00       	mov    $0x0,%eax
80108a27:	eb 25                	jmp    80108a4e <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a2c:	8b 00                	mov    (%eax),%eax
80108a2e:	83 e0 04             	and    $0x4,%eax
80108a31:	85 c0                	test   %eax,%eax
80108a33:	75 07                	jne    80108a3c <uva2ka+0x49>
    return 0;
80108a35:	b8 00 00 00 00       	mov    $0x0,%eax
80108a3a:	eb 12                	jmp    80108a4e <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a3f:	8b 00                	mov    (%eax),%eax
80108a41:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a46:	89 04 24             	mov    %eax,(%esp)
80108a49:	e8 9a f2 ff ff       	call   80107ce8 <p2v>
}
80108a4e:	c9                   	leave  
80108a4f:	c3                   	ret    

80108a50 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108a50:	55                   	push   %ebp
80108a51:	89 e5                	mov    %esp,%ebp
80108a53:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108a56:	8b 45 10             	mov    0x10(%ebp),%eax
80108a59:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108a5c:	e9 8b 00 00 00       	jmp    80108aec <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80108a61:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a69:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108a6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a73:	8b 45 08             	mov    0x8(%ebp),%eax
80108a76:	89 04 24             	mov    %eax,(%esp)
80108a79:	e8 75 ff ff ff       	call   801089f3 <uva2ka>
80108a7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108a81:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108a85:	75 07                	jne    80108a8e <copyout+0x3e>
      return -1;
80108a87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108a8c:	eb 6d                	jmp    80108afb <copyout+0xab>
    n = PGSIZE - (va - va0);
80108a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a91:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108a94:	89 d1                	mov    %edx,%ecx
80108a96:	29 c1                	sub    %eax,%ecx
80108a98:	89 c8                	mov    %ecx,%eax
80108a9a:	05 00 10 00 00       	add    $0x1000,%eax
80108a9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aa5:	3b 45 14             	cmp    0x14(%ebp),%eax
80108aa8:	76 06                	jbe    80108ab0 <copyout+0x60>
      n = len;
80108aaa:	8b 45 14             	mov    0x14(%ebp),%eax
80108aad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108ab0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ab3:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ab6:	89 d1                	mov    %edx,%ecx
80108ab8:	29 c1                	sub    %eax,%ecx
80108aba:	89 c8                	mov    %ecx,%eax
80108abc:	03 45 e8             	add    -0x18(%ebp),%eax
80108abf:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108ac2:	89 54 24 08          	mov    %edx,0x8(%esp)
80108ac6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ac9:	89 54 24 04          	mov    %edx,0x4(%esp)
80108acd:	89 04 24             	mov    %eax,(%esp)
80108ad0:	e8 40 cb ff ff       	call   80105615 <memmove>
    len -= n;
80108ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ad8:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ade:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108ae1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ae4:	05 00 10 00 00       	add    $0x1000,%eax
80108ae9:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108aec:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108af0:	0f 85 6b ff ff ff    	jne    80108a61 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108af6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108afb:	c9                   	leave  
80108afc:	c3                   	ret    
