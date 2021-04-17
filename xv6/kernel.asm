
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

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
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 14 3a 10 80       	mov    $0x80103a14,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	f3 0f 1e fb          	endbr32 
80100038:	55                   	push   %ebp
80100039:	89 e5                	mov    %esp,%ebp
8010003b:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003e:	83 ec 08             	sub    $0x8,%esp
80100041:	68 4c 90 10 80       	push   $0x8010904c
80100046:	68 60 d6 10 80       	push   $0x8010d660
8010004b:	e8 18 52 00 00       	call   80105268 <initlock>
80100050:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100053:	c7 05 ac 1d 11 80 5c 	movl   $0x80111d5c,0x80111dac
8010005a:	1d 11 80 
  bcache.head.next = &bcache.head;
8010005d:	c7 05 b0 1d 11 80 5c 	movl   $0x80111d5c,0x80111db0
80100064:	1d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100067:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
8010006e:	eb 47                	jmp    801000b7 <binit+0x83>
    b->next = bcache.head.next;
80100070:	8b 15 b0 1d 11 80    	mov    0x80111db0,%edx
80100076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100079:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
8010007c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007f:	c7 40 50 5c 1d 11 80 	movl   $0x80111d5c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100089:	83 c0 0c             	add    $0xc,%eax
8010008c:	83 ec 08             	sub    $0x8,%esp
8010008f:	68 53 90 10 80       	push   $0x80109053
80100094:	50                   	push   %eax
80100095:	e8 3b 50 00 00       	call   801050d5 <initsleeplock>
8010009a:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
8010009d:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
801000a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a5:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	a3 b0 1d 11 80       	mov    %eax,0x80111db0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b0:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b7:	b8 5c 1d 11 80       	mov    $0x80111d5c,%eax
801000bc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bf:	72 af                	jb     80100070 <binit+0x3c>
  }
}
801000c1:	90                   	nop
801000c2:	90                   	nop
801000c3:	c9                   	leave  
801000c4:	c3                   	ret    

801000c5 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c5:	f3 0f 1e fb          	endbr32 
801000c9:	55                   	push   %ebp
801000ca:	89 e5                	mov    %esp,%ebp
801000cc:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000cf:	83 ec 0c             	sub    $0xc,%esp
801000d2:	68 60 d6 10 80       	push   $0x8010d660
801000d7:	e8 b2 51 00 00       	call   8010528e <acquire>
801000dc:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000df:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
801000e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000e7:	eb 58                	jmp    80100141 <bget+0x7c>
    if(b->dev == dev && b->blockno == blockno){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 40 04             	mov    0x4(%eax),%eax
801000ef:	39 45 08             	cmp    %eax,0x8(%ebp)
801000f2:	75 44                	jne    80100138 <bget+0x73>
801000f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f7:	8b 40 08             	mov    0x8(%eax),%eax
801000fa:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000fd:	75 39                	jne    80100138 <bget+0x73>
      b->refcnt++;
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	8b 40 4c             	mov    0x4c(%eax),%eax
80100105:	8d 50 01             	lea    0x1(%eax),%edx
80100108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010b:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
8010010e:	83 ec 0c             	sub    $0xc,%esp
80100111:	68 60 d6 10 80       	push   $0x8010d660
80100116:	e8 e5 51 00 00       	call   80105300 <release>
8010011b:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	83 c0 0c             	add    $0xc,%eax
80100124:	83 ec 0c             	sub    $0xc,%esp
80100127:	50                   	push   %eax
80100128:	e8 e8 4f 00 00       	call   80105115 <acquiresleep>
8010012d:	83 c4 10             	add    $0x10,%esp
      return b;
80100130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100133:	e9 9d 00 00 00       	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013b:	8b 40 54             	mov    0x54(%eax),%eax
8010013e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100141:	81 7d f4 5c 1d 11 80 	cmpl   $0x80111d5c,-0xc(%ebp)
80100148:	75 9f                	jne    801000e9 <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010014a:	a1 ac 1d 11 80       	mov    0x80111dac,%eax
8010014f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100152:	eb 6b                	jmp    801001bf <bget+0xfa>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100157:	8b 40 4c             	mov    0x4c(%eax),%eax
8010015a:	85 c0                	test   %eax,%eax
8010015c:	75 58                	jne    801001b6 <bget+0xf1>
8010015e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100161:	8b 00                	mov    (%eax),%eax
80100163:	83 e0 04             	and    $0x4,%eax
80100166:	85 c0                	test   %eax,%eax
80100168:	75 4c                	jne    801001b6 <bget+0xf1>
      b->dev = dev;
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 55 08             	mov    0x8(%ebp),%edx
80100170:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100176:	8b 55 0c             	mov    0xc(%ebp),%edx
80100179:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
8010017c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
80100185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100188:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
8010018f:	83 ec 0c             	sub    $0xc,%esp
80100192:	68 60 d6 10 80       	push   $0x8010d660
80100197:	e8 64 51 00 00       	call   80105300 <release>
8010019c:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010019f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a2:	83 c0 0c             	add    $0xc,%eax
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	50                   	push   %eax
801001a9:	e8 67 4f 00 00       	call   80105115 <acquiresleep>
801001ae:	83 c4 10             	add    $0x10,%esp
      return b;
801001b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b4:	eb 1f                	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b9:	8b 40 50             	mov    0x50(%eax),%eax
801001bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001bf:	81 7d f4 5c 1d 11 80 	cmpl   $0x80111d5c,-0xc(%ebp)
801001c6:	75 8c                	jne    80100154 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 5a 90 10 80       	push   $0x8010905a
801001d0:	e8 33 04 00 00       	call   80100608 <panic>
}
801001d5:	c9                   	leave  
801001d6:	c3                   	ret    

801001d7 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001d7:	f3 0f 1e fb          	endbr32 
801001db:	55                   	push   %ebp
801001dc:	89 e5                	mov    %esp,%ebp
801001de:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001e1:	83 ec 08             	sub    $0x8,%esp
801001e4:	ff 75 0c             	pushl  0xc(%ebp)
801001e7:	ff 75 08             	pushl  0x8(%ebp)
801001ea:	e8 d6 fe ff ff       	call   801000c5 <bget>
801001ef:	83 c4 10             	add    $0x10,%esp
801001f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 02             	and    $0x2,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0e                	jne    8010020f <bread+0x38>
    iderw(b);
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	ff 75 f4             	pushl  -0xc(%ebp)
80100207:	e8 8d 28 00 00       	call   80102a99 <iderw>
8010020c:	83 c4 10             	add    $0x10,%esp
  }
  return b;
8010020f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100212:	c9                   	leave  
80100213:	c3                   	ret    

80100214 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100214:	f3 0f 1e fb          	endbr32 
80100218:	55                   	push   %ebp
80100219:	89 e5                	mov    %esp,%ebp
8010021b:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010021e:	8b 45 08             	mov    0x8(%ebp),%eax
80100221:	83 c0 0c             	add    $0xc,%eax
80100224:	83 ec 0c             	sub    $0xc,%esp
80100227:	50                   	push   %eax
80100228:	e8 a2 4f 00 00       	call   801051cf <holdingsleep>
8010022d:	83 c4 10             	add    $0x10,%esp
80100230:	85 c0                	test   %eax,%eax
80100232:	75 0d                	jne    80100241 <bwrite+0x2d>
    panic("bwrite");
80100234:	83 ec 0c             	sub    $0xc,%esp
80100237:	68 6b 90 10 80       	push   $0x8010906b
8010023c:	e8 c7 03 00 00       	call   80100608 <panic>
  b->flags |= B_DIRTY;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 00                	mov    (%eax),%eax
80100246:	83 c8 04             	or     $0x4,%eax
80100249:	89 c2                	mov    %eax,%edx
8010024b:	8b 45 08             	mov    0x8(%ebp),%eax
8010024e:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100250:	83 ec 0c             	sub    $0xc,%esp
80100253:	ff 75 08             	pushl  0x8(%ebp)
80100256:	e8 3e 28 00 00       	call   80102a99 <iderw>
8010025b:	83 c4 10             	add    $0x10,%esp
}
8010025e:	90                   	nop
8010025f:	c9                   	leave  
80100260:	c3                   	ret    

80100261 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100261:	f3 0f 1e fb          	endbr32 
80100265:	55                   	push   %ebp
80100266:	89 e5                	mov    %esp,%ebp
80100268:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	83 c0 0c             	add    $0xc,%eax
80100271:	83 ec 0c             	sub    $0xc,%esp
80100274:	50                   	push   %eax
80100275:	e8 55 4f 00 00       	call   801051cf <holdingsleep>
8010027a:	83 c4 10             	add    $0x10,%esp
8010027d:	85 c0                	test   %eax,%eax
8010027f:	75 0d                	jne    8010028e <brelse+0x2d>
    panic("brelse");
80100281:	83 ec 0c             	sub    $0xc,%esp
80100284:	68 72 90 10 80       	push   $0x80109072
80100289:	e8 7a 03 00 00       	call   80100608 <panic>

  releasesleep(&b->lock);
8010028e:	8b 45 08             	mov    0x8(%ebp),%eax
80100291:	83 c0 0c             	add    $0xc,%eax
80100294:	83 ec 0c             	sub    $0xc,%esp
80100297:	50                   	push   %eax
80100298:	e8 e0 4e 00 00       	call   8010517d <releasesleep>
8010029d:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	68 60 d6 10 80       	push   $0x8010d660
801002a8:	e8 e1 4f 00 00       	call   8010528e <acquire>
801002ad:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002b0:	8b 45 08             	mov    0x8(%ebp),%eax
801002b3:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b6:	8d 50 ff             	lea    -0x1(%eax),%edx
801002b9:	8b 45 08             	mov    0x8(%ebp),%eax
801002bc:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002bf:	8b 45 08             	mov    0x8(%ebp),%eax
801002c2:	8b 40 4c             	mov    0x4c(%eax),%eax
801002c5:	85 c0                	test   %eax,%eax
801002c7:	75 47                	jne    80100310 <brelse+0xaf>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002c9:	8b 45 08             	mov    0x8(%ebp),%eax
801002cc:	8b 40 54             	mov    0x54(%eax),%eax
801002cf:	8b 55 08             	mov    0x8(%ebp),%edx
801002d2:	8b 52 50             	mov    0x50(%edx),%edx
801002d5:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002d8:	8b 45 08             	mov    0x8(%ebp),%eax
801002db:	8b 40 50             	mov    0x50(%eax),%eax
801002de:	8b 55 08             	mov    0x8(%ebp),%edx
801002e1:	8b 52 54             	mov    0x54(%edx),%edx
801002e4:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002e7:	8b 15 b0 1d 11 80    	mov    0x80111db0,%edx
801002ed:	8b 45 08             	mov    0x8(%ebp),%eax
801002f0:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002f3:	8b 45 08             	mov    0x8(%ebp),%eax
801002f6:	c7 40 50 5c 1d 11 80 	movl   $0x80111d5c,0x50(%eax)
    bcache.head.next->prev = b;
801002fd:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
80100302:	8b 55 08             	mov    0x8(%ebp),%edx
80100305:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100308:	8b 45 08             	mov    0x8(%ebp),%eax
8010030b:	a3 b0 1d 11 80       	mov    %eax,0x80111db0
  }
  
  release(&bcache.lock);
80100310:	83 ec 0c             	sub    $0xc,%esp
80100313:	68 60 d6 10 80       	push   $0x8010d660
80100318:	e8 e3 4f 00 00       	call   80105300 <release>
8010031d:	83 c4 10             	add    $0x10,%esp
}
80100320:	90                   	nop
80100321:	c9                   	leave  
80100322:	c3                   	ret    

80100323 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80100323:	55                   	push   %ebp
80100324:	89 e5                	mov    %esp,%ebp
80100326:	83 ec 14             	sub    $0x14,%esp
80100329:	8b 45 08             	mov    0x8(%ebp),%eax
8010032c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100330:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100334:	89 c2                	mov    %eax,%edx
80100336:	ec                   	in     (%dx),%al
80100337:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010033a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010033e:	c9                   	leave  
8010033f:	c3                   	ret    

80100340 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80100340:	55                   	push   %ebp
80100341:	89 e5                	mov    %esp,%ebp
80100343:	83 ec 08             	sub    $0x8,%esp
80100346:	8b 45 08             	mov    0x8(%ebp),%eax
80100349:	8b 55 0c             	mov    0xc(%ebp),%edx
8010034c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100350:	89 d0                	mov    %edx,%eax
80100352:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100355:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100359:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010035d:	ee                   	out    %al,(%dx)
}
8010035e:	90                   	nop
8010035f:	c9                   	leave  
80100360:	c3                   	ret    

80100361 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100361:	55                   	push   %ebp
80100362:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100364:	fa                   	cli    
}
80100365:	90                   	nop
80100366:	5d                   	pop    %ebp
80100367:	c3                   	ret    

80100368 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100368:	f3 0f 1e fb          	endbr32 
8010036c:	55                   	push   %ebp
8010036d:	89 e5                	mov    %esp,%ebp
8010036f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100372:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100376:	74 1c                	je     80100394 <printint+0x2c>
80100378:	8b 45 08             	mov    0x8(%ebp),%eax
8010037b:	c1 e8 1f             	shr    $0x1f,%eax
8010037e:	0f b6 c0             	movzbl %al,%eax
80100381:	89 45 10             	mov    %eax,0x10(%ebp)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 0a                	je     80100394 <printint+0x2c>
    x = -xx;
8010038a:	8b 45 08             	mov    0x8(%ebp),%eax
8010038d:	f7 d8                	neg    %eax
8010038f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100392:	eb 06                	jmp    8010039a <printint+0x32>
  else
    x = xx;
80100394:	8b 45 08             	mov    0x8(%ebp),%eax
80100397:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010039a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
801003a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a7:	ba 00 00 00 00       	mov    $0x0,%edx
801003ac:	f7 f1                	div    %ecx
801003ae:	89 d1                	mov    %edx,%ecx
801003b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003b3:	8d 50 01             	lea    0x1(%eax),%edx
801003b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003b9:	0f b6 91 04 a0 10 80 	movzbl -0x7fef5ffc(%ecx),%edx
801003c0:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003ca:	ba 00 00 00 00       	mov    $0x0,%edx
801003cf:	f7 f1                	div    %ecx
801003d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003d8:	75 c7                	jne    801003a1 <printint+0x39>

  if(sign)
801003da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003de:	74 2a                	je     8010040a <printint+0xa2>
    buf[i++] = '-';
801003e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003e3:	8d 50 01             	lea    0x1(%eax),%edx
801003e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003e9:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ee:	eb 1a                	jmp    8010040a <printint+0xa2>
    consputc(buf[i]);
801003f0:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003f6:	01 d0                	add    %edx,%eax
801003f8:	0f b6 00             	movzbl (%eax),%eax
801003fb:	0f be c0             	movsbl %al,%eax
801003fe:	83 ec 0c             	sub    $0xc,%esp
80100401:	50                   	push   %eax
80100402:	e8 36 04 00 00       	call   8010083d <consputc>
80100407:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
8010040a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010040e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100412:	79 dc                	jns    801003f0 <printint+0x88>
}
80100414:	90                   	nop
80100415:	90                   	nop
80100416:	c9                   	leave  
80100417:	c3                   	ret    

80100418 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100418:	f3 0f 1e fb          	endbr32 
8010041c:	55                   	push   %ebp
8010041d:	89 e5                	mov    %esp,%ebp
8010041f:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100422:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
80100427:	89 45 e8             	mov    %eax,-0x18(%ebp)
  //changed: added holding check
  if(locking && !holding(&cons.lock))
8010042a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010042e:	74 24                	je     80100454 <cprintf+0x3c>
80100430:	83 ec 0c             	sub    $0xc,%esp
80100433:	68 c0 c5 10 80       	push   $0x8010c5c0
80100438:	e8 98 4f 00 00       	call   801053d5 <holding>
8010043d:	83 c4 10             	add    $0x10,%esp
80100440:	85 c0                	test   %eax,%eax
80100442:	75 10                	jne    80100454 <cprintf+0x3c>
    acquire(&cons.lock);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	68 c0 c5 10 80       	push   $0x8010c5c0
8010044c:	e8 3d 4e 00 00       	call   8010528e <acquire>
80100451:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100454:	8b 45 08             	mov    0x8(%ebp),%eax
80100457:	85 c0                	test   %eax,%eax
80100459:	75 0d                	jne    80100468 <cprintf+0x50>
    panic("null fmt");
8010045b:	83 ec 0c             	sub    $0xc,%esp
8010045e:	68 7c 90 10 80       	push   $0x8010907c
80100463:	e8 a0 01 00 00       	call   80100608 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100468:	8d 45 0c             	lea    0xc(%ebp),%eax
8010046b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010046e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100475:	e9 52 01 00 00       	jmp    801005cc <cprintf+0x1b4>
    if(c != '%'){
8010047a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010047e:	74 13                	je     80100493 <cprintf+0x7b>
      consputc(c);
80100480:	83 ec 0c             	sub    $0xc,%esp
80100483:	ff 75 e4             	pushl  -0x1c(%ebp)
80100486:	e8 b2 03 00 00       	call   8010083d <consputc>
8010048b:	83 c4 10             	add    $0x10,%esp
      continue;
8010048e:	e9 35 01 00 00       	jmp    801005c8 <cprintf+0x1b0>
    }
    c = fmt[++i] & 0xff;
80100493:	8b 55 08             	mov    0x8(%ebp),%edx
80100496:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010049a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010049d:	01 d0                	add    %edx,%eax
8010049f:	0f b6 00             	movzbl (%eax),%eax
801004a2:	0f be c0             	movsbl %al,%eax
801004a5:	25 ff 00 00 00       	and    $0xff,%eax
801004aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
801004ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801004b1:	0f 84 37 01 00 00    	je     801005ee <cprintf+0x1d6>
      break;
    switch(c){
801004b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004bb:	0f 84 dc 00 00 00    	je     8010059d <cprintf+0x185>
801004c1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004c5:	0f 8c e1 00 00 00    	jl     801005ac <cprintf+0x194>
801004cb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
801004cf:	0f 8f d7 00 00 00    	jg     801005ac <cprintf+0x194>
801004d5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
801004d9:	0f 8c cd 00 00 00    	jl     801005ac <cprintf+0x194>
801004df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004e2:	83 e8 63             	sub    $0x63,%eax
801004e5:	83 f8 15             	cmp    $0x15,%eax
801004e8:	0f 87 be 00 00 00    	ja     801005ac <cprintf+0x194>
801004ee:	8b 04 85 8c 90 10 80 	mov    -0x7fef6f74(,%eax,4),%eax
801004f5:	3e ff e0             	notrack jmp *%eax
    case 'd':
      printint(*argp++, 10, 1);
801004f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fb:	8d 50 04             	lea    0x4(%eax),%edx
801004fe:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100501:	8b 00                	mov    (%eax),%eax
80100503:	83 ec 04             	sub    $0x4,%esp
80100506:	6a 01                	push   $0x1
80100508:	6a 0a                	push   $0xa
8010050a:	50                   	push   %eax
8010050b:	e8 58 fe ff ff       	call   80100368 <printint>
80100510:	83 c4 10             	add    $0x10,%esp
      break;
80100513:	e9 b0 00 00 00       	jmp    801005c8 <cprintf+0x1b0>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010051b:	8d 50 04             	lea    0x4(%eax),%edx
8010051e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100521:	8b 00                	mov    (%eax),%eax
80100523:	83 ec 04             	sub    $0x4,%esp
80100526:	6a 00                	push   $0x0
80100528:	6a 10                	push   $0x10
8010052a:	50                   	push   %eax
8010052b:	e8 38 fe ff ff       	call   80100368 <printint>
80100530:	83 c4 10             	add    $0x10,%esp
      break;
80100533:	e9 90 00 00 00       	jmp    801005c8 <cprintf+0x1b0>
    case 's':
      if((s = (char*)*argp++) == 0)
80100538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010053b:	8d 50 04             	lea    0x4(%eax),%edx
8010053e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100541:	8b 00                	mov    (%eax),%eax
80100543:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100546:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010054a:	75 22                	jne    8010056e <cprintf+0x156>
        s = "(null)";
8010054c:	c7 45 ec 85 90 10 80 	movl   $0x80109085,-0x14(%ebp)
      for(; *s; s++)
80100553:	eb 19                	jmp    8010056e <cprintf+0x156>
        consputc(*s);
80100555:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f be c0             	movsbl %al,%eax
8010055e:	83 ec 0c             	sub    $0xc,%esp
80100561:	50                   	push   %eax
80100562:	e8 d6 02 00 00       	call   8010083d <consputc>
80100567:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010056a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010056e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100571:	0f b6 00             	movzbl (%eax),%eax
80100574:	84 c0                	test   %al,%al
80100576:	75 dd                	jne    80100555 <cprintf+0x13d>
      break;
80100578:	eb 4e                	jmp    801005c8 <cprintf+0x1b0>
    case 'c':
      s = (char*)argp++;
8010057a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010057d:	8d 50 04             	lea    0x4(%eax),%edx
80100580:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100583:	89 45 ec             	mov    %eax,-0x14(%ebp)
      consputc(*(s));
80100586:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100589:	0f b6 00             	movzbl (%eax),%eax
8010058c:	0f be c0             	movsbl %al,%eax
8010058f:	83 ec 0c             	sub    $0xc,%esp
80100592:	50                   	push   %eax
80100593:	e8 a5 02 00 00       	call   8010083d <consputc>
80100598:	83 c4 10             	add    $0x10,%esp
      break;
8010059b:	eb 2b                	jmp    801005c8 <cprintf+0x1b0>
    case '%':
      consputc('%');
8010059d:	83 ec 0c             	sub    $0xc,%esp
801005a0:	6a 25                	push   $0x25
801005a2:	e8 96 02 00 00       	call   8010083d <consputc>
801005a7:	83 c4 10             	add    $0x10,%esp
      break;
801005aa:	eb 1c                	jmp    801005c8 <cprintf+0x1b0>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801005ac:	83 ec 0c             	sub    $0xc,%esp
801005af:	6a 25                	push   $0x25
801005b1:	e8 87 02 00 00       	call   8010083d <consputc>
801005b6:	83 c4 10             	add    $0x10,%esp
      consputc(c);
801005b9:	83 ec 0c             	sub    $0xc,%esp
801005bc:	ff 75 e4             	pushl  -0x1c(%ebp)
801005bf:	e8 79 02 00 00       	call   8010083d <consputc>
801005c4:	83 c4 10             	add    $0x10,%esp
      break;
801005c7:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801005c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005cc:	8b 55 08             	mov    0x8(%ebp),%edx
801005cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d2:	01 d0                	add    %edx,%eax
801005d4:	0f b6 00             	movzbl (%eax),%eax
801005d7:	0f be c0             	movsbl %al,%eax
801005da:	25 ff 00 00 00       	and    $0xff,%eax
801005df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801005e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005e6:	0f 85 8e fe ff ff    	jne    8010047a <cprintf+0x62>
801005ec:	eb 01                	jmp    801005ef <cprintf+0x1d7>
      break;
801005ee:	90                   	nop
    }
  }

  if(locking)
801005ef:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005f3:	74 10                	je     80100605 <cprintf+0x1ed>
    release(&cons.lock);
801005f5:	83 ec 0c             	sub    $0xc,%esp
801005f8:	68 c0 c5 10 80       	push   $0x8010c5c0
801005fd:	e8 fe 4c 00 00       	call   80105300 <release>
80100602:	83 c4 10             	add    $0x10,%esp
}
80100605:	90                   	nop
80100606:	c9                   	leave  
80100607:	c3                   	ret    

80100608 <panic>:

void
panic(char *s)
{
80100608:	f3 0f 1e fb          	endbr32 
8010060c:	55                   	push   %ebp
8010060d:	89 e5                	mov    %esp,%ebp
8010060f:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
80100612:	e8 4a fd ff ff       	call   80100361 <cli>
  cons.locking = 0;
80100617:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
8010061e:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100621:	e8 3f 2b 00 00       	call   80103165 <lapicid>
80100626:	83 ec 08             	sub    $0x8,%esp
80100629:	50                   	push   %eax
8010062a:	68 e4 90 10 80       	push   $0x801090e4
8010062f:	e8 e4 fd ff ff       	call   80100418 <cprintf>
80100634:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100637:	8b 45 08             	mov    0x8(%ebp),%eax
8010063a:	83 ec 0c             	sub    $0xc,%esp
8010063d:	50                   	push   %eax
8010063e:	e8 d5 fd ff ff       	call   80100418 <cprintf>
80100643:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80100646:	83 ec 0c             	sub    $0xc,%esp
80100649:	68 f8 90 10 80       	push   $0x801090f8
8010064e:	e8 c5 fd ff ff       	call   80100418 <cprintf>
80100653:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100656:	83 ec 08             	sub    $0x8,%esp
80100659:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010065c:	50                   	push   %eax
8010065d:	8d 45 08             	lea    0x8(%ebp),%eax
80100660:	50                   	push   %eax
80100661:	e8 f0 4c 00 00       	call   80105356 <getcallerpcs>
80100666:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100670:	eb 1c                	jmp    8010068e <panic+0x86>
    cprintf(" %p", pcs[i]);
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100679:	83 ec 08             	sub    $0x8,%esp
8010067c:	50                   	push   %eax
8010067d:	68 fa 90 10 80       	push   $0x801090fa
80100682:	e8 91 fd ff ff       	call   80100418 <cprintf>
80100687:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010068a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010068e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100692:	7e de                	jle    80100672 <panic+0x6a>
  panicked = 1; // freeze other CPU
80100694:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
8010069b:	00 00 00 
  for(;;)
8010069e:	eb fe                	jmp    8010069e <panic+0x96>

801006a0 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801006a0:	f3 0f 1e fb          	endbr32 
801006a4:	55                   	push   %ebp
801006a5:	89 e5                	mov    %esp,%ebp
801006a7:	53                   	push   %ebx
801006a8:	83 ec 14             	sub    $0x14,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801006ab:	6a 0e                	push   $0xe
801006ad:	68 d4 03 00 00       	push   $0x3d4
801006b2:	e8 89 fc ff ff       	call   80100340 <outb>
801006b7:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
801006ba:	68 d5 03 00 00       	push   $0x3d5
801006bf:	e8 5f fc ff ff       	call   80100323 <inb>
801006c4:	83 c4 04             	add    $0x4,%esp
801006c7:	0f b6 c0             	movzbl %al,%eax
801006ca:	c1 e0 08             	shl    $0x8,%eax
801006cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801006d0:	6a 0f                	push   $0xf
801006d2:	68 d4 03 00 00       	push   $0x3d4
801006d7:	e8 64 fc ff ff       	call   80100340 <outb>
801006dc:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
801006df:	68 d5 03 00 00       	push   $0x3d5
801006e4:	e8 3a fc ff ff       	call   80100323 <inb>
801006e9:	83 c4 04             	add    $0x4,%esp
801006ec:	0f b6 c0             	movzbl %al,%eax
801006ef:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
801006f2:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
801006f6:	75 30                	jne    80100728 <cgaputc+0x88>
    pos += 80 - pos%80;
801006f8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fb:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100700:	89 c8                	mov    %ecx,%eax
80100702:	f7 ea                	imul   %edx
80100704:	c1 fa 05             	sar    $0x5,%edx
80100707:	89 c8                	mov    %ecx,%eax
80100709:	c1 f8 1f             	sar    $0x1f,%eax
8010070c:	29 c2                	sub    %eax,%edx
8010070e:	89 d0                	mov    %edx,%eax
80100710:	c1 e0 02             	shl    $0x2,%eax
80100713:	01 d0                	add    %edx,%eax
80100715:	c1 e0 04             	shl    $0x4,%eax
80100718:	29 c1                	sub    %eax,%ecx
8010071a:	89 ca                	mov    %ecx,%edx
8010071c:	b8 50 00 00 00       	mov    $0x50,%eax
80100721:	29 d0                	sub    %edx,%eax
80100723:	01 45 f4             	add    %eax,-0xc(%ebp)
80100726:	eb 38                	jmp    80100760 <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100728:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010072f:	75 0c                	jne    8010073d <cgaputc+0x9d>
    if(pos > 0) --pos;
80100731:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100735:	7e 29                	jle    80100760 <cgaputc+0xc0>
80100737:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010073b:	eb 23                	jmp    80100760 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010073d:	8b 45 08             	mov    0x8(%ebp),%eax
80100740:	0f b6 c0             	movzbl %al,%eax
80100743:	80 cc 07             	or     $0x7,%ah
80100746:	89 c3                	mov    %eax,%ebx
80100748:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010074e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100751:	8d 50 01             	lea    0x1(%eax),%edx
80100754:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100757:	01 c0                	add    %eax,%eax
80100759:	01 c8                	add    %ecx,%eax
8010075b:	89 da                	mov    %ebx,%edx
8010075d:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
80100760:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100764:	78 09                	js     8010076f <cgaputc+0xcf>
80100766:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
8010076d:	7e 0d                	jle    8010077c <cgaputc+0xdc>
    panic("pos under/overflow");
8010076f:	83 ec 0c             	sub    $0xc,%esp
80100772:	68 fe 90 10 80       	push   $0x801090fe
80100777:	e8 8c fe ff ff       	call   80100608 <panic>

  if((pos/80) >= 24){  // Scroll up.
8010077c:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100783:	7e 4c                	jle    801007d1 <cgaputc+0x131>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100785:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010078a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100790:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100795:	83 ec 04             	sub    $0x4,%esp
80100798:	68 60 0e 00 00       	push   $0xe60
8010079d:	52                   	push   %edx
8010079e:	50                   	push   %eax
8010079f:	e8 50 4e 00 00       	call   801055f4 <memmove>
801007a4:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801007a7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801007ab:	b8 80 07 00 00       	mov    $0x780,%eax
801007b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801007b3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801007b6:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801007bb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801007be:	01 c9                	add    %ecx,%ecx
801007c0:	01 c8                	add    %ecx,%eax
801007c2:	83 ec 04             	sub    $0x4,%esp
801007c5:	52                   	push   %edx
801007c6:	6a 00                	push   $0x0
801007c8:	50                   	push   %eax
801007c9:	e8 5f 4d 00 00       	call   8010552d <memset>
801007ce:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
801007d1:	83 ec 08             	sub    $0x8,%esp
801007d4:	6a 0e                	push   $0xe
801007d6:	68 d4 03 00 00       	push   $0x3d4
801007db:	e8 60 fb ff ff       	call   80100340 <outb>
801007e0:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
801007e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007e6:	c1 f8 08             	sar    $0x8,%eax
801007e9:	0f b6 c0             	movzbl %al,%eax
801007ec:	83 ec 08             	sub    $0x8,%esp
801007ef:	50                   	push   %eax
801007f0:	68 d5 03 00 00       	push   $0x3d5
801007f5:	e8 46 fb ff ff       	call   80100340 <outb>
801007fa:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
801007fd:	83 ec 08             	sub    $0x8,%esp
80100800:	6a 0f                	push   $0xf
80100802:	68 d4 03 00 00       	push   $0x3d4
80100807:	e8 34 fb ff ff       	call   80100340 <outb>
8010080c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100812:	0f b6 c0             	movzbl %al,%eax
80100815:	83 ec 08             	sub    $0x8,%esp
80100818:	50                   	push   %eax
80100819:	68 d5 03 00 00       	push   $0x3d5
8010081e:	e8 1d fb ff ff       	call   80100340 <outb>
80100823:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100826:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010082b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010082e:	01 d2                	add    %edx,%edx
80100830:	01 d0                	add    %edx,%eax
80100832:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100837:	90                   	nop
80100838:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010083b:	c9                   	leave  
8010083c:	c3                   	ret    

8010083d <consputc>:

void
consputc(int c)
{
8010083d:	f3 0f 1e fb          	endbr32 
80100841:	55                   	push   %ebp
80100842:	89 e5                	mov    %esp,%ebp
80100844:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100847:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
8010084c:	85 c0                	test   %eax,%eax
8010084e:	74 07                	je     80100857 <consputc+0x1a>
    cli();
80100850:	e8 0c fb ff ff       	call   80100361 <cli>
    for(;;)
80100855:	eb fe                	jmp    80100855 <consputc+0x18>
      ;
  }

  if(c == BACKSPACE){
80100857:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010085e:	75 29                	jne    80100889 <consputc+0x4c>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100860:	83 ec 0c             	sub    $0xc,%esp
80100863:	6a 08                	push   $0x8
80100865:	e8 c6 67 00 00       	call   80107030 <uartputc>
8010086a:	83 c4 10             	add    $0x10,%esp
8010086d:	83 ec 0c             	sub    $0xc,%esp
80100870:	6a 20                	push   $0x20
80100872:	e8 b9 67 00 00       	call   80107030 <uartputc>
80100877:	83 c4 10             	add    $0x10,%esp
8010087a:	83 ec 0c             	sub    $0xc,%esp
8010087d:	6a 08                	push   $0x8
8010087f:	e8 ac 67 00 00       	call   80107030 <uartputc>
80100884:	83 c4 10             	add    $0x10,%esp
80100887:	eb 0e                	jmp    80100897 <consputc+0x5a>
  } else
    uartputc(c);
80100889:	83 ec 0c             	sub    $0xc,%esp
8010088c:	ff 75 08             	pushl  0x8(%ebp)
8010088f:	e8 9c 67 00 00       	call   80107030 <uartputc>
80100894:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100897:	83 ec 0c             	sub    $0xc,%esp
8010089a:	ff 75 08             	pushl  0x8(%ebp)
8010089d:	e8 fe fd ff ff       	call   801006a0 <cgaputc>
801008a2:	83 c4 10             	add    $0x10,%esp
}
801008a5:	90                   	nop
801008a6:	c9                   	leave  
801008a7:	c3                   	ret    

801008a8 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801008a8:	f3 0f 1e fb          	endbr32 
801008ac:	55                   	push   %ebp
801008ad:	89 e5                	mov    %esp,%ebp
801008af:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801008b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801008b9:	83 ec 0c             	sub    $0xc,%esp
801008bc:	68 c0 c5 10 80       	push   $0x8010c5c0
801008c1:	e8 c8 49 00 00       	call   8010528e <acquire>
801008c6:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801008c9:	e9 52 01 00 00       	jmp    80100a20 <consoleintr+0x178>
    switch(c){
801008ce:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801008d2:	0f 84 81 00 00 00    	je     80100959 <consoleintr+0xb1>
801008d8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801008dc:	0f 8f ac 00 00 00    	jg     8010098e <consoleintr+0xe6>
801008e2:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008e6:	74 43                	je     8010092b <consoleintr+0x83>
801008e8:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008ec:	0f 8f 9c 00 00 00    	jg     8010098e <consoleintr+0xe6>
801008f2:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
801008f6:	74 61                	je     80100959 <consoleintr+0xb1>
801008f8:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
801008fc:	0f 85 8c 00 00 00    	jne    8010098e <consoleintr+0xe6>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100902:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100909:	e9 12 01 00 00       	jmp    80100a20 <consoleintr+0x178>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010090e:	a1 48 20 11 80       	mov    0x80112048,%eax
80100913:	83 e8 01             	sub    $0x1,%eax
80100916:	a3 48 20 11 80       	mov    %eax,0x80112048
        consputc(BACKSPACE);
8010091b:	83 ec 0c             	sub    $0xc,%esp
8010091e:	68 00 01 00 00       	push   $0x100
80100923:	e8 15 ff ff ff       	call   8010083d <consputc>
80100928:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
8010092b:	8b 15 48 20 11 80    	mov    0x80112048,%edx
80100931:	a1 44 20 11 80       	mov    0x80112044,%eax
80100936:	39 c2                	cmp    %eax,%edx
80100938:	0f 84 e2 00 00 00    	je     80100a20 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010093e:	a1 48 20 11 80       	mov    0x80112048,%eax
80100943:	83 e8 01             	sub    $0x1,%eax
80100946:	83 e0 7f             	and    $0x7f,%eax
80100949:	0f b6 80 c0 1f 11 80 	movzbl -0x7feee040(%eax),%eax
      while(input.e != input.w &&
80100950:	3c 0a                	cmp    $0xa,%al
80100952:	75 ba                	jne    8010090e <consoleintr+0x66>
      }
      break;
80100954:	e9 c7 00 00 00       	jmp    80100a20 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100959:	8b 15 48 20 11 80    	mov    0x80112048,%edx
8010095f:	a1 44 20 11 80       	mov    0x80112044,%eax
80100964:	39 c2                	cmp    %eax,%edx
80100966:	0f 84 b4 00 00 00    	je     80100a20 <consoleintr+0x178>
        input.e--;
8010096c:	a1 48 20 11 80       	mov    0x80112048,%eax
80100971:	83 e8 01             	sub    $0x1,%eax
80100974:	a3 48 20 11 80       	mov    %eax,0x80112048
        consputc(BACKSPACE);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 00 01 00 00       	push   $0x100
80100981:	e8 b7 fe ff ff       	call   8010083d <consputc>
80100986:	83 c4 10             	add    $0x10,%esp
      }
      break;
80100989:	e9 92 00 00 00       	jmp    80100a20 <consoleintr+0x178>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010098e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100992:	0f 84 87 00 00 00    	je     80100a1f <consoleintr+0x177>
80100998:	8b 15 48 20 11 80    	mov    0x80112048,%edx
8010099e:	a1 40 20 11 80       	mov    0x80112040,%eax
801009a3:	29 c2                	sub    %eax,%edx
801009a5:	89 d0                	mov    %edx,%eax
801009a7:	83 f8 7f             	cmp    $0x7f,%eax
801009aa:	77 73                	ja     80100a1f <consoleintr+0x177>
        c = (c == '\r') ? '\n' : c;
801009ac:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801009b0:	74 05                	je     801009b7 <consoleintr+0x10f>
801009b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009b5:	eb 05                	jmp    801009bc <consoleintr+0x114>
801009b7:	b8 0a 00 00 00       	mov    $0xa,%eax
801009bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801009bf:	a1 48 20 11 80       	mov    0x80112048,%eax
801009c4:	8d 50 01             	lea    0x1(%eax),%edx
801009c7:	89 15 48 20 11 80    	mov    %edx,0x80112048
801009cd:	83 e0 7f             	and    $0x7f,%eax
801009d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009d3:	88 90 c0 1f 11 80    	mov    %dl,-0x7feee040(%eax)
        consputc(c);
801009d9:	83 ec 0c             	sub    $0xc,%esp
801009dc:	ff 75 f0             	pushl  -0x10(%ebp)
801009df:	e8 59 fe ff ff       	call   8010083d <consputc>
801009e4:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009e7:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009eb:	74 18                	je     80100a05 <consoleintr+0x15d>
801009ed:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009f1:	74 12                	je     80100a05 <consoleintr+0x15d>
801009f3:	a1 48 20 11 80       	mov    0x80112048,%eax
801009f8:	8b 15 40 20 11 80    	mov    0x80112040,%edx
801009fe:	83 ea 80             	sub    $0xffffff80,%edx
80100a01:	39 d0                	cmp    %edx,%eax
80100a03:	75 1a                	jne    80100a1f <consoleintr+0x177>
          input.w = input.e;
80100a05:	a1 48 20 11 80       	mov    0x80112048,%eax
80100a0a:	a3 44 20 11 80       	mov    %eax,0x80112044
          wakeup(&input.r);
80100a0f:	83 ec 0c             	sub    $0xc,%esp
80100a12:	68 40 20 11 80       	push   $0x80112040
80100a17:	e8 f2 44 00 00       	call   80104f0e <wakeup>
80100a1c:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100a1f:	90                   	nop
  while((c = getc()) >= 0){
80100a20:	8b 45 08             	mov    0x8(%ebp),%eax
80100a23:	ff d0                	call   *%eax
80100a25:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100a28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a2c:	0f 89 9c fe ff ff    	jns    801008ce <consoleintr+0x26>
    }
  }
  release(&cons.lock);
80100a32:	83 ec 0c             	sub    $0xc,%esp
80100a35:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a3a:	e8 c1 48 00 00       	call   80105300 <release>
80100a3f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100a42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a46:	74 05                	je     80100a4d <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
80100a48:	e8 87 45 00 00       	call   80104fd4 <procdump>
  }
}
80100a4d:	90                   	nop
80100a4e:	c9                   	leave  
80100a4f:	c3                   	ret    

80100a50 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a50:	f3 0f 1e fb          	endbr32 
80100a54:	55                   	push   %ebp
80100a55:	89 e5                	mov    %esp,%ebp
80100a57:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100a5a:	83 ec 0c             	sub    $0xc,%esp
80100a5d:	ff 75 08             	pushl  0x8(%ebp)
80100a60:	e8 ba 11 00 00       	call   80101c1f <iunlock>
80100a65:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a68:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a76:	e8 13 48 00 00       	call   8010528e <acquire>
80100a7b:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a7e:	e9 ab 00 00 00       	jmp    80100b2e <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
80100a83:	e8 0e 3a 00 00       	call   80104496 <myproc>
80100a88:	8b 40 28             	mov    0x28(%eax),%eax
80100a8b:	85 c0                	test   %eax,%eax
80100a8d:	74 28                	je     80100ab7 <consoleread+0x67>
        release(&cons.lock);
80100a8f:	83 ec 0c             	sub    $0xc,%esp
80100a92:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a97:	e8 64 48 00 00       	call   80105300 <release>
80100a9c:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a9f:	83 ec 0c             	sub    $0xc,%esp
80100aa2:	ff 75 08             	pushl  0x8(%ebp)
80100aa5:	e8 5e 10 00 00       	call   80101b08 <ilock>
80100aaa:	83 c4 10             	add    $0x10,%esp
        return -1;
80100aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ab2:	e9 ab 00 00 00       	jmp    80100b62 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100ab7:	83 ec 08             	sub    $0x8,%esp
80100aba:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abf:	68 40 20 11 80       	push   $0x80112040
80100ac4:	e8 53 43 00 00       	call   80104e1c <sleep>
80100ac9:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100acc:	8b 15 40 20 11 80    	mov    0x80112040,%edx
80100ad2:	a1 44 20 11 80       	mov    0x80112044,%eax
80100ad7:	39 c2                	cmp    %eax,%edx
80100ad9:	74 a8                	je     80100a83 <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100adb:	a1 40 20 11 80       	mov    0x80112040,%eax
80100ae0:	8d 50 01             	lea    0x1(%eax),%edx
80100ae3:	89 15 40 20 11 80    	mov    %edx,0x80112040
80100ae9:	83 e0 7f             	and    $0x7f,%eax
80100aec:	0f b6 80 c0 1f 11 80 	movzbl -0x7feee040(%eax),%eax
80100af3:	0f be c0             	movsbl %al,%eax
80100af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100af9:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100afd:	75 17                	jne    80100b16 <consoleread+0xc6>
      if(n < target){
80100aff:	8b 45 10             	mov    0x10(%ebp),%eax
80100b02:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100b05:	76 2f                	jbe    80100b36 <consoleread+0xe6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100b07:	a1 40 20 11 80       	mov    0x80112040,%eax
80100b0c:	83 e8 01             	sub    $0x1,%eax
80100b0f:	a3 40 20 11 80       	mov    %eax,0x80112040
      }
      break;
80100b14:	eb 20                	jmp    80100b36 <consoleread+0xe6>
    }
    *dst++ = c;
80100b16:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b19:	8d 50 01             	lea    0x1(%eax),%edx
80100b1c:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b22:	88 10                	mov    %dl,(%eax)
    --n;
80100b24:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100b28:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b2c:	74 0b                	je     80100b39 <consoleread+0xe9>
  while(n > 0){
80100b2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b32:	7f 98                	jg     80100acc <consoleread+0x7c>
80100b34:	eb 04                	jmp    80100b3a <consoleread+0xea>
      break;
80100b36:	90                   	nop
80100b37:	eb 01                	jmp    80100b3a <consoleread+0xea>
      break;
80100b39:	90                   	nop
  }
  release(&cons.lock);
80100b3a:	83 ec 0c             	sub    $0xc,%esp
80100b3d:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b42:	e8 b9 47 00 00       	call   80105300 <release>
80100b47:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	ff 75 08             	pushl  0x8(%ebp)
80100b50:	e8 b3 0f 00 00       	call   80101b08 <ilock>
80100b55:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100b58:	8b 45 10             	mov    0x10(%ebp),%eax
80100b5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b5e:	29 c2                	sub    %eax,%edx
80100b60:	89 d0                	mov    %edx,%eax
}
80100b62:	c9                   	leave  
80100b63:	c3                   	ret    

80100b64 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b64:	f3 0f 1e fb          	endbr32 
80100b68:	55                   	push   %ebp
80100b69:	89 e5                	mov    %esp,%ebp
80100b6b:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b6e:	83 ec 0c             	sub    $0xc,%esp
80100b71:	ff 75 08             	pushl  0x8(%ebp)
80100b74:	e8 a6 10 00 00       	call   80101c1f <iunlock>
80100b79:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b7c:	83 ec 0c             	sub    $0xc,%esp
80100b7f:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b84:	e8 05 47 00 00       	call   8010528e <acquire>
80100b89:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b93:	eb 21                	jmp    80100bb6 <consolewrite+0x52>
    consputc(buf[i] & 0xff);
80100b95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b98:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b9b:	01 d0                	add    %edx,%eax
80100b9d:	0f b6 00             	movzbl (%eax),%eax
80100ba0:	0f be c0             	movsbl %al,%eax
80100ba3:	0f b6 c0             	movzbl %al,%eax
80100ba6:	83 ec 0c             	sub    $0xc,%esp
80100ba9:	50                   	push   %eax
80100baa:	e8 8e fc ff ff       	call   8010083d <consputc>
80100baf:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100bb2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bb9:	3b 45 10             	cmp    0x10(%ebp),%eax
80100bbc:	7c d7                	jl     80100b95 <consolewrite+0x31>
  release(&cons.lock);
80100bbe:	83 ec 0c             	sub    $0xc,%esp
80100bc1:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bc6:	e8 35 47 00 00       	call   80105300 <release>
80100bcb:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bce:	83 ec 0c             	sub    $0xc,%esp
80100bd1:	ff 75 08             	pushl  0x8(%ebp)
80100bd4:	e8 2f 0f 00 00       	call   80101b08 <ilock>
80100bd9:	83 c4 10             	add    $0x10,%esp

  return n;
80100bdc:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bdf:	c9                   	leave  
80100be0:	c3                   	ret    

80100be1 <consoleinit>:

void
consoleinit(void)
{
80100be1:	f3 0f 1e fb          	endbr32 
80100be5:	55                   	push   %ebp
80100be6:	89 e5                	mov    %esp,%ebp
80100be8:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100beb:	83 ec 08             	sub    $0x8,%esp
80100bee:	68 11 91 10 80       	push   $0x80109111
80100bf3:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bf8:	e8 6b 46 00 00       	call   80105268 <initlock>
80100bfd:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100c00:	c7 05 0c 2a 11 80 64 	movl   $0x80100b64,0x80112a0c
80100c07:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c0a:	c7 05 08 2a 11 80 50 	movl   $0x80100a50,0x80112a08
80100c11:	0a 10 80 
  cons.locking = 1;
80100c14:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100c1b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c1e:	83 ec 08             	sub    $0x8,%esp
80100c21:	6a 00                	push   $0x0
80100c23:	6a 01                	push   $0x1
80100c25:	e8 48 20 00 00       	call   80102c72 <ioapicenable>
80100c2a:	83 c4 10             	add    $0x10,%esp
}
80100c2d:	90                   	nop
80100c2e:	c9                   	leave  
80100c2f:	c3                   	ret    

80100c30 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c30:	f3 0f 1e fb          	endbr32 
80100c34:	55                   	push   %ebp
80100c35:	89 e5                	mov    %esp,%ebp
80100c37:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c3d:	e8 54 38 00 00       	call   80104496 <myproc>
80100c42:	89 45 d0             	mov    %eax,-0x30(%ebp)
  begin_op();
80100c45:	e8 8d 2a 00 00       	call   801036d7 <begin_op>

  if((ip = namei(path)) == 0){
80100c4a:	83 ec 0c             	sub    $0xc,%esp
80100c4d:	ff 75 08             	pushl  0x8(%ebp)
80100c50:	e8 1e 1a 00 00       	call   80102673 <namei>
80100c55:	83 c4 10             	add    $0x10,%esp
80100c58:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c5b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c5f:	75 1f                	jne    80100c80 <exec+0x50>
    end_op();
80100c61:	e8 01 2b 00 00       	call   80103767 <end_op>
    cprintf("exec: fail\n");
80100c66:	83 ec 0c             	sub    $0xc,%esp
80100c69:	68 19 91 10 80       	push   $0x80109119
80100c6e:	e8 a5 f7 ff ff       	call   80100418 <cprintf>
80100c73:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c7b:	e9 1e 04 00 00       	jmp    8010109e <exec+0x46e>
  }
  ilock(ip);
80100c80:	83 ec 0c             	sub    $0xc,%esp
80100c83:	ff 75 d8             	pushl  -0x28(%ebp)
80100c86:	e8 7d 0e 00 00       	call   80101b08 <ilock>
80100c8b:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c8e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c95:	6a 34                	push   $0x34
80100c97:	6a 00                	push   $0x0
80100c99:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c9f:	50                   	push   %eax
80100ca0:	ff 75 d8             	pushl  -0x28(%ebp)
80100ca3:	e8 68 13 00 00       	call   80102010 <readi>
80100ca8:	83 c4 10             	add    $0x10,%esp
80100cab:	83 f8 34             	cmp    $0x34,%eax
80100cae:	0f 85 93 03 00 00    	jne    80101047 <exec+0x417>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100cb4:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100cba:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cbf:	0f 85 85 03 00 00    	jne    8010104a <exec+0x41a>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100cc5:	e8 bc 76 00 00       	call   80108386 <setupkvm>
80100cca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ccd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100cd1:	0f 84 76 03 00 00    	je     8010104d <exec+0x41d>
    goto bad;

  // Load program into memory.
  sz = 0;
80100cd7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cde:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100ce5:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100ceb:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cee:	e9 de 00 00 00       	jmp    80100dd1 <exec+0x1a1>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100cf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cf6:	6a 20                	push   $0x20
80100cf8:	50                   	push   %eax
80100cf9:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100cff:	50                   	push   %eax
80100d00:	ff 75 d8             	pushl  -0x28(%ebp)
80100d03:	e8 08 13 00 00       	call   80102010 <readi>
80100d08:	83 c4 10             	add    $0x10,%esp
80100d0b:	83 f8 20             	cmp    $0x20,%eax
80100d0e:	0f 85 3c 03 00 00    	jne    80101050 <exec+0x420>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100d14:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d1a:	83 f8 01             	cmp    $0x1,%eax
80100d1d:	0f 85 a0 00 00 00    	jne    80100dc3 <exec+0x193>
      continue;
    if(ph.memsz < ph.filesz)
80100d23:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d29:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d2f:	39 c2                	cmp    %eax,%edx
80100d31:	0f 82 1c 03 00 00    	jb     80101053 <exec+0x423>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d37:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d3d:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d43:	01 c2                	add    %eax,%edx
80100d45:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d4b:	39 c2                	cmp    %eax,%edx
80100d4d:	0f 82 03 03 00 00    	jb     80101056 <exec+0x426>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d53:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d59:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d5f:	01 d0                	add    %edx,%eax
80100d61:	83 ec 04             	sub    $0x4,%esp
80100d64:	50                   	push   %eax
80100d65:	ff 75 e0             	pushl  -0x20(%ebp)
80100d68:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d6b:	e8 d4 79 00 00       	call   80108744 <allocuvm>
80100d70:	83 c4 10             	add    $0x10,%esp
80100d73:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d76:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7a:	0f 84 d9 02 00 00    	je     80101059 <exec+0x429>
      goto bad;

    if(ph.vaddr % PGSIZE != 0)
80100d80:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d86:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d8b:	85 c0                	test   %eax,%eax
80100d8d:	0f 85 c9 02 00 00    	jne    8010105c <exec+0x42c>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d93:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d99:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d9f:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100da5:	83 ec 0c             	sub    $0xc,%esp
80100da8:	52                   	push   %edx
80100da9:	50                   	push   %eax
80100daa:	ff 75 d8             	pushl  -0x28(%ebp)
80100dad:	51                   	push   %ecx
80100dae:	ff 75 d4             	pushl  -0x2c(%ebp)
80100db1:	e8 bd 78 00 00       	call   80108673 <loaduvm>
80100db6:	83 c4 20             	add    $0x20,%esp
80100db9:	85 c0                	test   %eax,%eax
80100dbb:	0f 88 9e 02 00 00    	js     8010105f <exec+0x42f>
80100dc1:	eb 01                	jmp    80100dc4 <exec+0x194>
      continue;
80100dc3:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100dc4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100dc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100dcb:	83 c0 20             	add    $0x20,%eax
80100dce:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100dd1:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100dd8:	0f b7 c0             	movzwl %ax,%eax
80100ddb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100dde:	0f 8c 0f ff ff ff    	jl     80100cf3 <exec+0xc3>
      goto bad;
  }
  iunlockput(ip);
80100de4:	83 ec 0c             	sub    $0xc,%esp
80100de7:	ff 75 d8             	pushl  -0x28(%ebp)
80100dea:	e8 56 0f 00 00       	call   80101d45 <iunlockput>
80100def:	83 c4 10             	add    $0x10,%esp
  end_op();
80100df2:	e8 70 29 00 00       	call   80103767 <end_op>
  ip = 0;
80100df7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100dfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e01:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e11:	05 00 20 00 00       	add    $0x2000,%eax
80100e16:	83 ec 04             	sub    $0x4,%esp
80100e19:	50                   	push   %eax
80100e1a:	ff 75 e0             	pushl  -0x20(%ebp)
80100e1d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e20:	e8 1f 79 00 00       	call   80108744 <allocuvm>
80100e25:	83 c4 10             	add    $0x10,%esp
80100e28:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e2b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e2f:	0f 84 2d 02 00 00    	je     80101062 <exec+0x432>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e38:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e3d:	83 ec 08             	sub    $0x8,%esp
80100e40:	50                   	push   %eax
80100e41:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e44:	e8 87 7b 00 00       	call   801089d0 <clearpteu>
80100e49:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100e4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e4f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e52:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e59:	e9 96 00 00 00       	jmp    80100ef4 <exec+0x2c4>
    if(argc >= MAXARG)
80100e5e:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e62:	0f 87 fd 01 00 00    	ja     80101065 <exec+0x435>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e72:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e75:	01 d0                	add    %edx,%eax
80100e77:	8b 00                	mov    (%eax),%eax
80100e79:	83 ec 0c             	sub    $0xc,%esp
80100e7c:	50                   	push   %eax
80100e7d:	e8 14 49 00 00       	call   80105796 <strlen>
80100e82:	83 c4 10             	add    $0x10,%esp
80100e85:	89 c2                	mov    %eax,%edx
80100e87:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8a:	29 d0                	sub    %edx,%eax
80100e8c:	83 e8 01             	sub    $0x1,%eax
80100e8f:	83 e0 fc             	and    $0xfffffffc,%eax
80100e92:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e98:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ea2:	01 d0                	add    %edx,%eax
80100ea4:	8b 00                	mov    (%eax),%eax
80100ea6:	83 ec 0c             	sub    $0xc,%esp
80100ea9:	50                   	push   %eax
80100eaa:	e8 e7 48 00 00       	call   80105796 <strlen>
80100eaf:	83 c4 10             	add    $0x10,%esp
80100eb2:	83 c0 01             	add    $0x1,%eax
80100eb5:	89 c1                	mov    %eax,%ecx
80100eb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ec4:	01 d0                	add    %edx,%eax
80100ec6:	8b 00                	mov    (%eax),%eax
80100ec8:	51                   	push   %ecx
80100ec9:	50                   	push   %eax
80100eca:	ff 75 dc             	pushl  -0x24(%ebp)
80100ecd:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ed0:	e8 b7 7c 00 00       	call   80108b8c <copyout>
80100ed5:	83 c4 10             	add    $0x10,%esp
80100ed8:	85 c0                	test   %eax,%eax
80100eda:	0f 88 88 01 00 00    	js     80101068 <exec+0x438>
      goto bad;
    ustack[3+argc] = sp;
80100ee0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee3:	8d 50 03             	lea    0x3(%eax),%edx
80100ee6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ee9:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100ef0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100ef4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ef7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100efe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f01:	01 d0                	add    %edx,%eax
80100f03:	8b 00                	mov    (%eax),%eax
80100f05:	85 c0                	test   %eax,%eax
80100f07:	0f 85 51 ff ff ff    	jne    80100e5e <exec+0x22e>
  }
  ustack[3+argc] = 0;
80100f0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f10:	83 c0 03             	add    $0x3,%eax
80100f13:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100f1a:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f1e:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100f25:	ff ff ff 
  ustack[1] = argc;
80100f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f2b:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f34:	83 c0 01             	add    $0x1,%eax
80100f37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f3e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f41:	29 d0                	sub    %edx,%eax
80100f43:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f4c:	83 c0 04             	add    $0x4,%eax
80100f4f:	c1 e0 02             	shl    $0x2,%eax
80100f52:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f58:	83 c0 04             	add    $0x4,%eax
80100f5b:	c1 e0 02             	shl    $0x2,%eax
80100f5e:	50                   	push   %eax
80100f5f:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f65:	50                   	push   %eax
80100f66:	ff 75 dc             	pushl  -0x24(%ebp)
80100f69:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f6c:	e8 1b 7c 00 00       	call   80108b8c <copyout>
80100f71:	83 c4 10             	add    $0x10,%esp
80100f74:	85 c0                	test   %eax,%eax
80100f76:	0f 88 ef 00 00 00    	js     8010106b <exec+0x43b>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80100f7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f85:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f88:	eb 17                	jmp    80100fa1 <exec+0x371>
    if(*s == '/')
80100f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f8d:	0f b6 00             	movzbl (%eax),%eax
80100f90:	3c 2f                	cmp    $0x2f,%al
80100f92:	75 09                	jne    80100f9d <exec+0x36d>
      last = s+1;
80100f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f97:	83 c0 01             	add    $0x1,%eax
80100f9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f9d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa4:	0f b6 00             	movzbl (%eax),%eax
80100fa7:	84 c0                	test   %al,%al
80100fa9:	75 df                	jne    80100f8a <exec+0x35a>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100fab:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fae:	83 c0 70             	add    $0x70,%eax
80100fb1:	83 ec 04             	sub    $0x4,%esp
80100fb4:	6a 10                	push   $0x10
80100fb6:	ff 75 f0             	pushl  -0x10(%ebp)
80100fb9:	50                   	push   %eax
80100fba:	e8 89 47 00 00       	call   80105748 <safestrcpy>
80100fbf:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100fc2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fc5:	8b 40 04             	mov    0x4(%eax),%eax
80100fc8:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100fcb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100fd1:	89 50 04             	mov    %edx,0x4(%eax)
  
  //uint change = sz - PGROUNDDOWN(curproc->sz);
  curproc->sz = sz;
80100fd4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fd7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fda:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fdc:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fdf:	8b 40 1c             	mov    0x1c(%eax),%eax
80100fe2:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100fe8:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100feb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fee:	8b 40 1c             	mov    0x1c(%eax),%eax
80100ff1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ff4:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100ff7:	83 ec 0c             	sub    $0xc,%esp
80100ffa:	ff 75 d0             	pushl  -0x30(%ebp)
80100ffd:	e8 5a 74 00 00       	call   8010845c <switchuvm>
80101002:	83 c4 10             	add    $0x10,%esp
  mencrypt(0, sz/PGSIZE - 2);
80101005:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101008:	c1 e8 0c             	shr    $0xc,%eax
8010100b:	83 e8 02             	sub    $0x2,%eax
8010100e:	83 ec 08             	sub    $0x8,%esp
80101011:	50                   	push   %eax
80101012:	6a 00                	push   $0x0
80101014:	e8 c9 7c 00 00       	call   80108ce2 <mencrypt>
80101019:	83 c4 10             	add    $0x10,%esp
  mencrypt((char*) sz - PGSIZE, 1);//(void*)PGROUNDDOWN((int)sz - change), change/PGSIZE);
8010101c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010101f:	2d 00 10 00 00       	sub    $0x1000,%eax
80101024:	83 ec 08             	sub    $0x8,%esp
80101027:	6a 01                	push   $0x1
80101029:	50                   	push   %eax
8010102a:	e8 b3 7c 00 00       	call   80108ce2 <mencrypt>
8010102f:	83 c4 10             	add    $0x10,%esp
 // cprintf("%d\n", sz);
 // cprintf("%d\n", change);

  freevm(oldpgdir);
80101032:	83 ec 0c             	sub    $0xc,%esp
80101035:	ff 75 cc             	pushl  -0x34(%ebp)
80101038:	e8 f6 78 00 00       	call   80108933 <freevm>
8010103d:	83 c4 10             	add    $0x10,%esp
  //for (void * i = (void*) PGROUNDDOWN(((int)curproc->sz)); i >= 0; i-=PGSIZE) {
  //  if(mencrypt(i, 1) != 0)
  //    break;
  //}

  return 0;
80101040:	b8 00 00 00 00       	mov    $0x0,%eax
80101045:	eb 57                	jmp    8010109e <exec+0x46e>
    goto bad;
80101047:	90                   	nop
80101048:	eb 22                	jmp    8010106c <exec+0x43c>
    goto bad;
8010104a:	90                   	nop
8010104b:	eb 1f                	jmp    8010106c <exec+0x43c>
    goto bad;
8010104d:	90                   	nop
8010104e:	eb 1c                	jmp    8010106c <exec+0x43c>
      goto bad;
80101050:	90                   	nop
80101051:	eb 19                	jmp    8010106c <exec+0x43c>
      goto bad;
80101053:	90                   	nop
80101054:	eb 16                	jmp    8010106c <exec+0x43c>
      goto bad;
80101056:	90                   	nop
80101057:	eb 13                	jmp    8010106c <exec+0x43c>
      goto bad;
80101059:	90                   	nop
8010105a:	eb 10                	jmp    8010106c <exec+0x43c>
      goto bad;
8010105c:	90                   	nop
8010105d:	eb 0d                	jmp    8010106c <exec+0x43c>
      goto bad;
8010105f:	90                   	nop
80101060:	eb 0a                	jmp    8010106c <exec+0x43c>
    goto bad;
80101062:	90                   	nop
80101063:	eb 07                	jmp    8010106c <exec+0x43c>
      goto bad;
80101065:	90                   	nop
80101066:	eb 04                	jmp    8010106c <exec+0x43c>
      goto bad;
80101068:	90                   	nop
80101069:	eb 01                	jmp    8010106c <exec+0x43c>
    goto bad;
8010106b:	90                   	nop

 bad:
  if(pgdir)
8010106c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101070:	74 0e                	je     80101080 <exec+0x450>
    freevm(pgdir);
80101072:	83 ec 0c             	sub    $0xc,%esp
80101075:	ff 75 d4             	pushl  -0x2c(%ebp)
80101078:	e8 b6 78 00 00       	call   80108933 <freevm>
8010107d:	83 c4 10             	add    $0x10,%esp
  if(ip){
80101080:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101084:	74 13                	je     80101099 <exec+0x469>
    iunlockput(ip);
80101086:	83 ec 0c             	sub    $0xc,%esp
80101089:	ff 75 d8             	pushl  -0x28(%ebp)
8010108c:	e8 b4 0c 00 00       	call   80101d45 <iunlockput>
80101091:	83 c4 10             	add    $0x10,%esp
    end_op();
80101094:	e8 ce 26 00 00       	call   80103767 <end_op>
  }
  return -1;
80101099:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010109e:	c9                   	leave  
8010109f:	c3                   	ret    

801010a0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010a0:	f3 0f 1e fb          	endbr32 
801010a4:	55                   	push   %ebp
801010a5:	89 e5                	mov    %esp,%ebp
801010a7:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801010aa:	83 ec 08             	sub    $0x8,%esp
801010ad:	68 25 91 10 80       	push   $0x80109125
801010b2:	68 60 20 11 80       	push   $0x80112060
801010b7:	e8 ac 41 00 00       	call   80105268 <initlock>
801010bc:	83 c4 10             	add    $0x10,%esp
}
801010bf:	90                   	nop
801010c0:	c9                   	leave  
801010c1:	c3                   	ret    

801010c2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010c2:	f3 0f 1e fb          	endbr32 
801010c6:	55                   	push   %ebp
801010c7:	89 e5                	mov    %esp,%ebp
801010c9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
801010cc:	83 ec 0c             	sub    $0xc,%esp
801010cf:	68 60 20 11 80       	push   $0x80112060
801010d4:	e8 b5 41 00 00       	call   8010528e <acquire>
801010d9:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010dc:	c7 45 f4 94 20 11 80 	movl   $0x80112094,-0xc(%ebp)
801010e3:	eb 2d                	jmp    80101112 <filealloc+0x50>
    if(f->ref == 0){
801010e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010e8:	8b 40 04             	mov    0x4(%eax),%eax
801010eb:	85 c0                	test   %eax,%eax
801010ed:	75 1f                	jne    8010110e <filealloc+0x4c>
      f->ref = 1;
801010ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010f2:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801010f9:	83 ec 0c             	sub    $0xc,%esp
801010fc:	68 60 20 11 80       	push   $0x80112060
80101101:	e8 fa 41 00 00       	call   80105300 <release>
80101106:	83 c4 10             	add    $0x10,%esp
      return f;
80101109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010110c:	eb 23                	jmp    80101131 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010110e:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101112:	b8 f4 29 11 80       	mov    $0x801129f4,%eax
80101117:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010111a:	72 c9                	jb     801010e5 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010111c:	83 ec 0c             	sub    $0xc,%esp
8010111f:	68 60 20 11 80       	push   $0x80112060
80101124:	e8 d7 41 00 00       	call   80105300 <release>
80101129:	83 c4 10             	add    $0x10,%esp
  return 0;
8010112c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101131:	c9                   	leave  
80101132:	c3                   	ret    

80101133 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101133:	f3 0f 1e fb          	endbr32 
80101137:	55                   	push   %ebp
80101138:	89 e5                	mov    %esp,%ebp
8010113a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010113d:	83 ec 0c             	sub    $0xc,%esp
80101140:	68 60 20 11 80       	push   $0x80112060
80101145:	e8 44 41 00 00       	call   8010528e <acquire>
8010114a:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010114d:	8b 45 08             	mov    0x8(%ebp),%eax
80101150:	8b 40 04             	mov    0x4(%eax),%eax
80101153:	85 c0                	test   %eax,%eax
80101155:	7f 0d                	jg     80101164 <filedup+0x31>
    panic("filedup");
80101157:	83 ec 0c             	sub    $0xc,%esp
8010115a:	68 2c 91 10 80       	push   $0x8010912c
8010115f:	e8 a4 f4 ff ff       	call   80100608 <panic>
  f->ref++;
80101164:	8b 45 08             	mov    0x8(%ebp),%eax
80101167:	8b 40 04             	mov    0x4(%eax),%eax
8010116a:	8d 50 01             	lea    0x1(%eax),%edx
8010116d:	8b 45 08             	mov    0x8(%ebp),%eax
80101170:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101173:	83 ec 0c             	sub    $0xc,%esp
80101176:	68 60 20 11 80       	push   $0x80112060
8010117b:	e8 80 41 00 00       	call   80105300 <release>
80101180:	83 c4 10             	add    $0x10,%esp
  return f;
80101183:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101186:	c9                   	leave  
80101187:	c3                   	ret    

80101188 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101188:	f3 0f 1e fb          	endbr32 
8010118c:	55                   	push   %ebp
8010118d:	89 e5                	mov    %esp,%ebp
8010118f:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101192:	83 ec 0c             	sub    $0xc,%esp
80101195:	68 60 20 11 80       	push   $0x80112060
8010119a:	e8 ef 40 00 00       	call   8010528e <acquire>
8010119f:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011a2:	8b 45 08             	mov    0x8(%ebp),%eax
801011a5:	8b 40 04             	mov    0x4(%eax),%eax
801011a8:	85 c0                	test   %eax,%eax
801011aa:	7f 0d                	jg     801011b9 <fileclose+0x31>
    panic("fileclose");
801011ac:	83 ec 0c             	sub    $0xc,%esp
801011af:	68 34 91 10 80       	push   $0x80109134
801011b4:	e8 4f f4 ff ff       	call   80100608 <panic>
  if(--f->ref > 0){
801011b9:	8b 45 08             	mov    0x8(%ebp),%eax
801011bc:	8b 40 04             	mov    0x4(%eax),%eax
801011bf:	8d 50 ff             	lea    -0x1(%eax),%edx
801011c2:	8b 45 08             	mov    0x8(%ebp),%eax
801011c5:	89 50 04             	mov    %edx,0x4(%eax)
801011c8:	8b 45 08             	mov    0x8(%ebp),%eax
801011cb:	8b 40 04             	mov    0x4(%eax),%eax
801011ce:	85 c0                	test   %eax,%eax
801011d0:	7e 15                	jle    801011e7 <fileclose+0x5f>
    release(&ftable.lock);
801011d2:	83 ec 0c             	sub    $0xc,%esp
801011d5:	68 60 20 11 80       	push   $0x80112060
801011da:	e8 21 41 00 00       	call   80105300 <release>
801011df:	83 c4 10             	add    $0x10,%esp
801011e2:	e9 8b 00 00 00       	jmp    80101272 <fileclose+0xea>
    return;
  }
  ff = *f;
801011e7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ea:	8b 10                	mov    (%eax),%edx
801011ec:	89 55 e0             	mov    %edx,-0x20(%ebp)
801011ef:	8b 50 04             	mov    0x4(%eax),%edx
801011f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801011f5:	8b 50 08             	mov    0x8(%eax),%edx
801011f8:	89 55 e8             	mov    %edx,-0x18(%ebp)
801011fb:	8b 50 0c             	mov    0xc(%eax),%edx
801011fe:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101201:	8b 50 10             	mov    0x10(%eax),%edx
80101204:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101207:	8b 40 14             	mov    0x14(%eax),%eax
8010120a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010120d:	8b 45 08             	mov    0x8(%ebp),%eax
80101210:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101217:	8b 45 08             	mov    0x8(%ebp),%eax
8010121a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101220:	83 ec 0c             	sub    $0xc,%esp
80101223:	68 60 20 11 80       	push   $0x80112060
80101228:	e8 d3 40 00 00       	call   80105300 <release>
8010122d:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101230:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101233:	83 f8 01             	cmp    $0x1,%eax
80101236:	75 19                	jne    80101251 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101238:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010123c:	0f be d0             	movsbl %al,%edx
8010123f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101242:	83 ec 08             	sub    $0x8,%esp
80101245:	52                   	push   %edx
80101246:	50                   	push   %eax
80101247:	e8 c1 2e 00 00       	call   8010410d <pipeclose>
8010124c:	83 c4 10             	add    $0x10,%esp
8010124f:	eb 21                	jmp    80101272 <fileclose+0xea>
  else if(ff.type == FD_INODE){
80101251:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101254:	83 f8 02             	cmp    $0x2,%eax
80101257:	75 19                	jne    80101272 <fileclose+0xea>
    begin_op();
80101259:	e8 79 24 00 00       	call   801036d7 <begin_op>
    iput(ff.ip);
8010125e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101261:	83 ec 0c             	sub    $0xc,%esp
80101264:	50                   	push   %eax
80101265:	e8 07 0a 00 00       	call   80101c71 <iput>
8010126a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010126d:	e8 f5 24 00 00       	call   80103767 <end_op>
  }
}
80101272:	c9                   	leave  
80101273:	c3                   	ret    

80101274 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101274:	f3 0f 1e fb          	endbr32 
80101278:	55                   	push   %ebp
80101279:	89 e5                	mov    %esp,%ebp
8010127b:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010127e:	8b 45 08             	mov    0x8(%ebp),%eax
80101281:	8b 00                	mov    (%eax),%eax
80101283:	83 f8 02             	cmp    $0x2,%eax
80101286:	75 40                	jne    801012c8 <filestat+0x54>
    ilock(f->ip);
80101288:	8b 45 08             	mov    0x8(%ebp),%eax
8010128b:	8b 40 10             	mov    0x10(%eax),%eax
8010128e:	83 ec 0c             	sub    $0xc,%esp
80101291:	50                   	push   %eax
80101292:	e8 71 08 00 00       	call   80101b08 <ilock>
80101297:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010129a:	8b 45 08             	mov    0x8(%ebp),%eax
8010129d:	8b 40 10             	mov    0x10(%eax),%eax
801012a0:	83 ec 08             	sub    $0x8,%esp
801012a3:	ff 75 0c             	pushl  0xc(%ebp)
801012a6:	50                   	push   %eax
801012a7:	e8 1a 0d 00 00       	call   80101fc6 <stati>
801012ac:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801012af:	8b 45 08             	mov    0x8(%ebp),%eax
801012b2:	8b 40 10             	mov    0x10(%eax),%eax
801012b5:	83 ec 0c             	sub    $0xc,%esp
801012b8:	50                   	push   %eax
801012b9:	e8 61 09 00 00       	call   80101c1f <iunlock>
801012be:	83 c4 10             	add    $0x10,%esp
    return 0;
801012c1:	b8 00 00 00 00       	mov    $0x0,%eax
801012c6:	eb 05                	jmp    801012cd <filestat+0x59>
  }
  return -1;
801012c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012cd:	c9                   	leave  
801012ce:	c3                   	ret    

801012cf <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012cf:	f3 0f 1e fb          	endbr32 
801012d3:	55                   	push   %ebp
801012d4:	89 e5                	mov    %esp,%ebp
801012d6:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801012d9:	8b 45 08             	mov    0x8(%ebp),%eax
801012dc:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801012e0:	84 c0                	test   %al,%al
801012e2:	75 0a                	jne    801012ee <fileread+0x1f>
    return -1;
801012e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012e9:	e9 9b 00 00 00       	jmp    80101389 <fileread+0xba>
  if(f->type == FD_PIPE)
801012ee:	8b 45 08             	mov    0x8(%ebp),%eax
801012f1:	8b 00                	mov    (%eax),%eax
801012f3:	83 f8 01             	cmp    $0x1,%eax
801012f6:	75 1a                	jne    80101312 <fileread+0x43>
    return piperead(f->pipe, addr, n);
801012f8:	8b 45 08             	mov    0x8(%ebp),%eax
801012fb:	8b 40 0c             	mov    0xc(%eax),%eax
801012fe:	83 ec 04             	sub    $0x4,%esp
80101301:	ff 75 10             	pushl  0x10(%ebp)
80101304:	ff 75 0c             	pushl  0xc(%ebp)
80101307:	50                   	push   %eax
80101308:	e8 b5 2f 00 00       	call   801042c2 <piperead>
8010130d:	83 c4 10             	add    $0x10,%esp
80101310:	eb 77                	jmp    80101389 <fileread+0xba>
  if(f->type == FD_INODE){
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	8b 00                	mov    (%eax),%eax
80101317:	83 f8 02             	cmp    $0x2,%eax
8010131a:	75 60                	jne    8010137c <fileread+0xad>
    ilock(f->ip);
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 40 10             	mov    0x10(%eax),%eax
80101322:	83 ec 0c             	sub    $0xc,%esp
80101325:	50                   	push   %eax
80101326:	e8 dd 07 00 00       	call   80101b08 <ilock>
8010132b:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010132e:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101331:	8b 45 08             	mov    0x8(%ebp),%eax
80101334:	8b 50 14             	mov    0x14(%eax),%edx
80101337:	8b 45 08             	mov    0x8(%ebp),%eax
8010133a:	8b 40 10             	mov    0x10(%eax),%eax
8010133d:	51                   	push   %ecx
8010133e:	52                   	push   %edx
8010133f:	ff 75 0c             	pushl  0xc(%ebp)
80101342:	50                   	push   %eax
80101343:	e8 c8 0c 00 00       	call   80102010 <readi>
80101348:	83 c4 10             	add    $0x10,%esp
8010134b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010134e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101352:	7e 11                	jle    80101365 <fileread+0x96>
      f->off += r;
80101354:	8b 45 08             	mov    0x8(%ebp),%eax
80101357:	8b 50 14             	mov    0x14(%eax),%edx
8010135a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010135d:	01 c2                	add    %eax,%edx
8010135f:	8b 45 08             	mov    0x8(%ebp),%eax
80101362:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101365:	8b 45 08             	mov    0x8(%ebp),%eax
80101368:	8b 40 10             	mov    0x10(%eax),%eax
8010136b:	83 ec 0c             	sub    $0xc,%esp
8010136e:	50                   	push   %eax
8010136f:	e8 ab 08 00 00       	call   80101c1f <iunlock>
80101374:	83 c4 10             	add    $0x10,%esp
    return r;
80101377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010137a:	eb 0d                	jmp    80101389 <fileread+0xba>
  }
  panic("fileread");
8010137c:	83 ec 0c             	sub    $0xc,%esp
8010137f:	68 3e 91 10 80       	push   $0x8010913e
80101384:	e8 7f f2 ff ff       	call   80100608 <panic>
}
80101389:	c9                   	leave  
8010138a:	c3                   	ret    

8010138b <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010138b:	f3 0f 1e fb          	endbr32 
8010138f:	55                   	push   %ebp
80101390:	89 e5                	mov    %esp,%ebp
80101392:	53                   	push   %ebx
80101393:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101396:	8b 45 08             	mov    0x8(%ebp),%eax
80101399:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010139d:	84 c0                	test   %al,%al
8010139f:	75 0a                	jne    801013ab <filewrite+0x20>
    return -1;
801013a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013a6:	e9 1b 01 00 00       	jmp    801014c6 <filewrite+0x13b>
  if(f->type == FD_PIPE)
801013ab:	8b 45 08             	mov    0x8(%ebp),%eax
801013ae:	8b 00                	mov    (%eax),%eax
801013b0:	83 f8 01             	cmp    $0x1,%eax
801013b3:	75 1d                	jne    801013d2 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801013b5:	8b 45 08             	mov    0x8(%ebp),%eax
801013b8:	8b 40 0c             	mov    0xc(%eax),%eax
801013bb:	83 ec 04             	sub    $0x4,%esp
801013be:	ff 75 10             	pushl  0x10(%ebp)
801013c1:	ff 75 0c             	pushl  0xc(%ebp)
801013c4:	50                   	push   %eax
801013c5:	e8 f2 2d 00 00       	call   801041bc <pipewrite>
801013ca:	83 c4 10             	add    $0x10,%esp
801013cd:	e9 f4 00 00 00       	jmp    801014c6 <filewrite+0x13b>
  if(f->type == FD_INODE){
801013d2:	8b 45 08             	mov    0x8(%ebp),%eax
801013d5:	8b 00                	mov    (%eax),%eax
801013d7:	83 f8 02             	cmp    $0x2,%eax
801013da:	0f 85 d9 00 00 00    	jne    801014b9 <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801013e0:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801013e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013ee:	e9 a3 00 00 00       	jmp    80101496 <filewrite+0x10b>
      int n1 = n - i;
801013f3:	8b 45 10             	mov    0x10(%ebp),%eax
801013f6:	2b 45 f4             	sub    -0xc(%ebp),%eax
801013f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013ff:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101402:	7e 06                	jle    8010140a <filewrite+0x7f>
        n1 = max;
80101404:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101407:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010140a:	e8 c8 22 00 00       	call   801036d7 <begin_op>
      ilock(f->ip);
8010140f:	8b 45 08             	mov    0x8(%ebp),%eax
80101412:	8b 40 10             	mov    0x10(%eax),%eax
80101415:	83 ec 0c             	sub    $0xc,%esp
80101418:	50                   	push   %eax
80101419:	e8 ea 06 00 00       	call   80101b08 <ilock>
8010141e:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101421:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101424:	8b 45 08             	mov    0x8(%ebp),%eax
80101427:	8b 50 14             	mov    0x14(%eax),%edx
8010142a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010142d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101430:	01 c3                	add    %eax,%ebx
80101432:	8b 45 08             	mov    0x8(%ebp),%eax
80101435:	8b 40 10             	mov    0x10(%eax),%eax
80101438:	51                   	push   %ecx
80101439:	52                   	push   %edx
8010143a:	53                   	push   %ebx
8010143b:	50                   	push   %eax
8010143c:	e8 28 0d 00 00       	call   80102169 <writei>
80101441:	83 c4 10             	add    $0x10,%esp
80101444:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101447:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010144b:	7e 11                	jle    8010145e <filewrite+0xd3>
        f->off += r;
8010144d:	8b 45 08             	mov    0x8(%ebp),%eax
80101450:	8b 50 14             	mov    0x14(%eax),%edx
80101453:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101456:	01 c2                	add    %eax,%edx
80101458:	8b 45 08             	mov    0x8(%ebp),%eax
8010145b:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010145e:	8b 45 08             	mov    0x8(%ebp),%eax
80101461:	8b 40 10             	mov    0x10(%eax),%eax
80101464:	83 ec 0c             	sub    $0xc,%esp
80101467:	50                   	push   %eax
80101468:	e8 b2 07 00 00       	call   80101c1f <iunlock>
8010146d:	83 c4 10             	add    $0x10,%esp
      end_op();
80101470:	e8 f2 22 00 00       	call   80103767 <end_op>

      if(r < 0)
80101475:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101479:	78 29                	js     801014a4 <filewrite+0x119>
        break;
      if(r != n1)
8010147b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010147e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101481:	74 0d                	je     80101490 <filewrite+0x105>
        panic("short filewrite");
80101483:	83 ec 0c             	sub    $0xc,%esp
80101486:	68 47 91 10 80       	push   $0x80109147
8010148b:	e8 78 f1 ff ff       	call   80100608 <panic>
      i += r;
80101490:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101493:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101499:	3b 45 10             	cmp    0x10(%ebp),%eax
8010149c:	0f 8c 51 ff ff ff    	jl     801013f3 <filewrite+0x68>
801014a2:	eb 01                	jmp    801014a5 <filewrite+0x11a>
        break;
801014a4:	90                   	nop
    }
    return i == n ? n : -1;
801014a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014a8:	3b 45 10             	cmp    0x10(%ebp),%eax
801014ab:	75 05                	jne    801014b2 <filewrite+0x127>
801014ad:	8b 45 10             	mov    0x10(%ebp),%eax
801014b0:	eb 14                	jmp    801014c6 <filewrite+0x13b>
801014b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014b7:	eb 0d                	jmp    801014c6 <filewrite+0x13b>
  }
  panic("filewrite");
801014b9:	83 ec 0c             	sub    $0xc,%esp
801014bc:	68 57 91 10 80       	push   $0x80109157
801014c1:	e8 42 f1 ff ff       	call   80100608 <panic>
}
801014c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801014c9:	c9                   	leave  
801014ca:	c3                   	ret    

801014cb <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014cb:	f3 0f 1e fb          	endbr32 
801014cf:	55                   	push   %ebp
801014d0:	89 e5                	mov    %esp,%ebp
801014d2:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014d5:	8b 45 08             	mov    0x8(%ebp),%eax
801014d8:	83 ec 08             	sub    $0x8,%esp
801014db:	6a 01                	push   $0x1
801014dd:	50                   	push   %eax
801014de:	e8 f4 ec ff ff       	call   801001d7 <bread>
801014e3:	83 c4 10             	add    $0x10,%esp
801014e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ec:	83 c0 5c             	add    $0x5c,%eax
801014ef:	83 ec 04             	sub    $0x4,%esp
801014f2:	6a 1c                	push   $0x1c
801014f4:	50                   	push   %eax
801014f5:	ff 75 0c             	pushl  0xc(%ebp)
801014f8:	e8 f7 40 00 00       	call   801055f4 <memmove>
801014fd:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101500:	83 ec 0c             	sub    $0xc,%esp
80101503:	ff 75 f4             	pushl  -0xc(%ebp)
80101506:	e8 56 ed ff ff       	call   80100261 <brelse>
8010150b:	83 c4 10             	add    $0x10,%esp
}
8010150e:	90                   	nop
8010150f:	c9                   	leave  
80101510:	c3                   	ret    

80101511 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101511:	f3 0f 1e fb          	endbr32 
80101515:	55                   	push   %ebp
80101516:	89 e5                	mov    %esp,%ebp
80101518:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010151b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010151e:	8b 45 08             	mov    0x8(%ebp),%eax
80101521:	83 ec 08             	sub    $0x8,%esp
80101524:	52                   	push   %edx
80101525:	50                   	push   %eax
80101526:	e8 ac ec ff ff       	call   801001d7 <bread>
8010152b:	83 c4 10             	add    $0x10,%esp
8010152e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101534:	83 c0 5c             	add    $0x5c,%eax
80101537:	83 ec 04             	sub    $0x4,%esp
8010153a:	68 00 02 00 00       	push   $0x200
8010153f:	6a 00                	push   $0x0
80101541:	50                   	push   %eax
80101542:	e8 e6 3f 00 00       	call   8010552d <memset>
80101547:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010154a:	83 ec 0c             	sub    $0xc,%esp
8010154d:	ff 75 f4             	pushl  -0xc(%ebp)
80101550:	e8 cb 23 00 00       	call   80103920 <log_write>
80101555:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101558:	83 ec 0c             	sub    $0xc,%esp
8010155b:	ff 75 f4             	pushl  -0xc(%ebp)
8010155e:	e8 fe ec ff ff       	call   80100261 <brelse>
80101563:	83 c4 10             	add    $0x10,%esp
}
80101566:	90                   	nop
80101567:	c9                   	leave  
80101568:	c3                   	ret    

80101569 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101569:	f3 0f 1e fb          	endbr32 
8010156d:	55                   	push   %ebp
8010156e:	89 e5                	mov    %esp,%ebp
80101570:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101573:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010157a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101581:	e9 13 01 00 00       	jmp    80101699 <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
80101586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101589:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010158f:	85 c0                	test   %eax,%eax
80101591:	0f 48 c2             	cmovs  %edx,%eax
80101594:	c1 f8 0c             	sar    $0xc,%eax
80101597:	89 c2                	mov    %eax,%edx
80101599:	a1 78 2a 11 80       	mov    0x80112a78,%eax
8010159e:	01 d0                	add    %edx,%eax
801015a0:	83 ec 08             	sub    $0x8,%esp
801015a3:	50                   	push   %eax
801015a4:	ff 75 08             	pushl  0x8(%ebp)
801015a7:	e8 2b ec ff ff       	call   801001d7 <bread>
801015ac:	83 c4 10             	add    $0x10,%esp
801015af:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015b2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015b9:	e9 a6 00 00 00       	jmp    80101664 <balloc+0xfb>
      m = 1 << (bi % 8);
801015be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c1:	99                   	cltd   
801015c2:	c1 ea 1d             	shr    $0x1d,%edx
801015c5:	01 d0                	add    %edx,%eax
801015c7:	83 e0 07             	and    $0x7,%eax
801015ca:	29 d0                	sub    %edx,%eax
801015cc:	ba 01 00 00 00       	mov    $0x1,%edx
801015d1:	89 c1                	mov    %eax,%ecx
801015d3:	d3 e2                	shl    %cl,%edx
801015d5:	89 d0                	mov    %edx,%eax
801015d7:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015dd:	8d 50 07             	lea    0x7(%eax),%edx
801015e0:	85 c0                	test   %eax,%eax
801015e2:	0f 48 c2             	cmovs  %edx,%eax
801015e5:	c1 f8 03             	sar    $0x3,%eax
801015e8:	89 c2                	mov    %eax,%edx
801015ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015ed:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801015f2:	0f b6 c0             	movzbl %al,%eax
801015f5:	23 45 e8             	and    -0x18(%ebp),%eax
801015f8:	85 c0                	test   %eax,%eax
801015fa:	75 64                	jne    80101660 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
801015fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ff:	8d 50 07             	lea    0x7(%eax),%edx
80101602:	85 c0                	test   %eax,%eax
80101604:	0f 48 c2             	cmovs  %edx,%eax
80101607:	c1 f8 03             	sar    $0x3,%eax
8010160a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010160d:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101612:	89 d1                	mov    %edx,%ecx
80101614:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101617:	09 ca                	or     %ecx,%edx
80101619:	89 d1                	mov    %edx,%ecx
8010161b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010161e:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101622:	83 ec 0c             	sub    $0xc,%esp
80101625:	ff 75 ec             	pushl  -0x14(%ebp)
80101628:	e8 f3 22 00 00       	call   80103920 <log_write>
8010162d:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101630:	83 ec 0c             	sub    $0xc,%esp
80101633:	ff 75 ec             	pushl  -0x14(%ebp)
80101636:	e8 26 ec ff ff       	call   80100261 <brelse>
8010163b:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010163e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101641:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101644:	01 c2                	add    %eax,%edx
80101646:	8b 45 08             	mov    0x8(%ebp),%eax
80101649:	83 ec 08             	sub    $0x8,%esp
8010164c:	52                   	push   %edx
8010164d:	50                   	push   %eax
8010164e:	e8 be fe ff ff       	call   80101511 <bzero>
80101653:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101656:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101659:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010165c:	01 d0                	add    %edx,%eax
8010165e:	eb 57                	jmp    801016b7 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101660:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101664:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010166b:	7f 17                	jg     80101684 <balloc+0x11b>
8010166d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101670:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101673:	01 d0                	add    %edx,%eax
80101675:	89 c2                	mov    %eax,%edx
80101677:	a1 60 2a 11 80       	mov    0x80112a60,%eax
8010167c:	39 c2                	cmp    %eax,%edx
8010167e:	0f 82 3a ff ff ff    	jb     801015be <balloc+0x55>
      }
    }
    brelse(bp);
80101684:	83 ec 0c             	sub    $0xc,%esp
80101687:	ff 75 ec             	pushl  -0x14(%ebp)
8010168a:	e8 d2 eb ff ff       	call   80100261 <brelse>
8010168f:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101692:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101699:	8b 15 60 2a 11 80    	mov    0x80112a60,%edx
8010169f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016a2:	39 c2                	cmp    %eax,%edx
801016a4:	0f 87 dc fe ff ff    	ja     80101586 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
801016aa:	83 ec 0c             	sub    $0xc,%esp
801016ad:	68 64 91 10 80       	push   $0x80109164
801016b2:	e8 51 ef ff ff       	call   80100608 <panic>
}
801016b7:	c9                   	leave  
801016b8:	c3                   	ret    

801016b9 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801016b9:	f3 0f 1e fb          	endbr32 
801016bd:	55                   	push   %ebp
801016be:	89 e5                	mov    %esp,%ebp
801016c0:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801016c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801016c6:	c1 e8 0c             	shr    $0xc,%eax
801016c9:	89 c2                	mov    %eax,%edx
801016cb:	a1 78 2a 11 80       	mov    0x80112a78,%eax
801016d0:	01 c2                	add    %eax,%edx
801016d2:	8b 45 08             	mov    0x8(%ebp),%eax
801016d5:	83 ec 08             	sub    $0x8,%esp
801016d8:	52                   	push   %edx
801016d9:	50                   	push   %eax
801016da:	e8 f8 ea ff ff       	call   801001d7 <bread>
801016df:	83 c4 10             	add    $0x10,%esp
801016e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801016e8:	25 ff 0f 00 00       	and    $0xfff,%eax
801016ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f3:	99                   	cltd   
801016f4:	c1 ea 1d             	shr    $0x1d,%edx
801016f7:	01 d0                	add    %edx,%eax
801016f9:	83 e0 07             	and    $0x7,%eax
801016fc:	29 d0                	sub    %edx,%eax
801016fe:	ba 01 00 00 00       	mov    $0x1,%edx
80101703:	89 c1                	mov    %eax,%ecx
80101705:	d3 e2                	shl    %cl,%edx
80101707:	89 d0                	mov    %edx,%eax
80101709:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010170c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170f:	8d 50 07             	lea    0x7(%eax),%edx
80101712:	85 c0                	test   %eax,%eax
80101714:	0f 48 c2             	cmovs  %edx,%eax
80101717:	c1 f8 03             	sar    $0x3,%eax
8010171a:	89 c2                	mov    %eax,%edx
8010171c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010171f:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101724:	0f b6 c0             	movzbl %al,%eax
80101727:	23 45 ec             	and    -0x14(%ebp),%eax
8010172a:	85 c0                	test   %eax,%eax
8010172c:	75 0d                	jne    8010173b <bfree+0x82>
    panic("freeing free block");
8010172e:	83 ec 0c             	sub    $0xc,%esp
80101731:	68 7a 91 10 80       	push   $0x8010917a
80101736:	e8 cd ee ff ff       	call   80100608 <panic>
  bp->data[bi/8] &= ~m;
8010173b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010173e:	8d 50 07             	lea    0x7(%eax),%edx
80101741:	85 c0                	test   %eax,%eax
80101743:	0f 48 c2             	cmovs  %edx,%eax
80101746:	c1 f8 03             	sar    $0x3,%eax
80101749:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010174c:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101751:	89 d1                	mov    %edx,%ecx
80101753:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101756:	f7 d2                	not    %edx
80101758:	21 ca                	and    %ecx,%edx
8010175a:	89 d1                	mov    %edx,%ecx
8010175c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010175f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101763:	83 ec 0c             	sub    $0xc,%esp
80101766:	ff 75 f4             	pushl  -0xc(%ebp)
80101769:	e8 b2 21 00 00       	call   80103920 <log_write>
8010176e:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101771:	83 ec 0c             	sub    $0xc,%esp
80101774:	ff 75 f4             	pushl  -0xc(%ebp)
80101777:	e8 e5 ea ff ff       	call   80100261 <brelse>
8010177c:	83 c4 10             	add    $0x10,%esp
}
8010177f:	90                   	nop
80101780:	c9                   	leave  
80101781:	c3                   	ret    

80101782 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101782:	f3 0f 1e fb          	endbr32 
80101786:	55                   	push   %ebp
80101787:	89 e5                	mov    %esp,%ebp
80101789:	57                   	push   %edi
8010178a:	56                   	push   %esi
8010178b:	53                   	push   %ebx
8010178c:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
8010178f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101796:	83 ec 08             	sub    $0x8,%esp
80101799:	68 8d 91 10 80       	push   $0x8010918d
8010179e:	68 80 2a 11 80       	push   $0x80112a80
801017a3:	e8 c0 3a 00 00       	call   80105268 <initlock>
801017a8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017ab:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801017b2:	eb 2d                	jmp    801017e1 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
801017b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801017b7:	89 d0                	mov    %edx,%eax
801017b9:	c1 e0 03             	shl    $0x3,%eax
801017bc:	01 d0                	add    %edx,%eax
801017be:	c1 e0 04             	shl    $0x4,%eax
801017c1:	83 c0 30             	add    $0x30,%eax
801017c4:	05 80 2a 11 80       	add    $0x80112a80,%eax
801017c9:	83 c0 10             	add    $0x10,%eax
801017cc:	83 ec 08             	sub    $0x8,%esp
801017cf:	68 94 91 10 80       	push   $0x80109194
801017d4:	50                   	push   %eax
801017d5:	e8 fb 38 00 00       	call   801050d5 <initsleeplock>
801017da:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017dd:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801017e1:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017e5:	7e cd                	jle    801017b4 <iinit+0x32>
  }

  readsb(dev, &sb);
801017e7:	83 ec 08             	sub    $0x8,%esp
801017ea:	68 60 2a 11 80       	push   $0x80112a60
801017ef:	ff 75 08             	pushl  0x8(%ebp)
801017f2:	e8 d4 fc ff ff       	call   801014cb <readsb>
801017f7:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017fa:	a1 78 2a 11 80       	mov    0x80112a78,%eax
801017ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101802:	8b 3d 74 2a 11 80    	mov    0x80112a74,%edi
80101808:	8b 35 70 2a 11 80    	mov    0x80112a70,%esi
8010180e:	8b 1d 6c 2a 11 80    	mov    0x80112a6c,%ebx
80101814:	8b 0d 68 2a 11 80    	mov    0x80112a68,%ecx
8010181a:	8b 15 64 2a 11 80    	mov    0x80112a64,%edx
80101820:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80101825:	ff 75 d4             	pushl  -0x2c(%ebp)
80101828:	57                   	push   %edi
80101829:	56                   	push   %esi
8010182a:	53                   	push   %ebx
8010182b:	51                   	push   %ecx
8010182c:	52                   	push   %edx
8010182d:	50                   	push   %eax
8010182e:	68 9c 91 10 80       	push   $0x8010919c
80101833:	e8 e0 eb ff ff       	call   80100418 <cprintf>
80101838:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010183b:	90                   	nop
8010183c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010183f:	5b                   	pop    %ebx
80101840:	5e                   	pop    %esi
80101841:	5f                   	pop    %edi
80101842:	5d                   	pop    %ebp
80101843:	c3                   	ret    

80101844 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101844:	f3 0f 1e fb          	endbr32 
80101848:	55                   	push   %ebp
80101849:	89 e5                	mov    %esp,%ebp
8010184b:	83 ec 28             	sub    $0x28,%esp
8010184e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101851:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101855:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010185c:	e9 9e 00 00 00       	jmp    801018ff <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
80101861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101864:	c1 e8 03             	shr    $0x3,%eax
80101867:	89 c2                	mov    %eax,%edx
80101869:	a1 74 2a 11 80       	mov    0x80112a74,%eax
8010186e:	01 d0                	add    %edx,%eax
80101870:	83 ec 08             	sub    $0x8,%esp
80101873:	50                   	push   %eax
80101874:	ff 75 08             	pushl  0x8(%ebp)
80101877:	e8 5b e9 ff ff       	call   801001d7 <bread>
8010187c:	83 c4 10             	add    $0x10,%esp
8010187f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101882:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101885:	8d 50 5c             	lea    0x5c(%eax),%edx
80101888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188b:	83 e0 07             	and    $0x7,%eax
8010188e:	c1 e0 06             	shl    $0x6,%eax
80101891:	01 d0                	add    %edx,%eax
80101893:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101896:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101899:	0f b7 00             	movzwl (%eax),%eax
8010189c:	66 85 c0             	test   %ax,%ax
8010189f:	75 4c                	jne    801018ed <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
801018a1:	83 ec 04             	sub    $0x4,%esp
801018a4:	6a 40                	push   $0x40
801018a6:	6a 00                	push   $0x0
801018a8:	ff 75 ec             	pushl  -0x14(%ebp)
801018ab:	e8 7d 3c 00 00       	call   8010552d <memset>
801018b0:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801018b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018b6:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801018ba:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801018bd:	83 ec 0c             	sub    $0xc,%esp
801018c0:	ff 75 f0             	pushl  -0x10(%ebp)
801018c3:	e8 58 20 00 00       	call   80103920 <log_write>
801018c8:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801018cb:	83 ec 0c             	sub    $0xc,%esp
801018ce:	ff 75 f0             	pushl  -0x10(%ebp)
801018d1:	e8 8b e9 ff ff       	call   80100261 <brelse>
801018d6:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801018d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018dc:	83 ec 08             	sub    $0x8,%esp
801018df:	50                   	push   %eax
801018e0:	ff 75 08             	pushl  0x8(%ebp)
801018e3:	e8 fc 00 00 00       	call   801019e4 <iget>
801018e8:	83 c4 10             	add    $0x10,%esp
801018eb:	eb 30                	jmp    8010191d <ialloc+0xd9>
    }
    brelse(bp);
801018ed:	83 ec 0c             	sub    $0xc,%esp
801018f0:	ff 75 f0             	pushl  -0x10(%ebp)
801018f3:	e8 69 e9 ff ff       	call   80100261 <brelse>
801018f8:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801018fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801018ff:	8b 15 68 2a 11 80    	mov    0x80112a68,%edx
80101905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101908:	39 c2                	cmp    %eax,%edx
8010190a:	0f 87 51 ff ff ff    	ja     80101861 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101910:	83 ec 0c             	sub    $0xc,%esp
80101913:	68 ef 91 10 80       	push   $0x801091ef
80101918:	e8 eb ec ff ff       	call   80100608 <panic>
}
8010191d:	c9                   	leave  
8010191e:	c3                   	ret    

8010191f <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010191f:	f3 0f 1e fb          	endbr32 
80101923:	55                   	push   %ebp
80101924:	89 e5                	mov    %esp,%ebp
80101926:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101929:	8b 45 08             	mov    0x8(%ebp),%eax
8010192c:	8b 40 04             	mov    0x4(%eax),%eax
8010192f:	c1 e8 03             	shr    $0x3,%eax
80101932:	89 c2                	mov    %eax,%edx
80101934:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101939:	01 c2                	add    %eax,%edx
8010193b:	8b 45 08             	mov    0x8(%ebp),%eax
8010193e:	8b 00                	mov    (%eax),%eax
80101940:	83 ec 08             	sub    $0x8,%esp
80101943:	52                   	push   %edx
80101944:	50                   	push   %eax
80101945:	e8 8d e8 ff ff       	call   801001d7 <bread>
8010194a:	83 c4 10             	add    $0x10,%esp
8010194d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101953:	8d 50 5c             	lea    0x5c(%eax),%edx
80101956:	8b 45 08             	mov    0x8(%ebp),%eax
80101959:	8b 40 04             	mov    0x4(%eax),%eax
8010195c:	83 e0 07             	and    $0x7,%eax
8010195f:	c1 e0 06             	shl    $0x6,%eax
80101962:	01 d0                	add    %edx,%eax
80101964:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101967:	8b 45 08             	mov    0x8(%ebp),%eax
8010196a:	0f b7 50 50          	movzwl 0x50(%eax),%edx
8010196e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101971:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101974:	8b 45 08             	mov    0x8(%ebp),%eax
80101977:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010197b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197e:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101982:	8b 45 08             	mov    0x8(%ebp),%eax
80101985:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101989:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010198c:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101990:	8b 45 08             	mov    0x8(%ebp),%eax
80101993:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101997:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010199a:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010199e:	8b 45 08             	mov    0x8(%ebp),%eax
801019a1:	8b 50 58             	mov    0x58(%eax),%edx
801019a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019a7:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019aa:	8b 45 08             	mov    0x8(%ebp),%eax
801019ad:	8d 50 5c             	lea    0x5c(%eax),%edx
801019b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b3:	83 c0 0c             	add    $0xc,%eax
801019b6:	83 ec 04             	sub    $0x4,%esp
801019b9:	6a 34                	push   $0x34
801019bb:	52                   	push   %edx
801019bc:	50                   	push   %eax
801019bd:	e8 32 3c 00 00       	call   801055f4 <memmove>
801019c2:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801019c5:	83 ec 0c             	sub    $0xc,%esp
801019c8:	ff 75 f4             	pushl  -0xc(%ebp)
801019cb:	e8 50 1f 00 00       	call   80103920 <log_write>
801019d0:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019d3:	83 ec 0c             	sub    $0xc,%esp
801019d6:	ff 75 f4             	pushl  -0xc(%ebp)
801019d9:	e8 83 e8 ff ff       	call   80100261 <brelse>
801019de:	83 c4 10             	add    $0x10,%esp
}
801019e1:	90                   	nop
801019e2:	c9                   	leave  
801019e3:	c3                   	ret    

801019e4 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019e4:	f3 0f 1e fb          	endbr32 
801019e8:	55                   	push   %ebp
801019e9:	89 e5                	mov    %esp,%ebp
801019eb:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801019ee:	83 ec 0c             	sub    $0xc,%esp
801019f1:	68 80 2a 11 80       	push   $0x80112a80
801019f6:	e8 93 38 00 00       	call   8010528e <acquire>
801019fb:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801019fe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a05:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
80101a0c:	eb 60                	jmp    80101a6e <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a11:	8b 40 08             	mov    0x8(%eax),%eax
80101a14:	85 c0                	test   %eax,%eax
80101a16:	7e 39                	jle    80101a51 <iget+0x6d>
80101a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1b:	8b 00                	mov    (%eax),%eax
80101a1d:	39 45 08             	cmp    %eax,0x8(%ebp)
80101a20:	75 2f                	jne    80101a51 <iget+0x6d>
80101a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a25:	8b 40 04             	mov    0x4(%eax),%eax
80101a28:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101a2b:	75 24                	jne    80101a51 <iget+0x6d>
      ip->ref++;
80101a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a30:	8b 40 08             	mov    0x8(%eax),%eax
80101a33:	8d 50 01             	lea    0x1(%eax),%edx
80101a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a39:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a3c:	83 ec 0c             	sub    $0xc,%esp
80101a3f:	68 80 2a 11 80       	push   $0x80112a80
80101a44:	e8 b7 38 00 00       	call   80105300 <release>
80101a49:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4f:	eb 77                	jmp    80101ac8 <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a51:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a55:	75 10                	jne    80101a67 <iget+0x83>
80101a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a5a:	8b 40 08             	mov    0x8(%eax),%eax
80101a5d:	85 c0                	test   %eax,%eax
80101a5f:	75 06                	jne    80101a67 <iget+0x83>
      empty = ip;
80101a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a67:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a6e:	81 7d f4 d4 46 11 80 	cmpl   $0x801146d4,-0xc(%ebp)
80101a75:	72 97                	jb     80101a0e <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a7b:	75 0d                	jne    80101a8a <iget+0xa6>
    panic("iget: no inodes");
80101a7d:	83 ec 0c             	sub    $0xc,%esp
80101a80:	68 01 92 10 80       	push   $0x80109201
80101a85:	e8 7e eb ff ff       	call   80100608 <panic>

  ip = empty;
80101a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a93:	8b 55 08             	mov    0x8(%ebp),%edx
80101a96:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a9b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a9e:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aae:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101ab5:	83 ec 0c             	sub    $0xc,%esp
80101ab8:	68 80 2a 11 80       	push   $0x80112a80
80101abd:	e8 3e 38 00 00       	call   80105300 <release>
80101ac2:	83 c4 10             	add    $0x10,%esp

  return ip;
80101ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101ac8:	c9                   	leave  
80101ac9:	c3                   	ret    

80101aca <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101aca:	f3 0f 1e fb          	endbr32 
80101ace:	55                   	push   %ebp
80101acf:	89 e5                	mov    %esp,%ebp
80101ad1:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ad4:	83 ec 0c             	sub    $0xc,%esp
80101ad7:	68 80 2a 11 80       	push   $0x80112a80
80101adc:	e8 ad 37 00 00       	call   8010528e <acquire>
80101ae1:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	8b 40 08             	mov    0x8(%eax),%eax
80101aea:	8d 50 01             	lea    0x1(%eax),%edx
80101aed:	8b 45 08             	mov    0x8(%ebp),%eax
80101af0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101af3:	83 ec 0c             	sub    $0xc,%esp
80101af6:	68 80 2a 11 80       	push   $0x80112a80
80101afb:	e8 00 38 00 00       	call   80105300 <release>
80101b00:	83 c4 10             	add    $0x10,%esp
  return ip;
80101b03:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b06:	c9                   	leave  
80101b07:	c3                   	ret    

80101b08 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b08:	f3 0f 1e fb          	endbr32 
80101b0c:	55                   	push   %ebp
80101b0d:	89 e5                	mov    %esp,%ebp
80101b0f:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b12:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b16:	74 0a                	je     80101b22 <ilock+0x1a>
80101b18:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1b:	8b 40 08             	mov    0x8(%eax),%eax
80101b1e:	85 c0                	test   %eax,%eax
80101b20:	7f 0d                	jg     80101b2f <ilock+0x27>
    panic("ilock");
80101b22:	83 ec 0c             	sub    $0xc,%esp
80101b25:	68 11 92 10 80       	push   $0x80109211
80101b2a:	e8 d9 ea ff ff       	call   80100608 <panic>

  acquiresleep(&ip->lock);
80101b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b32:	83 c0 0c             	add    $0xc,%eax
80101b35:	83 ec 0c             	sub    $0xc,%esp
80101b38:	50                   	push   %eax
80101b39:	e8 d7 35 00 00       	call   80105115 <acquiresleep>
80101b3e:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101b41:	8b 45 08             	mov    0x8(%ebp),%eax
80101b44:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b47:	85 c0                	test   %eax,%eax
80101b49:	0f 85 cd 00 00 00    	jne    80101c1c <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b52:	8b 40 04             	mov    0x4(%eax),%eax
80101b55:	c1 e8 03             	shr    $0x3,%eax
80101b58:	89 c2                	mov    %eax,%edx
80101b5a:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101b5f:	01 c2                	add    %eax,%edx
80101b61:	8b 45 08             	mov    0x8(%ebp),%eax
80101b64:	8b 00                	mov    (%eax),%eax
80101b66:	83 ec 08             	sub    $0x8,%esp
80101b69:	52                   	push   %edx
80101b6a:	50                   	push   %eax
80101b6b:	e8 67 e6 ff ff       	call   801001d7 <bread>
80101b70:	83 c4 10             	add    $0x10,%esp
80101b73:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b79:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7f:	8b 40 04             	mov    0x4(%eax),%eax
80101b82:	83 e0 07             	and    $0x7,%eax
80101b85:	c1 e0 06             	shl    $0x6,%eax
80101b88:	01 d0                	add    %edx,%eax
80101b8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b90:	0f b7 10             	movzwl (%eax),%edx
80101b93:	8b 45 08             	mov    0x8(%ebp),%eax
80101b96:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b9d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101ba1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba4:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bab:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101baf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb2:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb9:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101bbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc0:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bc7:	8b 50 08             	mov    0x8(%eax),%edx
80101bca:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcd:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bd3:	8d 50 0c             	lea    0xc(%eax),%edx
80101bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd9:	83 c0 5c             	add    $0x5c,%eax
80101bdc:	83 ec 04             	sub    $0x4,%esp
80101bdf:	6a 34                	push   $0x34
80101be1:	52                   	push   %edx
80101be2:	50                   	push   %eax
80101be3:	e8 0c 3a 00 00       	call   801055f4 <memmove>
80101be8:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101beb:	83 ec 0c             	sub    $0xc,%esp
80101bee:	ff 75 f4             	pushl  -0xc(%ebp)
80101bf1:	e8 6b e6 ff ff       	call   80100261 <brelse>
80101bf6:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c03:	8b 45 08             	mov    0x8(%ebp),%eax
80101c06:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101c0a:	66 85 c0             	test   %ax,%ax
80101c0d:	75 0d                	jne    80101c1c <ilock+0x114>
      panic("ilock: no type");
80101c0f:	83 ec 0c             	sub    $0xc,%esp
80101c12:	68 17 92 10 80       	push   $0x80109217
80101c17:	e8 ec e9 ff ff       	call   80100608 <panic>
  }
}
80101c1c:	90                   	nop
80101c1d:	c9                   	leave  
80101c1e:	c3                   	ret    

80101c1f <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c1f:	f3 0f 1e fb          	endbr32 
80101c23:	55                   	push   %ebp
80101c24:	89 e5                	mov    %esp,%ebp
80101c26:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c29:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c2d:	74 20                	je     80101c4f <iunlock+0x30>
80101c2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c32:	83 c0 0c             	add    $0xc,%eax
80101c35:	83 ec 0c             	sub    $0xc,%esp
80101c38:	50                   	push   %eax
80101c39:	e8 91 35 00 00       	call   801051cf <holdingsleep>
80101c3e:	83 c4 10             	add    $0x10,%esp
80101c41:	85 c0                	test   %eax,%eax
80101c43:	74 0a                	je     80101c4f <iunlock+0x30>
80101c45:	8b 45 08             	mov    0x8(%ebp),%eax
80101c48:	8b 40 08             	mov    0x8(%eax),%eax
80101c4b:	85 c0                	test   %eax,%eax
80101c4d:	7f 0d                	jg     80101c5c <iunlock+0x3d>
    panic("iunlock");
80101c4f:	83 ec 0c             	sub    $0xc,%esp
80101c52:	68 26 92 10 80       	push   $0x80109226
80101c57:	e8 ac e9 ff ff       	call   80100608 <panic>

  releasesleep(&ip->lock);
80101c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5f:	83 c0 0c             	add    $0xc,%eax
80101c62:	83 ec 0c             	sub    $0xc,%esp
80101c65:	50                   	push   %eax
80101c66:	e8 12 35 00 00       	call   8010517d <releasesleep>
80101c6b:	83 c4 10             	add    $0x10,%esp
}
80101c6e:	90                   	nop
80101c6f:	c9                   	leave  
80101c70:	c3                   	ret    

80101c71 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c71:	f3 0f 1e fb          	endbr32 
80101c75:	55                   	push   %ebp
80101c76:	89 e5                	mov    %esp,%ebp
80101c78:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7e:	83 c0 0c             	add    $0xc,%eax
80101c81:	83 ec 0c             	sub    $0xc,%esp
80101c84:	50                   	push   %eax
80101c85:	e8 8b 34 00 00       	call   80105115 <acquiresleep>
80101c8a:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c90:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c93:	85 c0                	test   %eax,%eax
80101c95:	74 6a                	je     80101d01 <iput+0x90>
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c9e:	66 85 c0             	test   %ax,%ax
80101ca1:	75 5e                	jne    80101d01 <iput+0x90>
    acquire(&icache.lock);
80101ca3:	83 ec 0c             	sub    $0xc,%esp
80101ca6:	68 80 2a 11 80       	push   $0x80112a80
80101cab:	e8 de 35 00 00       	call   8010528e <acquire>
80101cb0:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb6:	8b 40 08             	mov    0x8(%eax),%eax
80101cb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101cbc:	83 ec 0c             	sub    $0xc,%esp
80101cbf:	68 80 2a 11 80       	push   $0x80112a80
80101cc4:	e8 37 36 00 00       	call   80105300 <release>
80101cc9:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ccc:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101cd0:	75 2f                	jne    80101d01 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101cd2:	83 ec 0c             	sub    $0xc,%esp
80101cd5:	ff 75 08             	pushl  0x8(%ebp)
80101cd8:	e8 b5 01 00 00       	call   80101e92 <itrunc>
80101cdd:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce3:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101ce9:	83 ec 0c             	sub    $0xc,%esp
80101cec:	ff 75 08             	pushl  0x8(%ebp)
80101cef:	e8 2b fc ff ff       	call   8010191f <iupdate>
80101cf4:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101cf7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfa:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101d01:	8b 45 08             	mov    0x8(%ebp),%eax
80101d04:	83 c0 0c             	add    $0xc,%eax
80101d07:	83 ec 0c             	sub    $0xc,%esp
80101d0a:	50                   	push   %eax
80101d0b:	e8 6d 34 00 00       	call   8010517d <releasesleep>
80101d10:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101d13:	83 ec 0c             	sub    $0xc,%esp
80101d16:	68 80 2a 11 80       	push   $0x80112a80
80101d1b:	e8 6e 35 00 00       	call   8010528e <acquire>
80101d20:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101d23:	8b 45 08             	mov    0x8(%ebp),%eax
80101d26:	8b 40 08             	mov    0x8(%eax),%eax
80101d29:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2f:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d32:	83 ec 0c             	sub    $0xc,%esp
80101d35:	68 80 2a 11 80       	push   $0x80112a80
80101d3a:	e8 c1 35 00 00       	call   80105300 <release>
80101d3f:	83 c4 10             	add    $0x10,%esp
}
80101d42:	90                   	nop
80101d43:	c9                   	leave  
80101d44:	c3                   	ret    

80101d45 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d45:	f3 0f 1e fb          	endbr32 
80101d49:	55                   	push   %ebp
80101d4a:	89 e5                	mov    %esp,%ebp
80101d4c:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d4f:	83 ec 0c             	sub    $0xc,%esp
80101d52:	ff 75 08             	pushl  0x8(%ebp)
80101d55:	e8 c5 fe ff ff       	call   80101c1f <iunlock>
80101d5a:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d5d:	83 ec 0c             	sub    $0xc,%esp
80101d60:	ff 75 08             	pushl  0x8(%ebp)
80101d63:	e8 09 ff ff ff       	call   80101c71 <iput>
80101d68:	83 c4 10             	add    $0x10,%esp
}
80101d6b:	90                   	nop
80101d6c:	c9                   	leave  
80101d6d:	c3                   	ret    

80101d6e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d6e:	f3 0f 1e fb          	endbr32 
80101d72:	55                   	push   %ebp
80101d73:	89 e5                	mov    %esp,%ebp
80101d75:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d78:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d7c:	77 42                	ja     80101dc0 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101d7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d81:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d84:	83 c2 14             	add    $0x14,%edx
80101d87:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d92:	75 24                	jne    80101db8 <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d94:	8b 45 08             	mov    0x8(%ebp),%eax
80101d97:	8b 00                	mov    (%eax),%eax
80101d99:	83 ec 0c             	sub    $0xc,%esp
80101d9c:	50                   	push   %eax
80101d9d:	e8 c7 f7 ff ff       	call   80101569 <balloc>
80101da2:	83 c4 10             	add    $0x10,%esp
80101da5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dab:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dae:	8d 4a 14             	lea    0x14(%edx),%ecx
80101db1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db4:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dbb:	e9 d0 00 00 00       	jmp    80101e90 <bmap+0x122>
  }
  bn -= NDIRECT;
80101dc0:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101dc4:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101dc8:	0f 87 b5 00 00 00    	ja     80101e83 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101dce:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd1:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dda:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dde:	75 20                	jne    80101e00 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101de0:	8b 45 08             	mov    0x8(%ebp),%eax
80101de3:	8b 00                	mov    (%eax),%eax
80101de5:	83 ec 0c             	sub    $0xc,%esp
80101de8:	50                   	push   %eax
80101de9:	e8 7b f7 ff ff       	call   80101569 <balloc>
80101dee:	83 c4 10             	add    $0x10,%esp
80101df1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101df4:	8b 45 08             	mov    0x8(%ebp),%eax
80101df7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dfa:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101e00:	8b 45 08             	mov    0x8(%ebp),%eax
80101e03:	8b 00                	mov    (%eax),%eax
80101e05:	83 ec 08             	sub    $0x8,%esp
80101e08:	ff 75 f4             	pushl  -0xc(%ebp)
80101e0b:	50                   	push   %eax
80101e0c:	e8 c6 e3 ff ff       	call   801001d7 <bread>
80101e11:	83 c4 10             	add    $0x10,%esp
80101e14:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1a:	83 c0 5c             	add    $0x5c,%eax
80101e1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e20:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e23:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e2d:	01 d0                	add    %edx,%eax
80101e2f:	8b 00                	mov    (%eax),%eax
80101e31:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e34:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e38:	75 36                	jne    80101e70 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101e3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3d:	8b 00                	mov    (%eax),%eax
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	50                   	push   %eax
80101e43:	e8 21 f7 ff ff       	call   80101569 <balloc>
80101e48:	83 c4 10             	add    $0x10,%esp
80101e4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e51:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e5b:	01 c2                	add    %eax,%edx
80101e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e60:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101e62:	83 ec 0c             	sub    $0xc,%esp
80101e65:	ff 75 f0             	pushl  -0x10(%ebp)
80101e68:	e8 b3 1a 00 00       	call   80103920 <log_write>
80101e6d:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e70:	83 ec 0c             	sub    $0xc,%esp
80101e73:	ff 75 f0             	pushl  -0x10(%ebp)
80101e76:	e8 e6 e3 ff ff       	call   80100261 <brelse>
80101e7b:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e81:	eb 0d                	jmp    80101e90 <bmap+0x122>
  }

  panic("bmap: out of range");
80101e83:	83 ec 0c             	sub    $0xc,%esp
80101e86:	68 2e 92 10 80       	push   $0x8010922e
80101e8b:	e8 78 e7 ff ff       	call   80100608 <panic>
}
80101e90:	c9                   	leave  
80101e91:	c3                   	ret    

80101e92 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e92:	f3 0f 1e fb          	endbr32 
80101e96:	55                   	push   %ebp
80101e97:	89 e5                	mov    %esp,%ebp
80101e99:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ea3:	eb 45                	jmp    80101eea <itrunc+0x58>
    if(ip->addrs[i]){
80101ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101eab:	83 c2 14             	add    $0x14,%edx
80101eae:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101eb2:	85 c0                	test   %eax,%eax
80101eb4:	74 30                	je     80101ee6 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101eb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ebc:	83 c2 14             	add    $0x14,%edx
80101ebf:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ec3:	8b 55 08             	mov    0x8(%ebp),%edx
80101ec6:	8b 12                	mov    (%edx),%edx
80101ec8:	83 ec 08             	sub    $0x8,%esp
80101ecb:	50                   	push   %eax
80101ecc:	52                   	push   %edx
80101ecd:	e8 e7 f7 ff ff       	call   801016b9 <bfree>
80101ed2:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101edb:	83 c2 14             	add    $0x14,%edx
80101ede:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101ee5:	00 
  for(i = 0; i < NDIRECT; i++){
80101ee6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101eea:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101eee:	7e b5                	jle    80101ea5 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101ef0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef3:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ef9:	85 c0                	test   %eax,%eax
80101efb:	0f 84 aa 00 00 00    	je     80101fab <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f01:	8b 45 08             	mov    0x8(%ebp),%eax
80101f04:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0d:	8b 00                	mov    (%eax),%eax
80101f0f:	83 ec 08             	sub    $0x8,%esp
80101f12:	52                   	push   %edx
80101f13:	50                   	push   %eax
80101f14:	e8 be e2 ff ff       	call   801001d7 <bread>
80101f19:	83 c4 10             	add    $0x10,%esp
80101f1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f22:	83 c0 5c             	add    $0x5c,%eax
80101f25:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f28:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f2f:	eb 3c                	jmp    80101f6d <itrunc+0xdb>
      if(a[j])
80101f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f3e:	01 d0                	add    %edx,%eax
80101f40:	8b 00                	mov    (%eax),%eax
80101f42:	85 c0                	test   %eax,%eax
80101f44:	74 23                	je     80101f69 <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f49:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f50:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f53:	01 d0                	add    %edx,%eax
80101f55:	8b 00                	mov    (%eax),%eax
80101f57:	8b 55 08             	mov    0x8(%ebp),%edx
80101f5a:	8b 12                	mov    (%edx),%edx
80101f5c:	83 ec 08             	sub    $0x8,%esp
80101f5f:	50                   	push   %eax
80101f60:	52                   	push   %edx
80101f61:	e8 53 f7 ff ff       	call   801016b9 <bfree>
80101f66:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101f69:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f70:	83 f8 7f             	cmp    $0x7f,%eax
80101f73:	76 bc                	jbe    80101f31 <itrunc+0x9f>
    }
    brelse(bp);
80101f75:	83 ec 0c             	sub    $0xc,%esp
80101f78:	ff 75 ec             	pushl  -0x14(%ebp)
80101f7b:	e8 e1 e2 ff ff       	call   80100261 <brelse>
80101f80:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f83:	8b 45 08             	mov    0x8(%ebp),%eax
80101f86:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f8c:	8b 55 08             	mov    0x8(%ebp),%edx
80101f8f:	8b 12                	mov    (%edx),%edx
80101f91:	83 ec 08             	sub    $0x8,%esp
80101f94:	50                   	push   %eax
80101f95:	52                   	push   %edx
80101f96:	e8 1e f7 ff ff       	call   801016b9 <bfree>
80101f9b:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa1:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101fa8:	00 00 00 
  }

  ip->size = 0;
80101fab:	8b 45 08             	mov    0x8(%ebp),%eax
80101fae:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101fb5:	83 ec 0c             	sub    $0xc,%esp
80101fb8:	ff 75 08             	pushl  0x8(%ebp)
80101fbb:	e8 5f f9 ff ff       	call   8010191f <iupdate>
80101fc0:	83 c4 10             	add    $0x10,%esp
}
80101fc3:	90                   	nop
80101fc4:	c9                   	leave  
80101fc5:	c3                   	ret    

80101fc6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101fc6:	f3 0f 1e fb          	endbr32 
80101fca:	55                   	push   %ebp
80101fcb:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd0:	8b 00                	mov    (%eax),%eax
80101fd2:	89 c2                	mov    %eax,%edx
80101fd4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fd7:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101fda:	8b 45 08             	mov    0x8(%ebp),%eax
80101fdd:	8b 50 04             	mov    0x4(%eax),%edx
80101fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fe3:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe9:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101fed:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ff0:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ff3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff6:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ffd:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80102001:	8b 45 08             	mov    0x8(%ebp),%eax
80102004:	8b 50 58             	mov    0x58(%eax),%edx
80102007:	8b 45 0c             	mov    0xc(%ebp),%eax
8010200a:	89 50 10             	mov    %edx,0x10(%eax)
}
8010200d:	90                   	nop
8010200e:	5d                   	pop    %ebp
8010200f:	c3                   	ret    

80102010 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80102010:	f3 0f 1e fb          	endbr32 
80102014:	55                   	push   %ebp
80102015:	89 e5                	mov    %esp,%ebp
80102017:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010201a:	8b 45 08             	mov    0x8(%ebp),%eax
8010201d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102021:	66 83 f8 03          	cmp    $0x3,%ax
80102025:	75 5c                	jne    80102083 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102027:	8b 45 08             	mov    0x8(%ebp),%eax
8010202a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010202e:	66 85 c0             	test   %ax,%ax
80102031:	78 20                	js     80102053 <readi+0x43>
80102033:	8b 45 08             	mov    0x8(%ebp),%eax
80102036:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010203a:	66 83 f8 09          	cmp    $0x9,%ax
8010203e:	7f 13                	jg     80102053 <readi+0x43>
80102040:	8b 45 08             	mov    0x8(%ebp),%eax
80102043:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102047:	98                   	cwtl   
80102048:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
8010204f:	85 c0                	test   %eax,%eax
80102051:	75 0a                	jne    8010205d <readi+0x4d>
      return -1;
80102053:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102058:	e9 0a 01 00 00       	jmp    80102167 <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
8010205d:	8b 45 08             	mov    0x8(%ebp),%eax
80102060:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102064:	98                   	cwtl   
80102065:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
8010206c:	8b 55 14             	mov    0x14(%ebp),%edx
8010206f:	83 ec 04             	sub    $0x4,%esp
80102072:	52                   	push   %edx
80102073:	ff 75 0c             	pushl  0xc(%ebp)
80102076:	ff 75 08             	pushl  0x8(%ebp)
80102079:	ff d0                	call   *%eax
8010207b:	83 c4 10             	add    $0x10,%esp
8010207e:	e9 e4 00 00 00       	jmp    80102167 <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80102083:	8b 45 08             	mov    0x8(%ebp),%eax
80102086:	8b 40 58             	mov    0x58(%eax),%eax
80102089:	39 45 10             	cmp    %eax,0x10(%ebp)
8010208c:	77 0d                	ja     8010209b <readi+0x8b>
8010208e:	8b 55 10             	mov    0x10(%ebp),%edx
80102091:	8b 45 14             	mov    0x14(%ebp),%eax
80102094:	01 d0                	add    %edx,%eax
80102096:	39 45 10             	cmp    %eax,0x10(%ebp)
80102099:	76 0a                	jbe    801020a5 <readi+0x95>
    return -1;
8010209b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020a0:	e9 c2 00 00 00       	jmp    80102167 <readi+0x157>
  if(off + n > ip->size)
801020a5:	8b 55 10             	mov    0x10(%ebp),%edx
801020a8:	8b 45 14             	mov    0x14(%ebp),%eax
801020ab:	01 c2                	add    %eax,%edx
801020ad:	8b 45 08             	mov    0x8(%ebp),%eax
801020b0:	8b 40 58             	mov    0x58(%eax),%eax
801020b3:	39 c2                	cmp    %eax,%edx
801020b5:	76 0c                	jbe    801020c3 <readi+0xb3>
    n = ip->size - off;
801020b7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ba:	8b 40 58             	mov    0x58(%eax),%eax
801020bd:	2b 45 10             	sub    0x10(%ebp),%eax
801020c0:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020ca:	e9 89 00 00 00       	jmp    80102158 <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020cf:	8b 45 10             	mov    0x10(%ebp),%eax
801020d2:	c1 e8 09             	shr    $0x9,%eax
801020d5:	83 ec 08             	sub    $0x8,%esp
801020d8:	50                   	push   %eax
801020d9:	ff 75 08             	pushl  0x8(%ebp)
801020dc:	e8 8d fc ff ff       	call   80101d6e <bmap>
801020e1:	83 c4 10             	add    $0x10,%esp
801020e4:	8b 55 08             	mov    0x8(%ebp),%edx
801020e7:	8b 12                	mov    (%edx),%edx
801020e9:	83 ec 08             	sub    $0x8,%esp
801020ec:	50                   	push   %eax
801020ed:	52                   	push   %edx
801020ee:	e8 e4 e0 ff ff       	call   801001d7 <bread>
801020f3:	83 c4 10             	add    $0x10,%esp
801020f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020f9:	8b 45 10             	mov    0x10(%ebp),%eax
801020fc:	25 ff 01 00 00       	and    $0x1ff,%eax
80102101:	ba 00 02 00 00       	mov    $0x200,%edx
80102106:	29 c2                	sub    %eax,%edx
80102108:	8b 45 14             	mov    0x14(%ebp),%eax
8010210b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010210e:	39 c2                	cmp    %eax,%edx
80102110:	0f 46 c2             	cmovbe %edx,%eax
80102113:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102116:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102119:	8d 50 5c             	lea    0x5c(%eax),%edx
8010211c:	8b 45 10             	mov    0x10(%ebp),%eax
8010211f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102124:	01 d0                	add    %edx,%eax
80102126:	83 ec 04             	sub    $0x4,%esp
80102129:	ff 75 ec             	pushl  -0x14(%ebp)
8010212c:	50                   	push   %eax
8010212d:	ff 75 0c             	pushl  0xc(%ebp)
80102130:	e8 bf 34 00 00       	call   801055f4 <memmove>
80102135:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102138:	83 ec 0c             	sub    $0xc,%esp
8010213b:	ff 75 f0             	pushl  -0x10(%ebp)
8010213e:	e8 1e e1 ff ff       	call   80100261 <brelse>
80102143:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102146:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102149:	01 45 f4             	add    %eax,-0xc(%ebp)
8010214c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010214f:	01 45 10             	add    %eax,0x10(%ebp)
80102152:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102155:	01 45 0c             	add    %eax,0xc(%ebp)
80102158:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010215b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010215e:	0f 82 6b ff ff ff    	jb     801020cf <readi+0xbf>
  }
  return n;
80102164:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102167:	c9                   	leave  
80102168:	c3                   	ret    

80102169 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102169:	f3 0f 1e fb          	endbr32 
8010216d:	55                   	push   %ebp
8010216e:	89 e5                	mov    %esp,%ebp
80102170:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102173:	8b 45 08             	mov    0x8(%ebp),%eax
80102176:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010217a:	66 83 f8 03          	cmp    $0x3,%ax
8010217e:	75 5c                	jne    801021dc <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102180:	8b 45 08             	mov    0x8(%ebp),%eax
80102183:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102187:	66 85 c0             	test   %ax,%ax
8010218a:	78 20                	js     801021ac <writei+0x43>
8010218c:	8b 45 08             	mov    0x8(%ebp),%eax
8010218f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102193:	66 83 f8 09          	cmp    $0x9,%ax
80102197:	7f 13                	jg     801021ac <writei+0x43>
80102199:	8b 45 08             	mov    0x8(%ebp),%eax
8010219c:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021a0:	98                   	cwtl   
801021a1:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021a8:	85 c0                	test   %eax,%eax
801021aa:	75 0a                	jne    801021b6 <writei+0x4d>
      return -1;
801021ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021b1:	e9 3b 01 00 00       	jmp    801022f1 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
801021b6:	8b 45 08             	mov    0x8(%ebp),%eax
801021b9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021bd:	98                   	cwtl   
801021be:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021c5:	8b 55 14             	mov    0x14(%ebp),%edx
801021c8:	83 ec 04             	sub    $0x4,%esp
801021cb:	52                   	push   %edx
801021cc:	ff 75 0c             	pushl  0xc(%ebp)
801021cf:	ff 75 08             	pushl  0x8(%ebp)
801021d2:	ff d0                	call   *%eax
801021d4:	83 c4 10             	add    $0x10,%esp
801021d7:	e9 15 01 00 00       	jmp    801022f1 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
801021dc:	8b 45 08             	mov    0x8(%ebp),%eax
801021df:	8b 40 58             	mov    0x58(%eax),%eax
801021e2:	39 45 10             	cmp    %eax,0x10(%ebp)
801021e5:	77 0d                	ja     801021f4 <writei+0x8b>
801021e7:	8b 55 10             	mov    0x10(%ebp),%edx
801021ea:	8b 45 14             	mov    0x14(%ebp),%eax
801021ed:	01 d0                	add    %edx,%eax
801021ef:	39 45 10             	cmp    %eax,0x10(%ebp)
801021f2:	76 0a                	jbe    801021fe <writei+0x95>
    return -1;
801021f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021f9:	e9 f3 00 00 00       	jmp    801022f1 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
801021fe:	8b 55 10             	mov    0x10(%ebp),%edx
80102201:	8b 45 14             	mov    0x14(%ebp),%eax
80102204:	01 d0                	add    %edx,%eax
80102206:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010220b:	76 0a                	jbe    80102217 <writei+0xae>
    return -1;
8010220d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102212:	e9 da 00 00 00       	jmp    801022f1 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102217:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010221e:	e9 97 00 00 00       	jmp    801022ba <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102223:	8b 45 10             	mov    0x10(%ebp),%eax
80102226:	c1 e8 09             	shr    $0x9,%eax
80102229:	83 ec 08             	sub    $0x8,%esp
8010222c:	50                   	push   %eax
8010222d:	ff 75 08             	pushl  0x8(%ebp)
80102230:	e8 39 fb ff ff       	call   80101d6e <bmap>
80102235:	83 c4 10             	add    $0x10,%esp
80102238:	8b 55 08             	mov    0x8(%ebp),%edx
8010223b:	8b 12                	mov    (%edx),%edx
8010223d:	83 ec 08             	sub    $0x8,%esp
80102240:	50                   	push   %eax
80102241:	52                   	push   %edx
80102242:	e8 90 df ff ff       	call   801001d7 <bread>
80102247:	83 c4 10             	add    $0x10,%esp
8010224a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010224d:	8b 45 10             	mov    0x10(%ebp),%eax
80102250:	25 ff 01 00 00       	and    $0x1ff,%eax
80102255:	ba 00 02 00 00       	mov    $0x200,%edx
8010225a:	29 c2                	sub    %eax,%edx
8010225c:	8b 45 14             	mov    0x14(%ebp),%eax
8010225f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102262:	39 c2                	cmp    %eax,%edx
80102264:	0f 46 c2             	cmovbe %edx,%eax
80102267:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010226a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010226d:	8d 50 5c             	lea    0x5c(%eax),%edx
80102270:	8b 45 10             	mov    0x10(%ebp),%eax
80102273:	25 ff 01 00 00       	and    $0x1ff,%eax
80102278:	01 d0                	add    %edx,%eax
8010227a:	83 ec 04             	sub    $0x4,%esp
8010227d:	ff 75 ec             	pushl  -0x14(%ebp)
80102280:	ff 75 0c             	pushl  0xc(%ebp)
80102283:	50                   	push   %eax
80102284:	e8 6b 33 00 00       	call   801055f4 <memmove>
80102289:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010228c:	83 ec 0c             	sub    $0xc,%esp
8010228f:	ff 75 f0             	pushl  -0x10(%ebp)
80102292:	e8 89 16 00 00       	call   80103920 <log_write>
80102297:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010229a:	83 ec 0c             	sub    $0xc,%esp
8010229d:	ff 75 f0             	pushl  -0x10(%ebp)
801022a0:	e8 bc df ff ff       	call   80100261 <brelse>
801022a5:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022ab:	01 45 f4             	add    %eax,-0xc(%ebp)
801022ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022b1:	01 45 10             	add    %eax,0x10(%ebp)
801022b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022b7:	01 45 0c             	add    %eax,0xc(%ebp)
801022ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022bd:	3b 45 14             	cmp    0x14(%ebp),%eax
801022c0:	0f 82 5d ff ff ff    	jb     80102223 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
801022c6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801022ca:	74 22                	je     801022ee <writei+0x185>
801022cc:	8b 45 08             	mov    0x8(%ebp),%eax
801022cf:	8b 40 58             	mov    0x58(%eax),%eax
801022d2:	39 45 10             	cmp    %eax,0x10(%ebp)
801022d5:	76 17                	jbe    801022ee <writei+0x185>
    ip->size = off;
801022d7:	8b 45 08             	mov    0x8(%ebp),%eax
801022da:	8b 55 10             	mov    0x10(%ebp),%edx
801022dd:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801022e0:	83 ec 0c             	sub    $0xc,%esp
801022e3:	ff 75 08             	pushl  0x8(%ebp)
801022e6:	e8 34 f6 ff ff       	call   8010191f <iupdate>
801022eb:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801022ee:	8b 45 14             	mov    0x14(%ebp),%eax
}
801022f1:	c9                   	leave  
801022f2:	c3                   	ret    

801022f3 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801022f3:	f3 0f 1e fb          	endbr32 
801022f7:	55                   	push   %ebp
801022f8:	89 e5                	mov    %esp,%ebp
801022fa:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801022fd:	83 ec 04             	sub    $0x4,%esp
80102300:	6a 0e                	push   $0xe
80102302:	ff 75 0c             	pushl  0xc(%ebp)
80102305:	ff 75 08             	pushl  0x8(%ebp)
80102308:	e8 85 33 00 00       	call   80105692 <strncmp>
8010230d:	83 c4 10             	add    $0x10,%esp
}
80102310:	c9                   	leave  
80102311:	c3                   	ret    

80102312 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102312:	f3 0f 1e fb          	endbr32 
80102316:	55                   	push   %ebp
80102317:	89 e5                	mov    %esp,%ebp
80102319:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010231c:	8b 45 08             	mov    0x8(%ebp),%eax
8010231f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102323:	66 83 f8 01          	cmp    $0x1,%ax
80102327:	74 0d                	je     80102336 <dirlookup+0x24>
    panic("dirlookup not DIR");
80102329:	83 ec 0c             	sub    $0xc,%esp
8010232c:	68 41 92 10 80       	push   $0x80109241
80102331:	e8 d2 e2 ff ff       	call   80100608 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102336:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010233d:	eb 7b                	jmp    801023ba <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010233f:	6a 10                	push   $0x10
80102341:	ff 75 f4             	pushl  -0xc(%ebp)
80102344:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102347:	50                   	push   %eax
80102348:	ff 75 08             	pushl  0x8(%ebp)
8010234b:	e8 c0 fc ff ff       	call   80102010 <readi>
80102350:	83 c4 10             	add    $0x10,%esp
80102353:	83 f8 10             	cmp    $0x10,%eax
80102356:	74 0d                	je     80102365 <dirlookup+0x53>
      panic("dirlookup read");
80102358:	83 ec 0c             	sub    $0xc,%esp
8010235b:	68 53 92 10 80       	push   $0x80109253
80102360:	e8 a3 e2 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
80102365:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102369:	66 85 c0             	test   %ax,%ax
8010236c:	74 47                	je     801023b5 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
8010236e:	83 ec 08             	sub    $0x8,%esp
80102371:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102374:	83 c0 02             	add    $0x2,%eax
80102377:	50                   	push   %eax
80102378:	ff 75 0c             	pushl  0xc(%ebp)
8010237b:	e8 73 ff ff ff       	call   801022f3 <namecmp>
80102380:	83 c4 10             	add    $0x10,%esp
80102383:	85 c0                	test   %eax,%eax
80102385:	75 2f                	jne    801023b6 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
80102387:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010238b:	74 08                	je     80102395 <dirlookup+0x83>
        *poff = off;
8010238d:	8b 45 10             	mov    0x10(%ebp),%eax
80102390:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102393:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102395:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102399:	0f b7 c0             	movzwl %ax,%eax
8010239c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010239f:	8b 45 08             	mov    0x8(%ebp),%eax
801023a2:	8b 00                	mov    (%eax),%eax
801023a4:	83 ec 08             	sub    $0x8,%esp
801023a7:	ff 75 f0             	pushl  -0x10(%ebp)
801023aa:	50                   	push   %eax
801023ab:	e8 34 f6 ff ff       	call   801019e4 <iget>
801023b0:	83 c4 10             	add    $0x10,%esp
801023b3:	eb 19                	jmp    801023ce <dirlookup+0xbc>
      continue;
801023b5:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
801023b6:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801023ba:	8b 45 08             	mov    0x8(%ebp),%eax
801023bd:	8b 40 58             	mov    0x58(%eax),%eax
801023c0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801023c3:	0f 82 76 ff ff ff    	jb     8010233f <dirlookup+0x2d>
    }
  }

  return 0;
801023c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023ce:	c9                   	leave  
801023cf:	c3                   	ret    

801023d0 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801023d0:	f3 0f 1e fb          	endbr32 
801023d4:	55                   	push   %ebp
801023d5:	89 e5                	mov    %esp,%ebp
801023d7:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801023da:	83 ec 04             	sub    $0x4,%esp
801023dd:	6a 00                	push   $0x0
801023df:	ff 75 0c             	pushl  0xc(%ebp)
801023e2:	ff 75 08             	pushl  0x8(%ebp)
801023e5:	e8 28 ff ff ff       	call   80102312 <dirlookup>
801023ea:	83 c4 10             	add    $0x10,%esp
801023ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023f4:	74 18                	je     8010240e <dirlink+0x3e>
    iput(ip);
801023f6:	83 ec 0c             	sub    $0xc,%esp
801023f9:	ff 75 f0             	pushl  -0x10(%ebp)
801023fc:	e8 70 f8 ff ff       	call   80101c71 <iput>
80102401:	83 c4 10             	add    $0x10,%esp
    return -1;
80102404:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102409:	e9 9c 00 00 00       	jmp    801024aa <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010240e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102415:	eb 39                	jmp    80102450 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010241a:	6a 10                	push   $0x10
8010241c:	50                   	push   %eax
8010241d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102420:	50                   	push   %eax
80102421:	ff 75 08             	pushl  0x8(%ebp)
80102424:	e8 e7 fb ff ff       	call   80102010 <readi>
80102429:	83 c4 10             	add    $0x10,%esp
8010242c:	83 f8 10             	cmp    $0x10,%eax
8010242f:	74 0d                	je     8010243e <dirlink+0x6e>
      panic("dirlink read");
80102431:	83 ec 0c             	sub    $0xc,%esp
80102434:	68 62 92 10 80       	push   $0x80109262
80102439:	e8 ca e1 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
8010243e:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102442:	66 85 c0             	test   %ax,%ax
80102445:	74 18                	je     8010245f <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010244a:	83 c0 10             	add    $0x10,%eax
8010244d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102450:	8b 45 08             	mov    0x8(%ebp),%eax
80102453:	8b 50 58             	mov    0x58(%eax),%edx
80102456:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102459:	39 c2                	cmp    %eax,%edx
8010245b:	77 ba                	ja     80102417 <dirlink+0x47>
8010245d:	eb 01                	jmp    80102460 <dirlink+0x90>
      break;
8010245f:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102460:	83 ec 04             	sub    $0x4,%esp
80102463:	6a 0e                	push   $0xe
80102465:	ff 75 0c             	pushl  0xc(%ebp)
80102468:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010246b:	83 c0 02             	add    $0x2,%eax
8010246e:	50                   	push   %eax
8010246f:	e8 78 32 00 00       	call   801056ec <strncpy>
80102474:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102477:	8b 45 10             	mov    0x10(%ebp),%eax
8010247a:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010247e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102481:	6a 10                	push   $0x10
80102483:	50                   	push   %eax
80102484:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102487:	50                   	push   %eax
80102488:	ff 75 08             	pushl  0x8(%ebp)
8010248b:	e8 d9 fc ff ff       	call   80102169 <writei>
80102490:	83 c4 10             	add    $0x10,%esp
80102493:	83 f8 10             	cmp    $0x10,%eax
80102496:	74 0d                	je     801024a5 <dirlink+0xd5>
    panic("dirlink");
80102498:	83 ec 0c             	sub    $0xc,%esp
8010249b:	68 6f 92 10 80       	push   $0x8010926f
801024a0:	e8 63 e1 ff ff       	call   80100608 <panic>

  return 0;
801024a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024aa:	c9                   	leave  
801024ab:	c3                   	ret    

801024ac <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801024ac:	f3 0f 1e fb          	endbr32 
801024b0:	55                   	push   %ebp
801024b1:	89 e5                	mov    %esp,%ebp
801024b3:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801024b6:	eb 04                	jmp    801024bc <skipelem+0x10>
    path++;
801024b8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024bc:	8b 45 08             	mov    0x8(%ebp),%eax
801024bf:	0f b6 00             	movzbl (%eax),%eax
801024c2:	3c 2f                	cmp    $0x2f,%al
801024c4:	74 f2                	je     801024b8 <skipelem+0xc>
  if(*path == 0)
801024c6:	8b 45 08             	mov    0x8(%ebp),%eax
801024c9:	0f b6 00             	movzbl (%eax),%eax
801024cc:	84 c0                	test   %al,%al
801024ce:	75 07                	jne    801024d7 <skipelem+0x2b>
    return 0;
801024d0:	b8 00 00 00 00       	mov    $0x0,%eax
801024d5:	eb 77                	jmp    8010254e <skipelem+0xa2>
  s = path;
801024d7:	8b 45 08             	mov    0x8(%ebp),%eax
801024da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801024dd:	eb 04                	jmp    801024e3 <skipelem+0x37>
    path++;
801024df:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801024e3:	8b 45 08             	mov    0x8(%ebp),%eax
801024e6:	0f b6 00             	movzbl (%eax),%eax
801024e9:	3c 2f                	cmp    $0x2f,%al
801024eb:	74 0a                	je     801024f7 <skipelem+0x4b>
801024ed:	8b 45 08             	mov    0x8(%ebp),%eax
801024f0:	0f b6 00             	movzbl (%eax),%eax
801024f3:	84 c0                	test   %al,%al
801024f5:	75 e8                	jne    801024df <skipelem+0x33>
  len = path - s;
801024f7:	8b 45 08             	mov    0x8(%ebp),%eax
801024fa:	2b 45 f4             	sub    -0xc(%ebp),%eax
801024fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102500:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102504:	7e 15                	jle    8010251b <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102506:	83 ec 04             	sub    $0x4,%esp
80102509:	6a 0e                	push   $0xe
8010250b:	ff 75 f4             	pushl  -0xc(%ebp)
8010250e:	ff 75 0c             	pushl  0xc(%ebp)
80102511:	e8 de 30 00 00       	call   801055f4 <memmove>
80102516:	83 c4 10             	add    $0x10,%esp
80102519:	eb 26                	jmp    80102541 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010251b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010251e:	83 ec 04             	sub    $0x4,%esp
80102521:	50                   	push   %eax
80102522:	ff 75 f4             	pushl  -0xc(%ebp)
80102525:	ff 75 0c             	pushl  0xc(%ebp)
80102528:	e8 c7 30 00 00       	call   801055f4 <memmove>
8010252d:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102530:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102533:	8b 45 0c             	mov    0xc(%ebp),%eax
80102536:	01 d0                	add    %edx,%eax
80102538:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010253b:	eb 04                	jmp    80102541 <skipelem+0x95>
    path++;
8010253d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102541:	8b 45 08             	mov    0x8(%ebp),%eax
80102544:	0f b6 00             	movzbl (%eax),%eax
80102547:	3c 2f                	cmp    $0x2f,%al
80102549:	74 f2                	je     8010253d <skipelem+0x91>
  return path;
8010254b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010254e:	c9                   	leave  
8010254f:	c3                   	ret    

80102550 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102550:	f3 0f 1e fb          	endbr32 
80102554:	55                   	push   %ebp
80102555:	89 e5                	mov    %esp,%ebp
80102557:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010255a:	8b 45 08             	mov    0x8(%ebp),%eax
8010255d:	0f b6 00             	movzbl (%eax),%eax
80102560:	3c 2f                	cmp    $0x2f,%al
80102562:	75 17                	jne    8010257b <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
80102564:	83 ec 08             	sub    $0x8,%esp
80102567:	6a 01                	push   $0x1
80102569:	6a 01                	push   $0x1
8010256b:	e8 74 f4 ff ff       	call   801019e4 <iget>
80102570:	83 c4 10             	add    $0x10,%esp
80102573:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102576:	e9 ba 00 00 00       	jmp    80102635 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
8010257b:	e8 16 1f 00 00       	call   80104496 <myproc>
80102580:	8b 40 6c             	mov    0x6c(%eax),%eax
80102583:	83 ec 0c             	sub    $0xc,%esp
80102586:	50                   	push   %eax
80102587:	e8 3e f5 ff ff       	call   80101aca <idup>
8010258c:	83 c4 10             	add    $0x10,%esp
8010258f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102592:	e9 9e 00 00 00       	jmp    80102635 <namex+0xe5>
    ilock(ip);
80102597:	83 ec 0c             	sub    $0xc,%esp
8010259a:	ff 75 f4             	pushl  -0xc(%ebp)
8010259d:	e8 66 f5 ff ff       	call   80101b08 <ilock>
801025a2:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801025a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025a8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801025ac:	66 83 f8 01          	cmp    $0x1,%ax
801025b0:	74 18                	je     801025ca <namex+0x7a>
      iunlockput(ip);
801025b2:	83 ec 0c             	sub    $0xc,%esp
801025b5:	ff 75 f4             	pushl  -0xc(%ebp)
801025b8:	e8 88 f7 ff ff       	call   80101d45 <iunlockput>
801025bd:	83 c4 10             	add    $0x10,%esp
      return 0;
801025c0:	b8 00 00 00 00       	mov    $0x0,%eax
801025c5:	e9 a7 00 00 00       	jmp    80102671 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
801025ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025ce:	74 20                	je     801025f0 <namex+0xa0>
801025d0:	8b 45 08             	mov    0x8(%ebp),%eax
801025d3:	0f b6 00             	movzbl (%eax),%eax
801025d6:	84 c0                	test   %al,%al
801025d8:	75 16                	jne    801025f0 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
801025da:	83 ec 0c             	sub    $0xc,%esp
801025dd:	ff 75 f4             	pushl  -0xc(%ebp)
801025e0:	e8 3a f6 ff ff       	call   80101c1f <iunlock>
801025e5:	83 c4 10             	add    $0x10,%esp
      return ip;
801025e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025eb:	e9 81 00 00 00       	jmp    80102671 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801025f0:	83 ec 04             	sub    $0x4,%esp
801025f3:	6a 00                	push   $0x0
801025f5:	ff 75 10             	pushl  0x10(%ebp)
801025f8:	ff 75 f4             	pushl  -0xc(%ebp)
801025fb:	e8 12 fd ff ff       	call   80102312 <dirlookup>
80102600:	83 c4 10             	add    $0x10,%esp
80102603:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102606:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010260a:	75 15                	jne    80102621 <namex+0xd1>
      iunlockput(ip);
8010260c:	83 ec 0c             	sub    $0xc,%esp
8010260f:	ff 75 f4             	pushl  -0xc(%ebp)
80102612:	e8 2e f7 ff ff       	call   80101d45 <iunlockput>
80102617:	83 c4 10             	add    $0x10,%esp
      return 0;
8010261a:	b8 00 00 00 00       	mov    $0x0,%eax
8010261f:	eb 50                	jmp    80102671 <namex+0x121>
    }
    iunlockput(ip);
80102621:	83 ec 0c             	sub    $0xc,%esp
80102624:	ff 75 f4             	pushl  -0xc(%ebp)
80102627:	e8 19 f7 ff ff       	call   80101d45 <iunlockput>
8010262c:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010262f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102632:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
80102635:	83 ec 08             	sub    $0x8,%esp
80102638:	ff 75 10             	pushl  0x10(%ebp)
8010263b:	ff 75 08             	pushl  0x8(%ebp)
8010263e:	e8 69 fe ff ff       	call   801024ac <skipelem>
80102643:	83 c4 10             	add    $0x10,%esp
80102646:	89 45 08             	mov    %eax,0x8(%ebp)
80102649:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010264d:	0f 85 44 ff ff ff    	jne    80102597 <namex+0x47>
  }
  if(nameiparent){
80102653:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102657:	74 15                	je     8010266e <namex+0x11e>
    iput(ip);
80102659:	83 ec 0c             	sub    $0xc,%esp
8010265c:	ff 75 f4             	pushl  -0xc(%ebp)
8010265f:	e8 0d f6 ff ff       	call   80101c71 <iput>
80102664:	83 c4 10             	add    $0x10,%esp
    return 0;
80102667:	b8 00 00 00 00       	mov    $0x0,%eax
8010266c:	eb 03                	jmp    80102671 <namex+0x121>
  }
  return ip;
8010266e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102671:	c9                   	leave  
80102672:	c3                   	ret    

80102673 <namei>:

struct inode*
namei(char *path)
{
80102673:	f3 0f 1e fb          	endbr32 
80102677:	55                   	push   %ebp
80102678:	89 e5                	mov    %esp,%ebp
8010267a:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010267d:	83 ec 04             	sub    $0x4,%esp
80102680:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102683:	50                   	push   %eax
80102684:	6a 00                	push   $0x0
80102686:	ff 75 08             	pushl  0x8(%ebp)
80102689:	e8 c2 fe ff ff       	call   80102550 <namex>
8010268e:	83 c4 10             	add    $0x10,%esp
}
80102691:	c9                   	leave  
80102692:	c3                   	ret    

80102693 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102693:	f3 0f 1e fb          	endbr32 
80102697:	55                   	push   %ebp
80102698:	89 e5                	mov    %esp,%ebp
8010269a:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010269d:	83 ec 04             	sub    $0x4,%esp
801026a0:	ff 75 0c             	pushl  0xc(%ebp)
801026a3:	6a 01                	push   $0x1
801026a5:	ff 75 08             	pushl  0x8(%ebp)
801026a8:	e8 a3 fe ff ff       	call   80102550 <namex>
801026ad:	83 c4 10             	add    $0x10,%esp
}
801026b0:	c9                   	leave  
801026b1:	c3                   	ret    

801026b2 <inb>:
{
801026b2:	55                   	push   %ebp
801026b3:	89 e5                	mov    %esp,%ebp
801026b5:	83 ec 14             	sub    $0x14,%esp
801026b8:	8b 45 08             	mov    0x8(%ebp),%eax
801026bb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801026bf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801026c3:	89 c2                	mov    %eax,%edx
801026c5:	ec                   	in     (%dx),%al
801026c6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801026c9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801026cd:	c9                   	leave  
801026ce:	c3                   	ret    

801026cf <insl>:
{
801026cf:	55                   	push   %ebp
801026d0:	89 e5                	mov    %esp,%ebp
801026d2:	57                   	push   %edi
801026d3:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801026d4:	8b 55 08             	mov    0x8(%ebp),%edx
801026d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026da:	8b 45 10             	mov    0x10(%ebp),%eax
801026dd:	89 cb                	mov    %ecx,%ebx
801026df:	89 df                	mov    %ebx,%edi
801026e1:	89 c1                	mov    %eax,%ecx
801026e3:	fc                   	cld    
801026e4:	f3 6d                	rep insl (%dx),%es:(%edi)
801026e6:	89 c8                	mov    %ecx,%eax
801026e8:	89 fb                	mov    %edi,%ebx
801026ea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026ed:	89 45 10             	mov    %eax,0x10(%ebp)
}
801026f0:	90                   	nop
801026f1:	5b                   	pop    %ebx
801026f2:	5f                   	pop    %edi
801026f3:	5d                   	pop    %ebp
801026f4:	c3                   	ret    

801026f5 <outb>:
{
801026f5:	55                   	push   %ebp
801026f6:	89 e5                	mov    %esp,%ebp
801026f8:	83 ec 08             	sub    $0x8,%esp
801026fb:	8b 45 08             	mov    0x8(%ebp),%eax
801026fe:	8b 55 0c             	mov    0xc(%ebp),%edx
80102701:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102705:	89 d0                	mov    %edx,%eax
80102707:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010270a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010270e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102712:	ee                   	out    %al,(%dx)
}
80102713:	90                   	nop
80102714:	c9                   	leave  
80102715:	c3                   	ret    

80102716 <outsl>:
{
80102716:	55                   	push   %ebp
80102717:	89 e5                	mov    %esp,%ebp
80102719:	56                   	push   %esi
8010271a:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010271b:	8b 55 08             	mov    0x8(%ebp),%edx
8010271e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102721:	8b 45 10             	mov    0x10(%ebp),%eax
80102724:	89 cb                	mov    %ecx,%ebx
80102726:	89 de                	mov    %ebx,%esi
80102728:	89 c1                	mov    %eax,%ecx
8010272a:	fc                   	cld    
8010272b:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010272d:	89 c8                	mov    %ecx,%eax
8010272f:	89 f3                	mov    %esi,%ebx
80102731:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102734:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102737:	90                   	nop
80102738:	5b                   	pop    %ebx
80102739:	5e                   	pop    %esi
8010273a:	5d                   	pop    %ebp
8010273b:	c3                   	ret    

8010273c <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010273c:	f3 0f 1e fb          	endbr32 
80102740:	55                   	push   %ebp
80102741:	89 e5                	mov    %esp,%ebp
80102743:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102746:	90                   	nop
80102747:	68 f7 01 00 00       	push   $0x1f7
8010274c:	e8 61 ff ff ff       	call   801026b2 <inb>
80102751:	83 c4 04             	add    $0x4,%esp
80102754:	0f b6 c0             	movzbl %al,%eax
80102757:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010275a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010275d:	25 c0 00 00 00       	and    $0xc0,%eax
80102762:	83 f8 40             	cmp    $0x40,%eax
80102765:	75 e0                	jne    80102747 <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102767:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010276b:	74 11                	je     8010277e <idewait+0x42>
8010276d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102770:	83 e0 21             	and    $0x21,%eax
80102773:	85 c0                	test   %eax,%eax
80102775:	74 07                	je     8010277e <idewait+0x42>
    return -1;
80102777:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010277c:	eb 05                	jmp    80102783 <idewait+0x47>
  return 0;
8010277e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102783:	c9                   	leave  
80102784:	c3                   	ret    

80102785 <ideinit>:

void
ideinit(void)
{
80102785:	f3 0f 1e fb          	endbr32 
80102789:	55                   	push   %ebp
8010278a:	89 e5                	mov    %esp,%ebp
8010278c:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
8010278f:	83 ec 08             	sub    $0x8,%esp
80102792:	68 77 92 10 80       	push   $0x80109277
80102797:	68 00 c6 10 80       	push   $0x8010c600
8010279c:	e8 c7 2a 00 00       	call   80105268 <initlock>
801027a1:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801027a4:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
801027a9:	83 e8 01             	sub    $0x1,%eax
801027ac:	83 ec 08             	sub    $0x8,%esp
801027af:	50                   	push   %eax
801027b0:	6a 0e                	push   $0xe
801027b2:	e8 bb 04 00 00       	call   80102c72 <ioapicenable>
801027b7:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801027ba:	83 ec 0c             	sub    $0xc,%esp
801027bd:	6a 00                	push   $0x0
801027bf:	e8 78 ff ff ff       	call   8010273c <idewait>
801027c4:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801027c7:	83 ec 08             	sub    $0x8,%esp
801027ca:	68 f0 00 00 00       	push   $0xf0
801027cf:	68 f6 01 00 00       	push   $0x1f6
801027d4:	e8 1c ff ff ff       	call   801026f5 <outb>
801027d9:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
801027dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801027e3:	eb 24                	jmp    80102809 <ideinit+0x84>
    if(inb(0x1f7) != 0){
801027e5:	83 ec 0c             	sub    $0xc,%esp
801027e8:	68 f7 01 00 00       	push   $0x1f7
801027ed:	e8 c0 fe ff ff       	call   801026b2 <inb>
801027f2:	83 c4 10             	add    $0x10,%esp
801027f5:	84 c0                	test   %al,%al
801027f7:	74 0c                	je     80102805 <ideinit+0x80>
      havedisk1 = 1;
801027f9:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102800:	00 00 00 
      break;
80102803:	eb 0d                	jmp    80102812 <ideinit+0x8d>
  for(i=0; i<1000; i++){
80102805:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102809:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102810:	7e d3                	jle    801027e5 <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102812:	83 ec 08             	sub    $0x8,%esp
80102815:	68 e0 00 00 00       	push   $0xe0
8010281a:	68 f6 01 00 00       	push   $0x1f6
8010281f:	e8 d1 fe ff ff       	call   801026f5 <outb>
80102824:	83 c4 10             	add    $0x10,%esp
}
80102827:	90                   	nop
80102828:	c9                   	leave  
80102829:	c3                   	ret    

8010282a <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010282a:	f3 0f 1e fb          	endbr32 
8010282e:	55                   	push   %ebp
8010282f:	89 e5                	mov    %esp,%ebp
80102831:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102834:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102838:	75 0d                	jne    80102847 <idestart+0x1d>
    panic("idestart");
8010283a:	83 ec 0c             	sub    $0xc,%esp
8010283d:	68 7b 92 10 80       	push   $0x8010927b
80102842:	e8 c1 dd ff ff       	call   80100608 <panic>
  if(b->blockno >= FSSIZE)
80102847:	8b 45 08             	mov    0x8(%ebp),%eax
8010284a:	8b 40 08             	mov    0x8(%eax),%eax
8010284d:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102852:	76 0d                	jbe    80102861 <idestart+0x37>
    panic("incorrect blockno");
80102854:	83 ec 0c             	sub    $0xc,%esp
80102857:	68 84 92 10 80       	push   $0x80109284
8010285c:	e8 a7 dd ff ff       	call   80100608 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102861:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102868:	8b 45 08             	mov    0x8(%ebp),%eax
8010286b:	8b 50 08             	mov    0x8(%eax),%edx
8010286e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102871:	0f af c2             	imul   %edx,%eax
80102874:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102877:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010287b:	75 07                	jne    80102884 <idestart+0x5a>
8010287d:	b8 20 00 00 00       	mov    $0x20,%eax
80102882:	eb 05                	jmp    80102889 <idestart+0x5f>
80102884:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102889:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
8010288c:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102890:	75 07                	jne    80102899 <idestart+0x6f>
80102892:	b8 30 00 00 00       	mov    $0x30,%eax
80102897:	eb 05                	jmp    8010289e <idestart+0x74>
80102899:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010289e:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801028a1:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801028a5:	7e 0d                	jle    801028b4 <idestart+0x8a>
801028a7:	83 ec 0c             	sub    $0xc,%esp
801028aa:	68 7b 92 10 80       	push   $0x8010927b
801028af:	e8 54 dd ff ff       	call   80100608 <panic>

  idewait(0);
801028b4:	83 ec 0c             	sub    $0xc,%esp
801028b7:	6a 00                	push   $0x0
801028b9:	e8 7e fe ff ff       	call   8010273c <idewait>
801028be:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801028c1:	83 ec 08             	sub    $0x8,%esp
801028c4:	6a 00                	push   $0x0
801028c6:	68 f6 03 00 00       	push   $0x3f6
801028cb:	e8 25 fe ff ff       	call   801026f5 <outb>
801028d0:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
801028d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d6:	0f b6 c0             	movzbl %al,%eax
801028d9:	83 ec 08             	sub    $0x8,%esp
801028dc:	50                   	push   %eax
801028dd:	68 f2 01 00 00       	push   $0x1f2
801028e2:	e8 0e fe ff ff       	call   801026f5 <outb>
801028e7:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
801028ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028ed:	0f b6 c0             	movzbl %al,%eax
801028f0:	83 ec 08             	sub    $0x8,%esp
801028f3:	50                   	push   %eax
801028f4:	68 f3 01 00 00       	push   $0x1f3
801028f9:	e8 f7 fd ff ff       	call   801026f5 <outb>
801028fe:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102901:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102904:	c1 f8 08             	sar    $0x8,%eax
80102907:	0f b6 c0             	movzbl %al,%eax
8010290a:	83 ec 08             	sub    $0x8,%esp
8010290d:	50                   	push   %eax
8010290e:	68 f4 01 00 00       	push   $0x1f4
80102913:	e8 dd fd ff ff       	call   801026f5 <outb>
80102918:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010291b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010291e:	c1 f8 10             	sar    $0x10,%eax
80102921:	0f b6 c0             	movzbl %al,%eax
80102924:	83 ec 08             	sub    $0x8,%esp
80102927:	50                   	push   %eax
80102928:	68 f5 01 00 00       	push   $0x1f5
8010292d:	e8 c3 fd ff ff       	call   801026f5 <outb>
80102932:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102935:	8b 45 08             	mov    0x8(%ebp),%eax
80102938:	8b 40 04             	mov    0x4(%eax),%eax
8010293b:	c1 e0 04             	shl    $0x4,%eax
8010293e:	83 e0 10             	and    $0x10,%eax
80102941:	89 c2                	mov    %eax,%edx
80102943:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102946:	c1 f8 18             	sar    $0x18,%eax
80102949:	83 e0 0f             	and    $0xf,%eax
8010294c:	09 d0                	or     %edx,%eax
8010294e:	83 c8 e0             	or     $0xffffffe0,%eax
80102951:	0f b6 c0             	movzbl %al,%eax
80102954:	83 ec 08             	sub    $0x8,%esp
80102957:	50                   	push   %eax
80102958:	68 f6 01 00 00       	push   $0x1f6
8010295d:	e8 93 fd ff ff       	call   801026f5 <outb>
80102962:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102965:	8b 45 08             	mov    0x8(%ebp),%eax
80102968:	8b 00                	mov    (%eax),%eax
8010296a:	83 e0 04             	and    $0x4,%eax
8010296d:	85 c0                	test   %eax,%eax
8010296f:	74 35                	je     801029a6 <idestart+0x17c>
    outb(0x1f7, write_cmd);
80102971:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102974:	0f b6 c0             	movzbl %al,%eax
80102977:	83 ec 08             	sub    $0x8,%esp
8010297a:	50                   	push   %eax
8010297b:	68 f7 01 00 00       	push   $0x1f7
80102980:	e8 70 fd ff ff       	call   801026f5 <outb>
80102985:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102988:	8b 45 08             	mov    0x8(%ebp),%eax
8010298b:	83 c0 5c             	add    $0x5c,%eax
8010298e:	83 ec 04             	sub    $0x4,%esp
80102991:	68 80 00 00 00       	push   $0x80
80102996:	50                   	push   %eax
80102997:	68 f0 01 00 00       	push   $0x1f0
8010299c:	e8 75 fd ff ff       	call   80102716 <outsl>
801029a1:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
801029a4:	eb 17                	jmp    801029bd <idestart+0x193>
    outb(0x1f7, read_cmd);
801029a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801029a9:	0f b6 c0             	movzbl %al,%eax
801029ac:	83 ec 08             	sub    $0x8,%esp
801029af:	50                   	push   %eax
801029b0:	68 f7 01 00 00       	push   $0x1f7
801029b5:	e8 3b fd ff ff       	call   801026f5 <outb>
801029ba:	83 c4 10             	add    $0x10,%esp
}
801029bd:	90                   	nop
801029be:	c9                   	leave  
801029bf:	c3                   	ret    

801029c0 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801029c0:	f3 0f 1e fb          	endbr32 
801029c4:	55                   	push   %ebp
801029c5:	89 e5                	mov    %esp,%ebp
801029c7:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801029ca:	83 ec 0c             	sub    $0xc,%esp
801029cd:	68 00 c6 10 80       	push   $0x8010c600
801029d2:	e8 b7 28 00 00       	call   8010528e <acquire>
801029d7:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
801029da:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801029df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801029e6:	75 15                	jne    801029fd <ideintr+0x3d>
    release(&idelock);
801029e8:	83 ec 0c             	sub    $0xc,%esp
801029eb:	68 00 c6 10 80       	push   $0x8010c600
801029f0:	e8 0b 29 00 00       	call   80105300 <release>
801029f5:	83 c4 10             	add    $0x10,%esp
    return;
801029f8:	e9 9a 00 00 00       	jmp    80102a97 <ideintr+0xd7>
  }
  idequeue = b->qnext;
801029fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a00:	8b 40 58             	mov    0x58(%eax),%eax
80102a03:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a0b:	8b 00                	mov    (%eax),%eax
80102a0d:	83 e0 04             	and    $0x4,%eax
80102a10:	85 c0                	test   %eax,%eax
80102a12:	75 2d                	jne    80102a41 <ideintr+0x81>
80102a14:	83 ec 0c             	sub    $0xc,%esp
80102a17:	6a 01                	push   $0x1
80102a19:	e8 1e fd ff ff       	call   8010273c <idewait>
80102a1e:	83 c4 10             	add    $0x10,%esp
80102a21:	85 c0                	test   %eax,%eax
80102a23:	78 1c                	js     80102a41 <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a28:	83 c0 5c             	add    $0x5c,%eax
80102a2b:	83 ec 04             	sub    $0x4,%esp
80102a2e:	68 80 00 00 00       	push   $0x80
80102a33:	50                   	push   %eax
80102a34:	68 f0 01 00 00       	push   $0x1f0
80102a39:	e8 91 fc ff ff       	call   801026cf <insl>
80102a3e:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a44:	8b 00                	mov    (%eax),%eax
80102a46:	83 c8 02             	or     $0x2,%eax
80102a49:	89 c2                	mov    %eax,%edx
80102a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4e:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a53:	8b 00                	mov    (%eax),%eax
80102a55:	83 e0 fb             	and    $0xfffffffb,%eax
80102a58:	89 c2                	mov    %eax,%edx
80102a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5d:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102a5f:	83 ec 0c             	sub    $0xc,%esp
80102a62:	ff 75 f4             	pushl  -0xc(%ebp)
80102a65:	e8 a4 24 00 00       	call   80104f0e <wakeup>
80102a6a:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102a6d:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a72:	85 c0                	test   %eax,%eax
80102a74:	74 11                	je     80102a87 <ideintr+0xc7>
    idestart(idequeue);
80102a76:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a7b:	83 ec 0c             	sub    $0xc,%esp
80102a7e:	50                   	push   %eax
80102a7f:	e8 a6 fd ff ff       	call   8010282a <idestart>
80102a84:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102a87:	83 ec 0c             	sub    $0xc,%esp
80102a8a:	68 00 c6 10 80       	push   $0x8010c600
80102a8f:	e8 6c 28 00 00       	call   80105300 <release>
80102a94:	83 c4 10             	add    $0x10,%esp
}
80102a97:	c9                   	leave  
80102a98:	c3                   	ret    

80102a99 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102a99:	f3 0f 1e fb          	endbr32 
80102a9d:	55                   	push   %ebp
80102a9e:	89 e5                	mov    %esp,%ebp
80102aa0:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa6:	83 c0 0c             	add    $0xc,%eax
80102aa9:	83 ec 0c             	sub    $0xc,%esp
80102aac:	50                   	push   %eax
80102aad:	e8 1d 27 00 00       	call   801051cf <holdingsleep>
80102ab2:	83 c4 10             	add    $0x10,%esp
80102ab5:	85 c0                	test   %eax,%eax
80102ab7:	75 0d                	jne    80102ac6 <iderw+0x2d>
    panic("iderw: buf not locked");
80102ab9:	83 ec 0c             	sub    $0xc,%esp
80102abc:	68 96 92 10 80       	push   $0x80109296
80102ac1:	e8 42 db ff ff       	call   80100608 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac9:	8b 00                	mov    (%eax),%eax
80102acb:	83 e0 06             	and    $0x6,%eax
80102ace:	83 f8 02             	cmp    $0x2,%eax
80102ad1:	75 0d                	jne    80102ae0 <iderw+0x47>
    panic("iderw: nothing to do");
80102ad3:	83 ec 0c             	sub    $0xc,%esp
80102ad6:	68 ac 92 10 80       	push   $0x801092ac
80102adb:	e8 28 db ff ff       	call   80100608 <panic>
  if(b->dev != 0 && !havedisk1)
80102ae0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae3:	8b 40 04             	mov    0x4(%eax),%eax
80102ae6:	85 c0                	test   %eax,%eax
80102ae8:	74 16                	je     80102b00 <iderw+0x67>
80102aea:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102aef:	85 c0                	test   %eax,%eax
80102af1:	75 0d                	jne    80102b00 <iderw+0x67>
    panic("iderw: ide disk 1 not present");
80102af3:	83 ec 0c             	sub    $0xc,%esp
80102af6:	68 c1 92 10 80       	push   $0x801092c1
80102afb:	e8 08 db ff ff       	call   80100608 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b00:	83 ec 0c             	sub    $0xc,%esp
80102b03:	68 00 c6 10 80       	push   $0x8010c600
80102b08:	e8 81 27 00 00       	call   8010528e <acquire>
80102b0d:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102b10:	8b 45 08             	mov    0x8(%ebp),%eax
80102b13:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b1a:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102b21:	eb 0b                	jmp    80102b2e <iderw+0x95>
80102b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b26:	8b 00                	mov    (%eax),%eax
80102b28:	83 c0 58             	add    $0x58,%eax
80102b2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b31:	8b 00                	mov    (%eax),%eax
80102b33:	85 c0                	test   %eax,%eax
80102b35:	75 ec                	jne    80102b23 <iderw+0x8a>
    ;
  *pp = b;
80102b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b3a:	8b 55 08             	mov    0x8(%ebp),%edx
80102b3d:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102b3f:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102b44:	39 45 08             	cmp    %eax,0x8(%ebp)
80102b47:	75 23                	jne    80102b6c <iderw+0xd3>
    idestart(b);
80102b49:	83 ec 0c             	sub    $0xc,%esp
80102b4c:	ff 75 08             	pushl  0x8(%ebp)
80102b4f:	e8 d6 fc ff ff       	call   8010282a <idestart>
80102b54:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b57:	eb 13                	jmp    80102b6c <iderw+0xd3>
    sleep(b, &idelock);
80102b59:	83 ec 08             	sub    $0x8,%esp
80102b5c:	68 00 c6 10 80       	push   $0x8010c600
80102b61:	ff 75 08             	pushl  0x8(%ebp)
80102b64:	e8 b3 22 00 00       	call   80104e1c <sleep>
80102b69:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b6c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b6f:	8b 00                	mov    (%eax),%eax
80102b71:	83 e0 06             	and    $0x6,%eax
80102b74:	83 f8 02             	cmp    $0x2,%eax
80102b77:	75 e0                	jne    80102b59 <iderw+0xc0>
  }


  release(&idelock);
80102b79:	83 ec 0c             	sub    $0xc,%esp
80102b7c:	68 00 c6 10 80       	push   $0x8010c600
80102b81:	e8 7a 27 00 00       	call   80105300 <release>
80102b86:	83 c4 10             	add    $0x10,%esp
}
80102b89:	90                   	nop
80102b8a:	c9                   	leave  
80102b8b:	c3                   	ret    

80102b8c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b8c:	f3 0f 1e fb          	endbr32 
80102b90:	55                   	push   %ebp
80102b91:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b93:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102b98:	8b 55 08             	mov    0x8(%ebp),%edx
80102b9b:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102b9d:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102ba2:	8b 40 10             	mov    0x10(%eax),%eax
}
80102ba5:	5d                   	pop    %ebp
80102ba6:	c3                   	ret    

80102ba7 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102ba7:	f3 0f 1e fb          	endbr32 
80102bab:	55                   	push   %ebp
80102bac:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bae:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bb3:	8b 55 08             	mov    0x8(%ebp),%edx
80102bb6:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102bb8:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bbd:	8b 55 0c             	mov    0xc(%ebp),%edx
80102bc0:	89 50 10             	mov    %edx,0x10(%eax)
}
80102bc3:	90                   	nop
80102bc4:	5d                   	pop    %ebp
80102bc5:	c3                   	ret    

80102bc6 <ioapicinit>:

void
ioapicinit(void)
{
80102bc6:	f3 0f 1e fb          	endbr32 
80102bca:	55                   	push   %ebp
80102bcb:	89 e5                	mov    %esp,%ebp
80102bcd:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102bd0:	c7 05 d4 46 11 80 00 	movl   $0xfec00000,0x801146d4
80102bd7:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102bda:	6a 01                	push   $0x1
80102bdc:	e8 ab ff ff ff       	call   80102b8c <ioapicread>
80102be1:	83 c4 04             	add    $0x4,%esp
80102be4:	c1 e8 10             	shr    $0x10,%eax
80102be7:	25 ff 00 00 00       	and    $0xff,%eax
80102bec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102bef:	6a 00                	push   $0x0
80102bf1:	e8 96 ff ff ff       	call   80102b8c <ioapicread>
80102bf6:	83 c4 04             	add    $0x4,%esp
80102bf9:	c1 e8 18             	shr    $0x18,%eax
80102bfc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102bff:	0f b6 05 00 48 11 80 	movzbl 0x80114800,%eax
80102c06:	0f b6 c0             	movzbl %al,%eax
80102c09:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102c0c:	74 10                	je     80102c1e <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c0e:	83 ec 0c             	sub    $0xc,%esp
80102c11:	68 e0 92 10 80       	push   $0x801092e0
80102c16:	e8 fd d7 ff ff       	call   80100418 <cprintf>
80102c1b:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c25:	eb 3f                	jmp    80102c66 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c2a:	83 c0 20             	add    $0x20,%eax
80102c2d:	0d 00 00 01 00       	or     $0x10000,%eax
80102c32:	89 c2                	mov    %eax,%edx
80102c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c37:	83 c0 08             	add    $0x8,%eax
80102c3a:	01 c0                	add    %eax,%eax
80102c3c:	83 ec 08             	sub    $0x8,%esp
80102c3f:	52                   	push   %edx
80102c40:	50                   	push   %eax
80102c41:	e8 61 ff ff ff       	call   80102ba7 <ioapicwrite>
80102c46:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c4c:	83 c0 08             	add    $0x8,%eax
80102c4f:	01 c0                	add    %eax,%eax
80102c51:	83 c0 01             	add    $0x1,%eax
80102c54:	83 ec 08             	sub    $0x8,%esp
80102c57:	6a 00                	push   $0x0
80102c59:	50                   	push   %eax
80102c5a:	e8 48 ff ff ff       	call   80102ba7 <ioapicwrite>
80102c5f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102c62:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c69:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c6c:	7e b9                	jle    80102c27 <ioapicinit+0x61>
  }
}
80102c6e:	90                   	nop
80102c6f:	90                   	nop
80102c70:	c9                   	leave  
80102c71:	c3                   	ret    

80102c72 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c72:	f3 0f 1e fb          	endbr32 
80102c76:	55                   	push   %ebp
80102c77:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102c79:	8b 45 08             	mov    0x8(%ebp),%eax
80102c7c:	83 c0 20             	add    $0x20,%eax
80102c7f:	89 c2                	mov    %eax,%edx
80102c81:	8b 45 08             	mov    0x8(%ebp),%eax
80102c84:	83 c0 08             	add    $0x8,%eax
80102c87:	01 c0                	add    %eax,%eax
80102c89:	52                   	push   %edx
80102c8a:	50                   	push   %eax
80102c8b:	e8 17 ff ff ff       	call   80102ba7 <ioapicwrite>
80102c90:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c93:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c96:	c1 e0 18             	shl    $0x18,%eax
80102c99:	89 c2                	mov    %eax,%edx
80102c9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c9e:	83 c0 08             	add    $0x8,%eax
80102ca1:	01 c0                	add    %eax,%eax
80102ca3:	83 c0 01             	add    $0x1,%eax
80102ca6:	52                   	push   %edx
80102ca7:	50                   	push   %eax
80102ca8:	e8 fa fe ff ff       	call   80102ba7 <ioapicwrite>
80102cad:	83 c4 08             	add    $0x8,%esp
}
80102cb0:	90                   	nop
80102cb1:	c9                   	leave  
80102cb2:	c3                   	ret    

80102cb3 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102cb3:	f3 0f 1e fb          	endbr32 
80102cb7:	55                   	push   %ebp
80102cb8:	89 e5                	mov    %esp,%ebp
80102cba:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102cbd:	83 ec 08             	sub    $0x8,%esp
80102cc0:	68 12 93 10 80       	push   $0x80109312
80102cc5:	68 e0 46 11 80       	push   $0x801146e0
80102cca:	e8 99 25 00 00       	call   80105268 <initlock>
80102ccf:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102cd2:	c7 05 14 47 11 80 00 	movl   $0x0,0x80114714
80102cd9:	00 00 00 
  freerange(vstart, vend);
80102cdc:	83 ec 08             	sub    $0x8,%esp
80102cdf:	ff 75 0c             	pushl  0xc(%ebp)
80102ce2:	ff 75 08             	pushl  0x8(%ebp)
80102ce5:	e8 2e 00 00 00       	call   80102d18 <freerange>
80102cea:	83 c4 10             	add    $0x10,%esp
}
80102ced:	90                   	nop
80102cee:	c9                   	leave  
80102cef:	c3                   	ret    

80102cf0 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102cf0:	f3 0f 1e fb          	endbr32 
80102cf4:	55                   	push   %ebp
80102cf5:	89 e5                	mov    %esp,%ebp
80102cf7:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102cfa:	83 ec 08             	sub    $0x8,%esp
80102cfd:	ff 75 0c             	pushl  0xc(%ebp)
80102d00:	ff 75 08             	pushl  0x8(%ebp)
80102d03:	e8 10 00 00 00       	call   80102d18 <freerange>
80102d08:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102d0b:	c7 05 14 47 11 80 01 	movl   $0x1,0x80114714
80102d12:	00 00 00 
}
80102d15:	90                   	nop
80102d16:	c9                   	leave  
80102d17:	c3                   	ret    

80102d18 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d18:	f3 0f 1e fb          	endbr32 
80102d1c:	55                   	push   %ebp
80102d1d:	89 e5                	mov    %esp,%ebp
80102d1f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d22:	8b 45 08             	mov    0x8(%ebp),%eax
80102d25:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d2a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d32:	eb 15                	jmp    80102d49 <freerange+0x31>
    kfree(p);
80102d34:	83 ec 0c             	sub    $0xc,%esp
80102d37:	ff 75 f4             	pushl  -0xc(%ebp)
80102d3a:	e8 1b 00 00 00       	call   80102d5a <kfree>
80102d3f:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d42:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d4c:	05 00 10 00 00       	add    $0x1000,%eax
80102d51:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102d54:	73 de                	jae    80102d34 <freerange+0x1c>
}
80102d56:	90                   	nop
80102d57:	90                   	nop
80102d58:	c9                   	leave  
80102d59:	c3                   	ret    

80102d5a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d5a:	f3 0f 1e fb          	endbr32 
80102d5e:	55                   	push   %ebp
80102d5f:	89 e5                	mov    %esp,%ebp
80102d61:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102d64:	8b 45 08             	mov    0x8(%ebp),%eax
80102d67:	25 ff 0f 00 00       	and    $0xfff,%eax
80102d6c:	85 c0                	test   %eax,%eax
80102d6e:	75 18                	jne    80102d88 <kfree+0x2e>
80102d70:	81 7d 08 48 89 11 80 	cmpl   $0x80118948,0x8(%ebp)
80102d77:	72 0f                	jb     80102d88 <kfree+0x2e>
80102d79:	8b 45 08             	mov    0x8(%ebp),%eax
80102d7c:	05 00 00 00 80       	add    $0x80000000,%eax
80102d81:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102d86:	76 0d                	jbe    80102d95 <kfree+0x3b>
    panic("kfree");
80102d88:	83 ec 0c             	sub    $0xc,%esp
80102d8b:	68 17 93 10 80       	push   $0x80109317
80102d90:	e8 73 d8 ff ff       	call   80100608 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102d95:	83 ec 04             	sub    $0x4,%esp
80102d98:	68 00 10 00 00       	push   $0x1000
80102d9d:	6a 01                	push   $0x1
80102d9f:	ff 75 08             	pushl  0x8(%ebp)
80102da2:	e8 86 27 00 00       	call   8010552d <memset>
80102da7:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102daa:	a1 14 47 11 80       	mov    0x80114714,%eax
80102daf:	85 c0                	test   %eax,%eax
80102db1:	74 10                	je     80102dc3 <kfree+0x69>
    acquire(&kmem.lock);
80102db3:	83 ec 0c             	sub    $0xc,%esp
80102db6:	68 e0 46 11 80       	push   $0x801146e0
80102dbb:	e8 ce 24 00 00       	call   8010528e <acquire>
80102dc0:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102dc3:	8b 45 08             	mov    0x8(%ebp),%eax
80102dc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102dc9:	8b 15 18 47 11 80    	mov    0x80114718,%edx
80102dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dd2:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dd7:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102ddc:	a1 14 47 11 80       	mov    0x80114714,%eax
80102de1:	85 c0                	test   %eax,%eax
80102de3:	74 10                	je     80102df5 <kfree+0x9b>
    release(&kmem.lock);
80102de5:	83 ec 0c             	sub    $0xc,%esp
80102de8:	68 e0 46 11 80       	push   $0x801146e0
80102ded:	e8 0e 25 00 00       	call   80105300 <release>
80102df2:	83 c4 10             	add    $0x10,%esp
}
80102df5:	90                   	nop
80102df6:	c9                   	leave  
80102df7:	c3                   	ret    

80102df8 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102df8:	f3 0f 1e fb          	endbr32 
80102dfc:	55                   	push   %ebp
80102dfd:	89 e5                	mov    %esp,%ebp
80102dff:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102e02:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e07:	85 c0                	test   %eax,%eax
80102e09:	74 10                	je     80102e1b <kalloc+0x23>
    acquire(&kmem.lock);
80102e0b:	83 ec 0c             	sub    $0xc,%esp
80102e0e:	68 e0 46 11 80       	push   $0x801146e0
80102e13:	e8 76 24 00 00       	call   8010528e <acquire>
80102e18:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102e1b:	a1 18 47 11 80       	mov    0x80114718,%eax
80102e20:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e27:	74 0a                	je     80102e33 <kalloc+0x3b>
    kmem.freelist = r->next;
80102e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e2c:	8b 00                	mov    (%eax),%eax
80102e2e:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102e33:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e38:	85 c0                	test   %eax,%eax
80102e3a:	74 10                	je     80102e4c <kalloc+0x54>
    release(&kmem.lock);
80102e3c:	83 ec 0c             	sub    $0xc,%esp
80102e3f:	68 e0 46 11 80       	push   $0x801146e0
80102e44:	e8 b7 24 00 00       	call   80105300 <release>
80102e49:	83 c4 10             	add    $0x10,%esp

  return (char*)r;
80102e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e4f:	c9                   	leave  
80102e50:	c3                   	ret    

80102e51 <inb>:
{
80102e51:	55                   	push   %ebp
80102e52:	89 e5                	mov    %esp,%ebp
80102e54:	83 ec 14             	sub    $0x14,%esp
80102e57:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e5e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e62:	89 c2                	mov    %eax,%edx
80102e64:	ec                   	in     (%dx),%al
80102e65:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e68:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e6c:	c9                   	leave  
80102e6d:	c3                   	ret    

80102e6e <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e6e:	f3 0f 1e fb          	endbr32 
80102e72:	55                   	push   %ebp
80102e73:	89 e5                	mov    %esp,%ebp
80102e75:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102e78:	6a 64                	push   $0x64
80102e7a:	e8 d2 ff ff ff       	call   80102e51 <inb>
80102e7f:	83 c4 04             	add    $0x4,%esp
80102e82:	0f b6 c0             	movzbl %al,%eax
80102e85:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e8b:	83 e0 01             	and    $0x1,%eax
80102e8e:	85 c0                	test   %eax,%eax
80102e90:	75 0a                	jne    80102e9c <kbdgetc+0x2e>
    return -1;
80102e92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e97:	e9 23 01 00 00       	jmp    80102fbf <kbdgetc+0x151>
  data = inb(KBDATAP);
80102e9c:	6a 60                	push   $0x60
80102e9e:	e8 ae ff ff ff       	call   80102e51 <inb>
80102ea3:	83 c4 04             	add    $0x4,%esp
80102ea6:	0f b6 c0             	movzbl %al,%eax
80102ea9:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102eac:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102eb3:	75 17                	jne    80102ecc <kbdgetc+0x5e>
    shift |= E0ESC;
80102eb5:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102eba:	83 c8 40             	or     $0x40,%eax
80102ebd:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102ec2:	b8 00 00 00 00       	mov    $0x0,%eax
80102ec7:	e9 f3 00 00 00       	jmp    80102fbf <kbdgetc+0x151>
  } else if(data & 0x80){
80102ecc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ecf:	25 80 00 00 00       	and    $0x80,%eax
80102ed4:	85 c0                	test   %eax,%eax
80102ed6:	74 45                	je     80102f1d <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102ed8:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102edd:	83 e0 40             	and    $0x40,%eax
80102ee0:	85 c0                	test   %eax,%eax
80102ee2:	75 08                	jne    80102eec <kbdgetc+0x7e>
80102ee4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ee7:	83 e0 7f             	and    $0x7f,%eax
80102eea:	eb 03                	jmp    80102eef <kbdgetc+0x81>
80102eec:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eef:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102ef2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ef5:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102efa:	0f b6 00             	movzbl (%eax),%eax
80102efd:	83 c8 40             	or     $0x40,%eax
80102f00:	0f b6 c0             	movzbl %al,%eax
80102f03:	f7 d0                	not    %eax
80102f05:	89 c2                	mov    %eax,%edx
80102f07:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f0c:	21 d0                	and    %edx,%eax
80102f0e:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f13:	b8 00 00 00 00       	mov    $0x0,%eax
80102f18:	e9 a2 00 00 00       	jmp    80102fbf <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102f1d:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f22:	83 e0 40             	and    $0x40,%eax
80102f25:	85 c0                	test   %eax,%eax
80102f27:	74 14                	je     80102f3d <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f29:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f30:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f35:	83 e0 bf             	and    $0xffffffbf,%eax
80102f38:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102f3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f40:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f45:	0f b6 00             	movzbl (%eax),%eax
80102f48:	0f b6 d0             	movzbl %al,%edx
80102f4b:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f50:	09 d0                	or     %edx,%eax
80102f52:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102f57:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f5a:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102f5f:	0f b6 00             	movzbl (%eax),%eax
80102f62:	0f b6 d0             	movzbl %al,%edx
80102f65:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f6a:	31 d0                	xor    %edx,%eax
80102f6c:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102f71:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f76:	83 e0 03             	and    $0x3,%eax
80102f79:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102f80:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f83:	01 d0                	add    %edx,%eax
80102f85:	0f b6 00             	movzbl (%eax),%eax
80102f88:	0f b6 c0             	movzbl %al,%eax
80102f8b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f8e:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f93:	83 e0 08             	and    $0x8,%eax
80102f96:	85 c0                	test   %eax,%eax
80102f98:	74 22                	je     80102fbc <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102f9a:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102f9e:	76 0c                	jbe    80102fac <kbdgetc+0x13e>
80102fa0:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102fa4:	77 06                	ja     80102fac <kbdgetc+0x13e>
      c += 'A' - 'a';
80102fa6:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102faa:	eb 10                	jmp    80102fbc <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102fac:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102fb0:	76 0a                	jbe    80102fbc <kbdgetc+0x14e>
80102fb2:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102fb6:	77 04                	ja     80102fbc <kbdgetc+0x14e>
      c += 'a' - 'A';
80102fb8:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102fbc:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102fbf:	c9                   	leave  
80102fc0:	c3                   	ret    

80102fc1 <kbdintr>:

void
kbdintr(void)
{
80102fc1:	f3 0f 1e fb          	endbr32 
80102fc5:	55                   	push   %ebp
80102fc6:	89 e5                	mov    %esp,%ebp
80102fc8:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102fcb:	83 ec 0c             	sub    $0xc,%esp
80102fce:	68 6e 2e 10 80       	push   $0x80102e6e
80102fd3:	e8 d0 d8 ff ff       	call   801008a8 <consoleintr>
80102fd8:	83 c4 10             	add    $0x10,%esp
}
80102fdb:	90                   	nop
80102fdc:	c9                   	leave  
80102fdd:	c3                   	ret    

80102fde <inb>:
{
80102fde:	55                   	push   %ebp
80102fdf:	89 e5                	mov    %esp,%ebp
80102fe1:	83 ec 14             	sub    $0x14,%esp
80102fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80102fe7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102feb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102fef:	89 c2                	mov    %eax,%edx
80102ff1:	ec                   	in     (%dx),%al
80102ff2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ff5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ff9:	c9                   	leave  
80102ffa:	c3                   	ret    

80102ffb <outb>:
{
80102ffb:	55                   	push   %ebp
80102ffc:	89 e5                	mov    %esp,%ebp
80102ffe:	83 ec 08             	sub    $0x8,%esp
80103001:	8b 45 08             	mov    0x8(%ebp),%eax
80103004:	8b 55 0c             	mov    0xc(%ebp),%edx
80103007:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010300b:	89 d0                	mov    %edx,%eax
8010300d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103010:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103014:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103018:	ee                   	out    %al,(%dx)
}
80103019:	90                   	nop
8010301a:	c9                   	leave  
8010301b:	c3                   	ret    

8010301c <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
8010301c:	f3 0f 1e fb          	endbr32 
80103020:	55                   	push   %ebp
80103021:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103023:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103028:	8b 55 08             	mov    0x8(%ebp),%edx
8010302b:	c1 e2 02             	shl    $0x2,%edx
8010302e:	01 c2                	add    %eax,%edx
80103030:	8b 45 0c             	mov    0xc(%ebp),%eax
80103033:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103035:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010303a:	83 c0 20             	add    $0x20,%eax
8010303d:	8b 00                	mov    (%eax),%eax
}
8010303f:	90                   	nop
80103040:	5d                   	pop    %ebp
80103041:	c3                   	ret    

80103042 <lapicinit>:

void
lapicinit(void)
{
80103042:	f3 0f 1e fb          	endbr32 
80103046:	55                   	push   %ebp
80103047:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80103049:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010304e:	85 c0                	test   %eax,%eax
80103050:	0f 84 0c 01 00 00    	je     80103162 <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103056:	68 3f 01 00 00       	push   $0x13f
8010305b:	6a 3c                	push   $0x3c
8010305d:	e8 ba ff ff ff       	call   8010301c <lapicw>
80103062:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103065:	6a 0b                	push   $0xb
80103067:	68 f8 00 00 00       	push   $0xf8
8010306c:	e8 ab ff ff ff       	call   8010301c <lapicw>
80103071:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103074:	68 20 00 02 00       	push   $0x20020
80103079:	68 c8 00 00 00       	push   $0xc8
8010307e:	e8 99 ff ff ff       	call   8010301c <lapicw>
80103083:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80103086:	68 80 96 98 00       	push   $0x989680
8010308b:	68 e0 00 00 00       	push   $0xe0
80103090:	e8 87 ff ff ff       	call   8010301c <lapicw>
80103095:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103098:	68 00 00 01 00       	push   $0x10000
8010309d:	68 d4 00 00 00       	push   $0xd4
801030a2:	e8 75 ff ff ff       	call   8010301c <lapicw>
801030a7:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
801030aa:	68 00 00 01 00       	push   $0x10000
801030af:	68 d8 00 00 00       	push   $0xd8
801030b4:	e8 63 ff ff ff       	call   8010301c <lapicw>
801030b9:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801030bc:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801030c1:	83 c0 30             	add    $0x30,%eax
801030c4:	8b 00                	mov    (%eax),%eax
801030c6:	c1 e8 10             	shr    $0x10,%eax
801030c9:	25 fc 00 00 00       	and    $0xfc,%eax
801030ce:	85 c0                	test   %eax,%eax
801030d0:	74 12                	je     801030e4 <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
801030d2:	68 00 00 01 00       	push   $0x10000
801030d7:	68 d0 00 00 00       	push   $0xd0
801030dc:	e8 3b ff ff ff       	call   8010301c <lapicw>
801030e1:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801030e4:	6a 33                	push   $0x33
801030e6:	68 dc 00 00 00       	push   $0xdc
801030eb:	e8 2c ff ff ff       	call   8010301c <lapicw>
801030f0:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801030f3:	6a 00                	push   $0x0
801030f5:	68 a0 00 00 00       	push   $0xa0
801030fa:	e8 1d ff ff ff       	call   8010301c <lapicw>
801030ff:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103102:	6a 00                	push   $0x0
80103104:	68 a0 00 00 00       	push   $0xa0
80103109:	e8 0e ff ff ff       	call   8010301c <lapicw>
8010310e:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103111:	6a 00                	push   $0x0
80103113:	6a 2c                	push   $0x2c
80103115:	e8 02 ff ff ff       	call   8010301c <lapicw>
8010311a:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010311d:	6a 00                	push   $0x0
8010311f:	68 c4 00 00 00       	push   $0xc4
80103124:	e8 f3 fe ff ff       	call   8010301c <lapicw>
80103129:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010312c:	68 00 85 08 00       	push   $0x88500
80103131:	68 c0 00 00 00       	push   $0xc0
80103136:	e8 e1 fe ff ff       	call   8010301c <lapicw>
8010313b:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
8010313e:	90                   	nop
8010313f:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103144:	05 00 03 00 00       	add    $0x300,%eax
80103149:	8b 00                	mov    (%eax),%eax
8010314b:	25 00 10 00 00       	and    $0x1000,%eax
80103150:	85 c0                	test   %eax,%eax
80103152:	75 eb                	jne    8010313f <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103154:	6a 00                	push   $0x0
80103156:	6a 20                	push   $0x20
80103158:	e8 bf fe ff ff       	call   8010301c <lapicw>
8010315d:	83 c4 08             	add    $0x8,%esp
80103160:	eb 01                	jmp    80103163 <lapicinit+0x121>
    return;
80103162:	90                   	nop
}
80103163:	c9                   	leave  
80103164:	c3                   	ret    

80103165 <lapicid>:

int
lapicid(void)
{
80103165:	f3 0f 1e fb          	endbr32 
80103169:	55                   	push   %ebp
8010316a:	89 e5                	mov    %esp,%ebp
  if (!lapic)
8010316c:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103171:	85 c0                	test   %eax,%eax
80103173:	75 07                	jne    8010317c <lapicid+0x17>
    return 0;
80103175:	b8 00 00 00 00       	mov    $0x0,%eax
8010317a:	eb 0d                	jmp    80103189 <lapicid+0x24>
  return lapic[ID] >> 24;
8010317c:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103181:	83 c0 20             	add    $0x20,%eax
80103184:	8b 00                	mov    (%eax),%eax
80103186:	c1 e8 18             	shr    $0x18,%eax
}
80103189:	5d                   	pop    %ebp
8010318a:	c3                   	ret    

8010318b <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010318b:	f3 0f 1e fb          	endbr32 
8010318f:	55                   	push   %ebp
80103190:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103192:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103197:	85 c0                	test   %eax,%eax
80103199:	74 0c                	je     801031a7 <lapiceoi+0x1c>
    lapicw(EOI, 0);
8010319b:	6a 00                	push   $0x0
8010319d:	6a 2c                	push   $0x2c
8010319f:	e8 78 fe ff ff       	call   8010301c <lapicw>
801031a4:	83 c4 08             	add    $0x8,%esp
}
801031a7:	90                   	nop
801031a8:	c9                   	leave  
801031a9:	c3                   	ret    

801031aa <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801031aa:	f3 0f 1e fb          	endbr32 
801031ae:	55                   	push   %ebp
801031af:	89 e5                	mov    %esp,%ebp
}
801031b1:	90                   	nop
801031b2:	5d                   	pop    %ebp
801031b3:	c3                   	ret    

801031b4 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801031b4:	f3 0f 1e fb          	endbr32 
801031b8:	55                   	push   %ebp
801031b9:	89 e5                	mov    %esp,%ebp
801031bb:	83 ec 14             	sub    $0x14,%esp
801031be:	8b 45 08             	mov    0x8(%ebp),%eax
801031c1:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801031c4:	6a 0f                	push   $0xf
801031c6:	6a 70                	push   $0x70
801031c8:	e8 2e fe ff ff       	call   80102ffb <outb>
801031cd:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801031d0:	6a 0a                	push   $0xa
801031d2:	6a 71                	push   $0x71
801031d4:	e8 22 fe ff ff       	call   80102ffb <outb>
801031d9:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801031dc:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801031e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801031e6:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801031eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801031ee:	c1 e8 04             	shr    $0x4,%eax
801031f1:	89 c2                	mov    %eax,%edx
801031f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801031f6:	83 c0 02             	add    $0x2,%eax
801031f9:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801031fc:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103200:	c1 e0 18             	shl    $0x18,%eax
80103203:	50                   	push   %eax
80103204:	68 c4 00 00 00       	push   $0xc4
80103209:	e8 0e fe ff ff       	call   8010301c <lapicw>
8010320e:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103211:	68 00 c5 00 00       	push   $0xc500
80103216:	68 c0 00 00 00       	push   $0xc0
8010321b:	e8 fc fd ff ff       	call   8010301c <lapicw>
80103220:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103223:	68 c8 00 00 00       	push   $0xc8
80103228:	e8 7d ff ff ff       	call   801031aa <microdelay>
8010322d:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103230:	68 00 85 00 00       	push   $0x8500
80103235:	68 c0 00 00 00       	push   $0xc0
8010323a:	e8 dd fd ff ff       	call   8010301c <lapicw>
8010323f:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103242:	6a 64                	push   $0x64
80103244:	e8 61 ff ff ff       	call   801031aa <microdelay>
80103249:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010324c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103253:	eb 3d                	jmp    80103292 <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80103255:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103259:	c1 e0 18             	shl    $0x18,%eax
8010325c:	50                   	push   %eax
8010325d:	68 c4 00 00 00       	push   $0xc4
80103262:	e8 b5 fd ff ff       	call   8010301c <lapicw>
80103267:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
8010326a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010326d:	c1 e8 0c             	shr    $0xc,%eax
80103270:	80 cc 06             	or     $0x6,%ah
80103273:	50                   	push   %eax
80103274:	68 c0 00 00 00       	push   $0xc0
80103279:	e8 9e fd ff ff       	call   8010301c <lapicw>
8010327e:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103281:	68 c8 00 00 00       	push   $0xc8
80103286:	e8 1f ff ff ff       	call   801031aa <microdelay>
8010328b:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
8010328e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103292:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103296:	7e bd                	jle    80103255 <lapicstartap+0xa1>
  }
}
80103298:	90                   	nop
80103299:	90                   	nop
8010329a:	c9                   	leave  
8010329b:	c3                   	ret    

8010329c <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
8010329c:	f3 0f 1e fb          	endbr32 
801032a0:	55                   	push   %ebp
801032a1:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801032a3:	8b 45 08             	mov    0x8(%ebp),%eax
801032a6:	0f b6 c0             	movzbl %al,%eax
801032a9:	50                   	push   %eax
801032aa:	6a 70                	push   $0x70
801032ac:	e8 4a fd ff ff       	call   80102ffb <outb>
801032b1:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801032b4:	68 c8 00 00 00       	push   $0xc8
801032b9:	e8 ec fe ff ff       	call   801031aa <microdelay>
801032be:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801032c1:	6a 71                	push   $0x71
801032c3:	e8 16 fd ff ff       	call   80102fde <inb>
801032c8:	83 c4 04             	add    $0x4,%esp
801032cb:	0f b6 c0             	movzbl %al,%eax
}
801032ce:	c9                   	leave  
801032cf:	c3                   	ret    

801032d0 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801032d0:	f3 0f 1e fb          	endbr32 
801032d4:	55                   	push   %ebp
801032d5:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801032d7:	6a 00                	push   $0x0
801032d9:	e8 be ff ff ff       	call   8010329c <cmos_read>
801032de:	83 c4 04             	add    $0x4,%esp
801032e1:	8b 55 08             	mov    0x8(%ebp),%edx
801032e4:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801032e6:	6a 02                	push   $0x2
801032e8:	e8 af ff ff ff       	call   8010329c <cmos_read>
801032ed:	83 c4 04             	add    $0x4,%esp
801032f0:	8b 55 08             	mov    0x8(%ebp),%edx
801032f3:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801032f6:	6a 04                	push   $0x4
801032f8:	e8 9f ff ff ff       	call   8010329c <cmos_read>
801032fd:	83 c4 04             	add    $0x4,%esp
80103300:	8b 55 08             	mov    0x8(%ebp),%edx
80103303:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103306:	6a 07                	push   $0x7
80103308:	e8 8f ff ff ff       	call   8010329c <cmos_read>
8010330d:	83 c4 04             	add    $0x4,%esp
80103310:	8b 55 08             	mov    0x8(%ebp),%edx
80103313:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103316:	6a 08                	push   $0x8
80103318:	e8 7f ff ff ff       	call   8010329c <cmos_read>
8010331d:	83 c4 04             	add    $0x4,%esp
80103320:	8b 55 08             	mov    0x8(%ebp),%edx
80103323:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103326:	6a 09                	push   $0x9
80103328:	e8 6f ff ff ff       	call   8010329c <cmos_read>
8010332d:	83 c4 04             	add    $0x4,%esp
80103330:	8b 55 08             	mov    0x8(%ebp),%edx
80103333:	89 42 14             	mov    %eax,0x14(%edx)
}
80103336:	90                   	nop
80103337:	c9                   	leave  
80103338:	c3                   	ret    

80103339 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80103339:	f3 0f 1e fb          	endbr32 
8010333d:	55                   	push   %ebp
8010333e:	89 e5                	mov    %esp,%ebp
80103340:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103343:	6a 0b                	push   $0xb
80103345:	e8 52 ff ff ff       	call   8010329c <cmos_read>
8010334a:	83 c4 04             	add    $0x4,%esp
8010334d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103350:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103353:	83 e0 04             	and    $0x4,%eax
80103356:	85 c0                	test   %eax,%eax
80103358:	0f 94 c0             	sete   %al
8010335b:	0f b6 c0             	movzbl %al,%eax
8010335e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103361:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103364:	50                   	push   %eax
80103365:	e8 66 ff ff ff       	call   801032d0 <fill_rtcdate>
8010336a:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010336d:	6a 0a                	push   $0xa
8010336f:	e8 28 ff ff ff       	call   8010329c <cmos_read>
80103374:	83 c4 04             	add    $0x4,%esp
80103377:	25 80 00 00 00       	and    $0x80,%eax
8010337c:	85 c0                	test   %eax,%eax
8010337e:	75 27                	jne    801033a7 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80103380:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103383:	50                   	push   %eax
80103384:	e8 47 ff ff ff       	call   801032d0 <fill_rtcdate>
80103389:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010338c:	83 ec 04             	sub    $0x4,%esp
8010338f:	6a 18                	push   $0x18
80103391:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103394:	50                   	push   %eax
80103395:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103398:	50                   	push   %eax
80103399:	e8 fa 21 00 00       	call   80105598 <memcmp>
8010339e:	83 c4 10             	add    $0x10,%esp
801033a1:	85 c0                	test   %eax,%eax
801033a3:	74 05                	je     801033aa <cmostime+0x71>
801033a5:	eb ba                	jmp    80103361 <cmostime+0x28>
        continue;
801033a7:	90                   	nop
    fill_rtcdate(&t1);
801033a8:	eb b7                	jmp    80103361 <cmostime+0x28>
      break;
801033aa:	90                   	nop
  }

  // convert
  if(bcd) {
801033ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801033af:	0f 84 b4 00 00 00    	je     80103469 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801033b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033b8:	c1 e8 04             	shr    $0x4,%eax
801033bb:	89 c2                	mov    %eax,%edx
801033bd:	89 d0                	mov    %edx,%eax
801033bf:	c1 e0 02             	shl    $0x2,%eax
801033c2:	01 d0                	add    %edx,%eax
801033c4:	01 c0                	add    %eax,%eax
801033c6:	89 c2                	mov    %eax,%edx
801033c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033cb:	83 e0 0f             	and    $0xf,%eax
801033ce:	01 d0                	add    %edx,%eax
801033d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801033d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801033d6:	c1 e8 04             	shr    $0x4,%eax
801033d9:	89 c2                	mov    %eax,%edx
801033db:	89 d0                	mov    %edx,%eax
801033dd:	c1 e0 02             	shl    $0x2,%eax
801033e0:	01 d0                	add    %edx,%eax
801033e2:	01 c0                	add    %eax,%eax
801033e4:	89 c2                	mov    %eax,%edx
801033e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801033e9:	83 e0 0f             	and    $0xf,%eax
801033ec:	01 d0                	add    %edx,%eax
801033ee:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801033f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801033f4:	c1 e8 04             	shr    $0x4,%eax
801033f7:	89 c2                	mov    %eax,%edx
801033f9:	89 d0                	mov    %edx,%eax
801033fb:	c1 e0 02             	shl    $0x2,%eax
801033fe:	01 d0                	add    %edx,%eax
80103400:	01 c0                	add    %eax,%eax
80103402:	89 c2                	mov    %eax,%edx
80103404:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103407:	83 e0 0f             	and    $0xf,%eax
8010340a:	01 d0                	add    %edx,%eax
8010340c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010340f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103412:	c1 e8 04             	shr    $0x4,%eax
80103415:	89 c2                	mov    %eax,%edx
80103417:	89 d0                	mov    %edx,%eax
80103419:	c1 e0 02             	shl    $0x2,%eax
8010341c:	01 d0                	add    %edx,%eax
8010341e:	01 c0                	add    %eax,%eax
80103420:	89 c2                	mov    %eax,%edx
80103422:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103425:	83 e0 0f             	and    $0xf,%eax
80103428:	01 d0                	add    %edx,%eax
8010342a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010342d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103430:	c1 e8 04             	shr    $0x4,%eax
80103433:	89 c2                	mov    %eax,%edx
80103435:	89 d0                	mov    %edx,%eax
80103437:	c1 e0 02             	shl    $0x2,%eax
8010343a:	01 d0                	add    %edx,%eax
8010343c:	01 c0                	add    %eax,%eax
8010343e:	89 c2                	mov    %eax,%edx
80103440:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103443:	83 e0 0f             	and    $0xf,%eax
80103446:	01 d0                	add    %edx,%eax
80103448:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
8010344b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010344e:	c1 e8 04             	shr    $0x4,%eax
80103451:	89 c2                	mov    %eax,%edx
80103453:	89 d0                	mov    %edx,%eax
80103455:	c1 e0 02             	shl    $0x2,%eax
80103458:	01 d0                	add    %edx,%eax
8010345a:	01 c0                	add    %eax,%eax
8010345c:	89 c2                	mov    %eax,%edx
8010345e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103461:	83 e0 0f             	and    $0xf,%eax
80103464:	01 d0                	add    %edx,%eax
80103466:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103469:	8b 45 08             	mov    0x8(%ebp),%eax
8010346c:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010346f:	89 10                	mov    %edx,(%eax)
80103471:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103474:	89 50 04             	mov    %edx,0x4(%eax)
80103477:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010347a:	89 50 08             	mov    %edx,0x8(%eax)
8010347d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103480:	89 50 0c             	mov    %edx,0xc(%eax)
80103483:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103486:	89 50 10             	mov    %edx,0x10(%eax)
80103489:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010348c:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010348f:	8b 45 08             	mov    0x8(%ebp),%eax
80103492:	8b 40 14             	mov    0x14(%eax),%eax
80103495:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010349b:	8b 45 08             	mov    0x8(%ebp),%eax
8010349e:	89 50 14             	mov    %edx,0x14(%eax)
}
801034a1:	90                   	nop
801034a2:	c9                   	leave  
801034a3:	c3                   	ret    

801034a4 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801034a4:	f3 0f 1e fb          	endbr32 
801034a8:	55                   	push   %ebp
801034a9:	89 e5                	mov    %esp,%ebp
801034ab:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801034ae:	83 ec 08             	sub    $0x8,%esp
801034b1:	68 1d 93 10 80       	push   $0x8010931d
801034b6:	68 20 47 11 80       	push   $0x80114720
801034bb:	e8 a8 1d 00 00       	call   80105268 <initlock>
801034c0:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801034c3:	83 ec 08             	sub    $0x8,%esp
801034c6:	8d 45 dc             	lea    -0x24(%ebp),%eax
801034c9:	50                   	push   %eax
801034ca:	ff 75 08             	pushl  0x8(%ebp)
801034cd:	e8 f9 df ff ff       	call   801014cb <readsb>
801034d2:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801034d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034d8:	a3 54 47 11 80       	mov    %eax,0x80114754
  log.size = sb.nlog;
801034dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034e0:	a3 58 47 11 80       	mov    %eax,0x80114758
  log.dev = dev;
801034e5:	8b 45 08             	mov    0x8(%ebp),%eax
801034e8:	a3 64 47 11 80       	mov    %eax,0x80114764
  recover_from_log();
801034ed:	e8 bf 01 00 00       	call   801036b1 <recover_from_log>
}
801034f2:	90                   	nop
801034f3:	c9                   	leave  
801034f4:	c3                   	ret    

801034f5 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801034f5:	f3 0f 1e fb          	endbr32 
801034f9:	55                   	push   %ebp
801034fa:	89 e5                	mov    %esp,%ebp
801034fc:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801034ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103506:	e9 95 00 00 00       	jmp    801035a0 <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010350b:	8b 15 54 47 11 80    	mov    0x80114754,%edx
80103511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103514:	01 d0                	add    %edx,%eax
80103516:	83 c0 01             	add    $0x1,%eax
80103519:	89 c2                	mov    %eax,%edx
8010351b:	a1 64 47 11 80       	mov    0x80114764,%eax
80103520:	83 ec 08             	sub    $0x8,%esp
80103523:	52                   	push   %edx
80103524:	50                   	push   %eax
80103525:	e8 ad cc ff ff       	call   801001d7 <bread>
8010352a:	83 c4 10             	add    $0x10,%esp
8010352d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103533:	83 c0 10             	add    $0x10,%eax
80103536:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
8010353d:	89 c2                	mov    %eax,%edx
8010353f:	a1 64 47 11 80       	mov    0x80114764,%eax
80103544:	83 ec 08             	sub    $0x8,%esp
80103547:	52                   	push   %edx
80103548:	50                   	push   %eax
80103549:	e8 89 cc ff ff       	call   801001d7 <bread>
8010354e:	83 c4 10             	add    $0x10,%esp
80103551:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103554:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103557:	8d 50 5c             	lea    0x5c(%eax),%edx
8010355a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010355d:	83 c0 5c             	add    $0x5c,%eax
80103560:	83 ec 04             	sub    $0x4,%esp
80103563:	68 00 02 00 00       	push   $0x200
80103568:	52                   	push   %edx
80103569:	50                   	push   %eax
8010356a:	e8 85 20 00 00       	call   801055f4 <memmove>
8010356f:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103572:	83 ec 0c             	sub    $0xc,%esp
80103575:	ff 75 ec             	pushl  -0x14(%ebp)
80103578:	e8 97 cc ff ff       	call   80100214 <bwrite>
8010357d:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80103580:	83 ec 0c             	sub    $0xc,%esp
80103583:	ff 75 f0             	pushl  -0x10(%ebp)
80103586:	e8 d6 cc ff ff       	call   80100261 <brelse>
8010358b:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010358e:	83 ec 0c             	sub    $0xc,%esp
80103591:	ff 75 ec             	pushl  -0x14(%ebp)
80103594:	e8 c8 cc ff ff       	call   80100261 <brelse>
80103599:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010359c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035a0:	a1 68 47 11 80       	mov    0x80114768,%eax
801035a5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035a8:	0f 8c 5d ff ff ff    	jl     8010350b <install_trans+0x16>
  }
}
801035ae:	90                   	nop
801035af:	90                   	nop
801035b0:	c9                   	leave  
801035b1:	c3                   	ret    

801035b2 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801035b2:	f3 0f 1e fb          	endbr32 
801035b6:	55                   	push   %ebp
801035b7:	89 e5                	mov    %esp,%ebp
801035b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801035bc:	a1 54 47 11 80       	mov    0x80114754,%eax
801035c1:	89 c2                	mov    %eax,%edx
801035c3:	a1 64 47 11 80       	mov    0x80114764,%eax
801035c8:	83 ec 08             	sub    $0x8,%esp
801035cb:	52                   	push   %edx
801035cc:	50                   	push   %eax
801035cd:	e8 05 cc ff ff       	call   801001d7 <bread>
801035d2:	83 c4 10             	add    $0x10,%esp
801035d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801035d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035db:	83 c0 5c             	add    $0x5c,%eax
801035de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801035e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035e4:	8b 00                	mov    (%eax),%eax
801035e6:	a3 68 47 11 80       	mov    %eax,0x80114768
  for (i = 0; i < log.lh.n; i++) {
801035eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035f2:	eb 1b                	jmp    8010360f <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
801035f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035fa:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801035fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103601:	83 c2 10             	add    $0x10,%edx
80103604:	89 04 95 2c 47 11 80 	mov    %eax,-0x7feeb8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010360b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010360f:	a1 68 47 11 80       	mov    0x80114768,%eax
80103614:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103617:	7c db                	jl     801035f4 <read_head+0x42>
  }
  brelse(buf);
80103619:	83 ec 0c             	sub    $0xc,%esp
8010361c:	ff 75 f0             	pushl  -0x10(%ebp)
8010361f:	e8 3d cc ff ff       	call   80100261 <brelse>
80103624:	83 c4 10             	add    $0x10,%esp
}
80103627:	90                   	nop
80103628:	c9                   	leave  
80103629:	c3                   	ret    

8010362a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010362a:	f3 0f 1e fb          	endbr32 
8010362e:	55                   	push   %ebp
8010362f:	89 e5                	mov    %esp,%ebp
80103631:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103634:	a1 54 47 11 80       	mov    0x80114754,%eax
80103639:	89 c2                	mov    %eax,%edx
8010363b:	a1 64 47 11 80       	mov    0x80114764,%eax
80103640:	83 ec 08             	sub    $0x8,%esp
80103643:	52                   	push   %edx
80103644:	50                   	push   %eax
80103645:	e8 8d cb ff ff       	call   801001d7 <bread>
8010364a:	83 c4 10             	add    $0x10,%esp
8010364d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103650:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103653:	83 c0 5c             	add    $0x5c,%eax
80103656:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103659:	8b 15 68 47 11 80    	mov    0x80114768,%edx
8010365f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103662:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103664:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010366b:	eb 1b                	jmp    80103688 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
8010366d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103670:	83 c0 10             	add    $0x10,%eax
80103673:	8b 0c 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%ecx
8010367a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010367d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103680:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103684:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103688:	a1 68 47 11 80       	mov    0x80114768,%eax
8010368d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103690:	7c db                	jl     8010366d <write_head+0x43>
  }
  bwrite(buf);
80103692:	83 ec 0c             	sub    $0xc,%esp
80103695:	ff 75 f0             	pushl  -0x10(%ebp)
80103698:	e8 77 cb ff ff       	call   80100214 <bwrite>
8010369d:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801036a0:	83 ec 0c             	sub    $0xc,%esp
801036a3:	ff 75 f0             	pushl  -0x10(%ebp)
801036a6:	e8 b6 cb ff ff       	call   80100261 <brelse>
801036ab:	83 c4 10             	add    $0x10,%esp
}
801036ae:	90                   	nop
801036af:	c9                   	leave  
801036b0:	c3                   	ret    

801036b1 <recover_from_log>:

static void
recover_from_log(void)
{
801036b1:	f3 0f 1e fb          	endbr32 
801036b5:	55                   	push   %ebp
801036b6:	89 e5                	mov    %esp,%ebp
801036b8:	83 ec 08             	sub    $0x8,%esp
  read_head();
801036bb:	e8 f2 fe ff ff       	call   801035b2 <read_head>
  install_trans(); // if committed, copy from log to disk
801036c0:	e8 30 fe ff ff       	call   801034f5 <install_trans>
  log.lh.n = 0;
801036c5:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
801036cc:	00 00 00 
  write_head(); // clear the log
801036cf:	e8 56 ff ff ff       	call   8010362a <write_head>
}
801036d4:	90                   	nop
801036d5:	c9                   	leave  
801036d6:	c3                   	ret    

801036d7 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801036d7:	f3 0f 1e fb          	endbr32 
801036db:	55                   	push   %ebp
801036dc:	89 e5                	mov    %esp,%ebp
801036de:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801036e1:	83 ec 0c             	sub    $0xc,%esp
801036e4:	68 20 47 11 80       	push   $0x80114720
801036e9:	e8 a0 1b 00 00       	call   8010528e <acquire>
801036ee:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801036f1:	a1 60 47 11 80       	mov    0x80114760,%eax
801036f6:	85 c0                	test   %eax,%eax
801036f8:	74 17                	je     80103711 <begin_op+0x3a>
      sleep(&log, &log.lock);
801036fa:	83 ec 08             	sub    $0x8,%esp
801036fd:	68 20 47 11 80       	push   $0x80114720
80103702:	68 20 47 11 80       	push   $0x80114720
80103707:	e8 10 17 00 00       	call   80104e1c <sleep>
8010370c:	83 c4 10             	add    $0x10,%esp
8010370f:	eb e0                	jmp    801036f1 <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103711:	8b 0d 68 47 11 80    	mov    0x80114768,%ecx
80103717:	a1 5c 47 11 80       	mov    0x8011475c,%eax
8010371c:	8d 50 01             	lea    0x1(%eax),%edx
8010371f:	89 d0                	mov    %edx,%eax
80103721:	c1 e0 02             	shl    $0x2,%eax
80103724:	01 d0                	add    %edx,%eax
80103726:	01 c0                	add    %eax,%eax
80103728:	01 c8                	add    %ecx,%eax
8010372a:	83 f8 1e             	cmp    $0x1e,%eax
8010372d:	7e 17                	jle    80103746 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010372f:	83 ec 08             	sub    $0x8,%esp
80103732:	68 20 47 11 80       	push   $0x80114720
80103737:	68 20 47 11 80       	push   $0x80114720
8010373c:	e8 db 16 00 00       	call   80104e1c <sleep>
80103741:	83 c4 10             	add    $0x10,%esp
80103744:	eb ab                	jmp    801036f1 <begin_op+0x1a>
    } else {
      log.outstanding += 1;
80103746:	a1 5c 47 11 80       	mov    0x8011475c,%eax
8010374b:	83 c0 01             	add    $0x1,%eax
8010374e:	a3 5c 47 11 80       	mov    %eax,0x8011475c
      release(&log.lock);
80103753:	83 ec 0c             	sub    $0xc,%esp
80103756:	68 20 47 11 80       	push   $0x80114720
8010375b:	e8 a0 1b 00 00       	call   80105300 <release>
80103760:	83 c4 10             	add    $0x10,%esp
      break;
80103763:	90                   	nop
    }
  }
}
80103764:	90                   	nop
80103765:	c9                   	leave  
80103766:	c3                   	ret    

80103767 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103767:	f3 0f 1e fb          	endbr32 
8010376b:	55                   	push   %ebp
8010376c:	89 e5                	mov    %esp,%ebp
8010376e:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103771:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103778:	83 ec 0c             	sub    $0xc,%esp
8010377b:	68 20 47 11 80       	push   $0x80114720
80103780:	e8 09 1b 00 00       	call   8010528e <acquire>
80103785:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103788:	a1 5c 47 11 80       	mov    0x8011475c,%eax
8010378d:	83 e8 01             	sub    $0x1,%eax
80103790:	a3 5c 47 11 80       	mov    %eax,0x8011475c
  if(log.committing)
80103795:	a1 60 47 11 80       	mov    0x80114760,%eax
8010379a:	85 c0                	test   %eax,%eax
8010379c:	74 0d                	je     801037ab <end_op+0x44>
    panic("log.committing");
8010379e:	83 ec 0c             	sub    $0xc,%esp
801037a1:	68 21 93 10 80       	push   $0x80109321
801037a6:	e8 5d ce ff ff       	call   80100608 <panic>
  if(log.outstanding == 0){
801037ab:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801037b0:	85 c0                	test   %eax,%eax
801037b2:	75 13                	jne    801037c7 <end_op+0x60>
    do_commit = 1;
801037b4:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801037bb:	c7 05 60 47 11 80 01 	movl   $0x1,0x80114760
801037c2:	00 00 00 
801037c5:	eb 10                	jmp    801037d7 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801037c7:	83 ec 0c             	sub    $0xc,%esp
801037ca:	68 20 47 11 80       	push   $0x80114720
801037cf:	e8 3a 17 00 00       	call   80104f0e <wakeup>
801037d4:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801037d7:	83 ec 0c             	sub    $0xc,%esp
801037da:	68 20 47 11 80       	push   $0x80114720
801037df:	e8 1c 1b 00 00       	call   80105300 <release>
801037e4:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801037e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037eb:	74 3f                	je     8010382c <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801037ed:	e8 fa 00 00 00       	call   801038ec <commit>
    acquire(&log.lock);
801037f2:	83 ec 0c             	sub    $0xc,%esp
801037f5:	68 20 47 11 80       	push   $0x80114720
801037fa:	e8 8f 1a 00 00       	call   8010528e <acquire>
801037ff:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103802:	c7 05 60 47 11 80 00 	movl   $0x0,0x80114760
80103809:	00 00 00 
    wakeup(&log);
8010380c:	83 ec 0c             	sub    $0xc,%esp
8010380f:	68 20 47 11 80       	push   $0x80114720
80103814:	e8 f5 16 00 00       	call   80104f0e <wakeup>
80103819:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010381c:	83 ec 0c             	sub    $0xc,%esp
8010381f:	68 20 47 11 80       	push   $0x80114720
80103824:	e8 d7 1a 00 00       	call   80105300 <release>
80103829:	83 c4 10             	add    $0x10,%esp
  }
}
8010382c:	90                   	nop
8010382d:	c9                   	leave  
8010382e:	c3                   	ret    

8010382f <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010382f:	f3 0f 1e fb          	endbr32 
80103833:	55                   	push   %ebp
80103834:	89 e5                	mov    %esp,%ebp
80103836:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103839:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103840:	e9 95 00 00 00       	jmp    801038da <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103845:	8b 15 54 47 11 80    	mov    0x80114754,%edx
8010384b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010384e:	01 d0                	add    %edx,%eax
80103850:	83 c0 01             	add    $0x1,%eax
80103853:	89 c2                	mov    %eax,%edx
80103855:	a1 64 47 11 80       	mov    0x80114764,%eax
8010385a:	83 ec 08             	sub    $0x8,%esp
8010385d:	52                   	push   %edx
8010385e:	50                   	push   %eax
8010385f:	e8 73 c9 ff ff       	call   801001d7 <bread>
80103864:	83 c4 10             	add    $0x10,%esp
80103867:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010386a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010386d:	83 c0 10             	add    $0x10,%eax
80103870:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
80103877:	89 c2                	mov    %eax,%edx
80103879:	a1 64 47 11 80       	mov    0x80114764,%eax
8010387e:	83 ec 08             	sub    $0x8,%esp
80103881:	52                   	push   %edx
80103882:	50                   	push   %eax
80103883:	e8 4f c9 ff ff       	call   801001d7 <bread>
80103888:	83 c4 10             	add    $0x10,%esp
8010388b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010388e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103891:	8d 50 5c             	lea    0x5c(%eax),%edx
80103894:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103897:	83 c0 5c             	add    $0x5c,%eax
8010389a:	83 ec 04             	sub    $0x4,%esp
8010389d:	68 00 02 00 00       	push   $0x200
801038a2:	52                   	push   %edx
801038a3:	50                   	push   %eax
801038a4:	e8 4b 1d 00 00       	call   801055f4 <memmove>
801038a9:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801038ac:	83 ec 0c             	sub    $0xc,%esp
801038af:	ff 75 f0             	pushl  -0x10(%ebp)
801038b2:	e8 5d c9 ff ff       	call   80100214 <bwrite>
801038b7:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801038ba:	83 ec 0c             	sub    $0xc,%esp
801038bd:	ff 75 ec             	pushl  -0x14(%ebp)
801038c0:	e8 9c c9 ff ff       	call   80100261 <brelse>
801038c5:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801038c8:	83 ec 0c             	sub    $0xc,%esp
801038cb:	ff 75 f0             	pushl  -0x10(%ebp)
801038ce:	e8 8e c9 ff ff       	call   80100261 <brelse>
801038d3:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801038d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801038da:	a1 68 47 11 80       	mov    0x80114768,%eax
801038df:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801038e2:	0f 8c 5d ff ff ff    	jl     80103845 <write_log+0x16>
  }
}
801038e8:	90                   	nop
801038e9:	90                   	nop
801038ea:	c9                   	leave  
801038eb:	c3                   	ret    

801038ec <commit>:

static void
commit()
{
801038ec:	f3 0f 1e fb          	endbr32 
801038f0:	55                   	push   %ebp
801038f1:	89 e5                	mov    %esp,%ebp
801038f3:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801038f6:	a1 68 47 11 80       	mov    0x80114768,%eax
801038fb:	85 c0                	test   %eax,%eax
801038fd:	7e 1e                	jle    8010391d <commit+0x31>
    write_log();     // Write modified blocks from cache to log
801038ff:	e8 2b ff ff ff       	call   8010382f <write_log>
    write_head();    // Write header to disk -- the real commit
80103904:	e8 21 fd ff ff       	call   8010362a <write_head>
    install_trans(); // Now install writes to home locations
80103909:	e8 e7 fb ff ff       	call   801034f5 <install_trans>
    log.lh.n = 0;
8010390e:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
80103915:	00 00 00 
    write_head();    // Erase the transaction from the log
80103918:	e8 0d fd ff ff       	call   8010362a <write_head>
  }
}
8010391d:	90                   	nop
8010391e:	c9                   	leave  
8010391f:	c3                   	ret    

80103920 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103920:	f3 0f 1e fb          	endbr32 
80103924:	55                   	push   %ebp
80103925:	89 e5                	mov    %esp,%ebp
80103927:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010392a:	a1 68 47 11 80       	mov    0x80114768,%eax
8010392f:	83 f8 1d             	cmp    $0x1d,%eax
80103932:	7f 12                	jg     80103946 <log_write+0x26>
80103934:	a1 68 47 11 80       	mov    0x80114768,%eax
80103939:	8b 15 58 47 11 80    	mov    0x80114758,%edx
8010393f:	83 ea 01             	sub    $0x1,%edx
80103942:	39 d0                	cmp    %edx,%eax
80103944:	7c 0d                	jl     80103953 <log_write+0x33>
    panic("too big a transaction");
80103946:	83 ec 0c             	sub    $0xc,%esp
80103949:	68 30 93 10 80       	push   $0x80109330
8010394e:	e8 b5 cc ff ff       	call   80100608 <panic>
  if (log.outstanding < 1)
80103953:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103958:	85 c0                	test   %eax,%eax
8010395a:	7f 0d                	jg     80103969 <log_write+0x49>
    panic("log_write outside of trans");
8010395c:	83 ec 0c             	sub    $0xc,%esp
8010395f:	68 46 93 10 80       	push   $0x80109346
80103964:	e8 9f cc ff ff       	call   80100608 <panic>

  acquire(&log.lock);
80103969:	83 ec 0c             	sub    $0xc,%esp
8010396c:	68 20 47 11 80       	push   $0x80114720
80103971:	e8 18 19 00 00       	call   8010528e <acquire>
80103976:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103979:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103980:	eb 1d                	jmp    8010399f <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103985:	83 c0 10             	add    $0x10,%eax
80103988:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
8010398f:	89 c2                	mov    %eax,%edx
80103991:	8b 45 08             	mov    0x8(%ebp),%eax
80103994:	8b 40 08             	mov    0x8(%eax),%eax
80103997:	39 c2                	cmp    %eax,%edx
80103999:	74 10                	je     801039ab <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
8010399b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010399f:	a1 68 47 11 80       	mov    0x80114768,%eax
801039a4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039a7:	7c d9                	jl     80103982 <log_write+0x62>
801039a9:	eb 01                	jmp    801039ac <log_write+0x8c>
      break;
801039ab:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801039ac:	8b 45 08             	mov    0x8(%ebp),%eax
801039af:	8b 40 08             	mov    0x8(%eax),%eax
801039b2:	89 c2                	mov    %eax,%edx
801039b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039b7:	83 c0 10             	add    $0x10,%eax
801039ba:	89 14 85 2c 47 11 80 	mov    %edx,-0x7feeb8d4(,%eax,4)
  if (i == log.lh.n)
801039c1:	a1 68 47 11 80       	mov    0x80114768,%eax
801039c6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039c9:	75 0d                	jne    801039d8 <log_write+0xb8>
    log.lh.n++;
801039cb:	a1 68 47 11 80       	mov    0x80114768,%eax
801039d0:	83 c0 01             	add    $0x1,%eax
801039d3:	a3 68 47 11 80       	mov    %eax,0x80114768
  b->flags |= B_DIRTY; // prevent eviction
801039d8:	8b 45 08             	mov    0x8(%ebp),%eax
801039db:	8b 00                	mov    (%eax),%eax
801039dd:	83 c8 04             	or     $0x4,%eax
801039e0:	89 c2                	mov    %eax,%edx
801039e2:	8b 45 08             	mov    0x8(%ebp),%eax
801039e5:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801039e7:	83 ec 0c             	sub    $0xc,%esp
801039ea:	68 20 47 11 80       	push   $0x80114720
801039ef:	e8 0c 19 00 00       	call   80105300 <release>
801039f4:	83 c4 10             	add    $0x10,%esp
}
801039f7:	90                   	nop
801039f8:	c9                   	leave  
801039f9:	c3                   	ret    

801039fa <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801039fa:	55                   	push   %ebp
801039fb:	89 e5                	mov    %esp,%ebp
801039fd:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103a00:	8b 55 08             	mov    0x8(%ebp),%edx
80103a03:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a06:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103a09:	f0 87 02             	lock xchg %eax,(%edx)
80103a0c:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103a0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103a12:	c9                   	leave  
80103a13:	c3                   	ret    

80103a14 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103a14:	f3 0f 1e fb          	endbr32 
80103a18:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103a1c:	83 e4 f0             	and    $0xfffffff0,%esp
80103a1f:	ff 71 fc             	pushl  -0x4(%ecx)
80103a22:	55                   	push   %ebp
80103a23:	89 e5                	mov    %esp,%ebp
80103a25:	51                   	push   %ecx
80103a26:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103a29:	83 ec 08             	sub    $0x8,%esp
80103a2c:	68 00 00 40 80       	push   $0x80400000
80103a31:	68 48 89 11 80       	push   $0x80118948
80103a36:	e8 78 f2 ff ff       	call   80102cb3 <kinit1>
80103a3b:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103a3e:	e8 e0 49 00 00       	call   80108423 <kvmalloc>
  mpinit();        // detect other processors
80103a43:	e8 d9 03 00 00       	call   80103e21 <mpinit>
  lapicinit();     // interrupt controller
80103a48:	e8 f5 f5 ff ff       	call   80103042 <lapicinit>
  seginit();       // segment descriptors
80103a4d:	e8 84 44 00 00       	call   80107ed6 <seginit>
  picinit();       // disable pic
80103a52:	e8 35 05 00 00       	call   80103f8c <picinit>
  ioapicinit();    // another interrupt controller
80103a57:	e8 6a f1 ff ff       	call   80102bc6 <ioapicinit>
  consoleinit();   // console hardware
80103a5c:	e8 80 d1 ff ff       	call   80100be1 <consoleinit>
  uartinit();      // serial port
80103a61:	e8 df 34 00 00       	call   80106f45 <uartinit>
  pinit();         // process table
80103a66:	e8 6e 09 00 00       	call   801043d9 <pinit>
  tvinit();        // trap vectors
80103a6b:	e8 87 30 00 00       	call   80106af7 <tvinit>
  binit();         // buffer cache
80103a70:	e8 bf c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103a75:	e8 26 d6 ff ff       	call   801010a0 <fileinit>
  ideinit();       // disk 
80103a7a:	e8 06 ed ff ff       	call   80102785 <ideinit>
  startothers();   // start other processors
80103a7f:	e8 88 00 00 00       	call   80103b0c <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103a84:	83 ec 08             	sub    $0x8,%esp
80103a87:	68 00 00 00 8e       	push   $0x8e000000
80103a8c:	68 00 00 40 80       	push   $0x80400000
80103a91:	e8 5a f2 ff ff       	call   80102cf0 <kinit2>
80103a96:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103a99:	e8 5e 0b 00 00       	call   801045fc <userinit>
  mpmain();        // finish this processor's setup
80103a9e:	e8 1e 00 00 00       	call   80103ac1 <mpmain>

80103aa3 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103aa3:	f3 0f 1e fb          	endbr32 
80103aa7:	55                   	push   %ebp
80103aa8:	89 e5                	mov    %esp,%ebp
80103aaa:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103aad:	e8 8d 49 00 00       	call   8010843f <switchkvm>
  seginit();
80103ab2:	e8 1f 44 00 00       	call   80107ed6 <seginit>
  lapicinit();
80103ab7:	e8 86 f5 ff ff       	call   80103042 <lapicinit>
  mpmain();
80103abc:	e8 00 00 00 00       	call   80103ac1 <mpmain>

80103ac1 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103ac1:	f3 0f 1e fb          	endbr32 
80103ac5:	55                   	push   %ebp
80103ac6:	89 e5                	mov    %esp,%ebp
80103ac8:	53                   	push   %ebx
80103ac9:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103acc:	e8 2a 09 00 00       	call   801043fb <cpuid>
80103ad1:	89 c3                	mov    %eax,%ebx
80103ad3:	e8 23 09 00 00       	call   801043fb <cpuid>
80103ad8:	83 ec 04             	sub    $0x4,%esp
80103adb:	53                   	push   %ebx
80103adc:	50                   	push   %eax
80103add:	68 61 93 10 80       	push   $0x80109361
80103ae2:	e8 31 c9 ff ff       	call   80100418 <cprintf>
80103ae7:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103aea:	e8 82 31 00 00       	call   80106c71 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103aef:	e8 26 09 00 00       	call   8010441a <mycpu>
80103af4:	05 a0 00 00 00       	add    $0xa0,%eax
80103af9:	83 ec 08             	sub    $0x8,%esp
80103afc:	6a 01                	push   $0x1
80103afe:	50                   	push   %eax
80103aff:	e8 f6 fe ff ff       	call   801039fa <xchg>
80103b04:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103b07:	e8 0c 11 00 00       	call   80104c18 <scheduler>

80103b0c <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103b0c:	f3 0f 1e fb          	endbr32 
80103b10:	55                   	push   %ebp
80103b11:	89 e5                	mov    %esp,%ebp
80103b13:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103b16:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103b1d:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103b22:	83 ec 04             	sub    $0x4,%esp
80103b25:	50                   	push   %eax
80103b26:	68 0c c5 10 80       	push   $0x8010c50c
80103b2b:	ff 75 f0             	pushl  -0x10(%ebp)
80103b2e:	e8 c1 1a 00 00       	call   801055f4 <memmove>
80103b33:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103b36:	c7 45 f4 20 48 11 80 	movl   $0x80114820,-0xc(%ebp)
80103b3d:	eb 79                	jmp    80103bb8 <startothers+0xac>
    if(c == mycpu())  // We've started already.
80103b3f:	e8 d6 08 00 00       	call   8010441a <mycpu>
80103b44:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b47:	74 67                	je     80103bb0 <startothers+0xa4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103b49:	e8 aa f2 ff ff       	call   80102df8 <kalloc>
80103b4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b54:	83 e8 04             	sub    $0x4,%eax
80103b57:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b5a:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103b60:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b65:	83 e8 08             	sub    $0x8,%eax
80103b68:	c7 00 a3 3a 10 80    	movl   $0x80103aa3,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103b6e:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103b73:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b7c:	83 e8 0c             	sub    $0xc,%eax
80103b7f:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b84:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8d:	0f b6 00             	movzbl (%eax),%eax
80103b90:	0f b6 c0             	movzbl %al,%eax
80103b93:	83 ec 08             	sub    $0x8,%esp
80103b96:	52                   	push   %edx
80103b97:	50                   	push   %eax
80103b98:	e8 17 f6 ff ff       	call   801031b4 <lapicstartap>
80103b9d:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103ba0:	90                   	nop
80103ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103baa:	85 c0                	test   %eax,%eax
80103bac:	74 f3                	je     80103ba1 <startothers+0x95>
80103bae:	eb 01                	jmp    80103bb1 <startothers+0xa5>
      continue;
80103bb0:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103bb1:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103bb8:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103bbd:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103bc3:	05 20 48 11 80       	add    $0x80114820,%eax
80103bc8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103bcb:	0f 82 6e ff ff ff    	jb     80103b3f <startothers+0x33>
      ;
  }
}
80103bd1:	90                   	nop
80103bd2:	90                   	nop
80103bd3:	c9                   	leave  
80103bd4:	c3                   	ret    

80103bd5 <inb>:
{
80103bd5:	55                   	push   %ebp
80103bd6:	89 e5                	mov    %esp,%ebp
80103bd8:	83 ec 14             	sub    $0x14,%esp
80103bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80103bde:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103be2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103be6:	89 c2                	mov    %eax,%edx
80103be8:	ec                   	in     (%dx),%al
80103be9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103bec:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103bf0:	c9                   	leave  
80103bf1:	c3                   	ret    

80103bf2 <outb>:
{
80103bf2:	55                   	push   %ebp
80103bf3:	89 e5                	mov    %esp,%ebp
80103bf5:	83 ec 08             	sub    $0x8,%esp
80103bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80103bfb:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bfe:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103c02:	89 d0                	mov    %edx,%eax
80103c04:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c07:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103c0b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103c0f:	ee                   	out    %al,(%dx)
}
80103c10:	90                   	nop
80103c11:	c9                   	leave  
80103c12:	c3                   	ret    

80103c13 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103c13:	f3 0f 1e fb          	endbr32 
80103c17:	55                   	push   %ebp
80103c18:	89 e5                	mov    %esp,%ebp
80103c1a:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103c1d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c24:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103c2b:	eb 15                	jmp    80103c42 <sum+0x2f>
    sum += addr[i];
80103c2d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103c30:	8b 45 08             	mov    0x8(%ebp),%eax
80103c33:	01 d0                	add    %edx,%eax
80103c35:	0f b6 00             	movzbl (%eax),%eax
80103c38:	0f b6 c0             	movzbl %al,%eax
80103c3b:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c3e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103c42:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103c45:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103c48:	7c e3                	jl     80103c2d <sum+0x1a>
  return sum;
80103c4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103c4d:	c9                   	leave  
80103c4e:	c3                   	ret    

80103c4f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103c4f:	f3 0f 1e fb          	endbr32 
80103c53:	55                   	push   %ebp
80103c54:	89 e5                	mov    %esp,%ebp
80103c56:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103c59:	8b 45 08             	mov    0x8(%ebp),%eax
80103c5c:	05 00 00 00 80       	add    $0x80000000,%eax
80103c61:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103c64:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c6a:	01 d0                	add    %edx,%eax
80103c6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103c6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c72:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c75:	eb 36                	jmp    80103cad <mpsearch1+0x5e>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103c77:	83 ec 04             	sub    $0x4,%esp
80103c7a:	6a 04                	push   $0x4
80103c7c:	68 78 93 10 80       	push   $0x80109378
80103c81:	ff 75 f4             	pushl  -0xc(%ebp)
80103c84:	e8 0f 19 00 00       	call   80105598 <memcmp>
80103c89:	83 c4 10             	add    $0x10,%esp
80103c8c:	85 c0                	test   %eax,%eax
80103c8e:	75 19                	jne    80103ca9 <mpsearch1+0x5a>
80103c90:	83 ec 08             	sub    $0x8,%esp
80103c93:	6a 10                	push   $0x10
80103c95:	ff 75 f4             	pushl  -0xc(%ebp)
80103c98:	e8 76 ff ff ff       	call   80103c13 <sum>
80103c9d:	83 c4 10             	add    $0x10,%esp
80103ca0:	84 c0                	test   %al,%al
80103ca2:	75 05                	jne    80103ca9 <mpsearch1+0x5a>
      return (struct mp*)p;
80103ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca7:	eb 11                	jmp    80103cba <mpsearch1+0x6b>
  for(p = addr; p < e; p += sizeof(struct mp))
80103ca9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cb3:	72 c2                	jb     80103c77 <mpsearch1+0x28>
  return 0;
80103cb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103cba:	c9                   	leave  
80103cbb:	c3                   	ret    

80103cbc <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103cbc:	f3 0f 1e fb          	endbr32 
80103cc0:	55                   	push   %ebp
80103cc1:	89 e5                	mov    %esp,%ebp
80103cc3:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103cc6:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd0:	83 c0 0f             	add    $0xf,%eax
80103cd3:	0f b6 00             	movzbl (%eax),%eax
80103cd6:	0f b6 c0             	movzbl %al,%eax
80103cd9:	c1 e0 08             	shl    $0x8,%eax
80103cdc:	89 c2                	mov    %eax,%edx
80103cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce1:	83 c0 0e             	add    $0xe,%eax
80103ce4:	0f b6 00             	movzbl (%eax),%eax
80103ce7:	0f b6 c0             	movzbl %al,%eax
80103cea:	09 d0                	or     %edx,%eax
80103cec:	c1 e0 04             	shl    $0x4,%eax
80103cef:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103cf2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103cf6:	74 21                	je     80103d19 <mpsearch+0x5d>
    if((mp = mpsearch1(p, 1024)))
80103cf8:	83 ec 08             	sub    $0x8,%esp
80103cfb:	68 00 04 00 00       	push   $0x400
80103d00:	ff 75 f0             	pushl  -0x10(%ebp)
80103d03:	e8 47 ff ff ff       	call   80103c4f <mpsearch1>
80103d08:	83 c4 10             	add    $0x10,%esp
80103d0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d0e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d12:	74 51                	je     80103d65 <mpsearch+0xa9>
      return mp;
80103d14:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d17:	eb 61                	jmp    80103d7a <mpsearch+0xbe>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1c:	83 c0 14             	add    $0x14,%eax
80103d1f:	0f b6 00             	movzbl (%eax),%eax
80103d22:	0f b6 c0             	movzbl %al,%eax
80103d25:	c1 e0 08             	shl    $0x8,%eax
80103d28:	89 c2                	mov    %eax,%edx
80103d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d2d:	83 c0 13             	add    $0x13,%eax
80103d30:	0f b6 00             	movzbl (%eax),%eax
80103d33:	0f b6 c0             	movzbl %al,%eax
80103d36:	09 d0                	or     %edx,%eax
80103d38:	c1 e0 0a             	shl    $0xa,%eax
80103d3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103d3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d41:	2d 00 04 00 00       	sub    $0x400,%eax
80103d46:	83 ec 08             	sub    $0x8,%esp
80103d49:	68 00 04 00 00       	push   $0x400
80103d4e:	50                   	push   %eax
80103d4f:	e8 fb fe ff ff       	call   80103c4f <mpsearch1>
80103d54:	83 c4 10             	add    $0x10,%esp
80103d57:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d5a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d5e:	74 05                	je     80103d65 <mpsearch+0xa9>
      return mp;
80103d60:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d63:	eb 15                	jmp    80103d7a <mpsearch+0xbe>
  }
  return mpsearch1(0xF0000, 0x10000);
80103d65:	83 ec 08             	sub    $0x8,%esp
80103d68:	68 00 00 01 00       	push   $0x10000
80103d6d:	68 00 00 0f 00       	push   $0xf0000
80103d72:	e8 d8 fe ff ff       	call   80103c4f <mpsearch1>
80103d77:	83 c4 10             	add    $0x10,%esp
}
80103d7a:	c9                   	leave  
80103d7b:	c3                   	ret    

80103d7c <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103d7c:	f3 0f 1e fb          	endbr32 
80103d80:	55                   	push   %ebp
80103d81:	89 e5                	mov    %esp,%ebp
80103d83:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103d86:	e8 31 ff ff ff       	call   80103cbc <mpsearch>
80103d8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d92:	74 0a                	je     80103d9e <mpconfig+0x22>
80103d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d97:	8b 40 04             	mov    0x4(%eax),%eax
80103d9a:	85 c0                	test   %eax,%eax
80103d9c:	75 07                	jne    80103da5 <mpconfig+0x29>
    return 0;
80103d9e:	b8 00 00 00 00       	mov    $0x0,%eax
80103da3:	eb 7a                	jmp    80103e1f <mpconfig+0xa3>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da8:	8b 40 04             	mov    0x4(%eax),%eax
80103dab:	05 00 00 00 80       	add    $0x80000000,%eax
80103db0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103db3:	83 ec 04             	sub    $0x4,%esp
80103db6:	6a 04                	push   $0x4
80103db8:	68 7d 93 10 80       	push   $0x8010937d
80103dbd:	ff 75 f0             	pushl  -0x10(%ebp)
80103dc0:	e8 d3 17 00 00       	call   80105598 <memcmp>
80103dc5:	83 c4 10             	add    $0x10,%esp
80103dc8:	85 c0                	test   %eax,%eax
80103dca:	74 07                	je     80103dd3 <mpconfig+0x57>
    return 0;
80103dcc:	b8 00 00 00 00       	mov    $0x0,%eax
80103dd1:	eb 4c                	jmp    80103e1f <mpconfig+0xa3>
  if(conf->version != 1 && conf->version != 4)
80103dd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dd6:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103dda:	3c 01                	cmp    $0x1,%al
80103ddc:	74 12                	je     80103df0 <mpconfig+0x74>
80103dde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103de1:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103de5:	3c 04                	cmp    $0x4,%al
80103de7:	74 07                	je     80103df0 <mpconfig+0x74>
    return 0;
80103de9:	b8 00 00 00 00       	mov    $0x0,%eax
80103dee:	eb 2f                	jmp    80103e1f <mpconfig+0xa3>
  if(sum((uchar*)conf, conf->length) != 0)
80103df0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103df3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103df7:	0f b7 c0             	movzwl %ax,%eax
80103dfa:	83 ec 08             	sub    $0x8,%esp
80103dfd:	50                   	push   %eax
80103dfe:	ff 75 f0             	pushl  -0x10(%ebp)
80103e01:	e8 0d fe ff ff       	call   80103c13 <sum>
80103e06:	83 c4 10             	add    $0x10,%esp
80103e09:	84 c0                	test   %al,%al
80103e0b:	74 07                	je     80103e14 <mpconfig+0x98>
    return 0;
80103e0d:	b8 00 00 00 00       	mov    $0x0,%eax
80103e12:	eb 0b                	jmp    80103e1f <mpconfig+0xa3>
  *pmp = mp;
80103e14:	8b 45 08             	mov    0x8(%ebp),%eax
80103e17:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e1a:	89 10                	mov    %edx,(%eax)
  return conf;
80103e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103e1f:	c9                   	leave  
80103e20:	c3                   	ret    

80103e21 <mpinit>:

void
mpinit(void)
{
80103e21:	f3 0f 1e fb          	endbr32 
80103e25:	55                   	push   %ebp
80103e26:	89 e5                	mov    %esp,%ebp
80103e28:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103e2b:	83 ec 0c             	sub    $0xc,%esp
80103e2e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103e31:	50                   	push   %eax
80103e32:	e8 45 ff ff ff       	call   80103d7c <mpconfig>
80103e37:	83 c4 10             	add    $0x10,%esp
80103e3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e3d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e41:	75 0d                	jne    80103e50 <mpinit+0x2f>
    panic("Expect to run on an SMP");
80103e43:	83 ec 0c             	sub    $0xc,%esp
80103e46:	68 82 93 10 80       	push   $0x80109382
80103e4b:	e8 b8 c7 ff ff       	call   80100608 <panic>
  ismp = 1;
80103e50:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103e57:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e5a:	8b 40 24             	mov    0x24(%eax),%eax
80103e5d:	a3 1c 47 11 80       	mov    %eax,0x8011471c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e62:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e65:	83 c0 2c             	add    $0x2c,%eax
80103e68:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e6e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e72:	0f b7 d0             	movzwl %ax,%edx
80103e75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e78:	01 d0                	add    %edx,%eax
80103e7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103e7d:	e9 8c 00 00 00       	jmp    80103f0e <mpinit+0xed>
    switch(*p){
80103e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e85:	0f b6 00             	movzbl (%eax),%eax
80103e88:	0f b6 c0             	movzbl %al,%eax
80103e8b:	83 f8 04             	cmp    $0x4,%eax
80103e8e:	7f 76                	jg     80103f06 <mpinit+0xe5>
80103e90:	83 f8 03             	cmp    $0x3,%eax
80103e93:	7d 6b                	jge    80103f00 <mpinit+0xdf>
80103e95:	83 f8 02             	cmp    $0x2,%eax
80103e98:	74 4e                	je     80103ee8 <mpinit+0xc7>
80103e9a:	83 f8 02             	cmp    $0x2,%eax
80103e9d:	7f 67                	jg     80103f06 <mpinit+0xe5>
80103e9f:	85 c0                	test   %eax,%eax
80103ea1:	74 07                	je     80103eaa <mpinit+0x89>
80103ea3:	83 f8 01             	cmp    $0x1,%eax
80103ea6:	74 58                	je     80103f00 <mpinit+0xdf>
80103ea8:	eb 5c                	jmp    80103f06 <mpinit+0xe5>
    case MPPROC:
      proc = (struct mpproc*)p;
80103eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ead:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103eb0:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103eb5:	83 f8 07             	cmp    $0x7,%eax
80103eb8:	7f 28                	jg     80103ee2 <mpinit+0xc1>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103eba:	8b 15 a0 4d 11 80    	mov    0x80114da0,%edx
80103ec0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ec3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ec7:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103ecd:	81 c2 20 48 11 80    	add    $0x80114820,%edx
80103ed3:	88 02                	mov    %al,(%edx)
        ncpu++;
80103ed5:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103eda:	83 c0 01             	add    $0x1,%eax
80103edd:	a3 a0 4d 11 80       	mov    %eax,0x80114da0
      }
      p += sizeof(struct mpproc);
80103ee2:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103ee6:	eb 26                	jmp    80103f0e <mpinit+0xed>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eeb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103eee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103ef1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ef5:	a2 00 48 11 80       	mov    %al,0x80114800
      p += sizeof(struct mpioapic);
80103efa:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103efe:	eb 0e                	jmp    80103f0e <mpinit+0xed>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f00:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f04:	eb 08                	jmp    80103f0e <mpinit+0xed>
    default:
      ismp = 0;
80103f06:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103f0d:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f11:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103f14:	0f 82 68 ff ff ff    	jb     80103e82 <mpinit+0x61>
    }
  }
  if(!ismp)
80103f1a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f1e:	75 0d                	jne    80103f2d <mpinit+0x10c>
    panic("Didn't find a suitable machine");
80103f20:	83 ec 0c             	sub    $0xc,%esp
80103f23:	68 9c 93 10 80       	push   $0x8010939c
80103f28:	e8 db c6 ff ff       	call   80100608 <panic>

  if(mp->imcrp){
80103f2d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f30:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f34:	84 c0                	test   %al,%al
80103f36:	74 30                	je     80103f68 <mpinit+0x147>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f38:	83 ec 08             	sub    $0x8,%esp
80103f3b:	6a 70                	push   $0x70
80103f3d:	6a 22                	push   $0x22
80103f3f:	e8 ae fc ff ff       	call   80103bf2 <outb>
80103f44:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103f47:	83 ec 0c             	sub    $0xc,%esp
80103f4a:	6a 23                	push   $0x23
80103f4c:	e8 84 fc ff ff       	call   80103bd5 <inb>
80103f51:	83 c4 10             	add    $0x10,%esp
80103f54:	83 c8 01             	or     $0x1,%eax
80103f57:	0f b6 c0             	movzbl %al,%eax
80103f5a:	83 ec 08             	sub    $0x8,%esp
80103f5d:	50                   	push   %eax
80103f5e:	6a 23                	push   $0x23
80103f60:	e8 8d fc ff ff       	call   80103bf2 <outb>
80103f65:	83 c4 10             	add    $0x10,%esp
  }
}
80103f68:	90                   	nop
80103f69:	c9                   	leave  
80103f6a:	c3                   	ret    

80103f6b <outb>:
{
80103f6b:	55                   	push   %ebp
80103f6c:	89 e5                	mov    %esp,%ebp
80103f6e:	83 ec 08             	sub    $0x8,%esp
80103f71:	8b 45 08             	mov    0x8(%ebp),%eax
80103f74:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f77:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103f7b:	89 d0                	mov    %edx,%eax
80103f7d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f80:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f84:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f88:	ee                   	out    %al,(%dx)
}
80103f89:	90                   	nop
80103f8a:	c9                   	leave  
80103f8b:	c3                   	ret    

80103f8c <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103f8c:	f3 0f 1e fb          	endbr32 
80103f90:	55                   	push   %ebp
80103f91:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f93:	68 ff 00 00 00       	push   $0xff
80103f98:	6a 21                	push   $0x21
80103f9a:	e8 cc ff ff ff       	call   80103f6b <outb>
80103f9f:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103fa2:	68 ff 00 00 00       	push   $0xff
80103fa7:	68 a1 00 00 00       	push   $0xa1
80103fac:	e8 ba ff ff ff       	call   80103f6b <outb>
80103fb1:	83 c4 08             	add    $0x8,%esp
}
80103fb4:	90                   	nop
80103fb5:	c9                   	leave  
80103fb6:	c3                   	ret    

80103fb7 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fb7:	f3 0f 1e fb          	endbr32 
80103fbb:	55                   	push   %ebp
80103fbc:	89 e5                	mov    %esp,%ebp
80103fbe:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103fc1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fcb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd4:	8b 10                	mov    (%eax),%edx
80103fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd9:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fdb:	e8 e2 d0 ff ff       	call   801010c2 <filealloc>
80103fe0:	8b 55 08             	mov    0x8(%ebp),%edx
80103fe3:	89 02                	mov    %eax,(%edx)
80103fe5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe8:	8b 00                	mov    (%eax),%eax
80103fea:	85 c0                	test   %eax,%eax
80103fec:	0f 84 c8 00 00 00    	je     801040ba <pipealloc+0x103>
80103ff2:	e8 cb d0 ff ff       	call   801010c2 <filealloc>
80103ff7:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ffa:	89 02                	mov    %eax,(%edx)
80103ffc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fff:	8b 00                	mov    (%eax),%eax
80104001:	85 c0                	test   %eax,%eax
80104003:	0f 84 b1 00 00 00    	je     801040ba <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104009:	e8 ea ed ff ff       	call   80102df8 <kalloc>
8010400e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104011:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104015:	0f 84 a2 00 00 00    	je     801040bd <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
8010401b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401e:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104025:	00 00 00 
  p->writeopen = 1;
80104028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402b:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104032:	00 00 00 
  p->nwrite = 0;
80104035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104038:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010403f:	00 00 00 
  p->nread = 0;
80104042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104045:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010404c:	00 00 00 
  initlock(&p->lock, "pipe");
8010404f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104052:	83 ec 08             	sub    $0x8,%esp
80104055:	68 bb 93 10 80       	push   $0x801093bb
8010405a:	50                   	push   %eax
8010405b:	e8 08 12 00 00       	call   80105268 <initlock>
80104060:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104063:	8b 45 08             	mov    0x8(%ebp),%eax
80104066:	8b 00                	mov    (%eax),%eax
80104068:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010406e:	8b 45 08             	mov    0x8(%ebp),%eax
80104071:	8b 00                	mov    (%eax),%eax
80104073:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104077:	8b 45 08             	mov    0x8(%ebp),%eax
8010407a:	8b 00                	mov    (%eax),%eax
8010407c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104080:	8b 45 08             	mov    0x8(%ebp),%eax
80104083:	8b 00                	mov    (%eax),%eax
80104085:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104088:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010408b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408e:	8b 00                	mov    (%eax),%eax
80104090:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104096:	8b 45 0c             	mov    0xc(%ebp),%eax
80104099:	8b 00                	mov    (%eax),%eax
8010409b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010409f:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a2:	8b 00                	mov    (%eax),%eax
801040a4:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801040ab:	8b 00                	mov    (%eax),%eax
801040ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040b0:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040b3:	b8 00 00 00 00       	mov    $0x0,%eax
801040b8:	eb 51                	jmp    8010410b <pipealloc+0x154>
    goto bad;
801040ba:	90                   	nop
801040bb:	eb 01                	jmp    801040be <pipealloc+0x107>
    goto bad;
801040bd:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
801040be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040c2:	74 0e                	je     801040d2 <pipealloc+0x11b>
    kfree((char*)p);
801040c4:	83 ec 0c             	sub    $0xc,%esp
801040c7:	ff 75 f4             	pushl  -0xc(%ebp)
801040ca:	e8 8b ec ff ff       	call   80102d5a <kfree>
801040cf:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801040d2:	8b 45 08             	mov    0x8(%ebp),%eax
801040d5:	8b 00                	mov    (%eax),%eax
801040d7:	85 c0                	test   %eax,%eax
801040d9:	74 11                	je     801040ec <pipealloc+0x135>
    fileclose(*f0);
801040db:	8b 45 08             	mov    0x8(%ebp),%eax
801040de:	8b 00                	mov    (%eax),%eax
801040e0:	83 ec 0c             	sub    $0xc,%esp
801040e3:	50                   	push   %eax
801040e4:	e8 9f d0 ff ff       	call   80101188 <fileclose>
801040e9:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801040ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801040ef:	8b 00                	mov    (%eax),%eax
801040f1:	85 c0                	test   %eax,%eax
801040f3:	74 11                	je     80104106 <pipealloc+0x14f>
    fileclose(*f1);
801040f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f8:	8b 00                	mov    (%eax),%eax
801040fa:	83 ec 0c             	sub    $0xc,%esp
801040fd:	50                   	push   %eax
801040fe:	e8 85 d0 ff ff       	call   80101188 <fileclose>
80104103:	83 c4 10             	add    $0x10,%esp
  return -1;
80104106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010410b:	c9                   	leave  
8010410c:	c3                   	ret    

8010410d <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010410d:	f3 0f 1e fb          	endbr32 
80104111:	55                   	push   %ebp
80104112:	89 e5                	mov    %esp,%ebp
80104114:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104117:	8b 45 08             	mov    0x8(%ebp),%eax
8010411a:	83 ec 0c             	sub    $0xc,%esp
8010411d:	50                   	push   %eax
8010411e:	e8 6b 11 00 00       	call   8010528e <acquire>
80104123:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104126:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010412a:	74 23                	je     8010414f <pipeclose+0x42>
    p->writeopen = 0;
8010412c:	8b 45 08             	mov    0x8(%ebp),%eax
8010412f:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104136:	00 00 00 
    wakeup(&p->nread);
80104139:	8b 45 08             	mov    0x8(%ebp),%eax
8010413c:	05 34 02 00 00       	add    $0x234,%eax
80104141:	83 ec 0c             	sub    $0xc,%esp
80104144:	50                   	push   %eax
80104145:	e8 c4 0d 00 00       	call   80104f0e <wakeup>
8010414a:	83 c4 10             	add    $0x10,%esp
8010414d:	eb 21                	jmp    80104170 <pipeclose+0x63>
  } else {
    p->readopen = 0;
8010414f:	8b 45 08             	mov    0x8(%ebp),%eax
80104152:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104159:	00 00 00 
    wakeup(&p->nwrite);
8010415c:	8b 45 08             	mov    0x8(%ebp),%eax
8010415f:	05 38 02 00 00       	add    $0x238,%eax
80104164:	83 ec 0c             	sub    $0xc,%esp
80104167:	50                   	push   %eax
80104168:	e8 a1 0d 00 00       	call   80104f0e <wakeup>
8010416d:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104170:	8b 45 08             	mov    0x8(%ebp),%eax
80104173:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104179:	85 c0                	test   %eax,%eax
8010417b:	75 2c                	jne    801041a9 <pipeclose+0x9c>
8010417d:	8b 45 08             	mov    0x8(%ebp),%eax
80104180:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104186:	85 c0                	test   %eax,%eax
80104188:	75 1f                	jne    801041a9 <pipeclose+0x9c>
    release(&p->lock);
8010418a:	8b 45 08             	mov    0x8(%ebp),%eax
8010418d:	83 ec 0c             	sub    $0xc,%esp
80104190:	50                   	push   %eax
80104191:	e8 6a 11 00 00       	call   80105300 <release>
80104196:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104199:	83 ec 0c             	sub    $0xc,%esp
8010419c:	ff 75 08             	pushl  0x8(%ebp)
8010419f:	e8 b6 eb ff ff       	call   80102d5a <kfree>
801041a4:	83 c4 10             	add    $0x10,%esp
801041a7:	eb 10                	jmp    801041b9 <pipeclose+0xac>
  } else
    release(&p->lock);
801041a9:	8b 45 08             	mov    0x8(%ebp),%eax
801041ac:	83 ec 0c             	sub    $0xc,%esp
801041af:	50                   	push   %eax
801041b0:	e8 4b 11 00 00       	call   80105300 <release>
801041b5:	83 c4 10             	add    $0x10,%esp
}
801041b8:	90                   	nop
801041b9:	90                   	nop
801041ba:	c9                   	leave  
801041bb:	c3                   	ret    

801041bc <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801041bc:	f3 0f 1e fb          	endbr32 
801041c0:	55                   	push   %ebp
801041c1:	89 e5                	mov    %esp,%ebp
801041c3:	53                   	push   %ebx
801041c4:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801041c7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ca:	83 ec 0c             	sub    $0xc,%esp
801041cd:	50                   	push   %eax
801041ce:	e8 bb 10 00 00       	call   8010528e <acquire>
801041d3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801041d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041dd:	e9 ad 00 00 00       	jmp    8010428f <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
801041e2:	8b 45 08             	mov    0x8(%ebp),%eax
801041e5:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041eb:	85 c0                	test   %eax,%eax
801041ed:	74 0c                	je     801041fb <pipewrite+0x3f>
801041ef:	e8 a2 02 00 00       	call   80104496 <myproc>
801041f4:	8b 40 28             	mov    0x28(%eax),%eax
801041f7:	85 c0                	test   %eax,%eax
801041f9:	74 19                	je     80104214 <pipewrite+0x58>
        release(&p->lock);
801041fb:	8b 45 08             	mov    0x8(%ebp),%eax
801041fe:	83 ec 0c             	sub    $0xc,%esp
80104201:	50                   	push   %eax
80104202:	e8 f9 10 00 00       	call   80105300 <release>
80104207:	83 c4 10             	add    $0x10,%esp
        return -1;
8010420a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010420f:	e9 a9 00 00 00       	jmp    801042bd <pipewrite+0x101>
      }
      wakeup(&p->nread);
80104214:	8b 45 08             	mov    0x8(%ebp),%eax
80104217:	05 34 02 00 00       	add    $0x234,%eax
8010421c:	83 ec 0c             	sub    $0xc,%esp
8010421f:	50                   	push   %eax
80104220:	e8 e9 0c 00 00       	call   80104f0e <wakeup>
80104225:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104228:	8b 45 08             	mov    0x8(%ebp),%eax
8010422b:	8b 55 08             	mov    0x8(%ebp),%edx
8010422e:	81 c2 38 02 00 00    	add    $0x238,%edx
80104234:	83 ec 08             	sub    $0x8,%esp
80104237:	50                   	push   %eax
80104238:	52                   	push   %edx
80104239:	e8 de 0b 00 00       	call   80104e1c <sleep>
8010423e:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104241:	8b 45 08             	mov    0x8(%ebp),%eax
80104244:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010424a:	8b 45 08             	mov    0x8(%ebp),%eax
8010424d:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104253:	05 00 02 00 00       	add    $0x200,%eax
80104258:	39 c2                	cmp    %eax,%edx
8010425a:	74 86                	je     801041e2 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010425c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010425f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104262:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104265:	8b 45 08             	mov    0x8(%ebp),%eax
80104268:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010426e:	8d 48 01             	lea    0x1(%eax),%ecx
80104271:	8b 55 08             	mov    0x8(%ebp),%edx
80104274:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010427a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010427f:	89 c1                	mov    %eax,%ecx
80104281:	0f b6 13             	movzbl (%ebx),%edx
80104284:	8b 45 08             	mov    0x8(%ebp),%eax
80104287:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010428b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010428f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104292:	3b 45 10             	cmp    0x10(%ebp),%eax
80104295:	7c aa                	jl     80104241 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104297:	8b 45 08             	mov    0x8(%ebp),%eax
8010429a:	05 34 02 00 00       	add    $0x234,%eax
8010429f:	83 ec 0c             	sub    $0xc,%esp
801042a2:	50                   	push   %eax
801042a3:	e8 66 0c 00 00       	call   80104f0e <wakeup>
801042a8:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801042ab:	8b 45 08             	mov    0x8(%ebp),%eax
801042ae:	83 ec 0c             	sub    $0xc,%esp
801042b1:	50                   	push   %eax
801042b2:	e8 49 10 00 00       	call   80105300 <release>
801042b7:	83 c4 10             	add    $0x10,%esp
  return n;
801042ba:	8b 45 10             	mov    0x10(%ebp),%eax
}
801042bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042c0:	c9                   	leave  
801042c1:	c3                   	ret    

801042c2 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801042c2:	f3 0f 1e fb          	endbr32 
801042c6:	55                   	push   %ebp
801042c7:	89 e5                	mov    %esp,%ebp
801042c9:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801042cc:	8b 45 08             	mov    0x8(%ebp),%eax
801042cf:	83 ec 0c             	sub    $0xc,%esp
801042d2:	50                   	push   %eax
801042d3:	e8 b6 0f 00 00       	call   8010528e <acquire>
801042d8:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042db:	eb 3e                	jmp    8010431b <piperead+0x59>
    if(myproc()->killed){
801042dd:	e8 b4 01 00 00       	call   80104496 <myproc>
801042e2:	8b 40 28             	mov    0x28(%eax),%eax
801042e5:	85 c0                	test   %eax,%eax
801042e7:	74 19                	je     80104302 <piperead+0x40>
      release(&p->lock);
801042e9:	8b 45 08             	mov    0x8(%ebp),%eax
801042ec:	83 ec 0c             	sub    $0xc,%esp
801042ef:	50                   	push   %eax
801042f0:	e8 0b 10 00 00       	call   80105300 <release>
801042f5:	83 c4 10             	add    $0x10,%esp
      return -1;
801042f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042fd:	e9 be 00 00 00       	jmp    801043c0 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104302:	8b 45 08             	mov    0x8(%ebp),%eax
80104305:	8b 55 08             	mov    0x8(%ebp),%edx
80104308:	81 c2 34 02 00 00    	add    $0x234,%edx
8010430e:	83 ec 08             	sub    $0x8,%esp
80104311:	50                   	push   %eax
80104312:	52                   	push   %edx
80104313:	e8 04 0b 00 00       	call   80104e1c <sleep>
80104318:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010431b:	8b 45 08             	mov    0x8(%ebp),%eax
8010431e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104324:	8b 45 08             	mov    0x8(%ebp),%eax
80104327:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010432d:	39 c2                	cmp    %eax,%edx
8010432f:	75 0d                	jne    8010433e <piperead+0x7c>
80104331:	8b 45 08             	mov    0x8(%ebp),%eax
80104334:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010433a:	85 c0                	test   %eax,%eax
8010433c:	75 9f                	jne    801042dd <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010433e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104345:	eb 48                	jmp    8010438f <piperead+0xcd>
    if(p->nread == p->nwrite)
80104347:	8b 45 08             	mov    0x8(%ebp),%eax
8010434a:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104350:	8b 45 08             	mov    0x8(%ebp),%eax
80104353:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104359:	39 c2                	cmp    %eax,%edx
8010435b:	74 3c                	je     80104399 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010435d:	8b 45 08             	mov    0x8(%ebp),%eax
80104360:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104366:	8d 48 01             	lea    0x1(%eax),%ecx
80104369:	8b 55 08             	mov    0x8(%ebp),%edx
8010436c:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104372:	25 ff 01 00 00       	and    $0x1ff,%eax
80104377:	89 c1                	mov    %eax,%ecx
80104379:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010437c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010437f:	01 c2                	add    %eax,%edx
80104381:	8b 45 08             	mov    0x8(%ebp),%eax
80104384:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80104389:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010438b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010438f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104392:	3b 45 10             	cmp    0x10(%ebp),%eax
80104395:	7c b0                	jl     80104347 <piperead+0x85>
80104397:	eb 01                	jmp    8010439a <piperead+0xd8>
      break;
80104399:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010439a:	8b 45 08             	mov    0x8(%ebp),%eax
8010439d:	05 38 02 00 00       	add    $0x238,%eax
801043a2:	83 ec 0c             	sub    $0xc,%esp
801043a5:	50                   	push   %eax
801043a6:	e8 63 0b 00 00       	call   80104f0e <wakeup>
801043ab:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043ae:	8b 45 08             	mov    0x8(%ebp),%eax
801043b1:	83 ec 0c             	sub    $0xc,%esp
801043b4:	50                   	push   %eax
801043b5:	e8 46 0f 00 00       	call   80105300 <release>
801043ba:	83 c4 10             	add    $0x10,%esp
  return i;
801043bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043c0:	c9                   	leave  
801043c1:	c3                   	ret    

801043c2 <readeflags>:
{
801043c2:	55                   	push   %ebp
801043c3:	89 e5                	mov    %esp,%ebp
801043c5:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801043c8:	9c                   	pushf  
801043c9:	58                   	pop    %eax
801043ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801043cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043d0:	c9                   	leave  
801043d1:	c3                   	ret    

801043d2 <sti>:
{
801043d2:	55                   	push   %ebp
801043d3:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801043d5:	fb                   	sti    
}
801043d6:	90                   	nop
801043d7:	5d                   	pop    %ebp
801043d8:	c3                   	ret    

801043d9 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801043d9:	f3 0f 1e fb          	endbr32 
801043dd:	55                   	push   %ebp
801043de:	89 e5                	mov    %esp,%ebp
801043e0:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801043e3:	83 ec 08             	sub    $0x8,%esp
801043e6:	68 c0 93 10 80       	push   $0x801093c0
801043eb:	68 c0 4d 11 80       	push   $0x80114dc0
801043f0:	e8 73 0e 00 00       	call   80105268 <initlock>
801043f5:	83 c4 10             	add    $0x10,%esp
}
801043f8:	90                   	nop
801043f9:	c9                   	leave  
801043fa:	c3                   	ret    

801043fb <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801043fb:	f3 0f 1e fb          	endbr32 
801043ff:	55                   	push   %ebp
80104400:	89 e5                	mov    %esp,%ebp
80104402:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104405:	e8 10 00 00 00       	call   8010441a <mycpu>
8010440a:	2d 20 48 11 80       	sub    $0x80114820,%eax
8010440f:	c1 f8 04             	sar    $0x4,%eax
80104412:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104418:	c9                   	leave  
80104419:	c3                   	ret    

8010441a <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
8010441a:	f3 0f 1e fb          	endbr32 
8010441e:	55                   	push   %ebp
8010441f:	89 e5                	mov    %esp,%ebp
80104421:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104424:	e8 99 ff ff ff       	call   801043c2 <readeflags>
80104429:	25 00 02 00 00       	and    $0x200,%eax
8010442e:	85 c0                	test   %eax,%eax
80104430:	74 0d                	je     8010443f <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80104432:	83 ec 0c             	sub    $0xc,%esp
80104435:	68 c8 93 10 80       	push   $0x801093c8
8010443a:	e8 c9 c1 ff ff       	call   80100608 <panic>
  
  apicid = lapicid();
8010443f:	e8 21 ed ff ff       	call   80103165 <lapicid>
80104444:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104447:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010444e:	eb 2d                	jmp    8010447d <mycpu+0x63>
    if (cpus[i].apicid == apicid)
80104450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104453:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104459:	05 20 48 11 80       	add    $0x80114820,%eax
8010445e:	0f b6 00             	movzbl (%eax),%eax
80104461:	0f b6 c0             	movzbl %al,%eax
80104464:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104467:	75 10                	jne    80104479 <mycpu+0x5f>
      return &cpus[i];
80104469:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446c:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104472:	05 20 48 11 80       	add    $0x80114820,%eax
80104477:	eb 1b                	jmp    80104494 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80104479:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010447d:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80104482:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104485:	7c c9                	jl     80104450 <mycpu+0x36>
  }
  panic("unknown apicid\n");
80104487:	83 ec 0c             	sub    $0xc,%esp
8010448a:	68 ee 93 10 80       	push   $0x801093ee
8010448f:	e8 74 c1 ff ff       	call   80100608 <panic>
}
80104494:	c9                   	leave  
80104495:	c3                   	ret    

80104496 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104496:	f3 0f 1e fb          	endbr32 
8010449a:	55                   	push   %ebp
8010449b:	89 e5                	mov    %esp,%ebp
8010449d:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801044a0:	e8 75 0f 00 00       	call   8010541a <pushcli>
  c = mycpu();
801044a5:	e8 70 ff ff ff       	call   8010441a <mycpu>
801044aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801044ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b0:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801044b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801044b9:	e8 ad 0f 00 00       	call   8010546b <popcli>
  return p;
801044be:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801044c1:	c9                   	leave  
801044c2:	c3                   	ret    

801044c3 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801044c3:	f3 0f 1e fb          	endbr32 
801044c7:	55                   	push   %ebp
801044c8:	89 e5                	mov    %esp,%ebp
801044ca:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044cd:	83 ec 0c             	sub    $0xc,%esp
801044d0:	68 c0 4d 11 80       	push   $0x80114dc0
801044d5:	e8 b4 0d 00 00       	call   8010528e <acquire>
801044da:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044dd:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
801044e4:	eb 11                	jmp    801044f7 <allocproc+0x34>
    if(p->state == UNUSED)
801044e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e9:	8b 40 0c             	mov    0xc(%eax),%eax
801044ec:	85 c0                	test   %eax,%eax
801044ee:	74 2a                	je     8010451a <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044f0:	81 45 f4 cc 00 00 00 	addl   $0xcc,-0xc(%ebp)
801044f7:	81 7d f4 f4 80 11 80 	cmpl   $0x801180f4,-0xc(%ebp)
801044fe:	72 e6                	jb     801044e6 <allocproc+0x23>
      goto found;

  release(&ptable.lock);
80104500:	83 ec 0c             	sub    $0xc,%esp
80104503:	68 c0 4d 11 80       	push   $0x80114dc0
80104508:	e8 f3 0d 00 00       	call   80105300 <release>
8010450d:	83 c4 10             	add    $0x10,%esp
  return 0;
80104510:	b8 00 00 00 00       	mov    $0x0,%eax
80104515:	e9 e0 00 00 00       	jmp    801045fa <allocproc+0x137>
      goto found;
8010451a:	90                   	nop
8010451b:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
8010451f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104522:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104529:	a1 00 c0 10 80       	mov    0x8010c000,%eax
8010452e:	8d 50 01             	lea    0x1(%eax),%edx
80104531:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
80104537:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010453a:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
8010453d:	83 ec 0c             	sub    $0xc,%esp
80104540:	68 c0 4d 11 80       	push   $0x80114dc0
80104545:	e8 b6 0d 00 00       	call   80105300 <release>
8010454a:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010454d:	e8 a6 e8 ff ff       	call   80102df8 <kalloc>
80104552:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104555:	89 42 08             	mov    %eax,0x8(%edx)
80104558:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455b:	8b 40 08             	mov    0x8(%eax),%eax
8010455e:	85 c0                	test   %eax,%eax
80104560:	75 14                	jne    80104576 <allocproc+0xb3>
    p->state = UNUSED;
80104562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104565:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010456c:	b8 00 00 00 00       	mov    $0x0,%eax
80104571:	e9 84 00 00 00       	jmp    801045fa <allocproc+0x137>
  }
  sp = p->kstack + KSTACKSIZE;
80104576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104579:	8b 40 08             	mov    0x8(%eax),%eax
8010457c:	05 00 10 00 00       	add    $0x1000,%eax
80104581:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104584:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010458e:	89 50 1c             	mov    %edx,0x1c(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104591:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104595:	ba b1 6a 10 80       	mov    $0x80106ab1,%edx
8010459a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010459d:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010459f:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801045a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045a9:	89 50 20             	mov    %edx,0x20(%eax)
  memset(p->context, 0, sizeof *p->context);
801045ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045af:	8b 40 20             	mov    0x20(%eax),%eax
801045b2:	83 ec 04             	sub    $0x4,%esp
801045b5:	6a 14                	push   $0x14
801045b7:	6a 00                	push   $0x0
801045b9:	50                   	push   %eax
801045ba:	e8 6e 0f 00 00       	call   8010552d <memset>
801045bf:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801045c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c5:	8b 40 20             	mov    0x20(%eax),%eax
801045c8:	ba d2 4d 10 80       	mov    $0x80104dd2,%edx
801045cd:	89 50 10             	mov    %edx,0x10(%eax)
  p->queue_size = 0;
801045d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d3:	c7 80 c0 00 00 00 00 	movl   $0x0,0xc0(%eax)
801045da:	00 00 00 
  p->hand = 0;
801045dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e0:	c7 80 c8 00 00 00 00 	movl   $0x0,0xc8(%eax)
801045e7:	00 00 00 
  p->head = 0;
801045ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ed:	c7 80 c4 00 00 00 00 	movl   $0x0,0xc4(%eax)
801045f4:	00 00 00 
  return p;
801045f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045fa:	c9                   	leave  
801045fb:	c3                   	ret    

801045fc <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045fc:	f3 0f 1e fb          	endbr32 
80104600:	55                   	push   %ebp
80104601:	89 e5                	mov    %esp,%ebp
80104603:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104606:	e8 b8 fe ff ff       	call   801044c3 <allocproc>
8010460b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010460e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104611:	a3 40 c6 10 80       	mov    %eax,0x8010c640
  if((p->pgdir = setupkvm()) == 0)
80104616:	e8 6b 3d 00 00       	call   80108386 <setupkvm>
8010461b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010461e:	89 42 04             	mov    %eax,0x4(%edx)
80104621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104624:	8b 40 04             	mov    0x4(%eax),%eax
80104627:	85 c0                	test   %eax,%eax
80104629:	75 0d                	jne    80104638 <userinit+0x3c>
    panic("userinit: out of memory?");
8010462b:	83 ec 0c             	sub    $0xc,%esp
8010462e:	68 fe 93 10 80       	push   $0x801093fe
80104633:	e8 d0 bf ff ff       	call   80100608 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104638:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010463d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104640:	8b 40 04             	mov    0x4(%eax),%eax
80104643:	83 ec 04             	sub    $0x4,%esp
80104646:	52                   	push   %edx
80104647:	68 e0 c4 10 80       	push   $0x8010c4e0
8010464c:	50                   	push   %eax
8010464d:	e8 ad 3f 00 00       	call   801085ff <inituvm>
80104652:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104658:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010465e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104661:	8b 40 1c             	mov    0x1c(%eax),%eax
80104664:	83 ec 04             	sub    $0x4,%esp
80104667:	6a 4c                	push   $0x4c
80104669:	6a 00                	push   $0x0
8010466b:	50                   	push   %eax
8010466c:	e8 bc 0e 00 00       	call   8010552d <memset>
80104671:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104677:	8b 40 1c             	mov    0x1c(%eax),%eax
8010467a:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104683:	8b 40 1c             	mov    0x1c(%eax),%eax
80104686:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010468c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468f:	8b 50 1c             	mov    0x1c(%eax),%edx
80104692:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104695:	8b 40 1c             	mov    0x1c(%eax),%eax
80104698:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010469c:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801046a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a3:	8b 50 1c             	mov    0x1c(%eax),%edx
801046a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a9:	8b 40 1c             	mov    0x1c(%eax),%eax
801046ac:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046b0:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801046b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b7:	8b 40 1c             	mov    0x1c(%eax),%eax
801046ba:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801046c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c4:	8b 40 1c             	mov    0x1c(%eax),%eax
801046c7:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801046ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d1:	8b 40 1c             	mov    0x1c(%eax),%eax
801046d4:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801046db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046de:	83 c0 70             	add    $0x70,%eax
801046e1:	83 ec 04             	sub    $0x4,%esp
801046e4:	6a 10                	push   $0x10
801046e6:	68 17 94 10 80       	push   $0x80109417
801046eb:	50                   	push   %eax
801046ec:	e8 57 10 00 00       	call   80105748 <safestrcpy>
801046f1:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801046f4:	83 ec 0c             	sub    $0xc,%esp
801046f7:	68 20 94 10 80       	push   $0x80109420
801046fc:	e8 72 df ff ff       	call   80102673 <namei>
80104701:	83 c4 10             	add    $0x10,%esp
80104704:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104707:	89 42 6c             	mov    %eax,0x6c(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010470a:	83 ec 0c             	sub    $0xc,%esp
8010470d:	68 c0 4d 11 80       	push   $0x80114dc0
80104712:	e8 77 0b 00 00       	call   8010528e <acquire>
80104717:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
8010471a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010471d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104724:	83 ec 0c             	sub    $0xc,%esp
80104727:	68 c0 4d 11 80       	push   $0x80114dc0
8010472c:	e8 cf 0b 00 00       	call   80105300 <release>
80104731:	83 c4 10             	add    $0x10,%esp
}
80104734:	90                   	nop
80104735:	c9                   	leave  
80104736:	c3                   	ret    

80104737 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104737:	f3 0f 1e fb          	endbr32 
8010473b:	55                   	push   %ebp
8010473c:	89 e5                	mov    %esp,%ebp
8010473e:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80104741:	e8 50 fd ff ff       	call   80104496 <myproc>
80104746:	89 45 ec             	mov    %eax,-0x14(%ebp)

  sz = curproc->sz;
80104749:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010474c:	8b 00                	mov    (%eax),%eax
8010474e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104751:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104755:	7e 57                	jle    801047ae <growproc+0x77>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104757:	8b 55 08             	mov    0x8(%ebp),%edx
8010475a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475d:	01 c2                	add    %eax,%edx
8010475f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104762:	8b 40 04             	mov    0x4(%eax),%eax
80104765:	83 ec 04             	sub    $0x4,%esp
80104768:	52                   	push   %edx
80104769:	ff 75 f4             	pushl  -0xc(%ebp)
8010476c:	50                   	push   %eax
8010476d:	e8 d2 3f 00 00       	call   80108744 <allocuvm>
80104772:	83 c4 10             	add    $0x10,%esp
80104775:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104778:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010477c:	75 0a                	jne    80104788 <growproc+0x51>
      return -1;
8010477e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104783:	e9 ba 00 00 00       	jmp    80104842 <growproc+0x10b>
    mencrypt((void*)PGROUNDDOWN((int)curproc->sz), (PGROUNDUP(n))/PGSIZE);
80104788:	8b 45 08             	mov    0x8(%ebp),%eax
8010478b:	05 ff 0f 00 00       	add    $0xfff,%eax
80104790:	c1 f8 0c             	sar    $0xc,%eax
80104793:	89 c2                	mov    %eax,%edx
80104795:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104798:	8b 00                	mov    (%eax),%eax
8010479a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010479f:	83 ec 08             	sub    $0x8,%esp
801047a2:	52                   	push   %edx
801047a3:	50                   	push   %eax
801047a4:	e8 39 45 00 00       	call   80108ce2 <mencrypt>
801047a9:	83 c4 10             	add    $0x10,%esp
801047ac:	eb 79                	jmp    80104827 <growproc+0xf0>
  } else if(n < 0){
801047ae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047b2:	79 73                	jns    80104827 <growproc+0xf0>
    for(int i = 0; i - 1< - n / PGSIZE ; i--)  
801047b4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047bb:	eb 24                	jmp    801047e1 <growproc+0xaa>
      removepage((char*)PGROUNDDOWN((int)curproc->sz + i*PGSIZE));
801047bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047c0:	8b 00                	mov    (%eax),%eax
801047c2:	89 c2                	mov    %eax,%edx
801047c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047c7:	c1 e0 0c             	shl    $0xc,%eax
801047ca:	01 d0                	add    %edx,%eax
801047cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801047d1:	83 ec 0c             	sub    $0xc,%esp
801047d4:	50                   	push   %eax
801047d5:	e8 41 35 00 00       	call   80107d1b <removepage>
801047da:	83 c4 10             	add    $0x10,%esp
    for(int i = 0; i - 1< - n / PGSIZE ; i--)  
801047dd:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801047e1:	8b 45 08             	mov    0x8(%ebp),%eax
801047e4:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801047ea:	85 c0                	test   %eax,%eax
801047ec:	0f 48 c2             	cmovs  %edx,%eax
801047ef:	c1 f8 0c             	sar    $0xc,%eax
801047f2:	f7 d8                	neg    %eax
801047f4:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801047f7:	7e c4                	jle    801047bd <growproc+0x86>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801047f9:	8b 55 08             	mov    0x8(%ebp),%edx
801047fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ff:	01 c2                	add    %eax,%edx
80104801:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104804:	8b 40 04             	mov    0x4(%eax),%eax
80104807:	83 ec 04             	sub    $0x4,%esp
8010480a:	52                   	push   %edx
8010480b:	ff 75 f4             	pushl  -0xc(%ebp)
8010480e:	50                   	push   %eax
8010480f:	e8 39 40 00 00       	call   8010884d <deallocuvm>
80104814:	83 c4 10             	add    $0x10,%esp
80104817:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010481a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010481e:	75 07                	jne    80104827 <growproc+0xf0>
      return -1;
80104820:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104825:	eb 1b                	jmp    80104842 <growproc+0x10b>
    //  break;
  //}
    //walk through the page table and read the entries
    //Those entries contain the physical page number + flags

  curproc->sz = sz;
80104827:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010482a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010482d:	89 10                	mov    %edx,(%eax)

  switchuvm(curproc);
8010482f:	83 ec 0c             	sub    $0xc,%esp
80104832:	ff 75 ec             	pushl  -0x14(%ebp)
80104835:	e8 22 3c 00 00       	call   8010845c <switchuvm>
8010483a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010483d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104842:	c9                   	leave  
80104843:	c3                   	ret    

80104844 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104844:	f3 0f 1e fb          	endbr32 
80104848:	55                   	push   %ebp
80104849:	89 e5                	mov    %esp,%ebp
8010484b:	57                   	push   %edi
8010484c:	56                   	push   %esi
8010484d:	53                   	push   %ebx
8010484e:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104851:	e8 40 fc ff ff       	call   80104496 <myproc>
80104856:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104859:	e8 65 fc ff ff       	call   801044c3 <allocproc>
8010485e:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104861:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104865:	75 0a                	jne    80104871 <fork+0x2d>
    return -1;
80104867:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010486c:	e9 51 01 00 00       	jmp    801049c2 <fork+0x17e>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104871:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104874:	8b 10                	mov    (%eax),%edx
80104876:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104879:	8b 40 04             	mov    0x4(%eax),%eax
8010487c:	83 ec 08             	sub    $0x8,%esp
8010487f:	52                   	push   %edx
80104880:	50                   	push   %eax
80104881:	e8 8f 41 00 00       	call   80108a15 <copyuvm>
80104886:	83 c4 10             	add    $0x10,%esp
80104889:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010488c:	89 42 04             	mov    %eax,0x4(%edx)
8010488f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104892:	8b 40 04             	mov    0x4(%eax),%eax
80104895:	85 c0                	test   %eax,%eax
80104897:	75 30                	jne    801048c9 <fork+0x85>
    kfree(np->kstack);
80104899:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010489c:	8b 40 08             	mov    0x8(%eax),%eax
8010489f:	83 ec 0c             	sub    $0xc,%esp
801048a2:	50                   	push   %eax
801048a3:	e8 b2 e4 ff ff       	call   80102d5a <kfree>
801048a8:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801048ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048ae:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801048b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048b8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801048bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048c4:	e9 f9 00 00 00       	jmp    801049c2 <fork+0x17e>
  }
  curproc->child = np;
801048c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
801048cf:	89 50 18             	mov    %edx,0x18(%eax)
  np->sz = curproc->sz;
801048d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d5:	8b 10                	mov    (%eax),%edx
801048d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048da:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801048dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048df:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048e2:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801048e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e8:	8b 48 1c             	mov    0x1c(%eax),%ecx
801048eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048ee:	8b 40 1c             	mov    0x1c(%eax),%eax
801048f1:	89 c2                	mov    %eax,%edx
801048f3:	89 cb                	mov    %ecx,%ebx
801048f5:	b8 13 00 00 00       	mov    $0x13,%eax
801048fa:	89 d7                	mov    %edx,%edi
801048fc:	89 de                	mov    %ebx,%esi
801048fe:	89 c1                	mov    %eax,%ecx
80104900:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104902:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104905:	8b 40 1c             	mov    0x1c(%eax),%eax
80104908:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010490f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104916:	eb 3b                	jmp    80104953 <fork+0x10f>
    if(curproc->ofile[i])
80104918:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010491b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010491e:	83 c2 08             	add    $0x8,%edx
80104921:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104925:	85 c0                	test   %eax,%eax
80104927:	74 26                	je     8010494f <fork+0x10b>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104929:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010492c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010492f:	83 c2 08             	add    $0x8,%edx
80104932:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104936:	83 ec 0c             	sub    $0xc,%esp
80104939:	50                   	push   %eax
8010493a:	e8 f4 c7 ff ff       	call   80101133 <filedup>
8010493f:	83 c4 10             	add    $0x10,%esp
80104942:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104945:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104948:	83 c1 08             	add    $0x8,%ecx
8010494b:	89 44 8a 0c          	mov    %eax,0xc(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
8010494f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104953:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104957:	7e bf                	jle    80104918 <fork+0xd4>
  np->cwd = idup(curproc->cwd);
80104959:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010495c:	8b 40 6c             	mov    0x6c(%eax),%eax
8010495f:	83 ec 0c             	sub    $0xc,%esp
80104962:	50                   	push   %eax
80104963:	e8 62 d1 ff ff       	call   80101aca <idup>
80104968:	83 c4 10             	add    $0x10,%esp
8010496b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010496e:	89 42 6c             	mov    %eax,0x6c(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104971:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104974:	8d 50 70             	lea    0x70(%eax),%edx
80104977:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010497a:	83 c0 70             	add    $0x70,%eax
8010497d:	83 ec 04             	sub    $0x4,%esp
80104980:	6a 10                	push   $0x10
80104982:	52                   	push   %edx
80104983:	50                   	push   %eax
80104984:	e8 bf 0d 00 00       	call   80105748 <safestrcpy>
80104989:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010498c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010498f:	8b 40 10             	mov    0x10(%eax),%eax
80104992:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104995:	83 ec 0c             	sub    $0xc,%esp
80104998:	68 c0 4d 11 80       	push   $0x80114dc0
8010499d:	e8 ec 08 00 00       	call   8010528e <acquire>
801049a2:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801049a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049a8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801049af:	83 ec 0c             	sub    $0xc,%esp
801049b2:	68 c0 4d 11 80       	push   $0x80114dc0
801049b7:	e8 44 09 00 00       	call   80105300 <release>
801049bc:	83 c4 10             	add    $0x10,%esp

  return pid;
801049bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801049c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801049c5:	5b                   	pop    %ebx
801049c6:	5e                   	pop    %esi
801049c7:	5f                   	pop    %edi
801049c8:	5d                   	pop    %ebp
801049c9:	c3                   	ret    

801049ca <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801049ca:	f3 0f 1e fb          	endbr32 
801049ce:	55                   	push   %ebp
801049cf:	89 e5                	mov    %esp,%ebp
801049d1:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801049d4:	e8 bd fa ff ff       	call   80104496 <myproc>
801049d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801049dc:	a1 40 c6 10 80       	mov    0x8010c640,%eax
801049e1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801049e4:	75 0d                	jne    801049f3 <exit+0x29>
    panic("init exiting");
801049e6:	83 ec 0c             	sub    $0xc,%esp
801049e9:	68 22 94 10 80       	push   $0x80109422
801049ee:	e8 15 bc ff ff       	call   80100608 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801049f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801049fa:	eb 3f                	jmp    80104a3b <exit+0x71>
    if(curproc->ofile[fd]){
801049fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a02:	83 c2 08             	add    $0x8,%edx
80104a05:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104a09:	85 c0                	test   %eax,%eax
80104a0b:	74 2a                	je     80104a37 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104a0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a10:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a13:	83 c2 08             	add    $0x8,%edx
80104a16:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104a1a:	83 ec 0c             	sub    $0xc,%esp
80104a1d:	50                   	push   %eax
80104a1e:	e8 65 c7 ff ff       	call   80101188 <fileclose>
80104a23:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104a26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a29:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a2c:	83 c2 08             	add    $0x8,%edx
80104a2f:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80104a36:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104a37:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a3b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104a3f:	7e bb                	jle    801049fc <exit+0x32>
    }
  }

  begin_op();
80104a41:	e8 91 ec ff ff       	call   801036d7 <begin_op>
  iput(curproc->cwd);
80104a46:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a49:	8b 40 6c             	mov    0x6c(%eax),%eax
80104a4c:	83 ec 0c             	sub    $0xc,%esp
80104a4f:	50                   	push   %eax
80104a50:	e8 1c d2 ff ff       	call   80101c71 <iput>
80104a55:	83 c4 10             	add    $0x10,%esp
  end_op();
80104a58:	e8 0a ed ff ff       	call   80103767 <end_op>
  curproc->cwd = 0;
80104a5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a60:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)

  acquire(&ptable.lock);
80104a67:	83 ec 0c             	sub    $0xc,%esp
80104a6a:	68 c0 4d 11 80       	push   $0x80114dc0
80104a6f:	e8 1a 08 00 00       	call   8010528e <acquire>
80104a74:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104a77:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a7a:	8b 40 14             	mov    0x14(%eax),%eax
80104a7d:	83 ec 0c             	sub    $0xc,%esp
80104a80:	50                   	push   %eax
80104a81:	e8 41 04 00 00       	call   80104ec7 <wakeup1>
80104a86:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a89:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104a90:	eb 3a                	jmp    80104acc <exit+0x102>
    if(p->parent == curproc){
80104a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a95:	8b 40 14             	mov    0x14(%eax),%eax
80104a98:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a9b:	75 28                	jne    80104ac5 <exit+0xfb>
      p->parent = initproc;
80104a9d:	8b 15 40 c6 10 80    	mov    0x8010c640,%edx
80104aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa6:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aac:	8b 40 0c             	mov    0xc(%eax),%eax
80104aaf:	83 f8 05             	cmp    $0x5,%eax
80104ab2:	75 11                	jne    80104ac5 <exit+0xfb>
        wakeup1(initproc);
80104ab4:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104ab9:	83 ec 0c             	sub    $0xc,%esp
80104abc:	50                   	push   %eax
80104abd:	e8 05 04 00 00       	call   80104ec7 <wakeup1>
80104ac2:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ac5:	81 45 f4 cc 00 00 00 	addl   $0xcc,-0xc(%ebp)
80104acc:	81 7d f4 f4 80 11 80 	cmpl   $0x801180f4,-0xc(%ebp)
80104ad3:	72 bd                	jb     80104a92 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104ad5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ad8:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104adf:	e8 f3 01 00 00       	call   80104cd7 <sched>
  panic("zombie exit");
80104ae4:	83 ec 0c             	sub    $0xc,%esp
80104ae7:	68 2f 94 10 80       	push   $0x8010942f
80104aec:	e8 17 bb ff ff       	call   80100608 <panic>

80104af1 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104af1:	f3 0f 1e fb          	endbr32 
80104af5:	55                   	push   %ebp
80104af6:	89 e5                	mov    %esp,%ebp
80104af8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104afb:	e8 96 f9 ff ff       	call   80104496 <myproc>
80104b00:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104b03:	83 ec 0c             	sub    $0xc,%esp
80104b06:	68 c0 4d 11 80       	push   $0x80114dc0
80104b0b:	e8 7e 07 00 00       	call   8010528e <acquire>
80104b10:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104b13:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b1a:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104b21:	e9 a4 00 00 00       	jmp    80104bca <wait+0xd9>
      if(p->parent != curproc)
80104b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b29:	8b 40 14             	mov    0x14(%eax),%eax
80104b2c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104b2f:	0f 85 8d 00 00 00    	jne    80104bc2 <wait+0xd1>
        continue;
      havekids = 1;
80104b35:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b3f:	8b 40 0c             	mov    0xc(%eax),%eax
80104b42:	83 f8 05             	cmp    $0x5,%eax
80104b45:	75 7c                	jne    80104bc3 <wait+0xd2>
        // Found one.
        pid = p->pid;
80104b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b4a:	8b 40 10             	mov    0x10(%eax),%eax
80104b4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b53:	8b 40 08             	mov    0x8(%eax),%eax
80104b56:	83 ec 0c             	sub    $0xc,%esp
80104b59:	50                   	push   %eax
80104b5a:	e8 fb e1 ff ff       	call   80102d5a <kfree>
80104b5f:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b65:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b6f:	8b 40 04             	mov    0x4(%eax),%eax
80104b72:	83 ec 0c             	sub    $0xc,%esp
80104b75:	50                   	push   %eax
80104b76:	e8 b8 3d 00 00       	call   80108933 <freevm>
80104b7b:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b81:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b8b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b95:	c6 40 70 00          	movb   $0x0,0x70(%eax)
        p->killed = 0;
80104b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9c:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)
        p->state = UNUSED;
80104ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104bad:	83 ec 0c             	sub    $0xc,%esp
80104bb0:	68 c0 4d 11 80       	push   $0x80114dc0
80104bb5:	e8 46 07 00 00       	call   80105300 <release>
80104bba:	83 c4 10             	add    $0x10,%esp
        return pid;
80104bbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104bc0:	eb 54                	jmp    80104c16 <wait+0x125>
        continue;
80104bc2:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bc3:	81 45 f4 cc 00 00 00 	addl   $0xcc,-0xc(%ebp)
80104bca:	81 7d f4 f4 80 11 80 	cmpl   $0x801180f4,-0xc(%ebp)
80104bd1:	0f 82 4f ff ff ff    	jb     80104b26 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104bd7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104bdb:	74 0a                	je     80104be7 <wait+0xf6>
80104bdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104be0:	8b 40 28             	mov    0x28(%eax),%eax
80104be3:	85 c0                	test   %eax,%eax
80104be5:	74 17                	je     80104bfe <wait+0x10d>
      release(&ptable.lock);
80104be7:	83 ec 0c             	sub    $0xc,%esp
80104bea:	68 c0 4d 11 80       	push   $0x80114dc0
80104bef:	e8 0c 07 00 00       	call   80105300 <release>
80104bf4:	83 c4 10             	add    $0x10,%esp
      return -1;
80104bf7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bfc:	eb 18                	jmp    80104c16 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104bfe:	83 ec 08             	sub    $0x8,%esp
80104c01:	68 c0 4d 11 80       	push   $0x80114dc0
80104c06:	ff 75 ec             	pushl  -0x14(%ebp)
80104c09:	e8 0e 02 00 00       	call   80104e1c <sleep>
80104c0e:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104c11:	e9 fd fe ff ff       	jmp    80104b13 <wait+0x22>
  }
}
80104c16:	c9                   	leave  
80104c17:	c3                   	ret    

80104c18 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c18:	f3 0f 1e fb          	endbr32 
80104c1c:	55                   	push   %ebp
80104c1d:	89 e5                	mov    %esp,%ebp
80104c1f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104c22:	e8 f3 f7 ff ff       	call   8010441a <mycpu>
80104c27:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c2d:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c34:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c37:	e8 96 f7 ff ff       	call   801043d2 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c3c:	83 ec 0c             	sub    $0xc,%esp
80104c3f:	68 c0 4d 11 80       	push   $0x80114dc0
80104c44:	e8 45 06 00 00       	call   8010528e <acquire>
80104c49:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c4c:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104c53:	eb 64                	jmp    80104cb9 <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c58:	8b 40 0c             	mov    0xc(%eax),%eax
80104c5b:	83 f8 03             	cmp    $0x3,%eax
80104c5e:	75 51                	jne    80104cb1 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c63:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c66:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104c6c:	83 ec 0c             	sub    $0xc,%esp
80104c6f:	ff 75 f4             	pushl  -0xc(%ebp)
80104c72:	e8 e5 37 00 00       	call   8010845c <switchuvm>
80104c77:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7d:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c87:	8b 40 20             	mov    0x20(%eax),%eax
80104c8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104c8d:	83 c2 04             	add    $0x4,%edx
80104c90:	83 ec 08             	sub    $0x8,%esp
80104c93:	50                   	push   %eax
80104c94:	52                   	push   %edx
80104c95:	e8 27 0b 00 00       	call   801057c1 <swtch>
80104c9a:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104c9d:	e8 9d 37 00 00       	call   8010843f <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ca5:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104cac:	00 00 00 
80104caf:	eb 01                	jmp    80104cb2 <scheduler+0x9a>
        continue;
80104cb1:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cb2:	81 45 f4 cc 00 00 00 	addl   $0xcc,-0xc(%ebp)
80104cb9:	81 7d f4 f4 80 11 80 	cmpl   $0x801180f4,-0xc(%ebp)
80104cc0:	72 93                	jb     80104c55 <scheduler+0x3d>
    }
    release(&ptable.lock);
80104cc2:	83 ec 0c             	sub    $0xc,%esp
80104cc5:	68 c0 4d 11 80       	push   $0x80114dc0
80104cca:	e8 31 06 00 00       	call   80105300 <release>
80104ccf:	83 c4 10             	add    $0x10,%esp
    sti();
80104cd2:	e9 60 ff ff ff       	jmp    80104c37 <scheduler+0x1f>

80104cd7 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104cd7:	f3 0f 1e fb          	endbr32 
80104cdb:	55                   	push   %ebp
80104cdc:	89 e5                	mov    %esp,%ebp
80104cde:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104ce1:	e8 b0 f7 ff ff       	call   80104496 <myproc>
80104ce6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104ce9:	83 ec 0c             	sub    $0xc,%esp
80104cec:	68 c0 4d 11 80       	push   $0x80114dc0
80104cf1:	e8 df 06 00 00       	call   801053d5 <holding>
80104cf6:	83 c4 10             	add    $0x10,%esp
80104cf9:	85 c0                	test   %eax,%eax
80104cfb:	75 0d                	jne    80104d0a <sched+0x33>
    panic("sched ptable.lock");
80104cfd:	83 ec 0c             	sub    $0xc,%esp
80104d00:	68 3b 94 10 80       	push   $0x8010943b
80104d05:	e8 fe b8 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli != 1)
80104d0a:	e8 0b f7 ff ff       	call   8010441a <mycpu>
80104d0f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d15:	83 f8 01             	cmp    $0x1,%eax
80104d18:	74 0d                	je     80104d27 <sched+0x50>
    panic("sched locks");
80104d1a:	83 ec 0c             	sub    $0xc,%esp
80104d1d:	68 4d 94 10 80       	push   $0x8010944d
80104d22:	e8 e1 b8 ff ff       	call   80100608 <panic>
  if(p->state == RUNNING)
80104d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2a:	8b 40 0c             	mov    0xc(%eax),%eax
80104d2d:	83 f8 04             	cmp    $0x4,%eax
80104d30:	75 0d                	jne    80104d3f <sched+0x68>
    panic("sched running");
80104d32:	83 ec 0c             	sub    $0xc,%esp
80104d35:	68 59 94 10 80       	push   $0x80109459
80104d3a:	e8 c9 b8 ff ff       	call   80100608 <panic>
  if(readeflags()&FL_IF)
80104d3f:	e8 7e f6 ff ff       	call   801043c2 <readeflags>
80104d44:	25 00 02 00 00       	and    $0x200,%eax
80104d49:	85 c0                	test   %eax,%eax
80104d4b:	74 0d                	je     80104d5a <sched+0x83>
    panic("sched interruptible");
80104d4d:	83 ec 0c             	sub    $0xc,%esp
80104d50:	68 67 94 10 80       	push   $0x80109467
80104d55:	e8 ae b8 ff ff       	call   80100608 <panic>
  intena = mycpu()->intena;
80104d5a:	e8 bb f6 ff ff       	call   8010441a <mycpu>
80104d5f:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104d65:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104d68:	e8 ad f6 ff ff       	call   8010441a <mycpu>
80104d6d:	8b 40 04             	mov    0x4(%eax),%eax
80104d70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d73:	83 c2 20             	add    $0x20,%edx
80104d76:	83 ec 08             	sub    $0x8,%esp
80104d79:	50                   	push   %eax
80104d7a:	52                   	push   %edx
80104d7b:	e8 41 0a 00 00       	call   801057c1 <swtch>
80104d80:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104d83:	e8 92 f6 ff ff       	call   8010441a <mycpu>
80104d88:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d8b:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104d91:	90                   	nop
80104d92:	c9                   	leave  
80104d93:	c3                   	ret    

80104d94 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d94:	f3 0f 1e fb          	endbr32 
80104d98:	55                   	push   %ebp
80104d99:	89 e5                	mov    %esp,%ebp
80104d9b:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104d9e:	83 ec 0c             	sub    $0xc,%esp
80104da1:	68 c0 4d 11 80       	push   $0x80114dc0
80104da6:	e8 e3 04 00 00       	call   8010528e <acquire>
80104dab:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104dae:	e8 e3 f6 ff ff       	call   80104496 <myproc>
80104db3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104dba:	e8 18 ff ff ff       	call   80104cd7 <sched>
  release(&ptable.lock);
80104dbf:	83 ec 0c             	sub    $0xc,%esp
80104dc2:	68 c0 4d 11 80       	push   $0x80114dc0
80104dc7:	e8 34 05 00 00       	call   80105300 <release>
80104dcc:	83 c4 10             	add    $0x10,%esp
}
80104dcf:	90                   	nop
80104dd0:	c9                   	leave  
80104dd1:	c3                   	ret    

80104dd2 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104dd2:	f3 0f 1e fb          	endbr32 
80104dd6:	55                   	push   %ebp
80104dd7:	89 e5                	mov    %esp,%ebp
80104dd9:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104ddc:	83 ec 0c             	sub    $0xc,%esp
80104ddf:	68 c0 4d 11 80       	push   $0x80114dc0
80104de4:	e8 17 05 00 00       	call   80105300 <release>
80104de9:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104dec:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104df1:	85 c0                	test   %eax,%eax
80104df3:	74 24                	je     80104e19 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104df5:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104dfc:	00 00 00 
    iinit(ROOTDEV);
80104dff:	83 ec 0c             	sub    $0xc,%esp
80104e02:	6a 01                	push   $0x1
80104e04:	e8 79 c9 ff ff       	call   80101782 <iinit>
80104e09:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104e0c:	83 ec 0c             	sub    $0xc,%esp
80104e0f:	6a 01                	push   $0x1
80104e11:	e8 8e e6 ff ff       	call   801034a4 <initlog>
80104e16:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104e19:	90                   	nop
80104e1a:	c9                   	leave  
80104e1b:	c3                   	ret    

80104e1c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e1c:	f3 0f 1e fb          	endbr32 
80104e20:	55                   	push   %ebp
80104e21:	89 e5                	mov    %esp,%ebp
80104e23:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104e26:	e8 6b f6 ff ff       	call   80104496 <myproc>
80104e2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104e2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e32:	75 0d                	jne    80104e41 <sleep+0x25>
    panic("sleep");
80104e34:	83 ec 0c             	sub    $0xc,%esp
80104e37:	68 7b 94 10 80       	push   $0x8010947b
80104e3c:	e8 c7 b7 ff ff       	call   80100608 <panic>

  if(lk == 0)
80104e41:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e45:	75 0d                	jne    80104e54 <sleep+0x38>
    panic("sleep without lk");
80104e47:	83 ec 0c             	sub    $0xc,%esp
80104e4a:	68 81 94 10 80       	push   $0x80109481
80104e4f:	e8 b4 b7 ff ff       	call   80100608 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e54:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104e5b:	74 1e                	je     80104e7b <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e5d:	83 ec 0c             	sub    $0xc,%esp
80104e60:	68 c0 4d 11 80       	push   $0x80114dc0
80104e65:	e8 24 04 00 00       	call   8010528e <acquire>
80104e6a:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104e6d:	83 ec 0c             	sub    $0xc,%esp
80104e70:	ff 75 0c             	pushl  0xc(%ebp)
80104e73:	e8 88 04 00 00       	call   80105300 <release>
80104e78:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e7e:	8b 55 08             	mov    0x8(%ebp),%edx
80104e81:	89 50 24             	mov    %edx,0x24(%eax)
  p->state = SLEEPING;
80104e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e87:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104e8e:	e8 44 fe ff ff       	call   80104cd7 <sched>

  // Tidy up.
  p->chan = 0;
80104e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e96:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e9d:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104ea4:	74 1e                	je     80104ec4 <sleep+0xa8>
    release(&ptable.lock);
80104ea6:	83 ec 0c             	sub    $0xc,%esp
80104ea9:	68 c0 4d 11 80       	push   $0x80114dc0
80104eae:	e8 4d 04 00 00       	call   80105300 <release>
80104eb3:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104eb6:	83 ec 0c             	sub    $0xc,%esp
80104eb9:	ff 75 0c             	pushl  0xc(%ebp)
80104ebc:	e8 cd 03 00 00       	call   8010528e <acquire>
80104ec1:	83 c4 10             	add    $0x10,%esp
  }
}
80104ec4:	90                   	nop
80104ec5:	c9                   	leave  
80104ec6:	c3                   	ret    

80104ec7 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ec7:	f3 0f 1e fb          	endbr32 
80104ecb:	55                   	push   %ebp
80104ecc:	89 e5                	mov    %esp,%ebp
80104ece:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ed1:	c7 45 fc f4 4d 11 80 	movl   $0x80114df4,-0x4(%ebp)
80104ed8:	eb 27                	jmp    80104f01 <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
80104eda:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104edd:	8b 40 0c             	mov    0xc(%eax),%eax
80104ee0:	83 f8 02             	cmp    $0x2,%eax
80104ee3:	75 15                	jne    80104efa <wakeup1+0x33>
80104ee5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ee8:	8b 40 24             	mov    0x24(%eax),%eax
80104eeb:	39 45 08             	cmp    %eax,0x8(%ebp)
80104eee:	75 0a                	jne    80104efa <wakeup1+0x33>
      p->state = RUNNABLE;
80104ef0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ef3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104efa:	81 45 fc cc 00 00 00 	addl   $0xcc,-0x4(%ebp)
80104f01:	81 7d fc f4 80 11 80 	cmpl   $0x801180f4,-0x4(%ebp)
80104f08:	72 d0                	jb     80104eda <wakeup1+0x13>
}
80104f0a:	90                   	nop
80104f0b:	90                   	nop
80104f0c:	c9                   	leave  
80104f0d:	c3                   	ret    

80104f0e <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f0e:	f3 0f 1e fb          	endbr32 
80104f12:	55                   	push   %ebp
80104f13:	89 e5                	mov    %esp,%ebp
80104f15:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104f18:	83 ec 0c             	sub    $0xc,%esp
80104f1b:	68 c0 4d 11 80       	push   $0x80114dc0
80104f20:	e8 69 03 00 00       	call   8010528e <acquire>
80104f25:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104f28:	83 ec 0c             	sub    $0xc,%esp
80104f2b:	ff 75 08             	pushl  0x8(%ebp)
80104f2e:	e8 94 ff ff ff       	call   80104ec7 <wakeup1>
80104f33:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104f36:	83 ec 0c             	sub    $0xc,%esp
80104f39:	68 c0 4d 11 80       	push   $0x80114dc0
80104f3e:	e8 bd 03 00 00       	call   80105300 <release>
80104f43:	83 c4 10             	add    $0x10,%esp
}
80104f46:	90                   	nop
80104f47:	c9                   	leave  
80104f48:	c3                   	ret    

80104f49 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f49:	f3 0f 1e fb          	endbr32 
80104f4d:	55                   	push   %ebp
80104f4e:	89 e5                	mov    %esp,%ebp
80104f50:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f53:	83 ec 0c             	sub    $0xc,%esp
80104f56:	68 c0 4d 11 80       	push   $0x80114dc0
80104f5b:	e8 2e 03 00 00       	call   8010528e <acquire>
80104f60:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f63:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104f6a:	eb 48                	jmp    80104fb4 <kill+0x6b>
    if(p->pid == pid){
80104f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f6f:	8b 40 10             	mov    0x10(%eax),%eax
80104f72:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f75:	75 36                	jne    80104fad <kill+0x64>
      p->killed = 1;
80104f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f7a:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f84:	8b 40 0c             	mov    0xc(%eax),%eax
80104f87:	83 f8 02             	cmp    $0x2,%eax
80104f8a:	75 0a                	jne    80104f96 <kill+0x4d>
        p->state = RUNNABLE;
80104f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f8f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104f96:	83 ec 0c             	sub    $0xc,%esp
80104f99:	68 c0 4d 11 80       	push   $0x80114dc0
80104f9e:	e8 5d 03 00 00       	call   80105300 <release>
80104fa3:	83 c4 10             	add    $0x10,%esp
      return 0;
80104fa6:	b8 00 00 00 00       	mov    $0x0,%eax
80104fab:	eb 25                	jmp    80104fd2 <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fad:	81 45 f4 cc 00 00 00 	addl   $0xcc,-0xc(%ebp)
80104fb4:	81 7d f4 f4 80 11 80 	cmpl   $0x801180f4,-0xc(%ebp)
80104fbb:	72 af                	jb     80104f6c <kill+0x23>
    }
  }
  release(&ptable.lock);
80104fbd:	83 ec 0c             	sub    $0xc,%esp
80104fc0:	68 c0 4d 11 80       	push   $0x80114dc0
80104fc5:	e8 36 03 00 00       	call   80105300 <release>
80104fca:	83 c4 10             	add    $0x10,%esp
  return -1;
80104fcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104fd2:	c9                   	leave  
80104fd3:	c3                   	ret    

80104fd4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104fd4:	f3 0f 1e fb          	endbr32 
80104fd8:	55                   	push   %ebp
80104fd9:	89 e5                	mov    %esp,%ebp
80104fdb:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fde:	c7 45 f0 f4 4d 11 80 	movl   $0x80114df4,-0x10(%ebp)
80104fe5:	e9 da 00 00 00       	jmp    801050c4 <procdump+0xf0>
    if(p->state == UNUSED)
80104fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fed:	8b 40 0c             	mov    0xc(%eax),%eax
80104ff0:	85 c0                	test   %eax,%eax
80104ff2:	0f 84 c4 00 00 00    	je     801050bc <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ffb:	8b 40 0c             	mov    0xc(%eax),%eax
80104ffe:	83 f8 05             	cmp    $0x5,%eax
80105001:	77 23                	ja     80105026 <procdump+0x52>
80105003:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105006:	8b 40 0c             	mov    0xc(%eax),%eax
80105009:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105010:	85 c0                	test   %eax,%eax
80105012:	74 12                	je     80105026 <procdump+0x52>
      state = states[p->state];
80105014:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105017:	8b 40 0c             	mov    0xc(%eax),%eax
8010501a:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105021:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105024:	eb 07                	jmp    8010502d <procdump+0x59>
    else
      state = "???";
80105026:	c7 45 ec 92 94 10 80 	movl   $0x80109492,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010502d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105030:	8d 50 70             	lea    0x70(%eax),%edx
80105033:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105036:	8b 40 10             	mov    0x10(%eax),%eax
80105039:	52                   	push   %edx
8010503a:	ff 75 ec             	pushl  -0x14(%ebp)
8010503d:	50                   	push   %eax
8010503e:	68 96 94 10 80       	push   $0x80109496
80105043:	e8 d0 b3 ff ff       	call   80100418 <cprintf>
80105048:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010504b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010504e:	8b 40 0c             	mov    0xc(%eax),%eax
80105051:	83 f8 02             	cmp    $0x2,%eax
80105054:	75 54                	jne    801050aa <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105056:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105059:	8b 40 20             	mov    0x20(%eax),%eax
8010505c:	8b 40 0c             	mov    0xc(%eax),%eax
8010505f:	83 c0 08             	add    $0x8,%eax
80105062:	89 c2                	mov    %eax,%edx
80105064:	83 ec 08             	sub    $0x8,%esp
80105067:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010506a:	50                   	push   %eax
8010506b:	52                   	push   %edx
8010506c:	e8 e5 02 00 00       	call   80105356 <getcallerpcs>
80105071:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105074:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010507b:	eb 1c                	jmp    80105099 <procdump+0xc5>
        cprintf(" %p", pc[i]);
8010507d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105080:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105084:	83 ec 08             	sub    $0x8,%esp
80105087:	50                   	push   %eax
80105088:	68 9f 94 10 80       	push   $0x8010949f
8010508d:	e8 86 b3 ff ff       	call   80100418 <cprintf>
80105092:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105095:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105099:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010509d:	7f 0b                	jg     801050aa <procdump+0xd6>
8010509f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a2:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050a6:	85 c0                	test   %eax,%eax
801050a8:	75 d3                	jne    8010507d <procdump+0xa9>
    }
    cprintf("\n");
801050aa:	83 ec 0c             	sub    $0xc,%esp
801050ad:	68 a3 94 10 80       	push   $0x801094a3
801050b2:	e8 61 b3 ff ff       	call   80100418 <cprintf>
801050b7:	83 c4 10             	add    $0x10,%esp
801050ba:	eb 01                	jmp    801050bd <procdump+0xe9>
      continue;
801050bc:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050bd:	81 45 f0 cc 00 00 00 	addl   $0xcc,-0x10(%ebp)
801050c4:	81 7d f0 f4 80 11 80 	cmpl   $0x801180f4,-0x10(%ebp)
801050cb:	0f 82 19 ff ff ff    	jb     80104fea <procdump+0x16>
  }
}
801050d1:	90                   	nop
801050d2:	90                   	nop
801050d3:	c9                   	leave  
801050d4:	c3                   	ret    

801050d5 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801050d5:	f3 0f 1e fb          	endbr32 
801050d9:	55                   	push   %ebp
801050da:	89 e5                	mov    %esp,%ebp
801050dc:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801050df:	8b 45 08             	mov    0x8(%ebp),%eax
801050e2:	83 c0 04             	add    $0x4,%eax
801050e5:	83 ec 08             	sub    $0x8,%esp
801050e8:	68 cf 94 10 80       	push   $0x801094cf
801050ed:	50                   	push   %eax
801050ee:	e8 75 01 00 00       	call   80105268 <initlock>
801050f3:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801050f6:	8b 45 08             	mov    0x8(%ebp),%eax
801050f9:	8b 55 0c             	mov    0xc(%ebp),%edx
801050fc:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801050ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105102:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105108:	8b 45 08             	mov    0x8(%ebp),%eax
8010510b:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105112:	90                   	nop
80105113:	c9                   	leave  
80105114:	c3                   	ret    

80105115 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105115:	f3 0f 1e fb          	endbr32 
80105119:	55                   	push   %ebp
8010511a:	89 e5                	mov    %esp,%ebp
8010511c:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010511f:	8b 45 08             	mov    0x8(%ebp),%eax
80105122:	83 c0 04             	add    $0x4,%eax
80105125:	83 ec 0c             	sub    $0xc,%esp
80105128:	50                   	push   %eax
80105129:	e8 60 01 00 00       	call   8010528e <acquire>
8010512e:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105131:	eb 15                	jmp    80105148 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80105133:	8b 45 08             	mov    0x8(%ebp),%eax
80105136:	83 c0 04             	add    $0x4,%eax
80105139:	83 ec 08             	sub    $0x8,%esp
8010513c:	50                   	push   %eax
8010513d:	ff 75 08             	pushl  0x8(%ebp)
80105140:	e8 d7 fc ff ff       	call   80104e1c <sleep>
80105145:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105148:	8b 45 08             	mov    0x8(%ebp),%eax
8010514b:	8b 00                	mov    (%eax),%eax
8010514d:	85 c0                	test   %eax,%eax
8010514f:	75 e2                	jne    80105133 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80105151:	8b 45 08             	mov    0x8(%ebp),%eax
80105154:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010515a:	e8 37 f3 ff ff       	call   80104496 <myproc>
8010515f:	8b 50 10             	mov    0x10(%eax),%edx
80105162:	8b 45 08             	mov    0x8(%ebp),%eax
80105165:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105168:	8b 45 08             	mov    0x8(%ebp),%eax
8010516b:	83 c0 04             	add    $0x4,%eax
8010516e:	83 ec 0c             	sub    $0xc,%esp
80105171:	50                   	push   %eax
80105172:	e8 89 01 00 00       	call   80105300 <release>
80105177:	83 c4 10             	add    $0x10,%esp
}
8010517a:	90                   	nop
8010517b:	c9                   	leave  
8010517c:	c3                   	ret    

8010517d <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010517d:	f3 0f 1e fb          	endbr32 
80105181:	55                   	push   %ebp
80105182:	89 e5                	mov    %esp,%ebp
80105184:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105187:	8b 45 08             	mov    0x8(%ebp),%eax
8010518a:	83 c0 04             	add    $0x4,%eax
8010518d:	83 ec 0c             	sub    $0xc,%esp
80105190:	50                   	push   %eax
80105191:	e8 f8 00 00 00       	call   8010528e <acquire>
80105196:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105199:	8b 45 08             	mov    0x8(%ebp),%eax
8010519c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051a2:	8b 45 08             	mov    0x8(%ebp),%eax
801051a5:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801051ac:	83 ec 0c             	sub    $0xc,%esp
801051af:	ff 75 08             	pushl  0x8(%ebp)
801051b2:	e8 57 fd ff ff       	call   80104f0e <wakeup>
801051b7:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801051ba:	8b 45 08             	mov    0x8(%ebp),%eax
801051bd:	83 c0 04             	add    $0x4,%eax
801051c0:	83 ec 0c             	sub    $0xc,%esp
801051c3:	50                   	push   %eax
801051c4:	e8 37 01 00 00       	call   80105300 <release>
801051c9:	83 c4 10             	add    $0x10,%esp
}
801051cc:	90                   	nop
801051cd:	c9                   	leave  
801051ce:	c3                   	ret    

801051cf <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801051cf:	f3 0f 1e fb          	endbr32 
801051d3:	55                   	push   %ebp
801051d4:	89 e5                	mov    %esp,%ebp
801051d6:	53                   	push   %ebx
801051d7:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
801051da:	8b 45 08             	mov    0x8(%ebp),%eax
801051dd:	83 c0 04             	add    $0x4,%eax
801051e0:	83 ec 0c             	sub    $0xc,%esp
801051e3:	50                   	push   %eax
801051e4:	e8 a5 00 00 00       	call   8010528e <acquire>
801051e9:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
801051ec:	8b 45 08             	mov    0x8(%ebp),%eax
801051ef:	8b 00                	mov    (%eax),%eax
801051f1:	85 c0                	test   %eax,%eax
801051f3:	74 19                	je     8010520e <holdingsleep+0x3f>
801051f5:	8b 45 08             	mov    0x8(%ebp),%eax
801051f8:	8b 58 3c             	mov    0x3c(%eax),%ebx
801051fb:	e8 96 f2 ff ff       	call   80104496 <myproc>
80105200:	8b 40 10             	mov    0x10(%eax),%eax
80105203:	39 c3                	cmp    %eax,%ebx
80105205:	75 07                	jne    8010520e <holdingsleep+0x3f>
80105207:	b8 01 00 00 00       	mov    $0x1,%eax
8010520c:	eb 05                	jmp    80105213 <holdingsleep+0x44>
8010520e:	b8 00 00 00 00       	mov    $0x0,%eax
80105213:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105216:	8b 45 08             	mov    0x8(%ebp),%eax
80105219:	83 c0 04             	add    $0x4,%eax
8010521c:	83 ec 0c             	sub    $0xc,%esp
8010521f:	50                   	push   %eax
80105220:	e8 db 00 00 00       	call   80105300 <release>
80105225:	83 c4 10             	add    $0x10,%esp
  return r;
80105228:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010522b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010522e:	c9                   	leave  
8010522f:	c3                   	ret    

80105230 <readeflags>:
{
80105230:	55                   	push   %ebp
80105231:	89 e5                	mov    %esp,%ebp
80105233:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105236:	9c                   	pushf  
80105237:	58                   	pop    %eax
80105238:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010523b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010523e:	c9                   	leave  
8010523f:	c3                   	ret    

80105240 <cli>:
{
80105240:	55                   	push   %ebp
80105241:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105243:	fa                   	cli    
}
80105244:	90                   	nop
80105245:	5d                   	pop    %ebp
80105246:	c3                   	ret    

80105247 <sti>:
{
80105247:	55                   	push   %ebp
80105248:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010524a:	fb                   	sti    
}
8010524b:	90                   	nop
8010524c:	5d                   	pop    %ebp
8010524d:	c3                   	ret    

8010524e <xchg>:
{
8010524e:	55                   	push   %ebp
8010524f:	89 e5                	mov    %esp,%ebp
80105251:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105254:	8b 55 08             	mov    0x8(%ebp),%edx
80105257:	8b 45 0c             	mov    0xc(%ebp),%eax
8010525a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010525d:	f0 87 02             	lock xchg %eax,(%edx)
80105260:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105263:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105266:	c9                   	leave  
80105267:	c3                   	ret    

80105268 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105268:	f3 0f 1e fb          	endbr32 
8010526c:	55                   	push   %ebp
8010526d:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010526f:	8b 45 08             	mov    0x8(%ebp),%eax
80105272:	8b 55 0c             	mov    0xc(%ebp),%edx
80105275:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105278:	8b 45 08             	mov    0x8(%ebp),%eax
8010527b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105281:	8b 45 08             	mov    0x8(%ebp),%eax
80105284:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010528b:	90                   	nop
8010528c:	5d                   	pop    %ebp
8010528d:	c3                   	ret    

8010528e <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010528e:	f3 0f 1e fb          	endbr32 
80105292:	55                   	push   %ebp
80105293:	89 e5                	mov    %esp,%ebp
80105295:	53                   	push   %ebx
80105296:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105299:	e8 7c 01 00 00       	call   8010541a <pushcli>
  if(holding(lk))
8010529e:	8b 45 08             	mov    0x8(%ebp),%eax
801052a1:	83 ec 0c             	sub    $0xc,%esp
801052a4:	50                   	push   %eax
801052a5:	e8 2b 01 00 00       	call   801053d5 <holding>
801052aa:	83 c4 10             	add    $0x10,%esp
801052ad:	85 c0                	test   %eax,%eax
801052af:	74 0d                	je     801052be <acquire+0x30>
    panic("acquire");
801052b1:	83 ec 0c             	sub    $0xc,%esp
801052b4:	68 da 94 10 80       	push   $0x801094da
801052b9:	e8 4a b3 ff ff       	call   80100608 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801052be:	90                   	nop
801052bf:	8b 45 08             	mov    0x8(%ebp),%eax
801052c2:	83 ec 08             	sub    $0x8,%esp
801052c5:	6a 01                	push   $0x1
801052c7:	50                   	push   %eax
801052c8:	e8 81 ff ff ff       	call   8010524e <xchg>
801052cd:	83 c4 10             	add    $0x10,%esp
801052d0:	85 c0                	test   %eax,%eax
801052d2:	75 eb                	jne    801052bf <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801052d4:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801052d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801052dc:	e8 39 f1 ff ff       	call   8010441a <mycpu>
801052e1:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801052e4:	8b 45 08             	mov    0x8(%ebp),%eax
801052e7:	83 c0 0c             	add    $0xc,%eax
801052ea:	83 ec 08             	sub    $0x8,%esp
801052ed:	50                   	push   %eax
801052ee:	8d 45 08             	lea    0x8(%ebp),%eax
801052f1:	50                   	push   %eax
801052f2:	e8 5f 00 00 00       	call   80105356 <getcallerpcs>
801052f7:	83 c4 10             	add    $0x10,%esp
}
801052fa:	90                   	nop
801052fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052fe:	c9                   	leave  
801052ff:	c3                   	ret    

80105300 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105300:	f3 0f 1e fb          	endbr32 
80105304:	55                   	push   %ebp
80105305:	89 e5                	mov    %esp,%ebp
80105307:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010530a:	83 ec 0c             	sub    $0xc,%esp
8010530d:	ff 75 08             	pushl  0x8(%ebp)
80105310:	e8 c0 00 00 00       	call   801053d5 <holding>
80105315:	83 c4 10             	add    $0x10,%esp
80105318:	85 c0                	test   %eax,%eax
8010531a:	75 0d                	jne    80105329 <release+0x29>
    panic("release");
8010531c:	83 ec 0c             	sub    $0xc,%esp
8010531f:	68 e2 94 10 80       	push   $0x801094e2
80105324:	e8 df b2 ff ff       	call   80100608 <panic>

  lk->pcs[0] = 0;
80105329:	8b 45 08             	mov    0x8(%ebp),%eax
8010532c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105333:	8b 45 08             	mov    0x8(%ebp),%eax
80105336:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010533d:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105342:	8b 45 08             	mov    0x8(%ebp),%eax
80105345:	8b 55 08             	mov    0x8(%ebp),%edx
80105348:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010534e:	e8 18 01 00 00       	call   8010546b <popcli>
}
80105353:	90                   	nop
80105354:	c9                   	leave  
80105355:	c3                   	ret    

80105356 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105356:	f3 0f 1e fb          	endbr32 
8010535a:	55                   	push   %ebp
8010535b:	89 e5                	mov    %esp,%ebp
8010535d:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105360:	8b 45 08             	mov    0x8(%ebp),%eax
80105363:	83 e8 08             	sub    $0x8,%eax
80105366:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105369:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105370:	eb 38                	jmp    801053aa <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105372:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105376:	74 53                	je     801053cb <getcallerpcs+0x75>
80105378:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010537f:	76 4a                	jbe    801053cb <getcallerpcs+0x75>
80105381:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105385:	74 44                	je     801053cb <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105387:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010538a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105391:	8b 45 0c             	mov    0xc(%ebp),%eax
80105394:	01 c2                	add    %eax,%edx
80105396:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105399:	8b 40 04             	mov    0x4(%eax),%eax
8010539c:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010539e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053a1:	8b 00                	mov    (%eax),%eax
801053a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053a6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053aa:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053ae:	7e c2                	jle    80105372 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
801053b0:	eb 19                	jmp    801053cb <getcallerpcs+0x75>
    pcs[i] = 0;
801053b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053b5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801053bf:	01 d0                	add    %edx,%eax
801053c1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801053c7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053cb:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053cf:	7e e1                	jle    801053b2 <getcallerpcs+0x5c>
}
801053d1:	90                   	nop
801053d2:	90                   	nop
801053d3:	c9                   	leave  
801053d4:	c3                   	ret    

801053d5 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801053d5:	f3 0f 1e fb          	endbr32 
801053d9:	55                   	push   %ebp
801053da:	89 e5                	mov    %esp,%ebp
801053dc:	53                   	push   %ebx
801053dd:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
801053e0:	e8 35 00 00 00       	call   8010541a <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801053e5:	8b 45 08             	mov    0x8(%ebp),%eax
801053e8:	8b 00                	mov    (%eax),%eax
801053ea:	85 c0                	test   %eax,%eax
801053ec:	74 16                	je     80105404 <holding+0x2f>
801053ee:	8b 45 08             	mov    0x8(%ebp),%eax
801053f1:	8b 58 08             	mov    0x8(%eax),%ebx
801053f4:	e8 21 f0 ff ff       	call   8010441a <mycpu>
801053f9:	39 c3                	cmp    %eax,%ebx
801053fb:	75 07                	jne    80105404 <holding+0x2f>
801053fd:	b8 01 00 00 00       	mov    $0x1,%eax
80105402:	eb 05                	jmp    80105409 <holding+0x34>
80105404:	b8 00 00 00 00       	mov    $0x0,%eax
80105409:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
8010540c:	e8 5a 00 00 00       	call   8010546b <popcli>
  return r;
80105411:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105414:	83 c4 14             	add    $0x14,%esp
80105417:	5b                   	pop    %ebx
80105418:	5d                   	pop    %ebp
80105419:	c3                   	ret    

8010541a <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010541a:	f3 0f 1e fb          	endbr32 
8010541e:	55                   	push   %ebp
8010541f:	89 e5                	mov    %esp,%ebp
80105421:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105424:	e8 07 fe ff ff       	call   80105230 <readeflags>
80105429:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
8010542c:	e8 0f fe ff ff       	call   80105240 <cli>
  if(mycpu()->ncli == 0)
80105431:	e8 e4 ef ff ff       	call   8010441a <mycpu>
80105436:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010543c:	85 c0                	test   %eax,%eax
8010543e:	75 14                	jne    80105454 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80105440:	e8 d5 ef ff ff       	call   8010441a <mycpu>
80105445:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105448:	81 e2 00 02 00 00    	and    $0x200,%edx
8010544e:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105454:	e8 c1 ef ff ff       	call   8010441a <mycpu>
80105459:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010545f:	83 c2 01             	add    $0x1,%edx
80105462:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105468:	90                   	nop
80105469:	c9                   	leave  
8010546a:	c3                   	ret    

8010546b <popcli>:

void
popcli(void)
{
8010546b:	f3 0f 1e fb          	endbr32 
8010546f:	55                   	push   %ebp
80105470:	89 e5                	mov    %esp,%ebp
80105472:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105475:	e8 b6 fd ff ff       	call   80105230 <readeflags>
8010547a:	25 00 02 00 00       	and    $0x200,%eax
8010547f:	85 c0                	test   %eax,%eax
80105481:	74 0d                	je     80105490 <popcli+0x25>
    panic("popcli - interruptible");
80105483:	83 ec 0c             	sub    $0xc,%esp
80105486:	68 ea 94 10 80       	push   $0x801094ea
8010548b:	e8 78 b1 ff ff       	call   80100608 <panic>
  if(--mycpu()->ncli < 0)
80105490:	e8 85 ef ff ff       	call   8010441a <mycpu>
80105495:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010549b:	83 ea 01             	sub    $0x1,%edx
8010549e:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801054a4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054aa:	85 c0                	test   %eax,%eax
801054ac:	79 0d                	jns    801054bb <popcli+0x50>
    panic("popcli");
801054ae:	83 ec 0c             	sub    $0xc,%esp
801054b1:	68 01 95 10 80       	push   $0x80109501
801054b6:	e8 4d b1 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801054bb:	e8 5a ef ff ff       	call   8010441a <mycpu>
801054c0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054c6:	85 c0                	test   %eax,%eax
801054c8:	75 14                	jne    801054de <popcli+0x73>
801054ca:	e8 4b ef ff ff       	call   8010441a <mycpu>
801054cf:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801054d5:	85 c0                	test   %eax,%eax
801054d7:	74 05                	je     801054de <popcli+0x73>
    sti();
801054d9:	e8 69 fd ff ff       	call   80105247 <sti>
}
801054de:	90                   	nop
801054df:	c9                   	leave  
801054e0:	c3                   	ret    

801054e1 <stosb>:
{
801054e1:	55                   	push   %ebp
801054e2:	89 e5                	mov    %esp,%ebp
801054e4:	57                   	push   %edi
801054e5:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801054e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054e9:	8b 55 10             	mov    0x10(%ebp),%edx
801054ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ef:	89 cb                	mov    %ecx,%ebx
801054f1:	89 df                	mov    %ebx,%edi
801054f3:	89 d1                	mov    %edx,%ecx
801054f5:	fc                   	cld    
801054f6:	f3 aa                	rep stos %al,%es:(%edi)
801054f8:	89 ca                	mov    %ecx,%edx
801054fa:	89 fb                	mov    %edi,%ebx
801054fc:	89 5d 08             	mov    %ebx,0x8(%ebp)
801054ff:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105502:	90                   	nop
80105503:	5b                   	pop    %ebx
80105504:	5f                   	pop    %edi
80105505:	5d                   	pop    %ebp
80105506:	c3                   	ret    

80105507 <stosl>:
{
80105507:	55                   	push   %ebp
80105508:	89 e5                	mov    %esp,%ebp
8010550a:	57                   	push   %edi
8010550b:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010550c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010550f:	8b 55 10             	mov    0x10(%ebp),%edx
80105512:	8b 45 0c             	mov    0xc(%ebp),%eax
80105515:	89 cb                	mov    %ecx,%ebx
80105517:	89 df                	mov    %ebx,%edi
80105519:	89 d1                	mov    %edx,%ecx
8010551b:	fc                   	cld    
8010551c:	f3 ab                	rep stos %eax,%es:(%edi)
8010551e:	89 ca                	mov    %ecx,%edx
80105520:	89 fb                	mov    %edi,%ebx
80105522:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105525:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105528:	90                   	nop
80105529:	5b                   	pop    %ebx
8010552a:	5f                   	pop    %edi
8010552b:	5d                   	pop    %ebp
8010552c:	c3                   	ret    

8010552d <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010552d:	f3 0f 1e fb          	endbr32 
80105531:	55                   	push   %ebp
80105532:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105534:	8b 45 08             	mov    0x8(%ebp),%eax
80105537:	83 e0 03             	and    $0x3,%eax
8010553a:	85 c0                	test   %eax,%eax
8010553c:	75 43                	jne    80105581 <memset+0x54>
8010553e:	8b 45 10             	mov    0x10(%ebp),%eax
80105541:	83 e0 03             	and    $0x3,%eax
80105544:	85 c0                	test   %eax,%eax
80105546:	75 39                	jne    80105581 <memset+0x54>
    c &= 0xFF;
80105548:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010554f:	8b 45 10             	mov    0x10(%ebp),%eax
80105552:	c1 e8 02             	shr    $0x2,%eax
80105555:	89 c1                	mov    %eax,%ecx
80105557:	8b 45 0c             	mov    0xc(%ebp),%eax
8010555a:	c1 e0 18             	shl    $0x18,%eax
8010555d:	89 c2                	mov    %eax,%edx
8010555f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105562:	c1 e0 10             	shl    $0x10,%eax
80105565:	09 c2                	or     %eax,%edx
80105567:	8b 45 0c             	mov    0xc(%ebp),%eax
8010556a:	c1 e0 08             	shl    $0x8,%eax
8010556d:	09 d0                	or     %edx,%eax
8010556f:	0b 45 0c             	or     0xc(%ebp),%eax
80105572:	51                   	push   %ecx
80105573:	50                   	push   %eax
80105574:	ff 75 08             	pushl  0x8(%ebp)
80105577:	e8 8b ff ff ff       	call   80105507 <stosl>
8010557c:	83 c4 0c             	add    $0xc,%esp
8010557f:	eb 12                	jmp    80105593 <memset+0x66>
  } else
    stosb(dst, c, n);
80105581:	8b 45 10             	mov    0x10(%ebp),%eax
80105584:	50                   	push   %eax
80105585:	ff 75 0c             	pushl  0xc(%ebp)
80105588:	ff 75 08             	pushl  0x8(%ebp)
8010558b:	e8 51 ff ff ff       	call   801054e1 <stosb>
80105590:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105593:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105596:	c9                   	leave  
80105597:	c3                   	ret    

80105598 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105598:	f3 0f 1e fb          	endbr32 
8010559c:	55                   	push   %ebp
8010559d:	89 e5                	mov    %esp,%ebp
8010559f:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801055a2:	8b 45 08             	mov    0x8(%ebp),%eax
801055a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801055a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ab:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801055ae:	eb 30                	jmp    801055e0 <memcmp+0x48>
    if(*s1 != *s2)
801055b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055b3:	0f b6 10             	movzbl (%eax),%edx
801055b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055b9:	0f b6 00             	movzbl (%eax),%eax
801055bc:	38 c2                	cmp    %al,%dl
801055be:	74 18                	je     801055d8 <memcmp+0x40>
      return *s1 - *s2;
801055c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055c3:	0f b6 00             	movzbl (%eax),%eax
801055c6:	0f b6 d0             	movzbl %al,%edx
801055c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055cc:	0f b6 00             	movzbl (%eax),%eax
801055cf:	0f b6 c0             	movzbl %al,%eax
801055d2:	29 c2                	sub    %eax,%edx
801055d4:	89 d0                	mov    %edx,%eax
801055d6:	eb 1a                	jmp    801055f2 <memcmp+0x5a>
    s1++, s2++;
801055d8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055dc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
801055e0:	8b 45 10             	mov    0x10(%ebp),%eax
801055e3:	8d 50 ff             	lea    -0x1(%eax),%edx
801055e6:	89 55 10             	mov    %edx,0x10(%ebp)
801055e9:	85 c0                	test   %eax,%eax
801055eb:	75 c3                	jne    801055b0 <memcmp+0x18>
  }

  return 0;
801055ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055f2:	c9                   	leave  
801055f3:	c3                   	ret    

801055f4 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801055f4:	f3 0f 1e fb          	endbr32 
801055f8:	55                   	push   %ebp
801055f9:	89 e5                	mov    %esp,%ebp
801055fb:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801055fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105601:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105604:	8b 45 08             	mov    0x8(%ebp),%eax
80105607:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010560a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010560d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105610:	73 54                	jae    80105666 <memmove+0x72>
80105612:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105615:	8b 45 10             	mov    0x10(%ebp),%eax
80105618:	01 d0                	add    %edx,%eax
8010561a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010561d:	73 47                	jae    80105666 <memmove+0x72>
    s += n;
8010561f:	8b 45 10             	mov    0x10(%ebp),%eax
80105622:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105625:	8b 45 10             	mov    0x10(%ebp),%eax
80105628:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010562b:	eb 13                	jmp    80105640 <memmove+0x4c>
      *--d = *--s;
8010562d:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105631:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105635:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105638:	0f b6 10             	movzbl (%eax),%edx
8010563b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010563e:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105640:	8b 45 10             	mov    0x10(%ebp),%eax
80105643:	8d 50 ff             	lea    -0x1(%eax),%edx
80105646:	89 55 10             	mov    %edx,0x10(%ebp)
80105649:	85 c0                	test   %eax,%eax
8010564b:	75 e0                	jne    8010562d <memmove+0x39>
  if(s < d && s + n > d){
8010564d:	eb 24                	jmp    80105673 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
8010564f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105652:	8d 42 01             	lea    0x1(%edx),%eax
80105655:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105658:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010565b:	8d 48 01             	lea    0x1(%eax),%ecx
8010565e:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105661:	0f b6 12             	movzbl (%edx),%edx
80105664:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105666:	8b 45 10             	mov    0x10(%ebp),%eax
80105669:	8d 50 ff             	lea    -0x1(%eax),%edx
8010566c:	89 55 10             	mov    %edx,0x10(%ebp)
8010566f:	85 c0                	test   %eax,%eax
80105671:	75 dc                	jne    8010564f <memmove+0x5b>

  return dst;
80105673:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105676:	c9                   	leave  
80105677:	c3                   	ret    

80105678 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105678:	f3 0f 1e fb          	endbr32 
8010567c:	55                   	push   %ebp
8010567d:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
8010567f:	ff 75 10             	pushl  0x10(%ebp)
80105682:	ff 75 0c             	pushl  0xc(%ebp)
80105685:	ff 75 08             	pushl  0x8(%ebp)
80105688:	e8 67 ff ff ff       	call   801055f4 <memmove>
8010568d:	83 c4 0c             	add    $0xc,%esp
}
80105690:	c9                   	leave  
80105691:	c3                   	ret    

80105692 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105692:	f3 0f 1e fb          	endbr32 
80105696:	55                   	push   %ebp
80105697:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105699:	eb 0c                	jmp    801056a7 <strncmp+0x15>
    n--, p++, q++;
8010569b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010569f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801056a3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801056a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056ab:	74 1a                	je     801056c7 <strncmp+0x35>
801056ad:	8b 45 08             	mov    0x8(%ebp),%eax
801056b0:	0f b6 00             	movzbl (%eax),%eax
801056b3:	84 c0                	test   %al,%al
801056b5:	74 10                	je     801056c7 <strncmp+0x35>
801056b7:	8b 45 08             	mov    0x8(%ebp),%eax
801056ba:	0f b6 10             	movzbl (%eax),%edx
801056bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801056c0:	0f b6 00             	movzbl (%eax),%eax
801056c3:	38 c2                	cmp    %al,%dl
801056c5:	74 d4                	je     8010569b <strncmp+0x9>
  if(n == 0)
801056c7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056cb:	75 07                	jne    801056d4 <strncmp+0x42>
    return 0;
801056cd:	b8 00 00 00 00       	mov    $0x0,%eax
801056d2:	eb 16                	jmp    801056ea <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
801056d4:	8b 45 08             	mov    0x8(%ebp),%eax
801056d7:	0f b6 00             	movzbl (%eax),%eax
801056da:	0f b6 d0             	movzbl %al,%edx
801056dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801056e0:	0f b6 00             	movzbl (%eax),%eax
801056e3:	0f b6 c0             	movzbl %al,%eax
801056e6:	29 c2                	sub    %eax,%edx
801056e8:	89 d0                	mov    %edx,%eax
}
801056ea:	5d                   	pop    %ebp
801056eb:	c3                   	ret    

801056ec <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801056ec:	f3 0f 1e fb          	endbr32 
801056f0:	55                   	push   %ebp
801056f1:	89 e5                	mov    %esp,%ebp
801056f3:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801056f6:	8b 45 08             	mov    0x8(%ebp),%eax
801056f9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801056fc:	90                   	nop
801056fd:	8b 45 10             	mov    0x10(%ebp),%eax
80105700:	8d 50 ff             	lea    -0x1(%eax),%edx
80105703:	89 55 10             	mov    %edx,0x10(%ebp)
80105706:	85 c0                	test   %eax,%eax
80105708:	7e 2c                	jle    80105736 <strncpy+0x4a>
8010570a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010570d:	8d 42 01             	lea    0x1(%edx),%eax
80105710:	89 45 0c             	mov    %eax,0xc(%ebp)
80105713:	8b 45 08             	mov    0x8(%ebp),%eax
80105716:	8d 48 01             	lea    0x1(%eax),%ecx
80105719:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010571c:	0f b6 12             	movzbl (%edx),%edx
8010571f:	88 10                	mov    %dl,(%eax)
80105721:	0f b6 00             	movzbl (%eax),%eax
80105724:	84 c0                	test   %al,%al
80105726:	75 d5                	jne    801056fd <strncpy+0x11>
    ;
  while(n-- > 0)
80105728:	eb 0c                	jmp    80105736 <strncpy+0x4a>
    *s++ = 0;
8010572a:	8b 45 08             	mov    0x8(%ebp),%eax
8010572d:	8d 50 01             	lea    0x1(%eax),%edx
80105730:	89 55 08             	mov    %edx,0x8(%ebp)
80105733:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105736:	8b 45 10             	mov    0x10(%ebp),%eax
80105739:	8d 50 ff             	lea    -0x1(%eax),%edx
8010573c:	89 55 10             	mov    %edx,0x10(%ebp)
8010573f:	85 c0                	test   %eax,%eax
80105741:	7f e7                	jg     8010572a <strncpy+0x3e>
  return os;
80105743:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105746:	c9                   	leave  
80105747:	c3                   	ret    

80105748 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105748:	f3 0f 1e fb          	endbr32 
8010574c:	55                   	push   %ebp
8010574d:	89 e5                	mov    %esp,%ebp
8010574f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105752:	8b 45 08             	mov    0x8(%ebp),%eax
80105755:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105758:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010575c:	7f 05                	jg     80105763 <safestrcpy+0x1b>
    return os;
8010575e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105761:	eb 31                	jmp    80105794 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105763:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105767:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010576b:	7e 1e                	jle    8010578b <safestrcpy+0x43>
8010576d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105770:	8d 42 01             	lea    0x1(%edx),%eax
80105773:	89 45 0c             	mov    %eax,0xc(%ebp)
80105776:	8b 45 08             	mov    0x8(%ebp),%eax
80105779:	8d 48 01             	lea    0x1(%eax),%ecx
8010577c:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010577f:	0f b6 12             	movzbl (%edx),%edx
80105782:	88 10                	mov    %dl,(%eax)
80105784:	0f b6 00             	movzbl (%eax),%eax
80105787:	84 c0                	test   %al,%al
80105789:	75 d8                	jne    80105763 <safestrcpy+0x1b>
    ;
  *s = 0;
8010578b:	8b 45 08             	mov    0x8(%ebp),%eax
8010578e:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105791:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105794:	c9                   	leave  
80105795:	c3                   	ret    

80105796 <strlen>:

int
strlen(const char *s)
{
80105796:	f3 0f 1e fb          	endbr32 
8010579a:	55                   	push   %ebp
8010579b:	89 e5                	mov    %esp,%ebp
8010579d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801057a0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057a7:	eb 04                	jmp    801057ad <strlen+0x17>
801057a9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057ad:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057b0:	8b 45 08             	mov    0x8(%ebp),%eax
801057b3:	01 d0                	add    %edx,%eax
801057b5:	0f b6 00             	movzbl (%eax),%eax
801057b8:	84 c0                	test   %al,%al
801057ba:	75 ed                	jne    801057a9 <strlen+0x13>
    ;
  return n;
801057bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057bf:	c9                   	leave  
801057c0:	c3                   	ret    

801057c1 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801057c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801057c5:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801057c9:	55                   	push   %ebp
  pushl %ebx
801057ca:	53                   	push   %ebx
  pushl %esi
801057cb:	56                   	push   %esi
  pushl %edi
801057cc:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801057cd:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801057cf:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801057d1:	5f                   	pop    %edi
  popl %esi
801057d2:	5e                   	pop    %esi
  popl %ebx
801057d3:	5b                   	pop    %ebx
  popl %ebp
801057d4:	5d                   	pop    %ebp
  ret
801057d5:	c3                   	ret    

801057d6 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801057d6:	f3 0f 1e fb          	endbr32 
801057da:	55                   	push   %ebp
801057db:	89 e5                	mov    %esp,%ebp
801057dd:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801057e0:	e8 b1 ec ff ff       	call   80104496 <myproc>
801057e5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801057e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057eb:	8b 00                	mov    (%eax),%eax
801057ed:	39 45 08             	cmp    %eax,0x8(%ebp)
801057f0:	73 0f                	jae    80105801 <fetchint+0x2b>
801057f2:	8b 45 08             	mov    0x8(%ebp),%eax
801057f5:	8d 50 04             	lea    0x4(%eax),%edx
801057f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057fb:	8b 00                	mov    (%eax),%eax
801057fd:	39 c2                	cmp    %eax,%edx
801057ff:	76 07                	jbe    80105808 <fetchint+0x32>
    return -1;
80105801:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105806:	eb 0f                	jmp    80105817 <fetchint+0x41>
  *ip = *(int*)(addr);
80105808:	8b 45 08             	mov    0x8(%ebp),%eax
8010580b:	8b 10                	mov    (%eax),%edx
8010580d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105810:	89 10                	mov    %edx,(%eax)
  return 0;
80105812:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105817:	c9                   	leave  
80105818:	c3                   	ret    

80105819 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105819:	f3 0f 1e fb          	endbr32 
8010581d:	55                   	push   %ebp
8010581e:	89 e5                	mov    %esp,%ebp
80105820:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105823:	e8 6e ec ff ff       	call   80104496 <myproc>
80105828:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010582b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010582e:	8b 00                	mov    (%eax),%eax
80105830:	39 45 08             	cmp    %eax,0x8(%ebp)
80105833:	72 07                	jb     8010583c <fetchstr+0x23>
    return -1;
80105835:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010583a:	eb 43                	jmp    8010587f <fetchstr+0x66>
  *pp = (char*)addr;
8010583c:	8b 55 08             	mov    0x8(%ebp),%edx
8010583f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105842:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105844:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105847:	8b 00                	mov    (%eax),%eax
80105849:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010584c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010584f:	8b 00                	mov    (%eax),%eax
80105851:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105854:	eb 1c                	jmp    80105872 <fetchstr+0x59>
    if(*s == 0)
80105856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105859:	0f b6 00             	movzbl (%eax),%eax
8010585c:	84 c0                	test   %al,%al
8010585e:	75 0e                	jne    8010586e <fetchstr+0x55>
      return s - *pp;
80105860:	8b 45 0c             	mov    0xc(%ebp),%eax
80105863:	8b 00                	mov    (%eax),%eax
80105865:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105868:	29 c2                	sub    %eax,%edx
8010586a:	89 d0                	mov    %edx,%eax
8010586c:	eb 11                	jmp    8010587f <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
8010586e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105875:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105878:	72 dc                	jb     80105856 <fetchstr+0x3d>
  }
  return -1;
8010587a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010587f:	c9                   	leave  
80105880:	c3                   	ret    

80105881 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105881:	f3 0f 1e fb          	endbr32 
80105885:	55                   	push   %ebp
80105886:	89 e5                	mov    %esp,%ebp
80105888:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010588b:	e8 06 ec ff ff       	call   80104496 <myproc>
80105890:	8b 40 1c             	mov    0x1c(%eax),%eax
80105893:	8b 40 44             	mov    0x44(%eax),%eax
80105896:	8b 55 08             	mov    0x8(%ebp),%edx
80105899:	c1 e2 02             	shl    $0x2,%edx
8010589c:	01 d0                	add    %edx,%eax
8010589e:	83 c0 04             	add    $0x4,%eax
801058a1:	83 ec 08             	sub    $0x8,%esp
801058a4:	ff 75 0c             	pushl  0xc(%ebp)
801058a7:	50                   	push   %eax
801058a8:	e8 29 ff ff ff       	call   801057d6 <fetchint>
801058ad:	83 c4 10             	add    $0x10,%esp
}
801058b0:	c9                   	leave  
801058b1:	c3                   	ret    

801058b2 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801058b2:	f3 0f 1e fb          	endbr32 
801058b6:	55                   	push   %ebp
801058b7:	89 e5                	mov    %esp,%ebp
801058b9:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801058bc:	e8 d5 eb ff ff       	call   80104496 <myproc>
801058c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801058c4:	83 ec 08             	sub    $0x8,%esp
801058c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058ca:	50                   	push   %eax
801058cb:	ff 75 08             	pushl  0x8(%ebp)
801058ce:	e8 ae ff ff ff       	call   80105881 <argint>
801058d3:	83 c4 10             	add    $0x10,%esp
801058d6:	85 c0                	test   %eax,%eax
801058d8:	79 07                	jns    801058e1 <argptr+0x2f>
    return -1;
801058da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058df:	eb 3b                	jmp    8010591c <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801058e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058e5:	78 1f                	js     80105906 <argptr+0x54>
801058e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ea:	8b 00                	mov    (%eax),%eax
801058ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058ef:	39 d0                	cmp    %edx,%eax
801058f1:	76 13                	jbe    80105906 <argptr+0x54>
801058f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f6:	89 c2                	mov    %eax,%edx
801058f8:	8b 45 10             	mov    0x10(%ebp),%eax
801058fb:	01 c2                	add    %eax,%edx
801058fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105900:	8b 00                	mov    (%eax),%eax
80105902:	39 c2                	cmp    %eax,%edx
80105904:	76 07                	jbe    8010590d <argptr+0x5b>
    return -1;
80105906:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010590b:	eb 0f                	jmp    8010591c <argptr+0x6a>
  *pp = (char*)i;
8010590d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105910:	89 c2                	mov    %eax,%edx
80105912:	8b 45 0c             	mov    0xc(%ebp),%eax
80105915:	89 10                	mov    %edx,(%eax)
  return 0;
80105917:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010591c:	c9                   	leave  
8010591d:	c3                   	ret    

8010591e <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010591e:	f3 0f 1e fb          	endbr32 
80105922:	55                   	push   %ebp
80105923:	89 e5                	mov    %esp,%ebp
80105925:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105928:	83 ec 08             	sub    $0x8,%esp
8010592b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010592e:	50                   	push   %eax
8010592f:	ff 75 08             	pushl  0x8(%ebp)
80105932:	e8 4a ff ff ff       	call   80105881 <argint>
80105937:	83 c4 10             	add    $0x10,%esp
8010593a:	85 c0                	test   %eax,%eax
8010593c:	79 07                	jns    80105945 <argstr+0x27>
    return -1;
8010593e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105943:	eb 12                	jmp    80105957 <argstr+0x39>
  return fetchstr(addr, pp);
80105945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105948:	83 ec 08             	sub    $0x8,%esp
8010594b:	ff 75 0c             	pushl  0xc(%ebp)
8010594e:	50                   	push   %eax
8010594f:	e8 c5 fe ff ff       	call   80105819 <fetchstr>
80105954:	83 c4 10             	add    $0x10,%esp
}
80105957:	c9                   	leave  
80105958:	c3                   	ret    

80105959 <syscall>:
[SYS_dump_rawphymem] sys_dump_rawphymem,
};

void
syscall(void)
{
80105959:	f3 0f 1e fb          	endbr32 
8010595d:	55                   	push   %ebp
8010595e:	89 e5                	mov    %esp,%ebp
80105960:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105963:	e8 2e eb ff ff       	call   80104496 <myproc>
80105968:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010596b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010596e:	8b 40 1c             	mov    0x1c(%eax),%eax
80105971:	8b 40 1c             	mov    0x1c(%eax),%eax
80105974:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105977:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010597b:	7e 2f                	jle    801059ac <syscall+0x53>
8010597d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105980:	83 f8 18             	cmp    $0x18,%eax
80105983:	77 27                	ja     801059ac <syscall+0x53>
80105985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105988:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
8010598f:	85 c0                	test   %eax,%eax
80105991:	74 19                	je     801059ac <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105993:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105996:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
8010599d:	ff d0                	call   *%eax
8010599f:	89 c2                	mov    %eax,%edx
801059a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a4:	8b 40 1c             	mov    0x1c(%eax),%eax
801059a7:	89 50 1c             	mov    %edx,0x1c(%eax)
801059aa:	eb 2c                	jmp    801059d8 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801059ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059af:	8d 50 70             	lea    0x70(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801059b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b5:	8b 40 10             	mov    0x10(%eax),%eax
801059b8:	ff 75 f0             	pushl  -0x10(%ebp)
801059bb:	52                   	push   %edx
801059bc:	50                   	push   %eax
801059bd:	68 08 95 10 80       	push   $0x80109508
801059c2:	e8 51 aa ff ff       	call   80100418 <cprintf>
801059c7:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801059ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cd:	8b 40 1c             	mov    0x1c(%eax),%eax
801059d0:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801059d7:	90                   	nop
801059d8:	90                   	nop
801059d9:	c9                   	leave  
801059da:	c3                   	ret    

801059db <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801059db:	f3 0f 1e fb          	endbr32 
801059df:	55                   	push   %ebp
801059e0:	89 e5                	mov    %esp,%ebp
801059e2:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801059e5:	83 ec 08             	sub    $0x8,%esp
801059e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059eb:	50                   	push   %eax
801059ec:	ff 75 08             	pushl  0x8(%ebp)
801059ef:	e8 8d fe ff ff       	call   80105881 <argint>
801059f4:	83 c4 10             	add    $0x10,%esp
801059f7:	85 c0                	test   %eax,%eax
801059f9:	79 07                	jns    80105a02 <argfd+0x27>
    return -1;
801059fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a00:	eb 4f                	jmp    80105a51 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a05:	85 c0                	test   %eax,%eax
80105a07:	78 20                	js     80105a29 <argfd+0x4e>
80105a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a0c:	83 f8 0f             	cmp    $0xf,%eax
80105a0f:	7f 18                	jg     80105a29 <argfd+0x4e>
80105a11:	e8 80 ea ff ff       	call   80104496 <myproc>
80105a16:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a19:	83 c2 08             	add    $0x8,%edx
80105a1c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105a20:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a27:	75 07                	jne    80105a30 <argfd+0x55>
    return -1;
80105a29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a2e:	eb 21                	jmp    80105a51 <argfd+0x76>
  if(pfd)
80105a30:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a34:	74 08                	je     80105a3e <argfd+0x63>
    *pfd = fd;
80105a36:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a39:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a3c:	89 10                	mov    %edx,(%eax)
  if(pf)
80105a3e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a42:	74 08                	je     80105a4c <argfd+0x71>
    *pf = f;
80105a44:	8b 45 10             	mov    0x10(%ebp),%eax
80105a47:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a4a:	89 10                	mov    %edx,(%eax)
  return 0;
80105a4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a51:	c9                   	leave  
80105a52:	c3                   	ret    

80105a53 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105a53:	f3 0f 1e fb          	endbr32 
80105a57:	55                   	push   %ebp
80105a58:	89 e5                	mov    %esp,%ebp
80105a5a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105a5d:	e8 34 ea ff ff       	call   80104496 <myproc>
80105a62:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105a65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105a6c:	eb 2a                	jmp    80105a98 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a71:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a74:	83 c2 08             	add    $0x8,%edx
80105a77:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105a7b:	85 c0                	test   %eax,%eax
80105a7d:	75 15                	jne    80105a94 <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a85:	8d 4a 08             	lea    0x8(%edx),%ecx
80105a88:	8b 55 08             	mov    0x8(%ebp),%edx
80105a8b:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
      return fd;
80105a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a92:	eb 0f                	jmp    80105aa3 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105a94:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105a98:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105a9c:	7e d0                	jle    80105a6e <fdalloc+0x1b>
    }
  }
  return -1;
80105a9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105aa3:	c9                   	leave  
80105aa4:	c3                   	ret    

80105aa5 <sys_dup>:

int
sys_dup(void)
{
80105aa5:	f3 0f 1e fb          	endbr32 
80105aa9:	55                   	push   %ebp
80105aaa:	89 e5                	mov    %esp,%ebp
80105aac:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105aaf:	83 ec 04             	sub    $0x4,%esp
80105ab2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ab5:	50                   	push   %eax
80105ab6:	6a 00                	push   $0x0
80105ab8:	6a 00                	push   $0x0
80105aba:	e8 1c ff ff ff       	call   801059db <argfd>
80105abf:	83 c4 10             	add    $0x10,%esp
80105ac2:	85 c0                	test   %eax,%eax
80105ac4:	79 07                	jns    80105acd <sys_dup+0x28>
    return -1;
80105ac6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105acb:	eb 31                	jmp    80105afe <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad0:	83 ec 0c             	sub    $0xc,%esp
80105ad3:	50                   	push   %eax
80105ad4:	e8 7a ff ff ff       	call   80105a53 <fdalloc>
80105ad9:	83 c4 10             	add    $0x10,%esp
80105adc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105adf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ae3:	79 07                	jns    80105aec <sys_dup+0x47>
    return -1;
80105ae5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aea:	eb 12                	jmp    80105afe <sys_dup+0x59>
  filedup(f);
80105aec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aef:	83 ec 0c             	sub    $0xc,%esp
80105af2:	50                   	push   %eax
80105af3:	e8 3b b6 ff ff       	call   80101133 <filedup>
80105af8:	83 c4 10             	add    $0x10,%esp
  return fd;
80105afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105afe:	c9                   	leave  
80105aff:	c3                   	ret    

80105b00 <sys_read>:

int
sys_read(void)
{
80105b00:	f3 0f 1e fb          	endbr32 
80105b04:	55                   	push   %ebp
80105b05:	89 e5                	mov    %esp,%ebp
80105b07:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b0a:	83 ec 04             	sub    $0x4,%esp
80105b0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b10:	50                   	push   %eax
80105b11:	6a 00                	push   $0x0
80105b13:	6a 00                	push   $0x0
80105b15:	e8 c1 fe ff ff       	call   801059db <argfd>
80105b1a:	83 c4 10             	add    $0x10,%esp
80105b1d:	85 c0                	test   %eax,%eax
80105b1f:	78 2e                	js     80105b4f <sys_read+0x4f>
80105b21:	83 ec 08             	sub    $0x8,%esp
80105b24:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b27:	50                   	push   %eax
80105b28:	6a 02                	push   $0x2
80105b2a:	e8 52 fd ff ff       	call   80105881 <argint>
80105b2f:	83 c4 10             	add    $0x10,%esp
80105b32:	85 c0                	test   %eax,%eax
80105b34:	78 19                	js     80105b4f <sys_read+0x4f>
80105b36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b39:	83 ec 04             	sub    $0x4,%esp
80105b3c:	50                   	push   %eax
80105b3d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b40:	50                   	push   %eax
80105b41:	6a 01                	push   $0x1
80105b43:	e8 6a fd ff ff       	call   801058b2 <argptr>
80105b48:	83 c4 10             	add    $0x10,%esp
80105b4b:	85 c0                	test   %eax,%eax
80105b4d:	79 07                	jns    80105b56 <sys_read+0x56>
    return -1;
80105b4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b54:	eb 17                	jmp    80105b6d <sys_read+0x6d>
  return fileread(f, p, n);
80105b56:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b59:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b5f:	83 ec 04             	sub    $0x4,%esp
80105b62:	51                   	push   %ecx
80105b63:	52                   	push   %edx
80105b64:	50                   	push   %eax
80105b65:	e8 65 b7 ff ff       	call   801012cf <fileread>
80105b6a:	83 c4 10             	add    $0x10,%esp
}
80105b6d:	c9                   	leave  
80105b6e:	c3                   	ret    

80105b6f <sys_write>:

int
sys_write(void)
{
80105b6f:	f3 0f 1e fb          	endbr32 
80105b73:	55                   	push   %ebp
80105b74:	89 e5                	mov    %esp,%ebp
80105b76:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b79:	83 ec 04             	sub    $0x4,%esp
80105b7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b7f:	50                   	push   %eax
80105b80:	6a 00                	push   $0x0
80105b82:	6a 00                	push   $0x0
80105b84:	e8 52 fe ff ff       	call   801059db <argfd>
80105b89:	83 c4 10             	add    $0x10,%esp
80105b8c:	85 c0                	test   %eax,%eax
80105b8e:	78 2e                	js     80105bbe <sys_write+0x4f>
80105b90:	83 ec 08             	sub    $0x8,%esp
80105b93:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b96:	50                   	push   %eax
80105b97:	6a 02                	push   $0x2
80105b99:	e8 e3 fc ff ff       	call   80105881 <argint>
80105b9e:	83 c4 10             	add    $0x10,%esp
80105ba1:	85 c0                	test   %eax,%eax
80105ba3:	78 19                	js     80105bbe <sys_write+0x4f>
80105ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba8:	83 ec 04             	sub    $0x4,%esp
80105bab:	50                   	push   %eax
80105bac:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105baf:	50                   	push   %eax
80105bb0:	6a 01                	push   $0x1
80105bb2:	e8 fb fc ff ff       	call   801058b2 <argptr>
80105bb7:	83 c4 10             	add    $0x10,%esp
80105bba:	85 c0                	test   %eax,%eax
80105bbc:	79 07                	jns    80105bc5 <sys_write+0x56>
    return -1;
80105bbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bc3:	eb 17                	jmp    80105bdc <sys_write+0x6d>
  return filewrite(f, p, n);
80105bc5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105bc8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bce:	83 ec 04             	sub    $0x4,%esp
80105bd1:	51                   	push   %ecx
80105bd2:	52                   	push   %edx
80105bd3:	50                   	push   %eax
80105bd4:	e8 b2 b7 ff ff       	call   8010138b <filewrite>
80105bd9:	83 c4 10             	add    $0x10,%esp
}
80105bdc:	c9                   	leave  
80105bdd:	c3                   	ret    

80105bde <sys_close>:

int
sys_close(void)
{
80105bde:	f3 0f 1e fb          	endbr32 
80105be2:	55                   	push   %ebp
80105be3:	89 e5                	mov    %esp,%ebp
80105be5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105be8:	83 ec 04             	sub    $0x4,%esp
80105beb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bee:	50                   	push   %eax
80105bef:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bf2:	50                   	push   %eax
80105bf3:	6a 00                	push   $0x0
80105bf5:	e8 e1 fd ff ff       	call   801059db <argfd>
80105bfa:	83 c4 10             	add    $0x10,%esp
80105bfd:	85 c0                	test   %eax,%eax
80105bff:	79 07                	jns    80105c08 <sys_close+0x2a>
    return -1;
80105c01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c06:	eb 27                	jmp    80105c2f <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105c08:	e8 89 e8 ff ff       	call   80104496 <myproc>
80105c0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c10:	83 c2 08             	add    $0x8,%edx
80105c13:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80105c1a:	00 
  fileclose(f);
80105c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1e:	83 ec 0c             	sub    $0xc,%esp
80105c21:	50                   	push   %eax
80105c22:	e8 61 b5 ff ff       	call   80101188 <fileclose>
80105c27:	83 c4 10             	add    $0x10,%esp
  return 0;
80105c2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c2f:	c9                   	leave  
80105c30:	c3                   	ret    

80105c31 <sys_fstat>:

int
sys_fstat(void)
{
80105c31:	f3 0f 1e fb          	endbr32 
80105c35:	55                   	push   %ebp
80105c36:	89 e5                	mov    %esp,%ebp
80105c38:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105c3b:	83 ec 04             	sub    $0x4,%esp
80105c3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c41:	50                   	push   %eax
80105c42:	6a 00                	push   $0x0
80105c44:	6a 00                	push   $0x0
80105c46:	e8 90 fd ff ff       	call   801059db <argfd>
80105c4b:	83 c4 10             	add    $0x10,%esp
80105c4e:	85 c0                	test   %eax,%eax
80105c50:	78 17                	js     80105c69 <sys_fstat+0x38>
80105c52:	83 ec 04             	sub    $0x4,%esp
80105c55:	6a 14                	push   $0x14
80105c57:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c5a:	50                   	push   %eax
80105c5b:	6a 01                	push   $0x1
80105c5d:	e8 50 fc ff ff       	call   801058b2 <argptr>
80105c62:	83 c4 10             	add    $0x10,%esp
80105c65:	85 c0                	test   %eax,%eax
80105c67:	79 07                	jns    80105c70 <sys_fstat+0x3f>
    return -1;
80105c69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c6e:	eb 13                	jmp    80105c83 <sys_fstat+0x52>
  return filestat(f, st);
80105c70:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c76:	83 ec 08             	sub    $0x8,%esp
80105c79:	52                   	push   %edx
80105c7a:	50                   	push   %eax
80105c7b:	e8 f4 b5 ff ff       	call   80101274 <filestat>
80105c80:	83 c4 10             	add    $0x10,%esp
}
80105c83:	c9                   	leave  
80105c84:	c3                   	ret    

80105c85 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105c85:	f3 0f 1e fb          	endbr32 
80105c89:	55                   	push   %ebp
80105c8a:	89 e5                	mov    %esp,%ebp
80105c8c:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105c8f:	83 ec 08             	sub    $0x8,%esp
80105c92:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105c95:	50                   	push   %eax
80105c96:	6a 00                	push   $0x0
80105c98:	e8 81 fc ff ff       	call   8010591e <argstr>
80105c9d:	83 c4 10             	add    $0x10,%esp
80105ca0:	85 c0                	test   %eax,%eax
80105ca2:	78 15                	js     80105cb9 <sys_link+0x34>
80105ca4:	83 ec 08             	sub    $0x8,%esp
80105ca7:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105caa:	50                   	push   %eax
80105cab:	6a 01                	push   $0x1
80105cad:	e8 6c fc ff ff       	call   8010591e <argstr>
80105cb2:	83 c4 10             	add    $0x10,%esp
80105cb5:	85 c0                	test   %eax,%eax
80105cb7:	79 0a                	jns    80105cc3 <sys_link+0x3e>
    return -1;
80105cb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cbe:	e9 68 01 00 00       	jmp    80105e2b <sys_link+0x1a6>

  begin_op();
80105cc3:	e8 0f da ff ff       	call   801036d7 <begin_op>
  if((ip = namei(old)) == 0){
80105cc8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105ccb:	83 ec 0c             	sub    $0xc,%esp
80105cce:	50                   	push   %eax
80105ccf:	e8 9f c9 ff ff       	call   80102673 <namei>
80105cd4:	83 c4 10             	add    $0x10,%esp
80105cd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cda:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cde:	75 0f                	jne    80105cef <sys_link+0x6a>
    end_op();
80105ce0:	e8 82 da ff ff       	call   80103767 <end_op>
    return -1;
80105ce5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cea:	e9 3c 01 00 00       	jmp    80105e2b <sys_link+0x1a6>
  }

  ilock(ip);
80105cef:	83 ec 0c             	sub    $0xc,%esp
80105cf2:	ff 75 f4             	pushl  -0xc(%ebp)
80105cf5:	e8 0e be ff ff       	call   80101b08 <ilock>
80105cfa:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d00:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d04:	66 83 f8 01          	cmp    $0x1,%ax
80105d08:	75 1d                	jne    80105d27 <sys_link+0xa2>
    iunlockput(ip);
80105d0a:	83 ec 0c             	sub    $0xc,%esp
80105d0d:	ff 75 f4             	pushl  -0xc(%ebp)
80105d10:	e8 30 c0 ff ff       	call   80101d45 <iunlockput>
80105d15:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d18:	e8 4a da ff ff       	call   80103767 <end_op>
    return -1;
80105d1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d22:	e9 04 01 00 00       	jmp    80105e2b <sys_link+0x1a6>
  }

  ip->nlink++;
80105d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d2e:	83 c0 01             	add    $0x1,%eax
80105d31:	89 c2                	mov    %eax,%edx
80105d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d36:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d3a:	83 ec 0c             	sub    $0xc,%esp
80105d3d:	ff 75 f4             	pushl  -0xc(%ebp)
80105d40:	e8 da bb ff ff       	call   8010191f <iupdate>
80105d45:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105d48:	83 ec 0c             	sub    $0xc,%esp
80105d4b:	ff 75 f4             	pushl  -0xc(%ebp)
80105d4e:	e8 cc be ff ff       	call   80101c1f <iunlock>
80105d53:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105d56:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105d59:	83 ec 08             	sub    $0x8,%esp
80105d5c:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105d5f:	52                   	push   %edx
80105d60:	50                   	push   %eax
80105d61:	e8 2d c9 ff ff       	call   80102693 <nameiparent>
80105d66:	83 c4 10             	add    $0x10,%esp
80105d69:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d6c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d70:	74 71                	je     80105de3 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105d72:	83 ec 0c             	sub    $0xc,%esp
80105d75:	ff 75 f0             	pushl  -0x10(%ebp)
80105d78:	e8 8b bd ff ff       	call   80101b08 <ilock>
80105d7d:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105d80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d83:	8b 10                	mov    (%eax),%edx
80105d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d88:	8b 00                	mov    (%eax),%eax
80105d8a:	39 c2                	cmp    %eax,%edx
80105d8c:	75 1d                	jne    80105dab <sys_link+0x126>
80105d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d91:	8b 40 04             	mov    0x4(%eax),%eax
80105d94:	83 ec 04             	sub    $0x4,%esp
80105d97:	50                   	push   %eax
80105d98:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105d9b:	50                   	push   %eax
80105d9c:	ff 75 f0             	pushl  -0x10(%ebp)
80105d9f:	e8 2c c6 ff ff       	call   801023d0 <dirlink>
80105da4:	83 c4 10             	add    $0x10,%esp
80105da7:	85 c0                	test   %eax,%eax
80105da9:	79 10                	jns    80105dbb <sys_link+0x136>
    iunlockput(dp);
80105dab:	83 ec 0c             	sub    $0xc,%esp
80105dae:	ff 75 f0             	pushl  -0x10(%ebp)
80105db1:	e8 8f bf ff ff       	call   80101d45 <iunlockput>
80105db6:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105db9:	eb 29                	jmp    80105de4 <sys_link+0x15f>
  }
  iunlockput(dp);
80105dbb:	83 ec 0c             	sub    $0xc,%esp
80105dbe:	ff 75 f0             	pushl  -0x10(%ebp)
80105dc1:	e8 7f bf ff ff       	call   80101d45 <iunlockput>
80105dc6:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105dc9:	83 ec 0c             	sub    $0xc,%esp
80105dcc:	ff 75 f4             	pushl  -0xc(%ebp)
80105dcf:	e8 9d be ff ff       	call   80101c71 <iput>
80105dd4:	83 c4 10             	add    $0x10,%esp

  end_op();
80105dd7:	e8 8b d9 ff ff       	call   80103767 <end_op>

  return 0;
80105ddc:	b8 00 00 00 00       	mov    $0x0,%eax
80105de1:	eb 48                	jmp    80105e2b <sys_link+0x1a6>
    goto bad;
80105de3:	90                   	nop

bad:
  ilock(ip);
80105de4:	83 ec 0c             	sub    $0xc,%esp
80105de7:	ff 75 f4             	pushl  -0xc(%ebp)
80105dea:	e8 19 bd ff ff       	call   80101b08 <ilock>
80105def:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df5:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105df9:	83 e8 01             	sub    $0x1,%eax
80105dfc:	89 c2                	mov    %eax,%edx
80105dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e01:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e05:	83 ec 0c             	sub    $0xc,%esp
80105e08:	ff 75 f4             	pushl  -0xc(%ebp)
80105e0b:	e8 0f bb ff ff       	call   8010191f <iupdate>
80105e10:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e13:	83 ec 0c             	sub    $0xc,%esp
80105e16:	ff 75 f4             	pushl  -0xc(%ebp)
80105e19:	e8 27 bf ff ff       	call   80101d45 <iunlockput>
80105e1e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e21:	e8 41 d9 ff ff       	call   80103767 <end_op>
  return -1;
80105e26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e2b:	c9                   	leave  
80105e2c:	c3                   	ret    

80105e2d <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105e2d:	f3 0f 1e fb          	endbr32 
80105e31:	55                   	push   %ebp
80105e32:	89 e5                	mov    %esp,%ebp
80105e34:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e37:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105e3e:	eb 40                	jmp    80105e80 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e43:	6a 10                	push   $0x10
80105e45:	50                   	push   %eax
80105e46:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e49:	50                   	push   %eax
80105e4a:	ff 75 08             	pushl  0x8(%ebp)
80105e4d:	e8 be c1 ff ff       	call   80102010 <readi>
80105e52:	83 c4 10             	add    $0x10,%esp
80105e55:	83 f8 10             	cmp    $0x10,%eax
80105e58:	74 0d                	je     80105e67 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105e5a:	83 ec 0c             	sub    $0xc,%esp
80105e5d:	68 24 95 10 80       	push   $0x80109524
80105e62:	e8 a1 a7 ff ff       	call   80100608 <panic>
    if(de.inum != 0)
80105e67:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105e6b:	66 85 c0             	test   %ax,%ax
80105e6e:	74 07                	je     80105e77 <isdirempty+0x4a>
      return 0;
80105e70:	b8 00 00 00 00       	mov    $0x0,%eax
80105e75:	eb 1b                	jmp    80105e92 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7a:	83 c0 10             	add    $0x10,%eax
80105e7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e80:	8b 45 08             	mov    0x8(%ebp),%eax
80105e83:	8b 50 58             	mov    0x58(%eax),%edx
80105e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e89:	39 c2                	cmp    %eax,%edx
80105e8b:	77 b3                	ja     80105e40 <isdirempty+0x13>
  }
  return 1;
80105e8d:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105e92:	c9                   	leave  
80105e93:	c3                   	ret    

80105e94 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105e94:	f3 0f 1e fb          	endbr32 
80105e98:	55                   	push   %ebp
80105e99:	89 e5                	mov    %esp,%ebp
80105e9b:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105e9e:	83 ec 08             	sub    $0x8,%esp
80105ea1:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105ea4:	50                   	push   %eax
80105ea5:	6a 00                	push   $0x0
80105ea7:	e8 72 fa ff ff       	call   8010591e <argstr>
80105eac:	83 c4 10             	add    $0x10,%esp
80105eaf:	85 c0                	test   %eax,%eax
80105eb1:	79 0a                	jns    80105ebd <sys_unlink+0x29>
    return -1;
80105eb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eb8:	e9 bf 01 00 00       	jmp    8010607c <sys_unlink+0x1e8>

  begin_op();
80105ebd:	e8 15 d8 ff ff       	call   801036d7 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105ec2:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105ec5:	83 ec 08             	sub    $0x8,%esp
80105ec8:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105ecb:	52                   	push   %edx
80105ecc:	50                   	push   %eax
80105ecd:	e8 c1 c7 ff ff       	call   80102693 <nameiparent>
80105ed2:	83 c4 10             	add    $0x10,%esp
80105ed5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ed8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105edc:	75 0f                	jne    80105eed <sys_unlink+0x59>
    end_op();
80105ede:	e8 84 d8 ff ff       	call   80103767 <end_op>
    return -1;
80105ee3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ee8:	e9 8f 01 00 00       	jmp    8010607c <sys_unlink+0x1e8>
  }

  ilock(dp);
80105eed:	83 ec 0c             	sub    $0xc,%esp
80105ef0:	ff 75 f4             	pushl  -0xc(%ebp)
80105ef3:	e8 10 bc ff ff       	call   80101b08 <ilock>
80105ef8:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105efb:	83 ec 08             	sub    $0x8,%esp
80105efe:	68 36 95 10 80       	push   $0x80109536
80105f03:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f06:	50                   	push   %eax
80105f07:	e8 e7 c3 ff ff       	call   801022f3 <namecmp>
80105f0c:	83 c4 10             	add    $0x10,%esp
80105f0f:	85 c0                	test   %eax,%eax
80105f11:	0f 84 49 01 00 00    	je     80106060 <sys_unlink+0x1cc>
80105f17:	83 ec 08             	sub    $0x8,%esp
80105f1a:	68 38 95 10 80       	push   $0x80109538
80105f1f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f22:	50                   	push   %eax
80105f23:	e8 cb c3 ff ff       	call   801022f3 <namecmp>
80105f28:	83 c4 10             	add    $0x10,%esp
80105f2b:	85 c0                	test   %eax,%eax
80105f2d:	0f 84 2d 01 00 00    	je     80106060 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105f33:	83 ec 04             	sub    $0x4,%esp
80105f36:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105f39:	50                   	push   %eax
80105f3a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f3d:	50                   	push   %eax
80105f3e:	ff 75 f4             	pushl  -0xc(%ebp)
80105f41:	e8 cc c3 ff ff       	call   80102312 <dirlookup>
80105f46:	83 c4 10             	add    $0x10,%esp
80105f49:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f4c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f50:	0f 84 0d 01 00 00    	je     80106063 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105f56:	83 ec 0c             	sub    $0xc,%esp
80105f59:	ff 75 f0             	pushl  -0x10(%ebp)
80105f5c:	e8 a7 bb ff ff       	call   80101b08 <ilock>
80105f61:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f67:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f6b:	66 85 c0             	test   %ax,%ax
80105f6e:	7f 0d                	jg     80105f7d <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105f70:	83 ec 0c             	sub    $0xc,%esp
80105f73:	68 3b 95 10 80       	push   $0x8010953b
80105f78:	e8 8b a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f80:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f84:	66 83 f8 01          	cmp    $0x1,%ax
80105f88:	75 25                	jne    80105faf <sys_unlink+0x11b>
80105f8a:	83 ec 0c             	sub    $0xc,%esp
80105f8d:	ff 75 f0             	pushl  -0x10(%ebp)
80105f90:	e8 98 fe ff ff       	call   80105e2d <isdirempty>
80105f95:	83 c4 10             	add    $0x10,%esp
80105f98:	85 c0                	test   %eax,%eax
80105f9a:	75 13                	jne    80105faf <sys_unlink+0x11b>
    iunlockput(ip);
80105f9c:	83 ec 0c             	sub    $0xc,%esp
80105f9f:	ff 75 f0             	pushl  -0x10(%ebp)
80105fa2:	e8 9e bd ff ff       	call   80101d45 <iunlockput>
80105fa7:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105faa:	e9 b5 00 00 00       	jmp    80106064 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105faf:	83 ec 04             	sub    $0x4,%esp
80105fb2:	6a 10                	push   $0x10
80105fb4:	6a 00                	push   $0x0
80105fb6:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105fb9:	50                   	push   %eax
80105fba:	e8 6e f5 ff ff       	call   8010552d <memset>
80105fbf:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105fc2:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105fc5:	6a 10                	push   $0x10
80105fc7:	50                   	push   %eax
80105fc8:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105fcb:	50                   	push   %eax
80105fcc:	ff 75 f4             	pushl  -0xc(%ebp)
80105fcf:	e8 95 c1 ff ff       	call   80102169 <writei>
80105fd4:	83 c4 10             	add    $0x10,%esp
80105fd7:	83 f8 10             	cmp    $0x10,%eax
80105fda:	74 0d                	je     80105fe9 <sys_unlink+0x155>
    panic("unlink: writei");
80105fdc:	83 ec 0c             	sub    $0xc,%esp
80105fdf:	68 4d 95 10 80       	push   $0x8010954d
80105fe4:	e8 1f a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR){
80105fe9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fec:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ff0:	66 83 f8 01          	cmp    $0x1,%ax
80105ff4:	75 21                	jne    80106017 <sys_unlink+0x183>
    dp->nlink--;
80105ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ffd:	83 e8 01             	sub    $0x1,%eax
80106000:	89 c2                	mov    %eax,%edx
80106002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106005:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106009:	83 ec 0c             	sub    $0xc,%esp
8010600c:	ff 75 f4             	pushl  -0xc(%ebp)
8010600f:	e8 0b b9 ff ff       	call   8010191f <iupdate>
80106014:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106017:	83 ec 0c             	sub    $0xc,%esp
8010601a:	ff 75 f4             	pushl  -0xc(%ebp)
8010601d:	e8 23 bd ff ff       	call   80101d45 <iunlockput>
80106022:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106025:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106028:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010602c:	83 e8 01             	sub    $0x1,%eax
8010602f:	89 c2                	mov    %eax,%edx
80106031:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106034:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80106038:	83 ec 0c             	sub    $0xc,%esp
8010603b:	ff 75 f0             	pushl  -0x10(%ebp)
8010603e:	e8 dc b8 ff ff       	call   8010191f <iupdate>
80106043:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106046:	83 ec 0c             	sub    $0xc,%esp
80106049:	ff 75 f0             	pushl  -0x10(%ebp)
8010604c:	e8 f4 bc ff ff       	call   80101d45 <iunlockput>
80106051:	83 c4 10             	add    $0x10,%esp

  end_op();
80106054:	e8 0e d7 ff ff       	call   80103767 <end_op>

  return 0;
80106059:	b8 00 00 00 00       	mov    $0x0,%eax
8010605e:	eb 1c                	jmp    8010607c <sys_unlink+0x1e8>
    goto bad;
80106060:	90                   	nop
80106061:	eb 01                	jmp    80106064 <sys_unlink+0x1d0>
    goto bad;
80106063:	90                   	nop

bad:
  iunlockput(dp);
80106064:	83 ec 0c             	sub    $0xc,%esp
80106067:	ff 75 f4             	pushl  -0xc(%ebp)
8010606a:	e8 d6 bc ff ff       	call   80101d45 <iunlockput>
8010606f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106072:	e8 f0 d6 ff ff       	call   80103767 <end_op>
  return -1;
80106077:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010607c:	c9                   	leave  
8010607d:	c3                   	ret    

8010607e <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010607e:	f3 0f 1e fb          	endbr32 
80106082:	55                   	push   %ebp
80106083:	89 e5                	mov    %esp,%ebp
80106085:	83 ec 38             	sub    $0x38,%esp
80106088:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010608b:	8b 55 10             	mov    0x10(%ebp),%edx
8010608e:	8b 45 14             	mov    0x14(%ebp),%eax
80106091:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106095:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106099:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010609d:	83 ec 08             	sub    $0x8,%esp
801060a0:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801060a3:	50                   	push   %eax
801060a4:	ff 75 08             	pushl  0x8(%ebp)
801060a7:	e8 e7 c5 ff ff       	call   80102693 <nameiparent>
801060ac:	83 c4 10             	add    $0x10,%esp
801060af:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060b6:	75 0a                	jne    801060c2 <create+0x44>
    return 0;
801060b8:	b8 00 00 00 00       	mov    $0x0,%eax
801060bd:	e9 8e 01 00 00       	jmp    80106250 <create+0x1d2>
  ilock(dp);
801060c2:	83 ec 0c             	sub    $0xc,%esp
801060c5:	ff 75 f4             	pushl  -0xc(%ebp)
801060c8:	e8 3b ba ff ff       	call   80101b08 <ilock>
801060cd:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
801060d0:	83 ec 04             	sub    $0x4,%esp
801060d3:	6a 00                	push   $0x0
801060d5:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801060d8:	50                   	push   %eax
801060d9:	ff 75 f4             	pushl  -0xc(%ebp)
801060dc:	e8 31 c2 ff ff       	call   80102312 <dirlookup>
801060e1:	83 c4 10             	add    $0x10,%esp
801060e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060eb:	74 50                	je     8010613d <create+0xbf>
    iunlockput(dp);
801060ed:	83 ec 0c             	sub    $0xc,%esp
801060f0:	ff 75 f4             	pushl  -0xc(%ebp)
801060f3:	e8 4d bc ff ff       	call   80101d45 <iunlockput>
801060f8:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801060fb:	83 ec 0c             	sub    $0xc,%esp
801060fe:	ff 75 f0             	pushl  -0x10(%ebp)
80106101:	e8 02 ba ff ff       	call   80101b08 <ilock>
80106106:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106109:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010610e:	75 15                	jne    80106125 <create+0xa7>
80106110:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106113:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106117:	66 83 f8 02          	cmp    $0x2,%ax
8010611b:	75 08                	jne    80106125 <create+0xa7>
      return ip;
8010611d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106120:	e9 2b 01 00 00       	jmp    80106250 <create+0x1d2>
    iunlockput(ip);
80106125:	83 ec 0c             	sub    $0xc,%esp
80106128:	ff 75 f0             	pushl  -0x10(%ebp)
8010612b:	e8 15 bc ff ff       	call   80101d45 <iunlockput>
80106130:	83 c4 10             	add    $0x10,%esp
    return 0;
80106133:	b8 00 00 00 00       	mov    $0x0,%eax
80106138:	e9 13 01 00 00       	jmp    80106250 <create+0x1d2>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010613d:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106144:	8b 00                	mov    (%eax),%eax
80106146:	83 ec 08             	sub    $0x8,%esp
80106149:	52                   	push   %edx
8010614a:	50                   	push   %eax
8010614b:	e8 f4 b6 ff ff       	call   80101844 <ialloc>
80106150:	83 c4 10             	add    $0x10,%esp
80106153:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106156:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010615a:	75 0d                	jne    80106169 <create+0xeb>
    panic("create: ialloc");
8010615c:	83 ec 0c             	sub    $0xc,%esp
8010615f:	68 5c 95 10 80       	push   $0x8010955c
80106164:	e8 9f a4 ff ff       	call   80100608 <panic>

  ilock(ip);
80106169:	83 ec 0c             	sub    $0xc,%esp
8010616c:	ff 75 f0             	pushl  -0x10(%ebp)
8010616f:	e8 94 b9 ff ff       	call   80101b08 <ilock>
80106174:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617a:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010617e:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80106182:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106185:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106189:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
8010618d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106190:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106196:	83 ec 0c             	sub    $0xc,%esp
80106199:	ff 75 f0             	pushl  -0x10(%ebp)
8010619c:	e8 7e b7 ff ff       	call   8010191f <iupdate>
801061a1:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801061a4:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801061a9:	75 6a                	jne    80106215 <create+0x197>
    dp->nlink++;  // for ".."
801061ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ae:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801061b2:	83 c0 01             	add    $0x1,%eax
801061b5:	89 c2                	mov    %eax,%edx
801061b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ba:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801061be:	83 ec 0c             	sub    $0xc,%esp
801061c1:	ff 75 f4             	pushl  -0xc(%ebp)
801061c4:	e8 56 b7 ff ff       	call   8010191f <iupdate>
801061c9:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801061cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061cf:	8b 40 04             	mov    0x4(%eax),%eax
801061d2:	83 ec 04             	sub    $0x4,%esp
801061d5:	50                   	push   %eax
801061d6:	68 36 95 10 80       	push   $0x80109536
801061db:	ff 75 f0             	pushl  -0x10(%ebp)
801061de:	e8 ed c1 ff ff       	call   801023d0 <dirlink>
801061e3:	83 c4 10             	add    $0x10,%esp
801061e6:	85 c0                	test   %eax,%eax
801061e8:	78 1e                	js     80106208 <create+0x18a>
801061ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ed:	8b 40 04             	mov    0x4(%eax),%eax
801061f0:	83 ec 04             	sub    $0x4,%esp
801061f3:	50                   	push   %eax
801061f4:	68 38 95 10 80       	push   $0x80109538
801061f9:	ff 75 f0             	pushl  -0x10(%ebp)
801061fc:	e8 cf c1 ff ff       	call   801023d0 <dirlink>
80106201:	83 c4 10             	add    $0x10,%esp
80106204:	85 c0                	test   %eax,%eax
80106206:	79 0d                	jns    80106215 <create+0x197>
      panic("create dots");
80106208:	83 ec 0c             	sub    $0xc,%esp
8010620b:	68 6b 95 10 80       	push   $0x8010956b
80106210:	e8 f3 a3 ff ff       	call   80100608 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106215:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106218:	8b 40 04             	mov    0x4(%eax),%eax
8010621b:	83 ec 04             	sub    $0x4,%esp
8010621e:	50                   	push   %eax
8010621f:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106222:	50                   	push   %eax
80106223:	ff 75 f4             	pushl  -0xc(%ebp)
80106226:	e8 a5 c1 ff ff       	call   801023d0 <dirlink>
8010622b:	83 c4 10             	add    $0x10,%esp
8010622e:	85 c0                	test   %eax,%eax
80106230:	79 0d                	jns    8010623f <create+0x1c1>
    panic("create: dirlink");
80106232:	83 ec 0c             	sub    $0xc,%esp
80106235:	68 77 95 10 80       	push   $0x80109577
8010623a:	e8 c9 a3 ff ff       	call   80100608 <panic>

  iunlockput(dp);
8010623f:	83 ec 0c             	sub    $0xc,%esp
80106242:	ff 75 f4             	pushl  -0xc(%ebp)
80106245:	e8 fb ba ff ff       	call   80101d45 <iunlockput>
8010624a:	83 c4 10             	add    $0x10,%esp

  return ip;
8010624d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106250:	c9                   	leave  
80106251:	c3                   	ret    

80106252 <sys_open>:

int
sys_open(void)
{
80106252:	f3 0f 1e fb          	endbr32 
80106256:	55                   	push   %ebp
80106257:	89 e5                	mov    %esp,%ebp
80106259:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010625c:	83 ec 08             	sub    $0x8,%esp
8010625f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106262:	50                   	push   %eax
80106263:	6a 00                	push   $0x0
80106265:	e8 b4 f6 ff ff       	call   8010591e <argstr>
8010626a:	83 c4 10             	add    $0x10,%esp
8010626d:	85 c0                	test   %eax,%eax
8010626f:	78 15                	js     80106286 <sys_open+0x34>
80106271:	83 ec 08             	sub    $0x8,%esp
80106274:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106277:	50                   	push   %eax
80106278:	6a 01                	push   $0x1
8010627a:	e8 02 f6 ff ff       	call   80105881 <argint>
8010627f:	83 c4 10             	add    $0x10,%esp
80106282:	85 c0                	test   %eax,%eax
80106284:	79 0a                	jns    80106290 <sys_open+0x3e>
    return -1;
80106286:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010628b:	e9 61 01 00 00       	jmp    801063f1 <sys_open+0x19f>

  begin_op();
80106290:	e8 42 d4 ff ff       	call   801036d7 <begin_op>

  if(omode & O_CREATE){
80106295:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106298:	25 00 02 00 00       	and    $0x200,%eax
8010629d:	85 c0                	test   %eax,%eax
8010629f:	74 2a                	je     801062cb <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
801062a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062a4:	6a 00                	push   $0x0
801062a6:	6a 00                	push   $0x0
801062a8:	6a 02                	push   $0x2
801062aa:	50                   	push   %eax
801062ab:	e8 ce fd ff ff       	call   8010607e <create>
801062b0:	83 c4 10             	add    $0x10,%esp
801062b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801062b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062ba:	75 75                	jne    80106331 <sys_open+0xdf>
      end_op();
801062bc:	e8 a6 d4 ff ff       	call   80103767 <end_op>
      return -1;
801062c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c6:	e9 26 01 00 00       	jmp    801063f1 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
801062cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062ce:	83 ec 0c             	sub    $0xc,%esp
801062d1:	50                   	push   %eax
801062d2:	e8 9c c3 ff ff       	call   80102673 <namei>
801062d7:	83 c4 10             	add    $0x10,%esp
801062da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062e1:	75 0f                	jne    801062f2 <sys_open+0xa0>
      end_op();
801062e3:	e8 7f d4 ff ff       	call   80103767 <end_op>
      return -1;
801062e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ed:	e9 ff 00 00 00       	jmp    801063f1 <sys_open+0x19f>
    }
    ilock(ip);
801062f2:	83 ec 0c             	sub    $0xc,%esp
801062f5:	ff 75 f4             	pushl  -0xc(%ebp)
801062f8:	e8 0b b8 ff ff       	call   80101b08 <ilock>
801062fd:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106303:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106307:	66 83 f8 01          	cmp    $0x1,%ax
8010630b:	75 24                	jne    80106331 <sys_open+0xdf>
8010630d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106310:	85 c0                	test   %eax,%eax
80106312:	74 1d                	je     80106331 <sys_open+0xdf>
      iunlockput(ip);
80106314:	83 ec 0c             	sub    $0xc,%esp
80106317:	ff 75 f4             	pushl  -0xc(%ebp)
8010631a:	e8 26 ba ff ff       	call   80101d45 <iunlockput>
8010631f:	83 c4 10             	add    $0x10,%esp
      end_op();
80106322:	e8 40 d4 ff ff       	call   80103767 <end_op>
      return -1;
80106327:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010632c:	e9 c0 00 00 00       	jmp    801063f1 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106331:	e8 8c ad ff ff       	call   801010c2 <filealloc>
80106336:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106339:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010633d:	74 17                	je     80106356 <sys_open+0x104>
8010633f:	83 ec 0c             	sub    $0xc,%esp
80106342:	ff 75 f0             	pushl  -0x10(%ebp)
80106345:	e8 09 f7 ff ff       	call   80105a53 <fdalloc>
8010634a:	83 c4 10             	add    $0x10,%esp
8010634d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106350:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106354:	79 2e                	jns    80106384 <sys_open+0x132>
    if(f)
80106356:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010635a:	74 0e                	je     8010636a <sys_open+0x118>
      fileclose(f);
8010635c:	83 ec 0c             	sub    $0xc,%esp
8010635f:	ff 75 f0             	pushl  -0x10(%ebp)
80106362:	e8 21 ae ff ff       	call   80101188 <fileclose>
80106367:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010636a:	83 ec 0c             	sub    $0xc,%esp
8010636d:	ff 75 f4             	pushl  -0xc(%ebp)
80106370:	e8 d0 b9 ff ff       	call   80101d45 <iunlockput>
80106375:	83 c4 10             	add    $0x10,%esp
    end_op();
80106378:	e8 ea d3 ff ff       	call   80103767 <end_op>
    return -1;
8010637d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106382:	eb 6d                	jmp    801063f1 <sys_open+0x19f>
  }
  iunlock(ip);
80106384:	83 ec 0c             	sub    $0xc,%esp
80106387:	ff 75 f4             	pushl  -0xc(%ebp)
8010638a:	e8 90 b8 ff ff       	call   80101c1f <iunlock>
8010638f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106392:	e8 d0 d3 ff ff       	call   80103767 <end_op>

  f->type = FD_INODE;
80106397:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010639a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801063a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063a6:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801063a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ac:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801063b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063b6:	83 e0 01             	and    $0x1,%eax
801063b9:	85 c0                	test   %eax,%eax
801063bb:	0f 94 c0             	sete   %al
801063be:	89 c2                	mov    %eax,%edx
801063c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c3:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801063c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063c9:	83 e0 01             	and    $0x1,%eax
801063cc:	85 c0                	test   %eax,%eax
801063ce:	75 0a                	jne    801063da <sys_open+0x188>
801063d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063d3:	83 e0 02             	and    $0x2,%eax
801063d6:	85 c0                	test   %eax,%eax
801063d8:	74 07                	je     801063e1 <sys_open+0x18f>
801063da:	b8 01 00 00 00       	mov    $0x1,%eax
801063df:	eb 05                	jmp    801063e6 <sys_open+0x194>
801063e1:	b8 00 00 00 00       	mov    $0x0,%eax
801063e6:	89 c2                	mov    %eax,%edx
801063e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063eb:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801063ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801063f1:	c9                   	leave  
801063f2:	c3                   	ret    

801063f3 <sys_mkdir>:

int
sys_mkdir(void)
{
801063f3:	f3 0f 1e fb          	endbr32 
801063f7:	55                   	push   %ebp
801063f8:	89 e5                	mov    %esp,%ebp
801063fa:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801063fd:	e8 d5 d2 ff ff       	call   801036d7 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106402:	83 ec 08             	sub    $0x8,%esp
80106405:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106408:	50                   	push   %eax
80106409:	6a 00                	push   $0x0
8010640b:	e8 0e f5 ff ff       	call   8010591e <argstr>
80106410:	83 c4 10             	add    $0x10,%esp
80106413:	85 c0                	test   %eax,%eax
80106415:	78 1b                	js     80106432 <sys_mkdir+0x3f>
80106417:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010641a:	6a 00                	push   $0x0
8010641c:	6a 00                	push   $0x0
8010641e:	6a 01                	push   $0x1
80106420:	50                   	push   %eax
80106421:	e8 58 fc ff ff       	call   8010607e <create>
80106426:	83 c4 10             	add    $0x10,%esp
80106429:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010642c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106430:	75 0c                	jne    8010643e <sys_mkdir+0x4b>
    end_op();
80106432:	e8 30 d3 ff ff       	call   80103767 <end_op>
    return -1;
80106437:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010643c:	eb 18                	jmp    80106456 <sys_mkdir+0x63>
  }
  iunlockput(ip);
8010643e:	83 ec 0c             	sub    $0xc,%esp
80106441:	ff 75 f4             	pushl  -0xc(%ebp)
80106444:	e8 fc b8 ff ff       	call   80101d45 <iunlockput>
80106449:	83 c4 10             	add    $0x10,%esp
  end_op();
8010644c:	e8 16 d3 ff ff       	call   80103767 <end_op>
  return 0;
80106451:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106456:	c9                   	leave  
80106457:	c3                   	ret    

80106458 <sys_mknod>:

int
sys_mknod(void)
{
80106458:	f3 0f 1e fb          	endbr32 
8010645c:	55                   	push   %ebp
8010645d:	89 e5                	mov    %esp,%ebp
8010645f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106462:	e8 70 d2 ff ff       	call   801036d7 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106467:	83 ec 08             	sub    $0x8,%esp
8010646a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010646d:	50                   	push   %eax
8010646e:	6a 00                	push   $0x0
80106470:	e8 a9 f4 ff ff       	call   8010591e <argstr>
80106475:	83 c4 10             	add    $0x10,%esp
80106478:	85 c0                	test   %eax,%eax
8010647a:	78 4f                	js     801064cb <sys_mknod+0x73>
     argint(1, &major) < 0 ||
8010647c:	83 ec 08             	sub    $0x8,%esp
8010647f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106482:	50                   	push   %eax
80106483:	6a 01                	push   $0x1
80106485:	e8 f7 f3 ff ff       	call   80105881 <argint>
8010648a:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
8010648d:	85 c0                	test   %eax,%eax
8010648f:	78 3a                	js     801064cb <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80106491:	83 ec 08             	sub    $0x8,%esp
80106494:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106497:	50                   	push   %eax
80106498:	6a 02                	push   $0x2
8010649a:	e8 e2 f3 ff ff       	call   80105881 <argint>
8010649f:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801064a2:	85 c0                	test   %eax,%eax
801064a4:	78 25                	js     801064cb <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
801064a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064a9:	0f bf c8             	movswl %ax,%ecx
801064ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064af:	0f bf d0             	movswl %ax,%edx
801064b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064b5:	51                   	push   %ecx
801064b6:	52                   	push   %edx
801064b7:	6a 03                	push   $0x3
801064b9:	50                   	push   %eax
801064ba:	e8 bf fb ff ff       	call   8010607e <create>
801064bf:	83 c4 10             	add    $0x10,%esp
801064c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801064c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064c9:	75 0c                	jne    801064d7 <sys_mknod+0x7f>
    end_op();
801064cb:	e8 97 d2 ff ff       	call   80103767 <end_op>
    return -1;
801064d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064d5:	eb 18                	jmp    801064ef <sys_mknod+0x97>
  }
  iunlockput(ip);
801064d7:	83 ec 0c             	sub    $0xc,%esp
801064da:	ff 75 f4             	pushl  -0xc(%ebp)
801064dd:	e8 63 b8 ff ff       	call   80101d45 <iunlockput>
801064e2:	83 c4 10             	add    $0x10,%esp
  end_op();
801064e5:	e8 7d d2 ff ff       	call   80103767 <end_op>
  return 0;
801064ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064ef:	c9                   	leave  
801064f0:	c3                   	ret    

801064f1 <sys_chdir>:

int
sys_chdir(void)
{
801064f1:	f3 0f 1e fb          	endbr32 
801064f5:	55                   	push   %ebp
801064f6:	89 e5                	mov    %esp,%ebp
801064f8:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801064fb:	e8 96 df ff ff       	call   80104496 <myproc>
80106500:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106503:	e8 cf d1 ff ff       	call   801036d7 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106508:	83 ec 08             	sub    $0x8,%esp
8010650b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010650e:	50                   	push   %eax
8010650f:	6a 00                	push   $0x0
80106511:	e8 08 f4 ff ff       	call   8010591e <argstr>
80106516:	83 c4 10             	add    $0x10,%esp
80106519:	85 c0                	test   %eax,%eax
8010651b:	78 18                	js     80106535 <sys_chdir+0x44>
8010651d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106520:	83 ec 0c             	sub    $0xc,%esp
80106523:	50                   	push   %eax
80106524:	e8 4a c1 ff ff       	call   80102673 <namei>
80106529:	83 c4 10             	add    $0x10,%esp
8010652c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010652f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106533:	75 0c                	jne    80106541 <sys_chdir+0x50>
    end_op();
80106535:	e8 2d d2 ff ff       	call   80103767 <end_op>
    return -1;
8010653a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010653f:	eb 68                	jmp    801065a9 <sys_chdir+0xb8>
  }
  ilock(ip);
80106541:	83 ec 0c             	sub    $0xc,%esp
80106544:	ff 75 f0             	pushl  -0x10(%ebp)
80106547:	e8 bc b5 ff ff       	call   80101b08 <ilock>
8010654c:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010654f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106552:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106556:	66 83 f8 01          	cmp    $0x1,%ax
8010655a:	74 1a                	je     80106576 <sys_chdir+0x85>
    iunlockput(ip);
8010655c:	83 ec 0c             	sub    $0xc,%esp
8010655f:	ff 75 f0             	pushl  -0x10(%ebp)
80106562:	e8 de b7 ff ff       	call   80101d45 <iunlockput>
80106567:	83 c4 10             	add    $0x10,%esp
    end_op();
8010656a:	e8 f8 d1 ff ff       	call   80103767 <end_op>
    return -1;
8010656f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106574:	eb 33                	jmp    801065a9 <sys_chdir+0xb8>
  }
  iunlock(ip);
80106576:	83 ec 0c             	sub    $0xc,%esp
80106579:	ff 75 f0             	pushl  -0x10(%ebp)
8010657c:	e8 9e b6 ff ff       	call   80101c1f <iunlock>
80106581:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80106584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106587:	8b 40 6c             	mov    0x6c(%eax),%eax
8010658a:	83 ec 0c             	sub    $0xc,%esp
8010658d:	50                   	push   %eax
8010658e:	e8 de b6 ff ff       	call   80101c71 <iput>
80106593:	83 c4 10             	add    $0x10,%esp
  end_op();
80106596:	e8 cc d1 ff ff       	call   80103767 <end_op>
  curproc->cwd = ip;
8010659b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010659e:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065a1:	89 50 6c             	mov    %edx,0x6c(%eax)
  return 0;
801065a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065a9:	c9                   	leave  
801065aa:	c3                   	ret    

801065ab <sys_exec>:

int
sys_exec(void)
{
801065ab:	f3 0f 1e fb          	endbr32 
801065af:	55                   	push   %ebp
801065b0:	89 e5                	mov    %esp,%ebp
801065b2:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801065b8:	83 ec 08             	sub    $0x8,%esp
801065bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065be:	50                   	push   %eax
801065bf:	6a 00                	push   $0x0
801065c1:	e8 58 f3 ff ff       	call   8010591e <argstr>
801065c6:	83 c4 10             	add    $0x10,%esp
801065c9:	85 c0                	test   %eax,%eax
801065cb:	78 18                	js     801065e5 <sys_exec+0x3a>
801065cd:	83 ec 08             	sub    $0x8,%esp
801065d0:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801065d6:	50                   	push   %eax
801065d7:	6a 01                	push   $0x1
801065d9:	e8 a3 f2 ff ff       	call   80105881 <argint>
801065de:	83 c4 10             	add    $0x10,%esp
801065e1:	85 c0                	test   %eax,%eax
801065e3:	79 0a                	jns    801065ef <sys_exec+0x44>
    return -1;
801065e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ea:	e9 c6 00 00 00       	jmp    801066b5 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
801065ef:	83 ec 04             	sub    $0x4,%esp
801065f2:	68 80 00 00 00       	push   $0x80
801065f7:	6a 00                	push   $0x0
801065f9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801065ff:	50                   	push   %eax
80106600:	e8 28 ef ff ff       	call   8010552d <memset>
80106605:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106608:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010660f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106612:	83 f8 1f             	cmp    $0x1f,%eax
80106615:	76 0a                	jbe    80106621 <sys_exec+0x76>
      return -1;
80106617:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010661c:	e9 94 00 00 00       	jmp    801066b5 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106624:	c1 e0 02             	shl    $0x2,%eax
80106627:	89 c2                	mov    %eax,%edx
80106629:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010662f:	01 c2                	add    %eax,%edx
80106631:	83 ec 08             	sub    $0x8,%esp
80106634:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010663a:	50                   	push   %eax
8010663b:	52                   	push   %edx
8010663c:	e8 95 f1 ff ff       	call   801057d6 <fetchint>
80106641:	83 c4 10             	add    $0x10,%esp
80106644:	85 c0                	test   %eax,%eax
80106646:	79 07                	jns    8010664f <sys_exec+0xa4>
      return -1;
80106648:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010664d:	eb 66                	jmp    801066b5 <sys_exec+0x10a>
    if(uarg == 0){
8010664f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106655:	85 c0                	test   %eax,%eax
80106657:	75 27                	jne    80106680 <sys_exec+0xd5>
      argv[i] = 0;
80106659:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010665c:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106663:	00 00 00 00 
      break;
80106667:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106668:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010666b:	83 ec 08             	sub    $0x8,%esp
8010666e:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106674:	52                   	push   %edx
80106675:	50                   	push   %eax
80106676:	e8 b5 a5 ff ff       	call   80100c30 <exec>
8010667b:	83 c4 10             	add    $0x10,%esp
8010667e:	eb 35                	jmp    801066b5 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80106680:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106686:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106689:	c1 e2 02             	shl    $0x2,%edx
8010668c:	01 c2                	add    %eax,%edx
8010668e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106694:	83 ec 08             	sub    $0x8,%esp
80106697:	52                   	push   %edx
80106698:	50                   	push   %eax
80106699:	e8 7b f1 ff ff       	call   80105819 <fetchstr>
8010669e:	83 c4 10             	add    $0x10,%esp
801066a1:	85 c0                	test   %eax,%eax
801066a3:	79 07                	jns    801066ac <sys_exec+0x101>
      return -1;
801066a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066aa:	eb 09                	jmp    801066b5 <sys_exec+0x10a>
  for(i=0;; i++){
801066ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801066b0:	e9 5a ff ff ff       	jmp    8010660f <sys_exec+0x64>
}
801066b5:	c9                   	leave  
801066b6:	c3                   	ret    

801066b7 <sys_pipe>:

int
sys_pipe(void)
{
801066b7:	f3 0f 1e fb          	endbr32 
801066bb:	55                   	push   %ebp
801066bc:	89 e5                	mov    %esp,%ebp
801066be:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801066c1:	83 ec 04             	sub    $0x4,%esp
801066c4:	6a 08                	push   $0x8
801066c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066c9:	50                   	push   %eax
801066ca:	6a 00                	push   $0x0
801066cc:	e8 e1 f1 ff ff       	call   801058b2 <argptr>
801066d1:	83 c4 10             	add    $0x10,%esp
801066d4:	85 c0                	test   %eax,%eax
801066d6:	79 0a                	jns    801066e2 <sys_pipe+0x2b>
    return -1;
801066d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066dd:	e9 ae 00 00 00       	jmp    80106790 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
801066e2:	83 ec 08             	sub    $0x8,%esp
801066e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801066e8:	50                   	push   %eax
801066e9:	8d 45 e8             	lea    -0x18(%ebp),%eax
801066ec:	50                   	push   %eax
801066ed:	e8 c5 d8 ff ff       	call   80103fb7 <pipealloc>
801066f2:	83 c4 10             	add    $0x10,%esp
801066f5:	85 c0                	test   %eax,%eax
801066f7:	79 0a                	jns    80106703 <sys_pipe+0x4c>
    return -1;
801066f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066fe:	e9 8d 00 00 00       	jmp    80106790 <sys_pipe+0xd9>
  fd0 = -1;
80106703:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010670a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010670d:	83 ec 0c             	sub    $0xc,%esp
80106710:	50                   	push   %eax
80106711:	e8 3d f3 ff ff       	call   80105a53 <fdalloc>
80106716:	83 c4 10             	add    $0x10,%esp
80106719:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010671c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106720:	78 18                	js     8010673a <sys_pipe+0x83>
80106722:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106725:	83 ec 0c             	sub    $0xc,%esp
80106728:	50                   	push   %eax
80106729:	e8 25 f3 ff ff       	call   80105a53 <fdalloc>
8010672e:	83 c4 10             	add    $0x10,%esp
80106731:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106734:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106738:	79 3e                	jns    80106778 <sys_pipe+0xc1>
    if(fd0 >= 0)
8010673a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010673e:	78 13                	js     80106753 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106740:	e8 51 dd ff ff       	call   80104496 <myproc>
80106745:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106748:	83 c2 08             	add    $0x8,%edx
8010674b:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80106752:	00 
    fileclose(rf);
80106753:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106756:	83 ec 0c             	sub    $0xc,%esp
80106759:	50                   	push   %eax
8010675a:	e8 29 aa ff ff       	call   80101188 <fileclose>
8010675f:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106762:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106765:	83 ec 0c             	sub    $0xc,%esp
80106768:	50                   	push   %eax
80106769:	e8 1a aa ff ff       	call   80101188 <fileclose>
8010676e:	83 c4 10             	add    $0x10,%esp
    return -1;
80106771:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106776:	eb 18                	jmp    80106790 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80106778:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010677b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010677e:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106780:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106783:	8d 50 04             	lea    0x4(%eax),%edx
80106786:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106789:	89 02                	mov    %eax,(%edx)
  return 0;
8010678b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106790:	c9                   	leave  
80106791:	c3                   	ret    

80106792 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106792:	f3 0f 1e fb          	endbr32 
80106796:	55                   	push   %ebp
80106797:	89 e5                	mov    %esp,%ebp
80106799:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010679c:	e8 a3 e0 ff ff       	call   80104844 <fork>
}
801067a1:	c9                   	leave  
801067a2:	c3                   	ret    

801067a3 <sys_exit>:

int
sys_exit(void)
{
801067a3:	f3 0f 1e fb          	endbr32 
801067a7:	55                   	push   %ebp
801067a8:	89 e5                	mov    %esp,%ebp
801067aa:	83 ec 08             	sub    $0x8,%esp
  exit();
801067ad:	e8 18 e2 ff ff       	call   801049ca <exit>
  return 0;  // not reached
801067b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067b7:	c9                   	leave  
801067b8:	c3                   	ret    

801067b9 <sys_wait>:

int
sys_wait(void)
{
801067b9:	f3 0f 1e fb          	endbr32 
801067bd:	55                   	push   %ebp
801067be:	89 e5                	mov    %esp,%ebp
801067c0:	83 ec 08             	sub    $0x8,%esp
  return wait();
801067c3:	e8 29 e3 ff ff       	call   80104af1 <wait>
}
801067c8:	c9                   	leave  
801067c9:	c3                   	ret    

801067ca <sys_kill>:

int
sys_kill(void)
{
801067ca:	f3 0f 1e fb          	endbr32 
801067ce:	55                   	push   %ebp
801067cf:	89 e5                	mov    %esp,%ebp
801067d1:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801067d4:	83 ec 08             	sub    $0x8,%esp
801067d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067da:	50                   	push   %eax
801067db:	6a 00                	push   $0x0
801067dd:	e8 9f f0 ff ff       	call   80105881 <argint>
801067e2:	83 c4 10             	add    $0x10,%esp
801067e5:	85 c0                	test   %eax,%eax
801067e7:	79 07                	jns    801067f0 <sys_kill+0x26>
    return -1;
801067e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067ee:	eb 0f                	jmp    801067ff <sys_kill+0x35>
  return kill(pid);
801067f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f3:	83 ec 0c             	sub    $0xc,%esp
801067f6:	50                   	push   %eax
801067f7:	e8 4d e7 ff ff       	call   80104f49 <kill>
801067fc:	83 c4 10             	add    $0x10,%esp
}
801067ff:	c9                   	leave  
80106800:	c3                   	ret    

80106801 <sys_getpid>:

int
sys_getpid(void)
{
80106801:	f3 0f 1e fb          	endbr32 
80106805:	55                   	push   %ebp
80106806:	89 e5                	mov    %esp,%ebp
80106808:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010680b:	e8 86 dc ff ff       	call   80104496 <myproc>
80106810:	8b 40 10             	mov    0x10(%eax),%eax
}
80106813:	c9                   	leave  
80106814:	c3                   	ret    

80106815 <sys_sbrk>:

int
sys_sbrk(void)
{
80106815:	f3 0f 1e fb          	endbr32 
80106819:	55                   	push   %ebp
8010681a:	89 e5                	mov    %esp,%ebp
8010681c:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010681f:	83 ec 08             	sub    $0x8,%esp
80106822:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106825:	50                   	push   %eax
80106826:	6a 00                	push   $0x0
80106828:	e8 54 f0 ff ff       	call   80105881 <argint>
8010682d:	83 c4 10             	add    $0x10,%esp
80106830:	85 c0                	test   %eax,%eax
80106832:	79 07                	jns    8010683b <sys_sbrk+0x26>
    return -1;
80106834:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106839:	eb 27                	jmp    80106862 <sys_sbrk+0x4d>
  addr = myproc()->sz;
8010683b:	e8 56 dc ff ff       	call   80104496 <myproc>
80106840:	8b 00                	mov    (%eax),%eax
80106842:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106845:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106848:	83 ec 0c             	sub    $0xc,%esp
8010684b:	50                   	push   %eax
8010684c:	e8 e6 de ff ff       	call   80104737 <growproc>
80106851:	83 c4 10             	add    $0x10,%esp
80106854:	85 c0                	test   %eax,%eax
80106856:	79 07                	jns    8010685f <sys_sbrk+0x4a>
    return -1;
80106858:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010685d:	eb 03                	jmp    80106862 <sys_sbrk+0x4d>
  return addr;
8010685f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106862:	c9                   	leave  
80106863:	c3                   	ret    

80106864 <sys_sleep>:

int
sys_sleep(void)
{
80106864:	f3 0f 1e fb          	endbr32 
80106868:	55                   	push   %ebp
80106869:	89 e5                	mov    %esp,%ebp
8010686b:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010686e:	83 ec 08             	sub    $0x8,%esp
80106871:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106874:	50                   	push   %eax
80106875:	6a 00                	push   $0x0
80106877:	e8 05 f0 ff ff       	call   80105881 <argint>
8010687c:	83 c4 10             	add    $0x10,%esp
8010687f:	85 c0                	test   %eax,%eax
80106881:	79 07                	jns    8010688a <sys_sleep+0x26>
    return -1;
80106883:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106888:	eb 76                	jmp    80106900 <sys_sleep+0x9c>
  acquire(&tickslock);
8010688a:	83 ec 0c             	sub    $0xc,%esp
8010688d:	68 00 81 11 80       	push   $0x80118100
80106892:	e8 f7 e9 ff ff       	call   8010528e <acquire>
80106897:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010689a:	a1 40 89 11 80       	mov    0x80118940,%eax
8010689f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801068a2:	eb 38                	jmp    801068dc <sys_sleep+0x78>
    if(myproc()->killed){
801068a4:	e8 ed db ff ff       	call   80104496 <myproc>
801068a9:	8b 40 28             	mov    0x28(%eax),%eax
801068ac:	85 c0                	test   %eax,%eax
801068ae:	74 17                	je     801068c7 <sys_sleep+0x63>
      release(&tickslock);
801068b0:	83 ec 0c             	sub    $0xc,%esp
801068b3:	68 00 81 11 80       	push   $0x80118100
801068b8:	e8 43 ea ff ff       	call   80105300 <release>
801068bd:	83 c4 10             	add    $0x10,%esp
      return -1;
801068c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068c5:	eb 39                	jmp    80106900 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
801068c7:	83 ec 08             	sub    $0x8,%esp
801068ca:	68 00 81 11 80       	push   $0x80118100
801068cf:	68 40 89 11 80       	push   $0x80118940
801068d4:	e8 43 e5 ff ff       	call   80104e1c <sleep>
801068d9:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801068dc:	a1 40 89 11 80       	mov    0x80118940,%eax
801068e1:	2b 45 f4             	sub    -0xc(%ebp),%eax
801068e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801068e7:	39 d0                	cmp    %edx,%eax
801068e9:	72 b9                	jb     801068a4 <sys_sleep+0x40>
  }
  release(&tickslock);
801068eb:	83 ec 0c             	sub    $0xc,%esp
801068ee:	68 00 81 11 80       	push   $0x80118100
801068f3:	e8 08 ea ff ff       	call   80105300 <release>
801068f8:	83 c4 10             	add    $0x10,%esp
  return 0;
801068fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106900:	c9                   	leave  
80106901:	c3                   	ret    

80106902 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106902:	f3 0f 1e fb          	endbr32 
80106906:	55                   	push   %ebp
80106907:	89 e5                	mov    %esp,%ebp
80106909:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010690c:	83 ec 0c             	sub    $0xc,%esp
8010690f:	68 00 81 11 80       	push   $0x80118100
80106914:	e8 75 e9 ff ff       	call   8010528e <acquire>
80106919:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010691c:	a1 40 89 11 80       	mov    0x80118940,%eax
80106921:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106924:	83 ec 0c             	sub    $0xc,%esp
80106927:	68 00 81 11 80       	push   $0x80118100
8010692c:	e8 cf e9 ff ff       	call   80105300 <release>
80106931:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106934:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106937:	c9                   	leave  
80106938:	c3                   	ret    

80106939 <sys_mencrypt>:

//changed: added wrapper here
int sys_mencrypt(void) {
80106939:	f3 0f 1e fb          	endbr32 
8010693d:	55                   	push   %ebp
8010693e:	89 e5                	mov    %esp,%ebp
80106940:	83 ec 18             	sub    $0x18,%esp
  char * virtual_addr;

  //TODO: what to do if len is 0?

  //dummy size because we're dealing with actual pages here
  if(argint(1, &len) < 0)
80106943:	83 ec 08             	sub    $0x8,%esp
80106946:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106949:	50                   	push   %eax
8010694a:	6a 01                	push   $0x1
8010694c:	e8 30 ef ff ff       	call   80105881 <argint>
80106951:	83 c4 10             	add    $0x10,%esp
80106954:	85 c0                	test   %eax,%eax
80106956:	79 07                	jns    8010695f <sys_mencrypt+0x26>
    return -1;
80106958:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010695d:	eb 5e                	jmp    801069bd <sys_mencrypt+0x84>
  if (len == 0) {
8010695f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106962:	85 c0                	test   %eax,%eax
80106964:	75 07                	jne    8010696d <sys_mencrypt+0x34>
    return 0;
80106966:	b8 00 00 00 00       	mov    $0x0,%eax
8010696b:	eb 50                	jmp    801069bd <sys_mencrypt+0x84>
  }
  if (len < 0) {
8010696d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106970:	85 c0                	test   %eax,%eax
80106972:	79 07                	jns    8010697b <sys_mencrypt+0x42>
    return -1;
80106974:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106979:	eb 42                	jmp    801069bd <sys_mencrypt+0x84>
  }
  if (argptr(0, &virtual_addr, 1) < 0) {
8010697b:	83 ec 04             	sub    $0x4,%esp
8010697e:	6a 01                	push   $0x1
80106980:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106983:	50                   	push   %eax
80106984:	6a 00                	push   $0x0
80106986:	e8 27 ef ff ff       	call   801058b2 <argptr>
8010698b:	83 c4 10             	add    $0x10,%esp
8010698e:	85 c0                	test   %eax,%eax
80106990:	79 07                	jns    80106999 <sys_mencrypt+0x60>
    return -1;
80106992:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106997:	eb 24                	jmp    801069bd <sys_mencrypt+0x84>
  }

  //geq or ge?
  if ((void *) virtual_addr >= (void *)KERNBASE) {
80106999:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010699c:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
801069a1:	76 07                	jbe    801069aa <sys_mencrypt+0x71>
    return -1;
801069a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069a8:	eb 13                	jmp    801069bd <sys_mencrypt+0x84>
  }
  //virtual_addr = (char *)5000;
  return mencrypt((char*)virtual_addr, len);
801069aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069b0:	83 ec 08             	sub    $0x8,%esp
801069b3:	52                   	push   %edx
801069b4:	50                   	push   %eax
801069b5:	e8 28 23 00 00       	call   80108ce2 <mencrypt>
801069ba:	83 c4 10             	add    $0x10,%esp
}
801069bd:	c9                   	leave  
801069be:	c3                   	ret    

801069bf <sys_getpgtable>:

//changed: added wrapper here
int sys_getpgtable(void) {
801069bf:	f3 0f 1e fb          	endbr32 
801069c3:	55                   	push   %ebp
801069c4:	89 e5                	mov    %esp,%ebp
801069c6:	83 ec 18             	sub    $0x18,%esp
  struct pt_entry * entries; 
  int num;
  int wsetOnly;

  if(argint(1, &num) < 0)
801069c9:	83 ec 08             	sub    $0x8,%esp
801069cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069cf:	50                   	push   %eax
801069d0:	6a 01                	push   $0x1
801069d2:	e8 aa ee ff ff       	call   80105881 <argint>
801069d7:	83 c4 10             	add    $0x10,%esp
801069da:	85 c0                	test   %eax,%eax
801069dc:	79 07                	jns    801069e5 <sys_getpgtable+0x26>

    return -1;
801069de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069e3:	eb 56                	jmp    80106a3b <sys_getpgtable+0x7c>


  if(argptr(0, (char**)&entries, num*sizeof(struct pt_entry)) < 0){
801069e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069e8:	c1 e0 03             	shl    $0x3,%eax
801069eb:	83 ec 04             	sub    $0x4,%esp
801069ee:	50                   	push   %eax
801069ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069f2:	50                   	push   %eax
801069f3:	6a 00                	push   $0x0
801069f5:	e8 b8 ee ff ff       	call   801058b2 <argptr>
801069fa:	83 c4 10             	add    $0x10,%esp
801069fd:	85 c0                	test   %eax,%eax
801069ff:	79 07                	jns    80106a08 <sys_getpgtable+0x49>
    return -1;
80106a01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a06:	eb 33                	jmp    80106a3b <sys_getpgtable+0x7c>
  }
  if(argint(2, &wsetOnly) < 0) {
80106a08:	83 ec 08             	sub    $0x8,%esp
80106a0b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a0e:	50                   	push   %eax
80106a0f:	6a 02                	push   $0x2
80106a11:	e8 6b ee ff ff       	call   80105881 <argint>
80106a16:	83 c4 10             	add    $0x10,%esp
80106a19:	85 c0                	test   %eax,%eax
80106a1b:	79 07                	jns    80106a24 <sys_getpgtable+0x65>
    return -1;
80106a1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a22:	eb 17                	jmp    80106a3b <sys_getpgtable+0x7c>
  }
  return getpgtable(entries, num, wsetOnly);
80106a24:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106a27:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a2d:	83 ec 04             	sub    $0x4,%esp
80106a30:	51                   	push   %ecx
80106a31:	52                   	push   %edx
80106a32:	50                   	push   %eax
80106a33:	e8 cd 23 00 00       	call   80108e05 <getpgtable>
80106a38:	83 c4 10             	add    $0x10,%esp
}
80106a3b:	c9                   	leave  
80106a3c:	c3                   	ret    

80106a3d <sys_dump_rawphymem>:

//changed: added wrapper here
int sys_dump_rawphymem(void) {
80106a3d:	f3 0f 1e fb          	endbr32 
80106a41:	55                   	push   %ebp
80106a42:	89 e5                	mov    %esp,%ebp
80106a44:	83 ec 18             	sub    $0x18,%esp
  uint physical_addr; 
  char * buffer;

  if(argptr(1, &buffer, PGSIZE) < 0)
80106a47:	83 ec 04             	sub    $0x4,%esp
80106a4a:	68 00 10 00 00       	push   $0x1000
80106a4f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a52:	50                   	push   %eax
80106a53:	6a 01                	push   $0x1
80106a55:	e8 58 ee ff ff       	call   801058b2 <argptr>
80106a5a:	83 c4 10             	add    $0x10,%esp
80106a5d:	85 c0                	test   %eax,%eax
80106a5f:	79 07                	jns    80106a68 <sys_dump_rawphymem+0x2b>
    return -1;
80106a61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a66:	eb 2f                	jmp    80106a97 <sys_dump_rawphymem+0x5a>

  //dummy size because we're dealing with actual pages here
  if(argint(0, (int*)&physical_addr) < 0)
80106a68:	83 ec 08             	sub    $0x8,%esp
80106a6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a6e:	50                   	push   %eax
80106a6f:	6a 00                	push   $0x0
80106a71:	e8 0b ee ff ff       	call   80105881 <argint>
80106a76:	83 c4 10             	add    $0x10,%esp
80106a79:	85 c0                	test   %eax,%eax
80106a7b:	79 07                	jns    80106a84 <sys_dump_rawphymem+0x47>
    return -1;
80106a7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a82:	eb 13                	jmp    80106a97 <sys_dump_rawphymem+0x5a>

  return dump_rawphymem(physical_addr, buffer);
80106a84:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a8a:	83 ec 08             	sub    $0x8,%esp
80106a8d:	52                   	push   %edx
80106a8e:	50                   	push   %eax
80106a8f:	e8 5d 25 00 00       	call   80108ff1 <dump_rawphymem>
80106a94:	83 c4 10             	add    $0x10,%esp
}
80106a97:	c9                   	leave  
80106a98:	c3                   	ret    

80106a99 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106a99:	1e                   	push   %ds
  pushl %es
80106a9a:	06                   	push   %es
  pushl %fs
80106a9b:	0f a0                	push   %fs
  pushl %gs
80106a9d:	0f a8                	push   %gs
  pushal
80106a9f:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106aa0:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106aa4:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106aa6:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106aa8:	54                   	push   %esp
  call trap
80106aa9:	e8 df 01 00 00       	call   80106c8d <trap>
  addl $4, %esp
80106aae:	83 c4 04             	add    $0x4,%esp

80106ab1 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106ab1:	61                   	popa   
  popl %gs
80106ab2:	0f a9                	pop    %gs
  popl %fs
80106ab4:	0f a1                	pop    %fs
  popl %es
80106ab6:	07                   	pop    %es
  popl %ds
80106ab7:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106ab8:	83 c4 08             	add    $0x8,%esp
  iret
80106abb:	cf                   	iret   

80106abc <lidt>:
{
80106abc:	55                   	push   %ebp
80106abd:	89 e5                	mov    %esp,%ebp
80106abf:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ac5:	83 e8 01             	sub    $0x1,%eax
80106ac8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106acc:	8b 45 08             	mov    0x8(%ebp),%eax
80106acf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ad6:	c1 e8 10             	shr    $0x10,%eax
80106ad9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106add:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106ae0:	0f 01 18             	lidtl  (%eax)
}
80106ae3:	90                   	nop
80106ae4:	c9                   	leave  
80106ae5:	c3                   	ret    

80106ae6 <rcr2>:

static inline uint
rcr2(void)
{
80106ae6:	55                   	push   %ebp
80106ae7:	89 e5                	mov    %esp,%ebp
80106ae9:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106aec:	0f 20 d0             	mov    %cr2,%eax
80106aef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106af2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106af5:	c9                   	leave  
80106af6:	c3                   	ret    

80106af7 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106af7:	f3 0f 1e fb          	endbr32 
80106afb:	55                   	push   %ebp
80106afc:	89 e5                	mov    %esp,%ebp
80106afe:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b08:	e9 c3 00 00 00       	jmp    80106bd0 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b10:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106b17:	89 c2                	mov    %eax,%edx
80106b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b1c:	66 89 14 c5 40 81 11 	mov    %dx,-0x7fee7ec0(,%eax,8)
80106b23:	80 
80106b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b27:	66 c7 04 c5 42 81 11 	movw   $0x8,-0x7fee7ebe(,%eax,8)
80106b2e:	80 08 00 
80106b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b34:	0f b6 14 c5 44 81 11 	movzbl -0x7fee7ebc(,%eax,8),%edx
80106b3b:	80 
80106b3c:	83 e2 e0             	and    $0xffffffe0,%edx
80106b3f:	88 14 c5 44 81 11 80 	mov    %dl,-0x7fee7ebc(,%eax,8)
80106b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b49:	0f b6 14 c5 44 81 11 	movzbl -0x7fee7ebc(,%eax,8),%edx
80106b50:	80 
80106b51:	83 e2 1f             	and    $0x1f,%edx
80106b54:	88 14 c5 44 81 11 80 	mov    %dl,-0x7fee7ebc(,%eax,8)
80106b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b5e:	0f b6 14 c5 45 81 11 	movzbl -0x7fee7ebb(,%eax,8),%edx
80106b65:	80 
80106b66:	83 e2 f0             	and    $0xfffffff0,%edx
80106b69:	83 ca 0e             	or     $0xe,%edx
80106b6c:	88 14 c5 45 81 11 80 	mov    %dl,-0x7fee7ebb(,%eax,8)
80106b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b76:	0f b6 14 c5 45 81 11 	movzbl -0x7fee7ebb(,%eax,8),%edx
80106b7d:	80 
80106b7e:	83 e2 ef             	and    $0xffffffef,%edx
80106b81:	88 14 c5 45 81 11 80 	mov    %dl,-0x7fee7ebb(,%eax,8)
80106b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b8b:	0f b6 14 c5 45 81 11 	movzbl -0x7fee7ebb(,%eax,8),%edx
80106b92:	80 
80106b93:	83 e2 9f             	and    $0xffffff9f,%edx
80106b96:	88 14 c5 45 81 11 80 	mov    %dl,-0x7fee7ebb(,%eax,8)
80106b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba0:	0f b6 14 c5 45 81 11 	movzbl -0x7fee7ebb(,%eax,8),%edx
80106ba7:	80 
80106ba8:	83 ca 80             	or     $0xffffff80,%edx
80106bab:	88 14 c5 45 81 11 80 	mov    %dl,-0x7fee7ebb(,%eax,8)
80106bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb5:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106bbc:	c1 e8 10             	shr    $0x10,%eax
80106bbf:	89 c2                	mov    %eax,%edx
80106bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc4:	66 89 14 c5 46 81 11 	mov    %dx,-0x7fee7eba(,%eax,8)
80106bcb:	80 
  for(i = 0; i < 256; i++)
80106bcc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106bd0:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106bd7:	0f 8e 30 ff ff ff    	jle    80106b0d <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106bdd:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106be2:	66 a3 40 83 11 80    	mov    %ax,0x80118340
80106be8:	66 c7 05 42 83 11 80 	movw   $0x8,0x80118342
80106bef:	08 00 
80106bf1:	0f b6 05 44 83 11 80 	movzbl 0x80118344,%eax
80106bf8:	83 e0 e0             	and    $0xffffffe0,%eax
80106bfb:	a2 44 83 11 80       	mov    %al,0x80118344
80106c00:	0f b6 05 44 83 11 80 	movzbl 0x80118344,%eax
80106c07:	83 e0 1f             	and    $0x1f,%eax
80106c0a:	a2 44 83 11 80       	mov    %al,0x80118344
80106c0f:	0f b6 05 45 83 11 80 	movzbl 0x80118345,%eax
80106c16:	83 c8 0f             	or     $0xf,%eax
80106c19:	a2 45 83 11 80       	mov    %al,0x80118345
80106c1e:	0f b6 05 45 83 11 80 	movzbl 0x80118345,%eax
80106c25:	83 e0 ef             	and    $0xffffffef,%eax
80106c28:	a2 45 83 11 80       	mov    %al,0x80118345
80106c2d:	0f b6 05 45 83 11 80 	movzbl 0x80118345,%eax
80106c34:	83 c8 60             	or     $0x60,%eax
80106c37:	a2 45 83 11 80       	mov    %al,0x80118345
80106c3c:	0f b6 05 45 83 11 80 	movzbl 0x80118345,%eax
80106c43:	83 c8 80             	or     $0xffffff80,%eax
80106c46:	a2 45 83 11 80       	mov    %al,0x80118345
80106c4b:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106c50:	c1 e8 10             	shr    $0x10,%eax
80106c53:	66 a3 46 83 11 80    	mov    %ax,0x80118346

  initlock(&tickslock, "time");
80106c59:	83 ec 08             	sub    $0x8,%esp
80106c5c:	68 88 95 10 80       	push   $0x80109588
80106c61:	68 00 81 11 80       	push   $0x80118100
80106c66:	e8 fd e5 ff ff       	call   80105268 <initlock>
80106c6b:	83 c4 10             	add    $0x10,%esp
}
80106c6e:	90                   	nop
80106c6f:	c9                   	leave  
80106c70:	c3                   	ret    

80106c71 <idtinit>:

void
idtinit(void)
{
80106c71:	f3 0f 1e fb          	endbr32 
80106c75:	55                   	push   %ebp
80106c76:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106c78:	68 00 08 00 00       	push   $0x800
80106c7d:	68 40 81 11 80       	push   $0x80118140
80106c82:	e8 35 fe ff ff       	call   80106abc <lidt>
80106c87:	83 c4 08             	add    $0x8,%esp
}
80106c8a:	90                   	nop
80106c8b:	c9                   	leave  
80106c8c:	c3                   	ret    

80106c8d <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106c8d:	f3 0f 1e fb          	endbr32 
80106c91:	55                   	push   %ebp
80106c92:	89 e5                	mov    %esp,%ebp
80106c94:	57                   	push   %edi
80106c95:	56                   	push   %esi
80106c96:	53                   	push   %ebx
80106c97:	83 ec 2c             	sub    $0x2c,%esp
  //cprintf("in trap\n");
  if(tf->trapno == T_SYSCALL){
80106c9a:	8b 45 08             	mov    0x8(%ebp),%eax
80106c9d:	8b 40 30             	mov    0x30(%eax),%eax
80106ca0:	83 f8 40             	cmp    $0x40,%eax
80106ca3:	75 3b                	jne    80106ce0 <trap+0x53>
    if(myproc()->killed)
80106ca5:	e8 ec d7 ff ff       	call   80104496 <myproc>
80106caa:	8b 40 28             	mov    0x28(%eax),%eax
80106cad:	85 c0                	test   %eax,%eax
80106caf:	74 05                	je     80106cb6 <trap+0x29>
      exit();
80106cb1:	e8 14 dd ff ff       	call   801049ca <exit>
    myproc()->tf = tf;
80106cb6:	e8 db d7 ff ff       	call   80104496 <myproc>
80106cbb:	8b 55 08             	mov    0x8(%ebp),%edx
80106cbe:	89 50 1c             	mov    %edx,0x1c(%eax)
    syscall();
80106cc1:	e8 93 ec ff ff       	call   80105959 <syscall>
    if(myproc()->killed)
80106cc6:	e8 cb d7 ff ff       	call   80104496 <myproc>
80106ccb:	8b 40 28             	mov    0x28(%eax),%eax
80106cce:	85 c0                	test   %eax,%eax
80106cd0:	0f 84 28 02 00 00    	je     80106efe <trap+0x271>
      exit();
80106cd6:	e8 ef dc ff ff       	call   801049ca <exit>
    return;
80106cdb:	e9 1e 02 00 00       	jmp    80106efe <trap+0x271>
  }
  char *addr;
  switch(tf->trapno){
80106ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce3:	8b 40 30             	mov    0x30(%eax),%eax
80106ce6:	83 e8 0e             	sub    $0xe,%eax
80106ce9:	83 f8 31             	cmp    $0x31,%eax
80106cec:	0f 87 d4 00 00 00    	ja     80106dc6 <trap+0x139>
80106cf2:	8b 04 85 30 96 10 80 	mov    -0x7fef69d0(,%eax,4),%eax
80106cf9:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106cfc:	e8 fa d6 ff ff       	call   801043fb <cpuid>
80106d01:	85 c0                	test   %eax,%eax
80106d03:	75 3d                	jne    80106d42 <trap+0xb5>
      acquire(&tickslock);
80106d05:	83 ec 0c             	sub    $0xc,%esp
80106d08:	68 00 81 11 80       	push   $0x80118100
80106d0d:	e8 7c e5 ff ff       	call   8010528e <acquire>
80106d12:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106d15:	a1 40 89 11 80       	mov    0x80118940,%eax
80106d1a:	83 c0 01             	add    $0x1,%eax
80106d1d:	a3 40 89 11 80       	mov    %eax,0x80118940
      wakeup(&ticks);
80106d22:	83 ec 0c             	sub    $0xc,%esp
80106d25:	68 40 89 11 80       	push   $0x80118940
80106d2a:	e8 df e1 ff ff       	call   80104f0e <wakeup>
80106d2f:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106d32:	83 ec 0c             	sub    $0xc,%esp
80106d35:	68 00 81 11 80       	push   $0x80118100
80106d3a:	e8 c1 e5 ff ff       	call   80105300 <release>
80106d3f:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106d42:	e8 44 c4 ff ff       	call   8010318b <lapiceoi>
    break;
80106d47:	e9 32 01 00 00       	jmp    80106e7e <trap+0x1f1>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106d4c:	e8 6f bc ff ff       	call   801029c0 <ideintr>
    lapiceoi();
80106d51:	e8 35 c4 ff ff       	call   8010318b <lapiceoi>
    break;
80106d56:	e9 23 01 00 00       	jmp    80106e7e <trap+0x1f1>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106d5b:	e8 61 c2 ff ff       	call   80102fc1 <kbdintr>
    lapiceoi();
80106d60:	e8 26 c4 ff ff       	call   8010318b <lapiceoi>
    break;
80106d65:	e9 14 01 00 00       	jmp    80106e7e <trap+0x1f1>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106d6a:	e8 71 03 00 00       	call   801070e0 <uartintr>
    lapiceoi();
80106d6f:	e8 17 c4 ff ff       	call   8010318b <lapiceoi>
    break;
80106d74:	e9 05 01 00 00       	jmp    80106e7e <trap+0x1f1>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d79:	8b 45 08             	mov    0x8(%ebp),%eax
80106d7c:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d82:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d86:	0f b7 d8             	movzwl %ax,%ebx
80106d89:	e8 6d d6 ff ff       	call   801043fb <cpuid>
80106d8e:	56                   	push   %esi
80106d8f:	53                   	push   %ebx
80106d90:	50                   	push   %eax
80106d91:	68 90 95 10 80       	push   $0x80109590
80106d96:	e8 7d 96 ff ff       	call   80100418 <cprintf>
80106d9b:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106d9e:	e8 e8 c3 ff ff       	call   8010318b <lapiceoi>
    break;
80106da3:	e9 d6 00 00 00       	jmp    80106e7e <trap+0x1f1>
  case T_PGFLT:
    //get the virtual address that caused the fault
    addr = (char*)rcr2();
80106da8:	e8 39 fd ff ff       	call   80106ae6 <rcr2>
80106dad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (!mdecrypt(addr)) {
80106db0:	83 ec 0c             	sub    $0xc,%esp
80106db3:	ff 75 e4             	pushl  -0x1c(%ebp)
80106db6:	e8 73 1e 00 00       	call   80108c2e <mdecrypt>
80106dbb:	83 c4 10             	add    $0x10,%esp
80106dbe:	85 c0                	test   %eax,%eax
80106dc0:	0f 84 b7 00 00 00    	je     80106e7d <trap+0x1f0>
      //default kills the process
      break;
    };
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106dc6:	e8 cb d6 ff ff       	call   80104496 <myproc>
80106dcb:	85 c0                	test   %eax,%eax
80106dcd:	74 11                	je     80106de0 <trap+0x153>
80106dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80106dd2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106dd6:	0f b7 c0             	movzwl %ax,%eax
80106dd9:	83 e0 03             	and    $0x3,%eax
80106ddc:	85 c0                	test   %eax,%eax
80106dde:	75 39                	jne    80106e19 <trap+0x18c>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106de0:	e8 01 fd ff ff       	call   80106ae6 <rcr2>
80106de5:	89 c3                	mov    %eax,%ebx
80106de7:	8b 45 08             	mov    0x8(%ebp),%eax
80106dea:	8b 70 38             	mov    0x38(%eax),%esi
80106ded:	e8 09 d6 ff ff       	call   801043fb <cpuid>
80106df2:	8b 55 08             	mov    0x8(%ebp),%edx
80106df5:	8b 52 30             	mov    0x30(%edx),%edx
80106df8:	83 ec 0c             	sub    $0xc,%esp
80106dfb:	53                   	push   %ebx
80106dfc:	56                   	push   %esi
80106dfd:	50                   	push   %eax
80106dfe:	52                   	push   %edx
80106dff:	68 b4 95 10 80       	push   $0x801095b4
80106e04:	e8 0f 96 ff ff       	call   80100418 <cprintf>
80106e09:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106e0c:	83 ec 0c             	sub    $0xc,%esp
80106e0f:	68 e6 95 10 80       	push   $0x801095e6
80106e14:	e8 ef 97 ff ff       	call   80100608 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e19:	e8 c8 fc ff ff       	call   80106ae6 <rcr2>
80106e1e:	89 c6                	mov    %eax,%esi
80106e20:	8b 45 08             	mov    0x8(%ebp),%eax
80106e23:	8b 40 38             	mov    0x38(%eax),%eax
80106e26:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106e29:	e8 cd d5 ff ff       	call   801043fb <cpuid>
80106e2e:	89 c3                	mov    %eax,%ebx
80106e30:	8b 45 08             	mov    0x8(%ebp),%eax
80106e33:	8b 48 34             	mov    0x34(%eax),%ecx
80106e36:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106e39:	8b 45 08             	mov    0x8(%ebp),%eax
80106e3c:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106e3f:	e8 52 d6 ff ff       	call   80104496 <myproc>
80106e44:	8d 50 70             	lea    0x70(%eax),%edx
80106e47:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106e4a:	e8 47 d6 ff ff       	call   80104496 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e4f:	8b 40 10             	mov    0x10(%eax),%eax
80106e52:	56                   	push   %esi
80106e53:	ff 75 d4             	pushl  -0x2c(%ebp)
80106e56:	53                   	push   %ebx
80106e57:	ff 75 d0             	pushl  -0x30(%ebp)
80106e5a:	57                   	push   %edi
80106e5b:	ff 75 cc             	pushl  -0x34(%ebp)
80106e5e:	50                   	push   %eax
80106e5f:	68 ec 95 10 80       	push   $0x801095ec
80106e64:	e8 af 95 ff ff       	call   80100418 <cprintf>
80106e69:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106e6c:	e8 25 d6 ff ff       	call   80104496 <myproc>
80106e71:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
80106e78:	eb 04                	jmp    80106e7e <trap+0x1f1>
    break;
80106e7a:	90                   	nop
80106e7b:	eb 01                	jmp    80106e7e <trap+0x1f1>
      break;
80106e7d:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106e7e:	e8 13 d6 ff ff       	call   80104496 <myproc>
80106e83:	85 c0                	test   %eax,%eax
80106e85:	74 23                	je     80106eaa <trap+0x21d>
80106e87:	e8 0a d6 ff ff       	call   80104496 <myproc>
80106e8c:	8b 40 28             	mov    0x28(%eax),%eax
80106e8f:	85 c0                	test   %eax,%eax
80106e91:	74 17                	je     80106eaa <trap+0x21d>
80106e93:	8b 45 08             	mov    0x8(%ebp),%eax
80106e96:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e9a:	0f b7 c0             	movzwl %ax,%eax
80106e9d:	83 e0 03             	and    $0x3,%eax
80106ea0:	83 f8 03             	cmp    $0x3,%eax
80106ea3:	75 05                	jne    80106eaa <trap+0x21d>
    exit();
80106ea5:	e8 20 db ff ff       	call   801049ca <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106eaa:	e8 e7 d5 ff ff       	call   80104496 <myproc>
80106eaf:	85 c0                	test   %eax,%eax
80106eb1:	74 1d                	je     80106ed0 <trap+0x243>
80106eb3:	e8 de d5 ff ff       	call   80104496 <myproc>
80106eb8:	8b 40 0c             	mov    0xc(%eax),%eax
80106ebb:	83 f8 04             	cmp    $0x4,%eax
80106ebe:	75 10                	jne    80106ed0 <trap+0x243>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106ec0:	8b 45 08             	mov    0x8(%ebp),%eax
80106ec3:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106ec6:	83 f8 20             	cmp    $0x20,%eax
80106ec9:	75 05                	jne    80106ed0 <trap+0x243>
    yield();
80106ecb:	e8 c4 de ff ff       	call   80104d94 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106ed0:	e8 c1 d5 ff ff       	call   80104496 <myproc>
80106ed5:	85 c0                	test   %eax,%eax
80106ed7:	74 26                	je     80106eff <trap+0x272>
80106ed9:	e8 b8 d5 ff ff       	call   80104496 <myproc>
80106ede:	8b 40 28             	mov    0x28(%eax),%eax
80106ee1:	85 c0                	test   %eax,%eax
80106ee3:	74 1a                	je     80106eff <trap+0x272>
80106ee5:	8b 45 08             	mov    0x8(%ebp),%eax
80106ee8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106eec:	0f b7 c0             	movzwl %ax,%eax
80106eef:	83 e0 03             	and    $0x3,%eax
80106ef2:	83 f8 03             	cmp    $0x3,%eax
80106ef5:	75 08                	jne    80106eff <trap+0x272>
    exit();
80106ef7:	e8 ce da ff ff       	call   801049ca <exit>
80106efc:	eb 01                	jmp    80106eff <trap+0x272>
    return;
80106efe:	90                   	nop
}
80106eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f02:	5b                   	pop    %ebx
80106f03:	5e                   	pop    %esi
80106f04:	5f                   	pop    %edi
80106f05:	5d                   	pop    %ebp
80106f06:	c3                   	ret    

80106f07 <inb>:
{
80106f07:	55                   	push   %ebp
80106f08:	89 e5                	mov    %esp,%ebp
80106f0a:	83 ec 14             	sub    $0x14,%esp
80106f0d:	8b 45 08             	mov    0x8(%ebp),%eax
80106f10:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f14:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106f18:	89 c2                	mov    %eax,%edx
80106f1a:	ec                   	in     (%dx),%al
80106f1b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f1e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106f22:	c9                   	leave  
80106f23:	c3                   	ret    

80106f24 <outb>:
{
80106f24:	55                   	push   %ebp
80106f25:	89 e5                	mov    %esp,%ebp
80106f27:	83 ec 08             	sub    $0x8,%esp
80106f2a:	8b 45 08             	mov    0x8(%ebp),%eax
80106f2d:	8b 55 0c             	mov    0xc(%ebp),%edx
80106f30:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106f34:	89 d0                	mov    %edx,%eax
80106f36:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106f39:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106f3d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106f41:	ee                   	out    %al,(%dx)
}
80106f42:	90                   	nop
80106f43:	c9                   	leave  
80106f44:	c3                   	ret    

80106f45 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106f45:	f3 0f 1e fb          	endbr32 
80106f49:	55                   	push   %ebp
80106f4a:	89 e5                	mov    %esp,%ebp
80106f4c:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106f4f:	6a 00                	push   $0x0
80106f51:	68 fa 03 00 00       	push   $0x3fa
80106f56:	e8 c9 ff ff ff       	call   80106f24 <outb>
80106f5b:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106f5e:	68 80 00 00 00       	push   $0x80
80106f63:	68 fb 03 00 00       	push   $0x3fb
80106f68:	e8 b7 ff ff ff       	call   80106f24 <outb>
80106f6d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106f70:	6a 0c                	push   $0xc
80106f72:	68 f8 03 00 00       	push   $0x3f8
80106f77:	e8 a8 ff ff ff       	call   80106f24 <outb>
80106f7c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106f7f:	6a 00                	push   $0x0
80106f81:	68 f9 03 00 00       	push   $0x3f9
80106f86:	e8 99 ff ff ff       	call   80106f24 <outb>
80106f8b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106f8e:	6a 03                	push   $0x3
80106f90:	68 fb 03 00 00       	push   $0x3fb
80106f95:	e8 8a ff ff ff       	call   80106f24 <outb>
80106f9a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106f9d:	6a 00                	push   $0x0
80106f9f:	68 fc 03 00 00       	push   $0x3fc
80106fa4:	e8 7b ff ff ff       	call   80106f24 <outb>
80106fa9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106fac:	6a 01                	push   $0x1
80106fae:	68 f9 03 00 00       	push   $0x3f9
80106fb3:	e8 6c ff ff ff       	call   80106f24 <outb>
80106fb8:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106fbb:	68 fd 03 00 00       	push   $0x3fd
80106fc0:	e8 42 ff ff ff       	call   80106f07 <inb>
80106fc5:	83 c4 04             	add    $0x4,%esp
80106fc8:	3c ff                	cmp    $0xff,%al
80106fca:	74 61                	je     8010702d <uartinit+0xe8>
    return;
  uart = 1;
80106fcc:	c7 05 44 c6 10 80 01 	movl   $0x1,0x8010c644
80106fd3:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106fd6:	68 fa 03 00 00       	push   $0x3fa
80106fdb:	e8 27 ff ff ff       	call   80106f07 <inb>
80106fe0:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106fe3:	68 f8 03 00 00       	push   $0x3f8
80106fe8:	e8 1a ff ff ff       	call   80106f07 <inb>
80106fed:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106ff0:	83 ec 08             	sub    $0x8,%esp
80106ff3:	6a 00                	push   $0x0
80106ff5:	6a 04                	push   $0x4
80106ff7:	e8 76 bc ff ff       	call   80102c72 <ioapicenable>
80106ffc:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106fff:	c7 45 f4 f8 96 10 80 	movl   $0x801096f8,-0xc(%ebp)
80107006:	eb 19                	jmp    80107021 <uartinit+0xdc>
    uartputc(*p);
80107008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010700b:	0f b6 00             	movzbl (%eax),%eax
8010700e:	0f be c0             	movsbl %al,%eax
80107011:	83 ec 0c             	sub    $0xc,%esp
80107014:	50                   	push   %eax
80107015:	e8 16 00 00 00       	call   80107030 <uartputc>
8010701a:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010701d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107024:	0f b6 00             	movzbl (%eax),%eax
80107027:	84 c0                	test   %al,%al
80107029:	75 dd                	jne    80107008 <uartinit+0xc3>
8010702b:	eb 01                	jmp    8010702e <uartinit+0xe9>
    return;
8010702d:	90                   	nop
}
8010702e:	c9                   	leave  
8010702f:	c3                   	ret    

80107030 <uartputc>:

void
uartputc(int c)
{
80107030:	f3 0f 1e fb          	endbr32 
80107034:	55                   	push   %ebp
80107035:	89 e5                	mov    %esp,%ebp
80107037:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010703a:	a1 44 c6 10 80       	mov    0x8010c644,%eax
8010703f:	85 c0                	test   %eax,%eax
80107041:	74 53                	je     80107096 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107043:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010704a:	eb 11                	jmp    8010705d <uartputc+0x2d>
    microdelay(10);
8010704c:	83 ec 0c             	sub    $0xc,%esp
8010704f:	6a 0a                	push   $0xa
80107051:	e8 54 c1 ff ff       	call   801031aa <microdelay>
80107056:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107059:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010705d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107061:	7f 1a                	jg     8010707d <uartputc+0x4d>
80107063:	83 ec 0c             	sub    $0xc,%esp
80107066:	68 fd 03 00 00       	push   $0x3fd
8010706b:	e8 97 fe ff ff       	call   80106f07 <inb>
80107070:	83 c4 10             	add    $0x10,%esp
80107073:	0f b6 c0             	movzbl %al,%eax
80107076:	83 e0 20             	and    $0x20,%eax
80107079:	85 c0                	test   %eax,%eax
8010707b:	74 cf                	je     8010704c <uartputc+0x1c>
  outb(COM1+0, c);
8010707d:	8b 45 08             	mov    0x8(%ebp),%eax
80107080:	0f b6 c0             	movzbl %al,%eax
80107083:	83 ec 08             	sub    $0x8,%esp
80107086:	50                   	push   %eax
80107087:	68 f8 03 00 00       	push   $0x3f8
8010708c:	e8 93 fe ff ff       	call   80106f24 <outb>
80107091:	83 c4 10             	add    $0x10,%esp
80107094:	eb 01                	jmp    80107097 <uartputc+0x67>
    return;
80107096:	90                   	nop
}
80107097:	c9                   	leave  
80107098:	c3                   	ret    

80107099 <uartgetc>:

static int
uartgetc(void)
{
80107099:	f3 0f 1e fb          	endbr32 
8010709d:	55                   	push   %ebp
8010709e:	89 e5                	mov    %esp,%ebp
  if(!uart)
801070a0:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801070a5:	85 c0                	test   %eax,%eax
801070a7:	75 07                	jne    801070b0 <uartgetc+0x17>
    return -1;
801070a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070ae:	eb 2e                	jmp    801070de <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801070b0:	68 fd 03 00 00       	push   $0x3fd
801070b5:	e8 4d fe ff ff       	call   80106f07 <inb>
801070ba:	83 c4 04             	add    $0x4,%esp
801070bd:	0f b6 c0             	movzbl %al,%eax
801070c0:	83 e0 01             	and    $0x1,%eax
801070c3:	85 c0                	test   %eax,%eax
801070c5:	75 07                	jne    801070ce <uartgetc+0x35>
    return -1;
801070c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070cc:	eb 10                	jmp    801070de <uartgetc+0x45>
  return inb(COM1+0);
801070ce:	68 f8 03 00 00       	push   $0x3f8
801070d3:	e8 2f fe ff ff       	call   80106f07 <inb>
801070d8:	83 c4 04             	add    $0x4,%esp
801070db:	0f b6 c0             	movzbl %al,%eax
}
801070de:	c9                   	leave  
801070df:	c3                   	ret    

801070e0 <uartintr>:

void
uartintr(void)
{
801070e0:	f3 0f 1e fb          	endbr32 
801070e4:	55                   	push   %ebp
801070e5:	89 e5                	mov    %esp,%ebp
801070e7:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801070ea:	83 ec 0c             	sub    $0xc,%esp
801070ed:	68 99 70 10 80       	push   $0x80107099
801070f2:	e8 b1 97 ff ff       	call   801008a8 <consoleintr>
801070f7:	83 c4 10             	add    $0x10,%esp
}
801070fa:	90                   	nop
801070fb:	c9                   	leave  
801070fc:	c3                   	ret    

801070fd <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801070fd:	6a 00                	push   $0x0
  pushl $0
801070ff:	6a 00                	push   $0x0
  jmp alltraps
80107101:	e9 93 f9 ff ff       	jmp    80106a99 <alltraps>

80107106 <vector1>:
.globl vector1
vector1:
  pushl $0
80107106:	6a 00                	push   $0x0
  pushl $1
80107108:	6a 01                	push   $0x1
  jmp alltraps
8010710a:	e9 8a f9 ff ff       	jmp    80106a99 <alltraps>

8010710f <vector2>:
.globl vector2
vector2:
  pushl $0
8010710f:	6a 00                	push   $0x0
  pushl $2
80107111:	6a 02                	push   $0x2
  jmp alltraps
80107113:	e9 81 f9 ff ff       	jmp    80106a99 <alltraps>

80107118 <vector3>:
.globl vector3
vector3:
  pushl $0
80107118:	6a 00                	push   $0x0
  pushl $3
8010711a:	6a 03                	push   $0x3
  jmp alltraps
8010711c:	e9 78 f9 ff ff       	jmp    80106a99 <alltraps>

80107121 <vector4>:
.globl vector4
vector4:
  pushl $0
80107121:	6a 00                	push   $0x0
  pushl $4
80107123:	6a 04                	push   $0x4
  jmp alltraps
80107125:	e9 6f f9 ff ff       	jmp    80106a99 <alltraps>

8010712a <vector5>:
.globl vector5
vector5:
  pushl $0
8010712a:	6a 00                	push   $0x0
  pushl $5
8010712c:	6a 05                	push   $0x5
  jmp alltraps
8010712e:	e9 66 f9 ff ff       	jmp    80106a99 <alltraps>

80107133 <vector6>:
.globl vector6
vector6:
  pushl $0
80107133:	6a 00                	push   $0x0
  pushl $6
80107135:	6a 06                	push   $0x6
  jmp alltraps
80107137:	e9 5d f9 ff ff       	jmp    80106a99 <alltraps>

8010713c <vector7>:
.globl vector7
vector7:
  pushl $0
8010713c:	6a 00                	push   $0x0
  pushl $7
8010713e:	6a 07                	push   $0x7
  jmp alltraps
80107140:	e9 54 f9 ff ff       	jmp    80106a99 <alltraps>

80107145 <vector8>:
.globl vector8
vector8:
  pushl $8
80107145:	6a 08                	push   $0x8
  jmp alltraps
80107147:	e9 4d f9 ff ff       	jmp    80106a99 <alltraps>

8010714c <vector9>:
.globl vector9
vector9:
  pushl $0
8010714c:	6a 00                	push   $0x0
  pushl $9
8010714e:	6a 09                	push   $0x9
  jmp alltraps
80107150:	e9 44 f9 ff ff       	jmp    80106a99 <alltraps>

80107155 <vector10>:
.globl vector10
vector10:
  pushl $10
80107155:	6a 0a                	push   $0xa
  jmp alltraps
80107157:	e9 3d f9 ff ff       	jmp    80106a99 <alltraps>

8010715c <vector11>:
.globl vector11
vector11:
  pushl $11
8010715c:	6a 0b                	push   $0xb
  jmp alltraps
8010715e:	e9 36 f9 ff ff       	jmp    80106a99 <alltraps>

80107163 <vector12>:
.globl vector12
vector12:
  pushl $12
80107163:	6a 0c                	push   $0xc
  jmp alltraps
80107165:	e9 2f f9 ff ff       	jmp    80106a99 <alltraps>

8010716a <vector13>:
.globl vector13
vector13:
  pushl $13
8010716a:	6a 0d                	push   $0xd
  jmp alltraps
8010716c:	e9 28 f9 ff ff       	jmp    80106a99 <alltraps>

80107171 <vector14>:
.globl vector14
vector14:
  pushl $14
80107171:	6a 0e                	push   $0xe
  jmp alltraps
80107173:	e9 21 f9 ff ff       	jmp    80106a99 <alltraps>

80107178 <vector15>:
.globl vector15
vector15:
  pushl $0
80107178:	6a 00                	push   $0x0
  pushl $15
8010717a:	6a 0f                	push   $0xf
  jmp alltraps
8010717c:	e9 18 f9 ff ff       	jmp    80106a99 <alltraps>

80107181 <vector16>:
.globl vector16
vector16:
  pushl $0
80107181:	6a 00                	push   $0x0
  pushl $16
80107183:	6a 10                	push   $0x10
  jmp alltraps
80107185:	e9 0f f9 ff ff       	jmp    80106a99 <alltraps>

8010718a <vector17>:
.globl vector17
vector17:
  pushl $17
8010718a:	6a 11                	push   $0x11
  jmp alltraps
8010718c:	e9 08 f9 ff ff       	jmp    80106a99 <alltraps>

80107191 <vector18>:
.globl vector18
vector18:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $18
80107193:	6a 12                	push   $0x12
  jmp alltraps
80107195:	e9 ff f8 ff ff       	jmp    80106a99 <alltraps>

8010719a <vector19>:
.globl vector19
vector19:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $19
8010719c:	6a 13                	push   $0x13
  jmp alltraps
8010719e:	e9 f6 f8 ff ff       	jmp    80106a99 <alltraps>

801071a3 <vector20>:
.globl vector20
vector20:
  pushl $0
801071a3:	6a 00                	push   $0x0
  pushl $20
801071a5:	6a 14                	push   $0x14
  jmp alltraps
801071a7:	e9 ed f8 ff ff       	jmp    80106a99 <alltraps>

801071ac <vector21>:
.globl vector21
vector21:
  pushl $0
801071ac:	6a 00                	push   $0x0
  pushl $21
801071ae:	6a 15                	push   $0x15
  jmp alltraps
801071b0:	e9 e4 f8 ff ff       	jmp    80106a99 <alltraps>

801071b5 <vector22>:
.globl vector22
vector22:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $22
801071b7:	6a 16                	push   $0x16
  jmp alltraps
801071b9:	e9 db f8 ff ff       	jmp    80106a99 <alltraps>

801071be <vector23>:
.globl vector23
vector23:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $23
801071c0:	6a 17                	push   $0x17
  jmp alltraps
801071c2:	e9 d2 f8 ff ff       	jmp    80106a99 <alltraps>

801071c7 <vector24>:
.globl vector24
vector24:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $24
801071c9:	6a 18                	push   $0x18
  jmp alltraps
801071cb:	e9 c9 f8 ff ff       	jmp    80106a99 <alltraps>

801071d0 <vector25>:
.globl vector25
vector25:
  pushl $0
801071d0:	6a 00                	push   $0x0
  pushl $25
801071d2:	6a 19                	push   $0x19
  jmp alltraps
801071d4:	e9 c0 f8 ff ff       	jmp    80106a99 <alltraps>

801071d9 <vector26>:
.globl vector26
vector26:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $26
801071db:	6a 1a                	push   $0x1a
  jmp alltraps
801071dd:	e9 b7 f8 ff ff       	jmp    80106a99 <alltraps>

801071e2 <vector27>:
.globl vector27
vector27:
  pushl $0
801071e2:	6a 00                	push   $0x0
  pushl $27
801071e4:	6a 1b                	push   $0x1b
  jmp alltraps
801071e6:	e9 ae f8 ff ff       	jmp    80106a99 <alltraps>

801071eb <vector28>:
.globl vector28
vector28:
  pushl $0
801071eb:	6a 00                	push   $0x0
  pushl $28
801071ed:	6a 1c                	push   $0x1c
  jmp alltraps
801071ef:	e9 a5 f8 ff ff       	jmp    80106a99 <alltraps>

801071f4 <vector29>:
.globl vector29
vector29:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $29
801071f6:	6a 1d                	push   $0x1d
  jmp alltraps
801071f8:	e9 9c f8 ff ff       	jmp    80106a99 <alltraps>

801071fd <vector30>:
.globl vector30
vector30:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $30
801071ff:	6a 1e                	push   $0x1e
  jmp alltraps
80107201:	e9 93 f8 ff ff       	jmp    80106a99 <alltraps>

80107206 <vector31>:
.globl vector31
vector31:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $31
80107208:	6a 1f                	push   $0x1f
  jmp alltraps
8010720a:	e9 8a f8 ff ff       	jmp    80106a99 <alltraps>

8010720f <vector32>:
.globl vector32
vector32:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $32
80107211:	6a 20                	push   $0x20
  jmp alltraps
80107213:	e9 81 f8 ff ff       	jmp    80106a99 <alltraps>

80107218 <vector33>:
.globl vector33
vector33:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $33
8010721a:	6a 21                	push   $0x21
  jmp alltraps
8010721c:	e9 78 f8 ff ff       	jmp    80106a99 <alltraps>

80107221 <vector34>:
.globl vector34
vector34:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $34
80107223:	6a 22                	push   $0x22
  jmp alltraps
80107225:	e9 6f f8 ff ff       	jmp    80106a99 <alltraps>

8010722a <vector35>:
.globl vector35
vector35:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $35
8010722c:	6a 23                	push   $0x23
  jmp alltraps
8010722e:	e9 66 f8 ff ff       	jmp    80106a99 <alltraps>

80107233 <vector36>:
.globl vector36
vector36:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $36
80107235:	6a 24                	push   $0x24
  jmp alltraps
80107237:	e9 5d f8 ff ff       	jmp    80106a99 <alltraps>

8010723c <vector37>:
.globl vector37
vector37:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $37
8010723e:	6a 25                	push   $0x25
  jmp alltraps
80107240:	e9 54 f8 ff ff       	jmp    80106a99 <alltraps>

80107245 <vector38>:
.globl vector38
vector38:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $38
80107247:	6a 26                	push   $0x26
  jmp alltraps
80107249:	e9 4b f8 ff ff       	jmp    80106a99 <alltraps>

8010724e <vector39>:
.globl vector39
vector39:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $39
80107250:	6a 27                	push   $0x27
  jmp alltraps
80107252:	e9 42 f8 ff ff       	jmp    80106a99 <alltraps>

80107257 <vector40>:
.globl vector40
vector40:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $40
80107259:	6a 28                	push   $0x28
  jmp alltraps
8010725b:	e9 39 f8 ff ff       	jmp    80106a99 <alltraps>

80107260 <vector41>:
.globl vector41
vector41:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $41
80107262:	6a 29                	push   $0x29
  jmp alltraps
80107264:	e9 30 f8 ff ff       	jmp    80106a99 <alltraps>

80107269 <vector42>:
.globl vector42
vector42:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $42
8010726b:	6a 2a                	push   $0x2a
  jmp alltraps
8010726d:	e9 27 f8 ff ff       	jmp    80106a99 <alltraps>

80107272 <vector43>:
.globl vector43
vector43:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $43
80107274:	6a 2b                	push   $0x2b
  jmp alltraps
80107276:	e9 1e f8 ff ff       	jmp    80106a99 <alltraps>

8010727b <vector44>:
.globl vector44
vector44:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $44
8010727d:	6a 2c                	push   $0x2c
  jmp alltraps
8010727f:	e9 15 f8 ff ff       	jmp    80106a99 <alltraps>

80107284 <vector45>:
.globl vector45
vector45:
  pushl $0
80107284:	6a 00                	push   $0x0
  pushl $45
80107286:	6a 2d                	push   $0x2d
  jmp alltraps
80107288:	e9 0c f8 ff ff       	jmp    80106a99 <alltraps>

8010728d <vector46>:
.globl vector46
vector46:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $46
8010728f:	6a 2e                	push   $0x2e
  jmp alltraps
80107291:	e9 03 f8 ff ff       	jmp    80106a99 <alltraps>

80107296 <vector47>:
.globl vector47
vector47:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $47
80107298:	6a 2f                	push   $0x2f
  jmp alltraps
8010729a:	e9 fa f7 ff ff       	jmp    80106a99 <alltraps>

8010729f <vector48>:
.globl vector48
vector48:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $48
801072a1:	6a 30                	push   $0x30
  jmp alltraps
801072a3:	e9 f1 f7 ff ff       	jmp    80106a99 <alltraps>

801072a8 <vector49>:
.globl vector49
vector49:
  pushl $0
801072a8:	6a 00                	push   $0x0
  pushl $49
801072aa:	6a 31                	push   $0x31
  jmp alltraps
801072ac:	e9 e8 f7 ff ff       	jmp    80106a99 <alltraps>

801072b1 <vector50>:
.globl vector50
vector50:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $50
801072b3:	6a 32                	push   $0x32
  jmp alltraps
801072b5:	e9 df f7 ff ff       	jmp    80106a99 <alltraps>

801072ba <vector51>:
.globl vector51
vector51:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $51
801072bc:	6a 33                	push   $0x33
  jmp alltraps
801072be:	e9 d6 f7 ff ff       	jmp    80106a99 <alltraps>

801072c3 <vector52>:
.globl vector52
vector52:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $52
801072c5:	6a 34                	push   $0x34
  jmp alltraps
801072c7:	e9 cd f7 ff ff       	jmp    80106a99 <alltraps>

801072cc <vector53>:
.globl vector53
vector53:
  pushl $0
801072cc:	6a 00                	push   $0x0
  pushl $53
801072ce:	6a 35                	push   $0x35
  jmp alltraps
801072d0:	e9 c4 f7 ff ff       	jmp    80106a99 <alltraps>

801072d5 <vector54>:
.globl vector54
vector54:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $54
801072d7:	6a 36                	push   $0x36
  jmp alltraps
801072d9:	e9 bb f7 ff ff       	jmp    80106a99 <alltraps>

801072de <vector55>:
.globl vector55
vector55:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $55
801072e0:	6a 37                	push   $0x37
  jmp alltraps
801072e2:	e9 b2 f7 ff ff       	jmp    80106a99 <alltraps>

801072e7 <vector56>:
.globl vector56
vector56:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $56
801072e9:	6a 38                	push   $0x38
  jmp alltraps
801072eb:	e9 a9 f7 ff ff       	jmp    80106a99 <alltraps>

801072f0 <vector57>:
.globl vector57
vector57:
  pushl $0
801072f0:	6a 00                	push   $0x0
  pushl $57
801072f2:	6a 39                	push   $0x39
  jmp alltraps
801072f4:	e9 a0 f7 ff ff       	jmp    80106a99 <alltraps>

801072f9 <vector58>:
.globl vector58
vector58:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $58
801072fb:	6a 3a                	push   $0x3a
  jmp alltraps
801072fd:	e9 97 f7 ff ff       	jmp    80106a99 <alltraps>

80107302 <vector59>:
.globl vector59
vector59:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $59
80107304:	6a 3b                	push   $0x3b
  jmp alltraps
80107306:	e9 8e f7 ff ff       	jmp    80106a99 <alltraps>

8010730b <vector60>:
.globl vector60
vector60:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $60
8010730d:	6a 3c                	push   $0x3c
  jmp alltraps
8010730f:	e9 85 f7 ff ff       	jmp    80106a99 <alltraps>

80107314 <vector61>:
.globl vector61
vector61:
  pushl $0
80107314:	6a 00                	push   $0x0
  pushl $61
80107316:	6a 3d                	push   $0x3d
  jmp alltraps
80107318:	e9 7c f7 ff ff       	jmp    80106a99 <alltraps>

8010731d <vector62>:
.globl vector62
vector62:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $62
8010731f:	6a 3e                	push   $0x3e
  jmp alltraps
80107321:	e9 73 f7 ff ff       	jmp    80106a99 <alltraps>

80107326 <vector63>:
.globl vector63
vector63:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $63
80107328:	6a 3f                	push   $0x3f
  jmp alltraps
8010732a:	e9 6a f7 ff ff       	jmp    80106a99 <alltraps>

8010732f <vector64>:
.globl vector64
vector64:
  pushl $0
8010732f:	6a 00                	push   $0x0
  pushl $64
80107331:	6a 40                	push   $0x40
  jmp alltraps
80107333:	e9 61 f7 ff ff       	jmp    80106a99 <alltraps>

80107338 <vector65>:
.globl vector65
vector65:
  pushl $0
80107338:	6a 00                	push   $0x0
  pushl $65
8010733a:	6a 41                	push   $0x41
  jmp alltraps
8010733c:	e9 58 f7 ff ff       	jmp    80106a99 <alltraps>

80107341 <vector66>:
.globl vector66
vector66:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $66
80107343:	6a 42                	push   $0x42
  jmp alltraps
80107345:	e9 4f f7 ff ff       	jmp    80106a99 <alltraps>

8010734a <vector67>:
.globl vector67
vector67:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $67
8010734c:	6a 43                	push   $0x43
  jmp alltraps
8010734e:	e9 46 f7 ff ff       	jmp    80106a99 <alltraps>

80107353 <vector68>:
.globl vector68
vector68:
  pushl $0
80107353:	6a 00                	push   $0x0
  pushl $68
80107355:	6a 44                	push   $0x44
  jmp alltraps
80107357:	e9 3d f7 ff ff       	jmp    80106a99 <alltraps>

8010735c <vector69>:
.globl vector69
vector69:
  pushl $0
8010735c:	6a 00                	push   $0x0
  pushl $69
8010735e:	6a 45                	push   $0x45
  jmp alltraps
80107360:	e9 34 f7 ff ff       	jmp    80106a99 <alltraps>

80107365 <vector70>:
.globl vector70
vector70:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $70
80107367:	6a 46                	push   $0x46
  jmp alltraps
80107369:	e9 2b f7 ff ff       	jmp    80106a99 <alltraps>

8010736e <vector71>:
.globl vector71
vector71:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $71
80107370:	6a 47                	push   $0x47
  jmp alltraps
80107372:	e9 22 f7 ff ff       	jmp    80106a99 <alltraps>

80107377 <vector72>:
.globl vector72
vector72:
  pushl $0
80107377:	6a 00                	push   $0x0
  pushl $72
80107379:	6a 48                	push   $0x48
  jmp alltraps
8010737b:	e9 19 f7 ff ff       	jmp    80106a99 <alltraps>

80107380 <vector73>:
.globl vector73
vector73:
  pushl $0
80107380:	6a 00                	push   $0x0
  pushl $73
80107382:	6a 49                	push   $0x49
  jmp alltraps
80107384:	e9 10 f7 ff ff       	jmp    80106a99 <alltraps>

80107389 <vector74>:
.globl vector74
vector74:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $74
8010738b:	6a 4a                	push   $0x4a
  jmp alltraps
8010738d:	e9 07 f7 ff ff       	jmp    80106a99 <alltraps>

80107392 <vector75>:
.globl vector75
vector75:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $75
80107394:	6a 4b                	push   $0x4b
  jmp alltraps
80107396:	e9 fe f6 ff ff       	jmp    80106a99 <alltraps>

8010739b <vector76>:
.globl vector76
vector76:
  pushl $0
8010739b:	6a 00                	push   $0x0
  pushl $76
8010739d:	6a 4c                	push   $0x4c
  jmp alltraps
8010739f:	e9 f5 f6 ff ff       	jmp    80106a99 <alltraps>

801073a4 <vector77>:
.globl vector77
vector77:
  pushl $0
801073a4:	6a 00                	push   $0x0
  pushl $77
801073a6:	6a 4d                	push   $0x4d
  jmp alltraps
801073a8:	e9 ec f6 ff ff       	jmp    80106a99 <alltraps>

801073ad <vector78>:
.globl vector78
vector78:
  pushl $0
801073ad:	6a 00                	push   $0x0
  pushl $78
801073af:	6a 4e                	push   $0x4e
  jmp alltraps
801073b1:	e9 e3 f6 ff ff       	jmp    80106a99 <alltraps>

801073b6 <vector79>:
.globl vector79
vector79:
  pushl $0
801073b6:	6a 00                	push   $0x0
  pushl $79
801073b8:	6a 4f                	push   $0x4f
  jmp alltraps
801073ba:	e9 da f6 ff ff       	jmp    80106a99 <alltraps>

801073bf <vector80>:
.globl vector80
vector80:
  pushl $0
801073bf:	6a 00                	push   $0x0
  pushl $80
801073c1:	6a 50                	push   $0x50
  jmp alltraps
801073c3:	e9 d1 f6 ff ff       	jmp    80106a99 <alltraps>

801073c8 <vector81>:
.globl vector81
vector81:
  pushl $0
801073c8:	6a 00                	push   $0x0
  pushl $81
801073ca:	6a 51                	push   $0x51
  jmp alltraps
801073cc:	e9 c8 f6 ff ff       	jmp    80106a99 <alltraps>

801073d1 <vector82>:
.globl vector82
vector82:
  pushl $0
801073d1:	6a 00                	push   $0x0
  pushl $82
801073d3:	6a 52                	push   $0x52
  jmp alltraps
801073d5:	e9 bf f6 ff ff       	jmp    80106a99 <alltraps>

801073da <vector83>:
.globl vector83
vector83:
  pushl $0
801073da:	6a 00                	push   $0x0
  pushl $83
801073dc:	6a 53                	push   $0x53
  jmp alltraps
801073de:	e9 b6 f6 ff ff       	jmp    80106a99 <alltraps>

801073e3 <vector84>:
.globl vector84
vector84:
  pushl $0
801073e3:	6a 00                	push   $0x0
  pushl $84
801073e5:	6a 54                	push   $0x54
  jmp alltraps
801073e7:	e9 ad f6 ff ff       	jmp    80106a99 <alltraps>

801073ec <vector85>:
.globl vector85
vector85:
  pushl $0
801073ec:	6a 00                	push   $0x0
  pushl $85
801073ee:	6a 55                	push   $0x55
  jmp alltraps
801073f0:	e9 a4 f6 ff ff       	jmp    80106a99 <alltraps>

801073f5 <vector86>:
.globl vector86
vector86:
  pushl $0
801073f5:	6a 00                	push   $0x0
  pushl $86
801073f7:	6a 56                	push   $0x56
  jmp alltraps
801073f9:	e9 9b f6 ff ff       	jmp    80106a99 <alltraps>

801073fe <vector87>:
.globl vector87
vector87:
  pushl $0
801073fe:	6a 00                	push   $0x0
  pushl $87
80107400:	6a 57                	push   $0x57
  jmp alltraps
80107402:	e9 92 f6 ff ff       	jmp    80106a99 <alltraps>

80107407 <vector88>:
.globl vector88
vector88:
  pushl $0
80107407:	6a 00                	push   $0x0
  pushl $88
80107409:	6a 58                	push   $0x58
  jmp alltraps
8010740b:	e9 89 f6 ff ff       	jmp    80106a99 <alltraps>

80107410 <vector89>:
.globl vector89
vector89:
  pushl $0
80107410:	6a 00                	push   $0x0
  pushl $89
80107412:	6a 59                	push   $0x59
  jmp alltraps
80107414:	e9 80 f6 ff ff       	jmp    80106a99 <alltraps>

80107419 <vector90>:
.globl vector90
vector90:
  pushl $0
80107419:	6a 00                	push   $0x0
  pushl $90
8010741b:	6a 5a                	push   $0x5a
  jmp alltraps
8010741d:	e9 77 f6 ff ff       	jmp    80106a99 <alltraps>

80107422 <vector91>:
.globl vector91
vector91:
  pushl $0
80107422:	6a 00                	push   $0x0
  pushl $91
80107424:	6a 5b                	push   $0x5b
  jmp alltraps
80107426:	e9 6e f6 ff ff       	jmp    80106a99 <alltraps>

8010742b <vector92>:
.globl vector92
vector92:
  pushl $0
8010742b:	6a 00                	push   $0x0
  pushl $92
8010742d:	6a 5c                	push   $0x5c
  jmp alltraps
8010742f:	e9 65 f6 ff ff       	jmp    80106a99 <alltraps>

80107434 <vector93>:
.globl vector93
vector93:
  pushl $0
80107434:	6a 00                	push   $0x0
  pushl $93
80107436:	6a 5d                	push   $0x5d
  jmp alltraps
80107438:	e9 5c f6 ff ff       	jmp    80106a99 <alltraps>

8010743d <vector94>:
.globl vector94
vector94:
  pushl $0
8010743d:	6a 00                	push   $0x0
  pushl $94
8010743f:	6a 5e                	push   $0x5e
  jmp alltraps
80107441:	e9 53 f6 ff ff       	jmp    80106a99 <alltraps>

80107446 <vector95>:
.globl vector95
vector95:
  pushl $0
80107446:	6a 00                	push   $0x0
  pushl $95
80107448:	6a 5f                	push   $0x5f
  jmp alltraps
8010744a:	e9 4a f6 ff ff       	jmp    80106a99 <alltraps>

8010744f <vector96>:
.globl vector96
vector96:
  pushl $0
8010744f:	6a 00                	push   $0x0
  pushl $96
80107451:	6a 60                	push   $0x60
  jmp alltraps
80107453:	e9 41 f6 ff ff       	jmp    80106a99 <alltraps>

80107458 <vector97>:
.globl vector97
vector97:
  pushl $0
80107458:	6a 00                	push   $0x0
  pushl $97
8010745a:	6a 61                	push   $0x61
  jmp alltraps
8010745c:	e9 38 f6 ff ff       	jmp    80106a99 <alltraps>

80107461 <vector98>:
.globl vector98
vector98:
  pushl $0
80107461:	6a 00                	push   $0x0
  pushl $98
80107463:	6a 62                	push   $0x62
  jmp alltraps
80107465:	e9 2f f6 ff ff       	jmp    80106a99 <alltraps>

8010746a <vector99>:
.globl vector99
vector99:
  pushl $0
8010746a:	6a 00                	push   $0x0
  pushl $99
8010746c:	6a 63                	push   $0x63
  jmp alltraps
8010746e:	e9 26 f6 ff ff       	jmp    80106a99 <alltraps>

80107473 <vector100>:
.globl vector100
vector100:
  pushl $0
80107473:	6a 00                	push   $0x0
  pushl $100
80107475:	6a 64                	push   $0x64
  jmp alltraps
80107477:	e9 1d f6 ff ff       	jmp    80106a99 <alltraps>

8010747c <vector101>:
.globl vector101
vector101:
  pushl $0
8010747c:	6a 00                	push   $0x0
  pushl $101
8010747e:	6a 65                	push   $0x65
  jmp alltraps
80107480:	e9 14 f6 ff ff       	jmp    80106a99 <alltraps>

80107485 <vector102>:
.globl vector102
vector102:
  pushl $0
80107485:	6a 00                	push   $0x0
  pushl $102
80107487:	6a 66                	push   $0x66
  jmp alltraps
80107489:	e9 0b f6 ff ff       	jmp    80106a99 <alltraps>

8010748e <vector103>:
.globl vector103
vector103:
  pushl $0
8010748e:	6a 00                	push   $0x0
  pushl $103
80107490:	6a 67                	push   $0x67
  jmp alltraps
80107492:	e9 02 f6 ff ff       	jmp    80106a99 <alltraps>

80107497 <vector104>:
.globl vector104
vector104:
  pushl $0
80107497:	6a 00                	push   $0x0
  pushl $104
80107499:	6a 68                	push   $0x68
  jmp alltraps
8010749b:	e9 f9 f5 ff ff       	jmp    80106a99 <alltraps>

801074a0 <vector105>:
.globl vector105
vector105:
  pushl $0
801074a0:	6a 00                	push   $0x0
  pushl $105
801074a2:	6a 69                	push   $0x69
  jmp alltraps
801074a4:	e9 f0 f5 ff ff       	jmp    80106a99 <alltraps>

801074a9 <vector106>:
.globl vector106
vector106:
  pushl $0
801074a9:	6a 00                	push   $0x0
  pushl $106
801074ab:	6a 6a                	push   $0x6a
  jmp alltraps
801074ad:	e9 e7 f5 ff ff       	jmp    80106a99 <alltraps>

801074b2 <vector107>:
.globl vector107
vector107:
  pushl $0
801074b2:	6a 00                	push   $0x0
  pushl $107
801074b4:	6a 6b                	push   $0x6b
  jmp alltraps
801074b6:	e9 de f5 ff ff       	jmp    80106a99 <alltraps>

801074bb <vector108>:
.globl vector108
vector108:
  pushl $0
801074bb:	6a 00                	push   $0x0
  pushl $108
801074bd:	6a 6c                	push   $0x6c
  jmp alltraps
801074bf:	e9 d5 f5 ff ff       	jmp    80106a99 <alltraps>

801074c4 <vector109>:
.globl vector109
vector109:
  pushl $0
801074c4:	6a 00                	push   $0x0
  pushl $109
801074c6:	6a 6d                	push   $0x6d
  jmp alltraps
801074c8:	e9 cc f5 ff ff       	jmp    80106a99 <alltraps>

801074cd <vector110>:
.globl vector110
vector110:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $110
801074cf:	6a 6e                	push   $0x6e
  jmp alltraps
801074d1:	e9 c3 f5 ff ff       	jmp    80106a99 <alltraps>

801074d6 <vector111>:
.globl vector111
vector111:
  pushl $0
801074d6:	6a 00                	push   $0x0
  pushl $111
801074d8:	6a 6f                	push   $0x6f
  jmp alltraps
801074da:	e9 ba f5 ff ff       	jmp    80106a99 <alltraps>

801074df <vector112>:
.globl vector112
vector112:
  pushl $0
801074df:	6a 00                	push   $0x0
  pushl $112
801074e1:	6a 70                	push   $0x70
  jmp alltraps
801074e3:	e9 b1 f5 ff ff       	jmp    80106a99 <alltraps>

801074e8 <vector113>:
.globl vector113
vector113:
  pushl $0
801074e8:	6a 00                	push   $0x0
  pushl $113
801074ea:	6a 71                	push   $0x71
  jmp alltraps
801074ec:	e9 a8 f5 ff ff       	jmp    80106a99 <alltraps>

801074f1 <vector114>:
.globl vector114
vector114:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $114
801074f3:	6a 72                	push   $0x72
  jmp alltraps
801074f5:	e9 9f f5 ff ff       	jmp    80106a99 <alltraps>

801074fa <vector115>:
.globl vector115
vector115:
  pushl $0
801074fa:	6a 00                	push   $0x0
  pushl $115
801074fc:	6a 73                	push   $0x73
  jmp alltraps
801074fe:	e9 96 f5 ff ff       	jmp    80106a99 <alltraps>

80107503 <vector116>:
.globl vector116
vector116:
  pushl $0
80107503:	6a 00                	push   $0x0
  pushl $116
80107505:	6a 74                	push   $0x74
  jmp alltraps
80107507:	e9 8d f5 ff ff       	jmp    80106a99 <alltraps>

8010750c <vector117>:
.globl vector117
vector117:
  pushl $0
8010750c:	6a 00                	push   $0x0
  pushl $117
8010750e:	6a 75                	push   $0x75
  jmp alltraps
80107510:	e9 84 f5 ff ff       	jmp    80106a99 <alltraps>

80107515 <vector118>:
.globl vector118
vector118:
  pushl $0
80107515:	6a 00                	push   $0x0
  pushl $118
80107517:	6a 76                	push   $0x76
  jmp alltraps
80107519:	e9 7b f5 ff ff       	jmp    80106a99 <alltraps>

8010751e <vector119>:
.globl vector119
vector119:
  pushl $0
8010751e:	6a 00                	push   $0x0
  pushl $119
80107520:	6a 77                	push   $0x77
  jmp alltraps
80107522:	e9 72 f5 ff ff       	jmp    80106a99 <alltraps>

80107527 <vector120>:
.globl vector120
vector120:
  pushl $0
80107527:	6a 00                	push   $0x0
  pushl $120
80107529:	6a 78                	push   $0x78
  jmp alltraps
8010752b:	e9 69 f5 ff ff       	jmp    80106a99 <alltraps>

80107530 <vector121>:
.globl vector121
vector121:
  pushl $0
80107530:	6a 00                	push   $0x0
  pushl $121
80107532:	6a 79                	push   $0x79
  jmp alltraps
80107534:	e9 60 f5 ff ff       	jmp    80106a99 <alltraps>

80107539 <vector122>:
.globl vector122
vector122:
  pushl $0
80107539:	6a 00                	push   $0x0
  pushl $122
8010753b:	6a 7a                	push   $0x7a
  jmp alltraps
8010753d:	e9 57 f5 ff ff       	jmp    80106a99 <alltraps>

80107542 <vector123>:
.globl vector123
vector123:
  pushl $0
80107542:	6a 00                	push   $0x0
  pushl $123
80107544:	6a 7b                	push   $0x7b
  jmp alltraps
80107546:	e9 4e f5 ff ff       	jmp    80106a99 <alltraps>

8010754b <vector124>:
.globl vector124
vector124:
  pushl $0
8010754b:	6a 00                	push   $0x0
  pushl $124
8010754d:	6a 7c                	push   $0x7c
  jmp alltraps
8010754f:	e9 45 f5 ff ff       	jmp    80106a99 <alltraps>

80107554 <vector125>:
.globl vector125
vector125:
  pushl $0
80107554:	6a 00                	push   $0x0
  pushl $125
80107556:	6a 7d                	push   $0x7d
  jmp alltraps
80107558:	e9 3c f5 ff ff       	jmp    80106a99 <alltraps>

8010755d <vector126>:
.globl vector126
vector126:
  pushl $0
8010755d:	6a 00                	push   $0x0
  pushl $126
8010755f:	6a 7e                	push   $0x7e
  jmp alltraps
80107561:	e9 33 f5 ff ff       	jmp    80106a99 <alltraps>

80107566 <vector127>:
.globl vector127
vector127:
  pushl $0
80107566:	6a 00                	push   $0x0
  pushl $127
80107568:	6a 7f                	push   $0x7f
  jmp alltraps
8010756a:	e9 2a f5 ff ff       	jmp    80106a99 <alltraps>

8010756f <vector128>:
.globl vector128
vector128:
  pushl $0
8010756f:	6a 00                	push   $0x0
  pushl $128
80107571:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107576:	e9 1e f5 ff ff       	jmp    80106a99 <alltraps>

8010757b <vector129>:
.globl vector129
vector129:
  pushl $0
8010757b:	6a 00                	push   $0x0
  pushl $129
8010757d:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107582:	e9 12 f5 ff ff       	jmp    80106a99 <alltraps>

80107587 <vector130>:
.globl vector130
vector130:
  pushl $0
80107587:	6a 00                	push   $0x0
  pushl $130
80107589:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010758e:	e9 06 f5 ff ff       	jmp    80106a99 <alltraps>

80107593 <vector131>:
.globl vector131
vector131:
  pushl $0
80107593:	6a 00                	push   $0x0
  pushl $131
80107595:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010759a:	e9 fa f4 ff ff       	jmp    80106a99 <alltraps>

8010759f <vector132>:
.globl vector132
vector132:
  pushl $0
8010759f:	6a 00                	push   $0x0
  pushl $132
801075a1:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801075a6:	e9 ee f4 ff ff       	jmp    80106a99 <alltraps>

801075ab <vector133>:
.globl vector133
vector133:
  pushl $0
801075ab:	6a 00                	push   $0x0
  pushl $133
801075ad:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801075b2:	e9 e2 f4 ff ff       	jmp    80106a99 <alltraps>

801075b7 <vector134>:
.globl vector134
vector134:
  pushl $0
801075b7:	6a 00                	push   $0x0
  pushl $134
801075b9:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801075be:	e9 d6 f4 ff ff       	jmp    80106a99 <alltraps>

801075c3 <vector135>:
.globl vector135
vector135:
  pushl $0
801075c3:	6a 00                	push   $0x0
  pushl $135
801075c5:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801075ca:	e9 ca f4 ff ff       	jmp    80106a99 <alltraps>

801075cf <vector136>:
.globl vector136
vector136:
  pushl $0
801075cf:	6a 00                	push   $0x0
  pushl $136
801075d1:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801075d6:	e9 be f4 ff ff       	jmp    80106a99 <alltraps>

801075db <vector137>:
.globl vector137
vector137:
  pushl $0
801075db:	6a 00                	push   $0x0
  pushl $137
801075dd:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801075e2:	e9 b2 f4 ff ff       	jmp    80106a99 <alltraps>

801075e7 <vector138>:
.globl vector138
vector138:
  pushl $0
801075e7:	6a 00                	push   $0x0
  pushl $138
801075e9:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801075ee:	e9 a6 f4 ff ff       	jmp    80106a99 <alltraps>

801075f3 <vector139>:
.globl vector139
vector139:
  pushl $0
801075f3:	6a 00                	push   $0x0
  pushl $139
801075f5:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801075fa:	e9 9a f4 ff ff       	jmp    80106a99 <alltraps>

801075ff <vector140>:
.globl vector140
vector140:
  pushl $0
801075ff:	6a 00                	push   $0x0
  pushl $140
80107601:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107606:	e9 8e f4 ff ff       	jmp    80106a99 <alltraps>

8010760b <vector141>:
.globl vector141
vector141:
  pushl $0
8010760b:	6a 00                	push   $0x0
  pushl $141
8010760d:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107612:	e9 82 f4 ff ff       	jmp    80106a99 <alltraps>

80107617 <vector142>:
.globl vector142
vector142:
  pushl $0
80107617:	6a 00                	push   $0x0
  pushl $142
80107619:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010761e:	e9 76 f4 ff ff       	jmp    80106a99 <alltraps>

80107623 <vector143>:
.globl vector143
vector143:
  pushl $0
80107623:	6a 00                	push   $0x0
  pushl $143
80107625:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010762a:	e9 6a f4 ff ff       	jmp    80106a99 <alltraps>

8010762f <vector144>:
.globl vector144
vector144:
  pushl $0
8010762f:	6a 00                	push   $0x0
  pushl $144
80107631:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107636:	e9 5e f4 ff ff       	jmp    80106a99 <alltraps>

8010763b <vector145>:
.globl vector145
vector145:
  pushl $0
8010763b:	6a 00                	push   $0x0
  pushl $145
8010763d:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107642:	e9 52 f4 ff ff       	jmp    80106a99 <alltraps>

80107647 <vector146>:
.globl vector146
vector146:
  pushl $0
80107647:	6a 00                	push   $0x0
  pushl $146
80107649:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010764e:	e9 46 f4 ff ff       	jmp    80106a99 <alltraps>

80107653 <vector147>:
.globl vector147
vector147:
  pushl $0
80107653:	6a 00                	push   $0x0
  pushl $147
80107655:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010765a:	e9 3a f4 ff ff       	jmp    80106a99 <alltraps>

8010765f <vector148>:
.globl vector148
vector148:
  pushl $0
8010765f:	6a 00                	push   $0x0
  pushl $148
80107661:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107666:	e9 2e f4 ff ff       	jmp    80106a99 <alltraps>

8010766b <vector149>:
.globl vector149
vector149:
  pushl $0
8010766b:	6a 00                	push   $0x0
  pushl $149
8010766d:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107672:	e9 22 f4 ff ff       	jmp    80106a99 <alltraps>

80107677 <vector150>:
.globl vector150
vector150:
  pushl $0
80107677:	6a 00                	push   $0x0
  pushl $150
80107679:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010767e:	e9 16 f4 ff ff       	jmp    80106a99 <alltraps>

80107683 <vector151>:
.globl vector151
vector151:
  pushl $0
80107683:	6a 00                	push   $0x0
  pushl $151
80107685:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010768a:	e9 0a f4 ff ff       	jmp    80106a99 <alltraps>

8010768f <vector152>:
.globl vector152
vector152:
  pushl $0
8010768f:	6a 00                	push   $0x0
  pushl $152
80107691:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107696:	e9 fe f3 ff ff       	jmp    80106a99 <alltraps>

8010769b <vector153>:
.globl vector153
vector153:
  pushl $0
8010769b:	6a 00                	push   $0x0
  pushl $153
8010769d:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801076a2:	e9 f2 f3 ff ff       	jmp    80106a99 <alltraps>

801076a7 <vector154>:
.globl vector154
vector154:
  pushl $0
801076a7:	6a 00                	push   $0x0
  pushl $154
801076a9:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801076ae:	e9 e6 f3 ff ff       	jmp    80106a99 <alltraps>

801076b3 <vector155>:
.globl vector155
vector155:
  pushl $0
801076b3:	6a 00                	push   $0x0
  pushl $155
801076b5:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801076ba:	e9 da f3 ff ff       	jmp    80106a99 <alltraps>

801076bf <vector156>:
.globl vector156
vector156:
  pushl $0
801076bf:	6a 00                	push   $0x0
  pushl $156
801076c1:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801076c6:	e9 ce f3 ff ff       	jmp    80106a99 <alltraps>

801076cb <vector157>:
.globl vector157
vector157:
  pushl $0
801076cb:	6a 00                	push   $0x0
  pushl $157
801076cd:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801076d2:	e9 c2 f3 ff ff       	jmp    80106a99 <alltraps>

801076d7 <vector158>:
.globl vector158
vector158:
  pushl $0
801076d7:	6a 00                	push   $0x0
  pushl $158
801076d9:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801076de:	e9 b6 f3 ff ff       	jmp    80106a99 <alltraps>

801076e3 <vector159>:
.globl vector159
vector159:
  pushl $0
801076e3:	6a 00                	push   $0x0
  pushl $159
801076e5:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801076ea:	e9 aa f3 ff ff       	jmp    80106a99 <alltraps>

801076ef <vector160>:
.globl vector160
vector160:
  pushl $0
801076ef:	6a 00                	push   $0x0
  pushl $160
801076f1:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801076f6:	e9 9e f3 ff ff       	jmp    80106a99 <alltraps>

801076fb <vector161>:
.globl vector161
vector161:
  pushl $0
801076fb:	6a 00                	push   $0x0
  pushl $161
801076fd:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107702:	e9 92 f3 ff ff       	jmp    80106a99 <alltraps>

80107707 <vector162>:
.globl vector162
vector162:
  pushl $0
80107707:	6a 00                	push   $0x0
  pushl $162
80107709:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010770e:	e9 86 f3 ff ff       	jmp    80106a99 <alltraps>

80107713 <vector163>:
.globl vector163
vector163:
  pushl $0
80107713:	6a 00                	push   $0x0
  pushl $163
80107715:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010771a:	e9 7a f3 ff ff       	jmp    80106a99 <alltraps>

8010771f <vector164>:
.globl vector164
vector164:
  pushl $0
8010771f:	6a 00                	push   $0x0
  pushl $164
80107721:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107726:	e9 6e f3 ff ff       	jmp    80106a99 <alltraps>

8010772b <vector165>:
.globl vector165
vector165:
  pushl $0
8010772b:	6a 00                	push   $0x0
  pushl $165
8010772d:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107732:	e9 62 f3 ff ff       	jmp    80106a99 <alltraps>

80107737 <vector166>:
.globl vector166
vector166:
  pushl $0
80107737:	6a 00                	push   $0x0
  pushl $166
80107739:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010773e:	e9 56 f3 ff ff       	jmp    80106a99 <alltraps>

80107743 <vector167>:
.globl vector167
vector167:
  pushl $0
80107743:	6a 00                	push   $0x0
  pushl $167
80107745:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010774a:	e9 4a f3 ff ff       	jmp    80106a99 <alltraps>

8010774f <vector168>:
.globl vector168
vector168:
  pushl $0
8010774f:	6a 00                	push   $0x0
  pushl $168
80107751:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107756:	e9 3e f3 ff ff       	jmp    80106a99 <alltraps>

8010775b <vector169>:
.globl vector169
vector169:
  pushl $0
8010775b:	6a 00                	push   $0x0
  pushl $169
8010775d:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107762:	e9 32 f3 ff ff       	jmp    80106a99 <alltraps>

80107767 <vector170>:
.globl vector170
vector170:
  pushl $0
80107767:	6a 00                	push   $0x0
  pushl $170
80107769:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010776e:	e9 26 f3 ff ff       	jmp    80106a99 <alltraps>

80107773 <vector171>:
.globl vector171
vector171:
  pushl $0
80107773:	6a 00                	push   $0x0
  pushl $171
80107775:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010777a:	e9 1a f3 ff ff       	jmp    80106a99 <alltraps>

8010777f <vector172>:
.globl vector172
vector172:
  pushl $0
8010777f:	6a 00                	push   $0x0
  pushl $172
80107781:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107786:	e9 0e f3 ff ff       	jmp    80106a99 <alltraps>

8010778b <vector173>:
.globl vector173
vector173:
  pushl $0
8010778b:	6a 00                	push   $0x0
  pushl $173
8010778d:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107792:	e9 02 f3 ff ff       	jmp    80106a99 <alltraps>

80107797 <vector174>:
.globl vector174
vector174:
  pushl $0
80107797:	6a 00                	push   $0x0
  pushl $174
80107799:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010779e:	e9 f6 f2 ff ff       	jmp    80106a99 <alltraps>

801077a3 <vector175>:
.globl vector175
vector175:
  pushl $0
801077a3:	6a 00                	push   $0x0
  pushl $175
801077a5:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801077aa:	e9 ea f2 ff ff       	jmp    80106a99 <alltraps>

801077af <vector176>:
.globl vector176
vector176:
  pushl $0
801077af:	6a 00                	push   $0x0
  pushl $176
801077b1:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801077b6:	e9 de f2 ff ff       	jmp    80106a99 <alltraps>

801077bb <vector177>:
.globl vector177
vector177:
  pushl $0
801077bb:	6a 00                	push   $0x0
  pushl $177
801077bd:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801077c2:	e9 d2 f2 ff ff       	jmp    80106a99 <alltraps>

801077c7 <vector178>:
.globl vector178
vector178:
  pushl $0
801077c7:	6a 00                	push   $0x0
  pushl $178
801077c9:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801077ce:	e9 c6 f2 ff ff       	jmp    80106a99 <alltraps>

801077d3 <vector179>:
.globl vector179
vector179:
  pushl $0
801077d3:	6a 00                	push   $0x0
  pushl $179
801077d5:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801077da:	e9 ba f2 ff ff       	jmp    80106a99 <alltraps>

801077df <vector180>:
.globl vector180
vector180:
  pushl $0
801077df:	6a 00                	push   $0x0
  pushl $180
801077e1:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801077e6:	e9 ae f2 ff ff       	jmp    80106a99 <alltraps>

801077eb <vector181>:
.globl vector181
vector181:
  pushl $0
801077eb:	6a 00                	push   $0x0
  pushl $181
801077ed:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801077f2:	e9 a2 f2 ff ff       	jmp    80106a99 <alltraps>

801077f7 <vector182>:
.globl vector182
vector182:
  pushl $0
801077f7:	6a 00                	push   $0x0
  pushl $182
801077f9:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801077fe:	e9 96 f2 ff ff       	jmp    80106a99 <alltraps>

80107803 <vector183>:
.globl vector183
vector183:
  pushl $0
80107803:	6a 00                	push   $0x0
  pushl $183
80107805:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010780a:	e9 8a f2 ff ff       	jmp    80106a99 <alltraps>

8010780f <vector184>:
.globl vector184
vector184:
  pushl $0
8010780f:	6a 00                	push   $0x0
  pushl $184
80107811:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107816:	e9 7e f2 ff ff       	jmp    80106a99 <alltraps>

8010781b <vector185>:
.globl vector185
vector185:
  pushl $0
8010781b:	6a 00                	push   $0x0
  pushl $185
8010781d:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107822:	e9 72 f2 ff ff       	jmp    80106a99 <alltraps>

80107827 <vector186>:
.globl vector186
vector186:
  pushl $0
80107827:	6a 00                	push   $0x0
  pushl $186
80107829:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010782e:	e9 66 f2 ff ff       	jmp    80106a99 <alltraps>

80107833 <vector187>:
.globl vector187
vector187:
  pushl $0
80107833:	6a 00                	push   $0x0
  pushl $187
80107835:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010783a:	e9 5a f2 ff ff       	jmp    80106a99 <alltraps>

8010783f <vector188>:
.globl vector188
vector188:
  pushl $0
8010783f:	6a 00                	push   $0x0
  pushl $188
80107841:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107846:	e9 4e f2 ff ff       	jmp    80106a99 <alltraps>

8010784b <vector189>:
.globl vector189
vector189:
  pushl $0
8010784b:	6a 00                	push   $0x0
  pushl $189
8010784d:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107852:	e9 42 f2 ff ff       	jmp    80106a99 <alltraps>

80107857 <vector190>:
.globl vector190
vector190:
  pushl $0
80107857:	6a 00                	push   $0x0
  pushl $190
80107859:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010785e:	e9 36 f2 ff ff       	jmp    80106a99 <alltraps>

80107863 <vector191>:
.globl vector191
vector191:
  pushl $0
80107863:	6a 00                	push   $0x0
  pushl $191
80107865:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010786a:	e9 2a f2 ff ff       	jmp    80106a99 <alltraps>

8010786f <vector192>:
.globl vector192
vector192:
  pushl $0
8010786f:	6a 00                	push   $0x0
  pushl $192
80107871:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107876:	e9 1e f2 ff ff       	jmp    80106a99 <alltraps>

8010787b <vector193>:
.globl vector193
vector193:
  pushl $0
8010787b:	6a 00                	push   $0x0
  pushl $193
8010787d:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107882:	e9 12 f2 ff ff       	jmp    80106a99 <alltraps>

80107887 <vector194>:
.globl vector194
vector194:
  pushl $0
80107887:	6a 00                	push   $0x0
  pushl $194
80107889:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010788e:	e9 06 f2 ff ff       	jmp    80106a99 <alltraps>

80107893 <vector195>:
.globl vector195
vector195:
  pushl $0
80107893:	6a 00                	push   $0x0
  pushl $195
80107895:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010789a:	e9 fa f1 ff ff       	jmp    80106a99 <alltraps>

8010789f <vector196>:
.globl vector196
vector196:
  pushl $0
8010789f:	6a 00                	push   $0x0
  pushl $196
801078a1:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801078a6:	e9 ee f1 ff ff       	jmp    80106a99 <alltraps>

801078ab <vector197>:
.globl vector197
vector197:
  pushl $0
801078ab:	6a 00                	push   $0x0
  pushl $197
801078ad:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801078b2:	e9 e2 f1 ff ff       	jmp    80106a99 <alltraps>

801078b7 <vector198>:
.globl vector198
vector198:
  pushl $0
801078b7:	6a 00                	push   $0x0
  pushl $198
801078b9:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801078be:	e9 d6 f1 ff ff       	jmp    80106a99 <alltraps>

801078c3 <vector199>:
.globl vector199
vector199:
  pushl $0
801078c3:	6a 00                	push   $0x0
  pushl $199
801078c5:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801078ca:	e9 ca f1 ff ff       	jmp    80106a99 <alltraps>

801078cf <vector200>:
.globl vector200
vector200:
  pushl $0
801078cf:	6a 00                	push   $0x0
  pushl $200
801078d1:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801078d6:	e9 be f1 ff ff       	jmp    80106a99 <alltraps>

801078db <vector201>:
.globl vector201
vector201:
  pushl $0
801078db:	6a 00                	push   $0x0
  pushl $201
801078dd:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801078e2:	e9 b2 f1 ff ff       	jmp    80106a99 <alltraps>

801078e7 <vector202>:
.globl vector202
vector202:
  pushl $0
801078e7:	6a 00                	push   $0x0
  pushl $202
801078e9:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801078ee:	e9 a6 f1 ff ff       	jmp    80106a99 <alltraps>

801078f3 <vector203>:
.globl vector203
vector203:
  pushl $0
801078f3:	6a 00                	push   $0x0
  pushl $203
801078f5:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801078fa:	e9 9a f1 ff ff       	jmp    80106a99 <alltraps>

801078ff <vector204>:
.globl vector204
vector204:
  pushl $0
801078ff:	6a 00                	push   $0x0
  pushl $204
80107901:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107906:	e9 8e f1 ff ff       	jmp    80106a99 <alltraps>

8010790b <vector205>:
.globl vector205
vector205:
  pushl $0
8010790b:	6a 00                	push   $0x0
  pushl $205
8010790d:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107912:	e9 82 f1 ff ff       	jmp    80106a99 <alltraps>

80107917 <vector206>:
.globl vector206
vector206:
  pushl $0
80107917:	6a 00                	push   $0x0
  pushl $206
80107919:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010791e:	e9 76 f1 ff ff       	jmp    80106a99 <alltraps>

80107923 <vector207>:
.globl vector207
vector207:
  pushl $0
80107923:	6a 00                	push   $0x0
  pushl $207
80107925:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010792a:	e9 6a f1 ff ff       	jmp    80106a99 <alltraps>

8010792f <vector208>:
.globl vector208
vector208:
  pushl $0
8010792f:	6a 00                	push   $0x0
  pushl $208
80107931:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107936:	e9 5e f1 ff ff       	jmp    80106a99 <alltraps>

8010793b <vector209>:
.globl vector209
vector209:
  pushl $0
8010793b:	6a 00                	push   $0x0
  pushl $209
8010793d:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107942:	e9 52 f1 ff ff       	jmp    80106a99 <alltraps>

80107947 <vector210>:
.globl vector210
vector210:
  pushl $0
80107947:	6a 00                	push   $0x0
  pushl $210
80107949:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010794e:	e9 46 f1 ff ff       	jmp    80106a99 <alltraps>

80107953 <vector211>:
.globl vector211
vector211:
  pushl $0
80107953:	6a 00                	push   $0x0
  pushl $211
80107955:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010795a:	e9 3a f1 ff ff       	jmp    80106a99 <alltraps>

8010795f <vector212>:
.globl vector212
vector212:
  pushl $0
8010795f:	6a 00                	push   $0x0
  pushl $212
80107961:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107966:	e9 2e f1 ff ff       	jmp    80106a99 <alltraps>

8010796b <vector213>:
.globl vector213
vector213:
  pushl $0
8010796b:	6a 00                	push   $0x0
  pushl $213
8010796d:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107972:	e9 22 f1 ff ff       	jmp    80106a99 <alltraps>

80107977 <vector214>:
.globl vector214
vector214:
  pushl $0
80107977:	6a 00                	push   $0x0
  pushl $214
80107979:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010797e:	e9 16 f1 ff ff       	jmp    80106a99 <alltraps>

80107983 <vector215>:
.globl vector215
vector215:
  pushl $0
80107983:	6a 00                	push   $0x0
  pushl $215
80107985:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010798a:	e9 0a f1 ff ff       	jmp    80106a99 <alltraps>

8010798f <vector216>:
.globl vector216
vector216:
  pushl $0
8010798f:	6a 00                	push   $0x0
  pushl $216
80107991:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107996:	e9 fe f0 ff ff       	jmp    80106a99 <alltraps>

8010799b <vector217>:
.globl vector217
vector217:
  pushl $0
8010799b:	6a 00                	push   $0x0
  pushl $217
8010799d:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801079a2:	e9 f2 f0 ff ff       	jmp    80106a99 <alltraps>

801079a7 <vector218>:
.globl vector218
vector218:
  pushl $0
801079a7:	6a 00                	push   $0x0
  pushl $218
801079a9:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801079ae:	e9 e6 f0 ff ff       	jmp    80106a99 <alltraps>

801079b3 <vector219>:
.globl vector219
vector219:
  pushl $0
801079b3:	6a 00                	push   $0x0
  pushl $219
801079b5:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801079ba:	e9 da f0 ff ff       	jmp    80106a99 <alltraps>

801079bf <vector220>:
.globl vector220
vector220:
  pushl $0
801079bf:	6a 00                	push   $0x0
  pushl $220
801079c1:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801079c6:	e9 ce f0 ff ff       	jmp    80106a99 <alltraps>

801079cb <vector221>:
.globl vector221
vector221:
  pushl $0
801079cb:	6a 00                	push   $0x0
  pushl $221
801079cd:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801079d2:	e9 c2 f0 ff ff       	jmp    80106a99 <alltraps>

801079d7 <vector222>:
.globl vector222
vector222:
  pushl $0
801079d7:	6a 00                	push   $0x0
  pushl $222
801079d9:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801079de:	e9 b6 f0 ff ff       	jmp    80106a99 <alltraps>

801079e3 <vector223>:
.globl vector223
vector223:
  pushl $0
801079e3:	6a 00                	push   $0x0
  pushl $223
801079e5:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801079ea:	e9 aa f0 ff ff       	jmp    80106a99 <alltraps>

801079ef <vector224>:
.globl vector224
vector224:
  pushl $0
801079ef:	6a 00                	push   $0x0
  pushl $224
801079f1:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801079f6:	e9 9e f0 ff ff       	jmp    80106a99 <alltraps>

801079fb <vector225>:
.globl vector225
vector225:
  pushl $0
801079fb:	6a 00                	push   $0x0
  pushl $225
801079fd:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a02:	e9 92 f0 ff ff       	jmp    80106a99 <alltraps>

80107a07 <vector226>:
.globl vector226
vector226:
  pushl $0
80107a07:	6a 00                	push   $0x0
  pushl $226
80107a09:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a0e:	e9 86 f0 ff ff       	jmp    80106a99 <alltraps>

80107a13 <vector227>:
.globl vector227
vector227:
  pushl $0
80107a13:	6a 00                	push   $0x0
  pushl $227
80107a15:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a1a:	e9 7a f0 ff ff       	jmp    80106a99 <alltraps>

80107a1f <vector228>:
.globl vector228
vector228:
  pushl $0
80107a1f:	6a 00                	push   $0x0
  pushl $228
80107a21:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a26:	e9 6e f0 ff ff       	jmp    80106a99 <alltraps>

80107a2b <vector229>:
.globl vector229
vector229:
  pushl $0
80107a2b:	6a 00                	push   $0x0
  pushl $229
80107a2d:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107a32:	e9 62 f0 ff ff       	jmp    80106a99 <alltraps>

80107a37 <vector230>:
.globl vector230
vector230:
  pushl $0
80107a37:	6a 00                	push   $0x0
  pushl $230
80107a39:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107a3e:	e9 56 f0 ff ff       	jmp    80106a99 <alltraps>

80107a43 <vector231>:
.globl vector231
vector231:
  pushl $0
80107a43:	6a 00                	push   $0x0
  pushl $231
80107a45:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107a4a:	e9 4a f0 ff ff       	jmp    80106a99 <alltraps>

80107a4f <vector232>:
.globl vector232
vector232:
  pushl $0
80107a4f:	6a 00                	push   $0x0
  pushl $232
80107a51:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107a56:	e9 3e f0 ff ff       	jmp    80106a99 <alltraps>

80107a5b <vector233>:
.globl vector233
vector233:
  pushl $0
80107a5b:	6a 00                	push   $0x0
  pushl $233
80107a5d:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107a62:	e9 32 f0 ff ff       	jmp    80106a99 <alltraps>

80107a67 <vector234>:
.globl vector234
vector234:
  pushl $0
80107a67:	6a 00                	push   $0x0
  pushl $234
80107a69:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107a6e:	e9 26 f0 ff ff       	jmp    80106a99 <alltraps>

80107a73 <vector235>:
.globl vector235
vector235:
  pushl $0
80107a73:	6a 00                	push   $0x0
  pushl $235
80107a75:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107a7a:	e9 1a f0 ff ff       	jmp    80106a99 <alltraps>

80107a7f <vector236>:
.globl vector236
vector236:
  pushl $0
80107a7f:	6a 00                	push   $0x0
  pushl $236
80107a81:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107a86:	e9 0e f0 ff ff       	jmp    80106a99 <alltraps>

80107a8b <vector237>:
.globl vector237
vector237:
  pushl $0
80107a8b:	6a 00                	push   $0x0
  pushl $237
80107a8d:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107a92:	e9 02 f0 ff ff       	jmp    80106a99 <alltraps>

80107a97 <vector238>:
.globl vector238
vector238:
  pushl $0
80107a97:	6a 00                	push   $0x0
  pushl $238
80107a99:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107a9e:	e9 f6 ef ff ff       	jmp    80106a99 <alltraps>

80107aa3 <vector239>:
.globl vector239
vector239:
  pushl $0
80107aa3:	6a 00                	push   $0x0
  pushl $239
80107aa5:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107aaa:	e9 ea ef ff ff       	jmp    80106a99 <alltraps>

80107aaf <vector240>:
.globl vector240
vector240:
  pushl $0
80107aaf:	6a 00                	push   $0x0
  pushl $240
80107ab1:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107ab6:	e9 de ef ff ff       	jmp    80106a99 <alltraps>

80107abb <vector241>:
.globl vector241
vector241:
  pushl $0
80107abb:	6a 00                	push   $0x0
  pushl $241
80107abd:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107ac2:	e9 d2 ef ff ff       	jmp    80106a99 <alltraps>

80107ac7 <vector242>:
.globl vector242
vector242:
  pushl $0
80107ac7:	6a 00                	push   $0x0
  pushl $242
80107ac9:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107ace:	e9 c6 ef ff ff       	jmp    80106a99 <alltraps>

80107ad3 <vector243>:
.globl vector243
vector243:
  pushl $0
80107ad3:	6a 00                	push   $0x0
  pushl $243
80107ad5:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107ada:	e9 ba ef ff ff       	jmp    80106a99 <alltraps>

80107adf <vector244>:
.globl vector244
vector244:
  pushl $0
80107adf:	6a 00                	push   $0x0
  pushl $244
80107ae1:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107ae6:	e9 ae ef ff ff       	jmp    80106a99 <alltraps>

80107aeb <vector245>:
.globl vector245
vector245:
  pushl $0
80107aeb:	6a 00                	push   $0x0
  pushl $245
80107aed:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107af2:	e9 a2 ef ff ff       	jmp    80106a99 <alltraps>

80107af7 <vector246>:
.globl vector246
vector246:
  pushl $0
80107af7:	6a 00                	push   $0x0
  pushl $246
80107af9:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107afe:	e9 96 ef ff ff       	jmp    80106a99 <alltraps>

80107b03 <vector247>:
.globl vector247
vector247:
  pushl $0
80107b03:	6a 00                	push   $0x0
  pushl $247
80107b05:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b0a:	e9 8a ef ff ff       	jmp    80106a99 <alltraps>

80107b0f <vector248>:
.globl vector248
vector248:
  pushl $0
80107b0f:	6a 00                	push   $0x0
  pushl $248
80107b11:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b16:	e9 7e ef ff ff       	jmp    80106a99 <alltraps>

80107b1b <vector249>:
.globl vector249
vector249:
  pushl $0
80107b1b:	6a 00                	push   $0x0
  pushl $249
80107b1d:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b22:	e9 72 ef ff ff       	jmp    80106a99 <alltraps>

80107b27 <vector250>:
.globl vector250
vector250:
  pushl $0
80107b27:	6a 00                	push   $0x0
  pushl $250
80107b29:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b2e:	e9 66 ef ff ff       	jmp    80106a99 <alltraps>

80107b33 <vector251>:
.globl vector251
vector251:
  pushl $0
80107b33:	6a 00                	push   $0x0
  pushl $251
80107b35:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107b3a:	e9 5a ef ff ff       	jmp    80106a99 <alltraps>

80107b3f <vector252>:
.globl vector252
vector252:
  pushl $0
80107b3f:	6a 00                	push   $0x0
  pushl $252
80107b41:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107b46:	e9 4e ef ff ff       	jmp    80106a99 <alltraps>

80107b4b <vector253>:
.globl vector253
vector253:
  pushl $0
80107b4b:	6a 00                	push   $0x0
  pushl $253
80107b4d:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107b52:	e9 42 ef ff ff       	jmp    80106a99 <alltraps>

80107b57 <vector254>:
.globl vector254
vector254:
  pushl $0
80107b57:	6a 00                	push   $0x0
  pushl $254
80107b59:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107b5e:	e9 36 ef ff ff       	jmp    80106a99 <alltraps>

80107b63 <vector255>:
.globl vector255
vector255:
  pushl $0
80107b63:	6a 00                	push   $0x0
  pushl $255
80107b65:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107b6a:	e9 2a ef ff ff       	jmp    80106a99 <alltraps>

80107b6f <lgdt>:
{
80107b6f:	55                   	push   %ebp
80107b70:	89 e5                	mov    %esp,%ebp
80107b72:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107b75:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b78:	83 e8 01             	sub    $0x1,%eax
80107b7b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80107b82:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107b86:	8b 45 08             	mov    0x8(%ebp),%eax
80107b89:	c1 e8 10             	shr    $0x10,%eax
80107b8c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107b90:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107b93:	0f 01 10             	lgdtl  (%eax)
}
80107b96:	90                   	nop
80107b97:	c9                   	leave  
80107b98:	c3                   	ret    

80107b99 <ltr>:
{
80107b99:	55                   	push   %ebp
80107b9a:	89 e5                	mov    %esp,%ebp
80107b9c:	83 ec 04             	sub    $0x4,%esp
80107b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80107ba2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107ba6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107baa:	0f 00 d8             	ltr    %ax
}
80107bad:	90                   	nop
80107bae:	c9                   	leave  
80107baf:	c3                   	ret    

80107bb0 <lcr3>:

static inline void
lcr3(uint val)
{
80107bb0:	55                   	push   %ebp
80107bb1:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80107bb6:	0f 22 d8             	mov    %eax,%cr3
}
80107bb9:	90                   	nop
80107bba:	5d                   	pop    %ebp
80107bbb:	c3                   	ret    

80107bbc <addtoworkingset>:
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "elf.h"

int addtoworkingset(char* va){
80107bbc:	f3 0f 1e fb          	endbr32 
80107bc0:	55                   	push   %ebp
80107bc1:	89 e5                	mov    %esp,%ebp
80107bc3:	83 ec 18             	sub    $0x18,%esp
  struct proc* curproc = myproc();
80107bc6:	e8 cb c8 ff ff       	call   80104496 <myproc>
80107bcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  

  if(curproc->queue_size < CLOCKSIZE) {
80107bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd1:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
80107bd7:	83 f8 07             	cmp    $0x7,%eax
80107bda:	7f 4f                	jg     80107c2b <addtoworkingset+0x6f>
    curproc->clock_queue[curproc->queue_size].va = va;
80107bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdf:	8b 90 c0 00 00 00    	mov    0xc0(%eax),%edx
80107be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be8:	8d 4a 10             	lea    0x10(%edx),%ecx
80107beb:	8b 55 08             	mov    0x8(%ebp),%edx
80107bee:	89 14 c8             	mov    %edx,(%eax,%ecx,8)
    curproc->clock_queue[curproc->queue_size].abit = 1;
80107bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf4:	8b 90 c0 00 00 00    	mov    0xc0(%eax),%edx
80107bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfd:	83 c2 10             	add    $0x10,%edx
80107c00:	0f b6 4c d0 04       	movzbl 0x4(%eax,%edx,8),%ecx
80107c05:	83 c9 01             	or     $0x1,%ecx
80107c08:	88 4c d0 04          	mov    %cl,0x4(%eax,%edx,8)
    curproc->queue_size++;
80107c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0f:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
80107c15:	8d 50 01             	lea    0x1(%eax),%edx
80107c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1b:	89 90 c0 00 00 00    	mov    %edx,0xc0(%eax)
    return 0;
80107c21:	b8 00 00 00 00       	mov    $0x0,%eax
80107c26:	e9 ee 00 00 00       	jmp    80107d19 <addtoworkingset+0x15d>
  }
  while(1) {
    cprintf("Evicted a female");
80107c2b:	83 ec 0c             	sub    $0xc,%esp
80107c2e:	68 00 97 10 80       	push   $0x80109700
80107c33:	e8 e0 87 ff ff       	call   80100418 <cprintf>
80107c38:	83 c4 10             	add    $0x10,%esp
    //struct clock_queue_slot* cur_hand = &curproc->clock_queue[curproc->hand];
    if(curproc->clock_queue[curproc->hand].abit == 0)
80107c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3e:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
80107c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c47:	83 c2 10             	add    $0x10,%edx
80107c4a:	0f b6 44 d0 04       	movzbl 0x4(%eax,%edx,8),%eax
80107c4f:	83 e0 01             	and    $0x1,%eax
80107c52:	84 c0                	test   %al,%al
80107c54:	74 45                	je     80107c9b <addtoworkingset+0xdf>
      break;
    curproc->clock_queue[curproc->hand].abit = 0;
80107c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c59:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
80107c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c62:	83 c2 10             	add    $0x10,%edx
80107c65:	0f b6 4c d0 04       	movzbl 0x4(%eax,%edx,8),%ecx
80107c6a:	83 e1 fe             	and    $0xfffffffe,%ecx
80107c6d:	88 4c d0 04          	mov    %cl,0x4(%eax,%edx,8)
    curproc->hand = (curproc->hand + 1) % CLOCKSIZE;
80107c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c74:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
80107c7a:	8d 50 01             	lea    0x1(%eax),%edx
80107c7d:	89 d0                	mov    %edx,%eax
80107c7f:	c1 f8 1f             	sar    $0x1f,%eax
80107c82:	c1 e8 1d             	shr    $0x1d,%eax
80107c85:	01 c2                	add    %eax,%edx
80107c87:	83 e2 07             	and    $0x7,%edx
80107c8a:	29 c2                	sub    %eax,%edx
80107c8c:	89 d0                	mov    %edx,%eax
80107c8e:	89 c2                	mov    %eax,%edx
80107c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c93:	89 90 c8 00 00 00    	mov    %edx,0xc8(%eax)
    cprintf("Evicted a female");
80107c99:	eb 90                	jmp    80107c2b <addtoworkingset+0x6f>
      break;
80107c9b:	90                   	nop
  }
  mencrypt(curproc->clock_queue[curproc->hand].va, 1);
80107c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9f:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
80107ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca8:	83 c2 10             	add    $0x10,%edx
80107cab:	8b 04 d0             	mov    (%eax,%edx,8),%eax
80107cae:	83 ec 08             	sub    $0x8,%esp
80107cb1:	6a 01                	push   $0x1
80107cb3:	50                   	push   %eax
80107cb4:	e8 29 10 00 00       	call   80108ce2 <mencrypt>
80107cb9:	83 c4 10             	add    $0x10,%esp
  curproc->clock_queue[curproc->hand].va = va;
80107cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbf:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
80107cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc8:	8d 4a 10             	lea    0x10(%edx),%ecx
80107ccb:	8b 55 08             	mov    0x8(%ebp),%edx
80107cce:	89 14 c8             	mov    %edx,(%eax,%ecx,8)
  curproc->clock_queue[curproc->hand].abit = 1;
80107cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd4:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
80107cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdd:	83 c2 10             	add    $0x10,%edx
80107ce0:	0f b6 4c d0 04       	movzbl 0x4(%eax,%edx,8),%ecx
80107ce5:	83 c9 01             	or     $0x1,%ecx
80107ce8:	88 4c d0 04          	mov    %cl,0x4(%eax,%edx,8)
  curproc->hand = (curproc->hand + 1) % CLOCKSIZE;
80107cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cef:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
80107cf5:	8d 50 01             	lea    0x1(%eax),%edx
80107cf8:	89 d0                	mov    %edx,%eax
80107cfa:	c1 f8 1f             	sar    $0x1f,%eax
80107cfd:	c1 e8 1d             	shr    $0x1d,%eax
80107d00:	01 c2                	add    %eax,%edx
80107d02:	83 e2 07             	and    $0x7,%edx
80107d05:	29 c2                	sub    %eax,%edx
80107d07:	89 d0                	mov    %edx,%eax
80107d09:	89 c2                	mov    %eax,%edx
80107d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0e:	89 90 c8 00 00 00    	mov    %edx,0xc8(%eax)
  return 0;
80107d14:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d19:	c9                   	leave  
80107d1a:	c3                   	ret    

80107d1b <removepage>:
int removepage(char* va) {
80107d1b:	f3 0f 1e fb          	endbr32 
80107d1f:	55                   	push   %ebp
80107d20:	89 e5                	mov    %esp,%ebp
80107d22:	56                   	push   %esi
80107d23:	53                   	push   %ebx
80107d24:	83 ec 10             	sub    $0x10,%esp
 
  struct proc* curproc = myproc();
80107d27:	e8 6a c7 ff ff       	call   80104496 <myproc>
80107d2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(int i = curproc->head; i < curproc->head + curproc->queue_size; i++){
80107d2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d32:	8b 80 c4 00 00 00    	mov    0xc4(%eax),%eax
80107d38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d3b:	e9 01 01 00 00       	jmp    80107e41 <removepage+0x126>
    if(curproc->clock_queue[i % CLOCKSIZE].va == va){
80107d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d43:	99                   	cltd   
80107d44:	c1 ea 1d             	shr    $0x1d,%edx
80107d47:	01 d0                	add    %edx,%eax
80107d49:	83 e0 07             	and    $0x7,%eax
80107d4c:	29 d0                	sub    %edx,%eax
80107d4e:	89 c2                	mov    %eax,%edx
80107d50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d53:	83 c2 10             	add    $0x10,%edx
80107d56:	8b 04 d0             	mov    (%eax,%edx,8),%eax
80107d59:	39 45 08             	cmp    %eax,0x8(%ebp)
80107d5c:	0f 85 db 00 00 00    	jne    80107e3d <removepage+0x122>
      for(int j = i; j+1 < curproc->hand + curproc->queue_size; j++){
80107d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d65:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d68:	eb 46                	jmp    80107db0 <removepage+0x95>
       curproc->clock_queue[j % CLOCKSIZE] = curproc->clock_queue[(j+1) % CLOCKSIZE];
80107d6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d6d:	8d 50 01             	lea    0x1(%eax),%edx
80107d70:	89 d0                	mov    %edx,%eax
80107d72:	c1 f8 1f             	sar    $0x1f,%eax
80107d75:	c1 e8 1d             	shr    $0x1d,%eax
80107d78:	01 c2                	add    %eax,%edx
80107d7a:	83 e2 07             	and    $0x7,%edx
80107d7d:	29 c2                	sub    %eax,%edx
80107d7f:	89 d0                	mov    %edx,%eax
80107d81:	89 c6                	mov    %eax,%esi
80107d83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d86:	99                   	cltd   
80107d87:	c1 ea 1d             	shr    $0x1d,%edx
80107d8a:	01 d0                	add    %edx,%eax
80107d8c:	83 e0 07             	and    $0x7,%eax
80107d8f:	29 d0                	sub    %edx,%eax
80107d91:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80107d94:	8d 58 10             	lea    0x10(%eax),%ebx
80107d97:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d9a:	8d 56 10             	lea    0x10(%esi),%edx
80107d9d:	8d 14 d0             	lea    (%eax,%edx,8),%edx
80107da0:	8b 02                	mov    (%edx),%eax
80107da2:	8b 52 04             	mov    0x4(%edx),%edx
80107da5:	89 04 d9             	mov    %eax,(%ecx,%ebx,8)
80107da8:	89 54 d9 04          	mov    %edx,0x4(%ecx,%ebx,8)
      for(int j = i; j+1 < curproc->hand + curproc->queue_size; j++){
80107dac:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80107db0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107db3:	8d 48 01             	lea    0x1(%eax),%ecx
80107db6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107db9:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
80107dbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107dc2:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
80107dc8:	01 d0                	add    %edx,%eax
80107dca:	39 c1                	cmp    %eax,%ecx
80107dcc:	7c 9c                	jl     80107d6a <removepage+0x4f>
     //  if(i == curproc->head + curproc->queue_size)
     //    curproc->hand = curproc->head;
     //  else
     //    curproc->hand = (curproc->hand + 1) % CLOCKSIZE;
     //}    
     if(i % CLOCKSIZE < curproc->head || curproc->hand > i)
80107dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd1:	99                   	cltd   
80107dd2:	c1 ea 1d             	shr    $0x1d,%edx
80107dd5:	01 d0                	add    %edx,%eax
80107dd7:	83 e0 07             	and    $0x7,%eax
80107dda:	29 d0                	sub    %edx,%eax
80107ddc:	89 c2                	mov    %eax,%edx
80107dde:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107de1:	8b 80 c4 00 00 00    	mov    0xc4(%eax),%eax
80107de7:	39 c2                	cmp    %eax,%edx
80107de9:	7c 0e                	jl     80107df9 <removepage+0xde>
80107deb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107dee:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
80107df4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80107df7:	7d 28                	jge    80107e21 <removepage+0x106>
       curproc->hand = (curproc->hand - 1) % CLOCKSIZE;
80107df9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107dfc:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
80107e02:	8d 50 ff             	lea    -0x1(%eax),%edx
80107e05:	89 d0                	mov    %edx,%eax
80107e07:	c1 f8 1f             	sar    $0x1f,%eax
80107e0a:	c1 e8 1d             	shr    $0x1d,%eax
80107e0d:	01 c2                	add    %eax,%edx
80107e0f:	83 e2 07             	and    $0x7,%edx
80107e12:	29 c2                	sub    %eax,%edx
80107e14:	89 d0                	mov    %edx,%eax
80107e16:	89 c2                	mov    %eax,%edx
80107e18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e1b:	89 90 c8 00 00 00    	mov    %edx,0xc8(%eax)
     //  if(curproc->queue_size > 1)
     //    curproc->head = (curproc->head + 1) % CLOCKSIZE;
     
    // }

     curproc->queue_size--;
80107e21:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e24:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
80107e2a:	8d 50 ff             	lea    -0x1(%eax),%edx
80107e2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e30:	89 90 c0 00 00 00    	mov    %edx,0xc0(%eax)
     return 0;
80107e36:	b8 00 00 00 00       	mov    $0x0,%eax
80107e3b:	eb 26                	jmp    80107e63 <removepage+0x148>
  for(int i = curproc->head; i < curproc->head + curproc->queue_size; i++){
80107e3d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e44:	8b 90 c4 00 00 00    	mov    0xc4(%eax),%edx
80107e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e4d:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
80107e53:	01 d0                	add    %edx,%eax
80107e55:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80107e58:	0f 8c e2 fe ff ff    	jl     80107d40 <removepage+0x25>
   }
 }
 return 0;
80107e5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e63:	83 c4 10             	add    $0x10,%esp
80107e66:	5b                   	pop    %ebx
80107e67:	5e                   	pop    %esi
80107e68:	5d                   	pop    %ebp
80107e69:	c3                   	ret    

80107e6a <inwset>:


int inwset(char* va){
80107e6a:	f3 0f 1e fb          	endbr32 
80107e6e:	55                   	push   %ebp
80107e6f:	89 e5                	mov    %esp,%ebp
80107e71:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80107e74:	e8 1d c6 ff ff       	call   80104496 <myproc>
80107e79:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(int i = 0; i < curproc->queue_size; i++){
80107e7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e83:	eb 3c                	jmp    80107ec1 <inwset+0x57>
    if(curproc->clock_queue[i % CLOCKSIZE].va == va){
80107e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e88:	99                   	cltd   
80107e89:	c1 ea 1d             	shr    $0x1d,%edx
80107e8c:	01 d0                	add    %edx,%eax
80107e8e:	83 e0 07             	and    $0x7,%eax
80107e91:	29 d0                	sub    %edx,%eax
80107e93:	89 c2                	mov    %eax,%edx
80107e95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e98:	83 c2 10             	add    $0x10,%edx
80107e9b:	8b 04 d0             	mov    (%eax,%edx,8),%eax
80107e9e:	39 45 08             	cmp    %eax,0x8(%ebp)
80107ea1:	75 1a                	jne    80107ebd <inwset+0x53>
      cprintf("Found %p", va);
80107ea3:	83 ec 08             	sub    $0x8,%esp
80107ea6:	ff 75 08             	pushl  0x8(%ebp)
80107ea9:	68 11 97 10 80       	push   $0x80109711
80107eae:	e8 65 85 ff ff       	call   80100418 <cprintf>
80107eb3:	83 c4 10             	add    $0x10,%esp
      return 1;
80107eb6:	b8 01 00 00 00       	mov    $0x1,%eax
80107ebb:	eb 17                	jmp    80107ed4 <inwset+0x6a>
  for(int i = 0; i < curproc->queue_size; i++){
80107ebd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ec4:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
80107eca:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80107ecd:	7c b6                	jl     80107e85 <inwset+0x1b>
  }
  }
  return 0;
80107ecf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ed4:	c9                   	leave  
80107ed5:	c3                   	ret    

80107ed6 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107ed6:	f3 0f 1e fb          	endbr32 
80107eda:	55                   	push   %ebp
80107edb:	89 e5                	mov    %esp,%ebp
80107edd:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107ee0:	e8 16 c5 ff ff       	call   801043fb <cpuid>
80107ee5:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107eeb:	05 20 48 11 80       	add    $0x80114820,%eax
80107ef0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef6:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eff:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f08:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107f13:	83 e2 f0             	and    $0xfffffff0,%edx
80107f16:	83 ca 0a             	or     $0xa,%edx
80107f19:	88 50 7d             	mov    %dl,0x7d(%eax)
80107f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107f23:	83 ca 10             	or     $0x10,%edx
80107f26:	88 50 7d             	mov    %dl,0x7d(%eax)
80107f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107f30:	83 e2 9f             	and    $0xffffff9f,%edx
80107f33:	88 50 7d             	mov    %dl,0x7d(%eax)
80107f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f39:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107f3d:	83 ca 80             	or     $0xffffff80,%edx
80107f40:	88 50 7d             	mov    %dl,0x7d(%eax)
80107f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f46:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107f4a:	83 ca 0f             	or     $0xf,%edx
80107f4d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f53:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107f57:	83 e2 ef             	and    $0xffffffef,%edx
80107f5a:	88 50 7e             	mov    %dl,0x7e(%eax)
80107f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f60:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107f64:	83 e2 df             	and    $0xffffffdf,%edx
80107f67:	88 50 7e             	mov    %dl,0x7e(%eax)
80107f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107f71:	83 ca 40             	or     $0x40,%edx
80107f74:	88 50 7e             	mov    %dl,0x7e(%eax)
80107f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107f7e:	83 ca 80             	or     $0xffffff80,%edx
80107f81:	88 50 7e             	mov    %dl,0x7e(%eax)
80107f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f87:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8e:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107f95:	ff ff 
80107f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9a:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107fa1:	00 00 
80107fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa6:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107fb7:	83 e2 f0             	and    $0xfffffff0,%edx
80107fba:	83 ca 02             	or     $0x2,%edx
80107fbd:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107fcd:	83 ca 10             	or     $0x10,%edx
80107fd0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107fe0:	83 e2 9f             	and    $0xffffff9f,%edx
80107fe3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fec:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ff3:	83 ca 80             	or     $0xffffff80,%edx
80107ff6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fff:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108006:	83 ca 0f             	or     $0xf,%edx
80108009:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010800f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108012:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108019:	83 e2 ef             	and    $0xffffffef,%edx
8010801c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108025:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010802c:	83 e2 df             	and    $0xffffffdf,%edx
8010802f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108038:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010803f:	83 ca 40             	or     $0x40,%edx
80108042:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108052:	83 ca 80             	or     $0xffffff80,%edx
80108055:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010805b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010805e:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108068:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010806f:	ff ff 
80108071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108074:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010807b:	00 00 
8010807d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108080:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80108087:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010808a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108091:	83 e2 f0             	and    $0xfffffff0,%edx
80108094:	83 ca 0a             	or     $0xa,%edx
80108097:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010809d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801080a7:	83 ca 10             	or     $0x10,%edx
801080aa:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801080b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b3:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801080ba:	83 ca 60             	or     $0x60,%edx
801080bd:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801080c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801080cd:	83 ca 80             	or     $0xffffff80,%edx
801080d0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801080d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801080e0:	83 ca 0f             	or     $0xf,%edx
801080e3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801080e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ec:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801080f3:	83 e2 ef             	and    $0xffffffef,%edx
801080f6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801080fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ff:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108106:	83 e2 df             	and    $0xffffffdf,%edx
80108109:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010810f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108112:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108119:	83 ca 40             	or     $0x40,%edx
8010811c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108125:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010812c:	83 ca 80             	or     $0xffffff80,%edx
8010812f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108135:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108138:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010813f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108142:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108149:	ff ff 
8010814b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010814e:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108155:	00 00 
80108157:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010815a:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108161:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108164:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010816b:	83 e2 f0             	and    $0xfffffff0,%edx
8010816e:	83 ca 02             	or     $0x2,%edx
80108171:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010817a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108181:	83 ca 10             	or     $0x10,%edx
80108184:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010818a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108194:	83 ca 60             	or     $0x60,%edx
80108197:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010819d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801081a7:	83 ca 80             	or     $0xffffff80,%edx
801081aa:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801081b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801081ba:	83 ca 0f             	or     $0xf,%edx
801081bd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801081c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801081cd:	83 e2 ef             	and    $0xffffffef,%edx
801081d0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801081d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801081e0:	83 e2 df             	and    $0xffffffdf,%edx
801081e3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801081e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ec:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801081f3:	83 ca 40             	or     $0x40,%edx
801081f6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801081fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ff:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108206:	83 ca 80             	or     $0xffffff80,%edx
80108209:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010820f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108212:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80108219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010821c:	83 c0 70             	add    $0x70,%eax
8010821f:	83 ec 08             	sub    $0x8,%esp
80108222:	6a 30                	push   $0x30
80108224:	50                   	push   %eax
80108225:	e8 45 f9 ff ff       	call   80107b6f <lgdt>
8010822a:	83 c4 10             	add    $0x10,%esp
}
8010822d:	90                   	nop
8010822e:	c9                   	leave  
8010822f:	c3                   	ret    

80108230 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108230:	f3 0f 1e fb          	endbr32 
80108234:	55                   	push   %ebp
80108235:	89 e5                	mov    %esp,%ebp
80108237:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010823a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010823d:	c1 e8 16             	shr    $0x16,%eax
80108240:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108247:	8b 45 08             	mov    0x8(%ebp),%eax
8010824a:	01 d0                	add    %edx,%eax
8010824c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){//No need to check PTE_E here.
8010824f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108252:	8b 00                	mov    (%eax),%eax
80108254:	83 e0 01             	and    $0x1,%eax
80108257:	85 c0                	test   %eax,%eax
80108259:	74 14                	je     8010826f <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010825b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010825e:	8b 00                	mov    (%eax),%eax
80108260:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108265:	05 00 00 00 80       	add    $0x80000000,%eax
8010826a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010826d:	eb 42                	jmp    801082b1 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010826f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108273:	74 0e                	je     80108283 <walkpgdir+0x53>
80108275:	e8 7e ab ff ff       	call   80102df8 <kalloc>
8010827a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010827d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108281:	75 07                	jne    8010828a <walkpgdir+0x5a>
      return 0;
80108283:	b8 00 00 00 00       	mov    $0x0,%eax
80108288:	eb 3e                	jmp    801082c8 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010828a:	83 ec 04             	sub    $0x4,%esp
8010828d:	68 00 10 00 00       	push   $0x1000
80108292:	6a 00                	push   $0x0
80108294:	ff 75 f4             	pushl  -0xc(%ebp)
80108297:	e8 91 d2 ff ff       	call   8010552d <memset>
8010829c:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010829f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a2:	05 00 00 00 80       	add    $0x80000000,%eax
801082a7:	83 c8 07             	or     $0x7,%eax
801082aa:	89 c2                	mov    %eax,%edx
801082ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082af:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801082b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801082b4:	c1 e8 0c             	shr    $0xc,%eax
801082b7:	25 ff 03 00 00       	and    $0x3ff,%eax
801082bc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c6:	01 d0                	add    %edx,%eax
}
801082c8:	c9                   	leave  
801082c9:	c3                   	ret    

801082ca <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801082ca:	f3 0f 1e fb          	endbr32 
801082ce:	55                   	push   %ebp
801082cf:	89 e5                	mov    %esp,%ebp
801082d1:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801082d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801082d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801082df:	8b 55 0c             	mov    0xc(%ebp),%edx
801082e2:	8b 45 10             	mov    0x10(%ebp),%eax
801082e5:	01 d0                	add    %edx,%eax
801082e7:	83 e8 01             	sub    $0x1,%eax
801082ea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801082f2:	83 ec 04             	sub    $0x4,%esp
801082f5:	6a 01                	push   $0x1
801082f7:	ff 75 f4             	pushl  -0xc(%ebp)
801082fa:	ff 75 08             	pushl  0x8(%ebp)
801082fd:	e8 2e ff ff ff       	call   80108230 <walkpgdir>
80108302:	83 c4 10             	add    $0x10,%esp
80108305:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108308:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010830c:	75 07                	jne    80108315 <mappages+0x4b>
      return -1;
8010830e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108313:	eb 6f                	jmp    80108384 <mappages+0xba>
    if(*pte & (PTE_P | PTE_E))
80108315:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108318:	8b 00                	mov    (%eax),%eax
8010831a:	25 01 04 00 00       	and    $0x401,%eax
8010831f:	85 c0                	test   %eax,%eax
80108321:	74 0d                	je     80108330 <mappages+0x66>
      panic("remap");
80108323:	83 ec 0c             	sub    $0xc,%esp
80108326:	68 1a 97 10 80       	push   $0x8010971a
8010832b:	e8 d8 82 ff ff       	call   80100608 <panic>
    
    //"perm" is just the lower 12 bits of the PTE
    //if encrypted, then ensure that PTE_P is not set
    //This is somewhat redundant. If our code is correct,
    //we should just be able to say pa | perm
    if (perm & PTE_E)
80108330:	8b 45 18             	mov    0x18(%ebp),%eax
80108333:	25 00 04 00 00       	and    $0x400,%eax
80108338:	85 c0                	test   %eax,%eax
8010833a:	74 17                	je     80108353 <mappages+0x89>
      *pte = (pa | perm | PTE_E) & ~PTE_P;
8010833c:	8b 45 18             	mov    0x18(%ebp),%eax
8010833f:	0b 45 14             	or     0x14(%ebp),%eax
80108342:	25 fe fb ff ff       	and    $0xfffffbfe,%eax
80108347:	80 cc 04             	or     $0x4,%ah
8010834a:	89 c2                	mov    %eax,%edx
8010834c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010834f:	89 10                	mov    %edx,(%eax)
80108351:	eb 10                	jmp    80108363 <mappages+0x99>
    else
      *pte = pa | perm | PTE_P;
80108353:	8b 45 18             	mov    0x18(%ebp),%eax
80108356:	0b 45 14             	or     0x14(%ebp),%eax
80108359:	83 c8 01             	or     $0x1,%eax
8010835c:	89 c2                	mov    %eax,%edx
8010835e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108361:	89 10                	mov    %edx,(%eax)


    if(a == last)
80108363:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108366:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108369:	74 13                	je     8010837e <mappages+0xb4>
      break;
    a += PGSIZE;
8010836b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108372:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108379:	e9 74 ff ff ff       	jmp    801082f2 <mappages+0x28>
      break;
8010837e:	90                   	nop
  }
  return 0;
8010837f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108384:	c9                   	leave  
80108385:	c3                   	ret    

80108386 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108386:	f3 0f 1e fb          	endbr32 
8010838a:	55                   	push   %ebp
8010838b:	89 e5                	mov    %esp,%ebp
8010838d:	53                   	push   %ebx
8010838e:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108391:	e8 62 aa ff ff       	call   80102df8 <kalloc>
80108396:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108399:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010839d:	75 07                	jne    801083a6 <setupkvm+0x20>
    return 0;
8010839f:	b8 00 00 00 00       	mov    $0x0,%eax
801083a4:	eb 78                	jmp    8010841e <setupkvm+0x98>
  memset(pgdir, 0, PGSIZE);
801083a6:	83 ec 04             	sub    $0x4,%esp
801083a9:	68 00 10 00 00       	push   $0x1000
801083ae:	6a 00                	push   $0x0
801083b0:	ff 75 f0             	pushl  -0x10(%ebp)
801083b3:	e8 75 d1 ff ff       	call   8010552d <memset>
801083b8:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801083bb:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
801083c2:	eb 4e                	jmp    80108412 <setupkvm+0x8c>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801083c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c7:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801083ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cd:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801083d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d3:	8b 58 08             	mov    0x8(%eax),%ebx
801083d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d9:	8b 40 04             	mov    0x4(%eax),%eax
801083dc:	29 c3                	sub    %eax,%ebx
801083de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e1:	8b 00                	mov    (%eax),%eax
801083e3:	83 ec 0c             	sub    $0xc,%esp
801083e6:	51                   	push   %ecx
801083e7:	52                   	push   %edx
801083e8:	53                   	push   %ebx
801083e9:	50                   	push   %eax
801083ea:	ff 75 f0             	pushl  -0x10(%ebp)
801083ed:	e8 d8 fe ff ff       	call   801082ca <mappages>
801083f2:	83 c4 20             	add    $0x20,%esp
801083f5:	85 c0                	test   %eax,%eax
801083f7:	79 15                	jns    8010840e <setupkvm+0x88>
      freevm(pgdir);
801083f9:	83 ec 0c             	sub    $0xc,%esp
801083fc:	ff 75 f0             	pushl  -0x10(%ebp)
801083ff:	e8 2f 05 00 00       	call   80108933 <freevm>
80108404:	83 c4 10             	add    $0x10,%esp
      return 0;
80108407:	b8 00 00 00 00       	mov    $0x0,%eax
8010840c:	eb 10                	jmp    8010841e <setupkvm+0x98>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010840e:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108412:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108419:	72 a9                	jb     801083c4 <setupkvm+0x3e>
    }
  return pgdir;
8010841b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010841e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108421:	c9                   	leave  
80108422:	c3                   	ret    

80108423 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108423:	f3 0f 1e fb          	endbr32 
80108427:	55                   	push   %ebp
80108428:	89 e5                	mov    %esp,%ebp
8010842a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010842d:	e8 54 ff ff ff       	call   80108386 <setupkvm>
80108432:	a3 44 89 11 80       	mov    %eax,0x80118944
  switchkvm();
80108437:	e8 03 00 00 00       	call   8010843f <switchkvm>
}
8010843c:	90                   	nop
8010843d:	c9                   	leave  
8010843e:	c3                   	ret    

8010843f <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010843f:	f3 0f 1e fb          	endbr32 
80108443:	55                   	push   %ebp
80108444:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108446:	a1 44 89 11 80       	mov    0x80118944,%eax
8010844b:	05 00 00 00 80       	add    $0x80000000,%eax
80108450:	50                   	push   %eax
80108451:	e8 5a f7 ff ff       	call   80107bb0 <lcr3>
80108456:	83 c4 04             	add    $0x4,%esp
}
80108459:	90                   	nop
8010845a:	c9                   	leave  
8010845b:	c3                   	ret    

8010845c <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010845c:	f3 0f 1e fb          	endbr32 
80108460:	55                   	push   %ebp
80108461:	89 e5                	mov    %esp,%ebp
80108463:	56                   	push   %esi
80108464:	53                   	push   %ebx
80108465:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80108468:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010846c:	75 0d                	jne    8010847b <switchuvm+0x1f>
    panic("switchuvm: no process");
8010846e:	83 ec 0c             	sub    $0xc,%esp
80108471:	68 20 97 10 80       	push   $0x80109720
80108476:	e8 8d 81 ff ff       	call   80100608 <panic>
  if(p->kstack == 0)
8010847b:	8b 45 08             	mov    0x8(%ebp),%eax
8010847e:	8b 40 08             	mov    0x8(%eax),%eax
80108481:	85 c0                	test   %eax,%eax
80108483:	75 0d                	jne    80108492 <switchuvm+0x36>
    panic("switchuvm: no kstack");
80108485:	83 ec 0c             	sub    $0xc,%esp
80108488:	68 36 97 10 80       	push   $0x80109736
8010848d:	e8 76 81 ff ff       	call   80100608 <panic>
  if(p->pgdir == 0)
80108492:	8b 45 08             	mov    0x8(%ebp),%eax
80108495:	8b 40 04             	mov    0x4(%eax),%eax
80108498:	85 c0                	test   %eax,%eax
8010849a:	75 0d                	jne    801084a9 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
8010849c:	83 ec 0c             	sub    $0xc,%esp
8010849f:	68 4b 97 10 80       	push   $0x8010974b
801084a4:	e8 5f 81 ff ff       	call   80100608 <panic>

  pushcli();
801084a9:	e8 6c cf ff ff       	call   8010541a <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801084ae:	e8 67 bf ff ff       	call   8010441a <mycpu>
801084b3:	89 c3                	mov    %eax,%ebx
801084b5:	e8 60 bf ff ff       	call   8010441a <mycpu>
801084ba:	83 c0 08             	add    $0x8,%eax
801084bd:	89 c6                	mov    %eax,%esi
801084bf:	e8 56 bf ff ff       	call   8010441a <mycpu>
801084c4:	83 c0 08             	add    $0x8,%eax
801084c7:	c1 e8 10             	shr    $0x10,%eax
801084ca:	88 45 f7             	mov    %al,-0x9(%ebp)
801084cd:	e8 48 bf ff ff       	call   8010441a <mycpu>
801084d2:	83 c0 08             	add    $0x8,%eax
801084d5:	c1 e8 18             	shr    $0x18,%eax
801084d8:	89 c2                	mov    %eax,%edx
801084da:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801084e1:	67 00 
801084e3:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801084ea:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801084ee:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801084f4:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801084fb:	83 e0 f0             	and    $0xfffffff0,%eax
801084fe:	83 c8 09             	or     $0x9,%eax
80108501:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108507:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010850e:	83 c8 10             	or     $0x10,%eax
80108511:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108517:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010851e:	83 e0 9f             	and    $0xffffff9f,%eax
80108521:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108527:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010852e:	83 c8 80             	or     $0xffffff80,%eax
80108531:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108537:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010853e:	83 e0 f0             	and    $0xfffffff0,%eax
80108541:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108547:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010854e:	83 e0 ef             	and    $0xffffffef,%eax
80108551:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108557:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010855e:	83 e0 df             	and    $0xffffffdf,%eax
80108561:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108567:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010856e:	83 c8 40             	or     $0x40,%eax
80108571:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108577:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010857e:	83 e0 7f             	and    $0x7f,%eax
80108581:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108587:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010858d:	e8 88 be ff ff       	call   8010441a <mycpu>
80108592:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108599:	83 e2 ef             	and    $0xffffffef,%edx
8010859c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801085a2:	e8 73 be ff ff       	call   8010441a <mycpu>
801085a7:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801085ad:	8b 45 08             	mov    0x8(%ebp),%eax
801085b0:	8b 40 08             	mov    0x8(%eax),%eax
801085b3:	89 c3                	mov    %eax,%ebx
801085b5:	e8 60 be ff ff       	call   8010441a <mycpu>
801085ba:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801085c0:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801085c3:	e8 52 be ff ff       	call   8010441a <mycpu>
801085c8:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801085ce:	83 ec 0c             	sub    $0xc,%esp
801085d1:	6a 28                	push   $0x28
801085d3:	e8 c1 f5 ff ff       	call   80107b99 <ltr>
801085d8:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801085db:	8b 45 08             	mov    0x8(%ebp),%eax
801085de:	8b 40 04             	mov    0x4(%eax),%eax
801085e1:	05 00 00 00 80       	add    $0x80000000,%eax
801085e6:	83 ec 0c             	sub    $0xc,%esp
801085e9:	50                   	push   %eax
801085ea:	e8 c1 f5 ff ff       	call   80107bb0 <lcr3>
801085ef:	83 c4 10             	add    $0x10,%esp
  popcli();
801085f2:	e8 74 ce ff ff       	call   8010546b <popcli>
}
801085f7:	90                   	nop
801085f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801085fb:	5b                   	pop    %ebx
801085fc:	5e                   	pop    %esi
801085fd:	5d                   	pop    %ebp
801085fe:	c3                   	ret    

801085ff <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801085ff:	f3 0f 1e fb          	endbr32 
80108603:	55                   	push   %ebp
80108604:	89 e5                	mov    %esp,%ebp
80108606:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108609:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108610:	76 0d                	jbe    8010861f <inituvm+0x20>
    panic("inituvm: more than a page");
80108612:	83 ec 0c             	sub    $0xc,%esp
80108615:	68 5f 97 10 80       	push   $0x8010975f
8010861a:	e8 e9 7f ff ff       	call   80100608 <panic>
  mem = kalloc();
8010861f:	e8 d4 a7 ff ff       	call   80102df8 <kalloc>
80108624:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108627:	83 ec 04             	sub    $0x4,%esp
8010862a:	68 00 10 00 00       	push   $0x1000
8010862f:	6a 00                	push   $0x0
80108631:	ff 75 f4             	pushl  -0xc(%ebp)
80108634:	e8 f4 ce ff ff       	call   8010552d <memset>
80108639:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010863c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863f:	05 00 00 00 80       	add    $0x80000000,%eax
80108644:	83 ec 0c             	sub    $0xc,%esp
80108647:	6a 06                	push   $0x6
80108649:	50                   	push   %eax
8010864a:	68 00 10 00 00       	push   $0x1000
8010864f:	6a 00                	push   $0x0
80108651:	ff 75 08             	pushl  0x8(%ebp)
80108654:	e8 71 fc ff ff       	call   801082ca <mappages>
80108659:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010865c:	83 ec 04             	sub    $0x4,%esp
8010865f:	ff 75 10             	pushl  0x10(%ebp)
80108662:	ff 75 0c             	pushl  0xc(%ebp)
80108665:	ff 75 f4             	pushl  -0xc(%ebp)
80108668:	e8 87 cf ff ff       	call   801055f4 <memmove>
8010866d:	83 c4 10             	add    $0x10,%esp
}
80108670:	90                   	nop
80108671:	c9                   	leave  
80108672:	c3                   	ret    

80108673 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108673:	f3 0f 1e fb          	endbr32 
80108677:	55                   	push   %ebp
80108678:	89 e5                	mov    %esp,%ebp
8010867a:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010867d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108680:	25 ff 0f 00 00       	and    $0xfff,%eax
80108685:	85 c0                	test   %eax,%eax
80108687:	74 0d                	je     80108696 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80108689:	83 ec 0c             	sub    $0xc,%esp
8010868c:	68 7c 97 10 80       	push   $0x8010977c
80108691:	e8 72 7f ff ff       	call   80100608 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108696:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010869d:	e9 8f 00 00 00       	jmp    80108731 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801086a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801086a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a8:	01 d0                	add    %edx,%eax
801086aa:	83 ec 04             	sub    $0x4,%esp
801086ad:	6a 00                	push   $0x0
801086af:	50                   	push   %eax
801086b0:	ff 75 08             	pushl  0x8(%ebp)
801086b3:	e8 78 fb ff ff       	call   80108230 <walkpgdir>
801086b8:	83 c4 10             	add    $0x10,%esp
801086bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
801086be:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086c2:	75 0d                	jne    801086d1 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801086c4:	83 ec 0c             	sub    $0xc,%esp
801086c7:	68 9f 97 10 80       	push   $0x8010979f
801086cc:	e8 37 7f ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
801086d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086d4:	8b 00                	mov    (%eax),%eax
801086d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086db:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801086de:	8b 45 18             	mov    0x18(%ebp),%eax
801086e1:	2b 45 f4             	sub    -0xc(%ebp),%eax
801086e4:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801086e9:	77 0b                	ja     801086f6 <loaduvm+0x83>
      n = sz - i;
801086eb:	8b 45 18             	mov    0x18(%ebp),%eax
801086ee:	2b 45 f4             	sub    -0xc(%ebp),%eax
801086f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801086f4:	eb 07                	jmp    801086fd <loaduvm+0x8a>
    else
      n = PGSIZE;
801086f6:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801086fd:	8b 55 14             	mov    0x14(%ebp),%edx
80108700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108703:	01 d0                	add    %edx,%eax
80108705:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108708:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010870e:	ff 75 f0             	pushl  -0x10(%ebp)
80108711:	50                   	push   %eax
80108712:	52                   	push   %edx
80108713:	ff 75 10             	pushl  0x10(%ebp)
80108716:	e8 f5 98 ff ff       	call   80102010 <readi>
8010871b:	83 c4 10             	add    $0x10,%esp
8010871e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108721:	74 07                	je     8010872a <loaduvm+0xb7>
      return -1;
80108723:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108728:	eb 18                	jmp    80108742 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
8010872a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108731:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108734:	3b 45 18             	cmp    0x18(%ebp),%eax
80108737:	0f 82 65 ff ff ff    	jb     801086a2 <loaduvm+0x2f>
  }
  return 0;
8010873d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108742:	c9                   	leave  
80108743:	c3                   	ret    

80108744 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108744:	f3 0f 1e fb          	endbr32 
80108748:	55                   	push   %ebp
80108749:	89 e5                	mov    %esp,%ebp
8010874b:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010874e:	8b 45 10             	mov    0x10(%ebp),%eax
80108751:	85 c0                	test   %eax,%eax
80108753:	79 0a                	jns    8010875f <allocuvm+0x1b>
    return 0;
80108755:	b8 00 00 00 00       	mov    $0x0,%eax
8010875a:	e9 ec 00 00 00       	jmp    8010884b <allocuvm+0x107>
  if(newsz < oldsz)
8010875f:	8b 45 10             	mov    0x10(%ebp),%eax
80108762:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108765:	73 08                	jae    8010876f <allocuvm+0x2b>
    return oldsz;
80108767:	8b 45 0c             	mov    0xc(%ebp),%eax
8010876a:	e9 dc 00 00 00       	jmp    8010884b <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
8010876f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108772:	05 ff 0f 00 00       	add    $0xfff,%eax
80108777:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010877c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010877f:	e9 b8 00 00 00       	jmp    8010883c <allocuvm+0xf8>
    mem = kalloc();
80108784:	e8 6f a6 ff ff       	call   80102df8 <kalloc>
80108789:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010878c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108790:	75 2e                	jne    801087c0 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80108792:	83 ec 0c             	sub    $0xc,%esp
80108795:	68 bd 97 10 80       	push   $0x801097bd
8010879a:	e8 79 7c ff ff       	call   80100418 <cprintf>
8010879f:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801087a2:	83 ec 04             	sub    $0x4,%esp
801087a5:	ff 75 0c             	pushl  0xc(%ebp)
801087a8:	ff 75 10             	pushl  0x10(%ebp)
801087ab:	ff 75 08             	pushl  0x8(%ebp)
801087ae:	e8 9a 00 00 00       	call   8010884d <deallocuvm>
801087b3:	83 c4 10             	add    $0x10,%esp
      return 0;
801087b6:	b8 00 00 00 00       	mov    $0x0,%eax
801087bb:	e9 8b 00 00 00       	jmp    8010884b <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
801087c0:	83 ec 04             	sub    $0x4,%esp
801087c3:	68 00 10 00 00       	push   $0x1000
801087c8:	6a 00                	push   $0x0
801087ca:	ff 75 f0             	pushl  -0x10(%ebp)
801087cd:	e8 5b cd ff ff       	call   8010552d <memset>
801087d2:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801087d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087d8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801087de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e1:	83 ec 0c             	sub    $0xc,%esp
801087e4:	6a 06                	push   $0x6
801087e6:	52                   	push   %edx
801087e7:	68 00 10 00 00       	push   $0x1000
801087ec:	50                   	push   %eax
801087ed:	ff 75 08             	pushl  0x8(%ebp)
801087f0:	e8 d5 fa ff ff       	call   801082ca <mappages>
801087f5:	83 c4 20             	add    $0x20,%esp
801087f8:	85 c0                	test   %eax,%eax
801087fa:	79 39                	jns    80108835 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
801087fc:	83 ec 0c             	sub    $0xc,%esp
801087ff:	68 d5 97 10 80       	push   $0x801097d5
80108804:	e8 0f 7c ff ff       	call   80100418 <cprintf>
80108809:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010880c:	83 ec 04             	sub    $0x4,%esp
8010880f:	ff 75 0c             	pushl  0xc(%ebp)
80108812:	ff 75 10             	pushl  0x10(%ebp)
80108815:	ff 75 08             	pushl  0x8(%ebp)
80108818:	e8 30 00 00 00       	call   8010884d <deallocuvm>
8010881d:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108820:	83 ec 0c             	sub    $0xc,%esp
80108823:	ff 75 f0             	pushl  -0x10(%ebp)
80108826:	e8 2f a5 ff ff       	call   80102d5a <kfree>
8010882b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010882e:	b8 00 00 00 00       	mov    $0x0,%eax
80108833:	eb 16                	jmp    8010884b <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80108835:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010883c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883f:	3b 45 10             	cmp    0x10(%ebp),%eax
80108842:	0f 82 3c ff ff ff    	jb     80108784 <allocuvm+0x40>
    }
  }
  return newsz;
80108848:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010884b:	c9                   	leave  
8010884c:	c3                   	ret    

8010884d <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010884d:	f3 0f 1e fb          	endbr32 
80108851:	55                   	push   %ebp
80108852:	89 e5                	mov    %esp,%ebp
80108854:	83 ec 28             	sub    $0x28,%esp
 
  struct proc* curproc = myproc();
80108857:	e8 3a bc ff ff       	call   80104496 <myproc>
8010885c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pgdir != curproc->pgdir){
8010885f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108862:	8b 40 04             	mov    0x4(%eax),%eax
80108865:	39 45 08             	cmp    %eax,0x8(%ebp)
80108868:	74 09                	je     80108873 <deallocuvm+0x26>
    curproc = curproc->child;
8010886a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010886d:	8b 40 18             	mov    0x18(%eax),%eax
80108870:	89 45 f0             	mov    %eax,-0x10(%ebp)
  }

  pte_t *pte;
  uint a, pa;
 
  if(newsz >= oldsz)
80108873:	8b 45 10             	mov    0x10(%ebp),%eax
80108876:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108879:	72 08                	jb     80108883 <deallocuvm+0x36>
    return oldsz;
8010887b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010887e:	e9 ae 00 00 00       	jmp    80108931 <deallocuvm+0xe4>

  a = PGROUNDUP(newsz);
80108883:	8b 45 10             	mov    0x10(%ebp),%eax
80108886:	05 ff 0f 00 00       	add    $0xfff,%eax
8010888b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108890:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108893:	e9 8a 00 00 00       	jmp    80108922 <deallocuvm+0xd5>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889b:	83 ec 04             	sub    $0x4,%esp
8010889e:	6a 00                	push   $0x0
801088a0:	50                   	push   %eax
801088a1:	ff 75 08             	pushl  0x8(%ebp)
801088a4:	e8 87 f9 ff ff       	call   80108230 <walkpgdir>
801088a9:	83 c4 10             	add    $0x10,%esp
801088ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(!pte)
801088af:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801088b3:	75 16                	jne    801088cb <deallocuvm+0x7e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801088b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b8:	c1 e8 16             	shr    $0x16,%eax
801088bb:	83 c0 01             	add    $0x1,%eax
801088be:	c1 e0 16             	shl    $0x16,%eax
801088c1:	2d 00 10 00 00       	sub    $0x1000,%eax
801088c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801088c9:	eb 50                	jmp    8010891b <deallocuvm+0xce>
    else if((*pte & (PTE_P | PTE_E)) != 0){
801088cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088ce:	8b 00                	mov    (%eax),%eax
801088d0:	25 01 04 00 00       	and    $0x401,%eax
801088d5:	85 c0                	test   %eax,%eax
801088d7:	74 42                	je     8010891b <deallocuvm+0xce>
      pa = PTE_ADDR(*pte);
801088d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088dc:	8b 00                	mov    (%eax),%eax
801088de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(pa == 0)
801088e6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801088ea:	75 0d                	jne    801088f9 <deallocuvm+0xac>
        panic("kfree");
801088ec:	83 ec 0c             	sub    $0xc,%esp
801088ef:	68 f1 97 10 80       	push   $0x801097f1
801088f4:	e8 0f 7d ff ff       	call   80100608 <panic>
      char *v = P2V(pa);
801088f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088fc:	05 00 00 00 80       	add    $0x80000000,%eax
80108901:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v);
80108904:	83 ec 0c             	sub    $0xc,%esp
80108907:	ff 75 e4             	pushl  -0x1c(%ebp)
8010890a:	e8 4b a4 ff ff       	call   80102d5a <kfree>
8010890f:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108912:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108915:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010891b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108925:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108928:	0f 82 6a ff ff ff    	jb     80108898 <deallocuvm+0x4b>
    }
  }
  return newsz;
8010892e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108931:	c9                   	leave  
80108932:	c3                   	ret    

80108933 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108933:	f3 0f 1e fb          	endbr32 
80108937:	55                   	push   %ebp
80108938:	89 e5                	mov    %esp,%ebp
8010893a:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010893d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108941:	75 0d                	jne    80108950 <freevm+0x1d>
    panic("freevm: no pgdir");
80108943:	83 ec 0c             	sub    $0xc,%esp
80108946:	68 f7 97 10 80       	push   $0x801097f7
8010894b:	e8 b8 7c ff ff       	call   80100608 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108950:	83 ec 04             	sub    $0x4,%esp
80108953:	6a 00                	push   $0x0
80108955:	68 00 00 00 80       	push   $0x80000000
8010895a:	ff 75 08             	pushl  0x8(%ebp)
8010895d:	e8 eb fe ff ff       	call   8010884d <deallocuvm>
80108962:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108965:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010896c:	eb 48                	jmp    801089b6 <freevm+0x83>
    //you don't need to check for PTE_E here because
    //this is a pde_t, where PTE_E doesn't get set
    if(pgdir[i] & PTE_P){
8010896e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108971:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108978:	8b 45 08             	mov    0x8(%ebp),%eax
8010897b:	01 d0                	add    %edx,%eax
8010897d:	8b 00                	mov    (%eax),%eax
8010897f:	83 e0 01             	and    $0x1,%eax
80108982:	85 c0                	test   %eax,%eax
80108984:	74 2c                	je     801089b2 <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108989:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108990:	8b 45 08             	mov    0x8(%ebp),%eax
80108993:	01 d0                	add    %edx,%eax
80108995:	8b 00                	mov    (%eax),%eax
80108997:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010899c:	05 00 00 00 80       	add    $0x80000000,%eax
801089a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801089a4:	83 ec 0c             	sub    $0xc,%esp
801089a7:	ff 75 f0             	pushl  -0x10(%ebp)
801089aa:	e8 ab a3 ff ff       	call   80102d5a <kfree>
801089af:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801089b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801089b6:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801089bd:	76 af                	jbe    8010896e <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
801089bf:	83 ec 0c             	sub    $0xc,%esp
801089c2:	ff 75 08             	pushl  0x8(%ebp)
801089c5:	e8 90 a3 ff ff       	call   80102d5a <kfree>
801089ca:	83 c4 10             	add    $0x10,%esp
}
801089cd:	90                   	nop
801089ce:	c9                   	leave  
801089cf:	c3                   	ret    

801089d0 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801089d0:	f3 0f 1e fb          	endbr32 
801089d4:	55                   	push   %ebp
801089d5:	89 e5                	mov    %esp,%ebp
801089d7:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801089da:	83 ec 04             	sub    $0x4,%esp
801089dd:	6a 00                	push   $0x0
801089df:	ff 75 0c             	pushl  0xc(%ebp)
801089e2:	ff 75 08             	pushl  0x8(%ebp)
801089e5:	e8 46 f8 ff ff       	call   80108230 <walkpgdir>
801089ea:	83 c4 10             	add    $0x10,%esp
801089ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801089f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801089f4:	75 0d                	jne    80108a03 <clearpteu+0x33>
    panic("clearpteu");
801089f6:	83 ec 0c             	sub    $0xc,%esp
801089f9:	68 08 98 10 80       	push   $0x80109808
801089fe:	e8 05 7c ff ff       	call   80100608 <panic>
  *pte &= ~PTE_U;
80108a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a06:	8b 00                	mov    (%eax),%eax
80108a08:	83 e0 fb             	and    $0xfffffffb,%eax
80108a0b:	89 c2                	mov    %eax,%edx
80108a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a10:	89 10                	mov    %edx,(%eax)
}
80108a12:	90                   	nop
80108a13:	c9                   	leave  
80108a14:	c3                   	ret    

80108a15 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108a15:	f3 0f 1e fb          	endbr32 
80108a19:	55                   	push   %ebp
80108a1a:	89 e5                	mov    %esp,%ebp
80108a1c:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108a1f:	e8 62 f9 ff ff       	call   80108386 <setupkvm>
80108a24:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a2b:	75 0a                	jne    80108a37 <copyuvm+0x22>
    return 0;
80108a2d:	b8 00 00 00 00       	mov    $0x0,%eax
80108a32:	e9 fa 00 00 00       	jmp    80108b31 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108a37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a3e:	e9 c9 00 00 00       	jmp    80108b0c <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a46:	83 ec 04             	sub    $0x4,%esp
80108a49:	6a 00                	push   $0x0
80108a4b:	50                   	push   %eax
80108a4c:	ff 75 08             	pushl  0x8(%ebp)
80108a4f:	e8 dc f7 ff ff       	call   80108230 <walkpgdir>
80108a54:	83 c4 10             	add    $0x10,%esp
80108a57:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a5a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a5e:	75 0d                	jne    80108a6d <copyuvm+0x58>
      panic("copyuvm: pte should exist");
80108a60:	83 ec 0c             	sub    $0xc,%esp
80108a63:	68 12 98 10 80       	push   $0x80109812
80108a68:	e8 9b 7b ff ff       	call   80100608 <panic>
    if(!(*pte & (PTE_P | PTE_E)))
80108a6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a70:	8b 00                	mov    (%eax),%eax
80108a72:	25 01 04 00 00       	and    $0x401,%eax
80108a77:	85 c0                	test   %eax,%eax
80108a79:	75 0d                	jne    80108a88 <copyuvm+0x73>
      panic("copyuvm: page not present");
80108a7b:	83 ec 0c             	sub    $0xc,%esp
80108a7e:	68 2c 98 10 80       	push   $0x8010982c
80108a83:	e8 80 7b ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
80108a88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a8b:	8b 00                	mov    (%eax),%eax
80108a8d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a92:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108a95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a98:	8b 00                	mov    (%eax),%eax
80108a9a:	25 ff 0f 00 00       	and    $0xfff,%eax
80108a9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108aa2:	e8 51 a3 ff ff       	call   80102df8 <kalloc>
80108aa7:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108aaa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108aae:	74 6d                	je     80108b1d <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108ab0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ab3:	05 00 00 00 80       	add    $0x80000000,%eax
80108ab8:	83 ec 04             	sub    $0x4,%esp
80108abb:	68 00 10 00 00       	push   $0x1000
80108ac0:	50                   	push   %eax
80108ac1:	ff 75 e0             	pushl  -0x20(%ebp)
80108ac4:	e8 2b cb ff ff       	call   801055f4 <memmove>
80108ac9:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80108acc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108acf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ad2:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108adb:	83 ec 0c             	sub    $0xc,%esp
80108ade:	52                   	push   %edx
80108adf:	51                   	push   %ecx
80108ae0:	68 00 10 00 00       	push   $0x1000
80108ae5:	50                   	push   %eax
80108ae6:	ff 75 f0             	pushl  -0x10(%ebp)
80108ae9:	e8 dc f7 ff ff       	call   801082ca <mappages>
80108aee:	83 c4 20             	add    $0x20,%esp
80108af1:	85 c0                	test   %eax,%eax
80108af3:	79 10                	jns    80108b05 <copyuvm+0xf0>
      kfree(mem);
80108af5:	83 ec 0c             	sub    $0xc,%esp
80108af8:	ff 75 e0             	pushl  -0x20(%ebp)
80108afb:	e8 5a a2 ff ff       	call   80102d5a <kfree>
80108b00:	83 c4 10             	add    $0x10,%esp
      goto bad;
80108b03:	eb 19                	jmp    80108b1e <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80108b05:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b0f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108b12:	0f 82 2b ff ff ff    	jb     80108a43 <copyuvm+0x2e>
    }
  }
  return d;
80108b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b1b:	eb 14                	jmp    80108b31 <copyuvm+0x11c>
      goto bad;
80108b1d:	90                   	nop

bad:
  freevm(d);
80108b1e:	83 ec 0c             	sub    $0xc,%esp
80108b21:	ff 75 f0             	pushl  -0x10(%ebp)
80108b24:	e8 0a fe ff ff       	call   80108933 <freevm>
80108b29:	83 c4 10             	add    $0x10,%esp
  return 0;
80108b2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108b31:	c9                   	leave  
80108b32:	c3                   	ret    

80108b33 <uva2ka>:
// KVA -> PA
// PA -> KVA
// KVA = PA + KERNBASE
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108b33:	f3 0f 1e fb          	endbr32 
80108b37:	55                   	push   %ebp
80108b38:	89 e5                	mov    %esp,%ebp
80108b3a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108b3d:	83 ec 04             	sub    $0x4,%esp
80108b40:	6a 00                	push   $0x0
80108b42:	ff 75 0c             	pushl  0xc(%ebp)
80108b45:	ff 75 08             	pushl  0x8(%ebp)
80108b48:	e8 e3 f6 ff ff       	call   80108230 <walkpgdir>
80108b4d:	83 c4 10             	add    $0x10,%esp
80108b50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //TODO: uva2ka says not present if PTE_P is 0
  if(((*pte & PTE_P) | (*pte & PTE_E)) == 0)
80108b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b56:	8b 00                	mov    (%eax),%eax
80108b58:	25 01 04 00 00       	and    $0x401,%eax
80108b5d:	85 c0                	test   %eax,%eax
80108b5f:	75 07                	jne    80108b68 <uva2ka+0x35>
    return 0;
80108b61:	b8 00 00 00 00       	mov    $0x0,%eax
80108b66:	eb 22                	jmp    80108b8a <uva2ka+0x57>
  if((*pte & PTE_U) == 0)
80108b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b6b:	8b 00                	mov    (%eax),%eax
80108b6d:	83 e0 04             	and    $0x4,%eax
80108b70:	85 c0                	test   %eax,%eax
80108b72:	75 07                	jne    80108b7b <uva2ka+0x48>
    return 0;
80108b74:	b8 00 00 00 00       	mov    $0x0,%eax
80108b79:	eb 0f                	jmp    80108b8a <uva2ka+0x57>
  return (char*)P2V(PTE_ADDR(*pte));
80108b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b7e:	8b 00                	mov    (%eax),%eax
80108b80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b85:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108b8a:	c9                   	leave  
80108b8b:	c3                   	ret    

80108b8c <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108b8c:	f3 0f 1e fb          	endbr32 
80108b90:	55                   	push   %ebp
80108b91:	89 e5                	mov    %esp,%ebp
80108b93:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108b96:	8b 45 10             	mov    0x10(%ebp),%eax
80108b99:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108b9c:	eb 7f                	jmp    80108c1d <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ba1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ba6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //TODO: what happens if you copyout to an encrypted page?
    pa0 = uva2ka(pgdir, (char*)va0);
80108ba9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bac:	83 ec 08             	sub    $0x8,%esp
80108baf:	50                   	push   %eax
80108bb0:	ff 75 08             	pushl  0x8(%ebp)
80108bb3:	e8 7b ff ff ff       	call   80108b33 <uva2ka>
80108bb8:	83 c4 10             	add    $0x10,%esp
80108bbb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0) {
80108bbe:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108bc2:	75 07                	jne    80108bcb <copyout+0x3f>
      return -1;
80108bc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108bc9:	eb 61                	jmp    80108c2c <copyout+0xa0>
    }
    n = PGSIZE - (va - va0);
80108bcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bce:	2b 45 0c             	sub    0xc(%ebp),%eax
80108bd1:	05 00 10 00 00       	add    $0x1000,%eax
80108bd6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108bd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bdc:	3b 45 14             	cmp    0x14(%ebp),%eax
80108bdf:	76 06                	jbe    80108be7 <copyout+0x5b>
      n = len;
80108be1:	8b 45 14             	mov    0x14(%ebp),%eax
80108be4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108be7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bea:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108bed:	89 c2                	mov    %eax,%edx
80108bef:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bf2:	01 d0                	add    %edx,%eax
80108bf4:	83 ec 04             	sub    $0x4,%esp
80108bf7:	ff 75 f0             	pushl  -0x10(%ebp)
80108bfa:	ff 75 f4             	pushl  -0xc(%ebp)
80108bfd:	50                   	push   %eax
80108bfe:	e8 f1 c9 ff ff       	call   801055f4 <memmove>
80108c03:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c09:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108c0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c0f:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108c12:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c15:	05 00 10 00 00       	add    $0x1000,%eax
80108c1a:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108c1d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108c21:	0f 85 77 ff ff ff    	jne    80108b9e <copyout+0x12>
  }
  return 0;
80108c27:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c2c:	c9                   	leave  
80108c2d:	c3                   	ret    

80108c2e <mdecrypt>:


//returns 0 on success
int mdecrypt(char *virtual_addr) {
80108c2e:	f3 0f 1e fb          	endbr32 
80108c32:	55                   	push   %ebp
80108c33:	89 e5                	mov    %esp,%ebp
80108c35:	83 ec 28             	sub    $0x28,%esp
  //cprintf("mdecrypt: VPN %d, %p, pid %d\n", PPN(virtual_addr), virtual_addr, myproc()->pid);
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
80108c38:	e8 59 b8 ff ff       	call   80104496 <myproc>
80108c3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pde_t* mypd = p->pgdir;
80108c40:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c43:	8b 40 04             	mov    0x4(%eax),%eax
80108c46:	89 45 e8             	mov    %eax,-0x18(%ebp)
  //set the present bit to true and encrypt bit to false
  pte_t * pte = walkpgdir(mypd, virtual_addr, 0);
80108c49:	83 ec 04             	sub    $0x4,%esp
80108c4c:	6a 00                	push   $0x0
80108c4e:	ff 75 08             	pushl  0x8(%ebp)
80108c51:	ff 75 e8             	pushl  -0x18(%ebp)
80108c54:	e8 d7 f5 ff ff       	call   80108230 <walkpgdir>
80108c59:	83 c4 10             	add    $0x10,%esp
80108c5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (!pte || *pte == 0) {
80108c5f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108c63:	74 09                	je     80108c6e <mdecrypt+0x40>
80108c65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108c68:	8b 00                	mov    (%eax),%eax
80108c6a:	85 c0                	test   %eax,%eax
80108c6c:	75 07                	jne    80108c75 <mdecrypt+0x47>
    return -1;
80108c6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c73:	eb 6b                	jmp    80108ce0 <mdecrypt+0xb2>
  }

  *pte = *pte & ~PTE_E;
80108c75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108c78:	8b 00                	mov    (%eax),%eax
80108c7a:	80 e4 fb             	and    $0xfb,%ah
80108c7d:	89 c2                	mov    %eax,%edx
80108c7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108c82:	89 10                	mov    %edx,(%eax)
  *pte = *pte | PTE_P;
80108c84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108c87:	8b 00                	mov    (%eax),%eax
80108c89:	83 c8 01             	or     $0x1,%eax
80108c8c:	89 c2                	mov    %eax,%edx
80108c8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108c91:	89 10                	mov    %edx,(%eax)

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108c93:	8b 45 08             	mov    0x8(%ebp),%eax
80108c96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c9b:	89 45 08             	mov    %eax,0x8(%ebp)

  char * slider = virtual_addr;
80108c9e:	8b 45 08             	mov    0x8(%ebp),%eax
80108ca1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108ca4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108cab:	eb 17                	jmp    80108cc4 <mdecrypt+0x96>
    *slider = ~*slider;
80108cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb0:	0f b6 00             	movzbl (%eax),%eax
80108cb3:	f7 d0                	not    %eax
80108cb5:	89 c2                	mov    %eax,%edx
80108cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cba:	88 10                	mov    %dl,(%eax)
    slider++;
80108cbc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108cc0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108cc4:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80108ccb:	7e e0                	jle    80108cad <mdecrypt+0x7f>
  }
  addtoworkingset(virtual_addr);
80108ccd:	83 ec 0c             	sub    $0xc,%esp
80108cd0:	ff 75 08             	pushl  0x8(%ebp)
80108cd3:	e8 e4 ee ff ff       	call   80107bbc <addtoworkingset>
80108cd8:	83 c4 10             	add    $0x10,%esp
  return 0;
80108cdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108ce0:	c9                   	leave  
80108ce1:	c3                   	ret    

80108ce2 <mencrypt>:

int mencrypt(char *virtual_addr, int len) {
80108ce2:	f3 0f 1e fb          	endbr32 
80108ce6:	55                   	push   %ebp
80108ce7:	89 e5                	mov    %esp,%ebp
80108ce9:	83 ec 28             	sub    $0x28,%esp
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
80108cec:	e8 a5 b7 ff ff       	call   80104496 <myproc>
80108cf1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t* mypd = p->pgdir;
80108cf4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108cf7:	8b 40 04             	mov    0x4(%eax),%eax
80108cfa:	89 45 e0             	mov    %eax,-0x20(%ebp)

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108cfd:	8b 45 08             	mov    0x8(%ebp),%eax
80108d00:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d05:	89 45 08             	mov    %eax,0x8(%ebp)

  //error checking first. all or nothing.
  char * slider = virtual_addr;
80108d08:	8b 45 08             	mov    0x8(%ebp),%eax
80108d0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108d0e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108d15:	eb 3f                	jmp    80108d56 <mencrypt+0x74>
    //check page table for each translation first
    char * kvp = uva2ka(mypd, slider);
80108d17:	83 ec 08             	sub    $0x8,%esp
80108d1a:	ff 75 f4             	pushl  -0xc(%ebp)
80108d1d:	ff 75 e0             	pushl  -0x20(%ebp)
80108d20:	e8 0e fe ff ff       	call   80108b33 <uva2ka>
80108d25:	83 c4 10             	add    $0x10,%esp
80108d28:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if (!kvp) {
80108d2b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80108d2f:	75 1a                	jne    80108d4b <mencrypt+0x69>
      cprintf("mencrypt: Could not access address\n");
80108d31:	83 ec 0c             	sub    $0xc,%esp
80108d34:	68 48 98 10 80       	push   $0x80109848
80108d39:	e8 da 76 ff ff       	call   80100418 <cprintf>
80108d3e:	83 c4 10             	add    $0x10,%esp
      return -1;
80108d41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d46:	e9 b8 00 00 00       	jmp    80108e03 <mencrypt+0x121>
    }
    slider = slider + PGSIZE;
80108d4b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108d52:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d59:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108d5c:	7c b9                	jl     80108d17 <mencrypt+0x35>
  }

  //encrypt stage. Have to do this before setting flag 
  //or else we'll page fault
  slider = virtual_addr;
80108d5e:	8b 45 08             	mov    0x8(%ebp),%eax
80108d61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108d64:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108d6b:	eb 78                	jmp    80108de5 <mencrypt+0x103>
    //we get the page table entry that corresponds to this VA
    pte_t * mypte = walkpgdir(mypd, slider, 0);
80108d6d:	83 ec 04             	sub    $0x4,%esp
80108d70:	6a 00                	push   $0x0
80108d72:	ff 75 f4             	pushl  -0xc(%ebp)
80108d75:	ff 75 e0             	pushl  -0x20(%ebp)
80108d78:	e8 b3 f4 ff ff       	call   80108230 <walkpgdir>
80108d7d:	83 c4 10             	add    $0x10,%esp
80108d80:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (*mypte & PTE_E) {//already encrypted
80108d83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108d86:	8b 00                	mov    (%eax),%eax
80108d88:	25 00 04 00 00       	and    $0x400,%eax
80108d8d:	85 c0                	test   %eax,%eax
80108d8f:	74 09                	je     80108d9a <mencrypt+0xb8>
      slider += PGSIZE;
80108d91:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      continue;
80108d98:	eb 47                	jmp    80108de1 <mencrypt+0xff>
    }
    for (int offset = 0; offset < PGSIZE; offset++) {
80108d9a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80108da1:	eb 17                	jmp    80108dba <mencrypt+0xd8>
      *slider = ~*slider;
80108da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da6:	0f b6 00             	movzbl (%eax),%eax
80108da9:	f7 d0                	not    %eax
80108dab:	89 c2                	mov    %eax,%edx
80108dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108db0:	88 10                	mov    %dl,(%eax)
      slider++;
80108db2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    for (int offset = 0; offset < PGSIZE; offset++) {
80108db6:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80108dba:	81 7d e8 ff 0f 00 00 	cmpl   $0xfff,-0x18(%ebp)
80108dc1:	7e e0                	jle    80108da3 <mencrypt+0xc1>
    }
    *mypte = *mypte & ~PTE_P;
80108dc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108dc6:	8b 00                	mov    (%eax),%eax
80108dc8:	83 e0 fe             	and    $0xfffffffe,%eax
80108dcb:	89 c2                	mov    %eax,%edx
80108dcd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108dd0:	89 10                	mov    %edx,(%eax)
    *mypte = *mypte | PTE_E;
80108dd2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108dd5:	8b 00                	mov    (%eax),%eax
80108dd7:	80 cc 04             	or     $0x4,%ah
80108dda:	89 c2                	mov    %eax,%edx
80108ddc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ddf:	89 10                	mov    %edx,(%eax)
  for (int i = 0; i < len; i++) { 
80108de1:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108de5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108de8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108deb:	7c 80                	jl     80108d6d <mencrypt+0x8b>
  }

  switchuvm(myproc());
80108ded:	e8 a4 b6 ff ff       	call   80104496 <myproc>
80108df2:	83 ec 0c             	sub    $0xc,%esp
80108df5:	50                   	push   %eax
80108df6:	e8 61 f6 ff ff       	call   8010845c <switchuvm>
80108dfb:	83 c4 10             	add    $0x10,%esp
  return 0;
80108dfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108e03:	c9                   	leave  
80108e04:	c3                   	ret    

80108e05 <getpgtable>:

int getpgtable(struct pt_entry* entries, int num, int wsetOnly) {
80108e05:	f3 0f 1e fb          	endbr32 
80108e09:	55                   	push   %ebp
80108e0a:	89 e5                	mov    %esp,%ebp
80108e0c:	83 ec 28             	sub    $0x28,%esp
  struct proc * me = myproc();
80108e0f:	e8 82 b6 ff ff       	call   80104496 <myproc>
80108e14:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(wsetOnly != 0 && wsetOnly != 1)
80108e17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108e1b:	74 10                	je     80108e2d <getpgtable+0x28>
80108e1d:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
80108e21:	74 0a                	je     80108e2d <getpgtable+0x28>
    return -1;
80108e23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e28:	e9 c2 01 00 00       	jmp    80108fef <getpgtable+0x1ea>
  int index = 0;
80108e2d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  int old_index = 0;
80108e34:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  pte_t * curr_pte;
  //reverse order
  
  for (void * i = (void*) PGROUNDDOWN(((int)me->sz)); i >= 0 && old_index < num; i-=PGSIZE) {
80108e3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e3e:	8b 00                	mov    (%eax),%eax
80108e40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e45:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108e48:	e9 90 01 00 00       	jmp    80108fdd <getpgtable+0x1d8>
    //walk through the page table and read the entries
    

    if(wsetOnly){
80108e4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108e51:	74 1b                	je     80108e6e <getpgtable+0x69>
      if(!inwset(i)) {
80108e53:	83 ec 0c             	sub    $0xc,%esp
80108e56:	ff 75 ec             	pushl  -0x14(%ebp)
80108e59:	e8 0c f0 ff ff       	call   80107e6a <inwset>
80108e5e:	83 c4 10             	add    $0x10,%esp
80108e61:	85 c0                	test   %eax,%eax
80108e63:	75 09                	jne    80108e6e <getpgtable+0x69>
         old_index++;
80108e65:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
         continue;
80108e69:	e9 68 01 00 00       	jmp    80108fd6 <getpgtable+0x1d1>
      }
    }
    //Those entries contain the physical page number + flags
    curr_pte = walkpgdir(me->pgdir, i, 0);
80108e6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e71:	8b 40 04             	mov    0x4(%eax),%eax
80108e74:	83 ec 04             	sub    $0x4,%esp
80108e77:	6a 00                	push   $0x0
80108e79:	ff 75 ec             	pushl  -0x14(%ebp)
80108e7c:	50                   	push   %eax
80108e7d:	e8 ae f3 ff ff       	call   80108230 <walkpgdir>
80108e82:	83 c4 10             	add    $0x10,%esp
80108e85:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    //currPage is 0 if page is not allocated
    //see deallocuvm
    if (curr_pte && *curr_pte) {//this page is allocated
80108e88:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108e8c:	0f 84 3e 01 00 00    	je     80108fd0 <getpgtable+0x1cb>
80108e92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e95:	8b 00                	mov    (%eax),%eax
80108e97:	85 c0                	test   %eax,%eax
80108e99:	0f 84 31 01 00 00    	je     80108fd0 <getpgtable+0x1cb>
      //this is the same for all pt_entries... right?
      entries[index].pdx = PDX(i); 
80108e9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ea2:	c1 e8 16             	shr    $0x16,%eax
80108ea5:	89 c1                	mov    %eax,%ecx
80108ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eaa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108eb1:	8b 45 08             	mov    0x8(%ebp),%eax
80108eb4:	01 c2                	add    %eax,%edx
80108eb6:	89 c8                	mov    %ecx,%eax
80108eb8:	66 25 ff 03          	and    $0x3ff,%ax
80108ebc:	66 25 ff 03          	and    $0x3ff,%ax
80108ec0:	89 c1                	mov    %eax,%ecx
80108ec2:	0f b7 02             	movzwl (%edx),%eax
80108ec5:	66 25 00 fc          	and    $0xfc00,%ax
80108ec9:	09 c8                	or     %ecx,%eax
80108ecb:	66 89 02             	mov    %ax,(%edx)
      entries[index].ptx = PTX(i);
80108ece:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ed1:	c1 e8 0c             	shr    $0xc,%eax
80108ed4:	89 c1                	mov    %eax,%ecx
80108ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ed9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80108ee3:	01 c2                	add    %eax,%edx
80108ee5:	89 c8                	mov    %ecx,%eax
80108ee7:	66 25 ff 03          	and    $0x3ff,%ax
80108eeb:	0f b7 c0             	movzwl %ax,%eax
80108eee:	25 ff 03 00 00       	and    $0x3ff,%eax
80108ef3:	c1 e0 0a             	shl    $0xa,%eax
80108ef6:	89 c1                	mov    %eax,%ecx
80108ef8:	8b 02                	mov    (%edx),%eax
80108efa:	25 ff 03 f0 ff       	and    $0xfff003ff,%eax
80108eff:	09 c8                	or     %ecx,%eax
80108f01:	89 02                	mov    %eax,(%edx)
      //convert to physical addr then shift to get PPN 
      entries[index].ppage = PPN(*curr_pte);
80108f03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f06:	8b 00                	mov    (%eax),%eax
80108f08:	c1 e8 0c             	shr    $0xc,%eax
80108f0b:	89 c2                	mov    %eax,%edx
80108f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f10:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108f17:	8b 45 08             	mov    0x8(%ebp),%eax
80108f1a:	01 c8                	add    %ecx,%eax
80108f1c:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
80108f22:	89 d1                	mov    %edx,%ecx
80108f24:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
80108f2a:	8b 50 04             	mov    0x4(%eax),%edx
80108f2d:	81 e2 00 00 f0 ff    	and    $0xfff00000,%edx
80108f33:	09 ca                	or     %ecx,%edx
80108f35:	89 50 04             	mov    %edx,0x4(%eax)
      //have to set it like this because these are 1 bit wide fields
      entries[index].present = (*curr_pte & PTE_P) ? 1 : 0;
80108f38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f3b:	8b 08                	mov    (%eax),%ecx
80108f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f40:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108f47:	8b 45 08             	mov    0x8(%ebp),%eax
80108f4a:	01 c2                	add    %eax,%edx
80108f4c:	89 c8                	mov    %ecx,%eax
80108f4e:	83 e0 01             	and    $0x1,%eax
80108f51:	83 e0 01             	and    $0x1,%eax
80108f54:	c1 e0 04             	shl    $0x4,%eax
80108f57:	89 c1                	mov    %eax,%ecx
80108f59:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80108f5d:	83 e0 ef             	and    $0xffffffef,%eax
80108f60:	09 c8                	or     %ecx,%eax
80108f62:	88 42 06             	mov    %al,0x6(%edx)
      entries[index].writable = (*curr_pte & PTE_W) ? 1 : 0;
80108f65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f68:	8b 00                	mov    (%eax),%eax
80108f6a:	d1 e8                	shr    %eax
80108f6c:	89 c1                	mov    %eax,%ecx
80108f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f71:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108f78:	8b 45 08             	mov    0x8(%ebp),%eax
80108f7b:	01 c2                	add    %eax,%edx
80108f7d:	89 c8                	mov    %ecx,%eax
80108f7f:	83 e0 01             	and    $0x1,%eax
80108f82:	83 e0 01             	and    $0x1,%eax
80108f85:	c1 e0 05             	shl    $0x5,%eax
80108f88:	89 c1                	mov    %eax,%ecx
80108f8a:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80108f8e:	83 e0 df             	and    $0xffffffdf,%eax
80108f91:	09 c8                	or     %ecx,%eax
80108f93:	88 42 06             	mov    %al,0x6(%edx)
      entries[index].encrypted = (*curr_pte & PTE_E) ? 1 : 0;
80108f96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f99:	8b 00                	mov    (%eax),%eax
80108f9b:	c1 e8 0a             	shr    $0xa,%eax
80108f9e:	89 c1                	mov    %eax,%ecx
80108fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fa3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108faa:	8b 45 08             	mov    0x8(%ebp),%eax
80108fad:	01 c2                	add    %eax,%edx
80108faf:	89 c8                	mov    %ecx,%eax
80108fb1:	83 e0 01             	and    $0x1,%eax
80108fb4:	83 e0 01             	and    $0x1,%eax
80108fb7:	c1 e0 06             	shl    $0x6,%eax
80108fba:	89 c1                	mov    %eax,%ecx
80108fbc:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80108fc0:	83 e0 bf             	and    $0xffffffbf,%eax
80108fc3:	09 c8                	or     %ecx,%eax
80108fc5:	88 42 06             	mov    %al,0x6(%edx)
      index++;
80108fc8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      old_index++;
80108fcc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    }

    if (i == 0) {
80108fd0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108fd4:	74 15                	je     80108feb <getpgtable+0x1e6>
  for (void * i = (void*) PGROUNDDOWN(((int)me->sz)); i >= 0 && old_index < num; i-=PGSIZE) {
80108fd6:	81 6d ec 00 10 00 00 	subl   $0x1000,-0x14(%ebp)
80108fdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fe0:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108fe3:	0f 8c 64 fe ff ff    	jl     80108e4d <getpgtable+0x48>
80108fe9:	eb 01                	jmp    80108fec <getpgtable+0x1e7>
      break;
80108feb:	90                   	nop
    }
  }
  //index is the number of ptes copied
  return old_index;
80108fec:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108fef:	c9                   	leave  
80108ff0:	c3                   	ret    

80108ff1 <dump_rawphymem>:


int dump_rawphymem(uint physical_addr, char * buffer) {
80108ff1:	f3 0f 1e fb          	endbr32 
80108ff5:	55                   	push   %ebp
80108ff6:	89 e5                	mov    %esp,%ebp
80108ff8:	56                   	push   %esi
80108ff9:	53                   	push   %ebx
80108ffa:	83 ec 10             	sub    $0x10,%esp
  //note that copyout converts buffer to a kva and then copies
  //which means that if buffer is encrypted, it won't trigger a decryption request
  *buffer = *buffer;
80108ffd:	8b 45 0c             	mov    0xc(%ebp),%eax
80109000:	0f b6 10             	movzbl (%eax),%edx
80109003:	8b 45 0c             	mov    0xc(%ebp),%eax
80109006:	88 10                	mov    %dl,(%eax)
  int retval = copyout(myproc()->pgdir, (uint) buffer, (void *) P2V(physical_addr), PGSIZE);
80109008:	8b 45 08             	mov    0x8(%ebp),%eax
8010900b:	05 00 00 00 80       	add    $0x80000000,%eax
80109010:	89 c6                	mov    %eax,%esi
80109012:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80109015:	e8 7c b4 ff ff       	call   80104496 <myproc>
8010901a:	8b 40 04             	mov    0x4(%eax),%eax
8010901d:	68 00 10 00 00       	push   $0x1000
80109022:	56                   	push   %esi
80109023:	53                   	push   %ebx
80109024:	50                   	push   %eax
80109025:	e8 62 fb ff ff       	call   80108b8c <copyout>
8010902a:	83 c4 10             	add    $0x10,%esp
8010902d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (retval)
80109030:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109034:	74 07                	je     8010903d <dump_rawphymem+0x4c>
    return -1;
80109036:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010903b:	eb 05                	jmp    80109042 <dump_rawphymem+0x51>
  return 0;
8010903d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109042:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109045:	5b                   	pop    %ebx
80109046:	5e                   	pop    %esi
80109047:	5d                   	pop    %ebp
80109048:	c3                   	ret    
