
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
8010002d:	b8 2e 3a 10 80       	mov    $0x80103a2e,%eax
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
80100041:	68 f8 91 10 80       	push   $0x801091f8
80100046:	68 60 d6 10 80       	push   $0x8010d660
8010004b:	e8 61 52 00 00       	call   801052b1 <initlock>
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
8010008f:	68 ff 91 10 80       	push   $0x801091ff
80100094:	50                   	push   %eax
80100095:	e8 84 50 00 00       	call   8010511e <initsleeplock>
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
801000d7:	e8 fb 51 00 00       	call   801052d7 <acquire>
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
80100116:	e8 2e 52 00 00       	call   80105349 <release>
8010011b:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	83 c0 0c             	add    $0xc,%eax
80100124:	83 ec 0c             	sub    $0xc,%esp
80100127:	50                   	push   %eax
80100128:	e8 31 50 00 00       	call   8010515e <acquiresleep>
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
80100197:	e8 ad 51 00 00       	call   80105349 <release>
8010019c:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010019f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a2:	83 c0 0c             	add    $0xc,%eax
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	50                   	push   %eax
801001a9:	e8 b0 4f 00 00       	call   8010515e <acquiresleep>
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
801001cb:	68 06 92 10 80       	push   $0x80109206
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
80100207:	e8 a7 28 00 00       	call   80102ab3 <iderw>
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
80100228:	e8 eb 4f 00 00       	call   80105218 <holdingsleep>
8010022d:	83 c4 10             	add    $0x10,%esp
80100230:	85 c0                	test   %eax,%eax
80100232:	75 0d                	jne    80100241 <bwrite+0x2d>
    panic("bwrite");
80100234:	83 ec 0c             	sub    $0xc,%esp
80100237:	68 17 92 10 80       	push   $0x80109217
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
80100256:	e8 58 28 00 00       	call   80102ab3 <iderw>
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
80100275:	e8 9e 4f 00 00       	call   80105218 <holdingsleep>
8010027a:	83 c4 10             	add    $0x10,%esp
8010027d:	85 c0                	test   %eax,%eax
8010027f:	75 0d                	jne    8010028e <brelse+0x2d>
    panic("brelse");
80100281:	83 ec 0c             	sub    $0xc,%esp
80100284:	68 1e 92 10 80       	push   $0x8010921e
80100289:	e8 7a 03 00 00       	call   80100608 <panic>

  releasesleep(&b->lock);
8010028e:	8b 45 08             	mov    0x8(%ebp),%eax
80100291:	83 c0 0c             	add    $0xc,%eax
80100294:	83 ec 0c             	sub    $0xc,%esp
80100297:	50                   	push   %eax
80100298:	e8 29 4f 00 00       	call   801051c6 <releasesleep>
8010029d:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	68 60 d6 10 80       	push   $0x8010d660
801002a8:	e8 2a 50 00 00       	call   801052d7 <acquire>
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
80100318:	e8 2c 50 00 00       	call   80105349 <release>
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
80100438:	e8 e1 4f 00 00       	call   8010541e <holding>
8010043d:	83 c4 10             	add    $0x10,%esp
80100440:	85 c0                	test   %eax,%eax
80100442:	75 10                	jne    80100454 <cprintf+0x3c>
    acquire(&cons.lock);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	68 c0 c5 10 80       	push   $0x8010c5c0
8010044c:	e8 86 4e 00 00       	call   801052d7 <acquire>
80100451:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100454:	8b 45 08             	mov    0x8(%ebp),%eax
80100457:	85 c0                	test   %eax,%eax
80100459:	75 0d                	jne    80100468 <cprintf+0x50>
    panic("null fmt");
8010045b:	83 ec 0c             	sub    $0xc,%esp
8010045e:	68 28 92 10 80       	push   $0x80109228
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
801004ee:	8b 04 85 38 92 10 80 	mov    -0x7fef6dc8(,%eax,4),%eax
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
8010054c:	c7 45 ec 31 92 10 80 	movl   $0x80109231,-0x14(%ebp)
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
801005fd:	e8 47 4d 00 00       	call   80105349 <release>
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
80100621:	e8 59 2b 00 00       	call   8010317f <lapicid>
80100626:	83 ec 08             	sub    $0x8,%esp
80100629:	50                   	push   %eax
8010062a:	68 90 92 10 80       	push   $0x80109290
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
80100649:	68 a4 92 10 80       	push   $0x801092a4
8010064e:	e8 c5 fd ff ff       	call   80100418 <cprintf>
80100653:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100656:	83 ec 08             	sub    $0x8,%esp
80100659:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010065c:	50                   	push   %eax
8010065d:	8d 45 08             	lea    0x8(%ebp),%eax
80100660:	50                   	push   %eax
80100661:	e8 39 4d 00 00       	call   8010539f <getcallerpcs>
80100666:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100670:	eb 1c                	jmp    8010068e <panic+0x86>
    cprintf(" %p", pcs[i]);
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100679:	83 ec 08             	sub    $0x8,%esp
8010067c:	50                   	push   %eax
8010067d:	68 a6 92 10 80       	push   $0x801092a6
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
80100772:	68 aa 92 10 80       	push   $0x801092aa
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
8010079f:	e8 99 4e 00 00       	call   8010563d <memmove>
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
801007c9:	e8 a8 4d 00 00       	call   80105576 <memset>
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
80100865:	e8 0f 68 00 00       	call   80107079 <uartputc>
8010086a:	83 c4 10             	add    $0x10,%esp
8010086d:	83 ec 0c             	sub    $0xc,%esp
80100870:	6a 20                	push   $0x20
80100872:	e8 02 68 00 00       	call   80107079 <uartputc>
80100877:	83 c4 10             	add    $0x10,%esp
8010087a:	83 ec 0c             	sub    $0xc,%esp
8010087d:	6a 08                	push   $0x8
8010087f:	e8 f5 67 00 00       	call   80107079 <uartputc>
80100884:	83 c4 10             	add    $0x10,%esp
80100887:	eb 0e                	jmp    80100897 <consputc+0x5a>
  } else
    uartputc(c);
80100889:	83 ec 0c             	sub    $0xc,%esp
8010088c:	ff 75 08             	pushl  0x8(%ebp)
8010088f:	e8 e5 67 00 00       	call   80107079 <uartputc>
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
801008c1:	e8 11 4a 00 00       	call   801052d7 <acquire>
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
80100a17:	e8 3b 45 00 00       	call   80104f57 <wakeup>
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
80100a3a:	e8 0a 49 00 00       	call   80105349 <release>
80100a3f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100a42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a46:	74 05                	je     80100a4d <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
80100a48:	e8 d0 45 00 00       	call   8010501d <procdump>
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
80100a60:	e8 d4 11 00 00       	call   80101c39 <iunlock>
80100a65:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a68:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a76:	e8 5c 48 00 00       	call   801052d7 <acquire>
80100a7b:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a7e:	e9 ab 00 00 00       	jmp    80100b2e <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
80100a83:	e8 28 3a 00 00       	call   801044b0 <myproc>
80100a88:	8b 40 28             	mov    0x28(%eax),%eax
80100a8b:	85 c0                	test   %eax,%eax
80100a8d:	74 28                	je     80100ab7 <consoleread+0x67>
        release(&cons.lock);
80100a8f:	83 ec 0c             	sub    $0xc,%esp
80100a92:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a97:	e8 ad 48 00 00       	call   80105349 <release>
80100a9c:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a9f:	83 ec 0c             	sub    $0xc,%esp
80100aa2:	ff 75 08             	pushl  0x8(%ebp)
80100aa5:	e8 78 10 00 00       	call   80101b22 <ilock>
80100aaa:	83 c4 10             	add    $0x10,%esp
        return -1;
80100aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ab2:	e9 ab 00 00 00       	jmp    80100b62 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100ab7:	83 ec 08             	sub    $0x8,%esp
80100aba:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abf:	68 40 20 11 80       	push   $0x80112040
80100ac4:	e8 9c 43 00 00       	call   80104e65 <sleep>
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
80100b42:	e8 02 48 00 00       	call   80105349 <release>
80100b47:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	ff 75 08             	pushl  0x8(%ebp)
80100b50:	e8 cd 0f 00 00       	call   80101b22 <ilock>
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
80100b74:	e8 c0 10 00 00       	call   80101c39 <iunlock>
80100b79:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b7c:	83 ec 0c             	sub    $0xc,%esp
80100b7f:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b84:	e8 4e 47 00 00       	call   801052d7 <acquire>
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
80100bc6:	e8 7e 47 00 00       	call   80105349 <release>
80100bcb:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bce:	83 ec 0c             	sub    $0xc,%esp
80100bd1:	ff 75 08             	pushl  0x8(%ebp)
80100bd4:	e8 49 0f 00 00       	call   80101b22 <ilock>
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
80100bee:	68 bd 92 10 80       	push   $0x801092bd
80100bf3:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bf8:	e8 b4 46 00 00       	call   801052b1 <initlock>
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
80100c25:	e8 62 20 00 00       	call   80102c8c <ioapicenable>
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
80100c3d:	e8 6e 38 00 00       	call   801044b0 <myproc>
80100c42:	89 45 d0             	mov    %eax,-0x30(%ebp)
  
  begin_op();
80100c45:	e8 a7 2a 00 00       	call   801036f1 <begin_op>

  if((ip = namei(path)) == 0){
80100c4a:	83 ec 0c             	sub    $0xc,%esp
80100c4d:	ff 75 08             	pushl  0x8(%ebp)
80100c50:	e8 38 1a 00 00       	call   8010268d <namei>
80100c55:	83 c4 10             	add    $0x10,%esp
80100c58:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c5b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c5f:	75 1f                	jne    80100c80 <exec+0x50>
    end_op();
80100c61:	e8 1b 2b 00 00       	call   80103781 <end_op>
    cprintf("exec: fail\n");
80100c66:	83 ec 0c             	sub    $0xc,%esp
80100c69:	68 c5 92 10 80       	push   $0x801092c5
80100c6e:	e8 a5 f7 ff ff       	call   80100418 <cprintf>
80100c73:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c7b:	e9 38 04 00 00       	jmp    801010b8 <exec+0x488>
  }
  ilock(ip);
80100c80:	83 ec 0c             	sub    $0xc,%esp
80100c83:	ff 75 d8             	pushl  -0x28(%ebp)
80100c86:	e8 97 0e 00 00       	call   80101b22 <ilock>
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
80100ca3:	e8 82 13 00 00       	call   8010202a <readi>
80100ca8:	83 c4 10             	add    $0x10,%esp
80100cab:	83 f8 34             	cmp    $0x34,%eax
80100cae:	0f 85 ad 03 00 00    	jne    80101061 <exec+0x431>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100cb4:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100cba:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cbf:	0f 85 9f 03 00 00    	jne    80101064 <exec+0x434>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100cc5:	e8 c8 77 00 00       	call   80108492 <setupkvm>
80100cca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ccd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100cd1:	0f 84 90 03 00 00    	je     80101067 <exec+0x437>
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
80100d03:	e8 22 13 00 00       	call   8010202a <readi>
80100d08:	83 c4 10             	add    $0x10,%esp
80100d0b:	83 f8 20             	cmp    $0x20,%eax
80100d0e:	0f 85 56 03 00 00    	jne    8010106a <exec+0x43a>
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
80100d31:	0f 82 36 03 00 00    	jb     8010106d <exec+0x43d>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d37:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d3d:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d43:	01 c2                	add    %eax,%edx
80100d45:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d4b:	39 c2                	cmp    %eax,%edx
80100d4d:	0f 82 1d 03 00 00    	jb     80101070 <exec+0x440>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d53:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d59:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d5f:	01 d0                	add    %edx,%eax
80100d61:	83 ec 04             	sub    $0x4,%esp
80100d64:	50                   	push   %eax
80100d65:	ff 75 e0             	pushl  -0x20(%ebp)
80100d68:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d6b:	e8 e0 7a 00 00       	call   80108850 <allocuvm>
80100d70:	83 c4 10             	add    $0x10,%esp
80100d73:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d76:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7a:	0f 84 f3 02 00 00    	je     80101073 <exec+0x443>
      goto bad;

    if(ph.vaddr % PGSIZE != 0)
80100d80:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d86:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d8b:	85 c0                	test   %eax,%eax
80100d8d:	0f 85 e3 02 00 00    	jne    80101076 <exec+0x446>
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
80100db1:	e8 c9 79 00 00       	call   8010877f <loaduvm>
80100db6:	83 c4 20             	add    $0x20,%esp
80100db9:	85 c0                	test   %eax,%eax
80100dbb:	0f 88 b8 02 00 00    	js     80101079 <exec+0x449>
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
80100dea:	e8 70 0f 00 00       	call   80101d5f <iunlockput>
80100def:	83 c4 10             	add    $0x10,%esp
  end_op();
80100df2:	e8 8a 29 00 00       	call   80103781 <end_op>
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
80100e20:	e8 2b 7a 00 00       	call   80108850 <allocuvm>
80100e25:	83 c4 10             	add    $0x10,%esp
80100e28:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e2b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e2f:	0f 84 47 02 00 00    	je     8010107c <exec+0x44c>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e38:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e3d:	83 ec 08             	sub    $0x8,%esp
80100e40:	50                   	push   %eax
80100e41:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e44:	e8 89 7c 00 00       	call   80108ad2 <clearpteu>
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
80100e62:	0f 87 17 02 00 00    	ja     8010107f <exec+0x44f>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e72:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e75:	01 d0                	add    %edx,%eax
80100e77:	8b 00                	mov    (%eax),%eax
80100e79:	83 ec 0c             	sub    $0xc,%esp
80100e7c:	50                   	push   %eax
80100e7d:	e8 5d 49 00 00       	call   801057df <strlen>
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
80100eaa:	e8 30 49 00 00       	call   801057df <strlen>
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
80100ed0:	e8 b9 7d 00 00       	call   80108c8e <copyout>
80100ed5:	83 c4 10             	add    $0x10,%esp
80100ed8:	85 c0                	test   %eax,%eax
80100eda:	0f 88 a2 01 00 00    	js     80101082 <exec+0x452>
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
80100f6c:	e8 1d 7d 00 00       	call   80108c8e <copyout>
80100f71:	83 c4 10             	add    $0x10,%esp
80100f74:	85 c0                	test   %eax,%eax
80100f76:	0f 88 09 01 00 00    	js     80101085 <exec+0x455>
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
80100fba:	e8 d2 47 00 00       	call   80105791 <safestrcpy>
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
  curproc->queue_size = 0;
80100fd4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fd7:	c7 80 c0 00 00 00 00 	movl   $0x0,0xc0(%eax)
80100fde:	00 00 00 
  curproc->hand = 0;
80100fe1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fe4:	c7 80 c8 00 00 00 00 	movl   $0x0,0xc8(%eax)
80100feb:	00 00 00 
  //uint change = sz - PGROUNDDOWN(curproc->sz);
  curproc->sz = sz;
80100fee:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ff1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ff4:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100ff6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ff9:	8b 40 1c             	mov    0x1c(%eax),%eax
80100ffc:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80101002:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80101005:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101008:	8b 40 1c             	mov    0x1c(%eax),%eax
8010100b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010100e:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80101011:	83 ec 0c             	sub    $0xc,%esp
80101014:	ff 75 d0             	pushl  -0x30(%ebp)
80101017:	e8 4c 75 00 00       	call   80108568 <switchuvm>
8010101c:	83 c4 10             	add    $0x10,%esp
  mencrypt(0, sz/PGSIZE - 2);
8010101f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101022:	c1 e8 0c             	shr    $0xc,%eax
80101025:	83 e8 02             	sub    $0x2,%eax
80101028:	83 ec 08             	sub    $0x8,%esp
8010102b:	50                   	push   %eax
8010102c:	6a 00                	push   $0x0
8010102e:	e8 c0 7d 00 00       	call   80108df3 <mencrypt>
80101033:	83 c4 10             	add    $0x10,%esp
  mencrypt((char*) sz - PGSIZE, 1);//(void*)PGROUNDDOWN((int)sz - change), change/PGSIZE);
80101036:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101039:	2d 00 10 00 00       	sub    $0x1000,%eax
8010103e:	83 ec 08             	sub    $0x8,%esp
80101041:	6a 01                	push   $0x1
80101043:	50                   	push   %eax
80101044:	e8 aa 7d 00 00       	call   80108df3 <mencrypt>
80101049:	83 c4 10             	add    $0x10,%esp
 // cprintf("%d\n", sz);
 // cprintf("%d\n", change);

  freevm(oldpgdir);
8010104c:	83 ec 0c             	sub    $0xc,%esp
8010104f:	ff 75 cc             	pushl  -0x34(%ebp)
80101052:	e8 df 79 00 00       	call   80108a36 <freevm>
80101057:	83 c4 10             	add    $0x10,%esp
  //for (void * i = (void*) PGROUNDDOWN(((int)curproc->sz)); i >= 0; i-=PGSIZE) {
  //  if(mencrypt(i, 1) != 0)
  //    break;
  //}

  return 0;
8010105a:	b8 00 00 00 00       	mov    $0x0,%eax
8010105f:	eb 57                	jmp    801010b8 <exec+0x488>
    goto bad;
80101061:	90                   	nop
80101062:	eb 22                	jmp    80101086 <exec+0x456>
    goto bad;
80101064:	90                   	nop
80101065:	eb 1f                	jmp    80101086 <exec+0x456>
    goto bad;
80101067:	90                   	nop
80101068:	eb 1c                	jmp    80101086 <exec+0x456>
      goto bad;
8010106a:	90                   	nop
8010106b:	eb 19                	jmp    80101086 <exec+0x456>
      goto bad;
8010106d:	90                   	nop
8010106e:	eb 16                	jmp    80101086 <exec+0x456>
      goto bad;
80101070:	90                   	nop
80101071:	eb 13                	jmp    80101086 <exec+0x456>
      goto bad;
80101073:	90                   	nop
80101074:	eb 10                	jmp    80101086 <exec+0x456>
      goto bad;
80101076:	90                   	nop
80101077:	eb 0d                	jmp    80101086 <exec+0x456>
      goto bad;
80101079:	90                   	nop
8010107a:	eb 0a                	jmp    80101086 <exec+0x456>
    goto bad;
8010107c:	90                   	nop
8010107d:	eb 07                	jmp    80101086 <exec+0x456>
      goto bad;
8010107f:	90                   	nop
80101080:	eb 04                	jmp    80101086 <exec+0x456>
      goto bad;
80101082:	90                   	nop
80101083:	eb 01                	jmp    80101086 <exec+0x456>
    goto bad;
80101085:	90                   	nop

 bad:
  if(pgdir)
80101086:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010108a:	74 0e                	je     8010109a <exec+0x46a>
    freevm(pgdir);
8010108c:	83 ec 0c             	sub    $0xc,%esp
8010108f:	ff 75 d4             	pushl  -0x2c(%ebp)
80101092:	e8 9f 79 00 00       	call   80108a36 <freevm>
80101097:	83 c4 10             	add    $0x10,%esp
  if(ip){
8010109a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010109e:	74 13                	je     801010b3 <exec+0x483>
    iunlockput(ip);
801010a0:	83 ec 0c             	sub    $0xc,%esp
801010a3:	ff 75 d8             	pushl  -0x28(%ebp)
801010a6:	e8 b4 0c 00 00       	call   80101d5f <iunlockput>
801010ab:	83 c4 10             	add    $0x10,%esp
    end_op();
801010ae:	e8 ce 26 00 00       	call   80103781 <end_op>
  }
  return -1;
801010b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010b8:	c9                   	leave  
801010b9:	c3                   	ret    

801010ba <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010ba:	f3 0f 1e fb          	endbr32 
801010be:	55                   	push   %ebp
801010bf:	89 e5                	mov    %esp,%ebp
801010c1:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801010c4:	83 ec 08             	sub    $0x8,%esp
801010c7:	68 d1 92 10 80       	push   $0x801092d1
801010cc:	68 60 20 11 80       	push   $0x80112060
801010d1:	e8 db 41 00 00       	call   801052b1 <initlock>
801010d6:	83 c4 10             	add    $0x10,%esp
}
801010d9:	90                   	nop
801010da:	c9                   	leave  
801010db:	c3                   	ret    

801010dc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010dc:	f3 0f 1e fb          	endbr32 
801010e0:	55                   	push   %ebp
801010e1:	89 e5                	mov    %esp,%ebp
801010e3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
801010e6:	83 ec 0c             	sub    $0xc,%esp
801010e9:	68 60 20 11 80       	push   $0x80112060
801010ee:	e8 e4 41 00 00       	call   801052d7 <acquire>
801010f3:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010f6:	c7 45 f4 94 20 11 80 	movl   $0x80112094,-0xc(%ebp)
801010fd:	eb 2d                	jmp    8010112c <filealloc+0x50>
    if(f->ref == 0){
801010ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101102:	8b 40 04             	mov    0x4(%eax),%eax
80101105:	85 c0                	test   %eax,%eax
80101107:	75 1f                	jne    80101128 <filealloc+0x4c>
      f->ref = 1;
80101109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010110c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101113:	83 ec 0c             	sub    $0xc,%esp
80101116:	68 60 20 11 80       	push   $0x80112060
8010111b:	e8 29 42 00 00       	call   80105349 <release>
80101120:	83 c4 10             	add    $0x10,%esp
      return f;
80101123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101126:	eb 23                	jmp    8010114b <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101128:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010112c:	b8 f4 29 11 80       	mov    $0x801129f4,%eax
80101131:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101134:	72 c9                	jb     801010ff <filealloc+0x23>
    }
  }
  release(&ftable.lock);
80101136:	83 ec 0c             	sub    $0xc,%esp
80101139:	68 60 20 11 80       	push   $0x80112060
8010113e:	e8 06 42 00 00       	call   80105349 <release>
80101143:	83 c4 10             	add    $0x10,%esp
  return 0;
80101146:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010114b:	c9                   	leave  
8010114c:	c3                   	ret    

8010114d <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010114d:	f3 0f 1e fb          	endbr32 
80101151:	55                   	push   %ebp
80101152:	89 e5                	mov    %esp,%ebp
80101154:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101157:	83 ec 0c             	sub    $0xc,%esp
8010115a:	68 60 20 11 80       	push   $0x80112060
8010115f:	e8 73 41 00 00       	call   801052d7 <acquire>
80101164:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101167:	8b 45 08             	mov    0x8(%ebp),%eax
8010116a:	8b 40 04             	mov    0x4(%eax),%eax
8010116d:	85 c0                	test   %eax,%eax
8010116f:	7f 0d                	jg     8010117e <filedup+0x31>
    panic("filedup");
80101171:	83 ec 0c             	sub    $0xc,%esp
80101174:	68 d8 92 10 80       	push   $0x801092d8
80101179:	e8 8a f4 ff ff       	call   80100608 <panic>
  f->ref++;
8010117e:	8b 45 08             	mov    0x8(%ebp),%eax
80101181:	8b 40 04             	mov    0x4(%eax),%eax
80101184:	8d 50 01             	lea    0x1(%eax),%edx
80101187:	8b 45 08             	mov    0x8(%ebp),%eax
8010118a:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010118d:	83 ec 0c             	sub    $0xc,%esp
80101190:	68 60 20 11 80       	push   $0x80112060
80101195:	e8 af 41 00 00       	call   80105349 <release>
8010119a:	83 c4 10             	add    $0x10,%esp
  return f;
8010119d:	8b 45 08             	mov    0x8(%ebp),%eax
}
801011a0:	c9                   	leave  
801011a1:	c3                   	ret    

801011a2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011a2:	f3 0f 1e fb          	endbr32 
801011a6:	55                   	push   %ebp
801011a7:	89 e5                	mov    %esp,%ebp
801011a9:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801011ac:	83 ec 0c             	sub    $0xc,%esp
801011af:	68 60 20 11 80       	push   $0x80112060
801011b4:	e8 1e 41 00 00       	call   801052d7 <acquire>
801011b9:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011bc:	8b 45 08             	mov    0x8(%ebp),%eax
801011bf:	8b 40 04             	mov    0x4(%eax),%eax
801011c2:	85 c0                	test   %eax,%eax
801011c4:	7f 0d                	jg     801011d3 <fileclose+0x31>
    panic("fileclose");
801011c6:	83 ec 0c             	sub    $0xc,%esp
801011c9:	68 e0 92 10 80       	push   $0x801092e0
801011ce:	e8 35 f4 ff ff       	call   80100608 <panic>
  if(--f->ref > 0){
801011d3:	8b 45 08             	mov    0x8(%ebp),%eax
801011d6:	8b 40 04             	mov    0x4(%eax),%eax
801011d9:	8d 50 ff             	lea    -0x1(%eax),%edx
801011dc:	8b 45 08             	mov    0x8(%ebp),%eax
801011df:	89 50 04             	mov    %edx,0x4(%eax)
801011e2:	8b 45 08             	mov    0x8(%ebp),%eax
801011e5:	8b 40 04             	mov    0x4(%eax),%eax
801011e8:	85 c0                	test   %eax,%eax
801011ea:	7e 15                	jle    80101201 <fileclose+0x5f>
    release(&ftable.lock);
801011ec:	83 ec 0c             	sub    $0xc,%esp
801011ef:	68 60 20 11 80       	push   $0x80112060
801011f4:	e8 50 41 00 00       	call   80105349 <release>
801011f9:	83 c4 10             	add    $0x10,%esp
801011fc:	e9 8b 00 00 00       	jmp    8010128c <fileclose+0xea>
    return;
  }
  ff = *f;
80101201:	8b 45 08             	mov    0x8(%ebp),%eax
80101204:	8b 10                	mov    (%eax),%edx
80101206:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101209:	8b 50 04             	mov    0x4(%eax),%edx
8010120c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010120f:	8b 50 08             	mov    0x8(%eax),%edx
80101212:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101215:	8b 50 0c             	mov    0xc(%eax),%edx
80101218:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010121b:	8b 50 10             	mov    0x10(%eax),%edx
8010121e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101221:	8b 40 14             	mov    0x14(%eax),%eax
80101224:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101227:	8b 45 08             	mov    0x8(%ebp),%eax
8010122a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101231:	8b 45 08             	mov    0x8(%ebp),%eax
80101234:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010123a:	83 ec 0c             	sub    $0xc,%esp
8010123d:	68 60 20 11 80       	push   $0x80112060
80101242:	e8 02 41 00 00       	call   80105349 <release>
80101247:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010124a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010124d:	83 f8 01             	cmp    $0x1,%eax
80101250:	75 19                	jne    8010126b <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101252:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101256:	0f be d0             	movsbl %al,%edx
80101259:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010125c:	83 ec 08             	sub    $0x8,%esp
8010125f:	52                   	push   %edx
80101260:	50                   	push   %eax
80101261:	e8 c1 2e 00 00       	call   80104127 <pipeclose>
80101266:	83 c4 10             	add    $0x10,%esp
80101269:	eb 21                	jmp    8010128c <fileclose+0xea>
  else if(ff.type == FD_INODE){
8010126b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010126e:	83 f8 02             	cmp    $0x2,%eax
80101271:	75 19                	jne    8010128c <fileclose+0xea>
    begin_op();
80101273:	e8 79 24 00 00       	call   801036f1 <begin_op>
    iput(ff.ip);
80101278:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010127b:	83 ec 0c             	sub    $0xc,%esp
8010127e:	50                   	push   %eax
8010127f:	e8 07 0a 00 00       	call   80101c8b <iput>
80101284:	83 c4 10             	add    $0x10,%esp
    end_op();
80101287:	e8 f5 24 00 00       	call   80103781 <end_op>
  }
}
8010128c:	c9                   	leave  
8010128d:	c3                   	ret    

8010128e <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010128e:	f3 0f 1e fb          	endbr32 
80101292:	55                   	push   %ebp
80101293:	89 e5                	mov    %esp,%ebp
80101295:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101298:	8b 45 08             	mov    0x8(%ebp),%eax
8010129b:	8b 00                	mov    (%eax),%eax
8010129d:	83 f8 02             	cmp    $0x2,%eax
801012a0:	75 40                	jne    801012e2 <filestat+0x54>
    ilock(f->ip);
801012a2:	8b 45 08             	mov    0x8(%ebp),%eax
801012a5:	8b 40 10             	mov    0x10(%eax),%eax
801012a8:	83 ec 0c             	sub    $0xc,%esp
801012ab:	50                   	push   %eax
801012ac:	e8 71 08 00 00       	call   80101b22 <ilock>
801012b1:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801012b4:	8b 45 08             	mov    0x8(%ebp),%eax
801012b7:	8b 40 10             	mov    0x10(%eax),%eax
801012ba:	83 ec 08             	sub    $0x8,%esp
801012bd:	ff 75 0c             	pushl  0xc(%ebp)
801012c0:	50                   	push   %eax
801012c1:	e8 1a 0d 00 00       	call   80101fe0 <stati>
801012c6:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801012c9:	8b 45 08             	mov    0x8(%ebp),%eax
801012cc:	8b 40 10             	mov    0x10(%eax),%eax
801012cf:	83 ec 0c             	sub    $0xc,%esp
801012d2:	50                   	push   %eax
801012d3:	e8 61 09 00 00       	call   80101c39 <iunlock>
801012d8:	83 c4 10             	add    $0x10,%esp
    return 0;
801012db:	b8 00 00 00 00       	mov    $0x0,%eax
801012e0:	eb 05                	jmp    801012e7 <filestat+0x59>
  }
  return -1;
801012e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012e7:	c9                   	leave  
801012e8:	c3                   	ret    

801012e9 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012e9:	f3 0f 1e fb          	endbr32 
801012ed:	55                   	push   %ebp
801012ee:	89 e5                	mov    %esp,%ebp
801012f0:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801012f3:	8b 45 08             	mov    0x8(%ebp),%eax
801012f6:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801012fa:	84 c0                	test   %al,%al
801012fc:	75 0a                	jne    80101308 <fileread+0x1f>
    return -1;
801012fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101303:	e9 9b 00 00 00       	jmp    801013a3 <fileread+0xba>
  if(f->type == FD_PIPE)
80101308:	8b 45 08             	mov    0x8(%ebp),%eax
8010130b:	8b 00                	mov    (%eax),%eax
8010130d:	83 f8 01             	cmp    $0x1,%eax
80101310:	75 1a                	jne    8010132c <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	8b 40 0c             	mov    0xc(%eax),%eax
80101318:	83 ec 04             	sub    $0x4,%esp
8010131b:	ff 75 10             	pushl  0x10(%ebp)
8010131e:	ff 75 0c             	pushl  0xc(%ebp)
80101321:	50                   	push   %eax
80101322:	e8 b5 2f 00 00       	call   801042dc <piperead>
80101327:	83 c4 10             	add    $0x10,%esp
8010132a:	eb 77                	jmp    801013a3 <fileread+0xba>
  if(f->type == FD_INODE){
8010132c:	8b 45 08             	mov    0x8(%ebp),%eax
8010132f:	8b 00                	mov    (%eax),%eax
80101331:	83 f8 02             	cmp    $0x2,%eax
80101334:	75 60                	jne    80101396 <fileread+0xad>
    ilock(f->ip);
80101336:	8b 45 08             	mov    0x8(%ebp),%eax
80101339:	8b 40 10             	mov    0x10(%eax),%eax
8010133c:	83 ec 0c             	sub    $0xc,%esp
8010133f:	50                   	push   %eax
80101340:	e8 dd 07 00 00       	call   80101b22 <ilock>
80101345:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101348:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010134b:	8b 45 08             	mov    0x8(%ebp),%eax
8010134e:	8b 50 14             	mov    0x14(%eax),%edx
80101351:	8b 45 08             	mov    0x8(%ebp),%eax
80101354:	8b 40 10             	mov    0x10(%eax),%eax
80101357:	51                   	push   %ecx
80101358:	52                   	push   %edx
80101359:	ff 75 0c             	pushl  0xc(%ebp)
8010135c:	50                   	push   %eax
8010135d:	e8 c8 0c 00 00       	call   8010202a <readi>
80101362:	83 c4 10             	add    $0x10,%esp
80101365:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101368:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010136c:	7e 11                	jle    8010137f <fileread+0x96>
      f->off += r;
8010136e:	8b 45 08             	mov    0x8(%ebp),%eax
80101371:	8b 50 14             	mov    0x14(%eax),%edx
80101374:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101377:	01 c2                	add    %eax,%edx
80101379:	8b 45 08             	mov    0x8(%ebp),%eax
8010137c:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010137f:	8b 45 08             	mov    0x8(%ebp),%eax
80101382:	8b 40 10             	mov    0x10(%eax),%eax
80101385:	83 ec 0c             	sub    $0xc,%esp
80101388:	50                   	push   %eax
80101389:	e8 ab 08 00 00       	call   80101c39 <iunlock>
8010138e:	83 c4 10             	add    $0x10,%esp
    return r;
80101391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101394:	eb 0d                	jmp    801013a3 <fileread+0xba>
  }
  panic("fileread");
80101396:	83 ec 0c             	sub    $0xc,%esp
80101399:	68 ea 92 10 80       	push   $0x801092ea
8010139e:	e8 65 f2 ff ff       	call   80100608 <panic>
}
801013a3:	c9                   	leave  
801013a4:	c3                   	ret    

801013a5 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801013a5:	f3 0f 1e fb          	endbr32 
801013a9:	55                   	push   %ebp
801013aa:	89 e5                	mov    %esp,%ebp
801013ac:	53                   	push   %ebx
801013ad:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801013b0:	8b 45 08             	mov    0x8(%ebp),%eax
801013b3:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801013b7:	84 c0                	test   %al,%al
801013b9:	75 0a                	jne    801013c5 <filewrite+0x20>
    return -1;
801013bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013c0:	e9 1b 01 00 00       	jmp    801014e0 <filewrite+0x13b>
  if(f->type == FD_PIPE)
801013c5:	8b 45 08             	mov    0x8(%ebp),%eax
801013c8:	8b 00                	mov    (%eax),%eax
801013ca:	83 f8 01             	cmp    $0x1,%eax
801013cd:	75 1d                	jne    801013ec <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801013cf:	8b 45 08             	mov    0x8(%ebp),%eax
801013d2:	8b 40 0c             	mov    0xc(%eax),%eax
801013d5:	83 ec 04             	sub    $0x4,%esp
801013d8:	ff 75 10             	pushl  0x10(%ebp)
801013db:	ff 75 0c             	pushl  0xc(%ebp)
801013de:	50                   	push   %eax
801013df:	e8 f2 2d 00 00       	call   801041d6 <pipewrite>
801013e4:	83 c4 10             	add    $0x10,%esp
801013e7:	e9 f4 00 00 00       	jmp    801014e0 <filewrite+0x13b>
  if(f->type == FD_INODE){
801013ec:	8b 45 08             	mov    0x8(%ebp),%eax
801013ef:	8b 00                	mov    (%eax),%eax
801013f1:	83 f8 02             	cmp    $0x2,%eax
801013f4:	0f 85 d9 00 00 00    	jne    801014d3 <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801013fa:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101401:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101408:	e9 a3 00 00 00       	jmp    801014b0 <filewrite+0x10b>
      int n1 = n - i;
8010140d:	8b 45 10             	mov    0x10(%ebp),%eax
80101410:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101413:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101416:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101419:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010141c:	7e 06                	jle    80101424 <filewrite+0x7f>
        n1 = max;
8010141e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101421:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101424:	e8 c8 22 00 00       	call   801036f1 <begin_op>
      ilock(f->ip);
80101429:	8b 45 08             	mov    0x8(%ebp),%eax
8010142c:	8b 40 10             	mov    0x10(%eax),%eax
8010142f:	83 ec 0c             	sub    $0xc,%esp
80101432:	50                   	push   %eax
80101433:	e8 ea 06 00 00       	call   80101b22 <ilock>
80101438:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010143b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010143e:	8b 45 08             	mov    0x8(%ebp),%eax
80101441:	8b 50 14             	mov    0x14(%eax),%edx
80101444:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101447:	8b 45 0c             	mov    0xc(%ebp),%eax
8010144a:	01 c3                	add    %eax,%ebx
8010144c:	8b 45 08             	mov    0x8(%ebp),%eax
8010144f:	8b 40 10             	mov    0x10(%eax),%eax
80101452:	51                   	push   %ecx
80101453:	52                   	push   %edx
80101454:	53                   	push   %ebx
80101455:	50                   	push   %eax
80101456:	e8 28 0d 00 00       	call   80102183 <writei>
8010145b:	83 c4 10             	add    $0x10,%esp
8010145e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101461:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101465:	7e 11                	jle    80101478 <filewrite+0xd3>
        f->off += r;
80101467:	8b 45 08             	mov    0x8(%ebp),%eax
8010146a:	8b 50 14             	mov    0x14(%eax),%edx
8010146d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101470:	01 c2                	add    %eax,%edx
80101472:	8b 45 08             	mov    0x8(%ebp),%eax
80101475:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101478:	8b 45 08             	mov    0x8(%ebp),%eax
8010147b:	8b 40 10             	mov    0x10(%eax),%eax
8010147e:	83 ec 0c             	sub    $0xc,%esp
80101481:	50                   	push   %eax
80101482:	e8 b2 07 00 00       	call   80101c39 <iunlock>
80101487:	83 c4 10             	add    $0x10,%esp
      end_op();
8010148a:	e8 f2 22 00 00       	call   80103781 <end_op>

      if(r < 0)
8010148f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101493:	78 29                	js     801014be <filewrite+0x119>
        break;
      if(r != n1)
80101495:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101498:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010149b:	74 0d                	je     801014aa <filewrite+0x105>
        panic("short filewrite");
8010149d:	83 ec 0c             	sub    $0xc,%esp
801014a0:	68 f3 92 10 80       	push   $0x801092f3
801014a5:	e8 5e f1 ff ff       	call   80100608 <panic>
      i += r;
801014aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014ad:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801014b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014b3:	3b 45 10             	cmp    0x10(%ebp),%eax
801014b6:	0f 8c 51 ff ff ff    	jl     8010140d <filewrite+0x68>
801014bc:	eb 01                	jmp    801014bf <filewrite+0x11a>
        break;
801014be:	90                   	nop
    }
    return i == n ? n : -1;
801014bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014c2:	3b 45 10             	cmp    0x10(%ebp),%eax
801014c5:	75 05                	jne    801014cc <filewrite+0x127>
801014c7:	8b 45 10             	mov    0x10(%ebp),%eax
801014ca:	eb 14                	jmp    801014e0 <filewrite+0x13b>
801014cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014d1:	eb 0d                	jmp    801014e0 <filewrite+0x13b>
  }
  panic("filewrite");
801014d3:	83 ec 0c             	sub    $0xc,%esp
801014d6:	68 03 93 10 80       	push   $0x80109303
801014db:	e8 28 f1 ff ff       	call   80100608 <panic>
}
801014e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801014e3:	c9                   	leave  
801014e4:	c3                   	ret    

801014e5 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014e5:	f3 0f 1e fb          	endbr32 
801014e9:	55                   	push   %ebp
801014ea:	89 e5                	mov    %esp,%ebp
801014ec:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014ef:	8b 45 08             	mov    0x8(%ebp),%eax
801014f2:	83 ec 08             	sub    $0x8,%esp
801014f5:	6a 01                	push   $0x1
801014f7:	50                   	push   %eax
801014f8:	e8 da ec ff ff       	call   801001d7 <bread>
801014fd:	83 c4 10             	add    $0x10,%esp
80101500:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101506:	83 c0 5c             	add    $0x5c,%eax
80101509:	83 ec 04             	sub    $0x4,%esp
8010150c:	6a 1c                	push   $0x1c
8010150e:	50                   	push   %eax
8010150f:	ff 75 0c             	pushl  0xc(%ebp)
80101512:	e8 26 41 00 00       	call   8010563d <memmove>
80101517:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010151a:	83 ec 0c             	sub    $0xc,%esp
8010151d:	ff 75 f4             	pushl  -0xc(%ebp)
80101520:	e8 3c ed ff ff       	call   80100261 <brelse>
80101525:	83 c4 10             	add    $0x10,%esp
}
80101528:	90                   	nop
80101529:	c9                   	leave  
8010152a:	c3                   	ret    

8010152b <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010152b:	f3 0f 1e fb          	endbr32 
8010152f:	55                   	push   %ebp
80101530:	89 e5                	mov    %esp,%ebp
80101532:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101535:	8b 55 0c             	mov    0xc(%ebp),%edx
80101538:	8b 45 08             	mov    0x8(%ebp),%eax
8010153b:	83 ec 08             	sub    $0x8,%esp
8010153e:	52                   	push   %edx
8010153f:	50                   	push   %eax
80101540:	e8 92 ec ff ff       	call   801001d7 <bread>
80101545:	83 c4 10             	add    $0x10,%esp
80101548:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010154b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010154e:	83 c0 5c             	add    $0x5c,%eax
80101551:	83 ec 04             	sub    $0x4,%esp
80101554:	68 00 02 00 00       	push   $0x200
80101559:	6a 00                	push   $0x0
8010155b:	50                   	push   %eax
8010155c:	e8 15 40 00 00       	call   80105576 <memset>
80101561:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101564:	83 ec 0c             	sub    $0xc,%esp
80101567:	ff 75 f4             	pushl  -0xc(%ebp)
8010156a:	e8 cb 23 00 00       	call   8010393a <log_write>
8010156f:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101572:	83 ec 0c             	sub    $0xc,%esp
80101575:	ff 75 f4             	pushl  -0xc(%ebp)
80101578:	e8 e4 ec ff ff       	call   80100261 <brelse>
8010157d:	83 c4 10             	add    $0x10,%esp
}
80101580:	90                   	nop
80101581:	c9                   	leave  
80101582:	c3                   	ret    

80101583 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101583:	f3 0f 1e fb          	endbr32 
80101587:	55                   	push   %ebp
80101588:	89 e5                	mov    %esp,%ebp
8010158a:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010158d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010159b:	e9 13 01 00 00       	jmp    801016b3 <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801015a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a3:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801015a9:	85 c0                	test   %eax,%eax
801015ab:	0f 48 c2             	cmovs  %edx,%eax
801015ae:	c1 f8 0c             	sar    $0xc,%eax
801015b1:	89 c2                	mov    %eax,%edx
801015b3:	a1 78 2a 11 80       	mov    0x80112a78,%eax
801015b8:	01 d0                	add    %edx,%eax
801015ba:	83 ec 08             	sub    $0x8,%esp
801015bd:	50                   	push   %eax
801015be:	ff 75 08             	pushl  0x8(%ebp)
801015c1:	e8 11 ec ff ff       	call   801001d7 <bread>
801015c6:	83 c4 10             	add    $0x10,%esp
801015c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015cc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015d3:	e9 a6 00 00 00       	jmp    8010167e <balloc+0xfb>
      m = 1 << (bi % 8);
801015d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015db:	99                   	cltd   
801015dc:	c1 ea 1d             	shr    $0x1d,%edx
801015df:	01 d0                	add    %edx,%eax
801015e1:	83 e0 07             	and    $0x7,%eax
801015e4:	29 d0                	sub    %edx,%eax
801015e6:	ba 01 00 00 00       	mov    $0x1,%edx
801015eb:	89 c1                	mov    %eax,%ecx
801015ed:	d3 e2                	shl    %cl,%edx
801015ef:	89 d0                	mov    %edx,%eax
801015f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f7:	8d 50 07             	lea    0x7(%eax),%edx
801015fa:	85 c0                	test   %eax,%eax
801015fc:	0f 48 c2             	cmovs  %edx,%eax
801015ff:	c1 f8 03             	sar    $0x3,%eax
80101602:	89 c2                	mov    %eax,%edx
80101604:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101607:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010160c:	0f b6 c0             	movzbl %al,%eax
8010160f:	23 45 e8             	and    -0x18(%ebp),%eax
80101612:	85 c0                	test   %eax,%eax
80101614:	75 64                	jne    8010167a <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
80101616:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101619:	8d 50 07             	lea    0x7(%eax),%edx
8010161c:	85 c0                	test   %eax,%eax
8010161e:	0f 48 c2             	cmovs  %edx,%eax
80101621:	c1 f8 03             	sar    $0x3,%eax
80101624:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101627:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010162c:	89 d1                	mov    %edx,%ecx
8010162e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101631:	09 ca                	or     %ecx,%edx
80101633:	89 d1                	mov    %edx,%ecx
80101635:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101638:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010163c:	83 ec 0c             	sub    $0xc,%esp
8010163f:	ff 75 ec             	pushl  -0x14(%ebp)
80101642:	e8 f3 22 00 00       	call   8010393a <log_write>
80101647:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010164a:	83 ec 0c             	sub    $0xc,%esp
8010164d:	ff 75 ec             	pushl  -0x14(%ebp)
80101650:	e8 0c ec ff ff       	call   80100261 <brelse>
80101655:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101658:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010165b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010165e:	01 c2                	add    %eax,%edx
80101660:	8b 45 08             	mov    0x8(%ebp),%eax
80101663:	83 ec 08             	sub    $0x8,%esp
80101666:	52                   	push   %edx
80101667:	50                   	push   %eax
80101668:	e8 be fe ff ff       	call   8010152b <bzero>
8010166d:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101670:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101673:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101676:	01 d0                	add    %edx,%eax
80101678:	eb 57                	jmp    801016d1 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010167a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010167e:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101685:	7f 17                	jg     8010169e <balloc+0x11b>
80101687:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010168a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010168d:	01 d0                	add    %edx,%eax
8010168f:	89 c2                	mov    %eax,%edx
80101691:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80101696:	39 c2                	cmp    %eax,%edx
80101698:	0f 82 3a ff ff ff    	jb     801015d8 <balloc+0x55>
      }
    }
    brelse(bp);
8010169e:	83 ec 0c             	sub    $0xc,%esp
801016a1:	ff 75 ec             	pushl  -0x14(%ebp)
801016a4:	e8 b8 eb ff ff       	call   80100261 <brelse>
801016a9:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801016ac:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801016b3:	8b 15 60 2a 11 80    	mov    0x80112a60,%edx
801016b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016bc:	39 c2                	cmp    %eax,%edx
801016be:	0f 87 dc fe ff ff    	ja     801015a0 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
801016c4:	83 ec 0c             	sub    $0xc,%esp
801016c7:	68 10 93 10 80       	push   $0x80109310
801016cc:	e8 37 ef ff ff       	call   80100608 <panic>
}
801016d1:	c9                   	leave  
801016d2:	c3                   	ret    

801016d3 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801016d3:	f3 0f 1e fb          	endbr32 
801016d7:	55                   	push   %ebp
801016d8:	89 e5                	mov    %esp,%ebp
801016da:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801016dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801016e0:	c1 e8 0c             	shr    $0xc,%eax
801016e3:	89 c2                	mov    %eax,%edx
801016e5:	a1 78 2a 11 80       	mov    0x80112a78,%eax
801016ea:	01 c2                	add    %eax,%edx
801016ec:	8b 45 08             	mov    0x8(%ebp),%eax
801016ef:	83 ec 08             	sub    $0x8,%esp
801016f2:	52                   	push   %edx
801016f3:	50                   	push   %eax
801016f4:	e8 de ea ff ff       	call   801001d7 <bread>
801016f9:	83 c4 10             	add    $0x10,%esp
801016fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80101702:	25 ff 0f 00 00       	and    $0xfff,%eax
80101707:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010170a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170d:	99                   	cltd   
8010170e:	c1 ea 1d             	shr    $0x1d,%edx
80101711:	01 d0                	add    %edx,%eax
80101713:	83 e0 07             	and    $0x7,%eax
80101716:	29 d0                	sub    %edx,%eax
80101718:	ba 01 00 00 00       	mov    $0x1,%edx
8010171d:	89 c1                	mov    %eax,%ecx
8010171f:	d3 e2                	shl    %cl,%edx
80101721:	89 d0                	mov    %edx,%eax
80101723:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101726:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101729:	8d 50 07             	lea    0x7(%eax),%edx
8010172c:	85 c0                	test   %eax,%eax
8010172e:	0f 48 c2             	cmovs  %edx,%eax
80101731:	c1 f8 03             	sar    $0x3,%eax
80101734:	89 c2                	mov    %eax,%edx
80101736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101739:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010173e:	0f b6 c0             	movzbl %al,%eax
80101741:	23 45 ec             	and    -0x14(%ebp),%eax
80101744:	85 c0                	test   %eax,%eax
80101746:	75 0d                	jne    80101755 <bfree+0x82>
    panic("freeing free block");
80101748:	83 ec 0c             	sub    $0xc,%esp
8010174b:	68 26 93 10 80       	push   $0x80109326
80101750:	e8 b3 ee ff ff       	call   80100608 <panic>
  bp->data[bi/8] &= ~m;
80101755:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101758:	8d 50 07             	lea    0x7(%eax),%edx
8010175b:	85 c0                	test   %eax,%eax
8010175d:	0f 48 c2             	cmovs  %edx,%eax
80101760:	c1 f8 03             	sar    $0x3,%eax
80101763:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101766:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010176b:	89 d1                	mov    %edx,%ecx
8010176d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101770:	f7 d2                	not    %edx
80101772:	21 ca                	and    %ecx,%edx
80101774:	89 d1                	mov    %edx,%ecx
80101776:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101779:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010177d:	83 ec 0c             	sub    $0xc,%esp
80101780:	ff 75 f4             	pushl  -0xc(%ebp)
80101783:	e8 b2 21 00 00       	call   8010393a <log_write>
80101788:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010178b:	83 ec 0c             	sub    $0xc,%esp
8010178e:	ff 75 f4             	pushl  -0xc(%ebp)
80101791:	e8 cb ea ff ff       	call   80100261 <brelse>
80101796:	83 c4 10             	add    $0x10,%esp
}
80101799:	90                   	nop
8010179a:	c9                   	leave  
8010179b:	c3                   	ret    

8010179c <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010179c:	f3 0f 1e fb          	endbr32 
801017a0:	55                   	push   %ebp
801017a1:	89 e5                	mov    %esp,%ebp
801017a3:	57                   	push   %edi
801017a4:	56                   	push   %esi
801017a5:	53                   	push   %ebx
801017a6:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801017a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801017b0:	83 ec 08             	sub    $0x8,%esp
801017b3:	68 39 93 10 80       	push   $0x80109339
801017b8:	68 80 2a 11 80       	push   $0x80112a80
801017bd:	e8 ef 3a 00 00       	call   801052b1 <initlock>
801017c2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801017cc:	eb 2d                	jmp    801017fb <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
801017ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801017d1:	89 d0                	mov    %edx,%eax
801017d3:	c1 e0 03             	shl    $0x3,%eax
801017d6:	01 d0                	add    %edx,%eax
801017d8:	c1 e0 04             	shl    $0x4,%eax
801017db:	83 c0 30             	add    $0x30,%eax
801017de:	05 80 2a 11 80       	add    $0x80112a80,%eax
801017e3:	83 c0 10             	add    $0x10,%eax
801017e6:	83 ec 08             	sub    $0x8,%esp
801017e9:	68 40 93 10 80       	push   $0x80109340
801017ee:	50                   	push   %eax
801017ef:	e8 2a 39 00 00       	call   8010511e <initsleeplock>
801017f4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017f7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801017fb:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017ff:	7e cd                	jle    801017ce <iinit+0x32>
  }

  readsb(dev, &sb);
80101801:	83 ec 08             	sub    $0x8,%esp
80101804:	68 60 2a 11 80       	push   $0x80112a60
80101809:	ff 75 08             	pushl  0x8(%ebp)
8010180c:	e8 d4 fc ff ff       	call   801014e5 <readsb>
80101811:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101814:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101819:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010181c:	8b 3d 74 2a 11 80    	mov    0x80112a74,%edi
80101822:	8b 35 70 2a 11 80    	mov    0x80112a70,%esi
80101828:	8b 1d 6c 2a 11 80    	mov    0x80112a6c,%ebx
8010182e:	8b 0d 68 2a 11 80    	mov    0x80112a68,%ecx
80101834:	8b 15 64 2a 11 80    	mov    0x80112a64,%edx
8010183a:	a1 60 2a 11 80       	mov    0x80112a60,%eax
8010183f:	ff 75 d4             	pushl  -0x2c(%ebp)
80101842:	57                   	push   %edi
80101843:	56                   	push   %esi
80101844:	53                   	push   %ebx
80101845:	51                   	push   %ecx
80101846:	52                   	push   %edx
80101847:	50                   	push   %eax
80101848:	68 48 93 10 80       	push   $0x80109348
8010184d:	e8 c6 eb ff ff       	call   80100418 <cprintf>
80101852:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101855:	90                   	nop
80101856:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101859:	5b                   	pop    %ebx
8010185a:	5e                   	pop    %esi
8010185b:	5f                   	pop    %edi
8010185c:	5d                   	pop    %ebp
8010185d:	c3                   	ret    

8010185e <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010185e:	f3 0f 1e fb          	endbr32 
80101862:	55                   	push   %ebp
80101863:	89 e5                	mov    %esp,%ebp
80101865:	83 ec 28             	sub    $0x28,%esp
80101868:	8b 45 0c             	mov    0xc(%ebp),%eax
8010186b:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010186f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101876:	e9 9e 00 00 00       	jmp    80101919 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
8010187b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187e:	c1 e8 03             	shr    $0x3,%eax
80101881:	89 c2                	mov    %eax,%edx
80101883:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101888:	01 d0                	add    %edx,%eax
8010188a:	83 ec 08             	sub    $0x8,%esp
8010188d:	50                   	push   %eax
8010188e:	ff 75 08             	pushl  0x8(%ebp)
80101891:	e8 41 e9 ff ff       	call   801001d7 <bread>
80101896:	83 c4 10             	add    $0x10,%esp
80101899:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010189c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189f:	8d 50 5c             	lea    0x5c(%eax),%edx
801018a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a5:	83 e0 07             	and    $0x7,%eax
801018a8:	c1 e0 06             	shl    $0x6,%eax
801018ab:	01 d0                	add    %edx,%eax
801018ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801018b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018b3:	0f b7 00             	movzwl (%eax),%eax
801018b6:	66 85 c0             	test   %ax,%ax
801018b9:	75 4c                	jne    80101907 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
801018bb:	83 ec 04             	sub    $0x4,%esp
801018be:	6a 40                	push   $0x40
801018c0:	6a 00                	push   $0x0
801018c2:	ff 75 ec             	pushl  -0x14(%ebp)
801018c5:	e8 ac 3c 00 00       	call   80105576 <memset>
801018ca:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801018cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018d0:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801018d4:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801018d7:	83 ec 0c             	sub    $0xc,%esp
801018da:	ff 75 f0             	pushl  -0x10(%ebp)
801018dd:	e8 58 20 00 00       	call   8010393a <log_write>
801018e2:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801018e5:	83 ec 0c             	sub    $0xc,%esp
801018e8:	ff 75 f0             	pushl  -0x10(%ebp)
801018eb:	e8 71 e9 ff ff       	call   80100261 <brelse>
801018f0:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801018f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f6:	83 ec 08             	sub    $0x8,%esp
801018f9:	50                   	push   %eax
801018fa:	ff 75 08             	pushl  0x8(%ebp)
801018fd:	e8 fc 00 00 00       	call   801019fe <iget>
80101902:	83 c4 10             	add    $0x10,%esp
80101905:	eb 30                	jmp    80101937 <ialloc+0xd9>
    }
    brelse(bp);
80101907:	83 ec 0c             	sub    $0xc,%esp
8010190a:	ff 75 f0             	pushl  -0x10(%ebp)
8010190d:	e8 4f e9 ff ff       	call   80100261 <brelse>
80101912:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101915:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101919:	8b 15 68 2a 11 80    	mov    0x80112a68,%edx
8010191f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101922:	39 c2                	cmp    %eax,%edx
80101924:	0f 87 51 ff ff ff    	ja     8010187b <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
8010192a:	83 ec 0c             	sub    $0xc,%esp
8010192d:	68 9b 93 10 80       	push   $0x8010939b
80101932:	e8 d1 ec ff ff       	call   80100608 <panic>
}
80101937:	c9                   	leave  
80101938:	c3                   	ret    

80101939 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101939:	f3 0f 1e fb          	endbr32 
8010193d:	55                   	push   %ebp
8010193e:	89 e5                	mov    %esp,%ebp
80101940:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101943:	8b 45 08             	mov    0x8(%ebp),%eax
80101946:	8b 40 04             	mov    0x4(%eax),%eax
80101949:	c1 e8 03             	shr    $0x3,%eax
8010194c:	89 c2                	mov    %eax,%edx
8010194e:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101953:	01 c2                	add    %eax,%edx
80101955:	8b 45 08             	mov    0x8(%ebp),%eax
80101958:	8b 00                	mov    (%eax),%eax
8010195a:	83 ec 08             	sub    $0x8,%esp
8010195d:	52                   	push   %edx
8010195e:	50                   	push   %eax
8010195f:	e8 73 e8 ff ff       	call   801001d7 <bread>
80101964:	83 c4 10             	add    $0x10,%esp
80101967:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010196a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101970:	8b 45 08             	mov    0x8(%ebp),%eax
80101973:	8b 40 04             	mov    0x4(%eax),%eax
80101976:	83 e0 07             	and    $0x7,%eax
80101979:	c1 e0 06             	shl    $0x6,%eax
8010197c:	01 d0                	add    %edx,%eax
8010197e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101981:	8b 45 08             	mov    0x8(%ebp),%eax
80101984:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101988:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010198b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010198e:	8b 45 08             	mov    0x8(%ebp),%eax
80101991:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101995:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101998:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010199c:	8b 45 08             	mov    0x8(%ebp),%eax
8010199f:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801019a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019a6:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801019aa:	8b 45 08             	mov    0x8(%ebp),%eax
801019ad:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801019b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b4:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801019b8:	8b 45 08             	mov    0x8(%ebp),%eax
801019bb:	8b 50 58             	mov    0x58(%eax),%edx
801019be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c1:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019c4:	8b 45 08             	mov    0x8(%ebp),%eax
801019c7:	8d 50 5c             	lea    0x5c(%eax),%edx
801019ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019cd:	83 c0 0c             	add    $0xc,%eax
801019d0:	83 ec 04             	sub    $0x4,%esp
801019d3:	6a 34                	push   $0x34
801019d5:	52                   	push   %edx
801019d6:	50                   	push   %eax
801019d7:	e8 61 3c 00 00       	call   8010563d <memmove>
801019dc:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801019df:	83 ec 0c             	sub    $0xc,%esp
801019e2:	ff 75 f4             	pushl  -0xc(%ebp)
801019e5:	e8 50 1f 00 00       	call   8010393a <log_write>
801019ea:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019ed:	83 ec 0c             	sub    $0xc,%esp
801019f0:	ff 75 f4             	pushl  -0xc(%ebp)
801019f3:	e8 69 e8 ff ff       	call   80100261 <brelse>
801019f8:	83 c4 10             	add    $0x10,%esp
}
801019fb:	90                   	nop
801019fc:	c9                   	leave  
801019fd:	c3                   	ret    

801019fe <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019fe:	f3 0f 1e fb          	endbr32 
80101a02:	55                   	push   %ebp
80101a03:	89 e5                	mov    %esp,%ebp
80101a05:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a08:	83 ec 0c             	sub    $0xc,%esp
80101a0b:	68 80 2a 11 80       	push   $0x80112a80
80101a10:	e8 c2 38 00 00       	call   801052d7 <acquire>
80101a15:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101a18:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a1f:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
80101a26:	eb 60                	jmp    80101a88 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2b:	8b 40 08             	mov    0x8(%eax),%eax
80101a2e:	85 c0                	test   %eax,%eax
80101a30:	7e 39                	jle    80101a6b <iget+0x6d>
80101a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a35:	8b 00                	mov    (%eax),%eax
80101a37:	39 45 08             	cmp    %eax,0x8(%ebp)
80101a3a:	75 2f                	jne    80101a6b <iget+0x6d>
80101a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3f:	8b 40 04             	mov    0x4(%eax),%eax
80101a42:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101a45:	75 24                	jne    80101a6b <iget+0x6d>
      ip->ref++;
80101a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4a:	8b 40 08             	mov    0x8(%eax),%eax
80101a4d:	8d 50 01             	lea    0x1(%eax),%edx
80101a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a53:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a56:	83 ec 0c             	sub    $0xc,%esp
80101a59:	68 80 2a 11 80       	push   $0x80112a80
80101a5e:	e8 e6 38 00 00       	call   80105349 <release>
80101a63:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a69:	eb 77                	jmp    80101ae2 <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a6f:	75 10                	jne    80101a81 <iget+0x83>
80101a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a74:	8b 40 08             	mov    0x8(%eax),%eax
80101a77:	85 c0                	test   %eax,%eax
80101a79:	75 06                	jne    80101a81 <iget+0x83>
      empty = ip;
80101a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a81:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a88:	81 7d f4 d4 46 11 80 	cmpl   $0x801146d4,-0xc(%ebp)
80101a8f:	72 97                	jb     80101a28 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a91:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a95:	75 0d                	jne    80101aa4 <iget+0xa6>
    panic("iget: no inodes");
80101a97:	83 ec 0c             	sub    $0xc,%esp
80101a9a:	68 ad 93 10 80       	push   $0x801093ad
80101a9f:	e8 64 eb ff ff       	call   80100608 <panic>

  ip = empty;
80101aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aad:	8b 55 08             	mov    0x8(%ebp),%edx
80101ab0:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab5:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ab8:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101abe:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101acf:	83 ec 0c             	sub    $0xc,%esp
80101ad2:	68 80 2a 11 80       	push   $0x80112a80
80101ad7:	e8 6d 38 00 00       	call   80105349 <release>
80101adc:	83 c4 10             	add    $0x10,%esp

  return ip;
80101adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101ae2:	c9                   	leave  
80101ae3:	c3                   	ret    

80101ae4 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101ae4:	f3 0f 1e fb          	endbr32 
80101ae8:	55                   	push   %ebp
80101ae9:	89 e5                	mov    %esp,%ebp
80101aeb:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101aee:	83 ec 0c             	sub    $0xc,%esp
80101af1:	68 80 2a 11 80       	push   $0x80112a80
80101af6:	e8 dc 37 00 00       	call   801052d7 <acquire>
80101afb:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101afe:	8b 45 08             	mov    0x8(%ebp),%eax
80101b01:	8b 40 08             	mov    0x8(%eax),%eax
80101b04:	8d 50 01             	lea    0x1(%eax),%edx
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b0d:	83 ec 0c             	sub    $0xc,%esp
80101b10:	68 80 2a 11 80       	push   $0x80112a80
80101b15:	e8 2f 38 00 00       	call   80105349 <release>
80101b1a:	83 c4 10             	add    $0x10,%esp
  return ip;
80101b1d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b20:	c9                   	leave  
80101b21:	c3                   	ret    

80101b22 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b22:	f3 0f 1e fb          	endbr32 
80101b26:	55                   	push   %ebp
80101b27:	89 e5                	mov    %esp,%ebp
80101b29:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b2c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b30:	74 0a                	je     80101b3c <ilock+0x1a>
80101b32:	8b 45 08             	mov    0x8(%ebp),%eax
80101b35:	8b 40 08             	mov    0x8(%eax),%eax
80101b38:	85 c0                	test   %eax,%eax
80101b3a:	7f 0d                	jg     80101b49 <ilock+0x27>
    panic("ilock");
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	68 bd 93 10 80       	push   $0x801093bd
80101b44:	e8 bf ea ff ff       	call   80100608 <panic>

  acquiresleep(&ip->lock);
80101b49:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4c:	83 c0 0c             	add    $0xc,%eax
80101b4f:	83 ec 0c             	sub    $0xc,%esp
80101b52:	50                   	push   %eax
80101b53:	e8 06 36 00 00       	call   8010515e <acquiresleep>
80101b58:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101b5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b61:	85 c0                	test   %eax,%eax
80101b63:	0f 85 cd 00 00 00    	jne    80101c36 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b69:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6c:	8b 40 04             	mov    0x4(%eax),%eax
80101b6f:	c1 e8 03             	shr    $0x3,%eax
80101b72:	89 c2                	mov    %eax,%edx
80101b74:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101b79:	01 c2                	add    %eax,%edx
80101b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7e:	8b 00                	mov    (%eax),%eax
80101b80:	83 ec 08             	sub    $0x8,%esp
80101b83:	52                   	push   %edx
80101b84:	50                   	push   %eax
80101b85:	e8 4d e6 ff ff       	call   801001d7 <bread>
80101b8a:	83 c4 10             	add    $0x10,%esp
80101b8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b93:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b96:	8b 45 08             	mov    0x8(%ebp),%eax
80101b99:	8b 40 04             	mov    0x4(%eax),%eax
80101b9c:	83 e0 07             	and    $0x7,%eax
80101b9f:	c1 e0 06             	shl    $0x6,%eax
80101ba2:	01 d0                	add    %edx,%eax
80101ba4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101baa:	0f b7 10             	movzwl (%eax),%edx
80101bad:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb0:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb7:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbe:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101bc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bc5:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcc:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bd3:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bda:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be1:	8b 50 08             	mov    0x8(%eax),%edx
80101be4:	8b 45 08             	mov    0x8(%ebp),%eax
80101be7:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bed:	8d 50 0c             	lea    0xc(%eax),%edx
80101bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf3:	83 c0 5c             	add    $0x5c,%eax
80101bf6:	83 ec 04             	sub    $0x4,%esp
80101bf9:	6a 34                	push   $0x34
80101bfb:	52                   	push   %edx
80101bfc:	50                   	push   %eax
80101bfd:	e8 3b 3a 00 00       	call   8010563d <memmove>
80101c02:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101c05:	83 ec 0c             	sub    $0xc,%esp
80101c08:	ff 75 f4             	pushl  -0xc(%ebp)
80101c0b:	e8 51 e6 ff ff       	call   80100261 <brelse>
80101c10:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101c13:	8b 45 08             	mov    0x8(%ebp),%eax
80101c16:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c1d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c20:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101c24:	66 85 c0             	test   %ax,%ax
80101c27:	75 0d                	jne    80101c36 <ilock+0x114>
      panic("ilock: no type");
80101c29:	83 ec 0c             	sub    $0xc,%esp
80101c2c:	68 c3 93 10 80       	push   $0x801093c3
80101c31:	e8 d2 e9 ff ff       	call   80100608 <panic>
  }
}
80101c36:	90                   	nop
80101c37:	c9                   	leave  
80101c38:	c3                   	ret    

80101c39 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c39:	f3 0f 1e fb          	endbr32 
80101c3d:	55                   	push   %ebp
80101c3e:	89 e5                	mov    %esp,%ebp
80101c40:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c43:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c47:	74 20                	je     80101c69 <iunlock+0x30>
80101c49:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4c:	83 c0 0c             	add    $0xc,%eax
80101c4f:	83 ec 0c             	sub    $0xc,%esp
80101c52:	50                   	push   %eax
80101c53:	e8 c0 35 00 00       	call   80105218 <holdingsleep>
80101c58:	83 c4 10             	add    $0x10,%esp
80101c5b:	85 c0                	test   %eax,%eax
80101c5d:	74 0a                	je     80101c69 <iunlock+0x30>
80101c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c62:	8b 40 08             	mov    0x8(%eax),%eax
80101c65:	85 c0                	test   %eax,%eax
80101c67:	7f 0d                	jg     80101c76 <iunlock+0x3d>
    panic("iunlock");
80101c69:	83 ec 0c             	sub    $0xc,%esp
80101c6c:	68 d2 93 10 80       	push   $0x801093d2
80101c71:	e8 92 e9 ff ff       	call   80100608 <panic>

  releasesleep(&ip->lock);
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	83 c0 0c             	add    $0xc,%eax
80101c7c:	83 ec 0c             	sub    $0xc,%esp
80101c7f:	50                   	push   %eax
80101c80:	e8 41 35 00 00       	call   801051c6 <releasesleep>
80101c85:	83 c4 10             	add    $0x10,%esp
}
80101c88:	90                   	nop
80101c89:	c9                   	leave  
80101c8a:	c3                   	ret    

80101c8b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c8b:	f3 0f 1e fb          	endbr32 
80101c8f:	55                   	push   %ebp
80101c90:	89 e5                	mov    %esp,%ebp
80101c92:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101c95:	8b 45 08             	mov    0x8(%ebp),%eax
80101c98:	83 c0 0c             	add    $0xc,%eax
80101c9b:	83 ec 0c             	sub    $0xc,%esp
80101c9e:	50                   	push   %eax
80101c9f:	e8 ba 34 00 00       	call   8010515e <acquiresleep>
80101ca4:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101ca7:	8b 45 08             	mov    0x8(%ebp),%eax
80101caa:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cad:	85 c0                	test   %eax,%eax
80101caf:	74 6a                	je     80101d1b <iput+0x90>
80101cb1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101cb8:	66 85 c0             	test   %ax,%ax
80101cbb:	75 5e                	jne    80101d1b <iput+0x90>
    acquire(&icache.lock);
80101cbd:	83 ec 0c             	sub    $0xc,%esp
80101cc0:	68 80 2a 11 80       	push   $0x80112a80
80101cc5:	e8 0d 36 00 00       	call   801052d7 <acquire>
80101cca:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd0:	8b 40 08             	mov    0x8(%eax),%eax
80101cd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101cd6:	83 ec 0c             	sub    $0xc,%esp
80101cd9:	68 80 2a 11 80       	push   $0x80112a80
80101cde:	e8 66 36 00 00       	call   80105349 <release>
80101ce3:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ce6:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101cea:	75 2f                	jne    80101d1b <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101cec:	83 ec 0c             	sub    $0xc,%esp
80101cef:	ff 75 08             	pushl  0x8(%ebp)
80101cf2:	e8 b5 01 00 00       	call   80101eac <itrunc>
80101cf7:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101cfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfd:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101d03:	83 ec 0c             	sub    $0xc,%esp
80101d06:	ff 75 08             	pushl  0x8(%ebp)
80101d09:	e8 2b fc ff ff       	call   80101939 <iupdate>
80101d0e:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101d11:	8b 45 08             	mov    0x8(%ebp),%eax
80101d14:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1e:	83 c0 0c             	add    $0xc,%eax
80101d21:	83 ec 0c             	sub    $0xc,%esp
80101d24:	50                   	push   %eax
80101d25:	e8 9c 34 00 00       	call   801051c6 <releasesleep>
80101d2a:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101d2d:	83 ec 0c             	sub    $0xc,%esp
80101d30:	68 80 2a 11 80       	push   $0x80112a80
80101d35:	e8 9d 35 00 00       	call   801052d7 <acquire>
80101d3a:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d40:	8b 40 08             	mov    0x8(%eax),%eax
80101d43:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d46:	8b 45 08             	mov    0x8(%ebp),%eax
80101d49:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d4c:	83 ec 0c             	sub    $0xc,%esp
80101d4f:	68 80 2a 11 80       	push   $0x80112a80
80101d54:	e8 f0 35 00 00       	call   80105349 <release>
80101d59:	83 c4 10             	add    $0x10,%esp
}
80101d5c:	90                   	nop
80101d5d:	c9                   	leave  
80101d5e:	c3                   	ret    

80101d5f <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d5f:	f3 0f 1e fb          	endbr32 
80101d63:	55                   	push   %ebp
80101d64:	89 e5                	mov    %esp,%ebp
80101d66:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d69:	83 ec 0c             	sub    $0xc,%esp
80101d6c:	ff 75 08             	pushl  0x8(%ebp)
80101d6f:	e8 c5 fe ff ff       	call   80101c39 <iunlock>
80101d74:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d77:	83 ec 0c             	sub    $0xc,%esp
80101d7a:	ff 75 08             	pushl  0x8(%ebp)
80101d7d:	e8 09 ff ff ff       	call   80101c8b <iput>
80101d82:	83 c4 10             	add    $0x10,%esp
}
80101d85:	90                   	nop
80101d86:	c9                   	leave  
80101d87:	c3                   	ret    

80101d88 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d88:	f3 0f 1e fb          	endbr32 
80101d8c:	55                   	push   %ebp
80101d8d:	89 e5                	mov    %esp,%ebp
80101d8f:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d92:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d96:	77 42                	ja     80101dda <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101d98:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d9e:	83 c2 14             	add    $0x14,%edx
80101da1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101da5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dac:	75 24                	jne    80101dd2 <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101dae:	8b 45 08             	mov    0x8(%ebp),%eax
80101db1:	8b 00                	mov    (%eax),%eax
80101db3:	83 ec 0c             	sub    $0xc,%esp
80101db6:	50                   	push   %eax
80101db7:	e8 c7 f7 ff ff       	call   80101583 <balloc>
80101dbc:	83 c4 10             	add    $0x10,%esp
80101dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc5:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dc8:	8d 4a 14             	lea    0x14(%edx),%ecx
80101dcb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dce:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dd5:	e9 d0 00 00 00       	jmp    80101eaa <bmap+0x122>
  }
  bn -= NDIRECT;
80101dda:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101dde:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101de2:	0f 87 b5 00 00 00    	ja     80101e9d <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101de8:	8b 45 08             	mov    0x8(%ebp),%eax
80101deb:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101df1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101df4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101df8:	75 20                	jne    80101e1a <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101dfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfd:	8b 00                	mov    (%eax),%eax
80101dff:	83 ec 0c             	sub    $0xc,%esp
80101e02:	50                   	push   %eax
80101e03:	e8 7b f7 ff ff       	call   80101583 <balloc>
80101e08:	83 c4 10             	add    $0x10,%esp
80101e0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e14:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101e1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1d:	8b 00                	mov    (%eax),%eax
80101e1f:	83 ec 08             	sub    $0x8,%esp
80101e22:	ff 75 f4             	pushl  -0xc(%ebp)
80101e25:	50                   	push   %eax
80101e26:	e8 ac e3 ff ff       	call   801001d7 <bread>
80101e2b:	83 c4 10             	add    $0x10,%esp
80101e2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e34:	83 c0 5c             	add    $0x5c,%eax
80101e37:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e3d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e44:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e47:	01 d0                	add    %edx,%eax
80101e49:	8b 00                	mov    (%eax),%eax
80101e4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e52:	75 36                	jne    80101e8a <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101e54:	8b 45 08             	mov    0x8(%ebp),%eax
80101e57:	8b 00                	mov    (%eax),%eax
80101e59:	83 ec 0c             	sub    $0xc,%esp
80101e5c:	50                   	push   %eax
80101e5d:	e8 21 f7 ff ff       	call   80101583 <balloc>
80101e62:	83 c4 10             	add    $0x10,%esp
80101e65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e68:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e75:	01 c2                	add    %eax,%edx
80101e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e7a:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101e7c:	83 ec 0c             	sub    $0xc,%esp
80101e7f:	ff 75 f0             	pushl  -0x10(%ebp)
80101e82:	e8 b3 1a 00 00       	call   8010393a <log_write>
80101e87:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e8a:	83 ec 0c             	sub    $0xc,%esp
80101e8d:	ff 75 f0             	pushl  -0x10(%ebp)
80101e90:	e8 cc e3 ff ff       	call   80100261 <brelse>
80101e95:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e9b:	eb 0d                	jmp    80101eaa <bmap+0x122>
  }

  panic("bmap: out of range");
80101e9d:	83 ec 0c             	sub    $0xc,%esp
80101ea0:	68 da 93 10 80       	push   $0x801093da
80101ea5:	e8 5e e7 ff ff       	call   80100608 <panic>
}
80101eaa:	c9                   	leave  
80101eab:	c3                   	ret    

80101eac <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101eac:	f3 0f 1e fb          	endbr32 
80101eb0:	55                   	push   %ebp
80101eb1:	89 e5                	mov    %esp,%ebp
80101eb3:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101eb6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ebd:	eb 45                	jmp    80101f04 <itrunc+0x58>
    if(ip->addrs[i]){
80101ebf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ec5:	83 c2 14             	add    $0x14,%edx
80101ec8:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ecc:	85 c0                	test   %eax,%eax
80101ece:	74 30                	je     80101f00 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101ed0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ed6:	83 c2 14             	add    $0x14,%edx
80101ed9:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101edd:	8b 55 08             	mov    0x8(%ebp),%edx
80101ee0:	8b 12                	mov    (%edx),%edx
80101ee2:	83 ec 08             	sub    $0x8,%esp
80101ee5:	50                   	push   %eax
80101ee6:	52                   	push   %edx
80101ee7:	e8 e7 f7 ff ff       	call   801016d3 <bfree>
80101eec:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101eef:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ef5:	83 c2 14             	add    $0x14,%edx
80101ef8:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101eff:	00 
  for(i = 0; i < NDIRECT; i++){
80101f00:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f04:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f08:	7e b5                	jle    80101ebf <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0d:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f13:	85 c0                	test   %eax,%eax
80101f15:	0f 84 aa 00 00 00    	je     80101fc5 <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1e:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f24:	8b 45 08             	mov    0x8(%ebp),%eax
80101f27:	8b 00                	mov    (%eax),%eax
80101f29:	83 ec 08             	sub    $0x8,%esp
80101f2c:	52                   	push   %edx
80101f2d:	50                   	push   %eax
80101f2e:	e8 a4 e2 ff ff       	call   801001d7 <bread>
80101f33:	83 c4 10             	add    $0x10,%esp
80101f36:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f39:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f3c:	83 c0 5c             	add    $0x5c,%eax
80101f3f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f42:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f49:	eb 3c                	jmp    80101f87 <itrunc+0xdb>
      if(a[j])
80101f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f4e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f55:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f58:	01 d0                	add    %edx,%eax
80101f5a:	8b 00                	mov    (%eax),%eax
80101f5c:	85 c0                	test   %eax,%eax
80101f5e:	74 23                	je     80101f83 <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101f60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f63:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f6d:	01 d0                	add    %edx,%eax
80101f6f:	8b 00                	mov    (%eax),%eax
80101f71:	8b 55 08             	mov    0x8(%ebp),%edx
80101f74:	8b 12                	mov    (%edx),%edx
80101f76:	83 ec 08             	sub    $0x8,%esp
80101f79:	50                   	push   %eax
80101f7a:	52                   	push   %edx
80101f7b:	e8 53 f7 ff ff       	call   801016d3 <bfree>
80101f80:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101f83:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f8a:	83 f8 7f             	cmp    $0x7f,%eax
80101f8d:	76 bc                	jbe    80101f4b <itrunc+0x9f>
    }
    brelse(bp);
80101f8f:	83 ec 0c             	sub    $0xc,%esp
80101f92:	ff 75 ec             	pushl  -0x14(%ebp)
80101f95:	e8 c7 e2 ff ff       	call   80100261 <brelse>
80101f9a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa0:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101fa6:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa9:	8b 12                	mov    (%edx),%edx
80101fab:	83 ec 08             	sub    $0x8,%esp
80101fae:	50                   	push   %eax
80101faf:	52                   	push   %edx
80101fb0:	e8 1e f7 ff ff       	call   801016d3 <bfree>
80101fb5:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101fb8:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbb:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101fc2:	00 00 00 
  }

  ip->size = 0;
80101fc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc8:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101fcf:	83 ec 0c             	sub    $0xc,%esp
80101fd2:	ff 75 08             	pushl  0x8(%ebp)
80101fd5:	e8 5f f9 ff ff       	call   80101939 <iupdate>
80101fda:	83 c4 10             	add    $0x10,%esp
}
80101fdd:	90                   	nop
80101fde:	c9                   	leave  
80101fdf:	c3                   	ret    

80101fe0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101fe0:	f3 0f 1e fb          	endbr32 
80101fe4:	55                   	push   %ebp
80101fe5:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fea:	8b 00                	mov    (%eax),%eax
80101fec:	89 c2                	mov    %eax,%edx
80101fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ff1:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ff4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff7:	8b 50 04             	mov    0x4(%eax),%edx
80101ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ffd:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102000:	8b 45 08             	mov    0x8(%ebp),%eax
80102003:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80102007:	8b 45 0c             	mov    0xc(%ebp),%eax
8010200a:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
8010200d:	8b 45 08             	mov    0x8(%ebp),%eax
80102010:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80102014:	8b 45 0c             	mov    0xc(%ebp),%eax
80102017:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
8010201b:	8b 45 08             	mov    0x8(%ebp),%eax
8010201e:	8b 50 58             	mov    0x58(%eax),%edx
80102021:	8b 45 0c             	mov    0xc(%ebp),%eax
80102024:	89 50 10             	mov    %edx,0x10(%eax)
}
80102027:	90                   	nop
80102028:	5d                   	pop    %ebp
80102029:	c3                   	ret    

8010202a <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
8010202a:	f3 0f 1e fb          	endbr32 
8010202e:	55                   	push   %ebp
8010202f:	89 e5                	mov    %esp,%ebp
80102031:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102034:	8b 45 08             	mov    0x8(%ebp),%eax
80102037:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010203b:	66 83 f8 03          	cmp    $0x3,%ax
8010203f:	75 5c                	jne    8010209d <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102041:	8b 45 08             	mov    0x8(%ebp),%eax
80102044:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102048:	66 85 c0             	test   %ax,%ax
8010204b:	78 20                	js     8010206d <readi+0x43>
8010204d:	8b 45 08             	mov    0x8(%ebp),%eax
80102050:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102054:	66 83 f8 09          	cmp    $0x9,%ax
80102058:	7f 13                	jg     8010206d <readi+0x43>
8010205a:	8b 45 08             	mov    0x8(%ebp),%eax
8010205d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102061:	98                   	cwtl   
80102062:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
80102069:	85 c0                	test   %eax,%eax
8010206b:	75 0a                	jne    80102077 <readi+0x4d>
      return -1;
8010206d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102072:	e9 0a 01 00 00       	jmp    80102181 <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80102077:	8b 45 08             	mov    0x8(%ebp),%eax
8010207a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207e:	98                   	cwtl   
8010207f:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
80102086:	8b 55 14             	mov    0x14(%ebp),%edx
80102089:	83 ec 04             	sub    $0x4,%esp
8010208c:	52                   	push   %edx
8010208d:	ff 75 0c             	pushl  0xc(%ebp)
80102090:	ff 75 08             	pushl  0x8(%ebp)
80102093:	ff d0                	call   *%eax
80102095:	83 c4 10             	add    $0x10,%esp
80102098:	e9 e4 00 00 00       	jmp    80102181 <readi+0x157>
  }

  if(off > ip->size || off + n < off)
8010209d:	8b 45 08             	mov    0x8(%ebp),%eax
801020a0:	8b 40 58             	mov    0x58(%eax),%eax
801020a3:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a6:	77 0d                	ja     801020b5 <readi+0x8b>
801020a8:	8b 55 10             	mov    0x10(%ebp),%edx
801020ab:	8b 45 14             	mov    0x14(%ebp),%eax
801020ae:	01 d0                	add    %edx,%eax
801020b0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b3:	76 0a                	jbe    801020bf <readi+0x95>
    return -1;
801020b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020ba:	e9 c2 00 00 00       	jmp    80102181 <readi+0x157>
  if(off + n > ip->size)
801020bf:	8b 55 10             	mov    0x10(%ebp),%edx
801020c2:	8b 45 14             	mov    0x14(%ebp),%eax
801020c5:	01 c2                	add    %eax,%edx
801020c7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ca:	8b 40 58             	mov    0x58(%eax),%eax
801020cd:	39 c2                	cmp    %eax,%edx
801020cf:	76 0c                	jbe    801020dd <readi+0xb3>
    n = ip->size - off;
801020d1:	8b 45 08             	mov    0x8(%ebp),%eax
801020d4:	8b 40 58             	mov    0x58(%eax),%eax
801020d7:	2b 45 10             	sub    0x10(%ebp),%eax
801020da:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e4:	e9 89 00 00 00       	jmp    80102172 <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e9:	8b 45 10             	mov    0x10(%ebp),%eax
801020ec:	c1 e8 09             	shr    $0x9,%eax
801020ef:	83 ec 08             	sub    $0x8,%esp
801020f2:	50                   	push   %eax
801020f3:	ff 75 08             	pushl  0x8(%ebp)
801020f6:	e8 8d fc ff ff       	call   80101d88 <bmap>
801020fb:	83 c4 10             	add    $0x10,%esp
801020fe:	8b 55 08             	mov    0x8(%ebp),%edx
80102101:	8b 12                	mov    (%edx),%edx
80102103:	83 ec 08             	sub    $0x8,%esp
80102106:	50                   	push   %eax
80102107:	52                   	push   %edx
80102108:	e8 ca e0 ff ff       	call   801001d7 <bread>
8010210d:	83 c4 10             	add    $0x10,%esp
80102110:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102113:	8b 45 10             	mov    0x10(%ebp),%eax
80102116:	25 ff 01 00 00       	and    $0x1ff,%eax
8010211b:	ba 00 02 00 00       	mov    $0x200,%edx
80102120:	29 c2                	sub    %eax,%edx
80102122:	8b 45 14             	mov    0x14(%ebp),%eax
80102125:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102128:	39 c2                	cmp    %eax,%edx
8010212a:	0f 46 c2             	cmovbe %edx,%eax
8010212d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102130:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102133:	8d 50 5c             	lea    0x5c(%eax),%edx
80102136:	8b 45 10             	mov    0x10(%ebp),%eax
80102139:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213e:	01 d0                	add    %edx,%eax
80102140:	83 ec 04             	sub    $0x4,%esp
80102143:	ff 75 ec             	pushl  -0x14(%ebp)
80102146:	50                   	push   %eax
80102147:	ff 75 0c             	pushl  0xc(%ebp)
8010214a:	e8 ee 34 00 00       	call   8010563d <memmove>
8010214f:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102152:	83 ec 0c             	sub    $0xc,%esp
80102155:	ff 75 f0             	pushl  -0x10(%ebp)
80102158:	e8 04 e1 ff ff       	call   80100261 <brelse>
8010215d:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102160:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102163:	01 45 f4             	add    %eax,-0xc(%ebp)
80102166:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102169:	01 45 10             	add    %eax,0x10(%ebp)
8010216c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216f:	01 45 0c             	add    %eax,0xc(%ebp)
80102172:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102175:	3b 45 14             	cmp    0x14(%ebp),%eax
80102178:	0f 82 6b ff ff ff    	jb     801020e9 <readi+0xbf>
  }
  return n;
8010217e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102181:	c9                   	leave  
80102182:	c3                   	ret    

80102183 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102183:	f3 0f 1e fb          	endbr32 
80102187:	55                   	push   %ebp
80102188:	89 e5                	mov    %esp,%ebp
8010218a:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010218d:	8b 45 08             	mov    0x8(%ebp),%eax
80102190:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102194:	66 83 f8 03          	cmp    $0x3,%ax
80102198:	75 5c                	jne    801021f6 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010219a:	8b 45 08             	mov    0x8(%ebp),%eax
8010219d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021a1:	66 85 c0             	test   %ax,%ax
801021a4:	78 20                	js     801021c6 <writei+0x43>
801021a6:	8b 45 08             	mov    0x8(%ebp),%eax
801021a9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021ad:	66 83 f8 09          	cmp    $0x9,%ax
801021b1:	7f 13                	jg     801021c6 <writei+0x43>
801021b3:	8b 45 08             	mov    0x8(%ebp),%eax
801021b6:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021ba:	98                   	cwtl   
801021bb:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021c2:	85 c0                	test   %eax,%eax
801021c4:	75 0a                	jne    801021d0 <writei+0x4d>
      return -1;
801021c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021cb:	e9 3b 01 00 00       	jmp    8010230b <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
801021d0:	8b 45 08             	mov    0x8(%ebp),%eax
801021d3:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021d7:	98                   	cwtl   
801021d8:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021df:	8b 55 14             	mov    0x14(%ebp),%edx
801021e2:	83 ec 04             	sub    $0x4,%esp
801021e5:	52                   	push   %edx
801021e6:	ff 75 0c             	pushl  0xc(%ebp)
801021e9:	ff 75 08             	pushl  0x8(%ebp)
801021ec:	ff d0                	call   *%eax
801021ee:	83 c4 10             	add    $0x10,%esp
801021f1:	e9 15 01 00 00       	jmp    8010230b <writei+0x188>
  }

  if(off > ip->size || off + n < off)
801021f6:	8b 45 08             	mov    0x8(%ebp),%eax
801021f9:	8b 40 58             	mov    0x58(%eax),%eax
801021fc:	39 45 10             	cmp    %eax,0x10(%ebp)
801021ff:	77 0d                	ja     8010220e <writei+0x8b>
80102201:	8b 55 10             	mov    0x10(%ebp),%edx
80102204:	8b 45 14             	mov    0x14(%ebp),%eax
80102207:	01 d0                	add    %edx,%eax
80102209:	39 45 10             	cmp    %eax,0x10(%ebp)
8010220c:	76 0a                	jbe    80102218 <writei+0x95>
    return -1;
8010220e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102213:	e9 f3 00 00 00       	jmp    8010230b <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102218:	8b 55 10             	mov    0x10(%ebp),%edx
8010221b:	8b 45 14             	mov    0x14(%ebp),%eax
8010221e:	01 d0                	add    %edx,%eax
80102220:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102225:	76 0a                	jbe    80102231 <writei+0xae>
    return -1;
80102227:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010222c:	e9 da 00 00 00       	jmp    8010230b <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102231:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102238:	e9 97 00 00 00       	jmp    801022d4 <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010223d:	8b 45 10             	mov    0x10(%ebp),%eax
80102240:	c1 e8 09             	shr    $0x9,%eax
80102243:	83 ec 08             	sub    $0x8,%esp
80102246:	50                   	push   %eax
80102247:	ff 75 08             	pushl  0x8(%ebp)
8010224a:	e8 39 fb ff ff       	call   80101d88 <bmap>
8010224f:	83 c4 10             	add    $0x10,%esp
80102252:	8b 55 08             	mov    0x8(%ebp),%edx
80102255:	8b 12                	mov    (%edx),%edx
80102257:	83 ec 08             	sub    $0x8,%esp
8010225a:	50                   	push   %eax
8010225b:	52                   	push   %edx
8010225c:	e8 76 df ff ff       	call   801001d7 <bread>
80102261:	83 c4 10             	add    $0x10,%esp
80102264:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102267:	8b 45 10             	mov    0x10(%ebp),%eax
8010226a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010226f:	ba 00 02 00 00       	mov    $0x200,%edx
80102274:	29 c2                	sub    %eax,%edx
80102276:	8b 45 14             	mov    0x14(%ebp),%eax
80102279:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010227c:	39 c2                	cmp    %eax,%edx
8010227e:	0f 46 c2             	cmovbe %edx,%eax
80102281:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102284:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102287:	8d 50 5c             	lea    0x5c(%eax),%edx
8010228a:	8b 45 10             	mov    0x10(%ebp),%eax
8010228d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102292:	01 d0                	add    %edx,%eax
80102294:	83 ec 04             	sub    $0x4,%esp
80102297:	ff 75 ec             	pushl  -0x14(%ebp)
8010229a:	ff 75 0c             	pushl  0xc(%ebp)
8010229d:	50                   	push   %eax
8010229e:	e8 9a 33 00 00       	call   8010563d <memmove>
801022a3:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801022a6:	83 ec 0c             	sub    $0xc,%esp
801022a9:	ff 75 f0             	pushl  -0x10(%ebp)
801022ac:	e8 89 16 00 00       	call   8010393a <log_write>
801022b1:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801022b4:	83 ec 0c             	sub    $0xc,%esp
801022b7:	ff 75 f0             	pushl  -0x10(%ebp)
801022ba:	e8 a2 df ff ff       	call   80100261 <brelse>
801022bf:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022c5:	01 45 f4             	add    %eax,-0xc(%ebp)
801022c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022cb:	01 45 10             	add    %eax,0x10(%ebp)
801022ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022d1:	01 45 0c             	add    %eax,0xc(%ebp)
801022d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d7:	3b 45 14             	cmp    0x14(%ebp),%eax
801022da:	0f 82 5d ff ff ff    	jb     8010223d <writei+0xba>
  }

  if(n > 0 && off > ip->size){
801022e0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801022e4:	74 22                	je     80102308 <writei+0x185>
801022e6:	8b 45 08             	mov    0x8(%ebp),%eax
801022e9:	8b 40 58             	mov    0x58(%eax),%eax
801022ec:	39 45 10             	cmp    %eax,0x10(%ebp)
801022ef:	76 17                	jbe    80102308 <writei+0x185>
    ip->size = off;
801022f1:	8b 45 08             	mov    0x8(%ebp),%eax
801022f4:	8b 55 10             	mov    0x10(%ebp),%edx
801022f7:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801022fa:	83 ec 0c             	sub    $0xc,%esp
801022fd:	ff 75 08             	pushl  0x8(%ebp)
80102300:	e8 34 f6 ff ff       	call   80101939 <iupdate>
80102305:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102308:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010230b:	c9                   	leave  
8010230c:	c3                   	ret    

8010230d <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010230d:	f3 0f 1e fb          	endbr32 
80102311:	55                   	push   %ebp
80102312:	89 e5                	mov    %esp,%ebp
80102314:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102317:	83 ec 04             	sub    $0x4,%esp
8010231a:	6a 0e                	push   $0xe
8010231c:	ff 75 0c             	pushl  0xc(%ebp)
8010231f:	ff 75 08             	pushl  0x8(%ebp)
80102322:	e8 b4 33 00 00       	call   801056db <strncmp>
80102327:	83 c4 10             	add    $0x10,%esp
}
8010232a:	c9                   	leave  
8010232b:	c3                   	ret    

8010232c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010232c:	f3 0f 1e fb          	endbr32 
80102330:	55                   	push   %ebp
80102331:	89 e5                	mov    %esp,%ebp
80102333:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102336:	8b 45 08             	mov    0x8(%ebp),%eax
80102339:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010233d:	66 83 f8 01          	cmp    $0x1,%ax
80102341:	74 0d                	je     80102350 <dirlookup+0x24>
    panic("dirlookup not DIR");
80102343:	83 ec 0c             	sub    $0xc,%esp
80102346:	68 ed 93 10 80       	push   $0x801093ed
8010234b:	e8 b8 e2 ff ff       	call   80100608 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102350:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102357:	eb 7b                	jmp    801023d4 <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102359:	6a 10                	push   $0x10
8010235b:	ff 75 f4             	pushl  -0xc(%ebp)
8010235e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102361:	50                   	push   %eax
80102362:	ff 75 08             	pushl  0x8(%ebp)
80102365:	e8 c0 fc ff ff       	call   8010202a <readi>
8010236a:	83 c4 10             	add    $0x10,%esp
8010236d:	83 f8 10             	cmp    $0x10,%eax
80102370:	74 0d                	je     8010237f <dirlookup+0x53>
      panic("dirlookup read");
80102372:	83 ec 0c             	sub    $0xc,%esp
80102375:	68 ff 93 10 80       	push   $0x801093ff
8010237a:	e8 89 e2 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
8010237f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102383:	66 85 c0             	test   %ax,%ax
80102386:	74 47                	je     801023cf <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
80102388:	83 ec 08             	sub    $0x8,%esp
8010238b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010238e:	83 c0 02             	add    $0x2,%eax
80102391:	50                   	push   %eax
80102392:	ff 75 0c             	pushl  0xc(%ebp)
80102395:	e8 73 ff ff ff       	call   8010230d <namecmp>
8010239a:	83 c4 10             	add    $0x10,%esp
8010239d:	85 c0                	test   %eax,%eax
8010239f:	75 2f                	jne    801023d0 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
801023a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801023a5:	74 08                	je     801023af <dirlookup+0x83>
        *poff = off;
801023a7:	8b 45 10             	mov    0x10(%ebp),%eax
801023aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023ad:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801023af:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023b3:	0f b7 c0             	movzwl %ax,%eax
801023b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801023b9:	8b 45 08             	mov    0x8(%ebp),%eax
801023bc:	8b 00                	mov    (%eax),%eax
801023be:	83 ec 08             	sub    $0x8,%esp
801023c1:	ff 75 f0             	pushl  -0x10(%ebp)
801023c4:	50                   	push   %eax
801023c5:	e8 34 f6 ff ff       	call   801019fe <iget>
801023ca:	83 c4 10             	add    $0x10,%esp
801023cd:	eb 19                	jmp    801023e8 <dirlookup+0xbc>
      continue;
801023cf:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
801023d0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801023d4:	8b 45 08             	mov    0x8(%ebp),%eax
801023d7:	8b 40 58             	mov    0x58(%eax),%eax
801023da:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801023dd:	0f 82 76 ff ff ff    	jb     80102359 <dirlookup+0x2d>
    }
  }

  return 0;
801023e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023e8:	c9                   	leave  
801023e9:	c3                   	ret    

801023ea <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801023ea:	f3 0f 1e fb          	endbr32 
801023ee:	55                   	push   %ebp
801023ef:	89 e5                	mov    %esp,%ebp
801023f1:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801023f4:	83 ec 04             	sub    $0x4,%esp
801023f7:	6a 00                	push   $0x0
801023f9:	ff 75 0c             	pushl  0xc(%ebp)
801023fc:	ff 75 08             	pushl  0x8(%ebp)
801023ff:	e8 28 ff ff ff       	call   8010232c <dirlookup>
80102404:	83 c4 10             	add    $0x10,%esp
80102407:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010240a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010240e:	74 18                	je     80102428 <dirlink+0x3e>
    iput(ip);
80102410:	83 ec 0c             	sub    $0xc,%esp
80102413:	ff 75 f0             	pushl  -0x10(%ebp)
80102416:	e8 70 f8 ff ff       	call   80101c8b <iput>
8010241b:	83 c4 10             	add    $0x10,%esp
    return -1;
8010241e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102423:	e9 9c 00 00 00       	jmp    801024c4 <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102428:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010242f:	eb 39                	jmp    8010246a <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102434:	6a 10                	push   $0x10
80102436:	50                   	push   %eax
80102437:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010243a:	50                   	push   %eax
8010243b:	ff 75 08             	pushl  0x8(%ebp)
8010243e:	e8 e7 fb ff ff       	call   8010202a <readi>
80102443:	83 c4 10             	add    $0x10,%esp
80102446:	83 f8 10             	cmp    $0x10,%eax
80102449:	74 0d                	je     80102458 <dirlink+0x6e>
      panic("dirlink read");
8010244b:	83 ec 0c             	sub    $0xc,%esp
8010244e:	68 0e 94 10 80       	push   $0x8010940e
80102453:	e8 b0 e1 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
80102458:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010245c:	66 85 c0             	test   %ax,%ax
8010245f:	74 18                	je     80102479 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102464:	83 c0 10             	add    $0x10,%eax
80102467:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010246a:	8b 45 08             	mov    0x8(%ebp),%eax
8010246d:	8b 50 58             	mov    0x58(%eax),%edx
80102470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102473:	39 c2                	cmp    %eax,%edx
80102475:	77 ba                	ja     80102431 <dirlink+0x47>
80102477:	eb 01                	jmp    8010247a <dirlink+0x90>
      break;
80102479:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010247a:	83 ec 04             	sub    $0x4,%esp
8010247d:	6a 0e                	push   $0xe
8010247f:	ff 75 0c             	pushl  0xc(%ebp)
80102482:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102485:	83 c0 02             	add    $0x2,%eax
80102488:	50                   	push   %eax
80102489:	e8 a7 32 00 00       	call   80105735 <strncpy>
8010248e:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102491:	8b 45 10             	mov    0x10(%ebp),%eax
80102494:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249b:	6a 10                	push   $0x10
8010249d:	50                   	push   %eax
8010249e:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024a1:	50                   	push   %eax
801024a2:	ff 75 08             	pushl  0x8(%ebp)
801024a5:	e8 d9 fc ff ff       	call   80102183 <writei>
801024aa:	83 c4 10             	add    $0x10,%esp
801024ad:	83 f8 10             	cmp    $0x10,%eax
801024b0:	74 0d                	je     801024bf <dirlink+0xd5>
    panic("dirlink");
801024b2:	83 ec 0c             	sub    $0xc,%esp
801024b5:	68 1b 94 10 80       	push   $0x8010941b
801024ba:	e8 49 e1 ff ff       	call   80100608 <panic>

  return 0;
801024bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024c4:	c9                   	leave  
801024c5:	c3                   	ret    

801024c6 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801024c6:	f3 0f 1e fb          	endbr32 
801024ca:	55                   	push   %ebp
801024cb:	89 e5                	mov    %esp,%ebp
801024cd:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801024d0:	eb 04                	jmp    801024d6 <skipelem+0x10>
    path++;
801024d2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024d6:	8b 45 08             	mov    0x8(%ebp),%eax
801024d9:	0f b6 00             	movzbl (%eax),%eax
801024dc:	3c 2f                	cmp    $0x2f,%al
801024de:	74 f2                	je     801024d2 <skipelem+0xc>
  if(*path == 0)
801024e0:	8b 45 08             	mov    0x8(%ebp),%eax
801024e3:	0f b6 00             	movzbl (%eax),%eax
801024e6:	84 c0                	test   %al,%al
801024e8:	75 07                	jne    801024f1 <skipelem+0x2b>
    return 0;
801024ea:	b8 00 00 00 00       	mov    $0x0,%eax
801024ef:	eb 77                	jmp    80102568 <skipelem+0xa2>
  s = path;
801024f1:	8b 45 08             	mov    0x8(%ebp),%eax
801024f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801024f7:	eb 04                	jmp    801024fd <skipelem+0x37>
    path++;
801024f9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801024fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102500:	0f b6 00             	movzbl (%eax),%eax
80102503:	3c 2f                	cmp    $0x2f,%al
80102505:	74 0a                	je     80102511 <skipelem+0x4b>
80102507:	8b 45 08             	mov    0x8(%ebp),%eax
8010250a:	0f b6 00             	movzbl (%eax),%eax
8010250d:	84 c0                	test   %al,%al
8010250f:	75 e8                	jne    801024f9 <skipelem+0x33>
  len = path - s;
80102511:	8b 45 08             	mov    0x8(%ebp),%eax
80102514:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102517:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010251a:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010251e:	7e 15                	jle    80102535 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102520:	83 ec 04             	sub    $0x4,%esp
80102523:	6a 0e                	push   $0xe
80102525:	ff 75 f4             	pushl  -0xc(%ebp)
80102528:	ff 75 0c             	pushl  0xc(%ebp)
8010252b:	e8 0d 31 00 00       	call   8010563d <memmove>
80102530:	83 c4 10             	add    $0x10,%esp
80102533:	eb 26                	jmp    8010255b <skipelem+0x95>
  else {
    memmove(name, s, len);
80102535:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102538:	83 ec 04             	sub    $0x4,%esp
8010253b:	50                   	push   %eax
8010253c:	ff 75 f4             	pushl  -0xc(%ebp)
8010253f:	ff 75 0c             	pushl  0xc(%ebp)
80102542:	e8 f6 30 00 00       	call   8010563d <memmove>
80102547:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010254a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010254d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102550:	01 d0                	add    %edx,%eax
80102552:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102555:	eb 04                	jmp    8010255b <skipelem+0x95>
    path++;
80102557:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010255b:	8b 45 08             	mov    0x8(%ebp),%eax
8010255e:	0f b6 00             	movzbl (%eax),%eax
80102561:	3c 2f                	cmp    $0x2f,%al
80102563:	74 f2                	je     80102557 <skipelem+0x91>
  return path;
80102565:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102568:	c9                   	leave  
80102569:	c3                   	ret    

8010256a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010256a:	f3 0f 1e fb          	endbr32 
8010256e:	55                   	push   %ebp
8010256f:	89 e5                	mov    %esp,%ebp
80102571:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102574:	8b 45 08             	mov    0x8(%ebp),%eax
80102577:	0f b6 00             	movzbl (%eax),%eax
8010257a:	3c 2f                	cmp    $0x2f,%al
8010257c:	75 17                	jne    80102595 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
8010257e:	83 ec 08             	sub    $0x8,%esp
80102581:	6a 01                	push   $0x1
80102583:	6a 01                	push   $0x1
80102585:	e8 74 f4 ff ff       	call   801019fe <iget>
8010258a:	83 c4 10             	add    $0x10,%esp
8010258d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102590:	e9 ba 00 00 00       	jmp    8010264f <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
80102595:	e8 16 1f 00 00       	call   801044b0 <myproc>
8010259a:	8b 40 6c             	mov    0x6c(%eax),%eax
8010259d:	83 ec 0c             	sub    $0xc,%esp
801025a0:	50                   	push   %eax
801025a1:	e8 3e f5 ff ff       	call   80101ae4 <idup>
801025a6:	83 c4 10             	add    $0x10,%esp
801025a9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801025ac:	e9 9e 00 00 00       	jmp    8010264f <namex+0xe5>
    ilock(ip);
801025b1:	83 ec 0c             	sub    $0xc,%esp
801025b4:	ff 75 f4             	pushl  -0xc(%ebp)
801025b7:	e8 66 f5 ff ff       	call   80101b22 <ilock>
801025bc:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801025bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025c2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801025c6:	66 83 f8 01          	cmp    $0x1,%ax
801025ca:	74 18                	je     801025e4 <namex+0x7a>
      iunlockput(ip);
801025cc:	83 ec 0c             	sub    $0xc,%esp
801025cf:	ff 75 f4             	pushl  -0xc(%ebp)
801025d2:	e8 88 f7 ff ff       	call   80101d5f <iunlockput>
801025d7:	83 c4 10             	add    $0x10,%esp
      return 0;
801025da:	b8 00 00 00 00       	mov    $0x0,%eax
801025df:	e9 a7 00 00 00       	jmp    8010268b <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
801025e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025e8:	74 20                	je     8010260a <namex+0xa0>
801025ea:	8b 45 08             	mov    0x8(%ebp),%eax
801025ed:	0f b6 00             	movzbl (%eax),%eax
801025f0:	84 c0                	test   %al,%al
801025f2:	75 16                	jne    8010260a <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
801025f4:	83 ec 0c             	sub    $0xc,%esp
801025f7:	ff 75 f4             	pushl  -0xc(%ebp)
801025fa:	e8 3a f6 ff ff       	call   80101c39 <iunlock>
801025ff:	83 c4 10             	add    $0x10,%esp
      return ip;
80102602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102605:	e9 81 00 00 00       	jmp    8010268b <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010260a:	83 ec 04             	sub    $0x4,%esp
8010260d:	6a 00                	push   $0x0
8010260f:	ff 75 10             	pushl  0x10(%ebp)
80102612:	ff 75 f4             	pushl  -0xc(%ebp)
80102615:	e8 12 fd ff ff       	call   8010232c <dirlookup>
8010261a:	83 c4 10             	add    $0x10,%esp
8010261d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102620:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102624:	75 15                	jne    8010263b <namex+0xd1>
      iunlockput(ip);
80102626:	83 ec 0c             	sub    $0xc,%esp
80102629:	ff 75 f4             	pushl  -0xc(%ebp)
8010262c:	e8 2e f7 ff ff       	call   80101d5f <iunlockput>
80102631:	83 c4 10             	add    $0x10,%esp
      return 0;
80102634:	b8 00 00 00 00       	mov    $0x0,%eax
80102639:	eb 50                	jmp    8010268b <namex+0x121>
    }
    iunlockput(ip);
8010263b:	83 ec 0c             	sub    $0xc,%esp
8010263e:	ff 75 f4             	pushl  -0xc(%ebp)
80102641:	e8 19 f7 ff ff       	call   80101d5f <iunlockput>
80102646:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102649:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010264c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
8010264f:	83 ec 08             	sub    $0x8,%esp
80102652:	ff 75 10             	pushl  0x10(%ebp)
80102655:	ff 75 08             	pushl  0x8(%ebp)
80102658:	e8 69 fe ff ff       	call   801024c6 <skipelem>
8010265d:	83 c4 10             	add    $0x10,%esp
80102660:	89 45 08             	mov    %eax,0x8(%ebp)
80102663:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102667:	0f 85 44 ff ff ff    	jne    801025b1 <namex+0x47>
  }
  if(nameiparent){
8010266d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102671:	74 15                	je     80102688 <namex+0x11e>
    iput(ip);
80102673:	83 ec 0c             	sub    $0xc,%esp
80102676:	ff 75 f4             	pushl  -0xc(%ebp)
80102679:	e8 0d f6 ff ff       	call   80101c8b <iput>
8010267e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102681:	b8 00 00 00 00       	mov    $0x0,%eax
80102686:	eb 03                	jmp    8010268b <namex+0x121>
  }
  return ip;
80102688:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010268b:	c9                   	leave  
8010268c:	c3                   	ret    

8010268d <namei>:

struct inode*
namei(char *path)
{
8010268d:	f3 0f 1e fb          	endbr32 
80102691:	55                   	push   %ebp
80102692:	89 e5                	mov    %esp,%ebp
80102694:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102697:	83 ec 04             	sub    $0x4,%esp
8010269a:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010269d:	50                   	push   %eax
8010269e:	6a 00                	push   $0x0
801026a0:	ff 75 08             	pushl  0x8(%ebp)
801026a3:	e8 c2 fe ff ff       	call   8010256a <namex>
801026a8:	83 c4 10             	add    $0x10,%esp
}
801026ab:	c9                   	leave  
801026ac:	c3                   	ret    

801026ad <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801026ad:	f3 0f 1e fb          	endbr32 
801026b1:	55                   	push   %ebp
801026b2:	89 e5                	mov    %esp,%ebp
801026b4:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801026b7:	83 ec 04             	sub    $0x4,%esp
801026ba:	ff 75 0c             	pushl  0xc(%ebp)
801026bd:	6a 01                	push   $0x1
801026bf:	ff 75 08             	pushl  0x8(%ebp)
801026c2:	e8 a3 fe ff ff       	call   8010256a <namex>
801026c7:	83 c4 10             	add    $0x10,%esp
}
801026ca:	c9                   	leave  
801026cb:	c3                   	ret    

801026cc <inb>:
{
801026cc:	55                   	push   %ebp
801026cd:	89 e5                	mov    %esp,%ebp
801026cf:	83 ec 14             	sub    $0x14,%esp
801026d2:	8b 45 08             	mov    0x8(%ebp),%eax
801026d5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801026d9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801026dd:	89 c2                	mov    %eax,%edx
801026df:	ec                   	in     (%dx),%al
801026e0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801026e3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801026e7:	c9                   	leave  
801026e8:	c3                   	ret    

801026e9 <insl>:
{
801026e9:	55                   	push   %ebp
801026ea:	89 e5                	mov    %esp,%ebp
801026ec:	57                   	push   %edi
801026ed:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801026ee:	8b 55 08             	mov    0x8(%ebp),%edx
801026f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026f4:	8b 45 10             	mov    0x10(%ebp),%eax
801026f7:	89 cb                	mov    %ecx,%ebx
801026f9:	89 df                	mov    %ebx,%edi
801026fb:	89 c1                	mov    %eax,%ecx
801026fd:	fc                   	cld    
801026fe:	f3 6d                	rep insl (%dx),%es:(%edi)
80102700:	89 c8                	mov    %ecx,%eax
80102702:	89 fb                	mov    %edi,%ebx
80102704:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102707:	89 45 10             	mov    %eax,0x10(%ebp)
}
8010270a:	90                   	nop
8010270b:	5b                   	pop    %ebx
8010270c:	5f                   	pop    %edi
8010270d:	5d                   	pop    %ebp
8010270e:	c3                   	ret    

8010270f <outb>:
{
8010270f:	55                   	push   %ebp
80102710:	89 e5                	mov    %esp,%ebp
80102712:	83 ec 08             	sub    $0x8,%esp
80102715:	8b 45 08             	mov    0x8(%ebp),%eax
80102718:	8b 55 0c             	mov    0xc(%ebp),%edx
8010271b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010271f:	89 d0                	mov    %edx,%eax
80102721:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102724:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102728:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010272c:	ee                   	out    %al,(%dx)
}
8010272d:	90                   	nop
8010272e:	c9                   	leave  
8010272f:	c3                   	ret    

80102730 <outsl>:
{
80102730:	55                   	push   %ebp
80102731:	89 e5                	mov    %esp,%ebp
80102733:	56                   	push   %esi
80102734:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102735:	8b 55 08             	mov    0x8(%ebp),%edx
80102738:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010273b:	8b 45 10             	mov    0x10(%ebp),%eax
8010273e:	89 cb                	mov    %ecx,%ebx
80102740:	89 de                	mov    %ebx,%esi
80102742:	89 c1                	mov    %eax,%ecx
80102744:	fc                   	cld    
80102745:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102747:	89 c8                	mov    %ecx,%eax
80102749:	89 f3                	mov    %esi,%ebx
8010274b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010274e:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102751:	90                   	nop
80102752:	5b                   	pop    %ebx
80102753:	5e                   	pop    %esi
80102754:	5d                   	pop    %ebp
80102755:	c3                   	ret    

80102756 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102756:	f3 0f 1e fb          	endbr32 
8010275a:	55                   	push   %ebp
8010275b:	89 e5                	mov    %esp,%ebp
8010275d:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102760:	90                   	nop
80102761:	68 f7 01 00 00       	push   $0x1f7
80102766:	e8 61 ff ff ff       	call   801026cc <inb>
8010276b:	83 c4 04             	add    $0x4,%esp
8010276e:	0f b6 c0             	movzbl %al,%eax
80102771:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102774:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102777:	25 c0 00 00 00       	and    $0xc0,%eax
8010277c:	83 f8 40             	cmp    $0x40,%eax
8010277f:	75 e0                	jne    80102761 <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102781:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102785:	74 11                	je     80102798 <idewait+0x42>
80102787:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010278a:	83 e0 21             	and    $0x21,%eax
8010278d:	85 c0                	test   %eax,%eax
8010278f:	74 07                	je     80102798 <idewait+0x42>
    return -1;
80102791:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102796:	eb 05                	jmp    8010279d <idewait+0x47>
  return 0;
80102798:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010279d:	c9                   	leave  
8010279e:	c3                   	ret    

8010279f <ideinit>:

void
ideinit(void)
{
8010279f:	f3 0f 1e fb          	endbr32 
801027a3:	55                   	push   %ebp
801027a4:	89 e5                	mov    %esp,%ebp
801027a6:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801027a9:	83 ec 08             	sub    $0x8,%esp
801027ac:	68 23 94 10 80       	push   $0x80109423
801027b1:	68 00 c6 10 80       	push   $0x8010c600
801027b6:	e8 f6 2a 00 00       	call   801052b1 <initlock>
801027bb:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801027be:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
801027c3:	83 e8 01             	sub    $0x1,%eax
801027c6:	83 ec 08             	sub    $0x8,%esp
801027c9:	50                   	push   %eax
801027ca:	6a 0e                	push   $0xe
801027cc:	e8 bb 04 00 00       	call   80102c8c <ioapicenable>
801027d1:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801027d4:	83 ec 0c             	sub    $0xc,%esp
801027d7:	6a 00                	push   $0x0
801027d9:	e8 78 ff ff ff       	call   80102756 <idewait>
801027de:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801027e1:	83 ec 08             	sub    $0x8,%esp
801027e4:	68 f0 00 00 00       	push   $0xf0
801027e9:	68 f6 01 00 00       	push   $0x1f6
801027ee:	e8 1c ff ff ff       	call   8010270f <outb>
801027f3:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
801027f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801027fd:	eb 24                	jmp    80102823 <ideinit+0x84>
    if(inb(0x1f7) != 0){
801027ff:	83 ec 0c             	sub    $0xc,%esp
80102802:	68 f7 01 00 00       	push   $0x1f7
80102807:	e8 c0 fe ff ff       	call   801026cc <inb>
8010280c:	83 c4 10             	add    $0x10,%esp
8010280f:	84 c0                	test   %al,%al
80102811:	74 0c                	je     8010281f <ideinit+0x80>
      havedisk1 = 1;
80102813:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
8010281a:	00 00 00 
      break;
8010281d:	eb 0d                	jmp    8010282c <ideinit+0x8d>
  for(i=0; i<1000; i++){
8010281f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102823:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010282a:	7e d3                	jle    801027ff <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010282c:	83 ec 08             	sub    $0x8,%esp
8010282f:	68 e0 00 00 00       	push   $0xe0
80102834:	68 f6 01 00 00       	push   $0x1f6
80102839:	e8 d1 fe ff ff       	call   8010270f <outb>
8010283e:	83 c4 10             	add    $0x10,%esp
}
80102841:	90                   	nop
80102842:	c9                   	leave  
80102843:	c3                   	ret    

80102844 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102844:	f3 0f 1e fb          	endbr32 
80102848:	55                   	push   %ebp
80102849:	89 e5                	mov    %esp,%ebp
8010284b:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010284e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102852:	75 0d                	jne    80102861 <idestart+0x1d>
    panic("idestart");
80102854:	83 ec 0c             	sub    $0xc,%esp
80102857:	68 27 94 10 80       	push   $0x80109427
8010285c:	e8 a7 dd ff ff       	call   80100608 <panic>
  if(b->blockno >= FSSIZE)
80102861:	8b 45 08             	mov    0x8(%ebp),%eax
80102864:	8b 40 08             	mov    0x8(%eax),%eax
80102867:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010286c:	76 0d                	jbe    8010287b <idestart+0x37>
    panic("incorrect blockno");
8010286e:	83 ec 0c             	sub    $0xc,%esp
80102871:	68 30 94 10 80       	push   $0x80109430
80102876:	e8 8d dd ff ff       	call   80100608 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010287b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102882:	8b 45 08             	mov    0x8(%ebp),%eax
80102885:	8b 50 08             	mov    0x8(%eax),%edx
80102888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010288b:	0f af c2             	imul   %edx,%eax
8010288e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102891:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102895:	75 07                	jne    8010289e <idestart+0x5a>
80102897:	b8 20 00 00 00       	mov    $0x20,%eax
8010289c:	eb 05                	jmp    801028a3 <idestart+0x5f>
8010289e:	b8 c4 00 00 00       	mov    $0xc4,%eax
801028a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801028a6:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028aa:	75 07                	jne    801028b3 <idestart+0x6f>
801028ac:	b8 30 00 00 00       	mov    $0x30,%eax
801028b1:	eb 05                	jmp    801028b8 <idestart+0x74>
801028b3:	b8 c5 00 00 00       	mov    $0xc5,%eax
801028b8:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801028bb:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801028bf:	7e 0d                	jle    801028ce <idestart+0x8a>
801028c1:	83 ec 0c             	sub    $0xc,%esp
801028c4:	68 27 94 10 80       	push   $0x80109427
801028c9:	e8 3a dd ff ff       	call   80100608 <panic>

  idewait(0);
801028ce:	83 ec 0c             	sub    $0xc,%esp
801028d1:	6a 00                	push   $0x0
801028d3:	e8 7e fe ff ff       	call   80102756 <idewait>
801028d8:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801028db:	83 ec 08             	sub    $0x8,%esp
801028de:	6a 00                	push   $0x0
801028e0:	68 f6 03 00 00       	push   $0x3f6
801028e5:	e8 25 fe ff ff       	call   8010270f <outb>
801028ea:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
801028ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f0:	0f b6 c0             	movzbl %al,%eax
801028f3:	83 ec 08             	sub    $0x8,%esp
801028f6:	50                   	push   %eax
801028f7:	68 f2 01 00 00       	push   $0x1f2
801028fc:	e8 0e fe ff ff       	call   8010270f <outb>
80102901:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102904:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102907:	0f b6 c0             	movzbl %al,%eax
8010290a:	83 ec 08             	sub    $0x8,%esp
8010290d:	50                   	push   %eax
8010290e:	68 f3 01 00 00       	push   $0x1f3
80102913:	e8 f7 fd ff ff       	call   8010270f <outb>
80102918:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
8010291b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010291e:	c1 f8 08             	sar    $0x8,%eax
80102921:	0f b6 c0             	movzbl %al,%eax
80102924:	83 ec 08             	sub    $0x8,%esp
80102927:	50                   	push   %eax
80102928:	68 f4 01 00 00       	push   $0x1f4
8010292d:	e8 dd fd ff ff       	call   8010270f <outb>
80102932:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102935:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102938:	c1 f8 10             	sar    $0x10,%eax
8010293b:	0f b6 c0             	movzbl %al,%eax
8010293e:	83 ec 08             	sub    $0x8,%esp
80102941:	50                   	push   %eax
80102942:	68 f5 01 00 00       	push   $0x1f5
80102947:	e8 c3 fd ff ff       	call   8010270f <outb>
8010294c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010294f:	8b 45 08             	mov    0x8(%ebp),%eax
80102952:	8b 40 04             	mov    0x4(%eax),%eax
80102955:	c1 e0 04             	shl    $0x4,%eax
80102958:	83 e0 10             	and    $0x10,%eax
8010295b:	89 c2                	mov    %eax,%edx
8010295d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102960:	c1 f8 18             	sar    $0x18,%eax
80102963:	83 e0 0f             	and    $0xf,%eax
80102966:	09 d0                	or     %edx,%eax
80102968:	83 c8 e0             	or     $0xffffffe0,%eax
8010296b:	0f b6 c0             	movzbl %al,%eax
8010296e:	83 ec 08             	sub    $0x8,%esp
80102971:	50                   	push   %eax
80102972:	68 f6 01 00 00       	push   $0x1f6
80102977:	e8 93 fd ff ff       	call   8010270f <outb>
8010297c:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
8010297f:	8b 45 08             	mov    0x8(%ebp),%eax
80102982:	8b 00                	mov    (%eax),%eax
80102984:	83 e0 04             	and    $0x4,%eax
80102987:	85 c0                	test   %eax,%eax
80102989:	74 35                	je     801029c0 <idestart+0x17c>
    outb(0x1f7, write_cmd);
8010298b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010298e:	0f b6 c0             	movzbl %al,%eax
80102991:	83 ec 08             	sub    $0x8,%esp
80102994:	50                   	push   %eax
80102995:	68 f7 01 00 00       	push   $0x1f7
8010299a:	e8 70 fd ff ff       	call   8010270f <outb>
8010299f:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801029a2:	8b 45 08             	mov    0x8(%ebp),%eax
801029a5:	83 c0 5c             	add    $0x5c,%eax
801029a8:	83 ec 04             	sub    $0x4,%esp
801029ab:	68 80 00 00 00       	push   $0x80
801029b0:	50                   	push   %eax
801029b1:	68 f0 01 00 00       	push   $0x1f0
801029b6:	e8 75 fd ff ff       	call   80102730 <outsl>
801029bb:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
801029be:	eb 17                	jmp    801029d7 <idestart+0x193>
    outb(0x1f7, read_cmd);
801029c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801029c3:	0f b6 c0             	movzbl %al,%eax
801029c6:	83 ec 08             	sub    $0x8,%esp
801029c9:	50                   	push   %eax
801029ca:	68 f7 01 00 00       	push   $0x1f7
801029cf:	e8 3b fd ff ff       	call   8010270f <outb>
801029d4:	83 c4 10             	add    $0x10,%esp
}
801029d7:	90                   	nop
801029d8:	c9                   	leave  
801029d9:	c3                   	ret    

801029da <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801029da:	f3 0f 1e fb          	endbr32 
801029de:	55                   	push   %ebp
801029df:	89 e5                	mov    %esp,%ebp
801029e1:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801029e4:	83 ec 0c             	sub    $0xc,%esp
801029e7:	68 00 c6 10 80       	push   $0x8010c600
801029ec:	e8 e6 28 00 00       	call   801052d7 <acquire>
801029f1:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
801029f4:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801029f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a00:	75 15                	jne    80102a17 <ideintr+0x3d>
    release(&idelock);
80102a02:	83 ec 0c             	sub    $0xc,%esp
80102a05:	68 00 c6 10 80       	push   $0x8010c600
80102a0a:	e8 3a 29 00 00       	call   80105349 <release>
80102a0f:	83 c4 10             	add    $0x10,%esp
    return;
80102a12:	e9 9a 00 00 00       	jmp    80102ab1 <ideintr+0xd7>
  }
  idequeue = b->qnext;
80102a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a1a:	8b 40 58             	mov    0x58(%eax),%eax
80102a1d:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a25:	8b 00                	mov    (%eax),%eax
80102a27:	83 e0 04             	and    $0x4,%eax
80102a2a:	85 c0                	test   %eax,%eax
80102a2c:	75 2d                	jne    80102a5b <ideintr+0x81>
80102a2e:	83 ec 0c             	sub    $0xc,%esp
80102a31:	6a 01                	push   $0x1
80102a33:	e8 1e fd ff ff       	call   80102756 <idewait>
80102a38:	83 c4 10             	add    $0x10,%esp
80102a3b:	85 c0                	test   %eax,%eax
80102a3d:	78 1c                	js     80102a5b <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a42:	83 c0 5c             	add    $0x5c,%eax
80102a45:	83 ec 04             	sub    $0x4,%esp
80102a48:	68 80 00 00 00       	push   $0x80
80102a4d:	50                   	push   %eax
80102a4e:	68 f0 01 00 00       	push   $0x1f0
80102a53:	e8 91 fc ff ff       	call   801026e9 <insl>
80102a58:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5e:	8b 00                	mov    (%eax),%eax
80102a60:	83 c8 02             	or     $0x2,%eax
80102a63:	89 c2                	mov    %eax,%edx
80102a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a68:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a6d:	8b 00                	mov    (%eax),%eax
80102a6f:	83 e0 fb             	and    $0xfffffffb,%eax
80102a72:	89 c2                	mov    %eax,%edx
80102a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a77:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102a79:	83 ec 0c             	sub    $0xc,%esp
80102a7c:	ff 75 f4             	pushl  -0xc(%ebp)
80102a7f:	e8 d3 24 00 00       	call   80104f57 <wakeup>
80102a84:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102a87:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a8c:	85 c0                	test   %eax,%eax
80102a8e:	74 11                	je     80102aa1 <ideintr+0xc7>
    idestart(idequeue);
80102a90:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a95:	83 ec 0c             	sub    $0xc,%esp
80102a98:	50                   	push   %eax
80102a99:	e8 a6 fd ff ff       	call   80102844 <idestart>
80102a9e:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102aa1:	83 ec 0c             	sub    $0xc,%esp
80102aa4:	68 00 c6 10 80       	push   $0x8010c600
80102aa9:	e8 9b 28 00 00       	call   80105349 <release>
80102aae:	83 c4 10             	add    $0x10,%esp
}
80102ab1:	c9                   	leave  
80102ab2:	c3                   	ret    

80102ab3 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102ab3:	f3 0f 1e fb          	endbr32 
80102ab7:	55                   	push   %ebp
80102ab8:	89 e5                	mov    %esp,%ebp
80102aba:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102abd:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac0:	83 c0 0c             	add    $0xc,%eax
80102ac3:	83 ec 0c             	sub    $0xc,%esp
80102ac6:	50                   	push   %eax
80102ac7:	e8 4c 27 00 00       	call   80105218 <holdingsleep>
80102acc:	83 c4 10             	add    $0x10,%esp
80102acf:	85 c0                	test   %eax,%eax
80102ad1:	75 0d                	jne    80102ae0 <iderw+0x2d>
    panic("iderw: buf not locked");
80102ad3:	83 ec 0c             	sub    $0xc,%esp
80102ad6:	68 42 94 10 80       	push   $0x80109442
80102adb:	e8 28 db ff ff       	call   80100608 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102ae0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae3:	8b 00                	mov    (%eax),%eax
80102ae5:	83 e0 06             	and    $0x6,%eax
80102ae8:	83 f8 02             	cmp    $0x2,%eax
80102aeb:	75 0d                	jne    80102afa <iderw+0x47>
    panic("iderw: nothing to do");
80102aed:	83 ec 0c             	sub    $0xc,%esp
80102af0:	68 58 94 10 80       	push   $0x80109458
80102af5:	e8 0e db ff ff       	call   80100608 <panic>
  if(b->dev != 0 && !havedisk1)
80102afa:	8b 45 08             	mov    0x8(%ebp),%eax
80102afd:	8b 40 04             	mov    0x4(%eax),%eax
80102b00:	85 c0                	test   %eax,%eax
80102b02:	74 16                	je     80102b1a <iderw+0x67>
80102b04:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102b09:	85 c0                	test   %eax,%eax
80102b0b:	75 0d                	jne    80102b1a <iderw+0x67>
    panic("iderw: ide disk 1 not present");
80102b0d:	83 ec 0c             	sub    $0xc,%esp
80102b10:	68 6d 94 10 80       	push   $0x8010946d
80102b15:	e8 ee da ff ff       	call   80100608 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b1a:	83 ec 0c             	sub    $0xc,%esp
80102b1d:	68 00 c6 10 80       	push   $0x8010c600
80102b22:	e8 b0 27 00 00       	call   801052d7 <acquire>
80102b27:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2d:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b34:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102b3b:	eb 0b                	jmp    80102b48 <iderw+0x95>
80102b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b40:	8b 00                	mov    (%eax),%eax
80102b42:	83 c0 58             	add    $0x58,%eax
80102b45:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b4b:	8b 00                	mov    (%eax),%eax
80102b4d:	85 c0                	test   %eax,%eax
80102b4f:	75 ec                	jne    80102b3d <iderw+0x8a>
    ;
  *pp = b;
80102b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b54:	8b 55 08             	mov    0x8(%ebp),%edx
80102b57:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102b59:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102b5e:	39 45 08             	cmp    %eax,0x8(%ebp)
80102b61:	75 23                	jne    80102b86 <iderw+0xd3>
    idestart(b);
80102b63:	83 ec 0c             	sub    $0xc,%esp
80102b66:	ff 75 08             	pushl  0x8(%ebp)
80102b69:	e8 d6 fc ff ff       	call   80102844 <idestart>
80102b6e:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b71:	eb 13                	jmp    80102b86 <iderw+0xd3>
    sleep(b, &idelock);
80102b73:	83 ec 08             	sub    $0x8,%esp
80102b76:	68 00 c6 10 80       	push   $0x8010c600
80102b7b:	ff 75 08             	pushl  0x8(%ebp)
80102b7e:	e8 e2 22 00 00       	call   80104e65 <sleep>
80102b83:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b86:	8b 45 08             	mov    0x8(%ebp),%eax
80102b89:	8b 00                	mov    (%eax),%eax
80102b8b:	83 e0 06             	and    $0x6,%eax
80102b8e:	83 f8 02             	cmp    $0x2,%eax
80102b91:	75 e0                	jne    80102b73 <iderw+0xc0>
  }


  release(&idelock);
80102b93:	83 ec 0c             	sub    $0xc,%esp
80102b96:	68 00 c6 10 80       	push   $0x8010c600
80102b9b:	e8 a9 27 00 00       	call   80105349 <release>
80102ba0:	83 c4 10             	add    $0x10,%esp
}
80102ba3:	90                   	nop
80102ba4:	c9                   	leave  
80102ba5:	c3                   	ret    

80102ba6 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102ba6:	f3 0f 1e fb          	endbr32 
80102baa:	55                   	push   %ebp
80102bab:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bad:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bb2:	8b 55 08             	mov    0x8(%ebp),%edx
80102bb5:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102bb7:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bbc:	8b 40 10             	mov    0x10(%eax),%eax
}
80102bbf:	5d                   	pop    %ebp
80102bc0:	c3                   	ret    

80102bc1 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102bc1:	f3 0f 1e fb          	endbr32 
80102bc5:	55                   	push   %ebp
80102bc6:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bc8:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bcd:	8b 55 08             	mov    0x8(%ebp),%edx
80102bd0:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102bd2:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bd7:	8b 55 0c             	mov    0xc(%ebp),%edx
80102bda:	89 50 10             	mov    %edx,0x10(%eax)
}
80102bdd:	90                   	nop
80102bde:	5d                   	pop    %ebp
80102bdf:	c3                   	ret    

80102be0 <ioapicinit>:

void
ioapicinit(void)
{
80102be0:	f3 0f 1e fb          	endbr32 
80102be4:	55                   	push   %ebp
80102be5:	89 e5                	mov    %esp,%ebp
80102be7:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102bea:	c7 05 d4 46 11 80 00 	movl   $0xfec00000,0x801146d4
80102bf1:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102bf4:	6a 01                	push   $0x1
80102bf6:	e8 ab ff ff ff       	call   80102ba6 <ioapicread>
80102bfb:	83 c4 04             	add    $0x4,%esp
80102bfe:	c1 e8 10             	shr    $0x10,%eax
80102c01:	25 ff 00 00 00       	and    $0xff,%eax
80102c06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c09:	6a 00                	push   $0x0
80102c0b:	e8 96 ff ff ff       	call   80102ba6 <ioapicread>
80102c10:	83 c4 04             	add    $0x4,%esp
80102c13:	c1 e8 18             	shr    $0x18,%eax
80102c16:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c19:	0f b6 05 00 48 11 80 	movzbl 0x80114800,%eax
80102c20:	0f b6 c0             	movzbl %al,%eax
80102c23:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102c26:	74 10                	je     80102c38 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c28:	83 ec 0c             	sub    $0xc,%esp
80102c2b:	68 8c 94 10 80       	push   $0x8010948c
80102c30:	e8 e3 d7 ff ff       	call   80100418 <cprintf>
80102c35:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c38:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c3f:	eb 3f                	jmp    80102c80 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c44:	83 c0 20             	add    $0x20,%eax
80102c47:	0d 00 00 01 00       	or     $0x10000,%eax
80102c4c:	89 c2                	mov    %eax,%edx
80102c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c51:	83 c0 08             	add    $0x8,%eax
80102c54:	01 c0                	add    %eax,%eax
80102c56:	83 ec 08             	sub    $0x8,%esp
80102c59:	52                   	push   %edx
80102c5a:	50                   	push   %eax
80102c5b:	e8 61 ff ff ff       	call   80102bc1 <ioapicwrite>
80102c60:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c66:	83 c0 08             	add    $0x8,%eax
80102c69:	01 c0                	add    %eax,%eax
80102c6b:	83 c0 01             	add    $0x1,%eax
80102c6e:	83 ec 08             	sub    $0x8,%esp
80102c71:	6a 00                	push   $0x0
80102c73:	50                   	push   %eax
80102c74:	e8 48 ff ff ff       	call   80102bc1 <ioapicwrite>
80102c79:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102c7c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c83:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c86:	7e b9                	jle    80102c41 <ioapicinit+0x61>
  }
}
80102c88:	90                   	nop
80102c89:	90                   	nop
80102c8a:	c9                   	leave  
80102c8b:	c3                   	ret    

80102c8c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c8c:	f3 0f 1e fb          	endbr32 
80102c90:	55                   	push   %ebp
80102c91:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102c93:	8b 45 08             	mov    0x8(%ebp),%eax
80102c96:	83 c0 20             	add    $0x20,%eax
80102c99:	89 c2                	mov    %eax,%edx
80102c9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c9e:	83 c0 08             	add    $0x8,%eax
80102ca1:	01 c0                	add    %eax,%eax
80102ca3:	52                   	push   %edx
80102ca4:	50                   	push   %eax
80102ca5:	e8 17 ff ff ff       	call   80102bc1 <ioapicwrite>
80102caa:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102cad:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cb0:	c1 e0 18             	shl    $0x18,%eax
80102cb3:	89 c2                	mov    %eax,%edx
80102cb5:	8b 45 08             	mov    0x8(%ebp),%eax
80102cb8:	83 c0 08             	add    $0x8,%eax
80102cbb:	01 c0                	add    %eax,%eax
80102cbd:	83 c0 01             	add    $0x1,%eax
80102cc0:	52                   	push   %edx
80102cc1:	50                   	push   %eax
80102cc2:	e8 fa fe ff ff       	call   80102bc1 <ioapicwrite>
80102cc7:	83 c4 08             	add    $0x8,%esp
}
80102cca:	90                   	nop
80102ccb:	c9                   	leave  
80102ccc:	c3                   	ret    

80102ccd <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102ccd:	f3 0f 1e fb          	endbr32 
80102cd1:	55                   	push   %ebp
80102cd2:	89 e5                	mov    %esp,%ebp
80102cd4:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102cd7:	83 ec 08             	sub    $0x8,%esp
80102cda:	68 be 94 10 80       	push   $0x801094be
80102cdf:	68 e0 46 11 80       	push   $0x801146e0
80102ce4:	e8 c8 25 00 00       	call   801052b1 <initlock>
80102ce9:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102cec:	c7 05 14 47 11 80 00 	movl   $0x0,0x80114714
80102cf3:	00 00 00 
  freerange(vstart, vend);
80102cf6:	83 ec 08             	sub    $0x8,%esp
80102cf9:	ff 75 0c             	pushl  0xc(%ebp)
80102cfc:	ff 75 08             	pushl  0x8(%ebp)
80102cff:	e8 2e 00 00 00       	call   80102d32 <freerange>
80102d04:	83 c4 10             	add    $0x10,%esp
}
80102d07:	90                   	nop
80102d08:	c9                   	leave  
80102d09:	c3                   	ret    

80102d0a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d0a:	f3 0f 1e fb          	endbr32 
80102d0e:	55                   	push   %ebp
80102d0f:	89 e5                	mov    %esp,%ebp
80102d11:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102d14:	83 ec 08             	sub    $0x8,%esp
80102d17:	ff 75 0c             	pushl  0xc(%ebp)
80102d1a:	ff 75 08             	pushl  0x8(%ebp)
80102d1d:	e8 10 00 00 00       	call   80102d32 <freerange>
80102d22:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102d25:	c7 05 14 47 11 80 01 	movl   $0x1,0x80114714
80102d2c:	00 00 00 
}
80102d2f:	90                   	nop
80102d30:	c9                   	leave  
80102d31:	c3                   	ret    

80102d32 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d32:	f3 0f 1e fb          	endbr32 
80102d36:	55                   	push   %ebp
80102d37:	89 e5                	mov    %esp,%ebp
80102d39:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d3c:	8b 45 08             	mov    0x8(%ebp),%eax
80102d3f:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d49:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d4c:	eb 15                	jmp    80102d63 <freerange+0x31>
    kfree(p);
80102d4e:	83 ec 0c             	sub    $0xc,%esp
80102d51:	ff 75 f4             	pushl  -0xc(%ebp)
80102d54:	e8 1b 00 00 00       	call   80102d74 <kfree>
80102d59:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d5c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d66:	05 00 10 00 00       	add    $0x1000,%eax
80102d6b:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102d6e:	73 de                	jae    80102d4e <freerange+0x1c>
}
80102d70:	90                   	nop
80102d71:	90                   	nop
80102d72:	c9                   	leave  
80102d73:	c3                   	ret    

80102d74 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d74:	f3 0f 1e fb          	endbr32 
80102d78:	55                   	push   %ebp
80102d79:	89 e5                	mov    %esp,%ebp
80102d7b:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102d7e:	8b 45 08             	mov    0x8(%ebp),%eax
80102d81:	25 ff 0f 00 00       	and    $0xfff,%eax
80102d86:	85 c0                	test   %eax,%eax
80102d88:	75 18                	jne    80102da2 <kfree+0x2e>
80102d8a:	81 7d 08 48 89 11 80 	cmpl   $0x80118948,0x8(%ebp)
80102d91:	72 0f                	jb     80102da2 <kfree+0x2e>
80102d93:	8b 45 08             	mov    0x8(%ebp),%eax
80102d96:	05 00 00 00 80       	add    $0x80000000,%eax
80102d9b:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102da0:	76 0d                	jbe    80102daf <kfree+0x3b>
    panic("kfree");
80102da2:	83 ec 0c             	sub    $0xc,%esp
80102da5:	68 c3 94 10 80       	push   $0x801094c3
80102daa:	e8 59 d8 ff ff       	call   80100608 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102daf:	83 ec 04             	sub    $0x4,%esp
80102db2:	68 00 10 00 00       	push   $0x1000
80102db7:	6a 01                	push   $0x1
80102db9:	ff 75 08             	pushl  0x8(%ebp)
80102dbc:	e8 b5 27 00 00       	call   80105576 <memset>
80102dc1:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102dc4:	a1 14 47 11 80       	mov    0x80114714,%eax
80102dc9:	85 c0                	test   %eax,%eax
80102dcb:	74 10                	je     80102ddd <kfree+0x69>
    acquire(&kmem.lock);
80102dcd:	83 ec 0c             	sub    $0xc,%esp
80102dd0:	68 e0 46 11 80       	push   $0x801146e0
80102dd5:	e8 fd 24 00 00       	call   801052d7 <acquire>
80102dda:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102ddd:	8b 45 08             	mov    0x8(%ebp),%eax
80102de0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102de3:	8b 15 18 47 11 80    	mov    0x80114718,%edx
80102de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dec:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102df1:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102df6:	a1 14 47 11 80       	mov    0x80114714,%eax
80102dfb:	85 c0                	test   %eax,%eax
80102dfd:	74 10                	je     80102e0f <kfree+0x9b>
    release(&kmem.lock);
80102dff:	83 ec 0c             	sub    $0xc,%esp
80102e02:	68 e0 46 11 80       	push   $0x801146e0
80102e07:	e8 3d 25 00 00       	call   80105349 <release>
80102e0c:	83 c4 10             	add    $0x10,%esp
}
80102e0f:	90                   	nop
80102e10:	c9                   	leave  
80102e11:	c3                   	ret    

80102e12 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e12:	f3 0f 1e fb          	endbr32 
80102e16:	55                   	push   %ebp
80102e17:	89 e5                	mov    %esp,%ebp
80102e19:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102e1c:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e21:	85 c0                	test   %eax,%eax
80102e23:	74 10                	je     80102e35 <kalloc+0x23>
    acquire(&kmem.lock);
80102e25:	83 ec 0c             	sub    $0xc,%esp
80102e28:	68 e0 46 11 80       	push   $0x801146e0
80102e2d:	e8 a5 24 00 00       	call   801052d7 <acquire>
80102e32:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102e35:	a1 18 47 11 80       	mov    0x80114718,%eax
80102e3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e3d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e41:	74 0a                	je     80102e4d <kalloc+0x3b>
    kmem.freelist = r->next;
80102e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e46:	8b 00                	mov    (%eax),%eax
80102e48:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102e4d:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e52:	85 c0                	test   %eax,%eax
80102e54:	74 10                	je     80102e66 <kalloc+0x54>
    release(&kmem.lock);
80102e56:	83 ec 0c             	sub    $0xc,%esp
80102e59:	68 e0 46 11 80       	push   $0x801146e0
80102e5e:	e8 e6 24 00 00       	call   80105349 <release>
80102e63:	83 c4 10             	add    $0x10,%esp

  return (char*)r;
80102e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e69:	c9                   	leave  
80102e6a:	c3                   	ret    

80102e6b <inb>:
{
80102e6b:	55                   	push   %ebp
80102e6c:	89 e5                	mov    %esp,%ebp
80102e6e:	83 ec 14             	sub    $0x14,%esp
80102e71:	8b 45 08             	mov    0x8(%ebp),%eax
80102e74:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e78:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e7c:	89 c2                	mov    %eax,%edx
80102e7e:	ec                   	in     (%dx),%al
80102e7f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e82:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e86:	c9                   	leave  
80102e87:	c3                   	ret    

80102e88 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e88:	f3 0f 1e fb          	endbr32 
80102e8c:	55                   	push   %ebp
80102e8d:	89 e5                	mov    %esp,%ebp
80102e8f:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102e92:	6a 64                	push   $0x64
80102e94:	e8 d2 ff ff ff       	call   80102e6b <inb>
80102e99:	83 c4 04             	add    $0x4,%esp
80102e9c:	0f b6 c0             	movzbl %al,%eax
80102e9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea5:	83 e0 01             	and    $0x1,%eax
80102ea8:	85 c0                	test   %eax,%eax
80102eaa:	75 0a                	jne    80102eb6 <kbdgetc+0x2e>
    return -1;
80102eac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102eb1:	e9 23 01 00 00       	jmp    80102fd9 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102eb6:	6a 60                	push   $0x60
80102eb8:	e8 ae ff ff ff       	call   80102e6b <inb>
80102ebd:	83 c4 04             	add    $0x4,%esp
80102ec0:	0f b6 c0             	movzbl %al,%eax
80102ec3:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102ec6:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102ecd:	75 17                	jne    80102ee6 <kbdgetc+0x5e>
    shift |= E0ESC;
80102ecf:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102ed4:	83 c8 40             	or     $0x40,%eax
80102ed7:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102edc:	b8 00 00 00 00       	mov    $0x0,%eax
80102ee1:	e9 f3 00 00 00       	jmp    80102fd9 <kbdgetc+0x151>
  } else if(data & 0x80){
80102ee6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ee9:	25 80 00 00 00       	and    $0x80,%eax
80102eee:	85 c0                	test   %eax,%eax
80102ef0:	74 45                	je     80102f37 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102ef2:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102ef7:	83 e0 40             	and    $0x40,%eax
80102efa:	85 c0                	test   %eax,%eax
80102efc:	75 08                	jne    80102f06 <kbdgetc+0x7e>
80102efe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f01:	83 e0 7f             	and    $0x7f,%eax
80102f04:	eb 03                	jmp    80102f09 <kbdgetc+0x81>
80102f06:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f09:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f0f:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f14:	0f b6 00             	movzbl (%eax),%eax
80102f17:	83 c8 40             	or     $0x40,%eax
80102f1a:	0f b6 c0             	movzbl %al,%eax
80102f1d:	f7 d0                	not    %eax
80102f1f:	89 c2                	mov    %eax,%edx
80102f21:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f26:	21 d0                	and    %edx,%eax
80102f28:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f2d:	b8 00 00 00 00       	mov    $0x0,%eax
80102f32:	e9 a2 00 00 00       	jmp    80102fd9 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102f37:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f3c:	83 e0 40             	and    $0x40,%eax
80102f3f:	85 c0                	test   %eax,%eax
80102f41:	74 14                	je     80102f57 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f43:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f4a:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f4f:	83 e0 bf             	and    $0xffffffbf,%eax
80102f52:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102f57:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f5a:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f5f:	0f b6 00             	movzbl (%eax),%eax
80102f62:	0f b6 d0             	movzbl %al,%edx
80102f65:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f6a:	09 d0                	or     %edx,%eax
80102f6c:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102f71:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f74:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102f79:	0f b6 00             	movzbl (%eax),%eax
80102f7c:	0f b6 d0             	movzbl %al,%edx
80102f7f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f84:	31 d0                	xor    %edx,%eax
80102f86:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102f8b:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f90:	83 e0 03             	and    $0x3,%eax
80102f93:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102f9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f9d:	01 d0                	add    %edx,%eax
80102f9f:	0f b6 00             	movzbl (%eax),%eax
80102fa2:	0f b6 c0             	movzbl %al,%eax
80102fa5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102fa8:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fad:	83 e0 08             	and    $0x8,%eax
80102fb0:	85 c0                	test   %eax,%eax
80102fb2:	74 22                	je     80102fd6 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102fb4:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102fb8:	76 0c                	jbe    80102fc6 <kbdgetc+0x13e>
80102fba:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102fbe:	77 06                	ja     80102fc6 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102fc0:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102fc4:	eb 10                	jmp    80102fd6 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102fc6:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102fca:	76 0a                	jbe    80102fd6 <kbdgetc+0x14e>
80102fcc:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102fd0:	77 04                	ja     80102fd6 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102fd2:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102fd6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102fd9:	c9                   	leave  
80102fda:	c3                   	ret    

80102fdb <kbdintr>:

void
kbdintr(void)
{
80102fdb:	f3 0f 1e fb          	endbr32 
80102fdf:	55                   	push   %ebp
80102fe0:	89 e5                	mov    %esp,%ebp
80102fe2:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102fe5:	83 ec 0c             	sub    $0xc,%esp
80102fe8:	68 88 2e 10 80       	push   $0x80102e88
80102fed:	e8 b6 d8 ff ff       	call   801008a8 <consoleintr>
80102ff2:	83 c4 10             	add    $0x10,%esp
}
80102ff5:	90                   	nop
80102ff6:	c9                   	leave  
80102ff7:	c3                   	ret    

80102ff8 <inb>:
{
80102ff8:	55                   	push   %ebp
80102ff9:	89 e5                	mov    %esp,%ebp
80102ffb:	83 ec 14             	sub    $0x14,%esp
80102ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80103001:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103005:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103009:	89 c2                	mov    %eax,%edx
8010300b:	ec                   	in     (%dx),%al
8010300c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010300f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103013:	c9                   	leave  
80103014:	c3                   	ret    

80103015 <outb>:
{
80103015:	55                   	push   %ebp
80103016:	89 e5                	mov    %esp,%ebp
80103018:	83 ec 08             	sub    $0x8,%esp
8010301b:	8b 45 08             	mov    0x8(%ebp),%eax
8010301e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103021:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103025:	89 d0                	mov    %edx,%eax
80103027:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010302a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010302e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103032:	ee                   	out    %al,(%dx)
}
80103033:	90                   	nop
80103034:	c9                   	leave  
80103035:	c3                   	ret    

80103036 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80103036:	f3 0f 1e fb          	endbr32 
8010303a:	55                   	push   %ebp
8010303b:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010303d:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103042:	8b 55 08             	mov    0x8(%ebp),%edx
80103045:	c1 e2 02             	shl    $0x2,%edx
80103048:	01 c2                	add    %eax,%edx
8010304a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010304d:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
8010304f:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103054:	83 c0 20             	add    $0x20,%eax
80103057:	8b 00                	mov    (%eax),%eax
}
80103059:	90                   	nop
8010305a:	5d                   	pop    %ebp
8010305b:	c3                   	ret    

8010305c <lapicinit>:

void
lapicinit(void)
{
8010305c:	f3 0f 1e fb          	endbr32 
80103060:	55                   	push   %ebp
80103061:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80103063:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103068:	85 c0                	test   %eax,%eax
8010306a:	0f 84 0c 01 00 00    	je     8010317c <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103070:	68 3f 01 00 00       	push   $0x13f
80103075:	6a 3c                	push   $0x3c
80103077:	e8 ba ff ff ff       	call   80103036 <lapicw>
8010307c:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
8010307f:	6a 0b                	push   $0xb
80103081:	68 f8 00 00 00       	push   $0xf8
80103086:	e8 ab ff ff ff       	call   80103036 <lapicw>
8010308b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010308e:	68 20 00 02 00       	push   $0x20020
80103093:	68 c8 00 00 00       	push   $0xc8
80103098:	e8 99 ff ff ff       	call   80103036 <lapicw>
8010309d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
801030a0:	68 80 96 98 00       	push   $0x989680
801030a5:	68 e0 00 00 00       	push   $0xe0
801030aa:	e8 87 ff ff ff       	call   80103036 <lapicw>
801030af:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030b2:	68 00 00 01 00       	push   $0x10000
801030b7:	68 d4 00 00 00       	push   $0xd4
801030bc:	e8 75 ff ff ff       	call   80103036 <lapicw>
801030c1:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
801030c4:	68 00 00 01 00       	push   $0x10000
801030c9:	68 d8 00 00 00       	push   $0xd8
801030ce:	e8 63 ff ff ff       	call   80103036 <lapicw>
801030d3:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801030d6:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801030db:	83 c0 30             	add    $0x30,%eax
801030de:	8b 00                	mov    (%eax),%eax
801030e0:	c1 e8 10             	shr    $0x10,%eax
801030e3:	25 fc 00 00 00       	and    $0xfc,%eax
801030e8:	85 c0                	test   %eax,%eax
801030ea:	74 12                	je     801030fe <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
801030ec:	68 00 00 01 00       	push   $0x10000
801030f1:	68 d0 00 00 00       	push   $0xd0
801030f6:	e8 3b ff ff ff       	call   80103036 <lapicw>
801030fb:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801030fe:	6a 33                	push   $0x33
80103100:	68 dc 00 00 00       	push   $0xdc
80103105:	e8 2c ff ff ff       	call   80103036 <lapicw>
8010310a:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010310d:	6a 00                	push   $0x0
8010310f:	68 a0 00 00 00       	push   $0xa0
80103114:	e8 1d ff ff ff       	call   80103036 <lapicw>
80103119:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010311c:	6a 00                	push   $0x0
8010311e:	68 a0 00 00 00       	push   $0xa0
80103123:	e8 0e ff ff ff       	call   80103036 <lapicw>
80103128:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010312b:	6a 00                	push   $0x0
8010312d:	6a 2c                	push   $0x2c
8010312f:	e8 02 ff ff ff       	call   80103036 <lapicw>
80103134:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103137:	6a 00                	push   $0x0
80103139:	68 c4 00 00 00       	push   $0xc4
8010313e:	e8 f3 fe ff ff       	call   80103036 <lapicw>
80103143:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103146:	68 00 85 08 00       	push   $0x88500
8010314b:	68 c0 00 00 00       	push   $0xc0
80103150:	e8 e1 fe ff ff       	call   80103036 <lapicw>
80103155:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103158:	90                   	nop
80103159:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010315e:	05 00 03 00 00       	add    $0x300,%eax
80103163:	8b 00                	mov    (%eax),%eax
80103165:	25 00 10 00 00       	and    $0x1000,%eax
8010316a:	85 c0                	test   %eax,%eax
8010316c:	75 eb                	jne    80103159 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010316e:	6a 00                	push   $0x0
80103170:	6a 20                	push   $0x20
80103172:	e8 bf fe ff ff       	call   80103036 <lapicw>
80103177:	83 c4 08             	add    $0x8,%esp
8010317a:	eb 01                	jmp    8010317d <lapicinit+0x121>
    return;
8010317c:	90                   	nop
}
8010317d:	c9                   	leave  
8010317e:	c3                   	ret    

8010317f <lapicid>:

int
lapicid(void)
{
8010317f:	f3 0f 1e fb          	endbr32 
80103183:	55                   	push   %ebp
80103184:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103186:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010318b:	85 c0                	test   %eax,%eax
8010318d:	75 07                	jne    80103196 <lapicid+0x17>
    return 0;
8010318f:	b8 00 00 00 00       	mov    $0x0,%eax
80103194:	eb 0d                	jmp    801031a3 <lapicid+0x24>
  return lapic[ID] >> 24;
80103196:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010319b:	83 c0 20             	add    $0x20,%eax
8010319e:	8b 00                	mov    (%eax),%eax
801031a0:	c1 e8 18             	shr    $0x18,%eax
}
801031a3:	5d                   	pop    %ebp
801031a4:	c3                   	ret    

801031a5 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801031a5:	f3 0f 1e fb          	endbr32 
801031a9:	55                   	push   %ebp
801031aa:	89 e5                	mov    %esp,%ebp
  if(lapic)
801031ac:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031b1:	85 c0                	test   %eax,%eax
801031b3:	74 0c                	je     801031c1 <lapiceoi+0x1c>
    lapicw(EOI, 0);
801031b5:	6a 00                	push   $0x0
801031b7:	6a 2c                	push   $0x2c
801031b9:	e8 78 fe ff ff       	call   80103036 <lapicw>
801031be:	83 c4 08             	add    $0x8,%esp
}
801031c1:	90                   	nop
801031c2:	c9                   	leave  
801031c3:	c3                   	ret    

801031c4 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801031c4:	f3 0f 1e fb          	endbr32 
801031c8:	55                   	push   %ebp
801031c9:	89 e5                	mov    %esp,%ebp
}
801031cb:	90                   	nop
801031cc:	5d                   	pop    %ebp
801031cd:	c3                   	ret    

801031ce <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801031ce:	f3 0f 1e fb          	endbr32 
801031d2:	55                   	push   %ebp
801031d3:	89 e5                	mov    %esp,%ebp
801031d5:	83 ec 14             	sub    $0x14,%esp
801031d8:	8b 45 08             	mov    0x8(%ebp),%eax
801031db:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801031de:	6a 0f                	push   $0xf
801031e0:	6a 70                	push   $0x70
801031e2:	e8 2e fe ff ff       	call   80103015 <outb>
801031e7:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801031ea:	6a 0a                	push   $0xa
801031ec:	6a 71                	push   $0x71
801031ee:	e8 22 fe ff ff       	call   80103015 <outb>
801031f3:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801031f6:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801031fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103200:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103205:	8b 45 0c             	mov    0xc(%ebp),%eax
80103208:	c1 e8 04             	shr    $0x4,%eax
8010320b:	89 c2                	mov    %eax,%edx
8010320d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103210:	83 c0 02             	add    $0x2,%eax
80103213:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103216:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010321a:	c1 e0 18             	shl    $0x18,%eax
8010321d:	50                   	push   %eax
8010321e:	68 c4 00 00 00       	push   $0xc4
80103223:	e8 0e fe ff ff       	call   80103036 <lapicw>
80103228:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010322b:	68 00 c5 00 00       	push   $0xc500
80103230:	68 c0 00 00 00       	push   $0xc0
80103235:	e8 fc fd ff ff       	call   80103036 <lapicw>
8010323a:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010323d:	68 c8 00 00 00       	push   $0xc8
80103242:	e8 7d ff ff ff       	call   801031c4 <microdelay>
80103247:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010324a:	68 00 85 00 00       	push   $0x8500
8010324f:	68 c0 00 00 00       	push   $0xc0
80103254:	e8 dd fd ff ff       	call   80103036 <lapicw>
80103259:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010325c:	6a 64                	push   $0x64
8010325e:	e8 61 ff ff ff       	call   801031c4 <microdelay>
80103263:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103266:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010326d:	eb 3d                	jmp    801032ac <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
8010326f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103273:	c1 e0 18             	shl    $0x18,%eax
80103276:	50                   	push   %eax
80103277:	68 c4 00 00 00       	push   $0xc4
8010327c:	e8 b5 fd ff ff       	call   80103036 <lapicw>
80103281:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103284:	8b 45 0c             	mov    0xc(%ebp),%eax
80103287:	c1 e8 0c             	shr    $0xc,%eax
8010328a:	80 cc 06             	or     $0x6,%ah
8010328d:	50                   	push   %eax
8010328e:	68 c0 00 00 00       	push   $0xc0
80103293:	e8 9e fd ff ff       	call   80103036 <lapicw>
80103298:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010329b:	68 c8 00 00 00       	push   $0xc8
801032a0:	e8 1f ff ff ff       	call   801031c4 <microdelay>
801032a5:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801032a8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801032ac:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801032b0:	7e bd                	jle    8010326f <lapicstartap+0xa1>
  }
}
801032b2:	90                   	nop
801032b3:	90                   	nop
801032b4:	c9                   	leave  
801032b5:	c3                   	ret    

801032b6 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801032b6:	f3 0f 1e fb          	endbr32 
801032ba:	55                   	push   %ebp
801032bb:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801032bd:	8b 45 08             	mov    0x8(%ebp),%eax
801032c0:	0f b6 c0             	movzbl %al,%eax
801032c3:	50                   	push   %eax
801032c4:	6a 70                	push   $0x70
801032c6:	e8 4a fd ff ff       	call   80103015 <outb>
801032cb:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801032ce:	68 c8 00 00 00       	push   $0xc8
801032d3:	e8 ec fe ff ff       	call   801031c4 <microdelay>
801032d8:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801032db:	6a 71                	push   $0x71
801032dd:	e8 16 fd ff ff       	call   80102ff8 <inb>
801032e2:	83 c4 04             	add    $0x4,%esp
801032e5:	0f b6 c0             	movzbl %al,%eax
}
801032e8:	c9                   	leave  
801032e9:	c3                   	ret    

801032ea <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801032ea:	f3 0f 1e fb          	endbr32 
801032ee:	55                   	push   %ebp
801032ef:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801032f1:	6a 00                	push   $0x0
801032f3:	e8 be ff ff ff       	call   801032b6 <cmos_read>
801032f8:	83 c4 04             	add    $0x4,%esp
801032fb:	8b 55 08             	mov    0x8(%ebp),%edx
801032fe:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103300:	6a 02                	push   $0x2
80103302:	e8 af ff ff ff       	call   801032b6 <cmos_read>
80103307:	83 c4 04             	add    $0x4,%esp
8010330a:	8b 55 08             	mov    0x8(%ebp),%edx
8010330d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103310:	6a 04                	push   $0x4
80103312:	e8 9f ff ff ff       	call   801032b6 <cmos_read>
80103317:	83 c4 04             	add    $0x4,%esp
8010331a:	8b 55 08             	mov    0x8(%ebp),%edx
8010331d:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103320:	6a 07                	push   $0x7
80103322:	e8 8f ff ff ff       	call   801032b6 <cmos_read>
80103327:	83 c4 04             	add    $0x4,%esp
8010332a:	8b 55 08             	mov    0x8(%ebp),%edx
8010332d:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103330:	6a 08                	push   $0x8
80103332:	e8 7f ff ff ff       	call   801032b6 <cmos_read>
80103337:	83 c4 04             	add    $0x4,%esp
8010333a:	8b 55 08             	mov    0x8(%ebp),%edx
8010333d:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103340:	6a 09                	push   $0x9
80103342:	e8 6f ff ff ff       	call   801032b6 <cmos_read>
80103347:	83 c4 04             	add    $0x4,%esp
8010334a:	8b 55 08             	mov    0x8(%ebp),%edx
8010334d:	89 42 14             	mov    %eax,0x14(%edx)
}
80103350:	90                   	nop
80103351:	c9                   	leave  
80103352:	c3                   	ret    

80103353 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80103353:	f3 0f 1e fb          	endbr32 
80103357:	55                   	push   %ebp
80103358:	89 e5                	mov    %esp,%ebp
8010335a:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010335d:	6a 0b                	push   $0xb
8010335f:	e8 52 ff ff ff       	call   801032b6 <cmos_read>
80103364:	83 c4 04             	add    $0x4,%esp
80103367:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010336a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010336d:	83 e0 04             	and    $0x4,%eax
80103370:	85 c0                	test   %eax,%eax
80103372:	0f 94 c0             	sete   %al
80103375:	0f b6 c0             	movzbl %al,%eax
80103378:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010337b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010337e:	50                   	push   %eax
8010337f:	e8 66 ff ff ff       	call   801032ea <fill_rtcdate>
80103384:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103387:	6a 0a                	push   $0xa
80103389:	e8 28 ff ff ff       	call   801032b6 <cmos_read>
8010338e:	83 c4 04             	add    $0x4,%esp
80103391:	25 80 00 00 00       	and    $0x80,%eax
80103396:	85 c0                	test   %eax,%eax
80103398:	75 27                	jne    801033c1 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
8010339a:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010339d:	50                   	push   %eax
8010339e:	e8 47 ff ff ff       	call   801032ea <fill_rtcdate>
801033a3:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801033a6:	83 ec 04             	sub    $0x4,%esp
801033a9:	6a 18                	push   $0x18
801033ab:	8d 45 c0             	lea    -0x40(%ebp),%eax
801033ae:	50                   	push   %eax
801033af:	8d 45 d8             	lea    -0x28(%ebp),%eax
801033b2:	50                   	push   %eax
801033b3:	e8 29 22 00 00       	call   801055e1 <memcmp>
801033b8:	83 c4 10             	add    $0x10,%esp
801033bb:	85 c0                	test   %eax,%eax
801033bd:	74 05                	je     801033c4 <cmostime+0x71>
801033bf:	eb ba                	jmp    8010337b <cmostime+0x28>
        continue;
801033c1:	90                   	nop
    fill_rtcdate(&t1);
801033c2:	eb b7                	jmp    8010337b <cmostime+0x28>
      break;
801033c4:	90                   	nop
  }

  // convert
  if(bcd) {
801033c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801033c9:	0f 84 b4 00 00 00    	je     80103483 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801033cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033d2:	c1 e8 04             	shr    $0x4,%eax
801033d5:	89 c2                	mov    %eax,%edx
801033d7:	89 d0                	mov    %edx,%eax
801033d9:	c1 e0 02             	shl    $0x2,%eax
801033dc:	01 d0                	add    %edx,%eax
801033de:	01 c0                	add    %eax,%eax
801033e0:	89 c2                	mov    %eax,%edx
801033e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033e5:	83 e0 0f             	and    $0xf,%eax
801033e8:	01 d0                	add    %edx,%eax
801033ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801033ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
801033f0:	c1 e8 04             	shr    $0x4,%eax
801033f3:	89 c2                	mov    %eax,%edx
801033f5:	89 d0                	mov    %edx,%eax
801033f7:	c1 e0 02             	shl    $0x2,%eax
801033fa:	01 d0                	add    %edx,%eax
801033fc:	01 c0                	add    %eax,%eax
801033fe:	89 c2                	mov    %eax,%edx
80103400:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103403:	83 e0 0f             	and    $0xf,%eax
80103406:	01 d0                	add    %edx,%eax
80103408:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010340b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010340e:	c1 e8 04             	shr    $0x4,%eax
80103411:	89 c2                	mov    %eax,%edx
80103413:	89 d0                	mov    %edx,%eax
80103415:	c1 e0 02             	shl    $0x2,%eax
80103418:	01 d0                	add    %edx,%eax
8010341a:	01 c0                	add    %eax,%eax
8010341c:	89 c2                	mov    %eax,%edx
8010341e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103421:	83 e0 0f             	and    $0xf,%eax
80103424:	01 d0                	add    %edx,%eax
80103426:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103429:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010342c:	c1 e8 04             	shr    $0x4,%eax
8010342f:	89 c2                	mov    %eax,%edx
80103431:	89 d0                	mov    %edx,%eax
80103433:	c1 e0 02             	shl    $0x2,%eax
80103436:	01 d0                	add    %edx,%eax
80103438:	01 c0                	add    %eax,%eax
8010343a:	89 c2                	mov    %eax,%edx
8010343c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010343f:	83 e0 0f             	and    $0xf,%eax
80103442:	01 d0                	add    %edx,%eax
80103444:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103447:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010344a:	c1 e8 04             	shr    $0x4,%eax
8010344d:	89 c2                	mov    %eax,%edx
8010344f:	89 d0                	mov    %edx,%eax
80103451:	c1 e0 02             	shl    $0x2,%eax
80103454:	01 d0                	add    %edx,%eax
80103456:	01 c0                	add    %eax,%eax
80103458:	89 c2                	mov    %eax,%edx
8010345a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010345d:	83 e0 0f             	and    $0xf,%eax
80103460:	01 d0                	add    %edx,%eax
80103462:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103465:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103468:	c1 e8 04             	shr    $0x4,%eax
8010346b:	89 c2                	mov    %eax,%edx
8010346d:	89 d0                	mov    %edx,%eax
8010346f:	c1 e0 02             	shl    $0x2,%eax
80103472:	01 d0                	add    %edx,%eax
80103474:	01 c0                	add    %eax,%eax
80103476:	89 c2                	mov    %eax,%edx
80103478:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010347b:	83 e0 0f             	and    $0xf,%eax
8010347e:	01 d0                	add    %edx,%eax
80103480:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103483:	8b 45 08             	mov    0x8(%ebp),%eax
80103486:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103489:	89 10                	mov    %edx,(%eax)
8010348b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010348e:	89 50 04             	mov    %edx,0x4(%eax)
80103491:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103494:	89 50 08             	mov    %edx,0x8(%eax)
80103497:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010349a:	89 50 0c             	mov    %edx,0xc(%eax)
8010349d:	8b 55 e8             	mov    -0x18(%ebp),%edx
801034a0:	89 50 10             	mov    %edx,0x10(%eax)
801034a3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034a6:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801034a9:	8b 45 08             	mov    0x8(%ebp),%eax
801034ac:	8b 40 14             	mov    0x14(%eax),%eax
801034af:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801034b5:	8b 45 08             	mov    0x8(%ebp),%eax
801034b8:	89 50 14             	mov    %edx,0x14(%eax)
}
801034bb:	90                   	nop
801034bc:	c9                   	leave  
801034bd:	c3                   	ret    

801034be <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801034be:	f3 0f 1e fb          	endbr32 
801034c2:	55                   	push   %ebp
801034c3:	89 e5                	mov    %esp,%ebp
801034c5:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801034c8:	83 ec 08             	sub    $0x8,%esp
801034cb:	68 c9 94 10 80       	push   $0x801094c9
801034d0:	68 20 47 11 80       	push   $0x80114720
801034d5:	e8 d7 1d 00 00       	call   801052b1 <initlock>
801034da:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801034dd:	83 ec 08             	sub    $0x8,%esp
801034e0:	8d 45 dc             	lea    -0x24(%ebp),%eax
801034e3:	50                   	push   %eax
801034e4:	ff 75 08             	pushl  0x8(%ebp)
801034e7:	e8 f9 df ff ff       	call   801014e5 <readsb>
801034ec:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801034ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034f2:	a3 54 47 11 80       	mov    %eax,0x80114754
  log.size = sb.nlog;
801034f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034fa:	a3 58 47 11 80       	mov    %eax,0x80114758
  log.dev = dev;
801034ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103502:	a3 64 47 11 80       	mov    %eax,0x80114764
  recover_from_log();
80103507:	e8 bf 01 00 00       	call   801036cb <recover_from_log>
}
8010350c:	90                   	nop
8010350d:	c9                   	leave  
8010350e:	c3                   	ret    

8010350f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010350f:	f3 0f 1e fb          	endbr32 
80103513:	55                   	push   %ebp
80103514:	89 e5                	mov    %esp,%ebp
80103516:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103519:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103520:	e9 95 00 00 00       	jmp    801035ba <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103525:	8b 15 54 47 11 80    	mov    0x80114754,%edx
8010352b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010352e:	01 d0                	add    %edx,%eax
80103530:	83 c0 01             	add    $0x1,%eax
80103533:	89 c2                	mov    %eax,%edx
80103535:	a1 64 47 11 80       	mov    0x80114764,%eax
8010353a:	83 ec 08             	sub    $0x8,%esp
8010353d:	52                   	push   %edx
8010353e:	50                   	push   %eax
8010353f:	e8 93 cc ff ff       	call   801001d7 <bread>
80103544:	83 c4 10             	add    $0x10,%esp
80103547:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010354a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010354d:	83 c0 10             	add    $0x10,%eax
80103550:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
80103557:	89 c2                	mov    %eax,%edx
80103559:	a1 64 47 11 80       	mov    0x80114764,%eax
8010355e:	83 ec 08             	sub    $0x8,%esp
80103561:	52                   	push   %edx
80103562:	50                   	push   %eax
80103563:	e8 6f cc ff ff       	call   801001d7 <bread>
80103568:	83 c4 10             	add    $0x10,%esp
8010356b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010356e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103571:	8d 50 5c             	lea    0x5c(%eax),%edx
80103574:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103577:	83 c0 5c             	add    $0x5c,%eax
8010357a:	83 ec 04             	sub    $0x4,%esp
8010357d:	68 00 02 00 00       	push   $0x200
80103582:	52                   	push   %edx
80103583:	50                   	push   %eax
80103584:	e8 b4 20 00 00       	call   8010563d <memmove>
80103589:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010358c:	83 ec 0c             	sub    $0xc,%esp
8010358f:	ff 75 ec             	pushl  -0x14(%ebp)
80103592:	e8 7d cc ff ff       	call   80100214 <bwrite>
80103597:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010359a:	83 ec 0c             	sub    $0xc,%esp
8010359d:	ff 75 f0             	pushl  -0x10(%ebp)
801035a0:	e8 bc cc ff ff       	call   80100261 <brelse>
801035a5:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801035a8:	83 ec 0c             	sub    $0xc,%esp
801035ab:	ff 75 ec             	pushl  -0x14(%ebp)
801035ae:	e8 ae cc ff ff       	call   80100261 <brelse>
801035b3:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801035b6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035ba:	a1 68 47 11 80       	mov    0x80114768,%eax
801035bf:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035c2:	0f 8c 5d ff ff ff    	jl     80103525 <install_trans+0x16>
  }
}
801035c8:	90                   	nop
801035c9:	90                   	nop
801035ca:	c9                   	leave  
801035cb:	c3                   	ret    

801035cc <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801035cc:	f3 0f 1e fb          	endbr32 
801035d0:	55                   	push   %ebp
801035d1:	89 e5                	mov    %esp,%ebp
801035d3:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801035d6:	a1 54 47 11 80       	mov    0x80114754,%eax
801035db:	89 c2                	mov    %eax,%edx
801035dd:	a1 64 47 11 80       	mov    0x80114764,%eax
801035e2:	83 ec 08             	sub    $0x8,%esp
801035e5:	52                   	push   %edx
801035e6:	50                   	push   %eax
801035e7:	e8 eb cb ff ff       	call   801001d7 <bread>
801035ec:	83 c4 10             	add    $0x10,%esp
801035ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801035f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035f5:	83 c0 5c             	add    $0x5c,%eax
801035f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801035fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035fe:	8b 00                	mov    (%eax),%eax
80103600:	a3 68 47 11 80       	mov    %eax,0x80114768
  for (i = 0; i < log.lh.n; i++) {
80103605:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010360c:	eb 1b                	jmp    80103629 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
8010360e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103611:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103614:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103618:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010361b:	83 c2 10             	add    $0x10,%edx
8010361e:	89 04 95 2c 47 11 80 	mov    %eax,-0x7feeb8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103625:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103629:	a1 68 47 11 80       	mov    0x80114768,%eax
8010362e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103631:	7c db                	jl     8010360e <read_head+0x42>
  }
  brelse(buf);
80103633:	83 ec 0c             	sub    $0xc,%esp
80103636:	ff 75 f0             	pushl  -0x10(%ebp)
80103639:	e8 23 cc ff ff       	call   80100261 <brelse>
8010363e:	83 c4 10             	add    $0x10,%esp
}
80103641:	90                   	nop
80103642:	c9                   	leave  
80103643:	c3                   	ret    

80103644 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103644:	f3 0f 1e fb          	endbr32 
80103648:	55                   	push   %ebp
80103649:	89 e5                	mov    %esp,%ebp
8010364b:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010364e:	a1 54 47 11 80       	mov    0x80114754,%eax
80103653:	89 c2                	mov    %eax,%edx
80103655:	a1 64 47 11 80       	mov    0x80114764,%eax
8010365a:	83 ec 08             	sub    $0x8,%esp
8010365d:	52                   	push   %edx
8010365e:	50                   	push   %eax
8010365f:	e8 73 cb ff ff       	call   801001d7 <bread>
80103664:	83 c4 10             	add    $0x10,%esp
80103667:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010366a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010366d:	83 c0 5c             	add    $0x5c,%eax
80103670:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103673:	8b 15 68 47 11 80    	mov    0x80114768,%edx
80103679:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010367c:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010367e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103685:	eb 1b                	jmp    801036a2 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010368a:	83 c0 10             	add    $0x10,%eax
8010368d:	8b 0c 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%ecx
80103694:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103697:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010369a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010369e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036a2:	a1 68 47 11 80       	mov    0x80114768,%eax
801036a7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801036aa:	7c db                	jl     80103687 <write_head+0x43>
  }
  bwrite(buf);
801036ac:	83 ec 0c             	sub    $0xc,%esp
801036af:	ff 75 f0             	pushl  -0x10(%ebp)
801036b2:	e8 5d cb ff ff       	call   80100214 <bwrite>
801036b7:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801036ba:	83 ec 0c             	sub    $0xc,%esp
801036bd:	ff 75 f0             	pushl  -0x10(%ebp)
801036c0:	e8 9c cb ff ff       	call   80100261 <brelse>
801036c5:	83 c4 10             	add    $0x10,%esp
}
801036c8:	90                   	nop
801036c9:	c9                   	leave  
801036ca:	c3                   	ret    

801036cb <recover_from_log>:

static void
recover_from_log(void)
{
801036cb:	f3 0f 1e fb          	endbr32 
801036cf:	55                   	push   %ebp
801036d0:	89 e5                	mov    %esp,%ebp
801036d2:	83 ec 08             	sub    $0x8,%esp
  read_head();
801036d5:	e8 f2 fe ff ff       	call   801035cc <read_head>
  install_trans(); // if committed, copy from log to disk
801036da:	e8 30 fe ff ff       	call   8010350f <install_trans>
  log.lh.n = 0;
801036df:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
801036e6:	00 00 00 
  write_head(); // clear the log
801036e9:	e8 56 ff ff ff       	call   80103644 <write_head>
}
801036ee:	90                   	nop
801036ef:	c9                   	leave  
801036f0:	c3                   	ret    

801036f1 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801036f1:	f3 0f 1e fb          	endbr32 
801036f5:	55                   	push   %ebp
801036f6:	89 e5                	mov    %esp,%ebp
801036f8:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801036fb:	83 ec 0c             	sub    $0xc,%esp
801036fe:	68 20 47 11 80       	push   $0x80114720
80103703:	e8 cf 1b 00 00       	call   801052d7 <acquire>
80103708:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010370b:	a1 60 47 11 80       	mov    0x80114760,%eax
80103710:	85 c0                	test   %eax,%eax
80103712:	74 17                	je     8010372b <begin_op+0x3a>
      sleep(&log, &log.lock);
80103714:	83 ec 08             	sub    $0x8,%esp
80103717:	68 20 47 11 80       	push   $0x80114720
8010371c:	68 20 47 11 80       	push   $0x80114720
80103721:	e8 3f 17 00 00       	call   80104e65 <sleep>
80103726:	83 c4 10             	add    $0x10,%esp
80103729:	eb e0                	jmp    8010370b <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010372b:	8b 0d 68 47 11 80    	mov    0x80114768,%ecx
80103731:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103736:	8d 50 01             	lea    0x1(%eax),%edx
80103739:	89 d0                	mov    %edx,%eax
8010373b:	c1 e0 02             	shl    $0x2,%eax
8010373e:	01 d0                	add    %edx,%eax
80103740:	01 c0                	add    %eax,%eax
80103742:	01 c8                	add    %ecx,%eax
80103744:	83 f8 1e             	cmp    $0x1e,%eax
80103747:	7e 17                	jle    80103760 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103749:	83 ec 08             	sub    $0x8,%esp
8010374c:	68 20 47 11 80       	push   $0x80114720
80103751:	68 20 47 11 80       	push   $0x80114720
80103756:	e8 0a 17 00 00       	call   80104e65 <sleep>
8010375b:	83 c4 10             	add    $0x10,%esp
8010375e:	eb ab                	jmp    8010370b <begin_op+0x1a>
    } else {
      log.outstanding += 1;
80103760:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103765:	83 c0 01             	add    $0x1,%eax
80103768:	a3 5c 47 11 80       	mov    %eax,0x8011475c
      release(&log.lock);
8010376d:	83 ec 0c             	sub    $0xc,%esp
80103770:	68 20 47 11 80       	push   $0x80114720
80103775:	e8 cf 1b 00 00       	call   80105349 <release>
8010377a:	83 c4 10             	add    $0x10,%esp
      break;
8010377d:	90                   	nop
    }
  }
}
8010377e:	90                   	nop
8010377f:	c9                   	leave  
80103780:	c3                   	ret    

80103781 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103781:	f3 0f 1e fb          	endbr32 
80103785:	55                   	push   %ebp
80103786:	89 e5                	mov    %esp,%ebp
80103788:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010378b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103792:	83 ec 0c             	sub    $0xc,%esp
80103795:	68 20 47 11 80       	push   $0x80114720
8010379a:	e8 38 1b 00 00       	call   801052d7 <acquire>
8010379f:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801037a2:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801037a7:	83 e8 01             	sub    $0x1,%eax
801037aa:	a3 5c 47 11 80       	mov    %eax,0x8011475c
  if(log.committing)
801037af:	a1 60 47 11 80       	mov    0x80114760,%eax
801037b4:	85 c0                	test   %eax,%eax
801037b6:	74 0d                	je     801037c5 <end_op+0x44>
    panic("log.committing");
801037b8:	83 ec 0c             	sub    $0xc,%esp
801037bb:	68 cd 94 10 80       	push   $0x801094cd
801037c0:	e8 43 ce ff ff       	call   80100608 <panic>
  if(log.outstanding == 0){
801037c5:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801037ca:	85 c0                	test   %eax,%eax
801037cc:	75 13                	jne    801037e1 <end_op+0x60>
    do_commit = 1;
801037ce:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801037d5:	c7 05 60 47 11 80 01 	movl   $0x1,0x80114760
801037dc:	00 00 00 
801037df:	eb 10                	jmp    801037f1 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801037e1:	83 ec 0c             	sub    $0xc,%esp
801037e4:	68 20 47 11 80       	push   $0x80114720
801037e9:	e8 69 17 00 00       	call   80104f57 <wakeup>
801037ee:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801037f1:	83 ec 0c             	sub    $0xc,%esp
801037f4:	68 20 47 11 80       	push   $0x80114720
801037f9:	e8 4b 1b 00 00       	call   80105349 <release>
801037fe:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103801:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103805:	74 3f                	je     80103846 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103807:	e8 fa 00 00 00       	call   80103906 <commit>
    acquire(&log.lock);
8010380c:	83 ec 0c             	sub    $0xc,%esp
8010380f:	68 20 47 11 80       	push   $0x80114720
80103814:	e8 be 1a 00 00       	call   801052d7 <acquire>
80103819:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010381c:	c7 05 60 47 11 80 00 	movl   $0x0,0x80114760
80103823:	00 00 00 
    wakeup(&log);
80103826:	83 ec 0c             	sub    $0xc,%esp
80103829:	68 20 47 11 80       	push   $0x80114720
8010382e:	e8 24 17 00 00       	call   80104f57 <wakeup>
80103833:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103836:	83 ec 0c             	sub    $0xc,%esp
80103839:	68 20 47 11 80       	push   $0x80114720
8010383e:	e8 06 1b 00 00       	call   80105349 <release>
80103843:	83 c4 10             	add    $0x10,%esp
  }
}
80103846:	90                   	nop
80103847:	c9                   	leave  
80103848:	c3                   	ret    

80103849 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103849:	f3 0f 1e fb          	endbr32 
8010384d:	55                   	push   %ebp
8010384e:	89 e5                	mov    %esp,%ebp
80103850:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103853:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010385a:	e9 95 00 00 00       	jmp    801038f4 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010385f:	8b 15 54 47 11 80    	mov    0x80114754,%edx
80103865:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103868:	01 d0                	add    %edx,%eax
8010386a:	83 c0 01             	add    $0x1,%eax
8010386d:	89 c2                	mov    %eax,%edx
8010386f:	a1 64 47 11 80       	mov    0x80114764,%eax
80103874:	83 ec 08             	sub    $0x8,%esp
80103877:	52                   	push   %edx
80103878:	50                   	push   %eax
80103879:	e8 59 c9 ff ff       	call   801001d7 <bread>
8010387e:	83 c4 10             	add    $0x10,%esp
80103881:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103887:	83 c0 10             	add    $0x10,%eax
8010388a:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
80103891:	89 c2                	mov    %eax,%edx
80103893:	a1 64 47 11 80       	mov    0x80114764,%eax
80103898:	83 ec 08             	sub    $0x8,%esp
8010389b:	52                   	push   %edx
8010389c:	50                   	push   %eax
8010389d:	e8 35 c9 ff ff       	call   801001d7 <bread>
801038a2:	83 c4 10             	add    $0x10,%esp
801038a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801038a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038ab:	8d 50 5c             	lea    0x5c(%eax),%edx
801038ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038b1:	83 c0 5c             	add    $0x5c,%eax
801038b4:	83 ec 04             	sub    $0x4,%esp
801038b7:	68 00 02 00 00       	push   $0x200
801038bc:	52                   	push   %edx
801038bd:	50                   	push   %eax
801038be:	e8 7a 1d 00 00       	call   8010563d <memmove>
801038c3:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801038c6:	83 ec 0c             	sub    $0xc,%esp
801038c9:	ff 75 f0             	pushl  -0x10(%ebp)
801038cc:	e8 43 c9 ff ff       	call   80100214 <bwrite>
801038d1:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801038d4:	83 ec 0c             	sub    $0xc,%esp
801038d7:	ff 75 ec             	pushl  -0x14(%ebp)
801038da:	e8 82 c9 ff ff       	call   80100261 <brelse>
801038df:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801038e2:	83 ec 0c             	sub    $0xc,%esp
801038e5:	ff 75 f0             	pushl  -0x10(%ebp)
801038e8:	e8 74 c9 ff ff       	call   80100261 <brelse>
801038ed:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801038f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801038f4:	a1 68 47 11 80       	mov    0x80114768,%eax
801038f9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801038fc:	0f 8c 5d ff ff ff    	jl     8010385f <write_log+0x16>
  }
}
80103902:	90                   	nop
80103903:	90                   	nop
80103904:	c9                   	leave  
80103905:	c3                   	ret    

80103906 <commit>:

static void
commit()
{
80103906:	f3 0f 1e fb          	endbr32 
8010390a:	55                   	push   %ebp
8010390b:	89 e5                	mov    %esp,%ebp
8010390d:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103910:	a1 68 47 11 80       	mov    0x80114768,%eax
80103915:	85 c0                	test   %eax,%eax
80103917:	7e 1e                	jle    80103937 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103919:	e8 2b ff ff ff       	call   80103849 <write_log>
    write_head();    // Write header to disk -- the real commit
8010391e:	e8 21 fd ff ff       	call   80103644 <write_head>
    install_trans(); // Now install writes to home locations
80103923:	e8 e7 fb ff ff       	call   8010350f <install_trans>
    log.lh.n = 0;
80103928:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
8010392f:	00 00 00 
    write_head();    // Erase the transaction from the log
80103932:	e8 0d fd ff ff       	call   80103644 <write_head>
  }
}
80103937:	90                   	nop
80103938:	c9                   	leave  
80103939:	c3                   	ret    

8010393a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010393a:	f3 0f 1e fb          	endbr32 
8010393e:	55                   	push   %ebp
8010393f:	89 e5                	mov    %esp,%ebp
80103941:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103944:	a1 68 47 11 80       	mov    0x80114768,%eax
80103949:	83 f8 1d             	cmp    $0x1d,%eax
8010394c:	7f 12                	jg     80103960 <log_write+0x26>
8010394e:	a1 68 47 11 80       	mov    0x80114768,%eax
80103953:	8b 15 58 47 11 80    	mov    0x80114758,%edx
80103959:	83 ea 01             	sub    $0x1,%edx
8010395c:	39 d0                	cmp    %edx,%eax
8010395e:	7c 0d                	jl     8010396d <log_write+0x33>
    panic("too big a transaction");
80103960:	83 ec 0c             	sub    $0xc,%esp
80103963:	68 dc 94 10 80       	push   $0x801094dc
80103968:	e8 9b cc ff ff       	call   80100608 <panic>
  if (log.outstanding < 1)
8010396d:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103972:	85 c0                	test   %eax,%eax
80103974:	7f 0d                	jg     80103983 <log_write+0x49>
    panic("log_write outside of trans");
80103976:	83 ec 0c             	sub    $0xc,%esp
80103979:	68 f2 94 10 80       	push   $0x801094f2
8010397e:	e8 85 cc ff ff       	call   80100608 <panic>

  acquire(&log.lock);
80103983:	83 ec 0c             	sub    $0xc,%esp
80103986:	68 20 47 11 80       	push   $0x80114720
8010398b:	e8 47 19 00 00       	call   801052d7 <acquire>
80103990:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103993:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010399a:	eb 1d                	jmp    801039b9 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010399c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010399f:	83 c0 10             	add    $0x10,%eax
801039a2:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
801039a9:	89 c2                	mov    %eax,%edx
801039ab:	8b 45 08             	mov    0x8(%ebp),%eax
801039ae:	8b 40 08             	mov    0x8(%eax),%eax
801039b1:	39 c2                	cmp    %eax,%edx
801039b3:	74 10                	je     801039c5 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
801039b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039b9:	a1 68 47 11 80       	mov    0x80114768,%eax
801039be:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039c1:	7c d9                	jl     8010399c <log_write+0x62>
801039c3:	eb 01                	jmp    801039c6 <log_write+0x8c>
      break;
801039c5:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801039c6:	8b 45 08             	mov    0x8(%ebp),%eax
801039c9:	8b 40 08             	mov    0x8(%eax),%eax
801039cc:	89 c2                	mov    %eax,%edx
801039ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d1:	83 c0 10             	add    $0x10,%eax
801039d4:	89 14 85 2c 47 11 80 	mov    %edx,-0x7feeb8d4(,%eax,4)
  if (i == log.lh.n)
801039db:	a1 68 47 11 80       	mov    0x80114768,%eax
801039e0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039e3:	75 0d                	jne    801039f2 <log_write+0xb8>
    log.lh.n++;
801039e5:	a1 68 47 11 80       	mov    0x80114768,%eax
801039ea:	83 c0 01             	add    $0x1,%eax
801039ed:	a3 68 47 11 80       	mov    %eax,0x80114768
  b->flags |= B_DIRTY; // prevent eviction
801039f2:	8b 45 08             	mov    0x8(%ebp),%eax
801039f5:	8b 00                	mov    (%eax),%eax
801039f7:	83 c8 04             	or     $0x4,%eax
801039fa:	89 c2                	mov    %eax,%edx
801039fc:	8b 45 08             	mov    0x8(%ebp),%eax
801039ff:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103a01:	83 ec 0c             	sub    $0xc,%esp
80103a04:	68 20 47 11 80       	push   $0x80114720
80103a09:	e8 3b 19 00 00       	call   80105349 <release>
80103a0e:	83 c4 10             	add    $0x10,%esp
}
80103a11:	90                   	nop
80103a12:	c9                   	leave  
80103a13:	c3                   	ret    

80103a14 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103a14:	55                   	push   %ebp
80103a15:	89 e5                	mov    %esp,%ebp
80103a17:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103a1a:	8b 55 08             	mov    0x8(%ebp),%edx
80103a1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a20:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103a23:	f0 87 02             	lock xchg %eax,(%edx)
80103a26:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103a29:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103a2c:	c9                   	leave  
80103a2d:	c3                   	ret    

80103a2e <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103a2e:	f3 0f 1e fb          	endbr32 
80103a32:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103a36:	83 e4 f0             	and    $0xfffffff0,%esp
80103a39:	ff 71 fc             	pushl  -0x4(%ecx)
80103a3c:	55                   	push   %ebp
80103a3d:	89 e5                	mov    %esp,%ebp
80103a3f:	51                   	push   %ecx
80103a40:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103a43:	83 ec 08             	sub    $0x8,%esp
80103a46:	68 00 00 40 80       	push   $0x80400000
80103a4b:	68 48 89 11 80       	push   $0x80118948
80103a50:	e8 78 f2 ff ff       	call   80102ccd <kinit1>
80103a55:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103a58:	e8 d2 4a 00 00       	call   8010852f <kvmalloc>
  mpinit();        // detect other processors
80103a5d:	e8 d9 03 00 00       	call   80103e3b <mpinit>
  lapicinit();     // interrupt controller
80103a62:	e8 f5 f5 ff ff       	call   8010305c <lapicinit>
  seginit();       // segment descriptors
80103a67:	e8 ea 42 00 00       	call   80107d56 <seginit>
  picinit();       // disable pic
80103a6c:	e8 35 05 00 00       	call   80103fa6 <picinit>
  ioapicinit();    // another interrupt controller
80103a71:	e8 6a f1 ff ff       	call   80102be0 <ioapicinit>
  consoleinit();   // console hardware
80103a76:	e8 66 d1 ff ff       	call   80100be1 <consoleinit>
  uartinit();      // serial port
80103a7b:	e8 0e 35 00 00       	call   80106f8e <uartinit>
  pinit();         // process table
80103a80:	e8 6e 09 00 00       	call   801043f3 <pinit>
  tvinit();        // trap vectors
80103a85:	e8 b6 30 00 00       	call   80106b40 <tvinit>
  binit();         // buffer cache
80103a8a:	e8 a5 c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103a8f:	e8 26 d6 ff ff       	call   801010ba <fileinit>
  ideinit();       // disk 
80103a94:	e8 06 ed ff ff       	call   8010279f <ideinit>
  startothers();   // start other processors
80103a99:	e8 88 00 00 00       	call   80103b26 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103a9e:	83 ec 08             	sub    $0x8,%esp
80103aa1:	68 00 00 00 8e       	push   $0x8e000000
80103aa6:	68 00 00 40 80       	push   $0x80400000
80103aab:	e8 5a f2 ff ff       	call   80102d0a <kinit2>
80103ab0:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103ab3:	e8 5e 0b 00 00       	call   80104616 <userinit>
  mpmain();        // finish this processor's setup
80103ab8:	e8 1e 00 00 00       	call   80103adb <mpmain>

80103abd <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103abd:	f3 0f 1e fb          	endbr32 
80103ac1:	55                   	push   %ebp
80103ac2:	89 e5                	mov    %esp,%ebp
80103ac4:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103ac7:	e8 7f 4a 00 00       	call   8010854b <switchkvm>
  seginit();
80103acc:	e8 85 42 00 00       	call   80107d56 <seginit>
  lapicinit();
80103ad1:	e8 86 f5 ff ff       	call   8010305c <lapicinit>
  mpmain();
80103ad6:	e8 00 00 00 00       	call   80103adb <mpmain>

80103adb <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103adb:	f3 0f 1e fb          	endbr32 
80103adf:	55                   	push   %ebp
80103ae0:	89 e5                	mov    %esp,%ebp
80103ae2:	53                   	push   %ebx
80103ae3:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103ae6:	e8 2a 09 00 00       	call   80104415 <cpuid>
80103aeb:	89 c3                	mov    %eax,%ebx
80103aed:	e8 23 09 00 00       	call   80104415 <cpuid>
80103af2:	83 ec 04             	sub    $0x4,%esp
80103af5:	53                   	push   %ebx
80103af6:	50                   	push   %eax
80103af7:	68 0d 95 10 80       	push   $0x8010950d
80103afc:	e8 17 c9 ff ff       	call   80100418 <cprintf>
80103b01:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103b04:	e8 b1 31 00 00       	call   80106cba <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103b09:	e8 26 09 00 00       	call   80104434 <mycpu>
80103b0e:	05 a0 00 00 00       	add    $0xa0,%eax
80103b13:	83 ec 08             	sub    $0x8,%esp
80103b16:	6a 01                	push   $0x1
80103b18:	50                   	push   %eax
80103b19:	e8 f6 fe ff ff       	call   80103a14 <xchg>
80103b1e:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103b21:	e8 3b 11 00 00       	call   80104c61 <scheduler>

80103b26 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103b26:	f3 0f 1e fb          	endbr32 
80103b2a:	55                   	push   %ebp
80103b2b:	89 e5                	mov    %esp,%ebp
80103b2d:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103b30:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103b37:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103b3c:	83 ec 04             	sub    $0x4,%esp
80103b3f:	50                   	push   %eax
80103b40:	68 0c c5 10 80       	push   $0x8010c50c
80103b45:	ff 75 f0             	pushl  -0x10(%ebp)
80103b48:	e8 f0 1a 00 00       	call   8010563d <memmove>
80103b4d:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103b50:	c7 45 f4 20 48 11 80 	movl   $0x80114820,-0xc(%ebp)
80103b57:	eb 79                	jmp    80103bd2 <startothers+0xac>
    if(c == mycpu())  // We've started already.
80103b59:	e8 d6 08 00 00       	call   80104434 <mycpu>
80103b5e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b61:	74 67                	je     80103bca <startothers+0xa4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103b63:	e8 aa f2 ff ff       	call   80102e12 <kalloc>
80103b68:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b6e:	83 e8 04             	sub    $0x4,%eax
80103b71:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b74:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103b7a:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b7f:	83 e8 08             	sub    $0x8,%eax
80103b82:	c7 00 bd 3a 10 80    	movl   $0x80103abd,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103b88:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103b8d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b96:	83 e8 0c             	sub    $0xc,%eax
80103b99:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b9e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba7:	0f b6 00             	movzbl (%eax),%eax
80103baa:	0f b6 c0             	movzbl %al,%eax
80103bad:	83 ec 08             	sub    $0x8,%esp
80103bb0:	52                   	push   %edx
80103bb1:	50                   	push   %eax
80103bb2:	e8 17 f6 ff ff       	call   801031ce <lapicstartap>
80103bb7:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103bba:	90                   	nop
80103bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbe:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103bc4:	85 c0                	test   %eax,%eax
80103bc6:	74 f3                	je     80103bbb <startothers+0x95>
80103bc8:	eb 01                	jmp    80103bcb <startothers+0xa5>
      continue;
80103bca:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103bcb:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103bd2:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103bd7:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103bdd:	05 20 48 11 80       	add    $0x80114820,%eax
80103be2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103be5:	0f 82 6e ff ff ff    	jb     80103b59 <startothers+0x33>
      ;
  }
}
80103beb:	90                   	nop
80103bec:	90                   	nop
80103bed:	c9                   	leave  
80103bee:	c3                   	ret    

80103bef <inb>:
{
80103bef:	55                   	push   %ebp
80103bf0:	89 e5                	mov    %esp,%ebp
80103bf2:	83 ec 14             	sub    $0x14,%esp
80103bf5:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103bfc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103c00:	89 c2                	mov    %eax,%edx
80103c02:	ec                   	in     (%dx),%al
80103c03:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103c06:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103c0a:	c9                   	leave  
80103c0b:	c3                   	ret    

80103c0c <outb>:
{
80103c0c:	55                   	push   %ebp
80103c0d:	89 e5                	mov    %esp,%ebp
80103c0f:	83 ec 08             	sub    $0x8,%esp
80103c12:	8b 45 08             	mov    0x8(%ebp),%eax
80103c15:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c18:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103c1c:	89 d0                	mov    %edx,%eax
80103c1e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c21:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103c25:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103c29:	ee                   	out    %al,(%dx)
}
80103c2a:	90                   	nop
80103c2b:	c9                   	leave  
80103c2c:	c3                   	ret    

80103c2d <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103c2d:	f3 0f 1e fb          	endbr32 
80103c31:	55                   	push   %ebp
80103c32:	89 e5                	mov    %esp,%ebp
80103c34:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103c37:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c3e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103c45:	eb 15                	jmp    80103c5c <sum+0x2f>
    sum += addr[i];
80103c47:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c4d:	01 d0                	add    %edx,%eax
80103c4f:	0f b6 00             	movzbl (%eax),%eax
80103c52:	0f b6 c0             	movzbl %al,%eax
80103c55:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c58:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103c5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103c5f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103c62:	7c e3                	jl     80103c47 <sum+0x1a>
  return sum;
80103c64:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103c67:	c9                   	leave  
80103c68:	c3                   	ret    

80103c69 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103c69:	f3 0f 1e fb          	endbr32 
80103c6d:	55                   	push   %ebp
80103c6e:	89 e5                	mov    %esp,%ebp
80103c70:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103c73:	8b 45 08             	mov    0x8(%ebp),%eax
80103c76:	05 00 00 00 80       	add    $0x80000000,%eax
80103c7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103c7e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c84:	01 d0                	add    %edx,%eax
80103c86:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c8f:	eb 36                	jmp    80103cc7 <mpsearch1+0x5e>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103c91:	83 ec 04             	sub    $0x4,%esp
80103c94:	6a 04                	push   $0x4
80103c96:	68 24 95 10 80       	push   $0x80109524
80103c9b:	ff 75 f4             	pushl  -0xc(%ebp)
80103c9e:	e8 3e 19 00 00       	call   801055e1 <memcmp>
80103ca3:	83 c4 10             	add    $0x10,%esp
80103ca6:	85 c0                	test   %eax,%eax
80103ca8:	75 19                	jne    80103cc3 <mpsearch1+0x5a>
80103caa:	83 ec 08             	sub    $0x8,%esp
80103cad:	6a 10                	push   $0x10
80103caf:	ff 75 f4             	pushl  -0xc(%ebp)
80103cb2:	e8 76 ff ff ff       	call   80103c2d <sum>
80103cb7:	83 c4 10             	add    $0x10,%esp
80103cba:	84 c0                	test   %al,%al
80103cbc:	75 05                	jne    80103cc3 <mpsearch1+0x5a>
      return (struct mp*)p;
80103cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc1:	eb 11                	jmp    80103cd4 <mpsearch1+0x6b>
  for(p = addr; p < e; p += sizeof(struct mp))
80103cc3:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cca:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ccd:	72 c2                	jb     80103c91 <mpsearch1+0x28>
  return 0;
80103ccf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103cd4:	c9                   	leave  
80103cd5:	c3                   	ret    

80103cd6 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103cd6:	f3 0f 1e fb          	endbr32 
80103cda:	55                   	push   %ebp
80103cdb:	89 e5                	mov    %esp,%ebp
80103cdd:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103ce0:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cea:	83 c0 0f             	add    $0xf,%eax
80103ced:	0f b6 00             	movzbl (%eax),%eax
80103cf0:	0f b6 c0             	movzbl %al,%eax
80103cf3:	c1 e0 08             	shl    $0x8,%eax
80103cf6:	89 c2                	mov    %eax,%edx
80103cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cfb:	83 c0 0e             	add    $0xe,%eax
80103cfe:	0f b6 00             	movzbl (%eax),%eax
80103d01:	0f b6 c0             	movzbl %al,%eax
80103d04:	09 d0                	or     %edx,%eax
80103d06:	c1 e0 04             	shl    $0x4,%eax
80103d09:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d0c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d10:	74 21                	je     80103d33 <mpsearch+0x5d>
    if((mp = mpsearch1(p, 1024)))
80103d12:	83 ec 08             	sub    $0x8,%esp
80103d15:	68 00 04 00 00       	push   $0x400
80103d1a:	ff 75 f0             	pushl  -0x10(%ebp)
80103d1d:	e8 47 ff ff ff       	call   80103c69 <mpsearch1>
80103d22:	83 c4 10             	add    $0x10,%esp
80103d25:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d28:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d2c:	74 51                	je     80103d7f <mpsearch+0xa9>
      return mp;
80103d2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d31:	eb 61                	jmp    80103d94 <mpsearch+0xbe>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d36:	83 c0 14             	add    $0x14,%eax
80103d39:	0f b6 00             	movzbl (%eax),%eax
80103d3c:	0f b6 c0             	movzbl %al,%eax
80103d3f:	c1 e0 08             	shl    $0x8,%eax
80103d42:	89 c2                	mov    %eax,%edx
80103d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d47:	83 c0 13             	add    $0x13,%eax
80103d4a:	0f b6 00             	movzbl (%eax),%eax
80103d4d:	0f b6 c0             	movzbl %al,%eax
80103d50:	09 d0                	or     %edx,%eax
80103d52:	c1 e0 0a             	shl    $0xa,%eax
80103d55:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d5b:	2d 00 04 00 00       	sub    $0x400,%eax
80103d60:	83 ec 08             	sub    $0x8,%esp
80103d63:	68 00 04 00 00       	push   $0x400
80103d68:	50                   	push   %eax
80103d69:	e8 fb fe ff ff       	call   80103c69 <mpsearch1>
80103d6e:	83 c4 10             	add    $0x10,%esp
80103d71:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d74:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d78:	74 05                	je     80103d7f <mpsearch+0xa9>
      return mp;
80103d7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d7d:	eb 15                	jmp    80103d94 <mpsearch+0xbe>
  }
  return mpsearch1(0xF0000, 0x10000);
80103d7f:	83 ec 08             	sub    $0x8,%esp
80103d82:	68 00 00 01 00       	push   $0x10000
80103d87:	68 00 00 0f 00       	push   $0xf0000
80103d8c:	e8 d8 fe ff ff       	call   80103c69 <mpsearch1>
80103d91:	83 c4 10             	add    $0x10,%esp
}
80103d94:	c9                   	leave  
80103d95:	c3                   	ret    

80103d96 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103d96:	f3 0f 1e fb          	endbr32 
80103d9a:	55                   	push   %ebp
80103d9b:	89 e5                	mov    %esp,%ebp
80103d9d:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103da0:	e8 31 ff ff ff       	call   80103cd6 <mpsearch>
80103da5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103da8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103dac:	74 0a                	je     80103db8 <mpconfig+0x22>
80103dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db1:	8b 40 04             	mov    0x4(%eax),%eax
80103db4:	85 c0                	test   %eax,%eax
80103db6:	75 07                	jne    80103dbf <mpconfig+0x29>
    return 0;
80103db8:	b8 00 00 00 00       	mov    $0x0,%eax
80103dbd:	eb 7a                	jmp    80103e39 <mpconfig+0xa3>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc2:	8b 40 04             	mov    0x4(%eax),%eax
80103dc5:	05 00 00 00 80       	add    $0x80000000,%eax
80103dca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103dcd:	83 ec 04             	sub    $0x4,%esp
80103dd0:	6a 04                	push   $0x4
80103dd2:	68 29 95 10 80       	push   $0x80109529
80103dd7:	ff 75 f0             	pushl  -0x10(%ebp)
80103dda:	e8 02 18 00 00       	call   801055e1 <memcmp>
80103ddf:	83 c4 10             	add    $0x10,%esp
80103de2:	85 c0                	test   %eax,%eax
80103de4:	74 07                	je     80103ded <mpconfig+0x57>
    return 0;
80103de6:	b8 00 00 00 00       	mov    $0x0,%eax
80103deb:	eb 4c                	jmp    80103e39 <mpconfig+0xa3>
  if(conf->version != 1 && conf->version != 4)
80103ded:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103df0:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103df4:	3c 01                	cmp    $0x1,%al
80103df6:	74 12                	je     80103e0a <mpconfig+0x74>
80103df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dfb:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103dff:	3c 04                	cmp    $0x4,%al
80103e01:	74 07                	je     80103e0a <mpconfig+0x74>
    return 0;
80103e03:	b8 00 00 00 00       	mov    $0x0,%eax
80103e08:	eb 2f                	jmp    80103e39 <mpconfig+0xa3>
  if(sum((uchar*)conf, conf->length) != 0)
80103e0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e0d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e11:	0f b7 c0             	movzwl %ax,%eax
80103e14:	83 ec 08             	sub    $0x8,%esp
80103e17:	50                   	push   %eax
80103e18:	ff 75 f0             	pushl  -0x10(%ebp)
80103e1b:	e8 0d fe ff ff       	call   80103c2d <sum>
80103e20:	83 c4 10             	add    $0x10,%esp
80103e23:	84 c0                	test   %al,%al
80103e25:	74 07                	je     80103e2e <mpconfig+0x98>
    return 0;
80103e27:	b8 00 00 00 00       	mov    $0x0,%eax
80103e2c:	eb 0b                	jmp    80103e39 <mpconfig+0xa3>
  *pmp = mp;
80103e2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e31:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e34:	89 10                	mov    %edx,(%eax)
  return conf;
80103e36:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103e39:	c9                   	leave  
80103e3a:	c3                   	ret    

80103e3b <mpinit>:

void
mpinit(void)
{
80103e3b:	f3 0f 1e fb          	endbr32 
80103e3f:	55                   	push   %ebp
80103e40:	89 e5                	mov    %esp,%ebp
80103e42:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103e45:	83 ec 0c             	sub    $0xc,%esp
80103e48:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103e4b:	50                   	push   %eax
80103e4c:	e8 45 ff ff ff       	call   80103d96 <mpconfig>
80103e51:	83 c4 10             	add    $0x10,%esp
80103e54:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e57:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e5b:	75 0d                	jne    80103e6a <mpinit+0x2f>
    panic("Expect to run on an SMP");
80103e5d:	83 ec 0c             	sub    $0xc,%esp
80103e60:	68 2e 95 10 80       	push   $0x8010952e
80103e65:	e8 9e c7 ff ff       	call   80100608 <panic>
  ismp = 1;
80103e6a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103e71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e74:	8b 40 24             	mov    0x24(%eax),%eax
80103e77:	a3 1c 47 11 80       	mov    %eax,0x8011471c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e7f:	83 c0 2c             	add    $0x2c,%eax
80103e82:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e88:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e8c:	0f b7 d0             	movzwl %ax,%edx
80103e8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e92:	01 d0                	add    %edx,%eax
80103e94:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103e97:	e9 8c 00 00 00       	jmp    80103f28 <mpinit+0xed>
    switch(*p){
80103e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e9f:	0f b6 00             	movzbl (%eax),%eax
80103ea2:	0f b6 c0             	movzbl %al,%eax
80103ea5:	83 f8 04             	cmp    $0x4,%eax
80103ea8:	7f 76                	jg     80103f20 <mpinit+0xe5>
80103eaa:	83 f8 03             	cmp    $0x3,%eax
80103ead:	7d 6b                	jge    80103f1a <mpinit+0xdf>
80103eaf:	83 f8 02             	cmp    $0x2,%eax
80103eb2:	74 4e                	je     80103f02 <mpinit+0xc7>
80103eb4:	83 f8 02             	cmp    $0x2,%eax
80103eb7:	7f 67                	jg     80103f20 <mpinit+0xe5>
80103eb9:	85 c0                	test   %eax,%eax
80103ebb:	74 07                	je     80103ec4 <mpinit+0x89>
80103ebd:	83 f8 01             	cmp    $0x1,%eax
80103ec0:	74 58                	je     80103f1a <mpinit+0xdf>
80103ec2:	eb 5c                	jmp    80103f20 <mpinit+0xe5>
    case MPPROC:
      proc = (struct mpproc*)p;
80103ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec7:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103eca:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103ecf:	83 f8 07             	cmp    $0x7,%eax
80103ed2:	7f 28                	jg     80103efc <mpinit+0xc1>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103ed4:	8b 15 a0 4d 11 80    	mov    0x80114da0,%edx
80103eda:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103edd:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ee1:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103ee7:	81 c2 20 48 11 80    	add    $0x80114820,%edx
80103eed:	88 02                	mov    %al,(%edx)
        ncpu++;
80103eef:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103ef4:	83 c0 01             	add    $0x1,%eax
80103ef7:	a3 a0 4d 11 80       	mov    %eax,0x80114da0
      }
      p += sizeof(struct mpproc);
80103efc:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103f00:	eb 26                	jmp    80103f28 <mpinit+0xed>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f05:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103f08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f0b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f0f:	a2 00 48 11 80       	mov    %al,0x80114800
      p += sizeof(struct mpioapic);
80103f14:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f18:	eb 0e                	jmp    80103f28 <mpinit+0xed>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f1a:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f1e:	eb 08                	jmp    80103f28 <mpinit+0xed>
    default:
      ismp = 0;
80103f20:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103f27:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f2b:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103f2e:	0f 82 68 ff ff ff    	jb     80103e9c <mpinit+0x61>
    }
  }
  if(!ismp)
80103f34:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f38:	75 0d                	jne    80103f47 <mpinit+0x10c>
    panic("Didn't find a suitable machine");
80103f3a:	83 ec 0c             	sub    $0xc,%esp
80103f3d:	68 48 95 10 80       	push   $0x80109548
80103f42:	e8 c1 c6 ff ff       	call   80100608 <panic>

  if(mp->imcrp){
80103f47:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f4a:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f4e:	84 c0                	test   %al,%al
80103f50:	74 30                	je     80103f82 <mpinit+0x147>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f52:	83 ec 08             	sub    $0x8,%esp
80103f55:	6a 70                	push   $0x70
80103f57:	6a 22                	push   $0x22
80103f59:	e8 ae fc ff ff       	call   80103c0c <outb>
80103f5e:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103f61:	83 ec 0c             	sub    $0xc,%esp
80103f64:	6a 23                	push   $0x23
80103f66:	e8 84 fc ff ff       	call   80103bef <inb>
80103f6b:	83 c4 10             	add    $0x10,%esp
80103f6e:	83 c8 01             	or     $0x1,%eax
80103f71:	0f b6 c0             	movzbl %al,%eax
80103f74:	83 ec 08             	sub    $0x8,%esp
80103f77:	50                   	push   %eax
80103f78:	6a 23                	push   $0x23
80103f7a:	e8 8d fc ff ff       	call   80103c0c <outb>
80103f7f:	83 c4 10             	add    $0x10,%esp
  }
}
80103f82:	90                   	nop
80103f83:	c9                   	leave  
80103f84:	c3                   	ret    

80103f85 <outb>:
{
80103f85:	55                   	push   %ebp
80103f86:	89 e5                	mov    %esp,%ebp
80103f88:	83 ec 08             	sub    $0x8,%esp
80103f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f91:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103f95:	89 d0                	mov    %edx,%eax
80103f97:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f9a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f9e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103fa2:	ee                   	out    %al,(%dx)
}
80103fa3:	90                   	nop
80103fa4:	c9                   	leave  
80103fa5:	c3                   	ret    

80103fa6 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103fa6:	f3 0f 1e fb          	endbr32 
80103faa:	55                   	push   %ebp
80103fab:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103fad:	68 ff 00 00 00       	push   $0xff
80103fb2:	6a 21                	push   $0x21
80103fb4:	e8 cc ff ff ff       	call   80103f85 <outb>
80103fb9:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103fbc:	68 ff 00 00 00       	push   $0xff
80103fc1:	68 a1 00 00 00       	push   $0xa1
80103fc6:	e8 ba ff ff ff       	call   80103f85 <outb>
80103fcb:	83 c4 08             	add    $0x8,%esp
}
80103fce:	90                   	nop
80103fcf:	c9                   	leave  
80103fd0:	c3                   	ret    

80103fd1 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fd1:	f3 0f 1e fb          	endbr32 
80103fd5:	55                   	push   %ebp
80103fd6:	89 e5                	mov    %esp,%ebp
80103fd8:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103fdb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fe2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103feb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fee:	8b 10                	mov    (%eax),%edx
80103ff0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff3:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103ff5:	e8 e2 d0 ff ff       	call   801010dc <filealloc>
80103ffa:	8b 55 08             	mov    0x8(%ebp),%edx
80103ffd:	89 02                	mov    %eax,(%edx)
80103fff:	8b 45 08             	mov    0x8(%ebp),%eax
80104002:	8b 00                	mov    (%eax),%eax
80104004:	85 c0                	test   %eax,%eax
80104006:	0f 84 c8 00 00 00    	je     801040d4 <pipealloc+0x103>
8010400c:	e8 cb d0 ff ff       	call   801010dc <filealloc>
80104011:	8b 55 0c             	mov    0xc(%ebp),%edx
80104014:	89 02                	mov    %eax,(%edx)
80104016:	8b 45 0c             	mov    0xc(%ebp),%eax
80104019:	8b 00                	mov    (%eax),%eax
8010401b:	85 c0                	test   %eax,%eax
8010401d:	0f 84 b1 00 00 00    	je     801040d4 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104023:	e8 ea ed ff ff       	call   80102e12 <kalloc>
80104028:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010402b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010402f:	0f 84 a2 00 00 00    	je     801040d7 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
80104035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104038:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010403f:	00 00 00 
  p->writeopen = 1;
80104042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104045:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010404c:	00 00 00 
  p->nwrite = 0;
8010404f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104052:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104059:	00 00 00 
  p->nread = 0;
8010405c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405f:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104066:	00 00 00 
  initlock(&p->lock, "pipe");
80104069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406c:	83 ec 08             	sub    $0x8,%esp
8010406f:	68 67 95 10 80       	push   $0x80109567
80104074:	50                   	push   %eax
80104075:	e8 37 12 00 00       	call   801052b1 <initlock>
8010407a:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010407d:	8b 45 08             	mov    0x8(%ebp),%eax
80104080:	8b 00                	mov    (%eax),%eax
80104082:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104088:	8b 45 08             	mov    0x8(%ebp),%eax
8010408b:	8b 00                	mov    (%eax),%eax
8010408d:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104091:	8b 45 08             	mov    0x8(%ebp),%eax
80104094:	8b 00                	mov    (%eax),%eax
80104096:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010409a:	8b 45 08             	mov    0x8(%ebp),%eax
8010409d:	8b 00                	mov    (%eax),%eax
8010409f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040a2:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801040a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a8:	8b 00                	mov    (%eax),%eax
801040aa:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801040b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b3:	8b 00                	mov    (%eax),%eax
801040b5:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801040b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801040bc:	8b 00                	mov    (%eax),%eax
801040be:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c5:	8b 00                	mov    (%eax),%eax
801040c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040ca:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040cd:	b8 00 00 00 00       	mov    $0x0,%eax
801040d2:	eb 51                	jmp    80104125 <pipealloc+0x154>
    goto bad;
801040d4:	90                   	nop
801040d5:	eb 01                	jmp    801040d8 <pipealloc+0x107>
    goto bad;
801040d7:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
801040d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040dc:	74 0e                	je     801040ec <pipealloc+0x11b>
    kfree((char*)p);
801040de:	83 ec 0c             	sub    $0xc,%esp
801040e1:	ff 75 f4             	pushl  -0xc(%ebp)
801040e4:	e8 8b ec ff ff       	call   80102d74 <kfree>
801040e9:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801040ec:	8b 45 08             	mov    0x8(%ebp),%eax
801040ef:	8b 00                	mov    (%eax),%eax
801040f1:	85 c0                	test   %eax,%eax
801040f3:	74 11                	je     80104106 <pipealloc+0x135>
    fileclose(*f0);
801040f5:	8b 45 08             	mov    0x8(%ebp),%eax
801040f8:	8b 00                	mov    (%eax),%eax
801040fa:	83 ec 0c             	sub    $0xc,%esp
801040fd:	50                   	push   %eax
801040fe:	e8 9f d0 ff ff       	call   801011a2 <fileclose>
80104103:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104106:	8b 45 0c             	mov    0xc(%ebp),%eax
80104109:	8b 00                	mov    (%eax),%eax
8010410b:	85 c0                	test   %eax,%eax
8010410d:	74 11                	je     80104120 <pipealloc+0x14f>
    fileclose(*f1);
8010410f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104112:	8b 00                	mov    (%eax),%eax
80104114:	83 ec 0c             	sub    $0xc,%esp
80104117:	50                   	push   %eax
80104118:	e8 85 d0 ff ff       	call   801011a2 <fileclose>
8010411d:	83 c4 10             	add    $0x10,%esp
  return -1;
80104120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104125:	c9                   	leave  
80104126:	c3                   	ret    

80104127 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104127:	f3 0f 1e fb          	endbr32 
8010412b:	55                   	push   %ebp
8010412c:	89 e5                	mov    %esp,%ebp
8010412e:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104131:	8b 45 08             	mov    0x8(%ebp),%eax
80104134:	83 ec 0c             	sub    $0xc,%esp
80104137:	50                   	push   %eax
80104138:	e8 9a 11 00 00       	call   801052d7 <acquire>
8010413d:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104140:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104144:	74 23                	je     80104169 <pipeclose+0x42>
    p->writeopen = 0;
80104146:	8b 45 08             	mov    0x8(%ebp),%eax
80104149:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104150:	00 00 00 
    wakeup(&p->nread);
80104153:	8b 45 08             	mov    0x8(%ebp),%eax
80104156:	05 34 02 00 00       	add    $0x234,%eax
8010415b:	83 ec 0c             	sub    $0xc,%esp
8010415e:	50                   	push   %eax
8010415f:	e8 f3 0d 00 00       	call   80104f57 <wakeup>
80104164:	83 c4 10             	add    $0x10,%esp
80104167:	eb 21                	jmp    8010418a <pipeclose+0x63>
  } else {
    p->readopen = 0;
80104169:	8b 45 08             	mov    0x8(%ebp),%eax
8010416c:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104173:	00 00 00 
    wakeup(&p->nwrite);
80104176:	8b 45 08             	mov    0x8(%ebp),%eax
80104179:	05 38 02 00 00       	add    $0x238,%eax
8010417e:	83 ec 0c             	sub    $0xc,%esp
80104181:	50                   	push   %eax
80104182:	e8 d0 0d 00 00       	call   80104f57 <wakeup>
80104187:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010418a:	8b 45 08             	mov    0x8(%ebp),%eax
8010418d:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104193:	85 c0                	test   %eax,%eax
80104195:	75 2c                	jne    801041c3 <pipeclose+0x9c>
80104197:	8b 45 08             	mov    0x8(%ebp),%eax
8010419a:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801041a0:	85 c0                	test   %eax,%eax
801041a2:	75 1f                	jne    801041c3 <pipeclose+0x9c>
    release(&p->lock);
801041a4:	8b 45 08             	mov    0x8(%ebp),%eax
801041a7:	83 ec 0c             	sub    $0xc,%esp
801041aa:	50                   	push   %eax
801041ab:	e8 99 11 00 00       	call   80105349 <release>
801041b0:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801041b3:	83 ec 0c             	sub    $0xc,%esp
801041b6:	ff 75 08             	pushl  0x8(%ebp)
801041b9:	e8 b6 eb ff ff       	call   80102d74 <kfree>
801041be:	83 c4 10             	add    $0x10,%esp
801041c1:	eb 10                	jmp    801041d3 <pipeclose+0xac>
  } else
    release(&p->lock);
801041c3:	8b 45 08             	mov    0x8(%ebp),%eax
801041c6:	83 ec 0c             	sub    $0xc,%esp
801041c9:	50                   	push   %eax
801041ca:	e8 7a 11 00 00       	call   80105349 <release>
801041cf:	83 c4 10             	add    $0x10,%esp
}
801041d2:	90                   	nop
801041d3:	90                   	nop
801041d4:	c9                   	leave  
801041d5:	c3                   	ret    

801041d6 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801041d6:	f3 0f 1e fb          	endbr32 
801041da:	55                   	push   %ebp
801041db:	89 e5                	mov    %esp,%ebp
801041dd:	53                   	push   %ebx
801041de:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801041e1:	8b 45 08             	mov    0x8(%ebp),%eax
801041e4:	83 ec 0c             	sub    $0xc,%esp
801041e7:	50                   	push   %eax
801041e8:	e8 ea 10 00 00       	call   801052d7 <acquire>
801041ed:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801041f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041f7:	e9 ad 00 00 00       	jmp    801042a9 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
801041fc:	8b 45 08             	mov    0x8(%ebp),%eax
801041ff:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104205:	85 c0                	test   %eax,%eax
80104207:	74 0c                	je     80104215 <pipewrite+0x3f>
80104209:	e8 a2 02 00 00       	call   801044b0 <myproc>
8010420e:	8b 40 28             	mov    0x28(%eax),%eax
80104211:	85 c0                	test   %eax,%eax
80104213:	74 19                	je     8010422e <pipewrite+0x58>
        release(&p->lock);
80104215:	8b 45 08             	mov    0x8(%ebp),%eax
80104218:	83 ec 0c             	sub    $0xc,%esp
8010421b:	50                   	push   %eax
8010421c:	e8 28 11 00 00       	call   80105349 <release>
80104221:	83 c4 10             	add    $0x10,%esp
        return -1;
80104224:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104229:	e9 a9 00 00 00       	jmp    801042d7 <pipewrite+0x101>
      }
      wakeup(&p->nread);
8010422e:	8b 45 08             	mov    0x8(%ebp),%eax
80104231:	05 34 02 00 00       	add    $0x234,%eax
80104236:	83 ec 0c             	sub    $0xc,%esp
80104239:	50                   	push   %eax
8010423a:	e8 18 0d 00 00       	call   80104f57 <wakeup>
8010423f:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104242:	8b 45 08             	mov    0x8(%ebp),%eax
80104245:	8b 55 08             	mov    0x8(%ebp),%edx
80104248:	81 c2 38 02 00 00    	add    $0x238,%edx
8010424e:	83 ec 08             	sub    $0x8,%esp
80104251:	50                   	push   %eax
80104252:	52                   	push   %edx
80104253:	e8 0d 0c 00 00       	call   80104e65 <sleep>
80104258:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010425b:	8b 45 08             	mov    0x8(%ebp),%eax
8010425e:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104264:	8b 45 08             	mov    0x8(%ebp),%eax
80104267:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010426d:	05 00 02 00 00       	add    $0x200,%eax
80104272:	39 c2                	cmp    %eax,%edx
80104274:	74 86                	je     801041fc <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104276:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104279:	8b 45 0c             	mov    0xc(%ebp),%eax
8010427c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010427f:	8b 45 08             	mov    0x8(%ebp),%eax
80104282:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104288:	8d 48 01             	lea    0x1(%eax),%ecx
8010428b:	8b 55 08             	mov    0x8(%ebp),%edx
8010428e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104294:	25 ff 01 00 00       	and    $0x1ff,%eax
80104299:	89 c1                	mov    %eax,%ecx
8010429b:	0f b6 13             	movzbl (%ebx),%edx
8010429e:	8b 45 08             	mov    0x8(%ebp),%eax
801042a1:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
801042a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ac:	3b 45 10             	cmp    0x10(%ebp),%eax
801042af:	7c aa                	jl     8010425b <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801042b1:	8b 45 08             	mov    0x8(%ebp),%eax
801042b4:	05 34 02 00 00       	add    $0x234,%eax
801042b9:	83 ec 0c             	sub    $0xc,%esp
801042bc:	50                   	push   %eax
801042bd:	e8 95 0c 00 00       	call   80104f57 <wakeup>
801042c2:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801042c5:	8b 45 08             	mov    0x8(%ebp),%eax
801042c8:	83 ec 0c             	sub    $0xc,%esp
801042cb:	50                   	push   %eax
801042cc:	e8 78 10 00 00       	call   80105349 <release>
801042d1:	83 c4 10             	add    $0x10,%esp
  return n;
801042d4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801042d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042da:	c9                   	leave  
801042db:	c3                   	ret    

801042dc <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801042dc:	f3 0f 1e fb          	endbr32 
801042e0:	55                   	push   %ebp
801042e1:	89 e5                	mov    %esp,%ebp
801042e3:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801042e6:	8b 45 08             	mov    0x8(%ebp),%eax
801042e9:	83 ec 0c             	sub    $0xc,%esp
801042ec:	50                   	push   %eax
801042ed:	e8 e5 0f 00 00       	call   801052d7 <acquire>
801042f2:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042f5:	eb 3e                	jmp    80104335 <piperead+0x59>
    if(myproc()->killed){
801042f7:	e8 b4 01 00 00       	call   801044b0 <myproc>
801042fc:	8b 40 28             	mov    0x28(%eax),%eax
801042ff:	85 c0                	test   %eax,%eax
80104301:	74 19                	je     8010431c <piperead+0x40>
      release(&p->lock);
80104303:	8b 45 08             	mov    0x8(%ebp),%eax
80104306:	83 ec 0c             	sub    $0xc,%esp
80104309:	50                   	push   %eax
8010430a:	e8 3a 10 00 00       	call   80105349 <release>
8010430f:	83 c4 10             	add    $0x10,%esp
      return -1;
80104312:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104317:	e9 be 00 00 00       	jmp    801043da <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010431c:	8b 45 08             	mov    0x8(%ebp),%eax
8010431f:	8b 55 08             	mov    0x8(%ebp),%edx
80104322:	81 c2 34 02 00 00    	add    $0x234,%edx
80104328:	83 ec 08             	sub    $0x8,%esp
8010432b:	50                   	push   %eax
8010432c:	52                   	push   %edx
8010432d:	e8 33 0b 00 00       	call   80104e65 <sleep>
80104332:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104335:	8b 45 08             	mov    0x8(%ebp),%eax
80104338:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010433e:	8b 45 08             	mov    0x8(%ebp),%eax
80104341:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104347:	39 c2                	cmp    %eax,%edx
80104349:	75 0d                	jne    80104358 <piperead+0x7c>
8010434b:	8b 45 08             	mov    0x8(%ebp),%eax
8010434e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104354:	85 c0                	test   %eax,%eax
80104356:	75 9f                	jne    801042f7 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104358:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010435f:	eb 48                	jmp    801043a9 <piperead+0xcd>
    if(p->nread == p->nwrite)
80104361:	8b 45 08             	mov    0x8(%ebp),%eax
80104364:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010436a:	8b 45 08             	mov    0x8(%ebp),%eax
8010436d:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104373:	39 c2                	cmp    %eax,%edx
80104375:	74 3c                	je     801043b3 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104377:	8b 45 08             	mov    0x8(%ebp),%eax
8010437a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104380:	8d 48 01             	lea    0x1(%eax),%ecx
80104383:	8b 55 08             	mov    0x8(%ebp),%edx
80104386:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010438c:	25 ff 01 00 00       	and    $0x1ff,%eax
80104391:	89 c1                	mov    %eax,%ecx
80104393:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104396:	8b 45 0c             	mov    0xc(%ebp),%eax
80104399:	01 c2                	add    %eax,%edx
8010439b:	8b 45 08             	mov    0x8(%ebp),%eax
8010439e:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
801043a3:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801043a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ac:	3b 45 10             	cmp    0x10(%ebp),%eax
801043af:	7c b0                	jl     80104361 <piperead+0x85>
801043b1:	eb 01                	jmp    801043b4 <piperead+0xd8>
      break;
801043b3:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801043b4:	8b 45 08             	mov    0x8(%ebp),%eax
801043b7:	05 38 02 00 00       	add    $0x238,%eax
801043bc:	83 ec 0c             	sub    $0xc,%esp
801043bf:	50                   	push   %eax
801043c0:	e8 92 0b 00 00       	call   80104f57 <wakeup>
801043c5:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043c8:	8b 45 08             	mov    0x8(%ebp),%eax
801043cb:	83 ec 0c             	sub    $0xc,%esp
801043ce:	50                   	push   %eax
801043cf:	e8 75 0f 00 00       	call   80105349 <release>
801043d4:	83 c4 10             	add    $0x10,%esp
  return i;
801043d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043da:	c9                   	leave  
801043db:	c3                   	ret    

801043dc <readeflags>:
{
801043dc:	55                   	push   %ebp
801043dd:	89 e5                	mov    %esp,%ebp
801043df:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801043e2:	9c                   	pushf  
801043e3:	58                   	pop    %eax
801043e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801043e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043ea:	c9                   	leave  
801043eb:	c3                   	ret    

801043ec <sti>:
{
801043ec:	55                   	push   %ebp
801043ed:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801043ef:	fb                   	sti    
}
801043f0:	90                   	nop
801043f1:	5d                   	pop    %ebp
801043f2:	c3                   	ret    

801043f3 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801043f3:	f3 0f 1e fb          	endbr32 
801043f7:	55                   	push   %ebp
801043f8:	89 e5                	mov    %esp,%ebp
801043fa:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801043fd:	83 ec 08             	sub    $0x8,%esp
80104400:	68 6c 95 10 80       	push   $0x8010956c
80104405:	68 c0 4d 11 80       	push   $0x80114dc0
8010440a:	e8 a2 0e 00 00       	call   801052b1 <initlock>
8010440f:	83 c4 10             	add    $0x10,%esp
}
80104412:	90                   	nop
80104413:	c9                   	leave  
80104414:	c3                   	ret    

80104415 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104415:	f3 0f 1e fb          	endbr32 
80104419:	55                   	push   %ebp
8010441a:	89 e5                	mov    %esp,%ebp
8010441c:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010441f:	e8 10 00 00 00       	call   80104434 <mycpu>
80104424:	2d 20 48 11 80       	sub    $0x80114820,%eax
80104429:	c1 f8 04             	sar    $0x4,%eax
8010442c:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104432:	c9                   	leave  
80104433:	c3                   	ret    

80104434 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104434:	f3 0f 1e fb          	endbr32 
80104438:	55                   	push   %ebp
80104439:	89 e5                	mov    %esp,%ebp
8010443b:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
8010443e:	e8 99 ff ff ff       	call   801043dc <readeflags>
80104443:	25 00 02 00 00       	and    $0x200,%eax
80104448:	85 c0                	test   %eax,%eax
8010444a:	74 0d                	je     80104459 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
8010444c:	83 ec 0c             	sub    $0xc,%esp
8010444f:	68 74 95 10 80       	push   $0x80109574
80104454:	e8 af c1 ff ff       	call   80100608 <panic>
  
  apicid = lapicid();
80104459:	e8 21 ed ff ff       	call   8010317f <lapicid>
8010445e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104461:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104468:	eb 2d                	jmp    80104497 <mycpu+0x63>
    if (cpus[i].apicid == apicid)
8010446a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104473:	05 20 48 11 80       	add    $0x80114820,%eax
80104478:	0f b6 00             	movzbl (%eax),%eax
8010447b:	0f b6 c0             	movzbl %al,%eax
8010447e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104481:	75 10                	jne    80104493 <mycpu+0x5f>
      return &cpus[i];
80104483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104486:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010448c:	05 20 48 11 80       	add    $0x80114820,%eax
80104491:	eb 1b                	jmp    801044ae <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80104493:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104497:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
8010449c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010449f:	7c c9                	jl     8010446a <mycpu+0x36>
  }
  panic("unknown apicid\n");
801044a1:	83 ec 0c             	sub    $0xc,%esp
801044a4:	68 9a 95 10 80       	push   $0x8010959a
801044a9:	e8 5a c1 ff ff       	call   80100608 <panic>
}
801044ae:	c9                   	leave  
801044af:	c3                   	ret    

801044b0 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801044b0:	f3 0f 1e fb          	endbr32 
801044b4:	55                   	push   %ebp
801044b5:	89 e5                	mov    %esp,%ebp
801044b7:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801044ba:	e8 a4 0f 00 00       	call   80105463 <pushcli>
  c = mycpu();
801044bf:	e8 70 ff ff ff       	call   80104434 <mycpu>
801044c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801044c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ca:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801044d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801044d3:	e8 dc 0f 00 00       	call   801054b4 <popcli>
  return p;
801044d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801044db:	c9                   	leave  
801044dc:	c3                   	ret    

801044dd <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801044dd:	f3 0f 1e fb          	endbr32 
801044e1:	55                   	push   %ebp
801044e2:	89 e5                	mov    %esp,%ebp
801044e4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044e7:	83 ec 0c             	sub    $0xc,%esp
801044ea:	68 c0 4d 11 80       	push   $0x80114dc0
801044ef:	e8 e3 0d 00 00       	call   801052d7 <acquire>
801044f4:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044f7:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
801044fe:	eb 11                	jmp    80104511 <allocproc+0x34>
    if(p->state == UNUSED)
80104500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104503:	8b 40 0c             	mov    0xc(%eax),%eax
80104506:	85 c0                	test   %eax,%eax
80104508:	74 2a                	je     80104534 <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010450a:	81 45 f4 cc 00 00 00 	addl   $0xcc,-0xc(%ebp)
80104511:	81 7d f4 f4 80 11 80 	cmpl   $0x801180f4,-0xc(%ebp)
80104518:	72 e6                	jb     80104500 <allocproc+0x23>
      goto found;

  release(&ptable.lock);
8010451a:	83 ec 0c             	sub    $0xc,%esp
8010451d:	68 c0 4d 11 80       	push   $0x80114dc0
80104522:	e8 22 0e 00 00       	call   80105349 <release>
80104527:	83 c4 10             	add    $0x10,%esp
  return 0;
8010452a:	b8 00 00 00 00       	mov    $0x0,%eax
8010452f:	e9 e0 00 00 00       	jmp    80104614 <allocproc+0x137>
      goto found;
80104534:	90                   	nop
80104535:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80104539:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453c:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104543:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80104548:	8d 50 01             	lea    0x1(%eax),%edx
8010454b:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
80104551:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104554:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80104557:	83 ec 0c             	sub    $0xc,%esp
8010455a:	68 c0 4d 11 80       	push   $0x80114dc0
8010455f:	e8 e5 0d 00 00       	call   80105349 <release>
80104564:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104567:	e8 a6 e8 ff ff       	call   80102e12 <kalloc>
8010456c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010456f:	89 42 08             	mov    %eax,0x8(%edx)
80104572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104575:	8b 40 08             	mov    0x8(%eax),%eax
80104578:	85 c0                	test   %eax,%eax
8010457a:	75 14                	jne    80104590 <allocproc+0xb3>
    p->state = UNUSED;
8010457c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104586:	b8 00 00 00 00       	mov    $0x0,%eax
8010458b:	e9 84 00 00 00       	jmp    80104614 <allocproc+0x137>
  }
  sp = p->kstack + KSTACKSIZE;
80104590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104593:	8b 40 08             	mov    0x8(%eax),%eax
80104596:	05 00 10 00 00       	add    $0x1000,%eax
8010459b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010459e:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801045a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045a8:	89 50 1c             	mov    %edx,0x1c(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801045ab:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801045af:	ba fa 6a 10 80       	mov    $0x80106afa,%edx
801045b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045b7:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801045b9:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801045bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045c3:	89 50 20             	mov    %edx,0x20(%eax)
  memset(p->context, 0, sizeof *p->context);
801045c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c9:	8b 40 20             	mov    0x20(%eax),%eax
801045cc:	83 ec 04             	sub    $0x4,%esp
801045cf:	6a 14                	push   $0x14
801045d1:	6a 00                	push   $0x0
801045d3:	50                   	push   %eax
801045d4:	e8 9d 0f 00 00       	call   80105576 <memset>
801045d9:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801045dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045df:	8b 40 20             	mov    0x20(%eax),%eax
801045e2:	ba 1b 4e 10 80       	mov    $0x80104e1b,%edx
801045e7:	89 50 10             	mov    %edx,0x10(%eax)
  p->queue_size = 0;
801045ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ed:	c7 80 c0 00 00 00 00 	movl   $0x0,0xc0(%eax)
801045f4:	00 00 00 
  p->hand = 0;
801045f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fa:	c7 80 c8 00 00 00 00 	movl   $0x0,0xc8(%eax)
80104601:	00 00 00 
  p->head = 0;
80104604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104607:	c7 80 c4 00 00 00 00 	movl   $0x0,0xc4(%eax)
8010460e:	00 00 00 
  return p;
80104611:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104614:	c9                   	leave  
80104615:	c3                   	ret    

80104616 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104616:	f3 0f 1e fb          	endbr32 
8010461a:	55                   	push   %ebp
8010461b:	89 e5                	mov    %esp,%ebp
8010461d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104620:	e8 b8 fe ff ff       	call   801044dd <allocproc>
80104625:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462b:	a3 40 c6 10 80       	mov    %eax,0x8010c640
  if((p->pgdir = setupkvm()) == 0)
80104630:	e8 5d 3e 00 00       	call   80108492 <setupkvm>
80104635:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104638:	89 42 04             	mov    %eax,0x4(%edx)
8010463b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463e:	8b 40 04             	mov    0x4(%eax),%eax
80104641:	85 c0                	test   %eax,%eax
80104643:	75 0d                	jne    80104652 <userinit+0x3c>
    panic("userinit: out of memory?");
80104645:	83 ec 0c             	sub    $0xc,%esp
80104648:	68 aa 95 10 80       	push   $0x801095aa
8010464d:	e8 b6 bf ff ff       	call   80100608 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104652:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465a:	8b 40 04             	mov    0x4(%eax),%eax
8010465d:	83 ec 04             	sub    $0x4,%esp
80104660:	52                   	push   %edx
80104661:	68 e0 c4 10 80       	push   $0x8010c4e0
80104666:	50                   	push   %eax
80104667:	e8 9f 40 00 00       	call   8010870b <inituvm>
8010466c:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010466f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104672:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104678:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010467e:	83 ec 04             	sub    $0x4,%esp
80104681:	6a 4c                	push   $0x4c
80104683:	6a 00                	push   $0x0
80104685:	50                   	push   %eax
80104686:	e8 eb 0e 00 00       	call   80105576 <memset>
8010468b:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010468e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104691:	8b 40 1c             	mov    0x1c(%eax),%eax
80104694:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010469a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469d:	8b 40 1c             	mov    0x1c(%eax),%eax
801046a0:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801046a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a9:	8b 50 1c             	mov    0x1c(%eax),%edx
801046ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046af:	8b 40 1c             	mov    0x1c(%eax),%eax
801046b2:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046b6:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801046ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046bd:	8b 50 1c             	mov    0x1c(%eax),%edx
801046c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c3:	8b 40 1c             	mov    0x1c(%eax),%eax
801046c6:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046ca:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801046ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d1:	8b 40 1c             	mov    0x1c(%eax),%eax
801046d4:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801046db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046de:	8b 40 1c             	mov    0x1c(%eax),%eax
801046e1:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801046e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046eb:	8b 40 1c             	mov    0x1c(%eax),%eax
801046ee:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801046f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f8:	83 c0 70             	add    $0x70,%eax
801046fb:	83 ec 04             	sub    $0x4,%esp
801046fe:	6a 10                	push   $0x10
80104700:	68 c3 95 10 80       	push   $0x801095c3
80104705:	50                   	push   %eax
80104706:	e8 86 10 00 00       	call   80105791 <safestrcpy>
8010470b:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010470e:	83 ec 0c             	sub    $0xc,%esp
80104711:	68 cc 95 10 80       	push   $0x801095cc
80104716:	e8 72 df ff ff       	call   8010268d <namei>
8010471b:	83 c4 10             	add    $0x10,%esp
8010471e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104721:	89 42 6c             	mov    %eax,0x6c(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104724:	83 ec 0c             	sub    $0xc,%esp
80104727:	68 c0 4d 11 80       	push   $0x80114dc0
8010472c:	e8 a6 0b 00 00       	call   801052d7 <acquire>
80104731:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104737:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010473e:	83 ec 0c             	sub    $0xc,%esp
80104741:	68 c0 4d 11 80       	push   $0x80114dc0
80104746:	e8 fe 0b 00 00       	call   80105349 <release>
8010474b:	83 c4 10             	add    $0x10,%esp
}
8010474e:	90                   	nop
8010474f:	c9                   	leave  
80104750:	c3                   	ret    

80104751 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104751:	f3 0f 1e fb          	endbr32 
80104755:	55                   	push   %ebp
80104756:	89 e5                	mov    %esp,%ebp
80104758:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
8010475b:	e8 50 fd ff ff       	call   801044b0 <myproc>
80104760:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104763:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104766:	8b 00                	mov    (%eax),%eax
80104768:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010476b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010476f:	7e 54                	jle    801047c5 <growproc+0x74>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104771:	8b 55 08             	mov    0x8(%ebp),%edx
80104774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104777:	01 c2                	add    %eax,%edx
80104779:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010477c:	8b 40 04             	mov    0x4(%eax),%eax
8010477f:	83 ec 04             	sub    $0x4,%esp
80104782:	52                   	push   %edx
80104783:	ff 75 f4             	pushl  -0xc(%ebp)
80104786:	50                   	push   %eax
80104787:	e8 c4 40 00 00       	call   80108850 <allocuvm>
8010478c:	83 c4 10             	add    $0x10,%esp
8010478f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104792:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104796:	75 07                	jne    8010479f <growproc+0x4e>
      return -1;
80104798:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010479d:	eb 74                	jmp    80104813 <growproc+0xc2>
    mencrypt((void*)PGROUNDDOWN((int)curproc->sz), (PGROUNDUP(n))/PGSIZE);
8010479f:	8b 45 08             	mov    0x8(%ebp),%eax
801047a2:	05 ff 0f 00 00       	add    $0xfff,%eax
801047a7:	c1 f8 0c             	sar    $0xc,%eax
801047aa:	89 c2                	mov    %eax,%edx
801047ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047af:	8b 00                	mov    (%eax),%eax
801047b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801047b6:	83 ec 08             	sub    $0x8,%esp
801047b9:	52                   	push   %edx
801047ba:	50                   	push   %eax
801047bb:	e8 33 46 00 00       	call   80108df3 <mencrypt>
801047c0:	83 c4 10             	add    $0x10,%esp
801047c3:	eb 33                	jmp    801047f8 <growproc+0xa7>
  } else if(n < 0){
801047c5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047c9:	79 2d                	jns    801047f8 <growproc+0xa7>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n, 1)) == 0)
801047cb:	8b 55 08             	mov    0x8(%ebp),%edx
801047ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d1:	01 c2                	add    %eax,%edx
801047d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047d6:	8b 40 04             	mov    0x4(%eax),%eax
801047d9:	6a 01                	push   $0x1
801047db:	52                   	push   %edx
801047dc:	ff 75 f4             	pushl  -0xc(%ebp)
801047df:	50                   	push   %eax
801047e0:	e8 72 41 00 00       	call   80108957 <deallocuvm>
801047e5:	83 c4 10             	add    $0x10,%esp
801047e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047ef:	75 07                	jne    801047f8 <growproc+0xa7>
      return -1;
801047f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047f6:	eb 1b                	jmp    80104813 <growproc+0xc2>
    //  break;
  //}
    //walk through the page table and read the entries
    //Those entries contain the physical page number + flags

  curproc->sz = sz;
801047f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047fe:	89 10                	mov    %edx,(%eax)

  switchuvm(curproc);
80104800:	83 ec 0c             	sub    $0xc,%esp
80104803:	ff 75 f0             	pushl  -0x10(%ebp)
80104806:	e8 5d 3d 00 00       	call   80108568 <switchuvm>
8010480b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010480e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104813:	c9                   	leave  
80104814:	c3                   	ret    

80104815 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104815:	f3 0f 1e fb          	endbr32 
80104819:	55                   	push   %ebp
8010481a:	89 e5                	mov    %esp,%ebp
8010481c:	57                   	push   %edi
8010481d:	56                   	push   %esi
8010481e:	53                   	push   %ebx
8010481f:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104822:	e8 89 fc ff ff       	call   801044b0 <myproc>
80104827:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
8010482a:	e8 ae fc ff ff       	call   801044dd <allocproc>
8010482f:	89 45 d8             	mov    %eax,-0x28(%ebp)
80104832:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80104836:	75 0a                	jne    80104842 <fork+0x2d>
    return -1;
80104838:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010483d:	e9 c9 01 00 00       	jmp    80104a0b <fork+0x1f6>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104842:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104845:	8b 10                	mov    (%eax),%edx
80104847:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010484a:	8b 40 04             	mov    0x4(%eax),%eax
8010484d:	83 ec 08             	sub    $0x8,%esp
80104850:	52                   	push   %edx
80104851:	50                   	push   %eax
80104852:	e8 c0 42 00 00       	call   80108b17 <copyuvm>
80104857:	83 c4 10             	add    $0x10,%esp
8010485a:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010485d:	89 42 04             	mov    %eax,0x4(%edx)
80104860:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104863:	8b 40 04             	mov    0x4(%eax),%eax
80104866:	85 c0                	test   %eax,%eax
80104868:	75 30                	jne    8010489a <fork+0x85>
    kfree(np->kstack);
8010486a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010486d:	8b 40 08             	mov    0x8(%eax),%eax
80104870:	83 ec 0c             	sub    $0xc,%esp
80104873:	50                   	push   %eax
80104874:	e8 fb e4 ff ff       	call   80102d74 <kfree>
80104879:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010487c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010487f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104886:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104889:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104890:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104895:	e9 71 01 00 00       	jmp    80104a0b <fork+0x1f6>
  }
  curproc->child = np;
8010489a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010489d:	8b 55 d8             	mov    -0x28(%ebp),%edx
801048a0:	89 50 18             	mov    %edx,0x18(%eax)
  np->sz = curproc->sz;
801048a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048a6:	8b 10                	mov    (%eax),%edx
801048a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801048ab:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801048ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
801048b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801048b3:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801048b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048b9:	8b 48 1c             	mov    0x1c(%eax),%ecx
801048bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
801048bf:	8b 40 1c             	mov    0x1c(%eax),%eax
801048c2:	89 c2                	mov    %eax,%edx
801048c4:	89 cb                	mov    %ecx,%ebx
801048c6:	b8 13 00 00 00       	mov    $0x13,%eax
801048cb:	89 d7                	mov    %edx,%edi
801048cd:	89 de                	mov    %ebx,%esi
801048cf:	89 c1                	mov    %eax,%ecx
801048d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->hand = curproc->hand;
801048d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048d6:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
801048dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
801048df:	89 90 c8 00 00 00    	mov    %edx,0xc8(%eax)
  np->queue_size = curproc->queue_size;
801048e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048e8:	8b 90 c0 00 00 00    	mov    0xc0(%eax),%edx
801048ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
801048f1:	89 90 c0 00 00 00    	mov    %edx,0xc0(%eax)
  for(int i = 0; i < curproc->queue_size; i++){
801048f7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801048fe:	eb 3d                	jmp    8010493d <fork+0x128>
    np->clock_queue[i] = curproc->clock_queue[i];
80104900:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80104903:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104906:	8d 58 10             	lea    0x10(%eax),%ebx
80104909:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010490c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010490f:	83 c2 10             	add    $0x10,%edx
80104912:	8d 14 d0             	lea    (%eax,%edx,8),%edx
80104915:	8b 02                	mov    (%edx),%eax
80104917:	8b 52 04             	mov    0x4(%edx),%edx
8010491a:	89 04 d9             	mov    %eax,(%ecx,%ebx,8)
8010491d:	89 54 d9 04          	mov    %edx,0x4(%ecx,%ebx,8)
    np->clock_queue[i].va = curproc->clock_queue[i].va;
80104921:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104924:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104927:	83 c2 10             	add    $0x10,%edx
8010492a:	8b 14 d0             	mov    (%eax,%edx,8),%edx
8010492d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104930:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80104933:	83 c1 10             	add    $0x10,%ecx
80104936:	89 14 c8             	mov    %edx,(%eax,%ecx,8)
  for(int i = 0; i < curproc->queue_size; i++){
80104939:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
8010493d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104940:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
80104946:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80104949:	7c b5                	jl     80104900 <fork+0xeb>

      }

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010494b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010494e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104951:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104958:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010495f:	eb 3b                	jmp    8010499c <fork+0x187>
    if(curproc->ofile[i])
80104961:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104964:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104967:	83 c2 08             	add    $0x8,%edx
8010496a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010496e:	85 c0                	test   %eax,%eax
80104970:	74 26                	je     80104998 <fork+0x183>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104972:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104975:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104978:	83 c2 08             	add    $0x8,%edx
8010497b:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010497f:	83 ec 0c             	sub    $0xc,%esp
80104982:	50                   	push   %eax
80104983:	e8 c5 c7 ff ff       	call   8010114d <filedup>
80104988:	83 c4 10             	add    $0x10,%esp
8010498b:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010498e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104991:	83 c1 08             	add    $0x8,%ecx
80104994:	89 44 8a 0c          	mov    %eax,0xc(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104998:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010499c:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801049a0:	7e bf                	jle    80104961 <fork+0x14c>
  np->cwd = idup(curproc->cwd);
801049a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049a5:	8b 40 6c             	mov    0x6c(%eax),%eax
801049a8:	83 ec 0c             	sub    $0xc,%esp
801049ab:	50                   	push   %eax
801049ac:	e8 33 d1 ff ff       	call   80101ae4 <idup>
801049b1:	83 c4 10             	add    $0x10,%esp
801049b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
801049b7:	89 42 6c             	mov    %eax,0x6c(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801049ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049bd:	8d 50 70             	lea    0x70(%eax),%edx
801049c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801049c3:	83 c0 70             	add    $0x70,%eax
801049c6:	83 ec 04             	sub    $0x4,%esp
801049c9:	6a 10                	push   $0x10
801049cb:	52                   	push   %edx
801049cc:	50                   	push   %eax
801049cd:	e8 bf 0d 00 00       	call   80105791 <safestrcpy>
801049d2:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801049d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801049d8:	8b 40 10             	mov    0x10(%eax),%eax
801049db:	89 45 d4             	mov    %eax,-0x2c(%ebp)

  acquire(&ptable.lock);
801049de:	83 ec 0c             	sub    $0xc,%esp
801049e1:	68 c0 4d 11 80       	push   $0x80114dc0
801049e6:	e8 ec 08 00 00       	call   801052d7 <acquire>
801049eb:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801049ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
801049f1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801049f8:	83 ec 0c             	sub    $0xc,%esp
801049fb:	68 c0 4d 11 80       	push   $0x80114dc0
80104a00:	e8 44 09 00 00       	call   80105349 <release>
80104a05:	83 c4 10             	add    $0x10,%esp

  return pid;
80104a08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
80104a0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a0e:	5b                   	pop    %ebx
80104a0f:	5e                   	pop    %esi
80104a10:	5f                   	pop    %edi
80104a11:	5d                   	pop    %ebp
80104a12:	c3                   	ret    

80104a13 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104a13:	f3 0f 1e fb          	endbr32 
80104a17:	55                   	push   %ebp
80104a18:	89 e5                	mov    %esp,%ebp
80104a1a:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104a1d:	e8 8e fa ff ff       	call   801044b0 <myproc>
80104a22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104a25:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104a2a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a2d:	75 0d                	jne    80104a3c <exit+0x29>
    panic("init exiting");
80104a2f:	83 ec 0c             	sub    $0xc,%esp
80104a32:	68 ce 95 10 80       	push   $0x801095ce
80104a37:	e8 cc bb ff ff       	call   80100608 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a3c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a43:	eb 3f                	jmp    80104a84 <exit+0x71>
    if(curproc->ofile[fd]){
80104a45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a48:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a4b:	83 c2 08             	add    $0x8,%edx
80104a4e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104a52:	85 c0                	test   %eax,%eax
80104a54:	74 2a                	je     80104a80 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104a56:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a59:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a5c:	83 c2 08             	add    $0x8,%edx
80104a5f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104a63:	83 ec 0c             	sub    $0xc,%esp
80104a66:	50                   	push   %eax
80104a67:	e8 36 c7 ff ff       	call   801011a2 <fileclose>
80104a6c:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104a6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a72:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a75:	83 c2 08             	add    $0x8,%edx
80104a78:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80104a7f:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104a80:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a84:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104a88:	7e bb                	jle    80104a45 <exit+0x32>
    }
  }

  begin_op();
80104a8a:	e8 62 ec ff ff       	call   801036f1 <begin_op>
  iput(curproc->cwd);
80104a8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a92:	8b 40 6c             	mov    0x6c(%eax),%eax
80104a95:	83 ec 0c             	sub    $0xc,%esp
80104a98:	50                   	push   %eax
80104a99:	e8 ed d1 ff ff       	call   80101c8b <iput>
80104a9e:	83 c4 10             	add    $0x10,%esp
  end_op();
80104aa1:	e8 db ec ff ff       	call   80103781 <end_op>
  curproc->cwd = 0;
80104aa6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aa9:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)

  acquire(&ptable.lock);
80104ab0:	83 ec 0c             	sub    $0xc,%esp
80104ab3:	68 c0 4d 11 80       	push   $0x80114dc0
80104ab8:	e8 1a 08 00 00       	call   801052d7 <acquire>
80104abd:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104ac0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ac3:	8b 40 14             	mov    0x14(%eax),%eax
80104ac6:	83 ec 0c             	sub    $0xc,%esp
80104ac9:	50                   	push   %eax
80104aca:	e8 41 04 00 00       	call   80104f10 <wakeup1>
80104acf:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ad2:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104ad9:	eb 3a                	jmp    80104b15 <exit+0x102>
    if(p->parent == curproc){
80104adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ade:	8b 40 14             	mov    0x14(%eax),%eax
80104ae1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104ae4:	75 28                	jne    80104b0e <exit+0xfb>
      p->parent = initproc;
80104ae6:	8b 15 40 c6 10 80    	mov    0x8010c640,%edx
80104aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aef:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af5:	8b 40 0c             	mov    0xc(%eax),%eax
80104af8:	83 f8 05             	cmp    $0x5,%eax
80104afb:	75 11                	jne    80104b0e <exit+0xfb>
        wakeup1(initproc);
80104afd:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104b02:	83 ec 0c             	sub    $0xc,%esp
80104b05:	50                   	push   %eax
80104b06:	e8 05 04 00 00       	call   80104f10 <wakeup1>
80104b0b:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b0e:	81 45 f4 cc 00 00 00 	addl   $0xcc,-0xc(%ebp)
80104b15:	81 7d f4 f4 80 11 80 	cmpl   $0x801180f4,-0xc(%ebp)
80104b1c:	72 bd                	jb     80104adb <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104b1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b21:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104b28:	e8 f3 01 00 00       	call   80104d20 <sched>
  panic("zombie exit");
80104b2d:	83 ec 0c             	sub    $0xc,%esp
80104b30:	68 db 95 10 80       	push   $0x801095db
80104b35:	e8 ce ba ff ff       	call   80100608 <panic>

80104b3a <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104b3a:	f3 0f 1e fb          	endbr32 
80104b3e:	55                   	push   %ebp
80104b3f:	89 e5                	mov    %esp,%ebp
80104b41:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104b44:	e8 67 f9 ff ff       	call   801044b0 <myproc>
80104b49:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104b4c:	83 ec 0c             	sub    $0xc,%esp
80104b4f:	68 c0 4d 11 80       	push   $0x80114dc0
80104b54:	e8 7e 07 00 00       	call   801052d7 <acquire>
80104b59:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104b5c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b63:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104b6a:	e9 a4 00 00 00       	jmp    80104c13 <wait+0xd9>
      if(p->parent != curproc)
80104b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b72:	8b 40 14             	mov    0x14(%eax),%eax
80104b75:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104b78:	0f 85 8d 00 00 00    	jne    80104c0b <wait+0xd1>
        continue;
      havekids = 1;
80104b7e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b88:	8b 40 0c             	mov    0xc(%eax),%eax
80104b8b:	83 f8 05             	cmp    $0x5,%eax
80104b8e:	75 7c                	jne    80104c0c <wait+0xd2>
        // Found one.
        pid = p->pid;
80104b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b93:	8b 40 10             	mov    0x10(%eax),%eax
80104b96:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9c:	8b 40 08             	mov    0x8(%eax),%eax
80104b9f:	83 ec 0c             	sub    $0xc,%esp
80104ba2:	50                   	push   %eax
80104ba3:	e8 cc e1 ff ff       	call   80102d74 <kfree>
80104ba8:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bae:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb8:	8b 40 04             	mov    0x4(%eax),%eax
80104bbb:	83 ec 0c             	sub    $0xc,%esp
80104bbe:	50                   	push   %eax
80104bbf:	e8 72 3e 00 00       	call   80108a36 <freevm>
80104bc4:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bca:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bde:	c6 40 70 00          	movb   $0x0,0x70(%eax)
        p->killed = 0;
80104be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be5:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)
        p->state = UNUSED;
80104bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bef:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104bf6:	83 ec 0c             	sub    $0xc,%esp
80104bf9:	68 c0 4d 11 80       	push   $0x80114dc0
80104bfe:	e8 46 07 00 00       	call   80105349 <release>
80104c03:	83 c4 10             	add    $0x10,%esp
        return pid;
80104c06:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104c09:	eb 54                	jmp    80104c5f <wait+0x125>
        continue;
80104c0b:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c0c:	81 45 f4 cc 00 00 00 	addl   $0xcc,-0xc(%ebp)
80104c13:	81 7d f4 f4 80 11 80 	cmpl   $0x801180f4,-0xc(%ebp)
80104c1a:	0f 82 4f ff ff ff    	jb     80104b6f <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104c20:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c24:	74 0a                	je     80104c30 <wait+0xf6>
80104c26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c29:	8b 40 28             	mov    0x28(%eax),%eax
80104c2c:	85 c0                	test   %eax,%eax
80104c2e:	74 17                	je     80104c47 <wait+0x10d>
      release(&ptable.lock);
80104c30:	83 ec 0c             	sub    $0xc,%esp
80104c33:	68 c0 4d 11 80       	push   $0x80114dc0
80104c38:	e8 0c 07 00 00       	call   80105349 <release>
80104c3d:	83 c4 10             	add    $0x10,%esp
      return -1;
80104c40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c45:	eb 18                	jmp    80104c5f <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104c47:	83 ec 08             	sub    $0x8,%esp
80104c4a:	68 c0 4d 11 80       	push   $0x80114dc0
80104c4f:	ff 75 ec             	pushl  -0x14(%ebp)
80104c52:	e8 0e 02 00 00       	call   80104e65 <sleep>
80104c57:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104c5a:	e9 fd fe ff ff       	jmp    80104b5c <wait+0x22>
  }
}
80104c5f:	c9                   	leave  
80104c60:	c3                   	ret    

80104c61 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c61:	f3 0f 1e fb          	endbr32 
80104c65:	55                   	push   %ebp
80104c66:	89 e5                	mov    %esp,%ebp
80104c68:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104c6b:	e8 c4 f7 ff ff       	call   80104434 <mycpu>
80104c70:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104c73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c76:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c7d:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c80:	e8 67 f7 ff ff       	call   801043ec <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c85:	83 ec 0c             	sub    $0xc,%esp
80104c88:	68 c0 4d 11 80       	push   $0x80114dc0
80104c8d:	e8 45 06 00 00       	call   801052d7 <acquire>
80104c92:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c95:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104c9c:	eb 64                	jmp    80104d02 <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca1:	8b 40 0c             	mov    0xc(%eax),%eax
80104ca4:	83 f8 03             	cmp    $0x3,%eax
80104ca7:	75 51                	jne    80104cfa <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104ca9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cac:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104caf:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104cb5:	83 ec 0c             	sub    $0xc,%esp
80104cb8:	ff 75 f4             	pushl  -0xc(%ebp)
80104cbb:	e8 a8 38 00 00       	call   80108568 <switchuvm>
80104cc0:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc6:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd0:	8b 40 20             	mov    0x20(%eax),%eax
80104cd3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cd6:	83 c2 04             	add    $0x4,%edx
80104cd9:	83 ec 08             	sub    $0x8,%esp
80104cdc:	50                   	push   %eax
80104cdd:	52                   	push   %edx
80104cde:	e8 27 0b 00 00       	call   8010580a <swtch>
80104ce3:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104ce6:	e8 60 38 00 00       	call   8010854b <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104ceb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cee:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104cf5:	00 00 00 
80104cf8:	eb 01                	jmp    80104cfb <scheduler+0x9a>
        continue;
80104cfa:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cfb:	81 45 f4 cc 00 00 00 	addl   $0xcc,-0xc(%ebp)
80104d02:	81 7d f4 f4 80 11 80 	cmpl   $0x801180f4,-0xc(%ebp)
80104d09:	72 93                	jb     80104c9e <scheduler+0x3d>
    }
    release(&ptable.lock);
80104d0b:	83 ec 0c             	sub    $0xc,%esp
80104d0e:	68 c0 4d 11 80       	push   $0x80114dc0
80104d13:	e8 31 06 00 00       	call   80105349 <release>
80104d18:	83 c4 10             	add    $0x10,%esp
    sti();
80104d1b:	e9 60 ff ff ff       	jmp    80104c80 <scheduler+0x1f>

80104d20 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104d20:	f3 0f 1e fb          	endbr32 
80104d24:	55                   	push   %ebp
80104d25:	89 e5                	mov    %esp,%ebp
80104d27:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104d2a:	e8 81 f7 ff ff       	call   801044b0 <myproc>
80104d2f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104d32:	83 ec 0c             	sub    $0xc,%esp
80104d35:	68 c0 4d 11 80       	push   $0x80114dc0
80104d3a:	e8 df 06 00 00       	call   8010541e <holding>
80104d3f:	83 c4 10             	add    $0x10,%esp
80104d42:	85 c0                	test   %eax,%eax
80104d44:	75 0d                	jne    80104d53 <sched+0x33>
    panic("sched ptable.lock");
80104d46:	83 ec 0c             	sub    $0xc,%esp
80104d49:	68 e7 95 10 80       	push   $0x801095e7
80104d4e:	e8 b5 b8 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli != 1)
80104d53:	e8 dc f6 ff ff       	call   80104434 <mycpu>
80104d58:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d5e:	83 f8 01             	cmp    $0x1,%eax
80104d61:	74 0d                	je     80104d70 <sched+0x50>
    panic("sched locks");
80104d63:	83 ec 0c             	sub    $0xc,%esp
80104d66:	68 f9 95 10 80       	push   $0x801095f9
80104d6b:	e8 98 b8 ff ff       	call   80100608 <panic>
  if(p->state == RUNNING)
80104d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d73:	8b 40 0c             	mov    0xc(%eax),%eax
80104d76:	83 f8 04             	cmp    $0x4,%eax
80104d79:	75 0d                	jne    80104d88 <sched+0x68>
    panic("sched running");
80104d7b:	83 ec 0c             	sub    $0xc,%esp
80104d7e:	68 05 96 10 80       	push   $0x80109605
80104d83:	e8 80 b8 ff ff       	call   80100608 <panic>
  if(readeflags()&FL_IF)
80104d88:	e8 4f f6 ff ff       	call   801043dc <readeflags>
80104d8d:	25 00 02 00 00       	and    $0x200,%eax
80104d92:	85 c0                	test   %eax,%eax
80104d94:	74 0d                	je     80104da3 <sched+0x83>
    panic("sched interruptible");
80104d96:	83 ec 0c             	sub    $0xc,%esp
80104d99:	68 13 96 10 80       	push   $0x80109613
80104d9e:	e8 65 b8 ff ff       	call   80100608 <panic>
  intena = mycpu()->intena;
80104da3:	e8 8c f6 ff ff       	call   80104434 <mycpu>
80104da8:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104dae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104db1:	e8 7e f6 ff ff       	call   80104434 <mycpu>
80104db6:	8b 40 04             	mov    0x4(%eax),%eax
80104db9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dbc:	83 c2 20             	add    $0x20,%edx
80104dbf:	83 ec 08             	sub    $0x8,%esp
80104dc2:	50                   	push   %eax
80104dc3:	52                   	push   %edx
80104dc4:	e8 41 0a 00 00       	call   8010580a <swtch>
80104dc9:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104dcc:	e8 63 f6 ff ff       	call   80104434 <mycpu>
80104dd1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104dd4:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104dda:	90                   	nop
80104ddb:	c9                   	leave  
80104ddc:	c3                   	ret    

80104ddd <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104ddd:	f3 0f 1e fb          	endbr32 
80104de1:	55                   	push   %ebp
80104de2:	89 e5                	mov    %esp,%ebp
80104de4:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104de7:	83 ec 0c             	sub    $0xc,%esp
80104dea:	68 c0 4d 11 80       	push   $0x80114dc0
80104def:	e8 e3 04 00 00       	call   801052d7 <acquire>
80104df4:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104df7:	e8 b4 f6 ff ff       	call   801044b0 <myproc>
80104dfc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104e03:	e8 18 ff ff ff       	call   80104d20 <sched>
  release(&ptable.lock);
80104e08:	83 ec 0c             	sub    $0xc,%esp
80104e0b:	68 c0 4d 11 80       	push   $0x80114dc0
80104e10:	e8 34 05 00 00       	call   80105349 <release>
80104e15:	83 c4 10             	add    $0x10,%esp
}
80104e18:	90                   	nop
80104e19:	c9                   	leave  
80104e1a:	c3                   	ret    

80104e1b <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e1b:	f3 0f 1e fb          	endbr32 
80104e1f:	55                   	push   %ebp
80104e20:	89 e5                	mov    %esp,%ebp
80104e22:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e25:	83 ec 0c             	sub    $0xc,%esp
80104e28:	68 c0 4d 11 80       	push   $0x80114dc0
80104e2d:	e8 17 05 00 00       	call   80105349 <release>
80104e32:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104e35:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104e3a:	85 c0                	test   %eax,%eax
80104e3c:	74 24                	je     80104e62 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104e3e:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104e45:	00 00 00 
    iinit(ROOTDEV);
80104e48:	83 ec 0c             	sub    $0xc,%esp
80104e4b:	6a 01                	push   $0x1
80104e4d:	e8 4a c9 ff ff       	call   8010179c <iinit>
80104e52:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104e55:	83 ec 0c             	sub    $0xc,%esp
80104e58:	6a 01                	push   $0x1
80104e5a:	e8 5f e6 ff ff       	call   801034be <initlog>
80104e5f:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104e62:	90                   	nop
80104e63:	c9                   	leave  
80104e64:	c3                   	ret    

80104e65 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e65:	f3 0f 1e fb          	endbr32 
80104e69:	55                   	push   %ebp
80104e6a:	89 e5                	mov    %esp,%ebp
80104e6c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104e6f:	e8 3c f6 ff ff       	call   801044b0 <myproc>
80104e74:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104e77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e7b:	75 0d                	jne    80104e8a <sleep+0x25>
    panic("sleep");
80104e7d:	83 ec 0c             	sub    $0xc,%esp
80104e80:	68 27 96 10 80       	push   $0x80109627
80104e85:	e8 7e b7 ff ff       	call   80100608 <panic>

  if(lk == 0)
80104e8a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e8e:	75 0d                	jne    80104e9d <sleep+0x38>
    panic("sleep without lk");
80104e90:	83 ec 0c             	sub    $0xc,%esp
80104e93:	68 2d 96 10 80       	push   $0x8010962d
80104e98:	e8 6b b7 ff ff       	call   80100608 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e9d:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104ea4:	74 1e                	je     80104ec4 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ea6:	83 ec 0c             	sub    $0xc,%esp
80104ea9:	68 c0 4d 11 80       	push   $0x80114dc0
80104eae:	e8 24 04 00 00       	call   801052d7 <acquire>
80104eb3:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104eb6:	83 ec 0c             	sub    $0xc,%esp
80104eb9:	ff 75 0c             	pushl  0xc(%ebp)
80104ebc:	e8 88 04 00 00       	call   80105349 <release>
80104ec1:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec7:	8b 55 08             	mov    0x8(%ebp),%edx
80104eca:	89 50 24             	mov    %edx,0x24(%eax)
  p->state = SLEEPING;
80104ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed0:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104ed7:	e8 44 fe ff ff       	call   80104d20 <sched>

  // Tidy up.
  p->chan = 0;
80104edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104edf:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ee6:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104eed:	74 1e                	je     80104f0d <sleep+0xa8>
    release(&ptable.lock);
80104eef:	83 ec 0c             	sub    $0xc,%esp
80104ef2:	68 c0 4d 11 80       	push   $0x80114dc0
80104ef7:	e8 4d 04 00 00       	call   80105349 <release>
80104efc:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104eff:	83 ec 0c             	sub    $0xc,%esp
80104f02:	ff 75 0c             	pushl  0xc(%ebp)
80104f05:	e8 cd 03 00 00       	call   801052d7 <acquire>
80104f0a:	83 c4 10             	add    $0x10,%esp
  }
}
80104f0d:	90                   	nop
80104f0e:	c9                   	leave  
80104f0f:	c3                   	ret    

80104f10 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104f10:	f3 0f 1e fb          	endbr32 
80104f14:	55                   	push   %ebp
80104f15:	89 e5                	mov    %esp,%ebp
80104f17:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f1a:	c7 45 fc f4 4d 11 80 	movl   $0x80114df4,-0x4(%ebp)
80104f21:	eb 27                	jmp    80104f4a <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
80104f23:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f26:	8b 40 0c             	mov    0xc(%eax),%eax
80104f29:	83 f8 02             	cmp    $0x2,%eax
80104f2c:	75 15                	jne    80104f43 <wakeup1+0x33>
80104f2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f31:	8b 40 24             	mov    0x24(%eax),%eax
80104f34:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f37:	75 0a                	jne    80104f43 <wakeup1+0x33>
      p->state = RUNNABLE;
80104f39:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f3c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f43:	81 45 fc cc 00 00 00 	addl   $0xcc,-0x4(%ebp)
80104f4a:	81 7d fc f4 80 11 80 	cmpl   $0x801180f4,-0x4(%ebp)
80104f51:	72 d0                	jb     80104f23 <wakeup1+0x13>
}
80104f53:	90                   	nop
80104f54:	90                   	nop
80104f55:	c9                   	leave  
80104f56:	c3                   	ret    

80104f57 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f57:	f3 0f 1e fb          	endbr32 
80104f5b:	55                   	push   %ebp
80104f5c:	89 e5                	mov    %esp,%ebp
80104f5e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104f61:	83 ec 0c             	sub    $0xc,%esp
80104f64:	68 c0 4d 11 80       	push   $0x80114dc0
80104f69:	e8 69 03 00 00       	call   801052d7 <acquire>
80104f6e:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104f71:	83 ec 0c             	sub    $0xc,%esp
80104f74:	ff 75 08             	pushl  0x8(%ebp)
80104f77:	e8 94 ff ff ff       	call   80104f10 <wakeup1>
80104f7c:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104f7f:	83 ec 0c             	sub    $0xc,%esp
80104f82:	68 c0 4d 11 80       	push   $0x80114dc0
80104f87:	e8 bd 03 00 00       	call   80105349 <release>
80104f8c:	83 c4 10             	add    $0x10,%esp
}
80104f8f:	90                   	nop
80104f90:	c9                   	leave  
80104f91:	c3                   	ret    

80104f92 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f92:	f3 0f 1e fb          	endbr32 
80104f96:	55                   	push   %ebp
80104f97:	89 e5                	mov    %esp,%ebp
80104f99:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f9c:	83 ec 0c             	sub    $0xc,%esp
80104f9f:	68 c0 4d 11 80       	push   $0x80114dc0
80104fa4:	e8 2e 03 00 00       	call   801052d7 <acquire>
80104fa9:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fac:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104fb3:	eb 48                	jmp    80104ffd <kill+0x6b>
    if(p->pid == pid){
80104fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb8:	8b 40 10             	mov    0x10(%eax),%eax
80104fbb:	39 45 08             	cmp    %eax,0x8(%ebp)
80104fbe:	75 36                	jne    80104ff6 <kill+0x64>
      p->killed = 1;
80104fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc3:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fcd:	8b 40 0c             	mov    0xc(%eax),%eax
80104fd0:	83 f8 02             	cmp    $0x2,%eax
80104fd3:	75 0a                	jne    80104fdf <kill+0x4d>
        p->state = RUNNABLE;
80104fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104fdf:	83 ec 0c             	sub    $0xc,%esp
80104fe2:	68 c0 4d 11 80       	push   $0x80114dc0
80104fe7:	e8 5d 03 00 00       	call   80105349 <release>
80104fec:	83 c4 10             	add    $0x10,%esp
      return 0;
80104fef:	b8 00 00 00 00       	mov    $0x0,%eax
80104ff4:	eb 25                	jmp    8010501b <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ff6:	81 45 f4 cc 00 00 00 	addl   $0xcc,-0xc(%ebp)
80104ffd:	81 7d f4 f4 80 11 80 	cmpl   $0x801180f4,-0xc(%ebp)
80105004:	72 af                	jb     80104fb5 <kill+0x23>
    }
  }
  release(&ptable.lock);
80105006:	83 ec 0c             	sub    $0xc,%esp
80105009:	68 c0 4d 11 80       	push   $0x80114dc0
8010500e:	e8 36 03 00 00       	call   80105349 <release>
80105013:	83 c4 10             	add    $0x10,%esp
  return -1;
80105016:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010501b:	c9                   	leave  
8010501c:	c3                   	ret    

8010501d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010501d:	f3 0f 1e fb          	endbr32 
80105021:	55                   	push   %ebp
80105022:	89 e5                	mov    %esp,%ebp
80105024:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105027:	c7 45 f0 f4 4d 11 80 	movl   $0x80114df4,-0x10(%ebp)
8010502e:	e9 da 00 00 00       	jmp    8010510d <procdump+0xf0>
    if(p->state == UNUSED)
80105033:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105036:	8b 40 0c             	mov    0xc(%eax),%eax
80105039:	85 c0                	test   %eax,%eax
8010503b:	0f 84 c4 00 00 00    	je     80105105 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105041:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105044:	8b 40 0c             	mov    0xc(%eax),%eax
80105047:	83 f8 05             	cmp    $0x5,%eax
8010504a:	77 23                	ja     8010506f <procdump+0x52>
8010504c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010504f:	8b 40 0c             	mov    0xc(%eax),%eax
80105052:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105059:	85 c0                	test   %eax,%eax
8010505b:	74 12                	je     8010506f <procdump+0x52>
      state = states[p->state];
8010505d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105060:	8b 40 0c             	mov    0xc(%eax),%eax
80105063:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010506a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010506d:	eb 07                	jmp    80105076 <procdump+0x59>
    else
      state = "???";
8010506f:	c7 45 ec 3e 96 10 80 	movl   $0x8010963e,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105076:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105079:	8d 50 70             	lea    0x70(%eax),%edx
8010507c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010507f:	8b 40 10             	mov    0x10(%eax),%eax
80105082:	52                   	push   %edx
80105083:	ff 75 ec             	pushl  -0x14(%ebp)
80105086:	50                   	push   %eax
80105087:	68 42 96 10 80       	push   $0x80109642
8010508c:	e8 87 b3 ff ff       	call   80100418 <cprintf>
80105091:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105094:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105097:	8b 40 0c             	mov    0xc(%eax),%eax
8010509a:	83 f8 02             	cmp    $0x2,%eax
8010509d:	75 54                	jne    801050f3 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010509f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a2:	8b 40 20             	mov    0x20(%eax),%eax
801050a5:	8b 40 0c             	mov    0xc(%eax),%eax
801050a8:	83 c0 08             	add    $0x8,%eax
801050ab:	89 c2                	mov    %eax,%edx
801050ad:	83 ec 08             	sub    $0x8,%esp
801050b0:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801050b3:	50                   	push   %eax
801050b4:	52                   	push   %edx
801050b5:	e8 e5 02 00 00       	call   8010539f <getcallerpcs>
801050ba:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050c4:	eb 1c                	jmp    801050e2 <procdump+0xc5>
        cprintf(" %p", pc[i]);
801050c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c9:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050cd:	83 ec 08             	sub    $0x8,%esp
801050d0:	50                   	push   %eax
801050d1:	68 4b 96 10 80       	push   $0x8010964b
801050d6:	e8 3d b3 ff ff       	call   80100418 <cprintf>
801050db:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050e2:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801050e6:	7f 0b                	jg     801050f3 <procdump+0xd6>
801050e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050eb:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050ef:	85 c0                	test   %eax,%eax
801050f1:	75 d3                	jne    801050c6 <procdump+0xa9>
    }
    cprintf("\n");
801050f3:	83 ec 0c             	sub    $0xc,%esp
801050f6:	68 4f 96 10 80       	push   $0x8010964f
801050fb:	e8 18 b3 ff ff       	call   80100418 <cprintf>
80105100:	83 c4 10             	add    $0x10,%esp
80105103:	eb 01                	jmp    80105106 <procdump+0xe9>
      continue;
80105105:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105106:	81 45 f0 cc 00 00 00 	addl   $0xcc,-0x10(%ebp)
8010510d:	81 7d f0 f4 80 11 80 	cmpl   $0x801180f4,-0x10(%ebp)
80105114:	0f 82 19 ff ff ff    	jb     80105033 <procdump+0x16>
  }
}
8010511a:	90                   	nop
8010511b:	90                   	nop
8010511c:	c9                   	leave  
8010511d:	c3                   	ret    

8010511e <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010511e:	f3 0f 1e fb          	endbr32 
80105122:	55                   	push   %ebp
80105123:	89 e5                	mov    %esp,%ebp
80105125:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80105128:	8b 45 08             	mov    0x8(%ebp),%eax
8010512b:	83 c0 04             	add    $0x4,%eax
8010512e:	83 ec 08             	sub    $0x8,%esp
80105131:	68 7b 96 10 80       	push   $0x8010967b
80105136:	50                   	push   %eax
80105137:	e8 75 01 00 00       	call   801052b1 <initlock>
8010513c:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010513f:	8b 45 08             	mov    0x8(%ebp),%eax
80105142:	8b 55 0c             	mov    0xc(%ebp),%edx
80105145:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105148:	8b 45 08             	mov    0x8(%ebp),%eax
8010514b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105151:	8b 45 08             	mov    0x8(%ebp),%eax
80105154:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
8010515b:	90                   	nop
8010515c:	c9                   	leave  
8010515d:	c3                   	ret    

8010515e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010515e:	f3 0f 1e fb          	endbr32 
80105162:	55                   	push   %ebp
80105163:	89 e5                	mov    %esp,%ebp
80105165:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105168:	8b 45 08             	mov    0x8(%ebp),%eax
8010516b:	83 c0 04             	add    $0x4,%eax
8010516e:	83 ec 0c             	sub    $0xc,%esp
80105171:	50                   	push   %eax
80105172:	e8 60 01 00 00       	call   801052d7 <acquire>
80105177:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010517a:	eb 15                	jmp    80105191 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
8010517c:	8b 45 08             	mov    0x8(%ebp),%eax
8010517f:	83 c0 04             	add    $0x4,%eax
80105182:	83 ec 08             	sub    $0x8,%esp
80105185:	50                   	push   %eax
80105186:	ff 75 08             	pushl  0x8(%ebp)
80105189:	e8 d7 fc ff ff       	call   80104e65 <sleep>
8010518e:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105191:	8b 45 08             	mov    0x8(%ebp),%eax
80105194:	8b 00                	mov    (%eax),%eax
80105196:	85 c0                	test   %eax,%eax
80105198:	75 e2                	jne    8010517c <acquiresleep+0x1e>
  }
  lk->locked = 1;
8010519a:	8b 45 08             	mov    0x8(%ebp),%eax
8010519d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801051a3:	e8 08 f3 ff ff       	call   801044b0 <myproc>
801051a8:	8b 50 10             	mov    0x10(%eax),%edx
801051ab:	8b 45 08             	mov    0x8(%ebp),%eax
801051ae:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801051b1:	8b 45 08             	mov    0x8(%ebp),%eax
801051b4:	83 c0 04             	add    $0x4,%eax
801051b7:	83 ec 0c             	sub    $0xc,%esp
801051ba:	50                   	push   %eax
801051bb:	e8 89 01 00 00       	call   80105349 <release>
801051c0:	83 c4 10             	add    $0x10,%esp
}
801051c3:	90                   	nop
801051c4:	c9                   	leave  
801051c5:	c3                   	ret    

801051c6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801051c6:	f3 0f 1e fb          	endbr32 
801051ca:	55                   	push   %ebp
801051cb:	89 e5                	mov    %esp,%ebp
801051cd:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801051d0:	8b 45 08             	mov    0x8(%ebp),%eax
801051d3:	83 c0 04             	add    $0x4,%eax
801051d6:	83 ec 0c             	sub    $0xc,%esp
801051d9:	50                   	push   %eax
801051da:	e8 f8 00 00 00       	call   801052d7 <acquire>
801051df:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801051e2:	8b 45 08             	mov    0x8(%ebp),%eax
801051e5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051eb:	8b 45 08             	mov    0x8(%ebp),%eax
801051ee:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801051f5:	83 ec 0c             	sub    $0xc,%esp
801051f8:	ff 75 08             	pushl  0x8(%ebp)
801051fb:	e8 57 fd ff ff       	call   80104f57 <wakeup>
80105200:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105203:	8b 45 08             	mov    0x8(%ebp),%eax
80105206:	83 c0 04             	add    $0x4,%eax
80105209:	83 ec 0c             	sub    $0xc,%esp
8010520c:	50                   	push   %eax
8010520d:	e8 37 01 00 00       	call   80105349 <release>
80105212:	83 c4 10             	add    $0x10,%esp
}
80105215:	90                   	nop
80105216:	c9                   	leave  
80105217:	c3                   	ret    

80105218 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105218:	f3 0f 1e fb          	endbr32 
8010521c:	55                   	push   %ebp
8010521d:	89 e5                	mov    %esp,%ebp
8010521f:	53                   	push   %ebx
80105220:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
80105223:	8b 45 08             	mov    0x8(%ebp),%eax
80105226:	83 c0 04             	add    $0x4,%eax
80105229:	83 ec 0c             	sub    $0xc,%esp
8010522c:	50                   	push   %eax
8010522d:	e8 a5 00 00 00       	call   801052d7 <acquire>
80105232:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
80105235:	8b 45 08             	mov    0x8(%ebp),%eax
80105238:	8b 00                	mov    (%eax),%eax
8010523a:	85 c0                	test   %eax,%eax
8010523c:	74 19                	je     80105257 <holdingsleep+0x3f>
8010523e:	8b 45 08             	mov    0x8(%ebp),%eax
80105241:	8b 58 3c             	mov    0x3c(%eax),%ebx
80105244:	e8 67 f2 ff ff       	call   801044b0 <myproc>
80105249:	8b 40 10             	mov    0x10(%eax),%eax
8010524c:	39 c3                	cmp    %eax,%ebx
8010524e:	75 07                	jne    80105257 <holdingsleep+0x3f>
80105250:	b8 01 00 00 00       	mov    $0x1,%eax
80105255:	eb 05                	jmp    8010525c <holdingsleep+0x44>
80105257:	b8 00 00 00 00       	mov    $0x0,%eax
8010525c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010525f:	8b 45 08             	mov    0x8(%ebp),%eax
80105262:	83 c0 04             	add    $0x4,%eax
80105265:	83 ec 0c             	sub    $0xc,%esp
80105268:	50                   	push   %eax
80105269:	e8 db 00 00 00       	call   80105349 <release>
8010526e:	83 c4 10             	add    $0x10,%esp
  return r;
80105271:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105274:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105277:	c9                   	leave  
80105278:	c3                   	ret    

80105279 <readeflags>:
{
80105279:	55                   	push   %ebp
8010527a:	89 e5                	mov    %esp,%ebp
8010527c:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010527f:	9c                   	pushf  
80105280:	58                   	pop    %eax
80105281:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105284:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105287:	c9                   	leave  
80105288:	c3                   	ret    

80105289 <cli>:
{
80105289:	55                   	push   %ebp
8010528a:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010528c:	fa                   	cli    
}
8010528d:	90                   	nop
8010528e:	5d                   	pop    %ebp
8010528f:	c3                   	ret    

80105290 <sti>:
{
80105290:	55                   	push   %ebp
80105291:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105293:	fb                   	sti    
}
80105294:	90                   	nop
80105295:	5d                   	pop    %ebp
80105296:	c3                   	ret    

80105297 <xchg>:
{
80105297:	55                   	push   %ebp
80105298:	89 e5                	mov    %esp,%ebp
8010529a:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010529d:	8b 55 08             	mov    0x8(%ebp),%edx
801052a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052a6:	f0 87 02             	lock xchg %eax,(%edx)
801052a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801052ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052af:	c9                   	leave  
801052b0:	c3                   	ret    

801052b1 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801052b1:	f3 0f 1e fb          	endbr32 
801052b5:	55                   	push   %ebp
801052b6:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801052b8:	8b 45 08             	mov    0x8(%ebp),%eax
801052bb:	8b 55 0c             	mov    0xc(%ebp),%edx
801052be:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801052c1:	8b 45 08             	mov    0x8(%ebp),%eax
801052c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801052ca:	8b 45 08             	mov    0x8(%ebp),%eax
801052cd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801052d4:	90                   	nop
801052d5:	5d                   	pop    %ebp
801052d6:	c3                   	ret    

801052d7 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801052d7:	f3 0f 1e fb          	endbr32 
801052db:	55                   	push   %ebp
801052dc:	89 e5                	mov    %esp,%ebp
801052de:	53                   	push   %ebx
801052df:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801052e2:	e8 7c 01 00 00       	call   80105463 <pushcli>
  if(holding(lk))
801052e7:	8b 45 08             	mov    0x8(%ebp),%eax
801052ea:	83 ec 0c             	sub    $0xc,%esp
801052ed:	50                   	push   %eax
801052ee:	e8 2b 01 00 00       	call   8010541e <holding>
801052f3:	83 c4 10             	add    $0x10,%esp
801052f6:	85 c0                	test   %eax,%eax
801052f8:	74 0d                	je     80105307 <acquire+0x30>
    panic("acquire");
801052fa:	83 ec 0c             	sub    $0xc,%esp
801052fd:	68 86 96 10 80       	push   $0x80109686
80105302:	e8 01 b3 ff ff       	call   80100608 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105307:	90                   	nop
80105308:	8b 45 08             	mov    0x8(%ebp),%eax
8010530b:	83 ec 08             	sub    $0x8,%esp
8010530e:	6a 01                	push   $0x1
80105310:	50                   	push   %eax
80105311:	e8 81 ff ff ff       	call   80105297 <xchg>
80105316:	83 c4 10             	add    $0x10,%esp
80105319:	85 c0                	test   %eax,%eax
8010531b:	75 eb                	jne    80105308 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010531d:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105322:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105325:	e8 0a f1 ff ff       	call   80104434 <mycpu>
8010532a:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010532d:	8b 45 08             	mov    0x8(%ebp),%eax
80105330:	83 c0 0c             	add    $0xc,%eax
80105333:	83 ec 08             	sub    $0x8,%esp
80105336:	50                   	push   %eax
80105337:	8d 45 08             	lea    0x8(%ebp),%eax
8010533a:	50                   	push   %eax
8010533b:	e8 5f 00 00 00       	call   8010539f <getcallerpcs>
80105340:	83 c4 10             	add    $0x10,%esp
}
80105343:	90                   	nop
80105344:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105347:	c9                   	leave  
80105348:	c3                   	ret    

80105349 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105349:	f3 0f 1e fb          	endbr32 
8010534d:	55                   	push   %ebp
8010534e:	89 e5                	mov    %esp,%ebp
80105350:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105353:	83 ec 0c             	sub    $0xc,%esp
80105356:	ff 75 08             	pushl  0x8(%ebp)
80105359:	e8 c0 00 00 00       	call   8010541e <holding>
8010535e:	83 c4 10             	add    $0x10,%esp
80105361:	85 c0                	test   %eax,%eax
80105363:	75 0d                	jne    80105372 <release+0x29>
    panic("release");
80105365:	83 ec 0c             	sub    $0xc,%esp
80105368:	68 8e 96 10 80       	push   $0x8010968e
8010536d:	e8 96 b2 ff ff       	call   80100608 <panic>

  lk->pcs[0] = 0;
80105372:	8b 45 08             	mov    0x8(%ebp),%eax
80105375:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010537c:	8b 45 08             	mov    0x8(%ebp),%eax
8010537f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105386:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010538b:	8b 45 08             	mov    0x8(%ebp),%eax
8010538e:	8b 55 08             	mov    0x8(%ebp),%edx
80105391:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105397:	e8 18 01 00 00       	call   801054b4 <popcli>
}
8010539c:	90                   	nop
8010539d:	c9                   	leave  
8010539e:	c3                   	ret    

8010539f <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010539f:	f3 0f 1e fb          	endbr32 
801053a3:	55                   	push   %ebp
801053a4:	89 e5                	mov    %esp,%ebp
801053a6:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801053a9:	8b 45 08             	mov    0x8(%ebp),%eax
801053ac:	83 e8 08             	sub    $0x8,%eax
801053af:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053b2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801053b9:	eb 38                	jmp    801053f3 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801053bb:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801053bf:	74 53                	je     80105414 <getcallerpcs+0x75>
801053c1:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801053c8:	76 4a                	jbe    80105414 <getcallerpcs+0x75>
801053ca:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801053ce:	74 44                	je     80105414 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
801053d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053d3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053da:	8b 45 0c             	mov    0xc(%ebp),%eax
801053dd:	01 c2                	add    %eax,%edx
801053df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053e2:	8b 40 04             	mov    0x4(%eax),%eax
801053e5:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801053e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ea:	8b 00                	mov    (%eax),%eax
801053ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053ef:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053f3:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053f7:	7e c2                	jle    801053bb <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
801053f9:	eb 19                	jmp    80105414 <getcallerpcs+0x75>
    pcs[i] = 0;
801053fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053fe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105405:	8b 45 0c             	mov    0xc(%ebp),%eax
80105408:	01 d0                	add    %edx,%eax
8010540a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105410:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105414:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105418:	7e e1                	jle    801053fb <getcallerpcs+0x5c>
}
8010541a:	90                   	nop
8010541b:	90                   	nop
8010541c:	c9                   	leave  
8010541d:	c3                   	ret    

8010541e <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010541e:	f3 0f 1e fb          	endbr32 
80105422:	55                   	push   %ebp
80105423:	89 e5                	mov    %esp,%ebp
80105425:	53                   	push   %ebx
80105426:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
80105429:	e8 35 00 00 00       	call   80105463 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010542e:	8b 45 08             	mov    0x8(%ebp),%eax
80105431:	8b 00                	mov    (%eax),%eax
80105433:	85 c0                	test   %eax,%eax
80105435:	74 16                	je     8010544d <holding+0x2f>
80105437:	8b 45 08             	mov    0x8(%ebp),%eax
8010543a:	8b 58 08             	mov    0x8(%eax),%ebx
8010543d:	e8 f2 ef ff ff       	call   80104434 <mycpu>
80105442:	39 c3                	cmp    %eax,%ebx
80105444:	75 07                	jne    8010544d <holding+0x2f>
80105446:	b8 01 00 00 00       	mov    $0x1,%eax
8010544b:	eb 05                	jmp    80105452 <holding+0x34>
8010544d:	b8 00 00 00 00       	mov    $0x0,%eax
80105452:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
80105455:	e8 5a 00 00 00       	call   801054b4 <popcli>
  return r;
8010545a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010545d:	83 c4 14             	add    $0x14,%esp
80105460:	5b                   	pop    %ebx
80105461:	5d                   	pop    %ebp
80105462:	c3                   	ret    

80105463 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105463:	f3 0f 1e fb          	endbr32 
80105467:	55                   	push   %ebp
80105468:	89 e5                	mov    %esp,%ebp
8010546a:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010546d:	e8 07 fe ff ff       	call   80105279 <readeflags>
80105472:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105475:	e8 0f fe ff ff       	call   80105289 <cli>
  if(mycpu()->ncli == 0)
8010547a:	e8 b5 ef ff ff       	call   80104434 <mycpu>
8010547f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105485:	85 c0                	test   %eax,%eax
80105487:	75 14                	jne    8010549d <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80105489:	e8 a6 ef ff ff       	call   80104434 <mycpu>
8010548e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105491:	81 e2 00 02 00 00    	and    $0x200,%edx
80105497:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010549d:	e8 92 ef ff ff       	call   80104434 <mycpu>
801054a2:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054a8:	83 c2 01             	add    $0x1,%edx
801054ab:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801054b1:	90                   	nop
801054b2:	c9                   	leave  
801054b3:	c3                   	ret    

801054b4 <popcli>:

void
popcli(void)
{
801054b4:	f3 0f 1e fb          	endbr32 
801054b8:	55                   	push   %ebp
801054b9:	89 e5                	mov    %esp,%ebp
801054bb:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801054be:	e8 b6 fd ff ff       	call   80105279 <readeflags>
801054c3:	25 00 02 00 00       	and    $0x200,%eax
801054c8:	85 c0                	test   %eax,%eax
801054ca:	74 0d                	je     801054d9 <popcli+0x25>
    panic("popcli - interruptible");
801054cc:	83 ec 0c             	sub    $0xc,%esp
801054cf:	68 96 96 10 80       	push   $0x80109696
801054d4:	e8 2f b1 ff ff       	call   80100608 <panic>
  if(--mycpu()->ncli < 0)
801054d9:	e8 56 ef ff ff       	call   80104434 <mycpu>
801054de:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054e4:	83 ea 01             	sub    $0x1,%edx
801054e7:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801054ed:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054f3:	85 c0                	test   %eax,%eax
801054f5:	79 0d                	jns    80105504 <popcli+0x50>
    panic("popcli");
801054f7:	83 ec 0c             	sub    $0xc,%esp
801054fa:	68 ad 96 10 80       	push   $0x801096ad
801054ff:	e8 04 b1 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105504:	e8 2b ef ff ff       	call   80104434 <mycpu>
80105509:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010550f:	85 c0                	test   %eax,%eax
80105511:	75 14                	jne    80105527 <popcli+0x73>
80105513:	e8 1c ef ff ff       	call   80104434 <mycpu>
80105518:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010551e:	85 c0                	test   %eax,%eax
80105520:	74 05                	je     80105527 <popcli+0x73>
    sti();
80105522:	e8 69 fd ff ff       	call   80105290 <sti>
}
80105527:	90                   	nop
80105528:	c9                   	leave  
80105529:	c3                   	ret    

8010552a <stosb>:
{
8010552a:	55                   	push   %ebp
8010552b:	89 e5                	mov    %esp,%ebp
8010552d:	57                   	push   %edi
8010552e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010552f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105532:	8b 55 10             	mov    0x10(%ebp),%edx
80105535:	8b 45 0c             	mov    0xc(%ebp),%eax
80105538:	89 cb                	mov    %ecx,%ebx
8010553a:	89 df                	mov    %ebx,%edi
8010553c:	89 d1                	mov    %edx,%ecx
8010553e:	fc                   	cld    
8010553f:	f3 aa                	rep stos %al,%es:(%edi)
80105541:	89 ca                	mov    %ecx,%edx
80105543:	89 fb                	mov    %edi,%ebx
80105545:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105548:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010554b:	90                   	nop
8010554c:	5b                   	pop    %ebx
8010554d:	5f                   	pop    %edi
8010554e:	5d                   	pop    %ebp
8010554f:	c3                   	ret    

80105550 <stosl>:
{
80105550:	55                   	push   %ebp
80105551:	89 e5                	mov    %esp,%ebp
80105553:	57                   	push   %edi
80105554:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105555:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105558:	8b 55 10             	mov    0x10(%ebp),%edx
8010555b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010555e:	89 cb                	mov    %ecx,%ebx
80105560:	89 df                	mov    %ebx,%edi
80105562:	89 d1                	mov    %edx,%ecx
80105564:	fc                   	cld    
80105565:	f3 ab                	rep stos %eax,%es:(%edi)
80105567:	89 ca                	mov    %ecx,%edx
80105569:	89 fb                	mov    %edi,%ebx
8010556b:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010556e:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105571:	90                   	nop
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
80105576:	f3 0f 1e fb          	endbr32 
8010557a:	55                   	push   %ebp
8010557b:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010557d:	8b 45 08             	mov    0x8(%ebp),%eax
80105580:	83 e0 03             	and    $0x3,%eax
80105583:	85 c0                	test   %eax,%eax
80105585:	75 43                	jne    801055ca <memset+0x54>
80105587:	8b 45 10             	mov    0x10(%ebp),%eax
8010558a:	83 e0 03             	and    $0x3,%eax
8010558d:	85 c0                	test   %eax,%eax
8010558f:	75 39                	jne    801055ca <memset+0x54>
    c &= 0xFF;
80105591:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105598:	8b 45 10             	mov    0x10(%ebp),%eax
8010559b:	c1 e8 02             	shr    $0x2,%eax
8010559e:	89 c1                	mov    %eax,%ecx
801055a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a3:	c1 e0 18             	shl    $0x18,%eax
801055a6:	89 c2                	mov    %eax,%edx
801055a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ab:	c1 e0 10             	shl    $0x10,%eax
801055ae:	09 c2                	or     %eax,%edx
801055b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b3:	c1 e0 08             	shl    $0x8,%eax
801055b6:	09 d0                	or     %edx,%eax
801055b8:	0b 45 0c             	or     0xc(%ebp),%eax
801055bb:	51                   	push   %ecx
801055bc:	50                   	push   %eax
801055bd:	ff 75 08             	pushl  0x8(%ebp)
801055c0:	e8 8b ff ff ff       	call   80105550 <stosl>
801055c5:	83 c4 0c             	add    $0xc,%esp
801055c8:	eb 12                	jmp    801055dc <memset+0x66>
  } else
    stosb(dst, c, n);
801055ca:	8b 45 10             	mov    0x10(%ebp),%eax
801055cd:	50                   	push   %eax
801055ce:	ff 75 0c             	pushl  0xc(%ebp)
801055d1:	ff 75 08             	pushl  0x8(%ebp)
801055d4:	e8 51 ff ff ff       	call   8010552a <stosb>
801055d9:	83 c4 0c             	add    $0xc,%esp
  return dst;
801055dc:	8b 45 08             	mov    0x8(%ebp),%eax
}
801055df:	c9                   	leave  
801055e0:	c3                   	ret    

801055e1 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801055e1:	f3 0f 1e fb          	endbr32 
801055e5:	55                   	push   %ebp
801055e6:	89 e5                	mov    %esp,%ebp
801055e8:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801055eb:	8b 45 08             	mov    0x8(%ebp),%eax
801055ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801055f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801055f7:	eb 30                	jmp    80105629 <memcmp+0x48>
    if(*s1 != *s2)
801055f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055fc:	0f b6 10             	movzbl (%eax),%edx
801055ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105602:	0f b6 00             	movzbl (%eax),%eax
80105605:	38 c2                	cmp    %al,%dl
80105607:	74 18                	je     80105621 <memcmp+0x40>
      return *s1 - *s2;
80105609:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010560c:	0f b6 00             	movzbl (%eax),%eax
8010560f:	0f b6 d0             	movzbl %al,%edx
80105612:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105615:	0f b6 00             	movzbl (%eax),%eax
80105618:	0f b6 c0             	movzbl %al,%eax
8010561b:	29 c2                	sub    %eax,%edx
8010561d:	89 d0                	mov    %edx,%eax
8010561f:	eb 1a                	jmp    8010563b <memcmp+0x5a>
    s1++, s2++;
80105621:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105625:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105629:	8b 45 10             	mov    0x10(%ebp),%eax
8010562c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010562f:	89 55 10             	mov    %edx,0x10(%ebp)
80105632:	85 c0                	test   %eax,%eax
80105634:	75 c3                	jne    801055f9 <memcmp+0x18>
  }

  return 0;
80105636:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010563b:	c9                   	leave  
8010563c:	c3                   	ret    

8010563d <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010563d:	f3 0f 1e fb          	endbr32 
80105641:	55                   	push   %ebp
80105642:	89 e5                	mov    %esp,%ebp
80105644:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105647:	8b 45 0c             	mov    0xc(%ebp),%eax
8010564a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010564d:	8b 45 08             	mov    0x8(%ebp),%eax
80105650:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105653:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105656:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105659:	73 54                	jae    801056af <memmove+0x72>
8010565b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010565e:	8b 45 10             	mov    0x10(%ebp),%eax
80105661:	01 d0                	add    %edx,%eax
80105663:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105666:	73 47                	jae    801056af <memmove+0x72>
    s += n;
80105668:	8b 45 10             	mov    0x10(%ebp),%eax
8010566b:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010566e:	8b 45 10             	mov    0x10(%ebp),%eax
80105671:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105674:	eb 13                	jmp    80105689 <memmove+0x4c>
      *--d = *--s;
80105676:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010567a:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010567e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105681:	0f b6 10             	movzbl (%eax),%edx
80105684:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105687:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105689:	8b 45 10             	mov    0x10(%ebp),%eax
8010568c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010568f:	89 55 10             	mov    %edx,0x10(%ebp)
80105692:	85 c0                	test   %eax,%eax
80105694:	75 e0                	jne    80105676 <memmove+0x39>
  if(s < d && s + n > d){
80105696:	eb 24                	jmp    801056bc <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105698:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010569b:	8d 42 01             	lea    0x1(%edx),%eax
8010569e:	89 45 fc             	mov    %eax,-0x4(%ebp)
801056a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056a4:	8d 48 01             	lea    0x1(%eax),%ecx
801056a7:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801056aa:	0f b6 12             	movzbl (%edx),%edx
801056ad:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801056af:	8b 45 10             	mov    0x10(%ebp),%eax
801056b2:	8d 50 ff             	lea    -0x1(%eax),%edx
801056b5:	89 55 10             	mov    %edx,0x10(%ebp)
801056b8:	85 c0                	test   %eax,%eax
801056ba:	75 dc                	jne    80105698 <memmove+0x5b>

  return dst;
801056bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
801056bf:	c9                   	leave  
801056c0:	c3                   	ret    

801056c1 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801056c1:	f3 0f 1e fb          	endbr32 
801056c5:	55                   	push   %ebp
801056c6:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801056c8:	ff 75 10             	pushl  0x10(%ebp)
801056cb:	ff 75 0c             	pushl  0xc(%ebp)
801056ce:	ff 75 08             	pushl  0x8(%ebp)
801056d1:	e8 67 ff ff ff       	call   8010563d <memmove>
801056d6:	83 c4 0c             	add    $0xc,%esp
}
801056d9:	c9                   	leave  
801056da:	c3                   	ret    

801056db <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801056db:	f3 0f 1e fb          	endbr32 
801056df:	55                   	push   %ebp
801056e0:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801056e2:	eb 0c                	jmp    801056f0 <strncmp+0x15>
    n--, p++, q++;
801056e4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056e8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801056ec:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801056f0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056f4:	74 1a                	je     80105710 <strncmp+0x35>
801056f6:	8b 45 08             	mov    0x8(%ebp),%eax
801056f9:	0f b6 00             	movzbl (%eax),%eax
801056fc:	84 c0                	test   %al,%al
801056fe:	74 10                	je     80105710 <strncmp+0x35>
80105700:	8b 45 08             	mov    0x8(%ebp),%eax
80105703:	0f b6 10             	movzbl (%eax),%edx
80105706:	8b 45 0c             	mov    0xc(%ebp),%eax
80105709:	0f b6 00             	movzbl (%eax),%eax
8010570c:	38 c2                	cmp    %al,%dl
8010570e:	74 d4                	je     801056e4 <strncmp+0x9>
  if(n == 0)
80105710:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105714:	75 07                	jne    8010571d <strncmp+0x42>
    return 0;
80105716:	b8 00 00 00 00       	mov    $0x0,%eax
8010571b:	eb 16                	jmp    80105733 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
8010571d:	8b 45 08             	mov    0x8(%ebp),%eax
80105720:	0f b6 00             	movzbl (%eax),%eax
80105723:	0f b6 d0             	movzbl %al,%edx
80105726:	8b 45 0c             	mov    0xc(%ebp),%eax
80105729:	0f b6 00             	movzbl (%eax),%eax
8010572c:	0f b6 c0             	movzbl %al,%eax
8010572f:	29 c2                	sub    %eax,%edx
80105731:	89 d0                	mov    %edx,%eax
}
80105733:	5d                   	pop    %ebp
80105734:	c3                   	ret    

80105735 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105735:	f3 0f 1e fb          	endbr32 
80105739:	55                   	push   %ebp
8010573a:	89 e5                	mov    %esp,%ebp
8010573c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010573f:	8b 45 08             	mov    0x8(%ebp),%eax
80105742:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105745:	90                   	nop
80105746:	8b 45 10             	mov    0x10(%ebp),%eax
80105749:	8d 50 ff             	lea    -0x1(%eax),%edx
8010574c:	89 55 10             	mov    %edx,0x10(%ebp)
8010574f:	85 c0                	test   %eax,%eax
80105751:	7e 2c                	jle    8010577f <strncpy+0x4a>
80105753:	8b 55 0c             	mov    0xc(%ebp),%edx
80105756:	8d 42 01             	lea    0x1(%edx),%eax
80105759:	89 45 0c             	mov    %eax,0xc(%ebp)
8010575c:	8b 45 08             	mov    0x8(%ebp),%eax
8010575f:	8d 48 01             	lea    0x1(%eax),%ecx
80105762:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105765:	0f b6 12             	movzbl (%edx),%edx
80105768:	88 10                	mov    %dl,(%eax)
8010576a:	0f b6 00             	movzbl (%eax),%eax
8010576d:	84 c0                	test   %al,%al
8010576f:	75 d5                	jne    80105746 <strncpy+0x11>
    ;
  while(n-- > 0)
80105771:	eb 0c                	jmp    8010577f <strncpy+0x4a>
    *s++ = 0;
80105773:	8b 45 08             	mov    0x8(%ebp),%eax
80105776:	8d 50 01             	lea    0x1(%eax),%edx
80105779:	89 55 08             	mov    %edx,0x8(%ebp)
8010577c:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010577f:	8b 45 10             	mov    0x10(%ebp),%eax
80105782:	8d 50 ff             	lea    -0x1(%eax),%edx
80105785:	89 55 10             	mov    %edx,0x10(%ebp)
80105788:	85 c0                	test   %eax,%eax
8010578a:	7f e7                	jg     80105773 <strncpy+0x3e>
  return os;
8010578c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010578f:	c9                   	leave  
80105790:	c3                   	ret    

80105791 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105791:	f3 0f 1e fb          	endbr32 
80105795:	55                   	push   %ebp
80105796:	89 e5                	mov    %esp,%ebp
80105798:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010579b:	8b 45 08             	mov    0x8(%ebp),%eax
8010579e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801057a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057a5:	7f 05                	jg     801057ac <safestrcpy+0x1b>
    return os;
801057a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057aa:	eb 31                	jmp    801057dd <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801057ac:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057b0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057b4:	7e 1e                	jle    801057d4 <safestrcpy+0x43>
801057b6:	8b 55 0c             	mov    0xc(%ebp),%edx
801057b9:	8d 42 01             	lea    0x1(%edx),%eax
801057bc:	89 45 0c             	mov    %eax,0xc(%ebp)
801057bf:	8b 45 08             	mov    0x8(%ebp),%eax
801057c2:	8d 48 01             	lea    0x1(%eax),%ecx
801057c5:	89 4d 08             	mov    %ecx,0x8(%ebp)
801057c8:	0f b6 12             	movzbl (%edx),%edx
801057cb:	88 10                	mov    %dl,(%eax)
801057cd:	0f b6 00             	movzbl (%eax),%eax
801057d0:	84 c0                	test   %al,%al
801057d2:	75 d8                	jne    801057ac <safestrcpy+0x1b>
    ;
  *s = 0;
801057d4:	8b 45 08             	mov    0x8(%ebp),%eax
801057d7:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801057da:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057dd:	c9                   	leave  
801057de:	c3                   	ret    

801057df <strlen>:

int
strlen(const char *s)
{
801057df:	f3 0f 1e fb          	endbr32 
801057e3:	55                   	push   %ebp
801057e4:	89 e5                	mov    %esp,%ebp
801057e6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801057e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057f0:	eb 04                	jmp    801057f6 <strlen+0x17>
801057f2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057f6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057f9:	8b 45 08             	mov    0x8(%ebp),%eax
801057fc:	01 d0                	add    %edx,%eax
801057fe:	0f b6 00             	movzbl (%eax),%eax
80105801:	84 c0                	test   %al,%al
80105803:	75 ed                	jne    801057f2 <strlen+0x13>
    ;
  return n;
80105805:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105808:	c9                   	leave  
80105809:	c3                   	ret    

8010580a <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010580a:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010580e:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80105812:	55                   	push   %ebp
  pushl %ebx
80105813:	53                   	push   %ebx
  pushl %esi
80105814:	56                   	push   %esi
  pushl %edi
80105815:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105816:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105818:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
8010581a:	5f                   	pop    %edi
  popl %esi
8010581b:	5e                   	pop    %esi
  popl %ebx
8010581c:	5b                   	pop    %ebx
  popl %ebp
8010581d:	5d                   	pop    %ebp
  ret
8010581e:	c3                   	ret    

8010581f <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010581f:	f3 0f 1e fb          	endbr32 
80105823:	55                   	push   %ebp
80105824:	89 e5                	mov    %esp,%ebp
80105826:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105829:	e8 82 ec ff ff       	call   801044b0 <myproc>
8010582e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105834:	8b 00                	mov    (%eax),%eax
80105836:	39 45 08             	cmp    %eax,0x8(%ebp)
80105839:	73 0f                	jae    8010584a <fetchint+0x2b>
8010583b:	8b 45 08             	mov    0x8(%ebp),%eax
8010583e:	8d 50 04             	lea    0x4(%eax),%edx
80105841:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105844:	8b 00                	mov    (%eax),%eax
80105846:	39 c2                	cmp    %eax,%edx
80105848:	76 07                	jbe    80105851 <fetchint+0x32>
    return -1;
8010584a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010584f:	eb 0f                	jmp    80105860 <fetchint+0x41>
  *ip = *(int*)(addr);
80105851:	8b 45 08             	mov    0x8(%ebp),%eax
80105854:	8b 10                	mov    (%eax),%edx
80105856:	8b 45 0c             	mov    0xc(%ebp),%eax
80105859:	89 10                	mov    %edx,(%eax)
  return 0;
8010585b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105860:	c9                   	leave  
80105861:	c3                   	ret    

80105862 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105862:	f3 0f 1e fb          	endbr32 
80105866:	55                   	push   %ebp
80105867:	89 e5                	mov    %esp,%ebp
80105869:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010586c:	e8 3f ec ff ff       	call   801044b0 <myproc>
80105871:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105874:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105877:	8b 00                	mov    (%eax),%eax
80105879:	39 45 08             	cmp    %eax,0x8(%ebp)
8010587c:	72 07                	jb     80105885 <fetchstr+0x23>
    return -1;
8010587e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105883:	eb 43                	jmp    801058c8 <fetchstr+0x66>
  *pp = (char*)addr;
80105885:	8b 55 08             	mov    0x8(%ebp),%edx
80105888:	8b 45 0c             	mov    0xc(%ebp),%eax
8010588b:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010588d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105890:	8b 00                	mov    (%eax),%eax
80105892:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105895:	8b 45 0c             	mov    0xc(%ebp),%eax
80105898:	8b 00                	mov    (%eax),%eax
8010589a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010589d:	eb 1c                	jmp    801058bb <fetchstr+0x59>
    if(*s == 0)
8010589f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a2:	0f b6 00             	movzbl (%eax),%eax
801058a5:	84 c0                	test   %al,%al
801058a7:	75 0e                	jne    801058b7 <fetchstr+0x55>
      return s - *pp;
801058a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801058ac:	8b 00                	mov    (%eax),%eax
801058ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058b1:	29 c2                	sub    %eax,%edx
801058b3:	89 d0                	mov    %edx,%eax
801058b5:	eb 11                	jmp    801058c8 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
801058b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801058bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058be:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801058c1:	72 dc                	jb     8010589f <fetchstr+0x3d>
  }
  return -1;
801058c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058c8:	c9                   	leave  
801058c9:	c3                   	ret    

801058ca <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801058ca:	f3 0f 1e fb          	endbr32 
801058ce:	55                   	push   %ebp
801058cf:	89 e5                	mov    %esp,%ebp
801058d1:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801058d4:	e8 d7 eb ff ff       	call   801044b0 <myproc>
801058d9:	8b 40 1c             	mov    0x1c(%eax),%eax
801058dc:	8b 40 44             	mov    0x44(%eax),%eax
801058df:	8b 55 08             	mov    0x8(%ebp),%edx
801058e2:	c1 e2 02             	shl    $0x2,%edx
801058e5:	01 d0                	add    %edx,%eax
801058e7:	83 c0 04             	add    $0x4,%eax
801058ea:	83 ec 08             	sub    $0x8,%esp
801058ed:	ff 75 0c             	pushl  0xc(%ebp)
801058f0:	50                   	push   %eax
801058f1:	e8 29 ff ff ff       	call   8010581f <fetchint>
801058f6:	83 c4 10             	add    $0x10,%esp
}
801058f9:	c9                   	leave  
801058fa:	c3                   	ret    

801058fb <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801058fb:	f3 0f 1e fb          	endbr32 
801058ff:	55                   	push   %ebp
80105900:	89 e5                	mov    %esp,%ebp
80105902:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105905:	e8 a6 eb ff ff       	call   801044b0 <myproc>
8010590a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010590d:	83 ec 08             	sub    $0x8,%esp
80105910:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105913:	50                   	push   %eax
80105914:	ff 75 08             	pushl  0x8(%ebp)
80105917:	e8 ae ff ff ff       	call   801058ca <argint>
8010591c:	83 c4 10             	add    $0x10,%esp
8010591f:	85 c0                	test   %eax,%eax
80105921:	79 07                	jns    8010592a <argptr+0x2f>
    return -1;
80105923:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105928:	eb 3b                	jmp    80105965 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010592a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010592e:	78 1f                	js     8010594f <argptr+0x54>
80105930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105933:	8b 00                	mov    (%eax),%eax
80105935:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105938:	39 d0                	cmp    %edx,%eax
8010593a:	76 13                	jbe    8010594f <argptr+0x54>
8010593c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593f:	89 c2                	mov    %eax,%edx
80105941:	8b 45 10             	mov    0x10(%ebp),%eax
80105944:	01 c2                	add    %eax,%edx
80105946:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105949:	8b 00                	mov    (%eax),%eax
8010594b:	39 c2                	cmp    %eax,%edx
8010594d:	76 07                	jbe    80105956 <argptr+0x5b>
    return -1;
8010594f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105954:	eb 0f                	jmp    80105965 <argptr+0x6a>
  *pp = (char*)i;
80105956:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105959:	89 c2                	mov    %eax,%edx
8010595b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010595e:	89 10                	mov    %edx,(%eax)
  return 0;
80105960:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105965:	c9                   	leave  
80105966:	c3                   	ret    

80105967 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105967:	f3 0f 1e fb          	endbr32 
8010596b:	55                   	push   %ebp
8010596c:	89 e5                	mov    %esp,%ebp
8010596e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105971:	83 ec 08             	sub    $0x8,%esp
80105974:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105977:	50                   	push   %eax
80105978:	ff 75 08             	pushl  0x8(%ebp)
8010597b:	e8 4a ff ff ff       	call   801058ca <argint>
80105980:	83 c4 10             	add    $0x10,%esp
80105983:	85 c0                	test   %eax,%eax
80105985:	79 07                	jns    8010598e <argstr+0x27>
    return -1;
80105987:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010598c:	eb 12                	jmp    801059a0 <argstr+0x39>
  return fetchstr(addr, pp);
8010598e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105991:	83 ec 08             	sub    $0x8,%esp
80105994:	ff 75 0c             	pushl  0xc(%ebp)
80105997:	50                   	push   %eax
80105998:	e8 c5 fe ff ff       	call   80105862 <fetchstr>
8010599d:	83 c4 10             	add    $0x10,%esp
}
801059a0:	c9                   	leave  
801059a1:	c3                   	ret    

801059a2 <syscall>:
[SYS_dump_rawphymem] sys_dump_rawphymem,
};

void
syscall(void)
{
801059a2:	f3 0f 1e fb          	endbr32 
801059a6:	55                   	push   %ebp
801059a7:	89 e5                	mov    %esp,%ebp
801059a9:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801059ac:	e8 ff ea ff ff       	call   801044b0 <myproc>
801059b1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801059b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b7:	8b 40 1c             	mov    0x1c(%eax),%eax
801059ba:	8b 40 1c             	mov    0x1c(%eax),%eax
801059bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801059c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059c4:	7e 2f                	jle    801059f5 <syscall+0x53>
801059c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059c9:	83 f8 18             	cmp    $0x18,%eax
801059cc:	77 27                	ja     801059f5 <syscall+0x53>
801059ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d1:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801059d8:	85 c0                	test   %eax,%eax
801059da:	74 19                	je     801059f5 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
801059dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059df:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801059e6:	ff d0                	call   *%eax
801059e8:	89 c2                	mov    %eax,%edx
801059ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ed:	8b 40 1c             	mov    0x1c(%eax),%eax
801059f0:	89 50 1c             	mov    %edx,0x1c(%eax)
801059f3:	eb 2c                	jmp    80105a21 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801059f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f8:	8d 50 70             	lea    0x70(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801059fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059fe:	8b 40 10             	mov    0x10(%eax),%eax
80105a01:	ff 75 f0             	pushl  -0x10(%ebp)
80105a04:	52                   	push   %edx
80105a05:	50                   	push   %eax
80105a06:	68 b4 96 10 80       	push   $0x801096b4
80105a0b:	e8 08 aa ff ff       	call   80100418 <cprintf>
80105a10:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a16:	8b 40 1c             	mov    0x1c(%eax),%eax
80105a19:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a20:	90                   	nop
80105a21:	90                   	nop
80105a22:	c9                   	leave  
80105a23:	c3                   	ret    

80105a24 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a24:	f3 0f 1e fb          	endbr32 
80105a28:	55                   	push   %ebp
80105a29:	89 e5                	mov    %esp,%ebp
80105a2b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a2e:	83 ec 08             	sub    $0x8,%esp
80105a31:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a34:	50                   	push   %eax
80105a35:	ff 75 08             	pushl  0x8(%ebp)
80105a38:	e8 8d fe ff ff       	call   801058ca <argint>
80105a3d:	83 c4 10             	add    $0x10,%esp
80105a40:	85 c0                	test   %eax,%eax
80105a42:	79 07                	jns    80105a4b <argfd+0x27>
    return -1;
80105a44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a49:	eb 4f                	jmp    80105a9a <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a4e:	85 c0                	test   %eax,%eax
80105a50:	78 20                	js     80105a72 <argfd+0x4e>
80105a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a55:	83 f8 0f             	cmp    $0xf,%eax
80105a58:	7f 18                	jg     80105a72 <argfd+0x4e>
80105a5a:	e8 51 ea ff ff       	call   801044b0 <myproc>
80105a5f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a62:	83 c2 08             	add    $0x8,%edx
80105a65:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105a69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a70:	75 07                	jne    80105a79 <argfd+0x55>
    return -1;
80105a72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a77:	eb 21                	jmp    80105a9a <argfd+0x76>
  if(pfd)
80105a79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a7d:	74 08                	je     80105a87 <argfd+0x63>
    *pfd = fd;
80105a7f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a82:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a85:	89 10                	mov    %edx,(%eax)
  if(pf)
80105a87:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a8b:	74 08                	je     80105a95 <argfd+0x71>
    *pf = f;
80105a8d:	8b 45 10             	mov    0x10(%ebp),%eax
80105a90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a93:	89 10                	mov    %edx,(%eax)
  return 0;
80105a95:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a9a:	c9                   	leave  
80105a9b:	c3                   	ret    

80105a9c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105a9c:	f3 0f 1e fb          	endbr32 
80105aa0:	55                   	push   %ebp
80105aa1:	89 e5                	mov    %esp,%ebp
80105aa3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105aa6:	e8 05 ea ff ff       	call   801044b0 <myproc>
80105aab:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105aae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ab5:	eb 2a                	jmp    80105ae1 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105abd:	83 c2 08             	add    $0x8,%edx
80105ac0:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105ac4:	85 c0                	test   %eax,%eax
80105ac6:	75 15                	jne    80105add <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105acb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ace:	8d 4a 08             	lea    0x8(%edx),%ecx
80105ad1:	8b 55 08             	mov    0x8(%ebp),%edx
80105ad4:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
      return fd;
80105ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105adb:	eb 0f                	jmp    80105aec <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105add:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105ae1:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105ae5:	7e d0                	jle    80105ab7 <fdalloc+0x1b>
    }
  }
  return -1;
80105ae7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105aec:	c9                   	leave  
80105aed:	c3                   	ret    

80105aee <sys_dup>:

int
sys_dup(void)
{
80105aee:	f3 0f 1e fb          	endbr32 
80105af2:	55                   	push   %ebp
80105af3:	89 e5                	mov    %esp,%ebp
80105af5:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105af8:	83 ec 04             	sub    $0x4,%esp
80105afb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105afe:	50                   	push   %eax
80105aff:	6a 00                	push   $0x0
80105b01:	6a 00                	push   $0x0
80105b03:	e8 1c ff ff ff       	call   80105a24 <argfd>
80105b08:	83 c4 10             	add    $0x10,%esp
80105b0b:	85 c0                	test   %eax,%eax
80105b0d:	79 07                	jns    80105b16 <sys_dup+0x28>
    return -1;
80105b0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b14:	eb 31                	jmp    80105b47 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b19:	83 ec 0c             	sub    $0xc,%esp
80105b1c:	50                   	push   %eax
80105b1d:	e8 7a ff ff ff       	call   80105a9c <fdalloc>
80105b22:	83 c4 10             	add    $0x10,%esp
80105b25:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b28:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b2c:	79 07                	jns    80105b35 <sys_dup+0x47>
    return -1;
80105b2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b33:	eb 12                	jmp    80105b47 <sys_dup+0x59>
  filedup(f);
80105b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b38:	83 ec 0c             	sub    $0xc,%esp
80105b3b:	50                   	push   %eax
80105b3c:	e8 0c b6 ff ff       	call   8010114d <filedup>
80105b41:	83 c4 10             	add    $0x10,%esp
  return fd;
80105b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b47:	c9                   	leave  
80105b48:	c3                   	ret    

80105b49 <sys_read>:

int
sys_read(void)
{
80105b49:	f3 0f 1e fb          	endbr32 
80105b4d:	55                   	push   %ebp
80105b4e:	89 e5                	mov    %esp,%ebp
80105b50:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b53:	83 ec 04             	sub    $0x4,%esp
80105b56:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b59:	50                   	push   %eax
80105b5a:	6a 00                	push   $0x0
80105b5c:	6a 00                	push   $0x0
80105b5e:	e8 c1 fe ff ff       	call   80105a24 <argfd>
80105b63:	83 c4 10             	add    $0x10,%esp
80105b66:	85 c0                	test   %eax,%eax
80105b68:	78 2e                	js     80105b98 <sys_read+0x4f>
80105b6a:	83 ec 08             	sub    $0x8,%esp
80105b6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b70:	50                   	push   %eax
80105b71:	6a 02                	push   $0x2
80105b73:	e8 52 fd ff ff       	call   801058ca <argint>
80105b78:	83 c4 10             	add    $0x10,%esp
80105b7b:	85 c0                	test   %eax,%eax
80105b7d:	78 19                	js     80105b98 <sys_read+0x4f>
80105b7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b82:	83 ec 04             	sub    $0x4,%esp
80105b85:	50                   	push   %eax
80105b86:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b89:	50                   	push   %eax
80105b8a:	6a 01                	push   $0x1
80105b8c:	e8 6a fd ff ff       	call   801058fb <argptr>
80105b91:	83 c4 10             	add    $0x10,%esp
80105b94:	85 c0                	test   %eax,%eax
80105b96:	79 07                	jns    80105b9f <sys_read+0x56>
    return -1;
80105b98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b9d:	eb 17                	jmp    80105bb6 <sys_read+0x6d>
  return fileread(f, p, n);
80105b9f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ba2:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba8:	83 ec 04             	sub    $0x4,%esp
80105bab:	51                   	push   %ecx
80105bac:	52                   	push   %edx
80105bad:	50                   	push   %eax
80105bae:	e8 36 b7 ff ff       	call   801012e9 <fileread>
80105bb3:	83 c4 10             	add    $0x10,%esp
}
80105bb6:	c9                   	leave  
80105bb7:	c3                   	ret    

80105bb8 <sys_write>:

int
sys_write(void)
{
80105bb8:	f3 0f 1e fb          	endbr32 
80105bbc:	55                   	push   %ebp
80105bbd:	89 e5                	mov    %esp,%ebp
80105bbf:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105bc2:	83 ec 04             	sub    $0x4,%esp
80105bc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bc8:	50                   	push   %eax
80105bc9:	6a 00                	push   $0x0
80105bcb:	6a 00                	push   $0x0
80105bcd:	e8 52 fe ff ff       	call   80105a24 <argfd>
80105bd2:	83 c4 10             	add    $0x10,%esp
80105bd5:	85 c0                	test   %eax,%eax
80105bd7:	78 2e                	js     80105c07 <sys_write+0x4f>
80105bd9:	83 ec 08             	sub    $0x8,%esp
80105bdc:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bdf:	50                   	push   %eax
80105be0:	6a 02                	push   $0x2
80105be2:	e8 e3 fc ff ff       	call   801058ca <argint>
80105be7:	83 c4 10             	add    $0x10,%esp
80105bea:	85 c0                	test   %eax,%eax
80105bec:	78 19                	js     80105c07 <sys_write+0x4f>
80105bee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf1:	83 ec 04             	sub    $0x4,%esp
80105bf4:	50                   	push   %eax
80105bf5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bf8:	50                   	push   %eax
80105bf9:	6a 01                	push   $0x1
80105bfb:	e8 fb fc ff ff       	call   801058fb <argptr>
80105c00:	83 c4 10             	add    $0x10,%esp
80105c03:	85 c0                	test   %eax,%eax
80105c05:	79 07                	jns    80105c0e <sys_write+0x56>
    return -1;
80105c07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c0c:	eb 17                	jmp    80105c25 <sys_write+0x6d>
  return filewrite(f, p, n);
80105c0e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c11:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c17:	83 ec 04             	sub    $0x4,%esp
80105c1a:	51                   	push   %ecx
80105c1b:	52                   	push   %edx
80105c1c:	50                   	push   %eax
80105c1d:	e8 83 b7 ff ff       	call   801013a5 <filewrite>
80105c22:	83 c4 10             	add    $0x10,%esp
}
80105c25:	c9                   	leave  
80105c26:	c3                   	ret    

80105c27 <sys_close>:

int
sys_close(void)
{
80105c27:	f3 0f 1e fb          	endbr32 
80105c2b:	55                   	push   %ebp
80105c2c:	89 e5                	mov    %esp,%ebp
80105c2e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105c31:	83 ec 04             	sub    $0x4,%esp
80105c34:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c37:	50                   	push   %eax
80105c38:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c3b:	50                   	push   %eax
80105c3c:	6a 00                	push   $0x0
80105c3e:	e8 e1 fd ff ff       	call   80105a24 <argfd>
80105c43:	83 c4 10             	add    $0x10,%esp
80105c46:	85 c0                	test   %eax,%eax
80105c48:	79 07                	jns    80105c51 <sys_close+0x2a>
    return -1;
80105c4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c4f:	eb 27                	jmp    80105c78 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105c51:	e8 5a e8 ff ff       	call   801044b0 <myproc>
80105c56:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c59:	83 c2 08             	add    $0x8,%edx
80105c5c:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80105c63:	00 
  fileclose(f);
80105c64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c67:	83 ec 0c             	sub    $0xc,%esp
80105c6a:	50                   	push   %eax
80105c6b:	e8 32 b5 ff ff       	call   801011a2 <fileclose>
80105c70:	83 c4 10             	add    $0x10,%esp
  return 0;
80105c73:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c78:	c9                   	leave  
80105c79:	c3                   	ret    

80105c7a <sys_fstat>:

int
sys_fstat(void)
{
80105c7a:	f3 0f 1e fb          	endbr32 
80105c7e:	55                   	push   %ebp
80105c7f:	89 e5                	mov    %esp,%ebp
80105c81:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105c84:	83 ec 04             	sub    $0x4,%esp
80105c87:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c8a:	50                   	push   %eax
80105c8b:	6a 00                	push   $0x0
80105c8d:	6a 00                	push   $0x0
80105c8f:	e8 90 fd ff ff       	call   80105a24 <argfd>
80105c94:	83 c4 10             	add    $0x10,%esp
80105c97:	85 c0                	test   %eax,%eax
80105c99:	78 17                	js     80105cb2 <sys_fstat+0x38>
80105c9b:	83 ec 04             	sub    $0x4,%esp
80105c9e:	6a 14                	push   $0x14
80105ca0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ca3:	50                   	push   %eax
80105ca4:	6a 01                	push   $0x1
80105ca6:	e8 50 fc ff ff       	call   801058fb <argptr>
80105cab:	83 c4 10             	add    $0x10,%esp
80105cae:	85 c0                	test   %eax,%eax
80105cb0:	79 07                	jns    80105cb9 <sys_fstat+0x3f>
    return -1;
80105cb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb7:	eb 13                	jmp    80105ccc <sys_fstat+0x52>
  return filestat(f, st);
80105cb9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cbf:	83 ec 08             	sub    $0x8,%esp
80105cc2:	52                   	push   %edx
80105cc3:	50                   	push   %eax
80105cc4:	e8 c5 b5 ff ff       	call   8010128e <filestat>
80105cc9:	83 c4 10             	add    $0x10,%esp
}
80105ccc:	c9                   	leave  
80105ccd:	c3                   	ret    

80105cce <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105cce:	f3 0f 1e fb          	endbr32 
80105cd2:	55                   	push   %ebp
80105cd3:	89 e5                	mov    %esp,%ebp
80105cd5:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105cd8:	83 ec 08             	sub    $0x8,%esp
80105cdb:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105cde:	50                   	push   %eax
80105cdf:	6a 00                	push   $0x0
80105ce1:	e8 81 fc ff ff       	call   80105967 <argstr>
80105ce6:	83 c4 10             	add    $0x10,%esp
80105ce9:	85 c0                	test   %eax,%eax
80105ceb:	78 15                	js     80105d02 <sys_link+0x34>
80105ced:	83 ec 08             	sub    $0x8,%esp
80105cf0:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105cf3:	50                   	push   %eax
80105cf4:	6a 01                	push   $0x1
80105cf6:	e8 6c fc ff ff       	call   80105967 <argstr>
80105cfb:	83 c4 10             	add    $0x10,%esp
80105cfe:	85 c0                	test   %eax,%eax
80105d00:	79 0a                	jns    80105d0c <sys_link+0x3e>
    return -1;
80105d02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d07:	e9 68 01 00 00       	jmp    80105e74 <sys_link+0x1a6>

  begin_op();
80105d0c:	e8 e0 d9 ff ff       	call   801036f1 <begin_op>
  if((ip = namei(old)) == 0){
80105d11:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d14:	83 ec 0c             	sub    $0xc,%esp
80105d17:	50                   	push   %eax
80105d18:	e8 70 c9 ff ff       	call   8010268d <namei>
80105d1d:	83 c4 10             	add    $0x10,%esp
80105d20:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d27:	75 0f                	jne    80105d38 <sys_link+0x6a>
    end_op();
80105d29:	e8 53 da ff ff       	call   80103781 <end_op>
    return -1;
80105d2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d33:	e9 3c 01 00 00       	jmp    80105e74 <sys_link+0x1a6>
  }

  ilock(ip);
80105d38:	83 ec 0c             	sub    $0xc,%esp
80105d3b:	ff 75 f4             	pushl  -0xc(%ebp)
80105d3e:	e8 df bd ff ff       	call   80101b22 <ilock>
80105d43:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d49:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d4d:	66 83 f8 01          	cmp    $0x1,%ax
80105d51:	75 1d                	jne    80105d70 <sys_link+0xa2>
    iunlockput(ip);
80105d53:	83 ec 0c             	sub    $0xc,%esp
80105d56:	ff 75 f4             	pushl  -0xc(%ebp)
80105d59:	e8 01 c0 ff ff       	call   80101d5f <iunlockput>
80105d5e:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d61:	e8 1b da ff ff       	call   80103781 <end_op>
    return -1;
80105d66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6b:	e9 04 01 00 00       	jmp    80105e74 <sys_link+0x1a6>
  }

  ip->nlink++;
80105d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d73:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d77:	83 c0 01             	add    $0x1,%eax
80105d7a:	89 c2                	mov    %eax,%edx
80105d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7f:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d83:	83 ec 0c             	sub    $0xc,%esp
80105d86:	ff 75 f4             	pushl  -0xc(%ebp)
80105d89:	e8 ab bb ff ff       	call   80101939 <iupdate>
80105d8e:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105d91:	83 ec 0c             	sub    $0xc,%esp
80105d94:	ff 75 f4             	pushl  -0xc(%ebp)
80105d97:	e8 9d be ff ff       	call   80101c39 <iunlock>
80105d9c:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105d9f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105da2:	83 ec 08             	sub    $0x8,%esp
80105da5:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105da8:	52                   	push   %edx
80105da9:	50                   	push   %eax
80105daa:	e8 fe c8 ff ff       	call   801026ad <nameiparent>
80105daf:	83 c4 10             	add    $0x10,%esp
80105db2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105db5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105db9:	74 71                	je     80105e2c <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105dbb:	83 ec 0c             	sub    $0xc,%esp
80105dbe:	ff 75 f0             	pushl  -0x10(%ebp)
80105dc1:	e8 5c bd ff ff       	call   80101b22 <ilock>
80105dc6:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dcc:	8b 10                	mov    (%eax),%edx
80105dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd1:	8b 00                	mov    (%eax),%eax
80105dd3:	39 c2                	cmp    %eax,%edx
80105dd5:	75 1d                	jne    80105df4 <sys_link+0x126>
80105dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dda:	8b 40 04             	mov    0x4(%eax),%eax
80105ddd:	83 ec 04             	sub    $0x4,%esp
80105de0:	50                   	push   %eax
80105de1:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105de4:	50                   	push   %eax
80105de5:	ff 75 f0             	pushl  -0x10(%ebp)
80105de8:	e8 fd c5 ff ff       	call   801023ea <dirlink>
80105ded:	83 c4 10             	add    $0x10,%esp
80105df0:	85 c0                	test   %eax,%eax
80105df2:	79 10                	jns    80105e04 <sys_link+0x136>
    iunlockput(dp);
80105df4:	83 ec 0c             	sub    $0xc,%esp
80105df7:	ff 75 f0             	pushl  -0x10(%ebp)
80105dfa:	e8 60 bf ff ff       	call   80101d5f <iunlockput>
80105dff:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105e02:	eb 29                	jmp    80105e2d <sys_link+0x15f>
  }
  iunlockput(dp);
80105e04:	83 ec 0c             	sub    $0xc,%esp
80105e07:	ff 75 f0             	pushl  -0x10(%ebp)
80105e0a:	e8 50 bf ff ff       	call   80101d5f <iunlockput>
80105e0f:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105e12:	83 ec 0c             	sub    $0xc,%esp
80105e15:	ff 75 f4             	pushl  -0xc(%ebp)
80105e18:	e8 6e be ff ff       	call   80101c8b <iput>
80105e1d:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e20:	e8 5c d9 ff ff       	call   80103781 <end_op>

  return 0;
80105e25:	b8 00 00 00 00       	mov    $0x0,%eax
80105e2a:	eb 48                	jmp    80105e74 <sys_link+0x1a6>
    goto bad;
80105e2c:	90                   	nop

bad:
  ilock(ip);
80105e2d:	83 ec 0c             	sub    $0xc,%esp
80105e30:	ff 75 f4             	pushl  -0xc(%ebp)
80105e33:	e8 ea bc ff ff       	call   80101b22 <ilock>
80105e38:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e42:	83 e8 01             	sub    $0x1,%eax
80105e45:	89 c2                	mov    %eax,%edx
80105e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4a:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e4e:	83 ec 0c             	sub    $0xc,%esp
80105e51:	ff 75 f4             	pushl  -0xc(%ebp)
80105e54:	e8 e0 ba ff ff       	call   80101939 <iupdate>
80105e59:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e5c:	83 ec 0c             	sub    $0xc,%esp
80105e5f:	ff 75 f4             	pushl  -0xc(%ebp)
80105e62:	e8 f8 be ff ff       	call   80101d5f <iunlockput>
80105e67:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e6a:	e8 12 d9 ff ff       	call   80103781 <end_op>
  return -1;
80105e6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e74:	c9                   	leave  
80105e75:	c3                   	ret    

80105e76 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105e76:	f3 0f 1e fb          	endbr32 
80105e7a:	55                   	push   %ebp
80105e7b:	89 e5                	mov    %esp,%ebp
80105e7d:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e80:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105e87:	eb 40                	jmp    80105ec9 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8c:	6a 10                	push   $0x10
80105e8e:	50                   	push   %eax
80105e8f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e92:	50                   	push   %eax
80105e93:	ff 75 08             	pushl  0x8(%ebp)
80105e96:	e8 8f c1 ff ff       	call   8010202a <readi>
80105e9b:	83 c4 10             	add    $0x10,%esp
80105e9e:	83 f8 10             	cmp    $0x10,%eax
80105ea1:	74 0d                	je     80105eb0 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105ea3:	83 ec 0c             	sub    $0xc,%esp
80105ea6:	68 d0 96 10 80       	push   $0x801096d0
80105eab:	e8 58 a7 ff ff       	call   80100608 <panic>
    if(de.inum != 0)
80105eb0:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105eb4:	66 85 c0             	test   %ax,%ax
80105eb7:	74 07                	je     80105ec0 <isdirempty+0x4a>
      return 0;
80105eb9:	b8 00 00 00 00       	mov    $0x0,%eax
80105ebe:	eb 1b                	jmp    80105edb <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec3:	83 c0 10             	add    $0x10,%eax
80105ec6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80105ecc:	8b 50 58             	mov    0x58(%eax),%edx
80105ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed2:	39 c2                	cmp    %eax,%edx
80105ed4:	77 b3                	ja     80105e89 <isdirempty+0x13>
  }
  return 1;
80105ed6:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105edb:	c9                   	leave  
80105edc:	c3                   	ret    

80105edd <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105edd:	f3 0f 1e fb          	endbr32 
80105ee1:	55                   	push   %ebp
80105ee2:	89 e5                	mov    %esp,%ebp
80105ee4:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105ee7:	83 ec 08             	sub    $0x8,%esp
80105eea:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105eed:	50                   	push   %eax
80105eee:	6a 00                	push   $0x0
80105ef0:	e8 72 fa ff ff       	call   80105967 <argstr>
80105ef5:	83 c4 10             	add    $0x10,%esp
80105ef8:	85 c0                	test   %eax,%eax
80105efa:	79 0a                	jns    80105f06 <sys_unlink+0x29>
    return -1;
80105efc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f01:	e9 bf 01 00 00       	jmp    801060c5 <sys_unlink+0x1e8>

  begin_op();
80105f06:	e8 e6 d7 ff ff       	call   801036f1 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105f0b:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f0e:	83 ec 08             	sub    $0x8,%esp
80105f11:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f14:	52                   	push   %edx
80105f15:	50                   	push   %eax
80105f16:	e8 92 c7 ff ff       	call   801026ad <nameiparent>
80105f1b:	83 c4 10             	add    $0x10,%esp
80105f1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f25:	75 0f                	jne    80105f36 <sys_unlink+0x59>
    end_op();
80105f27:	e8 55 d8 ff ff       	call   80103781 <end_op>
    return -1;
80105f2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f31:	e9 8f 01 00 00       	jmp    801060c5 <sys_unlink+0x1e8>
  }

  ilock(dp);
80105f36:	83 ec 0c             	sub    $0xc,%esp
80105f39:	ff 75 f4             	pushl  -0xc(%ebp)
80105f3c:	e8 e1 bb ff ff       	call   80101b22 <ilock>
80105f41:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f44:	83 ec 08             	sub    $0x8,%esp
80105f47:	68 e2 96 10 80       	push   $0x801096e2
80105f4c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f4f:	50                   	push   %eax
80105f50:	e8 b8 c3 ff ff       	call   8010230d <namecmp>
80105f55:	83 c4 10             	add    $0x10,%esp
80105f58:	85 c0                	test   %eax,%eax
80105f5a:	0f 84 49 01 00 00    	je     801060a9 <sys_unlink+0x1cc>
80105f60:	83 ec 08             	sub    $0x8,%esp
80105f63:	68 e4 96 10 80       	push   $0x801096e4
80105f68:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f6b:	50                   	push   %eax
80105f6c:	e8 9c c3 ff ff       	call   8010230d <namecmp>
80105f71:	83 c4 10             	add    $0x10,%esp
80105f74:	85 c0                	test   %eax,%eax
80105f76:	0f 84 2d 01 00 00    	je     801060a9 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105f7c:	83 ec 04             	sub    $0x4,%esp
80105f7f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105f82:	50                   	push   %eax
80105f83:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f86:	50                   	push   %eax
80105f87:	ff 75 f4             	pushl  -0xc(%ebp)
80105f8a:	e8 9d c3 ff ff       	call   8010232c <dirlookup>
80105f8f:	83 c4 10             	add    $0x10,%esp
80105f92:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f95:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f99:	0f 84 0d 01 00 00    	je     801060ac <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105f9f:	83 ec 0c             	sub    $0xc,%esp
80105fa2:	ff 75 f0             	pushl  -0x10(%ebp)
80105fa5:	e8 78 bb ff ff       	call   80101b22 <ilock>
80105faa:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105fad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105fb4:	66 85 c0             	test   %ax,%ax
80105fb7:	7f 0d                	jg     80105fc6 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105fb9:	83 ec 0c             	sub    $0xc,%esp
80105fbc:	68 e7 96 10 80       	push   $0x801096e7
80105fc1:	e8 42 a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105fcd:	66 83 f8 01          	cmp    $0x1,%ax
80105fd1:	75 25                	jne    80105ff8 <sys_unlink+0x11b>
80105fd3:	83 ec 0c             	sub    $0xc,%esp
80105fd6:	ff 75 f0             	pushl  -0x10(%ebp)
80105fd9:	e8 98 fe ff ff       	call   80105e76 <isdirempty>
80105fde:	83 c4 10             	add    $0x10,%esp
80105fe1:	85 c0                	test   %eax,%eax
80105fe3:	75 13                	jne    80105ff8 <sys_unlink+0x11b>
    iunlockput(ip);
80105fe5:	83 ec 0c             	sub    $0xc,%esp
80105fe8:	ff 75 f0             	pushl  -0x10(%ebp)
80105feb:	e8 6f bd ff ff       	call   80101d5f <iunlockput>
80105ff0:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ff3:	e9 b5 00 00 00       	jmp    801060ad <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105ff8:	83 ec 04             	sub    $0x4,%esp
80105ffb:	6a 10                	push   $0x10
80105ffd:	6a 00                	push   $0x0
80105fff:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106002:	50                   	push   %eax
80106003:	e8 6e f5 ff ff       	call   80105576 <memset>
80106008:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010600b:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010600e:	6a 10                	push   $0x10
80106010:	50                   	push   %eax
80106011:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106014:	50                   	push   %eax
80106015:	ff 75 f4             	pushl  -0xc(%ebp)
80106018:	e8 66 c1 ff ff       	call   80102183 <writei>
8010601d:	83 c4 10             	add    $0x10,%esp
80106020:	83 f8 10             	cmp    $0x10,%eax
80106023:	74 0d                	je     80106032 <sys_unlink+0x155>
    panic("unlink: writei");
80106025:	83 ec 0c             	sub    $0xc,%esp
80106028:	68 f9 96 10 80       	push   $0x801096f9
8010602d:	e8 d6 a5 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR){
80106032:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106035:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106039:	66 83 f8 01          	cmp    $0x1,%ax
8010603d:	75 21                	jne    80106060 <sys_unlink+0x183>
    dp->nlink--;
8010603f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106042:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106046:	83 e8 01             	sub    $0x1,%eax
80106049:	89 c2                	mov    %eax,%edx
8010604b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010604e:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106052:	83 ec 0c             	sub    $0xc,%esp
80106055:	ff 75 f4             	pushl  -0xc(%ebp)
80106058:	e8 dc b8 ff ff       	call   80101939 <iupdate>
8010605d:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106060:	83 ec 0c             	sub    $0xc,%esp
80106063:	ff 75 f4             	pushl  -0xc(%ebp)
80106066:	e8 f4 bc ff ff       	call   80101d5f <iunlockput>
8010606b:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010606e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106071:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106075:	83 e8 01             	sub    $0x1,%eax
80106078:	89 c2                	mov    %eax,%edx
8010607a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010607d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80106081:	83 ec 0c             	sub    $0xc,%esp
80106084:	ff 75 f0             	pushl  -0x10(%ebp)
80106087:	e8 ad b8 ff ff       	call   80101939 <iupdate>
8010608c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010608f:	83 ec 0c             	sub    $0xc,%esp
80106092:	ff 75 f0             	pushl  -0x10(%ebp)
80106095:	e8 c5 bc ff ff       	call   80101d5f <iunlockput>
8010609a:	83 c4 10             	add    $0x10,%esp

  end_op();
8010609d:	e8 df d6 ff ff       	call   80103781 <end_op>

  return 0;
801060a2:	b8 00 00 00 00       	mov    $0x0,%eax
801060a7:	eb 1c                	jmp    801060c5 <sys_unlink+0x1e8>
    goto bad;
801060a9:	90                   	nop
801060aa:	eb 01                	jmp    801060ad <sys_unlink+0x1d0>
    goto bad;
801060ac:	90                   	nop

bad:
  iunlockput(dp);
801060ad:	83 ec 0c             	sub    $0xc,%esp
801060b0:	ff 75 f4             	pushl  -0xc(%ebp)
801060b3:	e8 a7 bc ff ff       	call   80101d5f <iunlockput>
801060b8:	83 c4 10             	add    $0x10,%esp
  end_op();
801060bb:	e8 c1 d6 ff ff       	call   80103781 <end_op>
  return -1;
801060c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060c5:	c9                   	leave  
801060c6:	c3                   	ret    

801060c7 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801060c7:	f3 0f 1e fb          	endbr32 
801060cb:	55                   	push   %ebp
801060cc:	89 e5                	mov    %esp,%ebp
801060ce:	83 ec 38             	sub    $0x38,%esp
801060d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801060d4:	8b 55 10             	mov    0x10(%ebp),%edx
801060d7:	8b 45 14             	mov    0x14(%ebp),%eax
801060da:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801060de:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801060e2:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801060e6:	83 ec 08             	sub    $0x8,%esp
801060e9:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801060ec:	50                   	push   %eax
801060ed:	ff 75 08             	pushl  0x8(%ebp)
801060f0:	e8 b8 c5 ff ff       	call   801026ad <nameiparent>
801060f5:	83 c4 10             	add    $0x10,%esp
801060f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060ff:	75 0a                	jne    8010610b <create+0x44>
    return 0;
80106101:	b8 00 00 00 00       	mov    $0x0,%eax
80106106:	e9 8e 01 00 00       	jmp    80106299 <create+0x1d2>
  ilock(dp);
8010610b:	83 ec 0c             	sub    $0xc,%esp
8010610e:	ff 75 f4             	pushl  -0xc(%ebp)
80106111:	e8 0c ba ff ff       	call   80101b22 <ilock>
80106116:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
80106119:	83 ec 04             	sub    $0x4,%esp
8010611c:	6a 00                	push   $0x0
8010611e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106121:	50                   	push   %eax
80106122:	ff 75 f4             	pushl  -0xc(%ebp)
80106125:	e8 02 c2 ff ff       	call   8010232c <dirlookup>
8010612a:	83 c4 10             	add    $0x10,%esp
8010612d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106130:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106134:	74 50                	je     80106186 <create+0xbf>
    iunlockput(dp);
80106136:	83 ec 0c             	sub    $0xc,%esp
80106139:	ff 75 f4             	pushl  -0xc(%ebp)
8010613c:	e8 1e bc ff ff       	call   80101d5f <iunlockput>
80106141:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106144:	83 ec 0c             	sub    $0xc,%esp
80106147:	ff 75 f0             	pushl  -0x10(%ebp)
8010614a:	e8 d3 b9 ff ff       	call   80101b22 <ilock>
8010614f:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106152:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106157:	75 15                	jne    8010616e <create+0xa7>
80106159:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010615c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106160:	66 83 f8 02          	cmp    $0x2,%ax
80106164:	75 08                	jne    8010616e <create+0xa7>
      return ip;
80106166:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106169:	e9 2b 01 00 00       	jmp    80106299 <create+0x1d2>
    iunlockput(ip);
8010616e:	83 ec 0c             	sub    $0xc,%esp
80106171:	ff 75 f0             	pushl  -0x10(%ebp)
80106174:	e8 e6 bb ff ff       	call   80101d5f <iunlockput>
80106179:	83 c4 10             	add    $0x10,%esp
    return 0;
8010617c:	b8 00 00 00 00       	mov    $0x0,%eax
80106181:	e9 13 01 00 00       	jmp    80106299 <create+0x1d2>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106186:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010618a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010618d:	8b 00                	mov    (%eax),%eax
8010618f:	83 ec 08             	sub    $0x8,%esp
80106192:	52                   	push   %edx
80106193:	50                   	push   %eax
80106194:	e8 c5 b6 ff ff       	call   8010185e <ialloc>
80106199:	83 c4 10             	add    $0x10,%esp
8010619c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010619f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061a3:	75 0d                	jne    801061b2 <create+0xeb>
    panic("create: ialloc");
801061a5:	83 ec 0c             	sub    $0xc,%esp
801061a8:	68 08 97 10 80       	push   $0x80109708
801061ad:	e8 56 a4 ff ff       	call   80100608 <panic>

  ilock(ip);
801061b2:	83 ec 0c             	sub    $0xc,%esp
801061b5:	ff 75 f0             	pushl  -0x10(%ebp)
801061b8:	e8 65 b9 ff ff       	call   80101b22 <ilock>
801061bd:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801061c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c3:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801061c7:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801061cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ce:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801061d2:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801061d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d9:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801061df:	83 ec 0c             	sub    $0xc,%esp
801061e2:	ff 75 f0             	pushl  -0x10(%ebp)
801061e5:	e8 4f b7 ff ff       	call   80101939 <iupdate>
801061ea:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801061ed:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801061f2:	75 6a                	jne    8010625e <create+0x197>
    dp->nlink++;  // for ".."
801061f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801061fb:	83 c0 01             	add    $0x1,%eax
801061fe:	89 c2                	mov    %eax,%edx
80106200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106203:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106207:	83 ec 0c             	sub    $0xc,%esp
8010620a:	ff 75 f4             	pushl  -0xc(%ebp)
8010620d:	e8 27 b7 ff ff       	call   80101939 <iupdate>
80106212:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106215:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106218:	8b 40 04             	mov    0x4(%eax),%eax
8010621b:	83 ec 04             	sub    $0x4,%esp
8010621e:	50                   	push   %eax
8010621f:	68 e2 96 10 80       	push   $0x801096e2
80106224:	ff 75 f0             	pushl  -0x10(%ebp)
80106227:	e8 be c1 ff ff       	call   801023ea <dirlink>
8010622c:	83 c4 10             	add    $0x10,%esp
8010622f:	85 c0                	test   %eax,%eax
80106231:	78 1e                	js     80106251 <create+0x18a>
80106233:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106236:	8b 40 04             	mov    0x4(%eax),%eax
80106239:	83 ec 04             	sub    $0x4,%esp
8010623c:	50                   	push   %eax
8010623d:	68 e4 96 10 80       	push   $0x801096e4
80106242:	ff 75 f0             	pushl  -0x10(%ebp)
80106245:	e8 a0 c1 ff ff       	call   801023ea <dirlink>
8010624a:	83 c4 10             	add    $0x10,%esp
8010624d:	85 c0                	test   %eax,%eax
8010624f:	79 0d                	jns    8010625e <create+0x197>
      panic("create dots");
80106251:	83 ec 0c             	sub    $0xc,%esp
80106254:	68 17 97 10 80       	push   $0x80109717
80106259:	e8 aa a3 ff ff       	call   80100608 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010625e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106261:	8b 40 04             	mov    0x4(%eax),%eax
80106264:	83 ec 04             	sub    $0x4,%esp
80106267:	50                   	push   %eax
80106268:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010626b:	50                   	push   %eax
8010626c:	ff 75 f4             	pushl  -0xc(%ebp)
8010626f:	e8 76 c1 ff ff       	call   801023ea <dirlink>
80106274:	83 c4 10             	add    $0x10,%esp
80106277:	85 c0                	test   %eax,%eax
80106279:	79 0d                	jns    80106288 <create+0x1c1>
    panic("create: dirlink");
8010627b:	83 ec 0c             	sub    $0xc,%esp
8010627e:	68 23 97 10 80       	push   $0x80109723
80106283:	e8 80 a3 ff ff       	call   80100608 <panic>

  iunlockput(dp);
80106288:	83 ec 0c             	sub    $0xc,%esp
8010628b:	ff 75 f4             	pushl  -0xc(%ebp)
8010628e:	e8 cc ba ff ff       	call   80101d5f <iunlockput>
80106293:	83 c4 10             	add    $0x10,%esp

  return ip;
80106296:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106299:	c9                   	leave  
8010629a:	c3                   	ret    

8010629b <sys_open>:

int
sys_open(void)
{
8010629b:	f3 0f 1e fb          	endbr32 
8010629f:	55                   	push   %ebp
801062a0:	89 e5                	mov    %esp,%ebp
801062a2:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801062a5:	83 ec 08             	sub    $0x8,%esp
801062a8:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062ab:	50                   	push   %eax
801062ac:	6a 00                	push   $0x0
801062ae:	e8 b4 f6 ff ff       	call   80105967 <argstr>
801062b3:	83 c4 10             	add    $0x10,%esp
801062b6:	85 c0                	test   %eax,%eax
801062b8:	78 15                	js     801062cf <sys_open+0x34>
801062ba:	83 ec 08             	sub    $0x8,%esp
801062bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062c0:	50                   	push   %eax
801062c1:	6a 01                	push   $0x1
801062c3:	e8 02 f6 ff ff       	call   801058ca <argint>
801062c8:	83 c4 10             	add    $0x10,%esp
801062cb:	85 c0                	test   %eax,%eax
801062cd:	79 0a                	jns    801062d9 <sys_open+0x3e>
    return -1;
801062cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d4:	e9 61 01 00 00       	jmp    8010643a <sys_open+0x19f>

  begin_op();
801062d9:	e8 13 d4 ff ff       	call   801036f1 <begin_op>

  if(omode & O_CREATE){
801062de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062e1:	25 00 02 00 00       	and    $0x200,%eax
801062e6:	85 c0                	test   %eax,%eax
801062e8:	74 2a                	je     80106314 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
801062ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062ed:	6a 00                	push   $0x0
801062ef:	6a 00                	push   $0x0
801062f1:	6a 02                	push   $0x2
801062f3:	50                   	push   %eax
801062f4:	e8 ce fd ff ff       	call   801060c7 <create>
801062f9:	83 c4 10             	add    $0x10,%esp
801062fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801062ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106303:	75 75                	jne    8010637a <sys_open+0xdf>
      end_op();
80106305:	e8 77 d4 ff ff       	call   80103781 <end_op>
      return -1;
8010630a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010630f:	e9 26 01 00 00       	jmp    8010643a <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80106314:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106317:	83 ec 0c             	sub    $0xc,%esp
8010631a:	50                   	push   %eax
8010631b:	e8 6d c3 ff ff       	call   8010268d <namei>
80106320:	83 c4 10             	add    $0x10,%esp
80106323:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106326:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010632a:	75 0f                	jne    8010633b <sys_open+0xa0>
      end_op();
8010632c:	e8 50 d4 ff ff       	call   80103781 <end_op>
      return -1;
80106331:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106336:	e9 ff 00 00 00       	jmp    8010643a <sys_open+0x19f>
    }
    ilock(ip);
8010633b:	83 ec 0c             	sub    $0xc,%esp
8010633e:	ff 75 f4             	pushl  -0xc(%ebp)
80106341:	e8 dc b7 ff ff       	call   80101b22 <ilock>
80106346:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010634c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106350:	66 83 f8 01          	cmp    $0x1,%ax
80106354:	75 24                	jne    8010637a <sys_open+0xdf>
80106356:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106359:	85 c0                	test   %eax,%eax
8010635b:	74 1d                	je     8010637a <sys_open+0xdf>
      iunlockput(ip);
8010635d:	83 ec 0c             	sub    $0xc,%esp
80106360:	ff 75 f4             	pushl  -0xc(%ebp)
80106363:	e8 f7 b9 ff ff       	call   80101d5f <iunlockput>
80106368:	83 c4 10             	add    $0x10,%esp
      end_op();
8010636b:	e8 11 d4 ff ff       	call   80103781 <end_op>
      return -1;
80106370:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106375:	e9 c0 00 00 00       	jmp    8010643a <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010637a:	e8 5d ad ff ff       	call   801010dc <filealloc>
8010637f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106382:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106386:	74 17                	je     8010639f <sys_open+0x104>
80106388:	83 ec 0c             	sub    $0xc,%esp
8010638b:	ff 75 f0             	pushl  -0x10(%ebp)
8010638e:	e8 09 f7 ff ff       	call   80105a9c <fdalloc>
80106393:	83 c4 10             	add    $0x10,%esp
80106396:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106399:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010639d:	79 2e                	jns    801063cd <sys_open+0x132>
    if(f)
8010639f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063a3:	74 0e                	je     801063b3 <sys_open+0x118>
      fileclose(f);
801063a5:	83 ec 0c             	sub    $0xc,%esp
801063a8:	ff 75 f0             	pushl  -0x10(%ebp)
801063ab:	e8 f2 ad ff ff       	call   801011a2 <fileclose>
801063b0:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801063b3:	83 ec 0c             	sub    $0xc,%esp
801063b6:	ff 75 f4             	pushl  -0xc(%ebp)
801063b9:	e8 a1 b9 ff ff       	call   80101d5f <iunlockput>
801063be:	83 c4 10             	add    $0x10,%esp
    end_op();
801063c1:	e8 bb d3 ff ff       	call   80103781 <end_op>
    return -1;
801063c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063cb:	eb 6d                	jmp    8010643a <sys_open+0x19f>
  }
  iunlock(ip);
801063cd:	83 ec 0c             	sub    $0xc,%esp
801063d0:	ff 75 f4             	pushl  -0xc(%ebp)
801063d3:	e8 61 b8 ff ff       	call   80101c39 <iunlock>
801063d8:	83 c4 10             	add    $0x10,%esp
  end_op();
801063db:	e8 a1 d3 ff ff       	call   80103781 <end_op>

  f->type = FD_INODE;
801063e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063e3:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801063e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063ef:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801063f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f5:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801063fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063ff:	83 e0 01             	and    $0x1,%eax
80106402:	85 c0                	test   %eax,%eax
80106404:	0f 94 c0             	sete   %al
80106407:	89 c2                	mov    %eax,%edx
80106409:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010640c:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010640f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106412:	83 e0 01             	and    $0x1,%eax
80106415:	85 c0                	test   %eax,%eax
80106417:	75 0a                	jne    80106423 <sys_open+0x188>
80106419:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010641c:	83 e0 02             	and    $0x2,%eax
8010641f:	85 c0                	test   %eax,%eax
80106421:	74 07                	je     8010642a <sys_open+0x18f>
80106423:	b8 01 00 00 00       	mov    $0x1,%eax
80106428:	eb 05                	jmp    8010642f <sys_open+0x194>
8010642a:	b8 00 00 00 00       	mov    $0x0,%eax
8010642f:	89 c2                	mov    %eax,%edx
80106431:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106434:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106437:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010643a:	c9                   	leave  
8010643b:	c3                   	ret    

8010643c <sys_mkdir>:

int
sys_mkdir(void)
{
8010643c:	f3 0f 1e fb          	endbr32 
80106440:	55                   	push   %ebp
80106441:	89 e5                	mov    %esp,%ebp
80106443:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106446:	e8 a6 d2 ff ff       	call   801036f1 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010644b:	83 ec 08             	sub    $0x8,%esp
8010644e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106451:	50                   	push   %eax
80106452:	6a 00                	push   $0x0
80106454:	e8 0e f5 ff ff       	call   80105967 <argstr>
80106459:	83 c4 10             	add    $0x10,%esp
8010645c:	85 c0                	test   %eax,%eax
8010645e:	78 1b                	js     8010647b <sys_mkdir+0x3f>
80106460:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106463:	6a 00                	push   $0x0
80106465:	6a 00                	push   $0x0
80106467:	6a 01                	push   $0x1
80106469:	50                   	push   %eax
8010646a:	e8 58 fc ff ff       	call   801060c7 <create>
8010646f:	83 c4 10             	add    $0x10,%esp
80106472:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106475:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106479:	75 0c                	jne    80106487 <sys_mkdir+0x4b>
    end_op();
8010647b:	e8 01 d3 ff ff       	call   80103781 <end_op>
    return -1;
80106480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106485:	eb 18                	jmp    8010649f <sys_mkdir+0x63>
  }
  iunlockput(ip);
80106487:	83 ec 0c             	sub    $0xc,%esp
8010648a:	ff 75 f4             	pushl  -0xc(%ebp)
8010648d:	e8 cd b8 ff ff       	call   80101d5f <iunlockput>
80106492:	83 c4 10             	add    $0x10,%esp
  end_op();
80106495:	e8 e7 d2 ff ff       	call   80103781 <end_op>
  return 0;
8010649a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010649f:	c9                   	leave  
801064a0:	c3                   	ret    

801064a1 <sys_mknod>:

int
sys_mknod(void)
{
801064a1:	f3 0f 1e fb          	endbr32 
801064a5:	55                   	push   %ebp
801064a6:	89 e5                	mov    %esp,%ebp
801064a8:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801064ab:	e8 41 d2 ff ff       	call   801036f1 <begin_op>
  if((argstr(0, &path)) < 0 ||
801064b0:	83 ec 08             	sub    $0x8,%esp
801064b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064b6:	50                   	push   %eax
801064b7:	6a 00                	push   $0x0
801064b9:	e8 a9 f4 ff ff       	call   80105967 <argstr>
801064be:	83 c4 10             	add    $0x10,%esp
801064c1:	85 c0                	test   %eax,%eax
801064c3:	78 4f                	js     80106514 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
801064c5:	83 ec 08             	sub    $0x8,%esp
801064c8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064cb:	50                   	push   %eax
801064cc:	6a 01                	push   $0x1
801064ce:	e8 f7 f3 ff ff       	call   801058ca <argint>
801064d3:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801064d6:	85 c0                	test   %eax,%eax
801064d8:	78 3a                	js     80106514 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
801064da:	83 ec 08             	sub    $0x8,%esp
801064dd:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064e0:	50                   	push   %eax
801064e1:	6a 02                	push   $0x2
801064e3:	e8 e2 f3 ff ff       	call   801058ca <argint>
801064e8:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801064eb:	85 c0                	test   %eax,%eax
801064ed:	78 25                	js     80106514 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
801064ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064f2:	0f bf c8             	movswl %ax,%ecx
801064f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064f8:	0f bf d0             	movswl %ax,%edx
801064fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064fe:	51                   	push   %ecx
801064ff:	52                   	push   %edx
80106500:	6a 03                	push   $0x3
80106502:	50                   	push   %eax
80106503:	e8 bf fb ff ff       	call   801060c7 <create>
80106508:	83 c4 10             	add    $0x10,%esp
8010650b:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
8010650e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106512:	75 0c                	jne    80106520 <sys_mknod+0x7f>
    end_op();
80106514:	e8 68 d2 ff ff       	call   80103781 <end_op>
    return -1;
80106519:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010651e:	eb 18                	jmp    80106538 <sys_mknod+0x97>
  }
  iunlockput(ip);
80106520:	83 ec 0c             	sub    $0xc,%esp
80106523:	ff 75 f4             	pushl  -0xc(%ebp)
80106526:	e8 34 b8 ff ff       	call   80101d5f <iunlockput>
8010652b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010652e:	e8 4e d2 ff ff       	call   80103781 <end_op>
  return 0;
80106533:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106538:	c9                   	leave  
80106539:	c3                   	ret    

8010653a <sys_chdir>:

int
sys_chdir(void)
{
8010653a:	f3 0f 1e fb          	endbr32 
8010653e:	55                   	push   %ebp
8010653f:	89 e5                	mov    %esp,%ebp
80106541:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106544:	e8 67 df ff ff       	call   801044b0 <myproc>
80106549:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010654c:	e8 a0 d1 ff ff       	call   801036f1 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106551:	83 ec 08             	sub    $0x8,%esp
80106554:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106557:	50                   	push   %eax
80106558:	6a 00                	push   $0x0
8010655a:	e8 08 f4 ff ff       	call   80105967 <argstr>
8010655f:	83 c4 10             	add    $0x10,%esp
80106562:	85 c0                	test   %eax,%eax
80106564:	78 18                	js     8010657e <sys_chdir+0x44>
80106566:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106569:	83 ec 0c             	sub    $0xc,%esp
8010656c:	50                   	push   %eax
8010656d:	e8 1b c1 ff ff       	call   8010268d <namei>
80106572:	83 c4 10             	add    $0x10,%esp
80106575:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106578:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010657c:	75 0c                	jne    8010658a <sys_chdir+0x50>
    end_op();
8010657e:	e8 fe d1 ff ff       	call   80103781 <end_op>
    return -1;
80106583:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106588:	eb 68                	jmp    801065f2 <sys_chdir+0xb8>
  }
  ilock(ip);
8010658a:	83 ec 0c             	sub    $0xc,%esp
8010658d:	ff 75 f0             	pushl  -0x10(%ebp)
80106590:	e8 8d b5 ff ff       	call   80101b22 <ilock>
80106595:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106598:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010659b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010659f:	66 83 f8 01          	cmp    $0x1,%ax
801065a3:	74 1a                	je     801065bf <sys_chdir+0x85>
    iunlockput(ip);
801065a5:	83 ec 0c             	sub    $0xc,%esp
801065a8:	ff 75 f0             	pushl  -0x10(%ebp)
801065ab:	e8 af b7 ff ff       	call   80101d5f <iunlockput>
801065b0:	83 c4 10             	add    $0x10,%esp
    end_op();
801065b3:	e8 c9 d1 ff ff       	call   80103781 <end_op>
    return -1;
801065b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065bd:	eb 33                	jmp    801065f2 <sys_chdir+0xb8>
  }
  iunlock(ip);
801065bf:	83 ec 0c             	sub    $0xc,%esp
801065c2:	ff 75 f0             	pushl  -0x10(%ebp)
801065c5:	e8 6f b6 ff ff       	call   80101c39 <iunlock>
801065ca:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801065cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d0:	8b 40 6c             	mov    0x6c(%eax),%eax
801065d3:	83 ec 0c             	sub    $0xc,%esp
801065d6:	50                   	push   %eax
801065d7:	e8 af b6 ff ff       	call   80101c8b <iput>
801065dc:	83 c4 10             	add    $0x10,%esp
  end_op();
801065df:	e8 9d d1 ff ff       	call   80103781 <end_op>
  curproc->cwd = ip;
801065e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065ea:	89 50 6c             	mov    %edx,0x6c(%eax)
  return 0;
801065ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065f2:	c9                   	leave  
801065f3:	c3                   	ret    

801065f4 <sys_exec>:

int
sys_exec(void)
{
801065f4:	f3 0f 1e fb          	endbr32 
801065f8:	55                   	push   %ebp
801065f9:	89 e5                	mov    %esp,%ebp
801065fb:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106601:	83 ec 08             	sub    $0x8,%esp
80106604:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106607:	50                   	push   %eax
80106608:	6a 00                	push   $0x0
8010660a:	e8 58 f3 ff ff       	call   80105967 <argstr>
8010660f:	83 c4 10             	add    $0x10,%esp
80106612:	85 c0                	test   %eax,%eax
80106614:	78 18                	js     8010662e <sys_exec+0x3a>
80106616:	83 ec 08             	sub    $0x8,%esp
80106619:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010661f:	50                   	push   %eax
80106620:	6a 01                	push   $0x1
80106622:	e8 a3 f2 ff ff       	call   801058ca <argint>
80106627:	83 c4 10             	add    $0x10,%esp
8010662a:	85 c0                	test   %eax,%eax
8010662c:	79 0a                	jns    80106638 <sys_exec+0x44>
    return -1;
8010662e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106633:	e9 c6 00 00 00       	jmp    801066fe <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106638:	83 ec 04             	sub    $0x4,%esp
8010663b:	68 80 00 00 00       	push   $0x80
80106640:	6a 00                	push   $0x0
80106642:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106648:	50                   	push   %eax
80106649:	e8 28 ef ff ff       	call   80105576 <memset>
8010664e:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106651:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010665b:	83 f8 1f             	cmp    $0x1f,%eax
8010665e:	76 0a                	jbe    8010666a <sys_exec+0x76>
      return -1;
80106660:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106665:	e9 94 00 00 00       	jmp    801066fe <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010666a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010666d:	c1 e0 02             	shl    $0x2,%eax
80106670:	89 c2                	mov    %eax,%edx
80106672:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106678:	01 c2                	add    %eax,%edx
8010667a:	83 ec 08             	sub    $0x8,%esp
8010667d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106683:	50                   	push   %eax
80106684:	52                   	push   %edx
80106685:	e8 95 f1 ff ff       	call   8010581f <fetchint>
8010668a:	83 c4 10             	add    $0x10,%esp
8010668d:	85 c0                	test   %eax,%eax
8010668f:	79 07                	jns    80106698 <sys_exec+0xa4>
      return -1;
80106691:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106696:	eb 66                	jmp    801066fe <sys_exec+0x10a>
    if(uarg == 0){
80106698:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010669e:	85 c0                	test   %eax,%eax
801066a0:	75 27                	jne    801066c9 <sys_exec+0xd5>
      argv[i] = 0;
801066a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a5:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801066ac:	00 00 00 00 
      break;
801066b0:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801066b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066b4:	83 ec 08             	sub    $0x8,%esp
801066b7:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801066bd:	52                   	push   %edx
801066be:	50                   	push   %eax
801066bf:	e8 6c a5 ff ff       	call   80100c30 <exec>
801066c4:	83 c4 10             	add    $0x10,%esp
801066c7:	eb 35                	jmp    801066fe <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801066c9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066d2:	c1 e2 02             	shl    $0x2,%edx
801066d5:	01 c2                	add    %eax,%edx
801066d7:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066dd:	83 ec 08             	sub    $0x8,%esp
801066e0:	52                   	push   %edx
801066e1:	50                   	push   %eax
801066e2:	e8 7b f1 ff ff       	call   80105862 <fetchstr>
801066e7:	83 c4 10             	add    $0x10,%esp
801066ea:	85 c0                	test   %eax,%eax
801066ec:	79 07                	jns    801066f5 <sys_exec+0x101>
      return -1;
801066ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f3:	eb 09                	jmp    801066fe <sys_exec+0x10a>
  for(i=0;; i++){
801066f5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801066f9:	e9 5a ff ff ff       	jmp    80106658 <sys_exec+0x64>
}
801066fe:	c9                   	leave  
801066ff:	c3                   	ret    

80106700 <sys_pipe>:

int
sys_pipe(void)
{
80106700:	f3 0f 1e fb          	endbr32 
80106704:	55                   	push   %ebp
80106705:	89 e5                	mov    %esp,%ebp
80106707:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010670a:	83 ec 04             	sub    $0x4,%esp
8010670d:	6a 08                	push   $0x8
8010670f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106712:	50                   	push   %eax
80106713:	6a 00                	push   $0x0
80106715:	e8 e1 f1 ff ff       	call   801058fb <argptr>
8010671a:	83 c4 10             	add    $0x10,%esp
8010671d:	85 c0                	test   %eax,%eax
8010671f:	79 0a                	jns    8010672b <sys_pipe+0x2b>
    return -1;
80106721:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106726:	e9 ae 00 00 00       	jmp    801067d9 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
8010672b:	83 ec 08             	sub    $0x8,%esp
8010672e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106731:	50                   	push   %eax
80106732:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106735:	50                   	push   %eax
80106736:	e8 96 d8 ff ff       	call   80103fd1 <pipealloc>
8010673b:	83 c4 10             	add    $0x10,%esp
8010673e:	85 c0                	test   %eax,%eax
80106740:	79 0a                	jns    8010674c <sys_pipe+0x4c>
    return -1;
80106742:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106747:	e9 8d 00 00 00       	jmp    801067d9 <sys_pipe+0xd9>
  fd0 = -1;
8010674c:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106753:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106756:	83 ec 0c             	sub    $0xc,%esp
80106759:	50                   	push   %eax
8010675a:	e8 3d f3 ff ff       	call   80105a9c <fdalloc>
8010675f:	83 c4 10             	add    $0x10,%esp
80106762:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106765:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106769:	78 18                	js     80106783 <sys_pipe+0x83>
8010676b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010676e:	83 ec 0c             	sub    $0xc,%esp
80106771:	50                   	push   %eax
80106772:	e8 25 f3 ff ff       	call   80105a9c <fdalloc>
80106777:	83 c4 10             	add    $0x10,%esp
8010677a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010677d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106781:	79 3e                	jns    801067c1 <sys_pipe+0xc1>
    if(fd0 >= 0)
80106783:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106787:	78 13                	js     8010679c <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106789:	e8 22 dd ff ff       	call   801044b0 <myproc>
8010678e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106791:	83 c2 08             	add    $0x8,%edx
80106794:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010679b:	00 
    fileclose(rf);
8010679c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010679f:	83 ec 0c             	sub    $0xc,%esp
801067a2:	50                   	push   %eax
801067a3:	e8 fa a9 ff ff       	call   801011a2 <fileclose>
801067a8:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801067ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067ae:	83 ec 0c             	sub    $0xc,%esp
801067b1:	50                   	push   %eax
801067b2:	e8 eb a9 ff ff       	call   801011a2 <fileclose>
801067b7:	83 c4 10             	add    $0x10,%esp
    return -1;
801067ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067bf:	eb 18                	jmp    801067d9 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
801067c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067c7:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801067c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067cc:	8d 50 04             	lea    0x4(%eax),%edx
801067cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067d2:	89 02                	mov    %eax,(%edx)
  return 0;
801067d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067d9:	c9                   	leave  
801067da:	c3                   	ret    

801067db <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801067db:	f3 0f 1e fb          	endbr32 
801067df:	55                   	push   %ebp
801067e0:	89 e5                	mov    %esp,%ebp
801067e2:	83 ec 08             	sub    $0x8,%esp
  return fork();
801067e5:	e8 2b e0 ff ff       	call   80104815 <fork>
}
801067ea:	c9                   	leave  
801067eb:	c3                   	ret    

801067ec <sys_exit>:

int
sys_exit(void)
{
801067ec:	f3 0f 1e fb          	endbr32 
801067f0:	55                   	push   %ebp
801067f1:	89 e5                	mov    %esp,%ebp
801067f3:	83 ec 08             	sub    $0x8,%esp
  exit();
801067f6:	e8 18 e2 ff ff       	call   80104a13 <exit>
  return 0;  // not reached
801067fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106800:	c9                   	leave  
80106801:	c3                   	ret    

80106802 <sys_wait>:

int
sys_wait(void)
{
80106802:	f3 0f 1e fb          	endbr32 
80106806:	55                   	push   %ebp
80106807:	89 e5                	mov    %esp,%ebp
80106809:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010680c:	e8 29 e3 ff ff       	call   80104b3a <wait>
}
80106811:	c9                   	leave  
80106812:	c3                   	ret    

80106813 <sys_kill>:

int
sys_kill(void)
{
80106813:	f3 0f 1e fb          	endbr32 
80106817:	55                   	push   %ebp
80106818:	89 e5                	mov    %esp,%ebp
8010681a:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010681d:	83 ec 08             	sub    $0x8,%esp
80106820:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106823:	50                   	push   %eax
80106824:	6a 00                	push   $0x0
80106826:	e8 9f f0 ff ff       	call   801058ca <argint>
8010682b:	83 c4 10             	add    $0x10,%esp
8010682e:	85 c0                	test   %eax,%eax
80106830:	79 07                	jns    80106839 <sys_kill+0x26>
    return -1;
80106832:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106837:	eb 0f                	jmp    80106848 <sys_kill+0x35>
  return kill(pid);
80106839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010683c:	83 ec 0c             	sub    $0xc,%esp
8010683f:	50                   	push   %eax
80106840:	e8 4d e7 ff ff       	call   80104f92 <kill>
80106845:	83 c4 10             	add    $0x10,%esp
}
80106848:	c9                   	leave  
80106849:	c3                   	ret    

8010684a <sys_getpid>:

int
sys_getpid(void)
{
8010684a:	f3 0f 1e fb          	endbr32 
8010684e:	55                   	push   %ebp
8010684f:	89 e5                	mov    %esp,%ebp
80106851:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106854:	e8 57 dc ff ff       	call   801044b0 <myproc>
80106859:	8b 40 10             	mov    0x10(%eax),%eax
}
8010685c:	c9                   	leave  
8010685d:	c3                   	ret    

8010685e <sys_sbrk>:

int
sys_sbrk(void)
{
8010685e:	f3 0f 1e fb          	endbr32 
80106862:	55                   	push   %ebp
80106863:	89 e5                	mov    %esp,%ebp
80106865:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106868:	83 ec 08             	sub    $0x8,%esp
8010686b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010686e:	50                   	push   %eax
8010686f:	6a 00                	push   $0x0
80106871:	e8 54 f0 ff ff       	call   801058ca <argint>
80106876:	83 c4 10             	add    $0x10,%esp
80106879:	85 c0                	test   %eax,%eax
8010687b:	79 07                	jns    80106884 <sys_sbrk+0x26>
    return -1;
8010687d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106882:	eb 27                	jmp    801068ab <sys_sbrk+0x4d>
  addr = myproc()->sz;
80106884:	e8 27 dc ff ff       	call   801044b0 <myproc>
80106889:	8b 00                	mov    (%eax),%eax
8010688b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010688e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106891:	83 ec 0c             	sub    $0xc,%esp
80106894:	50                   	push   %eax
80106895:	e8 b7 de ff ff       	call   80104751 <growproc>
8010689a:	83 c4 10             	add    $0x10,%esp
8010689d:	85 c0                	test   %eax,%eax
8010689f:	79 07                	jns    801068a8 <sys_sbrk+0x4a>
    return -1;
801068a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068a6:	eb 03                	jmp    801068ab <sys_sbrk+0x4d>
  return addr;
801068a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068ab:	c9                   	leave  
801068ac:	c3                   	ret    

801068ad <sys_sleep>:

int
sys_sleep(void)
{
801068ad:	f3 0f 1e fb          	endbr32 
801068b1:	55                   	push   %ebp
801068b2:	89 e5                	mov    %esp,%ebp
801068b4:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801068b7:	83 ec 08             	sub    $0x8,%esp
801068ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068bd:	50                   	push   %eax
801068be:	6a 00                	push   $0x0
801068c0:	e8 05 f0 ff ff       	call   801058ca <argint>
801068c5:	83 c4 10             	add    $0x10,%esp
801068c8:	85 c0                	test   %eax,%eax
801068ca:	79 07                	jns    801068d3 <sys_sleep+0x26>
    return -1;
801068cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068d1:	eb 76                	jmp    80106949 <sys_sleep+0x9c>
  acquire(&tickslock);
801068d3:	83 ec 0c             	sub    $0xc,%esp
801068d6:	68 00 81 11 80       	push   $0x80118100
801068db:	e8 f7 e9 ff ff       	call   801052d7 <acquire>
801068e0:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801068e3:	a1 40 89 11 80       	mov    0x80118940,%eax
801068e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801068eb:	eb 38                	jmp    80106925 <sys_sleep+0x78>
    if(myproc()->killed){
801068ed:	e8 be db ff ff       	call   801044b0 <myproc>
801068f2:	8b 40 28             	mov    0x28(%eax),%eax
801068f5:	85 c0                	test   %eax,%eax
801068f7:	74 17                	je     80106910 <sys_sleep+0x63>
      release(&tickslock);
801068f9:	83 ec 0c             	sub    $0xc,%esp
801068fc:	68 00 81 11 80       	push   $0x80118100
80106901:	e8 43 ea ff ff       	call   80105349 <release>
80106906:	83 c4 10             	add    $0x10,%esp
      return -1;
80106909:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010690e:	eb 39                	jmp    80106949 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106910:	83 ec 08             	sub    $0x8,%esp
80106913:	68 00 81 11 80       	push   $0x80118100
80106918:	68 40 89 11 80       	push   $0x80118940
8010691d:	e8 43 e5 ff ff       	call   80104e65 <sleep>
80106922:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106925:	a1 40 89 11 80       	mov    0x80118940,%eax
8010692a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010692d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106930:	39 d0                	cmp    %edx,%eax
80106932:	72 b9                	jb     801068ed <sys_sleep+0x40>
  }
  release(&tickslock);
80106934:	83 ec 0c             	sub    $0xc,%esp
80106937:	68 00 81 11 80       	push   $0x80118100
8010693c:	e8 08 ea ff ff       	call   80105349 <release>
80106941:	83 c4 10             	add    $0x10,%esp
  return 0;
80106944:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106949:	c9                   	leave  
8010694a:	c3                   	ret    

8010694b <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010694b:	f3 0f 1e fb          	endbr32 
8010694f:	55                   	push   %ebp
80106950:	89 e5                	mov    %esp,%ebp
80106952:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106955:	83 ec 0c             	sub    $0xc,%esp
80106958:	68 00 81 11 80       	push   $0x80118100
8010695d:	e8 75 e9 ff ff       	call   801052d7 <acquire>
80106962:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106965:	a1 40 89 11 80       	mov    0x80118940,%eax
8010696a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010696d:	83 ec 0c             	sub    $0xc,%esp
80106970:	68 00 81 11 80       	push   $0x80118100
80106975:	e8 cf e9 ff ff       	call   80105349 <release>
8010697a:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010697d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106980:	c9                   	leave  
80106981:	c3                   	ret    

80106982 <sys_mencrypt>:

//changed: added wrapper here
int sys_mencrypt(void) {
80106982:	f3 0f 1e fb          	endbr32 
80106986:	55                   	push   %ebp
80106987:	89 e5                	mov    %esp,%ebp
80106989:	83 ec 18             	sub    $0x18,%esp
  char * virtual_addr;

  //TODO: what to do if len is 0?

  //dummy size because we're dealing with actual pages here
  if(argint(1, &len) < 0)
8010698c:	83 ec 08             	sub    $0x8,%esp
8010698f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106992:	50                   	push   %eax
80106993:	6a 01                	push   $0x1
80106995:	e8 30 ef ff ff       	call   801058ca <argint>
8010699a:	83 c4 10             	add    $0x10,%esp
8010699d:	85 c0                	test   %eax,%eax
8010699f:	79 07                	jns    801069a8 <sys_mencrypt+0x26>
    return -1;
801069a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069a6:	eb 5e                	jmp    80106a06 <sys_mencrypt+0x84>
  if (len == 0) {
801069a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ab:	85 c0                	test   %eax,%eax
801069ad:	75 07                	jne    801069b6 <sys_mencrypt+0x34>
    return 0;
801069af:	b8 00 00 00 00       	mov    $0x0,%eax
801069b4:	eb 50                	jmp    80106a06 <sys_mencrypt+0x84>
  }
  if (len < 0) {
801069b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069b9:	85 c0                	test   %eax,%eax
801069bb:	79 07                	jns    801069c4 <sys_mencrypt+0x42>
    return -1;
801069bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069c2:	eb 42                	jmp    80106a06 <sys_mencrypt+0x84>
  }
  if (argptr(0, &virtual_addr, 1) < 0) {
801069c4:	83 ec 04             	sub    $0x4,%esp
801069c7:	6a 01                	push   $0x1
801069c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069cc:	50                   	push   %eax
801069cd:	6a 00                	push   $0x0
801069cf:	e8 27 ef ff ff       	call   801058fb <argptr>
801069d4:	83 c4 10             	add    $0x10,%esp
801069d7:	85 c0                	test   %eax,%eax
801069d9:	79 07                	jns    801069e2 <sys_mencrypt+0x60>
    return -1;
801069db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069e0:	eb 24                	jmp    80106a06 <sys_mencrypt+0x84>
  }

  //geq or ge?
  if ((void *) virtual_addr >= (void *)KERNBASE) {
801069e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069e5:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
801069ea:	76 07                	jbe    801069f3 <sys_mencrypt+0x71>
    return -1;
801069ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069f1:	eb 13                	jmp    80106a06 <sys_mencrypt+0x84>
  }
  //virtual_addr = (char *)5000;
  return mencrypt((char*)virtual_addr, len);
801069f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069f9:	83 ec 08             	sub    $0x8,%esp
801069fc:	52                   	push   %edx
801069fd:	50                   	push   %eax
801069fe:	e8 f0 23 00 00       	call   80108df3 <mencrypt>
80106a03:	83 c4 10             	add    $0x10,%esp
}
80106a06:	c9                   	leave  
80106a07:	c3                   	ret    

80106a08 <sys_getpgtable>:

//changed: added wrapper here
int sys_getpgtable(void) {
80106a08:	f3 0f 1e fb          	endbr32 
80106a0c:	55                   	push   %ebp
80106a0d:	89 e5                	mov    %esp,%ebp
80106a0f:	83 ec 18             	sub    $0x18,%esp
  struct pt_entry * entries; 
  int num;
  int wsetOnly;

  if(argint(1, &num) < 0)
80106a12:	83 ec 08             	sub    $0x8,%esp
80106a15:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a18:	50                   	push   %eax
80106a19:	6a 01                	push   $0x1
80106a1b:	e8 aa ee ff ff       	call   801058ca <argint>
80106a20:	83 c4 10             	add    $0x10,%esp
80106a23:	85 c0                	test   %eax,%eax
80106a25:	79 07                	jns    80106a2e <sys_getpgtable+0x26>

    return -1;
80106a27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a2c:	eb 56                	jmp    80106a84 <sys_getpgtable+0x7c>


  if(argptr(0, (char**)&entries, num*sizeof(struct pt_entry)) < 0){
80106a2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a31:	c1 e0 03             	shl    $0x3,%eax
80106a34:	83 ec 04             	sub    $0x4,%esp
80106a37:	50                   	push   %eax
80106a38:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a3b:	50                   	push   %eax
80106a3c:	6a 00                	push   $0x0
80106a3e:	e8 b8 ee ff ff       	call   801058fb <argptr>
80106a43:	83 c4 10             	add    $0x10,%esp
80106a46:	85 c0                	test   %eax,%eax
80106a48:	79 07                	jns    80106a51 <sys_getpgtable+0x49>
    return -1;
80106a4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a4f:	eb 33                	jmp    80106a84 <sys_getpgtable+0x7c>
  }
  if(argint(2, &wsetOnly) < 0) {
80106a51:	83 ec 08             	sub    $0x8,%esp
80106a54:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a57:	50                   	push   %eax
80106a58:	6a 02                	push   $0x2
80106a5a:	e8 6b ee ff ff       	call   801058ca <argint>
80106a5f:	83 c4 10             	add    $0x10,%esp
80106a62:	85 c0                	test   %eax,%eax
80106a64:	79 07                	jns    80106a6d <sys_getpgtable+0x65>
    return -1;
80106a66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a6b:	eb 17                	jmp    80106a84 <sys_getpgtable+0x7c>
  }
  return getpgtable(entries, num, wsetOnly);
80106a6d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106a70:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a76:	83 ec 04             	sub    $0x4,%esp
80106a79:	51                   	push   %ecx
80106a7a:	52                   	push   %edx
80106a7b:	50                   	push   %eax
80106a7c:	e8 ab 24 00 00       	call   80108f2c <getpgtable>
80106a81:	83 c4 10             	add    $0x10,%esp
}
80106a84:	c9                   	leave  
80106a85:	c3                   	ret    

80106a86 <sys_dump_rawphymem>:

//changed: added wrapper here
int sys_dump_rawphymem(void) {
80106a86:	f3 0f 1e fb          	endbr32 
80106a8a:	55                   	push   %ebp
80106a8b:	89 e5                	mov    %esp,%ebp
80106a8d:	83 ec 18             	sub    $0x18,%esp
  uint physical_addr; 
  char * buffer;

  if(argptr(1, &buffer, PGSIZE) < 0)
80106a90:	83 ec 04             	sub    $0x4,%esp
80106a93:	68 00 10 00 00       	push   $0x1000
80106a98:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a9b:	50                   	push   %eax
80106a9c:	6a 01                	push   $0x1
80106a9e:	e8 58 ee ff ff       	call   801058fb <argptr>
80106aa3:	83 c4 10             	add    $0x10,%esp
80106aa6:	85 c0                	test   %eax,%eax
80106aa8:	79 07                	jns    80106ab1 <sys_dump_rawphymem+0x2b>
    return -1;
80106aaa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aaf:	eb 2f                	jmp    80106ae0 <sys_dump_rawphymem+0x5a>

  //dummy size because we're dealing with actual pages here
  if(argint(0, (int*)&physical_addr) < 0)
80106ab1:	83 ec 08             	sub    $0x8,%esp
80106ab4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ab7:	50                   	push   %eax
80106ab8:	6a 00                	push   $0x0
80106aba:	e8 0b ee ff ff       	call   801058ca <argint>
80106abf:	83 c4 10             	add    $0x10,%esp
80106ac2:	85 c0                	test   %eax,%eax
80106ac4:	79 07                	jns    80106acd <sys_dump_rawphymem+0x47>
    return -1;
80106ac6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106acb:	eb 13                	jmp    80106ae0 <sys_dump_rawphymem+0x5a>

  return dump_rawphymem(physical_addr, buffer);
80106acd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ad3:	83 ec 08             	sub    $0x8,%esp
80106ad6:	52                   	push   %edx
80106ad7:	50                   	push   %eax
80106ad8:	e8 c3 26 00 00       	call   801091a0 <dump_rawphymem>
80106add:	83 c4 10             	add    $0x10,%esp
}
80106ae0:	c9                   	leave  
80106ae1:	c3                   	ret    

80106ae2 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106ae2:	1e                   	push   %ds
  pushl %es
80106ae3:	06                   	push   %es
  pushl %fs
80106ae4:	0f a0                	push   %fs
  pushl %gs
80106ae6:	0f a8                	push   %gs
  pushal
80106ae8:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106ae9:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106aed:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106aef:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106af1:	54                   	push   %esp
  call trap
80106af2:	e8 df 01 00 00       	call   80106cd6 <trap>
  addl $4, %esp
80106af7:	83 c4 04             	add    $0x4,%esp

80106afa <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106afa:	61                   	popa   
  popl %gs
80106afb:	0f a9                	pop    %gs
  popl %fs
80106afd:	0f a1                	pop    %fs
  popl %es
80106aff:	07                   	pop    %es
  popl %ds
80106b00:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106b01:	83 c4 08             	add    $0x8,%esp
  iret
80106b04:	cf                   	iret   

80106b05 <lidt>:
{
80106b05:	55                   	push   %ebp
80106b06:	89 e5                	mov    %esp,%ebp
80106b08:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b0e:	83 e8 01             	sub    $0x1,%eax
80106b11:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106b15:	8b 45 08             	mov    0x8(%ebp),%eax
80106b18:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80106b1f:	c1 e8 10             	shr    $0x10,%eax
80106b22:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106b26:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106b29:	0f 01 18             	lidtl  (%eax)
}
80106b2c:	90                   	nop
80106b2d:	c9                   	leave  
80106b2e:	c3                   	ret    

80106b2f <rcr2>:

static inline uint
rcr2(void)
{
80106b2f:	55                   	push   %ebp
80106b30:	89 e5                	mov    %esp,%ebp
80106b32:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106b35:	0f 20 d0             	mov    %cr2,%eax
80106b38:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106b3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106b3e:	c9                   	leave  
80106b3f:	c3                   	ret    

80106b40 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106b40:	f3 0f 1e fb          	endbr32 
80106b44:	55                   	push   %ebp
80106b45:	89 e5                	mov    %esp,%ebp
80106b47:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b51:	e9 c3 00 00 00       	jmp    80106c19 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b59:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106b60:	89 c2                	mov    %eax,%edx
80106b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b65:	66 89 14 c5 40 81 11 	mov    %dx,-0x7fee7ec0(,%eax,8)
80106b6c:	80 
80106b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b70:	66 c7 04 c5 42 81 11 	movw   $0x8,-0x7fee7ebe(,%eax,8)
80106b77:	80 08 00 
80106b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b7d:	0f b6 14 c5 44 81 11 	movzbl -0x7fee7ebc(,%eax,8),%edx
80106b84:	80 
80106b85:	83 e2 e0             	and    $0xffffffe0,%edx
80106b88:	88 14 c5 44 81 11 80 	mov    %dl,-0x7fee7ebc(,%eax,8)
80106b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b92:	0f b6 14 c5 44 81 11 	movzbl -0x7fee7ebc(,%eax,8),%edx
80106b99:	80 
80106b9a:	83 e2 1f             	and    $0x1f,%edx
80106b9d:	88 14 c5 44 81 11 80 	mov    %dl,-0x7fee7ebc(,%eax,8)
80106ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba7:	0f b6 14 c5 45 81 11 	movzbl -0x7fee7ebb(,%eax,8),%edx
80106bae:	80 
80106baf:	83 e2 f0             	and    $0xfffffff0,%edx
80106bb2:	83 ca 0e             	or     $0xe,%edx
80106bb5:	88 14 c5 45 81 11 80 	mov    %dl,-0x7fee7ebb(,%eax,8)
80106bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bbf:	0f b6 14 c5 45 81 11 	movzbl -0x7fee7ebb(,%eax,8),%edx
80106bc6:	80 
80106bc7:	83 e2 ef             	and    $0xffffffef,%edx
80106bca:	88 14 c5 45 81 11 80 	mov    %dl,-0x7fee7ebb(,%eax,8)
80106bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bd4:	0f b6 14 c5 45 81 11 	movzbl -0x7fee7ebb(,%eax,8),%edx
80106bdb:	80 
80106bdc:	83 e2 9f             	and    $0xffffff9f,%edx
80106bdf:	88 14 c5 45 81 11 80 	mov    %dl,-0x7fee7ebb(,%eax,8)
80106be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106be9:	0f b6 14 c5 45 81 11 	movzbl -0x7fee7ebb(,%eax,8),%edx
80106bf0:	80 
80106bf1:	83 ca 80             	or     $0xffffff80,%edx
80106bf4:	88 14 c5 45 81 11 80 	mov    %dl,-0x7fee7ebb(,%eax,8)
80106bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bfe:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106c05:	c1 e8 10             	shr    $0x10,%eax
80106c08:	89 c2                	mov    %eax,%edx
80106c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c0d:	66 89 14 c5 46 81 11 	mov    %dx,-0x7fee7eba(,%eax,8)
80106c14:	80 
  for(i = 0; i < 256; i++)
80106c15:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c19:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106c20:	0f 8e 30 ff ff ff    	jle    80106b56 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106c26:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106c2b:	66 a3 40 83 11 80    	mov    %ax,0x80118340
80106c31:	66 c7 05 42 83 11 80 	movw   $0x8,0x80118342
80106c38:	08 00 
80106c3a:	0f b6 05 44 83 11 80 	movzbl 0x80118344,%eax
80106c41:	83 e0 e0             	and    $0xffffffe0,%eax
80106c44:	a2 44 83 11 80       	mov    %al,0x80118344
80106c49:	0f b6 05 44 83 11 80 	movzbl 0x80118344,%eax
80106c50:	83 e0 1f             	and    $0x1f,%eax
80106c53:	a2 44 83 11 80       	mov    %al,0x80118344
80106c58:	0f b6 05 45 83 11 80 	movzbl 0x80118345,%eax
80106c5f:	83 c8 0f             	or     $0xf,%eax
80106c62:	a2 45 83 11 80       	mov    %al,0x80118345
80106c67:	0f b6 05 45 83 11 80 	movzbl 0x80118345,%eax
80106c6e:	83 e0 ef             	and    $0xffffffef,%eax
80106c71:	a2 45 83 11 80       	mov    %al,0x80118345
80106c76:	0f b6 05 45 83 11 80 	movzbl 0x80118345,%eax
80106c7d:	83 c8 60             	or     $0x60,%eax
80106c80:	a2 45 83 11 80       	mov    %al,0x80118345
80106c85:	0f b6 05 45 83 11 80 	movzbl 0x80118345,%eax
80106c8c:	83 c8 80             	or     $0xffffff80,%eax
80106c8f:	a2 45 83 11 80       	mov    %al,0x80118345
80106c94:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106c99:	c1 e8 10             	shr    $0x10,%eax
80106c9c:	66 a3 46 83 11 80    	mov    %ax,0x80118346

  initlock(&tickslock, "time");
80106ca2:	83 ec 08             	sub    $0x8,%esp
80106ca5:	68 34 97 10 80       	push   $0x80109734
80106caa:	68 00 81 11 80       	push   $0x80118100
80106caf:	e8 fd e5 ff ff       	call   801052b1 <initlock>
80106cb4:	83 c4 10             	add    $0x10,%esp
}
80106cb7:	90                   	nop
80106cb8:	c9                   	leave  
80106cb9:	c3                   	ret    

80106cba <idtinit>:

void
idtinit(void)
{
80106cba:	f3 0f 1e fb          	endbr32 
80106cbe:	55                   	push   %ebp
80106cbf:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106cc1:	68 00 08 00 00       	push   $0x800
80106cc6:	68 40 81 11 80       	push   $0x80118140
80106ccb:	e8 35 fe ff ff       	call   80106b05 <lidt>
80106cd0:	83 c4 08             	add    $0x8,%esp
}
80106cd3:	90                   	nop
80106cd4:	c9                   	leave  
80106cd5:	c3                   	ret    

80106cd6 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106cd6:	f3 0f 1e fb          	endbr32 
80106cda:	55                   	push   %ebp
80106cdb:	89 e5                	mov    %esp,%ebp
80106cdd:	57                   	push   %edi
80106cde:	56                   	push   %esi
80106cdf:	53                   	push   %ebx
80106ce0:	83 ec 2c             	sub    $0x2c,%esp
  //cprintf("in trap\n");
  if(tf->trapno == T_SYSCALL){
80106ce3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce6:	8b 40 30             	mov    0x30(%eax),%eax
80106ce9:	83 f8 40             	cmp    $0x40,%eax
80106cec:	75 3b                	jne    80106d29 <trap+0x53>
    if(myproc()->killed)
80106cee:	e8 bd d7 ff ff       	call   801044b0 <myproc>
80106cf3:	8b 40 28             	mov    0x28(%eax),%eax
80106cf6:	85 c0                	test   %eax,%eax
80106cf8:	74 05                	je     80106cff <trap+0x29>
      exit();
80106cfa:	e8 14 dd ff ff       	call   80104a13 <exit>
    myproc()->tf = tf;
80106cff:	e8 ac d7 ff ff       	call   801044b0 <myproc>
80106d04:	8b 55 08             	mov    0x8(%ebp),%edx
80106d07:	89 50 1c             	mov    %edx,0x1c(%eax)
    syscall();
80106d0a:	e8 93 ec ff ff       	call   801059a2 <syscall>
    if(myproc()->killed)
80106d0f:	e8 9c d7 ff ff       	call   801044b0 <myproc>
80106d14:	8b 40 28             	mov    0x28(%eax),%eax
80106d17:	85 c0                	test   %eax,%eax
80106d19:	0f 84 28 02 00 00    	je     80106f47 <trap+0x271>
      exit();
80106d1f:	e8 ef dc ff ff       	call   80104a13 <exit>
    return;
80106d24:	e9 1e 02 00 00       	jmp    80106f47 <trap+0x271>
  }
  char *addr;
  switch(tf->trapno){
80106d29:	8b 45 08             	mov    0x8(%ebp),%eax
80106d2c:	8b 40 30             	mov    0x30(%eax),%eax
80106d2f:	83 e8 0e             	sub    $0xe,%eax
80106d32:	83 f8 31             	cmp    $0x31,%eax
80106d35:	0f 87 d4 00 00 00    	ja     80106e0f <trap+0x139>
80106d3b:	8b 04 85 dc 97 10 80 	mov    -0x7fef6824(,%eax,4),%eax
80106d42:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106d45:	e8 cb d6 ff ff       	call   80104415 <cpuid>
80106d4a:	85 c0                	test   %eax,%eax
80106d4c:	75 3d                	jne    80106d8b <trap+0xb5>
      acquire(&tickslock);
80106d4e:	83 ec 0c             	sub    $0xc,%esp
80106d51:	68 00 81 11 80       	push   $0x80118100
80106d56:	e8 7c e5 ff ff       	call   801052d7 <acquire>
80106d5b:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106d5e:	a1 40 89 11 80       	mov    0x80118940,%eax
80106d63:	83 c0 01             	add    $0x1,%eax
80106d66:	a3 40 89 11 80       	mov    %eax,0x80118940
      wakeup(&ticks);
80106d6b:	83 ec 0c             	sub    $0xc,%esp
80106d6e:	68 40 89 11 80       	push   $0x80118940
80106d73:	e8 df e1 ff ff       	call   80104f57 <wakeup>
80106d78:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106d7b:	83 ec 0c             	sub    $0xc,%esp
80106d7e:	68 00 81 11 80       	push   $0x80118100
80106d83:	e8 c1 e5 ff ff       	call   80105349 <release>
80106d88:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106d8b:	e8 15 c4 ff ff       	call   801031a5 <lapiceoi>
    break;
80106d90:	e9 32 01 00 00       	jmp    80106ec7 <trap+0x1f1>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106d95:	e8 40 bc ff ff       	call   801029da <ideintr>
    lapiceoi();
80106d9a:	e8 06 c4 ff ff       	call   801031a5 <lapiceoi>
    break;
80106d9f:	e9 23 01 00 00       	jmp    80106ec7 <trap+0x1f1>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106da4:	e8 32 c2 ff ff       	call   80102fdb <kbdintr>
    lapiceoi();
80106da9:	e8 f7 c3 ff ff       	call   801031a5 <lapiceoi>
    break;
80106dae:	e9 14 01 00 00       	jmp    80106ec7 <trap+0x1f1>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106db3:	e8 71 03 00 00       	call   80107129 <uartintr>
    lapiceoi();
80106db8:	e8 e8 c3 ff ff       	call   801031a5 <lapiceoi>
    break;
80106dbd:	e9 05 01 00 00       	jmp    80106ec7 <trap+0x1f1>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80106dc5:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106dc8:	8b 45 08             	mov    0x8(%ebp),%eax
80106dcb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106dcf:	0f b7 d8             	movzwl %ax,%ebx
80106dd2:	e8 3e d6 ff ff       	call   80104415 <cpuid>
80106dd7:	56                   	push   %esi
80106dd8:	53                   	push   %ebx
80106dd9:	50                   	push   %eax
80106dda:	68 3c 97 10 80       	push   $0x8010973c
80106ddf:	e8 34 96 ff ff       	call   80100418 <cprintf>
80106de4:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106de7:	e8 b9 c3 ff ff       	call   801031a5 <lapiceoi>
    break;
80106dec:	e9 d6 00 00 00       	jmp    80106ec7 <trap+0x1f1>
  case T_PGFLT:
    //get the virtual address that caused the fault
    addr = (char*)rcr2();
80106df1:	e8 39 fd ff ff       	call   80106b2f <rcr2>
80106df6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (!mdecrypt(addr)) {
80106df9:	83 ec 0c             	sub    $0xc,%esp
80106dfc:	ff 75 e4             	pushl  -0x1c(%ebp)
80106dff:	e8 2c 1f 00 00       	call   80108d30 <mdecrypt>
80106e04:	83 c4 10             	add    $0x10,%esp
80106e07:	85 c0                	test   %eax,%eax
80106e09:	0f 84 b7 00 00 00    	je     80106ec6 <trap+0x1f0>
      //default kills the process
      break;
    };
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106e0f:	e8 9c d6 ff ff       	call   801044b0 <myproc>
80106e14:	85 c0                	test   %eax,%eax
80106e16:	74 11                	je     80106e29 <trap+0x153>
80106e18:	8b 45 08             	mov    0x8(%ebp),%eax
80106e1b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e1f:	0f b7 c0             	movzwl %ax,%eax
80106e22:	83 e0 03             	and    $0x3,%eax
80106e25:	85 c0                	test   %eax,%eax
80106e27:	75 39                	jne    80106e62 <trap+0x18c>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e29:	e8 01 fd ff ff       	call   80106b2f <rcr2>
80106e2e:	89 c3                	mov    %eax,%ebx
80106e30:	8b 45 08             	mov    0x8(%ebp),%eax
80106e33:	8b 70 38             	mov    0x38(%eax),%esi
80106e36:	e8 da d5 ff ff       	call   80104415 <cpuid>
80106e3b:	8b 55 08             	mov    0x8(%ebp),%edx
80106e3e:	8b 52 30             	mov    0x30(%edx),%edx
80106e41:	83 ec 0c             	sub    $0xc,%esp
80106e44:	53                   	push   %ebx
80106e45:	56                   	push   %esi
80106e46:	50                   	push   %eax
80106e47:	52                   	push   %edx
80106e48:	68 60 97 10 80       	push   $0x80109760
80106e4d:	e8 c6 95 ff ff       	call   80100418 <cprintf>
80106e52:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106e55:	83 ec 0c             	sub    $0xc,%esp
80106e58:	68 92 97 10 80       	push   $0x80109792
80106e5d:	e8 a6 97 ff ff       	call   80100608 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e62:	e8 c8 fc ff ff       	call   80106b2f <rcr2>
80106e67:	89 c6                	mov    %eax,%esi
80106e69:	8b 45 08             	mov    0x8(%ebp),%eax
80106e6c:	8b 40 38             	mov    0x38(%eax),%eax
80106e6f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106e72:	e8 9e d5 ff ff       	call   80104415 <cpuid>
80106e77:	89 c3                	mov    %eax,%ebx
80106e79:	8b 45 08             	mov    0x8(%ebp),%eax
80106e7c:	8b 48 34             	mov    0x34(%eax),%ecx
80106e7f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106e82:	8b 45 08             	mov    0x8(%ebp),%eax
80106e85:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106e88:	e8 23 d6 ff ff       	call   801044b0 <myproc>
80106e8d:	8d 50 70             	lea    0x70(%eax),%edx
80106e90:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106e93:	e8 18 d6 ff ff       	call   801044b0 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e98:	8b 40 10             	mov    0x10(%eax),%eax
80106e9b:	56                   	push   %esi
80106e9c:	ff 75 d4             	pushl  -0x2c(%ebp)
80106e9f:	53                   	push   %ebx
80106ea0:	ff 75 d0             	pushl  -0x30(%ebp)
80106ea3:	57                   	push   %edi
80106ea4:	ff 75 cc             	pushl  -0x34(%ebp)
80106ea7:	50                   	push   %eax
80106ea8:	68 98 97 10 80       	push   $0x80109798
80106ead:	e8 66 95 ff ff       	call   80100418 <cprintf>
80106eb2:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106eb5:	e8 f6 d5 ff ff       	call   801044b0 <myproc>
80106eba:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
80106ec1:	eb 04                	jmp    80106ec7 <trap+0x1f1>
    break;
80106ec3:	90                   	nop
80106ec4:	eb 01                	jmp    80106ec7 <trap+0x1f1>
      break;
80106ec6:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106ec7:	e8 e4 d5 ff ff       	call   801044b0 <myproc>
80106ecc:	85 c0                	test   %eax,%eax
80106ece:	74 23                	je     80106ef3 <trap+0x21d>
80106ed0:	e8 db d5 ff ff       	call   801044b0 <myproc>
80106ed5:	8b 40 28             	mov    0x28(%eax),%eax
80106ed8:	85 c0                	test   %eax,%eax
80106eda:	74 17                	je     80106ef3 <trap+0x21d>
80106edc:	8b 45 08             	mov    0x8(%ebp),%eax
80106edf:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ee3:	0f b7 c0             	movzwl %ax,%eax
80106ee6:	83 e0 03             	and    $0x3,%eax
80106ee9:	83 f8 03             	cmp    $0x3,%eax
80106eec:	75 05                	jne    80106ef3 <trap+0x21d>
    exit();
80106eee:	e8 20 db ff ff       	call   80104a13 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106ef3:	e8 b8 d5 ff ff       	call   801044b0 <myproc>
80106ef8:	85 c0                	test   %eax,%eax
80106efa:	74 1d                	je     80106f19 <trap+0x243>
80106efc:	e8 af d5 ff ff       	call   801044b0 <myproc>
80106f01:	8b 40 0c             	mov    0xc(%eax),%eax
80106f04:	83 f8 04             	cmp    $0x4,%eax
80106f07:	75 10                	jne    80106f19 <trap+0x243>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106f09:	8b 45 08             	mov    0x8(%ebp),%eax
80106f0c:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106f0f:	83 f8 20             	cmp    $0x20,%eax
80106f12:	75 05                	jne    80106f19 <trap+0x243>
    yield();
80106f14:	e8 c4 de ff ff       	call   80104ddd <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f19:	e8 92 d5 ff ff       	call   801044b0 <myproc>
80106f1e:	85 c0                	test   %eax,%eax
80106f20:	74 26                	je     80106f48 <trap+0x272>
80106f22:	e8 89 d5 ff ff       	call   801044b0 <myproc>
80106f27:	8b 40 28             	mov    0x28(%eax),%eax
80106f2a:	85 c0                	test   %eax,%eax
80106f2c:	74 1a                	je     80106f48 <trap+0x272>
80106f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80106f31:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f35:	0f b7 c0             	movzwl %ax,%eax
80106f38:	83 e0 03             	and    $0x3,%eax
80106f3b:	83 f8 03             	cmp    $0x3,%eax
80106f3e:	75 08                	jne    80106f48 <trap+0x272>
    exit();
80106f40:	e8 ce da ff ff       	call   80104a13 <exit>
80106f45:	eb 01                	jmp    80106f48 <trap+0x272>
    return;
80106f47:	90                   	nop
}
80106f48:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f4b:	5b                   	pop    %ebx
80106f4c:	5e                   	pop    %esi
80106f4d:	5f                   	pop    %edi
80106f4e:	5d                   	pop    %ebp
80106f4f:	c3                   	ret    

80106f50 <inb>:
{
80106f50:	55                   	push   %ebp
80106f51:	89 e5                	mov    %esp,%ebp
80106f53:	83 ec 14             	sub    $0x14,%esp
80106f56:	8b 45 08             	mov    0x8(%ebp),%eax
80106f59:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f5d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106f61:	89 c2                	mov    %eax,%edx
80106f63:	ec                   	in     (%dx),%al
80106f64:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f67:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106f6b:	c9                   	leave  
80106f6c:	c3                   	ret    

80106f6d <outb>:
{
80106f6d:	55                   	push   %ebp
80106f6e:	89 e5                	mov    %esp,%ebp
80106f70:	83 ec 08             	sub    $0x8,%esp
80106f73:	8b 45 08             	mov    0x8(%ebp),%eax
80106f76:	8b 55 0c             	mov    0xc(%ebp),%edx
80106f79:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106f7d:	89 d0                	mov    %edx,%eax
80106f7f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106f82:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106f86:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106f8a:	ee                   	out    %al,(%dx)
}
80106f8b:	90                   	nop
80106f8c:	c9                   	leave  
80106f8d:	c3                   	ret    

80106f8e <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106f8e:	f3 0f 1e fb          	endbr32 
80106f92:	55                   	push   %ebp
80106f93:	89 e5                	mov    %esp,%ebp
80106f95:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106f98:	6a 00                	push   $0x0
80106f9a:	68 fa 03 00 00       	push   $0x3fa
80106f9f:	e8 c9 ff ff ff       	call   80106f6d <outb>
80106fa4:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106fa7:	68 80 00 00 00       	push   $0x80
80106fac:	68 fb 03 00 00       	push   $0x3fb
80106fb1:	e8 b7 ff ff ff       	call   80106f6d <outb>
80106fb6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106fb9:	6a 0c                	push   $0xc
80106fbb:	68 f8 03 00 00       	push   $0x3f8
80106fc0:	e8 a8 ff ff ff       	call   80106f6d <outb>
80106fc5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106fc8:	6a 00                	push   $0x0
80106fca:	68 f9 03 00 00       	push   $0x3f9
80106fcf:	e8 99 ff ff ff       	call   80106f6d <outb>
80106fd4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106fd7:	6a 03                	push   $0x3
80106fd9:	68 fb 03 00 00       	push   $0x3fb
80106fde:	e8 8a ff ff ff       	call   80106f6d <outb>
80106fe3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106fe6:	6a 00                	push   $0x0
80106fe8:	68 fc 03 00 00       	push   $0x3fc
80106fed:	e8 7b ff ff ff       	call   80106f6d <outb>
80106ff2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106ff5:	6a 01                	push   $0x1
80106ff7:	68 f9 03 00 00       	push   $0x3f9
80106ffc:	e8 6c ff ff ff       	call   80106f6d <outb>
80107001:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107004:	68 fd 03 00 00       	push   $0x3fd
80107009:	e8 42 ff ff ff       	call   80106f50 <inb>
8010700e:	83 c4 04             	add    $0x4,%esp
80107011:	3c ff                	cmp    $0xff,%al
80107013:	74 61                	je     80107076 <uartinit+0xe8>
    return;
  uart = 1;
80107015:	c7 05 44 c6 10 80 01 	movl   $0x1,0x8010c644
8010701c:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010701f:	68 fa 03 00 00       	push   $0x3fa
80107024:	e8 27 ff ff ff       	call   80106f50 <inb>
80107029:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010702c:	68 f8 03 00 00       	push   $0x3f8
80107031:	e8 1a ff ff ff       	call   80106f50 <inb>
80107036:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80107039:	83 ec 08             	sub    $0x8,%esp
8010703c:	6a 00                	push   $0x0
8010703e:	6a 04                	push   $0x4
80107040:	e8 47 bc ff ff       	call   80102c8c <ioapicenable>
80107045:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107048:	c7 45 f4 a4 98 10 80 	movl   $0x801098a4,-0xc(%ebp)
8010704f:	eb 19                	jmp    8010706a <uartinit+0xdc>
    uartputc(*p);
80107051:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107054:	0f b6 00             	movzbl (%eax),%eax
80107057:	0f be c0             	movsbl %al,%eax
8010705a:	83 ec 0c             	sub    $0xc,%esp
8010705d:	50                   	push   %eax
8010705e:	e8 16 00 00 00       	call   80107079 <uartputc>
80107063:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80107066:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010706a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010706d:	0f b6 00             	movzbl (%eax),%eax
80107070:	84 c0                	test   %al,%al
80107072:	75 dd                	jne    80107051 <uartinit+0xc3>
80107074:	eb 01                	jmp    80107077 <uartinit+0xe9>
    return;
80107076:	90                   	nop
}
80107077:	c9                   	leave  
80107078:	c3                   	ret    

80107079 <uartputc>:

void
uartputc(int c)
{
80107079:	f3 0f 1e fb          	endbr32 
8010707d:	55                   	push   %ebp
8010707e:	89 e5                	mov    %esp,%ebp
80107080:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107083:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80107088:	85 c0                	test   %eax,%eax
8010708a:	74 53                	je     801070df <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010708c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107093:	eb 11                	jmp    801070a6 <uartputc+0x2d>
    microdelay(10);
80107095:	83 ec 0c             	sub    $0xc,%esp
80107098:	6a 0a                	push   $0xa
8010709a:	e8 25 c1 ff ff       	call   801031c4 <microdelay>
8010709f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801070a6:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801070aa:	7f 1a                	jg     801070c6 <uartputc+0x4d>
801070ac:	83 ec 0c             	sub    $0xc,%esp
801070af:	68 fd 03 00 00       	push   $0x3fd
801070b4:	e8 97 fe ff ff       	call   80106f50 <inb>
801070b9:	83 c4 10             	add    $0x10,%esp
801070bc:	0f b6 c0             	movzbl %al,%eax
801070bf:	83 e0 20             	and    $0x20,%eax
801070c2:	85 c0                	test   %eax,%eax
801070c4:	74 cf                	je     80107095 <uartputc+0x1c>
  outb(COM1+0, c);
801070c6:	8b 45 08             	mov    0x8(%ebp),%eax
801070c9:	0f b6 c0             	movzbl %al,%eax
801070cc:	83 ec 08             	sub    $0x8,%esp
801070cf:	50                   	push   %eax
801070d0:	68 f8 03 00 00       	push   $0x3f8
801070d5:	e8 93 fe ff ff       	call   80106f6d <outb>
801070da:	83 c4 10             	add    $0x10,%esp
801070dd:	eb 01                	jmp    801070e0 <uartputc+0x67>
    return;
801070df:	90                   	nop
}
801070e0:	c9                   	leave  
801070e1:	c3                   	ret    

801070e2 <uartgetc>:

static int
uartgetc(void)
{
801070e2:	f3 0f 1e fb          	endbr32 
801070e6:	55                   	push   %ebp
801070e7:	89 e5                	mov    %esp,%ebp
  if(!uart)
801070e9:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801070ee:	85 c0                	test   %eax,%eax
801070f0:	75 07                	jne    801070f9 <uartgetc+0x17>
    return -1;
801070f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070f7:	eb 2e                	jmp    80107127 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801070f9:	68 fd 03 00 00       	push   $0x3fd
801070fe:	e8 4d fe ff ff       	call   80106f50 <inb>
80107103:	83 c4 04             	add    $0x4,%esp
80107106:	0f b6 c0             	movzbl %al,%eax
80107109:	83 e0 01             	and    $0x1,%eax
8010710c:	85 c0                	test   %eax,%eax
8010710e:	75 07                	jne    80107117 <uartgetc+0x35>
    return -1;
80107110:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107115:	eb 10                	jmp    80107127 <uartgetc+0x45>
  return inb(COM1+0);
80107117:	68 f8 03 00 00       	push   $0x3f8
8010711c:	e8 2f fe ff ff       	call   80106f50 <inb>
80107121:	83 c4 04             	add    $0x4,%esp
80107124:	0f b6 c0             	movzbl %al,%eax
}
80107127:	c9                   	leave  
80107128:	c3                   	ret    

80107129 <uartintr>:

void
uartintr(void)
{
80107129:	f3 0f 1e fb          	endbr32 
8010712d:	55                   	push   %ebp
8010712e:	89 e5                	mov    %esp,%ebp
80107130:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107133:	83 ec 0c             	sub    $0xc,%esp
80107136:	68 e2 70 10 80       	push   $0x801070e2
8010713b:	e8 68 97 ff ff       	call   801008a8 <consoleintr>
80107140:	83 c4 10             	add    $0x10,%esp
}
80107143:	90                   	nop
80107144:	c9                   	leave  
80107145:	c3                   	ret    

80107146 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107146:	6a 00                	push   $0x0
  pushl $0
80107148:	6a 00                	push   $0x0
  jmp alltraps
8010714a:	e9 93 f9 ff ff       	jmp    80106ae2 <alltraps>

8010714f <vector1>:
.globl vector1
vector1:
  pushl $0
8010714f:	6a 00                	push   $0x0
  pushl $1
80107151:	6a 01                	push   $0x1
  jmp alltraps
80107153:	e9 8a f9 ff ff       	jmp    80106ae2 <alltraps>

80107158 <vector2>:
.globl vector2
vector2:
  pushl $0
80107158:	6a 00                	push   $0x0
  pushl $2
8010715a:	6a 02                	push   $0x2
  jmp alltraps
8010715c:	e9 81 f9 ff ff       	jmp    80106ae2 <alltraps>

80107161 <vector3>:
.globl vector3
vector3:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $3
80107163:	6a 03                	push   $0x3
  jmp alltraps
80107165:	e9 78 f9 ff ff       	jmp    80106ae2 <alltraps>

8010716a <vector4>:
.globl vector4
vector4:
  pushl $0
8010716a:	6a 00                	push   $0x0
  pushl $4
8010716c:	6a 04                	push   $0x4
  jmp alltraps
8010716e:	e9 6f f9 ff ff       	jmp    80106ae2 <alltraps>

80107173 <vector5>:
.globl vector5
vector5:
  pushl $0
80107173:	6a 00                	push   $0x0
  pushl $5
80107175:	6a 05                	push   $0x5
  jmp alltraps
80107177:	e9 66 f9 ff ff       	jmp    80106ae2 <alltraps>

8010717c <vector6>:
.globl vector6
vector6:
  pushl $0
8010717c:	6a 00                	push   $0x0
  pushl $6
8010717e:	6a 06                	push   $0x6
  jmp alltraps
80107180:	e9 5d f9 ff ff       	jmp    80106ae2 <alltraps>

80107185 <vector7>:
.globl vector7
vector7:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $7
80107187:	6a 07                	push   $0x7
  jmp alltraps
80107189:	e9 54 f9 ff ff       	jmp    80106ae2 <alltraps>

8010718e <vector8>:
.globl vector8
vector8:
  pushl $8
8010718e:	6a 08                	push   $0x8
  jmp alltraps
80107190:	e9 4d f9 ff ff       	jmp    80106ae2 <alltraps>

80107195 <vector9>:
.globl vector9
vector9:
  pushl $0
80107195:	6a 00                	push   $0x0
  pushl $9
80107197:	6a 09                	push   $0x9
  jmp alltraps
80107199:	e9 44 f9 ff ff       	jmp    80106ae2 <alltraps>

8010719e <vector10>:
.globl vector10
vector10:
  pushl $10
8010719e:	6a 0a                	push   $0xa
  jmp alltraps
801071a0:	e9 3d f9 ff ff       	jmp    80106ae2 <alltraps>

801071a5 <vector11>:
.globl vector11
vector11:
  pushl $11
801071a5:	6a 0b                	push   $0xb
  jmp alltraps
801071a7:	e9 36 f9 ff ff       	jmp    80106ae2 <alltraps>

801071ac <vector12>:
.globl vector12
vector12:
  pushl $12
801071ac:	6a 0c                	push   $0xc
  jmp alltraps
801071ae:	e9 2f f9 ff ff       	jmp    80106ae2 <alltraps>

801071b3 <vector13>:
.globl vector13
vector13:
  pushl $13
801071b3:	6a 0d                	push   $0xd
  jmp alltraps
801071b5:	e9 28 f9 ff ff       	jmp    80106ae2 <alltraps>

801071ba <vector14>:
.globl vector14
vector14:
  pushl $14
801071ba:	6a 0e                	push   $0xe
  jmp alltraps
801071bc:	e9 21 f9 ff ff       	jmp    80106ae2 <alltraps>

801071c1 <vector15>:
.globl vector15
vector15:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $15
801071c3:	6a 0f                	push   $0xf
  jmp alltraps
801071c5:	e9 18 f9 ff ff       	jmp    80106ae2 <alltraps>

801071ca <vector16>:
.globl vector16
vector16:
  pushl $0
801071ca:	6a 00                	push   $0x0
  pushl $16
801071cc:	6a 10                	push   $0x10
  jmp alltraps
801071ce:	e9 0f f9 ff ff       	jmp    80106ae2 <alltraps>

801071d3 <vector17>:
.globl vector17
vector17:
  pushl $17
801071d3:	6a 11                	push   $0x11
  jmp alltraps
801071d5:	e9 08 f9 ff ff       	jmp    80106ae2 <alltraps>

801071da <vector18>:
.globl vector18
vector18:
  pushl $0
801071da:	6a 00                	push   $0x0
  pushl $18
801071dc:	6a 12                	push   $0x12
  jmp alltraps
801071de:	e9 ff f8 ff ff       	jmp    80106ae2 <alltraps>

801071e3 <vector19>:
.globl vector19
vector19:
  pushl $0
801071e3:	6a 00                	push   $0x0
  pushl $19
801071e5:	6a 13                	push   $0x13
  jmp alltraps
801071e7:	e9 f6 f8 ff ff       	jmp    80106ae2 <alltraps>

801071ec <vector20>:
.globl vector20
vector20:
  pushl $0
801071ec:	6a 00                	push   $0x0
  pushl $20
801071ee:	6a 14                	push   $0x14
  jmp alltraps
801071f0:	e9 ed f8 ff ff       	jmp    80106ae2 <alltraps>

801071f5 <vector21>:
.globl vector21
vector21:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $21
801071f7:	6a 15                	push   $0x15
  jmp alltraps
801071f9:	e9 e4 f8 ff ff       	jmp    80106ae2 <alltraps>

801071fe <vector22>:
.globl vector22
vector22:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $22
80107200:	6a 16                	push   $0x16
  jmp alltraps
80107202:	e9 db f8 ff ff       	jmp    80106ae2 <alltraps>

80107207 <vector23>:
.globl vector23
vector23:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $23
80107209:	6a 17                	push   $0x17
  jmp alltraps
8010720b:	e9 d2 f8 ff ff       	jmp    80106ae2 <alltraps>

80107210 <vector24>:
.globl vector24
vector24:
  pushl $0
80107210:	6a 00                	push   $0x0
  pushl $24
80107212:	6a 18                	push   $0x18
  jmp alltraps
80107214:	e9 c9 f8 ff ff       	jmp    80106ae2 <alltraps>

80107219 <vector25>:
.globl vector25
vector25:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $25
8010721b:	6a 19                	push   $0x19
  jmp alltraps
8010721d:	e9 c0 f8 ff ff       	jmp    80106ae2 <alltraps>

80107222 <vector26>:
.globl vector26
vector26:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $26
80107224:	6a 1a                	push   $0x1a
  jmp alltraps
80107226:	e9 b7 f8 ff ff       	jmp    80106ae2 <alltraps>

8010722b <vector27>:
.globl vector27
vector27:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $27
8010722d:	6a 1b                	push   $0x1b
  jmp alltraps
8010722f:	e9 ae f8 ff ff       	jmp    80106ae2 <alltraps>

80107234 <vector28>:
.globl vector28
vector28:
  pushl $0
80107234:	6a 00                	push   $0x0
  pushl $28
80107236:	6a 1c                	push   $0x1c
  jmp alltraps
80107238:	e9 a5 f8 ff ff       	jmp    80106ae2 <alltraps>

8010723d <vector29>:
.globl vector29
vector29:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $29
8010723f:	6a 1d                	push   $0x1d
  jmp alltraps
80107241:	e9 9c f8 ff ff       	jmp    80106ae2 <alltraps>

80107246 <vector30>:
.globl vector30
vector30:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $30
80107248:	6a 1e                	push   $0x1e
  jmp alltraps
8010724a:	e9 93 f8 ff ff       	jmp    80106ae2 <alltraps>

8010724f <vector31>:
.globl vector31
vector31:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $31
80107251:	6a 1f                	push   $0x1f
  jmp alltraps
80107253:	e9 8a f8 ff ff       	jmp    80106ae2 <alltraps>

80107258 <vector32>:
.globl vector32
vector32:
  pushl $0
80107258:	6a 00                	push   $0x0
  pushl $32
8010725a:	6a 20                	push   $0x20
  jmp alltraps
8010725c:	e9 81 f8 ff ff       	jmp    80106ae2 <alltraps>

80107261 <vector33>:
.globl vector33
vector33:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $33
80107263:	6a 21                	push   $0x21
  jmp alltraps
80107265:	e9 78 f8 ff ff       	jmp    80106ae2 <alltraps>

8010726a <vector34>:
.globl vector34
vector34:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $34
8010726c:	6a 22                	push   $0x22
  jmp alltraps
8010726e:	e9 6f f8 ff ff       	jmp    80106ae2 <alltraps>

80107273 <vector35>:
.globl vector35
vector35:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $35
80107275:	6a 23                	push   $0x23
  jmp alltraps
80107277:	e9 66 f8 ff ff       	jmp    80106ae2 <alltraps>

8010727c <vector36>:
.globl vector36
vector36:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $36
8010727e:	6a 24                	push   $0x24
  jmp alltraps
80107280:	e9 5d f8 ff ff       	jmp    80106ae2 <alltraps>

80107285 <vector37>:
.globl vector37
vector37:
  pushl $0
80107285:	6a 00                	push   $0x0
  pushl $37
80107287:	6a 25                	push   $0x25
  jmp alltraps
80107289:	e9 54 f8 ff ff       	jmp    80106ae2 <alltraps>

8010728e <vector38>:
.globl vector38
vector38:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $38
80107290:	6a 26                	push   $0x26
  jmp alltraps
80107292:	e9 4b f8 ff ff       	jmp    80106ae2 <alltraps>

80107297 <vector39>:
.globl vector39
vector39:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $39
80107299:	6a 27                	push   $0x27
  jmp alltraps
8010729b:	e9 42 f8 ff ff       	jmp    80106ae2 <alltraps>

801072a0 <vector40>:
.globl vector40
vector40:
  pushl $0
801072a0:	6a 00                	push   $0x0
  pushl $40
801072a2:	6a 28                	push   $0x28
  jmp alltraps
801072a4:	e9 39 f8 ff ff       	jmp    80106ae2 <alltraps>

801072a9 <vector41>:
.globl vector41
vector41:
  pushl $0
801072a9:	6a 00                	push   $0x0
  pushl $41
801072ab:	6a 29                	push   $0x29
  jmp alltraps
801072ad:	e9 30 f8 ff ff       	jmp    80106ae2 <alltraps>

801072b2 <vector42>:
.globl vector42
vector42:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $42
801072b4:	6a 2a                	push   $0x2a
  jmp alltraps
801072b6:	e9 27 f8 ff ff       	jmp    80106ae2 <alltraps>

801072bb <vector43>:
.globl vector43
vector43:
  pushl $0
801072bb:	6a 00                	push   $0x0
  pushl $43
801072bd:	6a 2b                	push   $0x2b
  jmp alltraps
801072bf:	e9 1e f8 ff ff       	jmp    80106ae2 <alltraps>

801072c4 <vector44>:
.globl vector44
vector44:
  pushl $0
801072c4:	6a 00                	push   $0x0
  pushl $44
801072c6:	6a 2c                	push   $0x2c
  jmp alltraps
801072c8:	e9 15 f8 ff ff       	jmp    80106ae2 <alltraps>

801072cd <vector45>:
.globl vector45
vector45:
  pushl $0
801072cd:	6a 00                	push   $0x0
  pushl $45
801072cf:	6a 2d                	push   $0x2d
  jmp alltraps
801072d1:	e9 0c f8 ff ff       	jmp    80106ae2 <alltraps>

801072d6 <vector46>:
.globl vector46
vector46:
  pushl $0
801072d6:	6a 00                	push   $0x0
  pushl $46
801072d8:	6a 2e                	push   $0x2e
  jmp alltraps
801072da:	e9 03 f8 ff ff       	jmp    80106ae2 <alltraps>

801072df <vector47>:
.globl vector47
vector47:
  pushl $0
801072df:	6a 00                	push   $0x0
  pushl $47
801072e1:	6a 2f                	push   $0x2f
  jmp alltraps
801072e3:	e9 fa f7 ff ff       	jmp    80106ae2 <alltraps>

801072e8 <vector48>:
.globl vector48
vector48:
  pushl $0
801072e8:	6a 00                	push   $0x0
  pushl $48
801072ea:	6a 30                	push   $0x30
  jmp alltraps
801072ec:	e9 f1 f7 ff ff       	jmp    80106ae2 <alltraps>

801072f1 <vector49>:
.globl vector49
vector49:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $49
801072f3:	6a 31                	push   $0x31
  jmp alltraps
801072f5:	e9 e8 f7 ff ff       	jmp    80106ae2 <alltraps>

801072fa <vector50>:
.globl vector50
vector50:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $50
801072fc:	6a 32                	push   $0x32
  jmp alltraps
801072fe:	e9 df f7 ff ff       	jmp    80106ae2 <alltraps>

80107303 <vector51>:
.globl vector51
vector51:
  pushl $0
80107303:	6a 00                	push   $0x0
  pushl $51
80107305:	6a 33                	push   $0x33
  jmp alltraps
80107307:	e9 d6 f7 ff ff       	jmp    80106ae2 <alltraps>

8010730c <vector52>:
.globl vector52
vector52:
  pushl $0
8010730c:	6a 00                	push   $0x0
  pushl $52
8010730e:	6a 34                	push   $0x34
  jmp alltraps
80107310:	e9 cd f7 ff ff       	jmp    80106ae2 <alltraps>

80107315 <vector53>:
.globl vector53
vector53:
  pushl $0
80107315:	6a 00                	push   $0x0
  pushl $53
80107317:	6a 35                	push   $0x35
  jmp alltraps
80107319:	e9 c4 f7 ff ff       	jmp    80106ae2 <alltraps>

8010731e <vector54>:
.globl vector54
vector54:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $54
80107320:	6a 36                	push   $0x36
  jmp alltraps
80107322:	e9 bb f7 ff ff       	jmp    80106ae2 <alltraps>

80107327 <vector55>:
.globl vector55
vector55:
  pushl $0
80107327:	6a 00                	push   $0x0
  pushl $55
80107329:	6a 37                	push   $0x37
  jmp alltraps
8010732b:	e9 b2 f7 ff ff       	jmp    80106ae2 <alltraps>

80107330 <vector56>:
.globl vector56
vector56:
  pushl $0
80107330:	6a 00                	push   $0x0
  pushl $56
80107332:	6a 38                	push   $0x38
  jmp alltraps
80107334:	e9 a9 f7 ff ff       	jmp    80106ae2 <alltraps>

80107339 <vector57>:
.globl vector57
vector57:
  pushl $0
80107339:	6a 00                	push   $0x0
  pushl $57
8010733b:	6a 39                	push   $0x39
  jmp alltraps
8010733d:	e9 a0 f7 ff ff       	jmp    80106ae2 <alltraps>

80107342 <vector58>:
.globl vector58
vector58:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $58
80107344:	6a 3a                	push   $0x3a
  jmp alltraps
80107346:	e9 97 f7 ff ff       	jmp    80106ae2 <alltraps>

8010734b <vector59>:
.globl vector59
vector59:
  pushl $0
8010734b:	6a 00                	push   $0x0
  pushl $59
8010734d:	6a 3b                	push   $0x3b
  jmp alltraps
8010734f:	e9 8e f7 ff ff       	jmp    80106ae2 <alltraps>

80107354 <vector60>:
.globl vector60
vector60:
  pushl $0
80107354:	6a 00                	push   $0x0
  pushl $60
80107356:	6a 3c                	push   $0x3c
  jmp alltraps
80107358:	e9 85 f7 ff ff       	jmp    80106ae2 <alltraps>

8010735d <vector61>:
.globl vector61
vector61:
  pushl $0
8010735d:	6a 00                	push   $0x0
  pushl $61
8010735f:	6a 3d                	push   $0x3d
  jmp alltraps
80107361:	e9 7c f7 ff ff       	jmp    80106ae2 <alltraps>

80107366 <vector62>:
.globl vector62
vector62:
  pushl $0
80107366:	6a 00                	push   $0x0
  pushl $62
80107368:	6a 3e                	push   $0x3e
  jmp alltraps
8010736a:	e9 73 f7 ff ff       	jmp    80106ae2 <alltraps>

8010736f <vector63>:
.globl vector63
vector63:
  pushl $0
8010736f:	6a 00                	push   $0x0
  pushl $63
80107371:	6a 3f                	push   $0x3f
  jmp alltraps
80107373:	e9 6a f7 ff ff       	jmp    80106ae2 <alltraps>

80107378 <vector64>:
.globl vector64
vector64:
  pushl $0
80107378:	6a 00                	push   $0x0
  pushl $64
8010737a:	6a 40                	push   $0x40
  jmp alltraps
8010737c:	e9 61 f7 ff ff       	jmp    80106ae2 <alltraps>

80107381 <vector65>:
.globl vector65
vector65:
  pushl $0
80107381:	6a 00                	push   $0x0
  pushl $65
80107383:	6a 41                	push   $0x41
  jmp alltraps
80107385:	e9 58 f7 ff ff       	jmp    80106ae2 <alltraps>

8010738a <vector66>:
.globl vector66
vector66:
  pushl $0
8010738a:	6a 00                	push   $0x0
  pushl $66
8010738c:	6a 42                	push   $0x42
  jmp alltraps
8010738e:	e9 4f f7 ff ff       	jmp    80106ae2 <alltraps>

80107393 <vector67>:
.globl vector67
vector67:
  pushl $0
80107393:	6a 00                	push   $0x0
  pushl $67
80107395:	6a 43                	push   $0x43
  jmp alltraps
80107397:	e9 46 f7 ff ff       	jmp    80106ae2 <alltraps>

8010739c <vector68>:
.globl vector68
vector68:
  pushl $0
8010739c:	6a 00                	push   $0x0
  pushl $68
8010739e:	6a 44                	push   $0x44
  jmp alltraps
801073a0:	e9 3d f7 ff ff       	jmp    80106ae2 <alltraps>

801073a5 <vector69>:
.globl vector69
vector69:
  pushl $0
801073a5:	6a 00                	push   $0x0
  pushl $69
801073a7:	6a 45                	push   $0x45
  jmp alltraps
801073a9:	e9 34 f7 ff ff       	jmp    80106ae2 <alltraps>

801073ae <vector70>:
.globl vector70
vector70:
  pushl $0
801073ae:	6a 00                	push   $0x0
  pushl $70
801073b0:	6a 46                	push   $0x46
  jmp alltraps
801073b2:	e9 2b f7 ff ff       	jmp    80106ae2 <alltraps>

801073b7 <vector71>:
.globl vector71
vector71:
  pushl $0
801073b7:	6a 00                	push   $0x0
  pushl $71
801073b9:	6a 47                	push   $0x47
  jmp alltraps
801073bb:	e9 22 f7 ff ff       	jmp    80106ae2 <alltraps>

801073c0 <vector72>:
.globl vector72
vector72:
  pushl $0
801073c0:	6a 00                	push   $0x0
  pushl $72
801073c2:	6a 48                	push   $0x48
  jmp alltraps
801073c4:	e9 19 f7 ff ff       	jmp    80106ae2 <alltraps>

801073c9 <vector73>:
.globl vector73
vector73:
  pushl $0
801073c9:	6a 00                	push   $0x0
  pushl $73
801073cb:	6a 49                	push   $0x49
  jmp alltraps
801073cd:	e9 10 f7 ff ff       	jmp    80106ae2 <alltraps>

801073d2 <vector74>:
.globl vector74
vector74:
  pushl $0
801073d2:	6a 00                	push   $0x0
  pushl $74
801073d4:	6a 4a                	push   $0x4a
  jmp alltraps
801073d6:	e9 07 f7 ff ff       	jmp    80106ae2 <alltraps>

801073db <vector75>:
.globl vector75
vector75:
  pushl $0
801073db:	6a 00                	push   $0x0
  pushl $75
801073dd:	6a 4b                	push   $0x4b
  jmp alltraps
801073df:	e9 fe f6 ff ff       	jmp    80106ae2 <alltraps>

801073e4 <vector76>:
.globl vector76
vector76:
  pushl $0
801073e4:	6a 00                	push   $0x0
  pushl $76
801073e6:	6a 4c                	push   $0x4c
  jmp alltraps
801073e8:	e9 f5 f6 ff ff       	jmp    80106ae2 <alltraps>

801073ed <vector77>:
.globl vector77
vector77:
  pushl $0
801073ed:	6a 00                	push   $0x0
  pushl $77
801073ef:	6a 4d                	push   $0x4d
  jmp alltraps
801073f1:	e9 ec f6 ff ff       	jmp    80106ae2 <alltraps>

801073f6 <vector78>:
.globl vector78
vector78:
  pushl $0
801073f6:	6a 00                	push   $0x0
  pushl $78
801073f8:	6a 4e                	push   $0x4e
  jmp alltraps
801073fa:	e9 e3 f6 ff ff       	jmp    80106ae2 <alltraps>

801073ff <vector79>:
.globl vector79
vector79:
  pushl $0
801073ff:	6a 00                	push   $0x0
  pushl $79
80107401:	6a 4f                	push   $0x4f
  jmp alltraps
80107403:	e9 da f6 ff ff       	jmp    80106ae2 <alltraps>

80107408 <vector80>:
.globl vector80
vector80:
  pushl $0
80107408:	6a 00                	push   $0x0
  pushl $80
8010740a:	6a 50                	push   $0x50
  jmp alltraps
8010740c:	e9 d1 f6 ff ff       	jmp    80106ae2 <alltraps>

80107411 <vector81>:
.globl vector81
vector81:
  pushl $0
80107411:	6a 00                	push   $0x0
  pushl $81
80107413:	6a 51                	push   $0x51
  jmp alltraps
80107415:	e9 c8 f6 ff ff       	jmp    80106ae2 <alltraps>

8010741a <vector82>:
.globl vector82
vector82:
  pushl $0
8010741a:	6a 00                	push   $0x0
  pushl $82
8010741c:	6a 52                	push   $0x52
  jmp alltraps
8010741e:	e9 bf f6 ff ff       	jmp    80106ae2 <alltraps>

80107423 <vector83>:
.globl vector83
vector83:
  pushl $0
80107423:	6a 00                	push   $0x0
  pushl $83
80107425:	6a 53                	push   $0x53
  jmp alltraps
80107427:	e9 b6 f6 ff ff       	jmp    80106ae2 <alltraps>

8010742c <vector84>:
.globl vector84
vector84:
  pushl $0
8010742c:	6a 00                	push   $0x0
  pushl $84
8010742e:	6a 54                	push   $0x54
  jmp alltraps
80107430:	e9 ad f6 ff ff       	jmp    80106ae2 <alltraps>

80107435 <vector85>:
.globl vector85
vector85:
  pushl $0
80107435:	6a 00                	push   $0x0
  pushl $85
80107437:	6a 55                	push   $0x55
  jmp alltraps
80107439:	e9 a4 f6 ff ff       	jmp    80106ae2 <alltraps>

8010743e <vector86>:
.globl vector86
vector86:
  pushl $0
8010743e:	6a 00                	push   $0x0
  pushl $86
80107440:	6a 56                	push   $0x56
  jmp alltraps
80107442:	e9 9b f6 ff ff       	jmp    80106ae2 <alltraps>

80107447 <vector87>:
.globl vector87
vector87:
  pushl $0
80107447:	6a 00                	push   $0x0
  pushl $87
80107449:	6a 57                	push   $0x57
  jmp alltraps
8010744b:	e9 92 f6 ff ff       	jmp    80106ae2 <alltraps>

80107450 <vector88>:
.globl vector88
vector88:
  pushl $0
80107450:	6a 00                	push   $0x0
  pushl $88
80107452:	6a 58                	push   $0x58
  jmp alltraps
80107454:	e9 89 f6 ff ff       	jmp    80106ae2 <alltraps>

80107459 <vector89>:
.globl vector89
vector89:
  pushl $0
80107459:	6a 00                	push   $0x0
  pushl $89
8010745b:	6a 59                	push   $0x59
  jmp alltraps
8010745d:	e9 80 f6 ff ff       	jmp    80106ae2 <alltraps>

80107462 <vector90>:
.globl vector90
vector90:
  pushl $0
80107462:	6a 00                	push   $0x0
  pushl $90
80107464:	6a 5a                	push   $0x5a
  jmp alltraps
80107466:	e9 77 f6 ff ff       	jmp    80106ae2 <alltraps>

8010746b <vector91>:
.globl vector91
vector91:
  pushl $0
8010746b:	6a 00                	push   $0x0
  pushl $91
8010746d:	6a 5b                	push   $0x5b
  jmp alltraps
8010746f:	e9 6e f6 ff ff       	jmp    80106ae2 <alltraps>

80107474 <vector92>:
.globl vector92
vector92:
  pushl $0
80107474:	6a 00                	push   $0x0
  pushl $92
80107476:	6a 5c                	push   $0x5c
  jmp alltraps
80107478:	e9 65 f6 ff ff       	jmp    80106ae2 <alltraps>

8010747d <vector93>:
.globl vector93
vector93:
  pushl $0
8010747d:	6a 00                	push   $0x0
  pushl $93
8010747f:	6a 5d                	push   $0x5d
  jmp alltraps
80107481:	e9 5c f6 ff ff       	jmp    80106ae2 <alltraps>

80107486 <vector94>:
.globl vector94
vector94:
  pushl $0
80107486:	6a 00                	push   $0x0
  pushl $94
80107488:	6a 5e                	push   $0x5e
  jmp alltraps
8010748a:	e9 53 f6 ff ff       	jmp    80106ae2 <alltraps>

8010748f <vector95>:
.globl vector95
vector95:
  pushl $0
8010748f:	6a 00                	push   $0x0
  pushl $95
80107491:	6a 5f                	push   $0x5f
  jmp alltraps
80107493:	e9 4a f6 ff ff       	jmp    80106ae2 <alltraps>

80107498 <vector96>:
.globl vector96
vector96:
  pushl $0
80107498:	6a 00                	push   $0x0
  pushl $96
8010749a:	6a 60                	push   $0x60
  jmp alltraps
8010749c:	e9 41 f6 ff ff       	jmp    80106ae2 <alltraps>

801074a1 <vector97>:
.globl vector97
vector97:
  pushl $0
801074a1:	6a 00                	push   $0x0
  pushl $97
801074a3:	6a 61                	push   $0x61
  jmp alltraps
801074a5:	e9 38 f6 ff ff       	jmp    80106ae2 <alltraps>

801074aa <vector98>:
.globl vector98
vector98:
  pushl $0
801074aa:	6a 00                	push   $0x0
  pushl $98
801074ac:	6a 62                	push   $0x62
  jmp alltraps
801074ae:	e9 2f f6 ff ff       	jmp    80106ae2 <alltraps>

801074b3 <vector99>:
.globl vector99
vector99:
  pushl $0
801074b3:	6a 00                	push   $0x0
  pushl $99
801074b5:	6a 63                	push   $0x63
  jmp alltraps
801074b7:	e9 26 f6 ff ff       	jmp    80106ae2 <alltraps>

801074bc <vector100>:
.globl vector100
vector100:
  pushl $0
801074bc:	6a 00                	push   $0x0
  pushl $100
801074be:	6a 64                	push   $0x64
  jmp alltraps
801074c0:	e9 1d f6 ff ff       	jmp    80106ae2 <alltraps>

801074c5 <vector101>:
.globl vector101
vector101:
  pushl $0
801074c5:	6a 00                	push   $0x0
  pushl $101
801074c7:	6a 65                	push   $0x65
  jmp alltraps
801074c9:	e9 14 f6 ff ff       	jmp    80106ae2 <alltraps>

801074ce <vector102>:
.globl vector102
vector102:
  pushl $0
801074ce:	6a 00                	push   $0x0
  pushl $102
801074d0:	6a 66                	push   $0x66
  jmp alltraps
801074d2:	e9 0b f6 ff ff       	jmp    80106ae2 <alltraps>

801074d7 <vector103>:
.globl vector103
vector103:
  pushl $0
801074d7:	6a 00                	push   $0x0
  pushl $103
801074d9:	6a 67                	push   $0x67
  jmp alltraps
801074db:	e9 02 f6 ff ff       	jmp    80106ae2 <alltraps>

801074e0 <vector104>:
.globl vector104
vector104:
  pushl $0
801074e0:	6a 00                	push   $0x0
  pushl $104
801074e2:	6a 68                	push   $0x68
  jmp alltraps
801074e4:	e9 f9 f5 ff ff       	jmp    80106ae2 <alltraps>

801074e9 <vector105>:
.globl vector105
vector105:
  pushl $0
801074e9:	6a 00                	push   $0x0
  pushl $105
801074eb:	6a 69                	push   $0x69
  jmp alltraps
801074ed:	e9 f0 f5 ff ff       	jmp    80106ae2 <alltraps>

801074f2 <vector106>:
.globl vector106
vector106:
  pushl $0
801074f2:	6a 00                	push   $0x0
  pushl $106
801074f4:	6a 6a                	push   $0x6a
  jmp alltraps
801074f6:	e9 e7 f5 ff ff       	jmp    80106ae2 <alltraps>

801074fb <vector107>:
.globl vector107
vector107:
  pushl $0
801074fb:	6a 00                	push   $0x0
  pushl $107
801074fd:	6a 6b                	push   $0x6b
  jmp alltraps
801074ff:	e9 de f5 ff ff       	jmp    80106ae2 <alltraps>

80107504 <vector108>:
.globl vector108
vector108:
  pushl $0
80107504:	6a 00                	push   $0x0
  pushl $108
80107506:	6a 6c                	push   $0x6c
  jmp alltraps
80107508:	e9 d5 f5 ff ff       	jmp    80106ae2 <alltraps>

8010750d <vector109>:
.globl vector109
vector109:
  pushl $0
8010750d:	6a 00                	push   $0x0
  pushl $109
8010750f:	6a 6d                	push   $0x6d
  jmp alltraps
80107511:	e9 cc f5 ff ff       	jmp    80106ae2 <alltraps>

80107516 <vector110>:
.globl vector110
vector110:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $110
80107518:	6a 6e                	push   $0x6e
  jmp alltraps
8010751a:	e9 c3 f5 ff ff       	jmp    80106ae2 <alltraps>

8010751f <vector111>:
.globl vector111
vector111:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $111
80107521:	6a 6f                	push   $0x6f
  jmp alltraps
80107523:	e9 ba f5 ff ff       	jmp    80106ae2 <alltraps>

80107528 <vector112>:
.globl vector112
vector112:
  pushl $0
80107528:	6a 00                	push   $0x0
  pushl $112
8010752a:	6a 70                	push   $0x70
  jmp alltraps
8010752c:	e9 b1 f5 ff ff       	jmp    80106ae2 <alltraps>

80107531 <vector113>:
.globl vector113
vector113:
  pushl $0
80107531:	6a 00                	push   $0x0
  pushl $113
80107533:	6a 71                	push   $0x71
  jmp alltraps
80107535:	e9 a8 f5 ff ff       	jmp    80106ae2 <alltraps>

8010753a <vector114>:
.globl vector114
vector114:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $114
8010753c:	6a 72                	push   $0x72
  jmp alltraps
8010753e:	e9 9f f5 ff ff       	jmp    80106ae2 <alltraps>

80107543 <vector115>:
.globl vector115
vector115:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $115
80107545:	6a 73                	push   $0x73
  jmp alltraps
80107547:	e9 96 f5 ff ff       	jmp    80106ae2 <alltraps>

8010754c <vector116>:
.globl vector116
vector116:
  pushl $0
8010754c:	6a 00                	push   $0x0
  pushl $116
8010754e:	6a 74                	push   $0x74
  jmp alltraps
80107550:	e9 8d f5 ff ff       	jmp    80106ae2 <alltraps>

80107555 <vector117>:
.globl vector117
vector117:
  pushl $0
80107555:	6a 00                	push   $0x0
  pushl $117
80107557:	6a 75                	push   $0x75
  jmp alltraps
80107559:	e9 84 f5 ff ff       	jmp    80106ae2 <alltraps>

8010755e <vector118>:
.globl vector118
vector118:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $118
80107560:	6a 76                	push   $0x76
  jmp alltraps
80107562:	e9 7b f5 ff ff       	jmp    80106ae2 <alltraps>

80107567 <vector119>:
.globl vector119
vector119:
  pushl $0
80107567:	6a 00                	push   $0x0
  pushl $119
80107569:	6a 77                	push   $0x77
  jmp alltraps
8010756b:	e9 72 f5 ff ff       	jmp    80106ae2 <alltraps>

80107570 <vector120>:
.globl vector120
vector120:
  pushl $0
80107570:	6a 00                	push   $0x0
  pushl $120
80107572:	6a 78                	push   $0x78
  jmp alltraps
80107574:	e9 69 f5 ff ff       	jmp    80106ae2 <alltraps>

80107579 <vector121>:
.globl vector121
vector121:
  pushl $0
80107579:	6a 00                	push   $0x0
  pushl $121
8010757b:	6a 79                	push   $0x79
  jmp alltraps
8010757d:	e9 60 f5 ff ff       	jmp    80106ae2 <alltraps>

80107582 <vector122>:
.globl vector122
vector122:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $122
80107584:	6a 7a                	push   $0x7a
  jmp alltraps
80107586:	e9 57 f5 ff ff       	jmp    80106ae2 <alltraps>

8010758b <vector123>:
.globl vector123
vector123:
  pushl $0
8010758b:	6a 00                	push   $0x0
  pushl $123
8010758d:	6a 7b                	push   $0x7b
  jmp alltraps
8010758f:	e9 4e f5 ff ff       	jmp    80106ae2 <alltraps>

80107594 <vector124>:
.globl vector124
vector124:
  pushl $0
80107594:	6a 00                	push   $0x0
  pushl $124
80107596:	6a 7c                	push   $0x7c
  jmp alltraps
80107598:	e9 45 f5 ff ff       	jmp    80106ae2 <alltraps>

8010759d <vector125>:
.globl vector125
vector125:
  pushl $0
8010759d:	6a 00                	push   $0x0
  pushl $125
8010759f:	6a 7d                	push   $0x7d
  jmp alltraps
801075a1:	e9 3c f5 ff ff       	jmp    80106ae2 <alltraps>

801075a6 <vector126>:
.globl vector126
vector126:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $126
801075a8:	6a 7e                	push   $0x7e
  jmp alltraps
801075aa:	e9 33 f5 ff ff       	jmp    80106ae2 <alltraps>

801075af <vector127>:
.globl vector127
vector127:
  pushl $0
801075af:	6a 00                	push   $0x0
  pushl $127
801075b1:	6a 7f                	push   $0x7f
  jmp alltraps
801075b3:	e9 2a f5 ff ff       	jmp    80106ae2 <alltraps>

801075b8 <vector128>:
.globl vector128
vector128:
  pushl $0
801075b8:	6a 00                	push   $0x0
  pushl $128
801075ba:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801075bf:	e9 1e f5 ff ff       	jmp    80106ae2 <alltraps>

801075c4 <vector129>:
.globl vector129
vector129:
  pushl $0
801075c4:	6a 00                	push   $0x0
  pushl $129
801075c6:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801075cb:	e9 12 f5 ff ff       	jmp    80106ae2 <alltraps>

801075d0 <vector130>:
.globl vector130
vector130:
  pushl $0
801075d0:	6a 00                	push   $0x0
  pushl $130
801075d2:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801075d7:	e9 06 f5 ff ff       	jmp    80106ae2 <alltraps>

801075dc <vector131>:
.globl vector131
vector131:
  pushl $0
801075dc:	6a 00                	push   $0x0
  pushl $131
801075de:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801075e3:	e9 fa f4 ff ff       	jmp    80106ae2 <alltraps>

801075e8 <vector132>:
.globl vector132
vector132:
  pushl $0
801075e8:	6a 00                	push   $0x0
  pushl $132
801075ea:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801075ef:	e9 ee f4 ff ff       	jmp    80106ae2 <alltraps>

801075f4 <vector133>:
.globl vector133
vector133:
  pushl $0
801075f4:	6a 00                	push   $0x0
  pushl $133
801075f6:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801075fb:	e9 e2 f4 ff ff       	jmp    80106ae2 <alltraps>

80107600 <vector134>:
.globl vector134
vector134:
  pushl $0
80107600:	6a 00                	push   $0x0
  pushl $134
80107602:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107607:	e9 d6 f4 ff ff       	jmp    80106ae2 <alltraps>

8010760c <vector135>:
.globl vector135
vector135:
  pushl $0
8010760c:	6a 00                	push   $0x0
  pushl $135
8010760e:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107613:	e9 ca f4 ff ff       	jmp    80106ae2 <alltraps>

80107618 <vector136>:
.globl vector136
vector136:
  pushl $0
80107618:	6a 00                	push   $0x0
  pushl $136
8010761a:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010761f:	e9 be f4 ff ff       	jmp    80106ae2 <alltraps>

80107624 <vector137>:
.globl vector137
vector137:
  pushl $0
80107624:	6a 00                	push   $0x0
  pushl $137
80107626:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010762b:	e9 b2 f4 ff ff       	jmp    80106ae2 <alltraps>

80107630 <vector138>:
.globl vector138
vector138:
  pushl $0
80107630:	6a 00                	push   $0x0
  pushl $138
80107632:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107637:	e9 a6 f4 ff ff       	jmp    80106ae2 <alltraps>

8010763c <vector139>:
.globl vector139
vector139:
  pushl $0
8010763c:	6a 00                	push   $0x0
  pushl $139
8010763e:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107643:	e9 9a f4 ff ff       	jmp    80106ae2 <alltraps>

80107648 <vector140>:
.globl vector140
vector140:
  pushl $0
80107648:	6a 00                	push   $0x0
  pushl $140
8010764a:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010764f:	e9 8e f4 ff ff       	jmp    80106ae2 <alltraps>

80107654 <vector141>:
.globl vector141
vector141:
  pushl $0
80107654:	6a 00                	push   $0x0
  pushl $141
80107656:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010765b:	e9 82 f4 ff ff       	jmp    80106ae2 <alltraps>

80107660 <vector142>:
.globl vector142
vector142:
  pushl $0
80107660:	6a 00                	push   $0x0
  pushl $142
80107662:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107667:	e9 76 f4 ff ff       	jmp    80106ae2 <alltraps>

8010766c <vector143>:
.globl vector143
vector143:
  pushl $0
8010766c:	6a 00                	push   $0x0
  pushl $143
8010766e:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107673:	e9 6a f4 ff ff       	jmp    80106ae2 <alltraps>

80107678 <vector144>:
.globl vector144
vector144:
  pushl $0
80107678:	6a 00                	push   $0x0
  pushl $144
8010767a:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010767f:	e9 5e f4 ff ff       	jmp    80106ae2 <alltraps>

80107684 <vector145>:
.globl vector145
vector145:
  pushl $0
80107684:	6a 00                	push   $0x0
  pushl $145
80107686:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010768b:	e9 52 f4 ff ff       	jmp    80106ae2 <alltraps>

80107690 <vector146>:
.globl vector146
vector146:
  pushl $0
80107690:	6a 00                	push   $0x0
  pushl $146
80107692:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107697:	e9 46 f4 ff ff       	jmp    80106ae2 <alltraps>

8010769c <vector147>:
.globl vector147
vector147:
  pushl $0
8010769c:	6a 00                	push   $0x0
  pushl $147
8010769e:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801076a3:	e9 3a f4 ff ff       	jmp    80106ae2 <alltraps>

801076a8 <vector148>:
.globl vector148
vector148:
  pushl $0
801076a8:	6a 00                	push   $0x0
  pushl $148
801076aa:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801076af:	e9 2e f4 ff ff       	jmp    80106ae2 <alltraps>

801076b4 <vector149>:
.globl vector149
vector149:
  pushl $0
801076b4:	6a 00                	push   $0x0
  pushl $149
801076b6:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801076bb:	e9 22 f4 ff ff       	jmp    80106ae2 <alltraps>

801076c0 <vector150>:
.globl vector150
vector150:
  pushl $0
801076c0:	6a 00                	push   $0x0
  pushl $150
801076c2:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801076c7:	e9 16 f4 ff ff       	jmp    80106ae2 <alltraps>

801076cc <vector151>:
.globl vector151
vector151:
  pushl $0
801076cc:	6a 00                	push   $0x0
  pushl $151
801076ce:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801076d3:	e9 0a f4 ff ff       	jmp    80106ae2 <alltraps>

801076d8 <vector152>:
.globl vector152
vector152:
  pushl $0
801076d8:	6a 00                	push   $0x0
  pushl $152
801076da:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801076df:	e9 fe f3 ff ff       	jmp    80106ae2 <alltraps>

801076e4 <vector153>:
.globl vector153
vector153:
  pushl $0
801076e4:	6a 00                	push   $0x0
  pushl $153
801076e6:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801076eb:	e9 f2 f3 ff ff       	jmp    80106ae2 <alltraps>

801076f0 <vector154>:
.globl vector154
vector154:
  pushl $0
801076f0:	6a 00                	push   $0x0
  pushl $154
801076f2:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801076f7:	e9 e6 f3 ff ff       	jmp    80106ae2 <alltraps>

801076fc <vector155>:
.globl vector155
vector155:
  pushl $0
801076fc:	6a 00                	push   $0x0
  pushl $155
801076fe:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107703:	e9 da f3 ff ff       	jmp    80106ae2 <alltraps>

80107708 <vector156>:
.globl vector156
vector156:
  pushl $0
80107708:	6a 00                	push   $0x0
  pushl $156
8010770a:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010770f:	e9 ce f3 ff ff       	jmp    80106ae2 <alltraps>

80107714 <vector157>:
.globl vector157
vector157:
  pushl $0
80107714:	6a 00                	push   $0x0
  pushl $157
80107716:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010771b:	e9 c2 f3 ff ff       	jmp    80106ae2 <alltraps>

80107720 <vector158>:
.globl vector158
vector158:
  pushl $0
80107720:	6a 00                	push   $0x0
  pushl $158
80107722:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107727:	e9 b6 f3 ff ff       	jmp    80106ae2 <alltraps>

8010772c <vector159>:
.globl vector159
vector159:
  pushl $0
8010772c:	6a 00                	push   $0x0
  pushl $159
8010772e:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107733:	e9 aa f3 ff ff       	jmp    80106ae2 <alltraps>

80107738 <vector160>:
.globl vector160
vector160:
  pushl $0
80107738:	6a 00                	push   $0x0
  pushl $160
8010773a:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010773f:	e9 9e f3 ff ff       	jmp    80106ae2 <alltraps>

80107744 <vector161>:
.globl vector161
vector161:
  pushl $0
80107744:	6a 00                	push   $0x0
  pushl $161
80107746:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010774b:	e9 92 f3 ff ff       	jmp    80106ae2 <alltraps>

80107750 <vector162>:
.globl vector162
vector162:
  pushl $0
80107750:	6a 00                	push   $0x0
  pushl $162
80107752:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107757:	e9 86 f3 ff ff       	jmp    80106ae2 <alltraps>

8010775c <vector163>:
.globl vector163
vector163:
  pushl $0
8010775c:	6a 00                	push   $0x0
  pushl $163
8010775e:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107763:	e9 7a f3 ff ff       	jmp    80106ae2 <alltraps>

80107768 <vector164>:
.globl vector164
vector164:
  pushl $0
80107768:	6a 00                	push   $0x0
  pushl $164
8010776a:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010776f:	e9 6e f3 ff ff       	jmp    80106ae2 <alltraps>

80107774 <vector165>:
.globl vector165
vector165:
  pushl $0
80107774:	6a 00                	push   $0x0
  pushl $165
80107776:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010777b:	e9 62 f3 ff ff       	jmp    80106ae2 <alltraps>

80107780 <vector166>:
.globl vector166
vector166:
  pushl $0
80107780:	6a 00                	push   $0x0
  pushl $166
80107782:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107787:	e9 56 f3 ff ff       	jmp    80106ae2 <alltraps>

8010778c <vector167>:
.globl vector167
vector167:
  pushl $0
8010778c:	6a 00                	push   $0x0
  pushl $167
8010778e:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107793:	e9 4a f3 ff ff       	jmp    80106ae2 <alltraps>

80107798 <vector168>:
.globl vector168
vector168:
  pushl $0
80107798:	6a 00                	push   $0x0
  pushl $168
8010779a:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010779f:	e9 3e f3 ff ff       	jmp    80106ae2 <alltraps>

801077a4 <vector169>:
.globl vector169
vector169:
  pushl $0
801077a4:	6a 00                	push   $0x0
  pushl $169
801077a6:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801077ab:	e9 32 f3 ff ff       	jmp    80106ae2 <alltraps>

801077b0 <vector170>:
.globl vector170
vector170:
  pushl $0
801077b0:	6a 00                	push   $0x0
  pushl $170
801077b2:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801077b7:	e9 26 f3 ff ff       	jmp    80106ae2 <alltraps>

801077bc <vector171>:
.globl vector171
vector171:
  pushl $0
801077bc:	6a 00                	push   $0x0
  pushl $171
801077be:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801077c3:	e9 1a f3 ff ff       	jmp    80106ae2 <alltraps>

801077c8 <vector172>:
.globl vector172
vector172:
  pushl $0
801077c8:	6a 00                	push   $0x0
  pushl $172
801077ca:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801077cf:	e9 0e f3 ff ff       	jmp    80106ae2 <alltraps>

801077d4 <vector173>:
.globl vector173
vector173:
  pushl $0
801077d4:	6a 00                	push   $0x0
  pushl $173
801077d6:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801077db:	e9 02 f3 ff ff       	jmp    80106ae2 <alltraps>

801077e0 <vector174>:
.globl vector174
vector174:
  pushl $0
801077e0:	6a 00                	push   $0x0
  pushl $174
801077e2:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801077e7:	e9 f6 f2 ff ff       	jmp    80106ae2 <alltraps>

801077ec <vector175>:
.globl vector175
vector175:
  pushl $0
801077ec:	6a 00                	push   $0x0
  pushl $175
801077ee:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801077f3:	e9 ea f2 ff ff       	jmp    80106ae2 <alltraps>

801077f8 <vector176>:
.globl vector176
vector176:
  pushl $0
801077f8:	6a 00                	push   $0x0
  pushl $176
801077fa:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801077ff:	e9 de f2 ff ff       	jmp    80106ae2 <alltraps>

80107804 <vector177>:
.globl vector177
vector177:
  pushl $0
80107804:	6a 00                	push   $0x0
  pushl $177
80107806:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010780b:	e9 d2 f2 ff ff       	jmp    80106ae2 <alltraps>

80107810 <vector178>:
.globl vector178
vector178:
  pushl $0
80107810:	6a 00                	push   $0x0
  pushl $178
80107812:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107817:	e9 c6 f2 ff ff       	jmp    80106ae2 <alltraps>

8010781c <vector179>:
.globl vector179
vector179:
  pushl $0
8010781c:	6a 00                	push   $0x0
  pushl $179
8010781e:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107823:	e9 ba f2 ff ff       	jmp    80106ae2 <alltraps>

80107828 <vector180>:
.globl vector180
vector180:
  pushl $0
80107828:	6a 00                	push   $0x0
  pushl $180
8010782a:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010782f:	e9 ae f2 ff ff       	jmp    80106ae2 <alltraps>

80107834 <vector181>:
.globl vector181
vector181:
  pushl $0
80107834:	6a 00                	push   $0x0
  pushl $181
80107836:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010783b:	e9 a2 f2 ff ff       	jmp    80106ae2 <alltraps>

80107840 <vector182>:
.globl vector182
vector182:
  pushl $0
80107840:	6a 00                	push   $0x0
  pushl $182
80107842:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107847:	e9 96 f2 ff ff       	jmp    80106ae2 <alltraps>

8010784c <vector183>:
.globl vector183
vector183:
  pushl $0
8010784c:	6a 00                	push   $0x0
  pushl $183
8010784e:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107853:	e9 8a f2 ff ff       	jmp    80106ae2 <alltraps>

80107858 <vector184>:
.globl vector184
vector184:
  pushl $0
80107858:	6a 00                	push   $0x0
  pushl $184
8010785a:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010785f:	e9 7e f2 ff ff       	jmp    80106ae2 <alltraps>

80107864 <vector185>:
.globl vector185
vector185:
  pushl $0
80107864:	6a 00                	push   $0x0
  pushl $185
80107866:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010786b:	e9 72 f2 ff ff       	jmp    80106ae2 <alltraps>

80107870 <vector186>:
.globl vector186
vector186:
  pushl $0
80107870:	6a 00                	push   $0x0
  pushl $186
80107872:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107877:	e9 66 f2 ff ff       	jmp    80106ae2 <alltraps>

8010787c <vector187>:
.globl vector187
vector187:
  pushl $0
8010787c:	6a 00                	push   $0x0
  pushl $187
8010787e:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107883:	e9 5a f2 ff ff       	jmp    80106ae2 <alltraps>

80107888 <vector188>:
.globl vector188
vector188:
  pushl $0
80107888:	6a 00                	push   $0x0
  pushl $188
8010788a:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010788f:	e9 4e f2 ff ff       	jmp    80106ae2 <alltraps>

80107894 <vector189>:
.globl vector189
vector189:
  pushl $0
80107894:	6a 00                	push   $0x0
  pushl $189
80107896:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010789b:	e9 42 f2 ff ff       	jmp    80106ae2 <alltraps>

801078a0 <vector190>:
.globl vector190
vector190:
  pushl $0
801078a0:	6a 00                	push   $0x0
  pushl $190
801078a2:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801078a7:	e9 36 f2 ff ff       	jmp    80106ae2 <alltraps>

801078ac <vector191>:
.globl vector191
vector191:
  pushl $0
801078ac:	6a 00                	push   $0x0
  pushl $191
801078ae:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801078b3:	e9 2a f2 ff ff       	jmp    80106ae2 <alltraps>

801078b8 <vector192>:
.globl vector192
vector192:
  pushl $0
801078b8:	6a 00                	push   $0x0
  pushl $192
801078ba:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801078bf:	e9 1e f2 ff ff       	jmp    80106ae2 <alltraps>

801078c4 <vector193>:
.globl vector193
vector193:
  pushl $0
801078c4:	6a 00                	push   $0x0
  pushl $193
801078c6:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801078cb:	e9 12 f2 ff ff       	jmp    80106ae2 <alltraps>

801078d0 <vector194>:
.globl vector194
vector194:
  pushl $0
801078d0:	6a 00                	push   $0x0
  pushl $194
801078d2:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801078d7:	e9 06 f2 ff ff       	jmp    80106ae2 <alltraps>

801078dc <vector195>:
.globl vector195
vector195:
  pushl $0
801078dc:	6a 00                	push   $0x0
  pushl $195
801078de:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801078e3:	e9 fa f1 ff ff       	jmp    80106ae2 <alltraps>

801078e8 <vector196>:
.globl vector196
vector196:
  pushl $0
801078e8:	6a 00                	push   $0x0
  pushl $196
801078ea:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801078ef:	e9 ee f1 ff ff       	jmp    80106ae2 <alltraps>

801078f4 <vector197>:
.globl vector197
vector197:
  pushl $0
801078f4:	6a 00                	push   $0x0
  pushl $197
801078f6:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801078fb:	e9 e2 f1 ff ff       	jmp    80106ae2 <alltraps>

80107900 <vector198>:
.globl vector198
vector198:
  pushl $0
80107900:	6a 00                	push   $0x0
  pushl $198
80107902:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107907:	e9 d6 f1 ff ff       	jmp    80106ae2 <alltraps>

8010790c <vector199>:
.globl vector199
vector199:
  pushl $0
8010790c:	6a 00                	push   $0x0
  pushl $199
8010790e:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107913:	e9 ca f1 ff ff       	jmp    80106ae2 <alltraps>

80107918 <vector200>:
.globl vector200
vector200:
  pushl $0
80107918:	6a 00                	push   $0x0
  pushl $200
8010791a:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010791f:	e9 be f1 ff ff       	jmp    80106ae2 <alltraps>

80107924 <vector201>:
.globl vector201
vector201:
  pushl $0
80107924:	6a 00                	push   $0x0
  pushl $201
80107926:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010792b:	e9 b2 f1 ff ff       	jmp    80106ae2 <alltraps>

80107930 <vector202>:
.globl vector202
vector202:
  pushl $0
80107930:	6a 00                	push   $0x0
  pushl $202
80107932:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107937:	e9 a6 f1 ff ff       	jmp    80106ae2 <alltraps>

8010793c <vector203>:
.globl vector203
vector203:
  pushl $0
8010793c:	6a 00                	push   $0x0
  pushl $203
8010793e:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107943:	e9 9a f1 ff ff       	jmp    80106ae2 <alltraps>

80107948 <vector204>:
.globl vector204
vector204:
  pushl $0
80107948:	6a 00                	push   $0x0
  pushl $204
8010794a:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010794f:	e9 8e f1 ff ff       	jmp    80106ae2 <alltraps>

80107954 <vector205>:
.globl vector205
vector205:
  pushl $0
80107954:	6a 00                	push   $0x0
  pushl $205
80107956:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010795b:	e9 82 f1 ff ff       	jmp    80106ae2 <alltraps>

80107960 <vector206>:
.globl vector206
vector206:
  pushl $0
80107960:	6a 00                	push   $0x0
  pushl $206
80107962:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107967:	e9 76 f1 ff ff       	jmp    80106ae2 <alltraps>

8010796c <vector207>:
.globl vector207
vector207:
  pushl $0
8010796c:	6a 00                	push   $0x0
  pushl $207
8010796e:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107973:	e9 6a f1 ff ff       	jmp    80106ae2 <alltraps>

80107978 <vector208>:
.globl vector208
vector208:
  pushl $0
80107978:	6a 00                	push   $0x0
  pushl $208
8010797a:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010797f:	e9 5e f1 ff ff       	jmp    80106ae2 <alltraps>

80107984 <vector209>:
.globl vector209
vector209:
  pushl $0
80107984:	6a 00                	push   $0x0
  pushl $209
80107986:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010798b:	e9 52 f1 ff ff       	jmp    80106ae2 <alltraps>

80107990 <vector210>:
.globl vector210
vector210:
  pushl $0
80107990:	6a 00                	push   $0x0
  pushl $210
80107992:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107997:	e9 46 f1 ff ff       	jmp    80106ae2 <alltraps>

8010799c <vector211>:
.globl vector211
vector211:
  pushl $0
8010799c:	6a 00                	push   $0x0
  pushl $211
8010799e:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801079a3:	e9 3a f1 ff ff       	jmp    80106ae2 <alltraps>

801079a8 <vector212>:
.globl vector212
vector212:
  pushl $0
801079a8:	6a 00                	push   $0x0
  pushl $212
801079aa:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801079af:	e9 2e f1 ff ff       	jmp    80106ae2 <alltraps>

801079b4 <vector213>:
.globl vector213
vector213:
  pushl $0
801079b4:	6a 00                	push   $0x0
  pushl $213
801079b6:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801079bb:	e9 22 f1 ff ff       	jmp    80106ae2 <alltraps>

801079c0 <vector214>:
.globl vector214
vector214:
  pushl $0
801079c0:	6a 00                	push   $0x0
  pushl $214
801079c2:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801079c7:	e9 16 f1 ff ff       	jmp    80106ae2 <alltraps>

801079cc <vector215>:
.globl vector215
vector215:
  pushl $0
801079cc:	6a 00                	push   $0x0
  pushl $215
801079ce:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801079d3:	e9 0a f1 ff ff       	jmp    80106ae2 <alltraps>

801079d8 <vector216>:
.globl vector216
vector216:
  pushl $0
801079d8:	6a 00                	push   $0x0
  pushl $216
801079da:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801079df:	e9 fe f0 ff ff       	jmp    80106ae2 <alltraps>

801079e4 <vector217>:
.globl vector217
vector217:
  pushl $0
801079e4:	6a 00                	push   $0x0
  pushl $217
801079e6:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801079eb:	e9 f2 f0 ff ff       	jmp    80106ae2 <alltraps>

801079f0 <vector218>:
.globl vector218
vector218:
  pushl $0
801079f0:	6a 00                	push   $0x0
  pushl $218
801079f2:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801079f7:	e9 e6 f0 ff ff       	jmp    80106ae2 <alltraps>

801079fc <vector219>:
.globl vector219
vector219:
  pushl $0
801079fc:	6a 00                	push   $0x0
  pushl $219
801079fe:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107a03:	e9 da f0 ff ff       	jmp    80106ae2 <alltraps>

80107a08 <vector220>:
.globl vector220
vector220:
  pushl $0
80107a08:	6a 00                	push   $0x0
  pushl $220
80107a0a:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107a0f:	e9 ce f0 ff ff       	jmp    80106ae2 <alltraps>

80107a14 <vector221>:
.globl vector221
vector221:
  pushl $0
80107a14:	6a 00                	push   $0x0
  pushl $221
80107a16:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107a1b:	e9 c2 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a20 <vector222>:
.globl vector222
vector222:
  pushl $0
80107a20:	6a 00                	push   $0x0
  pushl $222
80107a22:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a27:	e9 b6 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a2c <vector223>:
.globl vector223
vector223:
  pushl $0
80107a2c:	6a 00                	push   $0x0
  pushl $223
80107a2e:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a33:	e9 aa f0 ff ff       	jmp    80106ae2 <alltraps>

80107a38 <vector224>:
.globl vector224
vector224:
  pushl $0
80107a38:	6a 00                	push   $0x0
  pushl $224
80107a3a:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a3f:	e9 9e f0 ff ff       	jmp    80106ae2 <alltraps>

80107a44 <vector225>:
.globl vector225
vector225:
  pushl $0
80107a44:	6a 00                	push   $0x0
  pushl $225
80107a46:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a4b:	e9 92 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a50 <vector226>:
.globl vector226
vector226:
  pushl $0
80107a50:	6a 00                	push   $0x0
  pushl $226
80107a52:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a57:	e9 86 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a5c <vector227>:
.globl vector227
vector227:
  pushl $0
80107a5c:	6a 00                	push   $0x0
  pushl $227
80107a5e:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a63:	e9 7a f0 ff ff       	jmp    80106ae2 <alltraps>

80107a68 <vector228>:
.globl vector228
vector228:
  pushl $0
80107a68:	6a 00                	push   $0x0
  pushl $228
80107a6a:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a6f:	e9 6e f0 ff ff       	jmp    80106ae2 <alltraps>

80107a74 <vector229>:
.globl vector229
vector229:
  pushl $0
80107a74:	6a 00                	push   $0x0
  pushl $229
80107a76:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107a7b:	e9 62 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a80 <vector230>:
.globl vector230
vector230:
  pushl $0
80107a80:	6a 00                	push   $0x0
  pushl $230
80107a82:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107a87:	e9 56 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a8c <vector231>:
.globl vector231
vector231:
  pushl $0
80107a8c:	6a 00                	push   $0x0
  pushl $231
80107a8e:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107a93:	e9 4a f0 ff ff       	jmp    80106ae2 <alltraps>

80107a98 <vector232>:
.globl vector232
vector232:
  pushl $0
80107a98:	6a 00                	push   $0x0
  pushl $232
80107a9a:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107a9f:	e9 3e f0 ff ff       	jmp    80106ae2 <alltraps>

80107aa4 <vector233>:
.globl vector233
vector233:
  pushl $0
80107aa4:	6a 00                	push   $0x0
  pushl $233
80107aa6:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107aab:	e9 32 f0 ff ff       	jmp    80106ae2 <alltraps>

80107ab0 <vector234>:
.globl vector234
vector234:
  pushl $0
80107ab0:	6a 00                	push   $0x0
  pushl $234
80107ab2:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107ab7:	e9 26 f0 ff ff       	jmp    80106ae2 <alltraps>

80107abc <vector235>:
.globl vector235
vector235:
  pushl $0
80107abc:	6a 00                	push   $0x0
  pushl $235
80107abe:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107ac3:	e9 1a f0 ff ff       	jmp    80106ae2 <alltraps>

80107ac8 <vector236>:
.globl vector236
vector236:
  pushl $0
80107ac8:	6a 00                	push   $0x0
  pushl $236
80107aca:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107acf:	e9 0e f0 ff ff       	jmp    80106ae2 <alltraps>

80107ad4 <vector237>:
.globl vector237
vector237:
  pushl $0
80107ad4:	6a 00                	push   $0x0
  pushl $237
80107ad6:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107adb:	e9 02 f0 ff ff       	jmp    80106ae2 <alltraps>

80107ae0 <vector238>:
.globl vector238
vector238:
  pushl $0
80107ae0:	6a 00                	push   $0x0
  pushl $238
80107ae2:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107ae7:	e9 f6 ef ff ff       	jmp    80106ae2 <alltraps>

80107aec <vector239>:
.globl vector239
vector239:
  pushl $0
80107aec:	6a 00                	push   $0x0
  pushl $239
80107aee:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107af3:	e9 ea ef ff ff       	jmp    80106ae2 <alltraps>

80107af8 <vector240>:
.globl vector240
vector240:
  pushl $0
80107af8:	6a 00                	push   $0x0
  pushl $240
80107afa:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107aff:	e9 de ef ff ff       	jmp    80106ae2 <alltraps>

80107b04 <vector241>:
.globl vector241
vector241:
  pushl $0
80107b04:	6a 00                	push   $0x0
  pushl $241
80107b06:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107b0b:	e9 d2 ef ff ff       	jmp    80106ae2 <alltraps>

80107b10 <vector242>:
.globl vector242
vector242:
  pushl $0
80107b10:	6a 00                	push   $0x0
  pushl $242
80107b12:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107b17:	e9 c6 ef ff ff       	jmp    80106ae2 <alltraps>

80107b1c <vector243>:
.globl vector243
vector243:
  pushl $0
80107b1c:	6a 00                	push   $0x0
  pushl $243
80107b1e:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b23:	e9 ba ef ff ff       	jmp    80106ae2 <alltraps>

80107b28 <vector244>:
.globl vector244
vector244:
  pushl $0
80107b28:	6a 00                	push   $0x0
  pushl $244
80107b2a:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b2f:	e9 ae ef ff ff       	jmp    80106ae2 <alltraps>

80107b34 <vector245>:
.globl vector245
vector245:
  pushl $0
80107b34:	6a 00                	push   $0x0
  pushl $245
80107b36:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b3b:	e9 a2 ef ff ff       	jmp    80106ae2 <alltraps>

80107b40 <vector246>:
.globl vector246
vector246:
  pushl $0
80107b40:	6a 00                	push   $0x0
  pushl $246
80107b42:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b47:	e9 96 ef ff ff       	jmp    80106ae2 <alltraps>

80107b4c <vector247>:
.globl vector247
vector247:
  pushl $0
80107b4c:	6a 00                	push   $0x0
  pushl $247
80107b4e:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b53:	e9 8a ef ff ff       	jmp    80106ae2 <alltraps>

80107b58 <vector248>:
.globl vector248
vector248:
  pushl $0
80107b58:	6a 00                	push   $0x0
  pushl $248
80107b5a:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b5f:	e9 7e ef ff ff       	jmp    80106ae2 <alltraps>

80107b64 <vector249>:
.globl vector249
vector249:
  pushl $0
80107b64:	6a 00                	push   $0x0
  pushl $249
80107b66:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b6b:	e9 72 ef ff ff       	jmp    80106ae2 <alltraps>

80107b70 <vector250>:
.globl vector250
vector250:
  pushl $0
80107b70:	6a 00                	push   $0x0
  pushl $250
80107b72:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b77:	e9 66 ef ff ff       	jmp    80106ae2 <alltraps>

80107b7c <vector251>:
.globl vector251
vector251:
  pushl $0
80107b7c:	6a 00                	push   $0x0
  pushl $251
80107b7e:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107b83:	e9 5a ef ff ff       	jmp    80106ae2 <alltraps>

80107b88 <vector252>:
.globl vector252
vector252:
  pushl $0
80107b88:	6a 00                	push   $0x0
  pushl $252
80107b8a:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107b8f:	e9 4e ef ff ff       	jmp    80106ae2 <alltraps>

80107b94 <vector253>:
.globl vector253
vector253:
  pushl $0
80107b94:	6a 00                	push   $0x0
  pushl $253
80107b96:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107b9b:	e9 42 ef ff ff       	jmp    80106ae2 <alltraps>

80107ba0 <vector254>:
.globl vector254
vector254:
  pushl $0
80107ba0:	6a 00                	push   $0x0
  pushl $254
80107ba2:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107ba7:	e9 36 ef ff ff       	jmp    80106ae2 <alltraps>

80107bac <vector255>:
.globl vector255
vector255:
  pushl $0
80107bac:	6a 00                	push   $0x0
  pushl $255
80107bae:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107bb3:	e9 2a ef ff ff       	jmp    80106ae2 <alltraps>

80107bb8 <lgdt>:
{
80107bb8:	55                   	push   %ebp
80107bb9:	89 e5                	mov    %esp,%ebp
80107bbb:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bc1:	83 e8 01             	sub    $0x1,%eax
80107bc4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80107bcb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107bcf:	8b 45 08             	mov    0x8(%ebp),%eax
80107bd2:	c1 e8 10             	shr    $0x10,%eax
80107bd5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107bd9:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107bdc:	0f 01 10             	lgdtl  (%eax)
}
80107bdf:	90                   	nop
80107be0:	c9                   	leave  
80107be1:	c3                   	ret    

80107be2 <ltr>:
{
80107be2:	55                   	push   %ebp
80107be3:	89 e5                	mov    %esp,%ebp
80107be5:	83 ec 04             	sub    $0x4,%esp
80107be8:	8b 45 08             	mov    0x8(%ebp),%eax
80107beb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107bef:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107bf3:	0f 00 d8             	ltr    %ax
}
80107bf6:	90                   	nop
80107bf7:	c9                   	leave  
80107bf8:	c3                   	ret    

80107bf9 <lcr3>:

static inline void
lcr3(uint val)
{
80107bf9:	55                   	push   %ebp
80107bfa:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107bfc:	8b 45 08             	mov    0x8(%ebp),%eax
80107bff:	0f 22 d8             	mov    %eax,%cr3
}
80107c02:	90                   	nop
80107c03:	5d                   	pop    %ebp
80107c04:	c3                   	ret    

80107c05 <removepage>:
#include "mmu.h"
#include "proc.h"
#include "elf.h"


int removepage(char* va) {
80107c05:	f3 0f 1e fb          	endbr32 
80107c09:	55                   	push   %ebp
80107c0a:	89 e5                	mov    %esp,%ebp
80107c0c:	53                   	push   %ebx
80107c0d:	83 ec 14             	sub    $0x14,%esp
//  cprintf("in remvoe page");
  // panic("wloefbn");
  struct proc* curproc = myproc();
80107c10:	e8 9b c8 ff ff       	call   801044b0 <myproc>
80107c15:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(int i = 0; i < CLOCKSIZE; i++){
80107c18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c1f:	e9 d9 00 00 00       	jmp    80107cfd <removepage+0xf8>
    if(curproc->clock_queue[i].va == va){
80107c24:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107c2a:	83 c2 10             	add    $0x10,%edx
80107c2d:	8b 04 d0             	mov    (%eax,%edx,8),%eax
80107c30:	39 45 08             	cmp    %eax,0x8(%ebp)
80107c33:	0f 85 c0 00 00 00    	jne    80107cf9 <removepage+0xf4>

      for(int j = i; j+1 < curproc->queue_size; j++){
80107c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c3f:	eb 43                	jmp    80107c84 <removepage+0x7f>
       curproc->clock_queue[j] = curproc->clock_queue[j+1];
80107c41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c44:	8d 50 01             	lea    0x1(%eax),%edx
80107c47:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80107c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c4d:	8d 58 10             	lea    0x10(%eax),%ebx
80107c50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c53:	83 c2 10             	add    $0x10,%edx
80107c56:	8d 14 d0             	lea    (%eax,%edx,8),%edx
80107c59:	8b 02                	mov    (%edx),%eax
80107c5b:	8b 52 04             	mov    0x4(%edx),%edx
80107c5e:	89 04 d9             	mov    %eax,(%ecx,%ebx,8)
80107c61:	89 54 d9 04          	mov    %edx,0x4(%ecx,%ebx,8)
       curproc->clock_queue[j].va = curproc->clock_queue[j+1].va;
80107c65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c68:	8d 50 01             	lea    0x1(%eax),%edx
80107c6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c6e:	83 c2 10             	add    $0x10,%edx
80107c71:	8b 14 d0             	mov    (%eax,%edx,8),%edx
80107c74:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c77:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80107c7a:	83 c1 10             	add    $0x10,%ecx
80107c7d:	89 14 c8             	mov    %edx,(%eax,%ecx,8)
      for(int j = i; j+1 < curproc->queue_size; j++){
80107c80:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80107c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c87:	8d 50 01             	lea    0x1(%eax),%edx
80107c8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c8d:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
80107c93:	39 c2                	cmp    %eax,%edx
80107c95:	7c aa                	jl     80107c41 <removepage+0x3c>
     }

     curproc->queue_size--;
80107c97:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c9a:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
80107ca0:	8d 50 ff             	lea    -0x1(%eax),%edx
80107ca3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ca6:	89 90 c0 00 00 00    	mov    %edx,0xc0(%eax)

     if( curproc->hand > i)
80107cac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107caf:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
80107cb5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80107cb8:	7d 15                	jge    80107ccf <removepage+0xca>
       curproc->hand = curproc->hand - 1;
80107cba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cbd:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
80107cc3:	8d 50 ff             	lea    -0x1(%eax),%edx
80107cc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cc9:	89 90 c8 00 00 00    	mov    %edx,0xc8(%eax)
     if(curproc->hand==curproc->queue_size){
80107ccf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cd2:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
80107cd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cdb:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
80107ce1:	39 c2                	cmp    %eax,%edx
80107ce3:	75 0d                	jne    80107cf2 <removepage+0xed>
       curproc->hand=0;
80107ce5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ce8:	c7 80 c8 00 00 00 00 	movl   $0x0,0xc8(%eax)
80107cef:	00 00 00 
     }
     return 0;
80107cf2:	b8 00 00 00 00       	mov    $0x0,%eax
80107cf7:	eb 13                	jmp    80107d0c <removepage+0x107>
  for(int i = 0; i < CLOCKSIZE; i++){
80107cf9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107cfd:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80107d01:	0f 8e 1d ff ff ff    	jle    80107c24 <removepage+0x1f>
   }
 }
 return 0;
80107d07:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d0c:	83 c4 14             	add    $0x14,%esp
80107d0f:	5b                   	pop    %ebx
80107d10:	5d                   	pop    %ebp
80107d11:	c3                   	ret    

80107d12 <inwset>:
//   }
//   return 0;
// }


int inwset(char* va){
80107d12:	f3 0f 1e fb          	endbr32 
80107d16:	55                   	push   %ebp
80107d17:	89 e5                	mov    %esp,%ebp
80107d19:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80107d1c:	e8 8f c7 ff ff       	call   801044b0 <myproc>
80107d21:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(int i = 0; i < CLOCKSIZE; i++){
80107d24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d2b:	eb 1c                	jmp    80107d49 <inwset+0x37>
    if(curproc->clock_queue[i].va == va){
80107d2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d30:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107d33:	83 c2 10             	add    $0x10,%edx
80107d36:	8b 04 d0             	mov    (%eax,%edx,8),%eax
80107d39:	39 45 08             	cmp    %eax,0x8(%ebp)
80107d3c:	75 07                	jne    80107d45 <inwset+0x33>
      // cprintf("Found %p", va);
      return 1;
80107d3e:	b8 01 00 00 00       	mov    $0x1,%eax
80107d43:	eb 0f                	jmp    80107d54 <inwset+0x42>
  for(int i = 0; i < CLOCKSIZE; i++){
80107d45:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107d49:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80107d4d:	7e de                	jle    80107d2d <inwset+0x1b>
    }
  }
  return 0;
80107d4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d54:	c9                   	leave  
80107d55:	c3                   	ret    

80107d56 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107d56:	f3 0f 1e fb          	endbr32 
80107d5a:	55                   	push   %ebp
80107d5b:	89 e5                	mov    %esp,%ebp
80107d5d:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107d60:	e8 b0 c6 ff ff       	call   80104415 <cpuid>
80107d65:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107d6b:	05 20 48 11 80       	add    $0x80114820,%eax
80107d70:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d76:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d88:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d93:	83 e2 f0             	and    $0xfffffff0,%edx
80107d96:	83 ca 0a             	or     $0xa,%edx
80107d99:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107da3:	83 ca 10             	or     $0x10,%edx
80107da6:	88 50 7d             	mov    %dl,0x7d(%eax)
80107da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dac:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107db0:	83 e2 9f             	and    $0xffffff9f,%edx
80107db3:	88 50 7d             	mov    %dl,0x7d(%eax)
80107db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107dbd:	83 ca 80             	or     $0xffffff80,%edx
80107dc0:	88 50 7d             	mov    %dl,0x7d(%eax)
80107dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107dca:	83 ca 0f             	or     $0xf,%edx
80107dcd:	88 50 7e             	mov    %dl,0x7e(%eax)
80107dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107dd7:	83 e2 ef             	and    $0xffffffef,%edx
80107dda:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107de4:	83 e2 df             	and    $0xffffffdf,%edx
80107de7:	88 50 7e             	mov    %dl,0x7e(%eax)
80107dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ded:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107df1:	83 ca 40             	or     $0x40,%edx
80107df4:	88 50 7e             	mov    %dl,0x7e(%eax)
80107df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfa:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107dfe:	83 ca 80             	or     $0xffffff80,%edx
80107e01:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e07:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0e:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107e15:	ff ff 
80107e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1a:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107e21:	00 00 
80107e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e26:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e30:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107e37:	83 e2 f0             	and    $0xfffffff0,%edx
80107e3a:	83 ca 02             	or     $0x2,%edx
80107e3d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e46:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107e4d:	83 ca 10             	or     $0x10,%edx
80107e50:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e59:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107e60:	83 e2 9f             	and    $0xffffff9f,%edx
80107e63:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107e73:	83 ca 80             	or     $0xffffff80,%edx
80107e76:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e86:	83 ca 0f             	or     $0xf,%edx
80107e89:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e92:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e99:	83 e2 ef             	and    $0xffffffef,%edx
80107e9c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107eac:	83 e2 df             	and    $0xffffffdf,%edx
80107eaf:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ebf:	83 ca 40             	or     $0x40,%edx
80107ec2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ed2:	83 ca 80             	or     $0xffffff80,%edx
80107ed5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ede:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee8:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107eef:	ff ff 
80107ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef4:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107efb:	00 00 
80107efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f00:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107f11:	83 e2 f0             	and    $0xfffffff0,%edx
80107f14:	83 ca 0a             	or     $0xa,%edx
80107f17:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f20:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107f27:	83 ca 10             	or     $0x10,%edx
80107f2a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f33:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107f3a:	83 ca 60             	or     $0x60,%edx
80107f3d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f46:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107f4d:	83 ca 80             	or     $0xffffff80,%edx
80107f50:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f59:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f60:	83 ca 0f             	or     $0xf,%edx
80107f63:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f73:	83 e2 ef             	and    $0xffffffef,%edx
80107f76:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f86:	83 e2 df             	and    $0xffffffdf,%edx
80107f89:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f92:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f99:	83 ca 40             	or     $0x40,%edx
80107f9c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107fac:	83 ca 80             	or     $0xffffff80,%edx
80107faf:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb8:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc2:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107fc9:	ff ff 
80107fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fce:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107fd5:	00 00 
80107fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fda:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107feb:	83 e2 f0             	and    $0xfffffff0,%edx
80107fee:	83 ca 02             	or     $0x2,%edx
80107ff1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffa:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108001:	83 ca 10             	or     $0x10,%edx
80108004:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010800a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108014:	83 ca 60             	or     $0x60,%edx
80108017:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010801d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108020:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108027:	83 ca 80             	or     $0xffffff80,%edx
8010802a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108033:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010803a:	83 ca 0f             	or     $0xf,%edx
8010803d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108046:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010804d:	83 e2 ef             	and    $0xffffffef,%edx
80108050:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108059:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108060:	83 e2 df             	and    $0xffffffdf,%edx
80108063:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108073:	83 ca 40             	or     $0x40,%edx
80108076:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010807c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010807f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108086:	83 ca 80             	or     $0xffffff80,%edx
80108089:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010808f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108092:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80108099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809c:	83 c0 70             	add    $0x70,%eax
8010809f:	83 ec 08             	sub    $0x8,%esp
801080a2:	6a 30                	push   $0x30
801080a4:	50                   	push   %eax
801080a5:	e8 0e fb ff ff       	call   80107bb8 <lgdt>
801080aa:	83 c4 10             	add    $0x10,%esp
}
801080ad:	90                   	nop
801080ae:	c9                   	leave  
801080af:	c3                   	ret    

801080b0 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801080b0:	f3 0f 1e fb          	endbr32 
801080b4:	55                   	push   %ebp
801080b5:	89 e5                	mov    %esp,%ebp
801080b7:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801080ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801080bd:	c1 e8 16             	shr    $0x16,%eax
801080c0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080c7:	8b 45 08             	mov    0x8(%ebp),%eax
801080ca:	01 d0                	add    %edx,%eax
801080cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){//No need to check PTE_E here.
801080cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080d2:	8b 00                	mov    (%eax),%eax
801080d4:	83 e0 01             	and    $0x1,%eax
801080d7:	85 c0                	test   %eax,%eax
801080d9:	74 14                	je     801080ef <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801080db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080de:	8b 00                	mov    (%eax),%eax
801080e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080e5:	05 00 00 00 80       	add    $0x80000000,%eax
801080ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
801080ed:	eb 42                	jmp    80108131 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801080ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801080f3:	74 0e                	je     80108103 <walkpgdir+0x53>
801080f5:	e8 18 ad ff ff       	call   80102e12 <kalloc>
801080fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801080fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108101:	75 07                	jne    8010810a <walkpgdir+0x5a>
      return 0;
80108103:	b8 00 00 00 00       	mov    $0x0,%eax
80108108:	eb 3e                	jmp    80108148 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010810a:	83 ec 04             	sub    $0x4,%esp
8010810d:	68 00 10 00 00       	push   $0x1000
80108112:	6a 00                	push   $0x0
80108114:	ff 75 f4             	pushl  -0xc(%ebp)
80108117:	e8 5a d4 ff ff       	call   80105576 <memset>
8010811c:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010811f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108122:	05 00 00 00 80       	add    $0x80000000,%eax
80108127:	83 c8 07             	or     $0x7,%eax
8010812a:	89 c2                	mov    %eax,%edx
8010812c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010812f:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108131:	8b 45 0c             	mov    0xc(%ebp),%eax
80108134:	c1 e8 0c             	shr    $0xc,%eax
80108137:	25 ff 03 00 00       	and    $0x3ff,%eax
8010813c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108146:	01 d0                	add    %edx,%eax
}
80108148:	c9                   	leave  
80108149:	c3                   	ret    

8010814a <addtoworkingset>:

int addtoworkingset(char* va){
8010814a:	f3 0f 1e fb          	endbr32 
8010814e:	55                   	push   %ebp
8010814f:	89 e5                	mov    %esp,%ebp
80108151:	53                   	push   %ebx
80108152:	83 ec 14             	sub    $0x14,%esp
  struct proc* curproc = myproc();
80108155:	e8 56 c3 ff ff       	call   801044b0 <myproc>
8010815a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  pte_t * curr_pte;
  // cprintf("in the add");
  if(curproc->queue_size < CLOCKSIZE) {
8010815d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108160:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
80108166:	83 f8 07             	cmp    $0x7,%eax
80108169:	0f 8f 63 01 00 00    	jg     801082d2 <addtoworkingset+0x188>
    curr_pte=walkpgdir(curproc->pgdir,curproc->clock_queue[curproc->hand].va,0);
8010816f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108172:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
80108178:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010817b:	83 c2 10             	add    $0x10,%edx
8010817e:	8b 14 d0             	mov    (%eax,%edx,8),%edx
80108181:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108184:	8b 40 04             	mov    0x4(%eax),%eax
80108187:	83 ec 04             	sub    $0x4,%esp
8010818a:	6a 00                	push   $0x0
8010818c:	52                   	push   %edx
8010818d:	50                   	push   %eax
8010818e:	e8 1d ff ff ff       	call   801080b0 <walkpgdir>
80108193:	83 c4 10             	add    $0x10,%esp
80108196:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((*curr_pte & PTE_E)==PTE_E){
80108199:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010819c:	8b 00                	mov    (%eax),%eax
8010819e:	25 00 04 00 00       	and    $0x400,%eax
801081a3:	85 c0                	test   %eax,%eax
801081a5:	74 1d                	je     801081c4 <addtoworkingset+0x7a>
      cprintf("error");
801081a7:	83 ec 0c             	sub    $0xc,%esp
801081aa:	68 ac 98 10 80       	push   $0x801098ac
801081af:	e8 64 82 ff ff       	call   80100418 <cprintf>
801081b4:	83 c4 10             	add    $0x10,%esp
      panic("error");
801081b7:	83 ec 0c             	sub    $0xc,%esp
801081ba:	68 ac 98 10 80       	push   $0x801098ac
801081bf:	e8 44 84 ff ff       	call   80100608 <panic>
    }
    curproc->queue_size++;
801081c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081c7:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
801081cd:	8d 50 01             	lea    0x1(%eax),%edx
801081d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081d3:	89 90 c0 00 00 00    	mov    %edx,0xc0(%eax)

    for(int i = (curproc->hand + curproc->queue_size - 1) % curproc->queue_size; i+1< curproc->queue_size; i++){
801081d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081dc:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
801081e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081e5:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
801081eb:	01 d0                	add    %edx,%eax
801081ed:	8d 50 ff             	lea    -0x1(%eax),%edx
801081f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081f3:	8b 88 c0 00 00 00    	mov    0xc0(%eax),%ecx
801081f9:	89 d0                	mov    %edx,%eax
801081fb:	99                   	cltd   
801081fc:	f7 f9                	idiv   %ecx
801081fe:	89 55 f4             	mov    %edx,-0xc(%ebp)
80108201:	eb 7d                	jmp    80108280 <addtoworkingset+0x136>
      curproc->clock_queue[i+1] = curproc->clock_queue[i];
80108203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108206:	83 c0 01             	add    $0x1,%eax
80108209:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010820c:	8d 58 10             	lea    0x10(%eax),%ebx
8010820f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108212:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108215:	83 c2 10             	add    $0x10,%edx
80108218:	8d 14 d0             	lea    (%eax,%edx,8),%edx
8010821b:	8b 02                	mov    (%edx),%eax
8010821d:	8b 52 04             	mov    0x4(%edx),%edx
80108220:	89 04 d9             	mov    %eax,(%ecx,%ebx,8)
80108223:	89 54 d9 04          	mov    %edx,0x4(%ecx,%ebx,8)
      if((curproc->hand + curproc->queue_size - 1) % curproc->queue_size < curproc->hand){
80108227:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010822a:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
80108230:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108233:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
80108239:	01 d0                	add    %edx,%eax
8010823b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010823e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108241:	8b 88 c0 00 00 00    	mov    0xc0(%eax),%ecx
80108247:	89 d0                	mov    %edx,%eax
80108249:	99                   	cltd   
8010824a:	f7 f9                	idiv   %ecx
8010824c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010824f:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
80108255:	39 c2                	cmp    %eax,%edx
80108257:	7d 23                	jge    8010827c <addtoworkingset+0x132>
        curproc->hand = (curproc->hand + 1) % curproc->queue_size;
80108259:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010825c:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
80108262:	8d 50 01             	lea    0x1(%eax),%edx
80108265:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108268:	8b 88 c0 00 00 00    	mov    0xc0(%eax),%ecx
8010826e:	89 d0                	mov    %edx,%eax
80108270:	99                   	cltd   
80108271:	f7 f9                	idiv   %ecx
80108273:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108276:	89 90 c8 00 00 00    	mov    %edx,0xc8(%eax)
    for(int i = (curproc->hand + curproc->queue_size - 1) % curproc->queue_size; i+1< curproc->queue_size; i++){
8010827c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108280:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108283:	8d 50 01             	lea    0x1(%eax),%edx
80108286:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108289:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
8010828f:	39 c2                	cmp    %eax,%edx
80108291:	0f 8c 6c ff ff ff    	jl     80108203 <addtoworkingset+0xb9>
      }
    }

    curproc->clock_queue[(curproc->hand + curproc->queue_size - 1) % curproc->queue_size].va = va;
80108297:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010829a:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
801082a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082a3:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
801082a9:	01 d0                	add    %edx,%eax
801082ab:	8d 50 ff             	lea    -0x1(%eax),%edx
801082ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082b1:	8b 88 c0 00 00 00    	mov    0xc0(%eax),%ecx
801082b7:	89 d0                	mov    %edx,%eax
801082b9:	99                   	cltd   
801082ba:	f7 f9                	idiv   %ecx
801082bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082bf:	8d 4a 10             	lea    0x10(%edx),%ecx
801082c2:	8b 55 08             	mov    0x8(%ebp),%edx
801082c5:	89 14 c8             	mov    %edx,(%eax,%ecx,8)

    return 0;
801082c8:	b8 00 00 00 00       	mov    $0x0,%eax
801082cd:	e9 d2 00 00 00       	jmp    801083a4 <addtoworkingset+0x25a>

  while(1) {

    pte_t * curr_pte;
    //struct clock_queue_slot* cur_hand = &curproc->clock_queue[curproc->hand];
    curr_pte=walkpgdir(curproc->pgdir,curproc->clock_queue[curproc->hand].va,0);
801082d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082d5:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
801082db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082de:	83 c2 10             	add    $0x10,%edx
801082e1:	8b 14 d0             	mov    (%eax,%edx,8),%edx
801082e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082e7:	8b 40 04             	mov    0x4(%eax),%eax
801082ea:	83 ec 04             	sub    $0x4,%esp
801082ed:	6a 00                	push   $0x0
801082ef:	52                   	push   %edx
801082f0:	50                   	push   %eax
801082f1:	e8 ba fd ff ff       	call   801080b0 <walkpgdir>
801082f6:	83 c4 10             	add    $0x10,%esp
801082f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((*curr_pte & PTE_A) == 0){  
801082fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082ff:	8b 00                	mov    (%eax),%eax
80108301:	83 e0 20             	and    $0x20,%eax
80108304:	85 c0                	test   %eax,%eax
80108306:	74 39                	je     80108341 <addtoworkingset+0x1f7>
      break;
    }
    *curr_pte = *curr_pte & ~PTE_A;
80108308:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010830b:	8b 00                	mov    (%eax),%eax
8010830d:	83 e0 df             	and    $0xffffffdf,%eax
80108310:	89 c2                	mov    %eax,%edx
80108312:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108315:	89 10                	mov    %edx,(%eax)
    // curproc->clock_queue[curproc->hand].abit = 0;
    //cprintf("hand before  is %d",curproc->hand);
    curproc->hand = (curproc->hand + 1) % CLOCKSIZE;
80108317:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010831a:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
80108320:	8d 50 01             	lea    0x1(%eax),%edx
80108323:	89 d0                	mov    %edx,%eax
80108325:	c1 f8 1f             	sar    $0x1f,%eax
80108328:	c1 e8 1d             	shr    $0x1d,%eax
8010832b:	01 c2                	add    %eax,%edx
8010832d:	83 e2 07             	and    $0x7,%edx
80108330:	29 c2                	sub    %eax,%edx
80108332:	89 d0                	mov    %edx,%eax
80108334:	89 c2                	mov    %eax,%edx
80108336:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108339:	89 90 c8 00 00 00    	mov    %edx,0xc8(%eax)
  while(1) {
8010833f:	eb 91                	jmp    801082d2 <addtoworkingset+0x188>
      break;
80108341:	90                   	nop
  }
  mencrypt(curproc->clock_queue[curproc->hand].va, 1);
80108342:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108345:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
8010834b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010834e:	83 c2 10             	add    $0x10,%edx
80108351:	8b 04 d0             	mov    (%eax,%edx,8),%eax
80108354:	83 ec 08             	sub    $0x8,%esp
80108357:	6a 01                	push   $0x1
80108359:	50                   	push   %eax
8010835a:	e8 94 0a 00 00       	call   80108df3 <mencrypt>
8010835f:	83 c4 10             	add    $0x10,%esp
  //cprintf("hand is %d",curproc->hand);
  curproc->clock_queue[curproc->hand].va = va;
80108362:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108365:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
8010836b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010836e:	8d 4a 10             	lea    0x10(%edx),%ecx
80108371:	8b 55 08             	mov    0x8(%ebp),%edx
80108374:	89 14 c8             	mov    %edx,(%eax,%ecx,8)
  curproc->hand = (curproc->hand + 1) % CLOCKSIZE;
80108377:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010837a:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
80108380:	8d 50 01             	lea    0x1(%eax),%edx
80108383:	89 d0                	mov    %edx,%eax
80108385:	c1 f8 1f             	sar    $0x1f,%eax
80108388:	c1 e8 1d             	shr    $0x1d,%eax
8010838b:	01 c2                	add    %eax,%edx
8010838d:	83 e2 07             	and    $0x7,%edx
80108390:	29 c2                	sub    %eax,%edx
80108392:	89 d0                	mov    %edx,%eax
80108394:	89 c2                	mov    %eax,%edx
80108396:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108399:	89 90 c8 00 00 00    	mov    %edx,0xc8(%eax)
  return 0;
8010839f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801083a7:	c9                   	leave  
801083a8:	c3                   	ret    

801083a9 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801083a9:	f3 0f 1e fb          	endbr32 
801083ad:	55                   	push   %ebp
801083ae:	89 e5                	mov    %esp,%ebp
801083b0:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801083b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801083b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801083be:	8b 55 0c             	mov    0xc(%ebp),%edx
801083c1:	8b 45 10             	mov    0x10(%ebp),%eax
801083c4:	01 d0                	add    %edx,%eax
801083c6:	83 e8 01             	sub    $0x1,%eax
801083c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801083d1:	83 ec 04             	sub    $0x4,%esp
801083d4:	6a 01                	push   $0x1
801083d6:	ff 75 f4             	pushl  -0xc(%ebp)
801083d9:	ff 75 08             	pushl  0x8(%ebp)
801083dc:	e8 cf fc ff ff       	call   801080b0 <walkpgdir>
801083e1:	83 c4 10             	add    $0x10,%esp
801083e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083eb:	75 0a                	jne    801083f7 <mappages+0x4e>
      return -1;
801083ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083f2:	e9 99 00 00 00       	jmp    80108490 <mappages+0xe7>
    if(*pte & (PTE_P | PTE_E))
801083f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083fa:	8b 00                	mov    (%eax),%eax
801083fc:	25 01 04 00 00       	and    $0x401,%eax
80108401:	85 c0                	test   %eax,%eax
80108403:	74 0d                	je     80108412 <mappages+0x69>
      panic("remap");
80108405:	83 ec 0c             	sub    $0xc,%esp
80108408:	68 b2 98 10 80       	push   $0x801098b2
8010840d:	e8 f6 81 ff ff       	call   80100608 <panic>
    
    //"perm" is just the lower 12 bits of the PTE
    //if encrypted, then ensure that PTE_P is not set
    //This is somewhat redundant. If our code is correct,
    //we should just be able to say pa | perm
    if (perm & PTE_E)
80108412:	8b 45 18             	mov    0x18(%ebp),%eax
80108415:	25 00 04 00 00       	and    $0x400,%eax
8010841a:	85 c0                	test   %eax,%eax
8010841c:	74 17                	je     80108435 <mappages+0x8c>
      *pte = (pa | perm | PTE_E ) & ~PTE_P ;
8010841e:	8b 45 18             	mov    0x18(%ebp),%eax
80108421:	0b 45 14             	or     0x14(%ebp),%eax
80108424:	25 fe fb ff ff       	and    $0xfffffbfe,%eax
80108429:	80 cc 04             	or     $0x4,%ah
8010842c:	89 c2                	mov    %eax,%edx
8010842e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108431:	89 10                	mov    %edx,(%eax)
80108433:	eb 10                	jmp    80108445 <mappages+0x9c>
    else
      *pte = pa | perm | PTE_P;
80108435:	8b 45 18             	mov    0x18(%ebp),%eax
80108438:	0b 45 14             	or     0x14(%ebp),%eax
8010843b:	83 c8 01             	or     $0x1,%eax
8010843e:	89 c2                	mov    %eax,%edx
80108440:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108443:	89 10                	mov    %edx,(%eax)
    if((perm & PTE_A) == PTE_A){
80108445:	8b 45 18             	mov    0x18(%ebp),%eax
80108448:	83 e0 20             	and    $0x20,%eax
8010844b:	85 c0                	test   %eax,%eax
8010844d:	74 11                	je     80108460 <mappages+0xb7>
      *pte = *pte | PTE_A;
8010844f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108452:	8b 00                	mov    (%eax),%eax
80108454:	83 c8 20             	or     $0x20,%eax
80108457:	89 c2                	mov    %eax,%edx
80108459:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010845c:	89 10                	mov    %edx,(%eax)
8010845e:	eb 0f                	jmp    8010846f <mappages+0xc6>
    }
    else{
      *pte = *pte & ~PTE_A;
80108460:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108463:	8b 00                	mov    (%eax),%eax
80108465:	83 e0 df             	and    $0xffffffdf,%eax
80108468:	89 c2                	mov    %eax,%edx
8010846a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010846d:	89 10                	mov    %edx,(%eax)
    }

    if(a == last)
8010846f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108472:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108475:	74 13                	je     8010848a <mappages+0xe1>
      break;
    a += PGSIZE;
80108477:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010847e:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108485:	e9 47 ff ff ff       	jmp    801083d1 <mappages+0x28>
      break;
8010848a:	90                   	nop
  }
  return 0;
8010848b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108490:	c9                   	leave  
80108491:	c3                   	ret    

80108492 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108492:	f3 0f 1e fb          	endbr32 
80108496:	55                   	push   %ebp
80108497:	89 e5                	mov    %esp,%ebp
80108499:	53                   	push   %ebx
8010849a:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010849d:	e8 70 a9 ff ff       	call   80102e12 <kalloc>
801084a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801084a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084a9:	75 07                	jne    801084b2 <setupkvm+0x20>
    return 0;
801084ab:	b8 00 00 00 00       	mov    $0x0,%eax
801084b0:	eb 78                	jmp    8010852a <setupkvm+0x98>
  memset(pgdir, 0, PGSIZE);
801084b2:	83 ec 04             	sub    $0x4,%esp
801084b5:	68 00 10 00 00       	push   $0x1000
801084ba:	6a 00                	push   $0x0
801084bc:	ff 75 f0             	pushl  -0x10(%ebp)
801084bf:	e8 b2 d0 ff ff       	call   80105576 <memset>
801084c4:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801084c7:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
801084ce:	eb 4e                	jmp    8010851e <setupkvm+0x8c>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801084d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d3:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801084d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d9:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801084dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084df:	8b 58 08             	mov    0x8(%eax),%ebx
801084e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e5:	8b 40 04             	mov    0x4(%eax),%eax
801084e8:	29 c3                	sub    %eax,%ebx
801084ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ed:	8b 00                	mov    (%eax),%eax
801084ef:	83 ec 0c             	sub    $0xc,%esp
801084f2:	51                   	push   %ecx
801084f3:	52                   	push   %edx
801084f4:	53                   	push   %ebx
801084f5:	50                   	push   %eax
801084f6:	ff 75 f0             	pushl  -0x10(%ebp)
801084f9:	e8 ab fe ff ff       	call   801083a9 <mappages>
801084fe:	83 c4 20             	add    $0x20,%esp
80108501:	85 c0                	test   %eax,%eax
80108503:	79 15                	jns    8010851a <setupkvm+0x88>
      freevm(pgdir);
80108505:	83 ec 0c             	sub    $0xc,%esp
80108508:	ff 75 f0             	pushl  -0x10(%ebp)
8010850b:	e8 26 05 00 00       	call   80108a36 <freevm>
80108510:	83 c4 10             	add    $0x10,%esp
      return 0;
80108513:	b8 00 00 00 00       	mov    $0x0,%eax
80108518:	eb 10                	jmp    8010852a <setupkvm+0x98>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010851a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010851e:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108525:	72 a9                	jb     801084d0 <setupkvm+0x3e>
    }
  return pgdir;
80108527:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010852a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010852d:	c9                   	leave  
8010852e:	c3                   	ret    

8010852f <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010852f:	f3 0f 1e fb          	endbr32 
80108533:	55                   	push   %ebp
80108534:	89 e5                	mov    %esp,%ebp
80108536:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108539:	e8 54 ff ff ff       	call   80108492 <setupkvm>
8010853e:	a3 44 89 11 80       	mov    %eax,0x80118944
  switchkvm();
80108543:	e8 03 00 00 00       	call   8010854b <switchkvm>
}
80108548:	90                   	nop
80108549:	c9                   	leave  
8010854a:	c3                   	ret    

8010854b <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010854b:	f3 0f 1e fb          	endbr32 
8010854f:	55                   	push   %ebp
80108550:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108552:	a1 44 89 11 80       	mov    0x80118944,%eax
80108557:	05 00 00 00 80       	add    $0x80000000,%eax
8010855c:	50                   	push   %eax
8010855d:	e8 97 f6 ff ff       	call   80107bf9 <lcr3>
80108562:	83 c4 04             	add    $0x4,%esp
}
80108565:	90                   	nop
80108566:	c9                   	leave  
80108567:	c3                   	ret    

80108568 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108568:	f3 0f 1e fb          	endbr32 
8010856c:	55                   	push   %ebp
8010856d:	89 e5                	mov    %esp,%ebp
8010856f:	56                   	push   %esi
80108570:	53                   	push   %ebx
80108571:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80108574:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108578:	75 0d                	jne    80108587 <switchuvm+0x1f>
    panic("switchuvm: no process");
8010857a:	83 ec 0c             	sub    $0xc,%esp
8010857d:	68 b8 98 10 80       	push   $0x801098b8
80108582:	e8 81 80 ff ff       	call   80100608 <panic>
  if(p->kstack == 0)
80108587:	8b 45 08             	mov    0x8(%ebp),%eax
8010858a:	8b 40 08             	mov    0x8(%eax),%eax
8010858d:	85 c0                	test   %eax,%eax
8010858f:	75 0d                	jne    8010859e <switchuvm+0x36>
    panic("switchuvm: no kstack");
80108591:	83 ec 0c             	sub    $0xc,%esp
80108594:	68 ce 98 10 80       	push   $0x801098ce
80108599:	e8 6a 80 ff ff       	call   80100608 <panic>
  if(p->pgdir == 0)
8010859e:	8b 45 08             	mov    0x8(%ebp),%eax
801085a1:	8b 40 04             	mov    0x4(%eax),%eax
801085a4:	85 c0                	test   %eax,%eax
801085a6:	75 0d                	jne    801085b5 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
801085a8:	83 ec 0c             	sub    $0xc,%esp
801085ab:	68 e3 98 10 80       	push   $0x801098e3
801085b0:	e8 53 80 ff ff       	call   80100608 <panic>

  pushcli();
801085b5:	e8 a9 ce ff ff       	call   80105463 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801085ba:	e8 75 be ff ff       	call   80104434 <mycpu>
801085bf:	89 c3                	mov    %eax,%ebx
801085c1:	e8 6e be ff ff       	call   80104434 <mycpu>
801085c6:	83 c0 08             	add    $0x8,%eax
801085c9:	89 c6                	mov    %eax,%esi
801085cb:	e8 64 be ff ff       	call   80104434 <mycpu>
801085d0:	83 c0 08             	add    $0x8,%eax
801085d3:	c1 e8 10             	shr    $0x10,%eax
801085d6:	88 45 f7             	mov    %al,-0x9(%ebp)
801085d9:	e8 56 be ff ff       	call   80104434 <mycpu>
801085de:	83 c0 08             	add    $0x8,%eax
801085e1:	c1 e8 18             	shr    $0x18,%eax
801085e4:	89 c2                	mov    %eax,%edx
801085e6:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801085ed:	67 00 
801085ef:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801085f6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801085fa:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80108600:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108607:	83 e0 f0             	and    $0xfffffff0,%eax
8010860a:	83 c8 09             	or     $0x9,%eax
8010860d:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108613:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010861a:	83 c8 10             	or     $0x10,%eax
8010861d:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108623:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010862a:	83 e0 9f             	and    $0xffffff9f,%eax
8010862d:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108633:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010863a:	83 c8 80             	or     $0xffffff80,%eax
8010863d:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108643:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010864a:	83 e0 f0             	and    $0xfffffff0,%eax
8010864d:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108653:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010865a:	83 e0 ef             	and    $0xffffffef,%eax
8010865d:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108663:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010866a:	83 e0 df             	and    $0xffffffdf,%eax
8010866d:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108673:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010867a:	83 c8 40             	or     $0x40,%eax
8010867d:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108683:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010868a:	83 e0 7f             	and    $0x7f,%eax
8010868d:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108693:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108699:	e8 96 bd ff ff       	call   80104434 <mycpu>
8010869e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801086a5:	83 e2 ef             	and    $0xffffffef,%edx
801086a8:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801086ae:	e8 81 bd ff ff       	call   80104434 <mycpu>
801086b3:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801086b9:	8b 45 08             	mov    0x8(%ebp),%eax
801086bc:	8b 40 08             	mov    0x8(%eax),%eax
801086bf:	89 c3                	mov    %eax,%ebx
801086c1:	e8 6e bd ff ff       	call   80104434 <mycpu>
801086c6:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801086cc:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801086cf:	e8 60 bd ff ff       	call   80104434 <mycpu>
801086d4:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801086da:	83 ec 0c             	sub    $0xc,%esp
801086dd:	6a 28                	push   $0x28
801086df:	e8 fe f4 ff ff       	call   80107be2 <ltr>
801086e4:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801086e7:	8b 45 08             	mov    0x8(%ebp),%eax
801086ea:	8b 40 04             	mov    0x4(%eax),%eax
801086ed:	05 00 00 00 80       	add    $0x80000000,%eax
801086f2:	83 ec 0c             	sub    $0xc,%esp
801086f5:	50                   	push   %eax
801086f6:	e8 fe f4 ff ff       	call   80107bf9 <lcr3>
801086fb:	83 c4 10             	add    $0x10,%esp
  popcli();
801086fe:	e8 b1 cd ff ff       	call   801054b4 <popcli>
}
80108703:	90                   	nop
80108704:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108707:	5b                   	pop    %ebx
80108708:	5e                   	pop    %esi
80108709:	5d                   	pop    %ebp
8010870a:	c3                   	ret    

8010870b <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010870b:	f3 0f 1e fb          	endbr32 
8010870f:	55                   	push   %ebp
80108710:	89 e5                	mov    %esp,%ebp
80108712:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108715:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010871c:	76 0d                	jbe    8010872b <inituvm+0x20>
    panic("inituvm: more than a page");
8010871e:	83 ec 0c             	sub    $0xc,%esp
80108721:	68 f7 98 10 80       	push   $0x801098f7
80108726:	e8 dd 7e ff ff       	call   80100608 <panic>
  mem = kalloc();
8010872b:	e8 e2 a6 ff ff       	call   80102e12 <kalloc>
80108730:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108733:	83 ec 04             	sub    $0x4,%esp
80108736:	68 00 10 00 00       	push   $0x1000
8010873b:	6a 00                	push   $0x0
8010873d:	ff 75 f4             	pushl  -0xc(%ebp)
80108740:	e8 31 ce ff ff       	call   80105576 <memset>
80108745:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874b:	05 00 00 00 80       	add    $0x80000000,%eax
80108750:	83 ec 0c             	sub    $0xc,%esp
80108753:	6a 06                	push   $0x6
80108755:	50                   	push   %eax
80108756:	68 00 10 00 00       	push   $0x1000
8010875b:	6a 00                	push   $0x0
8010875d:	ff 75 08             	pushl  0x8(%ebp)
80108760:	e8 44 fc ff ff       	call   801083a9 <mappages>
80108765:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108768:	83 ec 04             	sub    $0x4,%esp
8010876b:	ff 75 10             	pushl  0x10(%ebp)
8010876e:	ff 75 0c             	pushl  0xc(%ebp)
80108771:	ff 75 f4             	pushl  -0xc(%ebp)
80108774:	e8 c4 ce ff ff       	call   8010563d <memmove>
80108779:	83 c4 10             	add    $0x10,%esp
}
8010877c:	90                   	nop
8010877d:	c9                   	leave  
8010877e:	c3                   	ret    

8010877f <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010877f:	f3 0f 1e fb          	endbr32 
80108783:	55                   	push   %ebp
80108784:	89 e5                	mov    %esp,%ebp
80108786:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108789:	8b 45 0c             	mov    0xc(%ebp),%eax
8010878c:	25 ff 0f 00 00       	and    $0xfff,%eax
80108791:	85 c0                	test   %eax,%eax
80108793:	74 0d                	je     801087a2 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80108795:	83 ec 0c             	sub    $0xc,%esp
80108798:	68 14 99 10 80       	push   $0x80109914
8010879d:	e8 66 7e ff ff       	call   80100608 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801087a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801087a9:	e9 8f 00 00 00       	jmp    8010883d <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801087ae:	8b 55 0c             	mov    0xc(%ebp),%edx
801087b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b4:	01 d0                	add    %edx,%eax
801087b6:	83 ec 04             	sub    $0x4,%esp
801087b9:	6a 00                	push   $0x0
801087bb:	50                   	push   %eax
801087bc:	ff 75 08             	pushl  0x8(%ebp)
801087bf:	e8 ec f8 ff ff       	call   801080b0 <walkpgdir>
801087c4:	83 c4 10             	add    $0x10,%esp
801087c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801087ca:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801087ce:	75 0d                	jne    801087dd <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801087d0:	83 ec 0c             	sub    $0xc,%esp
801087d3:	68 37 99 10 80       	push   $0x80109937
801087d8:	e8 2b 7e ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
801087dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087e0:	8b 00                	mov    (%eax),%eax
801087e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087e7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801087ea:	8b 45 18             	mov    0x18(%ebp),%eax
801087ed:	2b 45 f4             	sub    -0xc(%ebp),%eax
801087f0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801087f5:	77 0b                	ja     80108802 <loaduvm+0x83>
      n = sz - i;
801087f7:	8b 45 18             	mov    0x18(%ebp),%eax
801087fa:	2b 45 f4             	sub    -0xc(%ebp),%eax
801087fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108800:	eb 07                	jmp    80108809 <loaduvm+0x8a>
    else
      n = PGSIZE;
80108802:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108809:	8b 55 14             	mov    0x14(%ebp),%edx
8010880c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010880f:	01 d0                	add    %edx,%eax
80108811:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108814:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010881a:	ff 75 f0             	pushl  -0x10(%ebp)
8010881d:	50                   	push   %eax
8010881e:	52                   	push   %edx
8010881f:	ff 75 10             	pushl  0x10(%ebp)
80108822:	e8 03 98 ff ff       	call   8010202a <readi>
80108827:	83 c4 10             	add    $0x10,%esp
8010882a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010882d:	74 07                	je     80108836 <loaduvm+0xb7>
      return -1;
8010882f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108834:	eb 18                	jmp    8010884e <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80108836:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010883d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108840:	3b 45 18             	cmp    0x18(%ebp),%eax
80108843:	0f 82 65 ff ff ff    	jb     801087ae <loaduvm+0x2f>
  }
  return 0;
80108849:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010884e:	c9                   	leave  
8010884f:	c3                   	ret    

80108850 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108850:	f3 0f 1e fb          	endbr32 
80108854:	55                   	push   %ebp
80108855:	89 e5                	mov    %esp,%ebp
80108857:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010885a:	8b 45 10             	mov    0x10(%ebp),%eax
8010885d:	85 c0                	test   %eax,%eax
8010885f:	79 0a                	jns    8010886b <allocuvm+0x1b>
    return 0;
80108861:	b8 00 00 00 00       	mov    $0x0,%eax
80108866:	e9 ea 00 00 00       	jmp    80108955 <allocuvm+0x105>
  if(newsz < oldsz)
8010886b:	8b 45 10             	mov    0x10(%ebp),%eax
8010886e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108871:	73 08                	jae    8010887b <allocuvm+0x2b>
    return oldsz;
80108873:	8b 45 0c             	mov    0xc(%ebp),%eax
80108876:	e9 da 00 00 00       	jmp    80108955 <allocuvm+0x105>

  a = PGROUNDUP(oldsz);
8010887b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010887e:	05 ff 0f 00 00       	add    $0xfff,%eax
80108883:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108888:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010888b:	e9 b6 00 00 00       	jmp    80108946 <allocuvm+0xf6>
    mem = kalloc();
80108890:	e8 7d a5 ff ff       	call   80102e12 <kalloc>
80108895:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108898:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010889c:	75 2d                	jne    801088cb <allocuvm+0x7b>
      cprintf("allocuvm out of memory\n");
8010889e:	83 ec 0c             	sub    $0xc,%esp
801088a1:	68 55 99 10 80       	push   $0x80109955
801088a6:	e8 6d 7b ff ff       	call   80100418 <cprintf>
801088ab:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz, 0);
801088ae:	6a 00                	push   $0x0
801088b0:	ff 75 0c             	pushl  0xc(%ebp)
801088b3:	ff 75 10             	pushl  0x10(%ebp)
801088b6:	ff 75 08             	pushl  0x8(%ebp)
801088b9:	e8 99 00 00 00       	call   80108957 <deallocuvm>
801088be:	83 c4 10             	add    $0x10,%esp
      return 0;
801088c1:	b8 00 00 00 00       	mov    $0x0,%eax
801088c6:	e9 8a 00 00 00       	jmp    80108955 <allocuvm+0x105>
    }
    memset(mem, 0, PGSIZE);
801088cb:	83 ec 04             	sub    $0x4,%esp
801088ce:	68 00 10 00 00       	push   $0x1000
801088d3:	6a 00                	push   $0x0
801088d5:	ff 75 f0             	pushl  -0x10(%ebp)
801088d8:	e8 99 cc ff ff       	call   80105576 <memset>
801088dd:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801088e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088e3:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801088e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ec:	83 ec 0c             	sub    $0xc,%esp
801088ef:	6a 06                	push   $0x6
801088f1:	52                   	push   %edx
801088f2:	68 00 10 00 00       	push   $0x1000
801088f7:	50                   	push   %eax
801088f8:	ff 75 08             	pushl  0x8(%ebp)
801088fb:	e8 a9 fa ff ff       	call   801083a9 <mappages>
80108900:	83 c4 20             	add    $0x20,%esp
80108903:	85 c0                	test   %eax,%eax
80108905:	79 38                	jns    8010893f <allocuvm+0xef>
      cprintf("allocuvm out of memory (2)\n");
80108907:	83 ec 0c             	sub    $0xc,%esp
8010890a:	68 6d 99 10 80       	push   $0x8010996d
8010890f:	e8 04 7b ff ff       	call   80100418 <cprintf>
80108914:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz, 0);
80108917:	6a 00                	push   $0x0
80108919:	ff 75 0c             	pushl  0xc(%ebp)
8010891c:	ff 75 10             	pushl  0x10(%ebp)
8010891f:	ff 75 08             	pushl  0x8(%ebp)
80108922:	e8 30 00 00 00       	call   80108957 <deallocuvm>
80108927:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
8010892a:	83 ec 0c             	sub    $0xc,%esp
8010892d:	ff 75 f0             	pushl  -0x10(%ebp)
80108930:	e8 3f a4 ff ff       	call   80102d74 <kfree>
80108935:	83 c4 10             	add    $0x10,%esp
      return 0;
80108938:	b8 00 00 00 00       	mov    $0x0,%eax
8010893d:	eb 16                	jmp    80108955 <allocuvm+0x105>
  for(; a < newsz; a += PGSIZE){
8010893f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108946:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108949:	3b 45 10             	cmp    0x10(%ebp),%eax
8010894c:	0f 82 3e ff ff ff    	jb     80108890 <allocuvm+0x40>
    }
  }
  return newsz;
80108952:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108955:	c9                   	leave  
80108956:	c3                   	ret    

80108957 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz, uint growproc)
{
80108957:	f3 0f 1e fb          	endbr32 
8010895b:	55                   	push   %ebp
8010895c:	89 e5                	mov    %esp,%ebp
8010895e:	83 ec 18             	sub    $0x18,%esp

  pte_t *pte;
  uint a, pa;
 
  if(newsz >= oldsz)
80108961:	8b 45 10             	mov    0x10(%ebp),%eax
80108964:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108967:	72 08                	jb     80108971 <deallocuvm+0x1a>
    return oldsz;
80108969:	8b 45 0c             	mov    0xc(%ebp),%eax
8010896c:	e9 c3 00 00 00       	jmp    80108a34 <deallocuvm+0xdd>

  a = PGROUNDUP(newsz);
80108971:	8b 45 10             	mov    0x10(%ebp),%eax
80108974:	05 ff 0f 00 00       	add    $0xfff,%eax
80108979:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010897e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108981:	e9 9f 00 00 00       	jmp    80108a25 <deallocuvm+0xce>
    
    pte = walkpgdir(pgdir, (char*)a, 0);
80108986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108989:	83 ec 04             	sub    $0x4,%esp
8010898c:	6a 00                	push   $0x0
8010898e:	50                   	push   %eax
8010898f:	ff 75 08             	pushl  0x8(%ebp)
80108992:	e8 19 f7 ff ff       	call   801080b0 <walkpgdir>
80108997:	83 c4 10             	add    $0x10,%esp
8010899a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010899d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801089a1:	75 16                	jne    801089b9 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801089a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a6:	c1 e8 16             	shr    $0x16,%eax
801089a9:	83 c0 01             	add    $0x1,%eax
801089ac:	c1 e0 16             	shl    $0x16,%eax
801089af:	2d 00 10 00 00       	sub    $0x1000,%eax
801089b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801089b7:	eb 65                	jmp    80108a1e <deallocuvm+0xc7>
    else if((*pte & (PTE_P | PTE_E)) != 0){
801089b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089bc:	8b 00                	mov    (%eax),%eax
801089be:	25 01 04 00 00       	and    $0x401,%eax
801089c3:	85 c0                	test   %eax,%eax
801089c5:	74 57                	je     80108a1e <deallocuvm+0xc7>
      pa = PTE_ADDR(*pte);
801089c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089ca:	8b 00                	mov    (%eax),%eax
801089cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801089d4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801089d8:	75 0d                	jne    801089e7 <deallocuvm+0x90>
        panic("kfree");
801089da:	83 ec 0c             	sub    $0xc,%esp
801089dd:	68 89 99 10 80       	push   $0x80109989
801089e2:	e8 21 7c ff ff       	call   80100608 <panic>
      if(growproc)
801089e7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801089eb:	74 0f                	je     801089fc <deallocuvm+0xa5>
        removepage((char*)a);
801089ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f0:	83 ec 0c             	sub    $0xc,%esp
801089f3:	50                   	push   %eax
801089f4:	e8 0c f2 ff ff       	call   80107c05 <removepage>
801089f9:	83 c4 10             	add    $0x10,%esp
      char *v = P2V(pa);
801089fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089ff:	05 00 00 00 80       	add    $0x80000000,%eax
80108a04:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108a07:	83 ec 0c             	sub    $0xc,%esp
80108a0a:	ff 75 e8             	pushl  -0x18(%ebp)
80108a0d:	e8 62 a3 ff ff       	call   80102d74 <kfree>
80108a12:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a18:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108a1e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a28:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108a2b:	0f 82 55 ff ff ff    	jb     80108986 <deallocuvm+0x2f>
    }
  }
  return newsz;
80108a31:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108a34:	c9                   	leave  
80108a35:	c3                   	ret    

80108a36 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108a36:	f3 0f 1e fb          	endbr32 
80108a3a:	55                   	push   %ebp
80108a3b:	89 e5                	mov    %esp,%ebp
80108a3d:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108a40:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108a44:	75 0d                	jne    80108a53 <freevm+0x1d>
    panic("freevm: no pgdir");
80108a46:	83 ec 0c             	sub    $0xc,%esp
80108a49:	68 8f 99 10 80       	push   $0x8010998f
80108a4e:	e8 b5 7b ff ff       	call   80100608 <panic>
  deallocuvm(pgdir, KERNBASE, 0, 0);
80108a53:	6a 00                	push   $0x0
80108a55:	6a 00                	push   $0x0
80108a57:	68 00 00 00 80       	push   $0x80000000
80108a5c:	ff 75 08             	pushl  0x8(%ebp)
80108a5f:	e8 f3 fe ff ff       	call   80108957 <deallocuvm>
80108a64:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108a67:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a6e:	eb 48                	jmp    80108ab8 <freevm+0x82>
    //you don't need to check for PTE_E here because
    //this is a pde_t, where PTE_E doesn't get set
    if(pgdir[i] & PTE_P){
80108a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a73:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80108a7d:	01 d0                	add    %edx,%eax
80108a7f:	8b 00                	mov    (%eax),%eax
80108a81:	83 e0 01             	and    $0x1,%eax
80108a84:	85 c0                	test   %eax,%eax
80108a86:	74 2c                	je     80108ab4 <freevm+0x7e>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a8b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a92:	8b 45 08             	mov    0x8(%ebp),%eax
80108a95:	01 d0                	add    %edx,%eax
80108a97:	8b 00                	mov    (%eax),%eax
80108a99:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a9e:	05 00 00 00 80       	add    $0x80000000,%eax
80108aa3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108aa6:	83 ec 0c             	sub    $0xc,%esp
80108aa9:	ff 75 f0             	pushl  -0x10(%ebp)
80108aac:	e8 c3 a2 ff ff       	call   80102d74 <kfree>
80108ab1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108ab4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108ab8:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108abf:	76 af                	jbe    80108a70 <freevm+0x3a>
    }
  }
  kfree((char*)pgdir);
80108ac1:	83 ec 0c             	sub    $0xc,%esp
80108ac4:	ff 75 08             	pushl  0x8(%ebp)
80108ac7:	e8 a8 a2 ff ff       	call   80102d74 <kfree>
80108acc:	83 c4 10             	add    $0x10,%esp
}
80108acf:	90                   	nop
80108ad0:	c9                   	leave  
80108ad1:	c3                   	ret    

80108ad2 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108ad2:	f3 0f 1e fb          	endbr32 
80108ad6:	55                   	push   %ebp
80108ad7:	89 e5                	mov    %esp,%ebp
80108ad9:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108adc:	83 ec 04             	sub    $0x4,%esp
80108adf:	6a 00                	push   $0x0
80108ae1:	ff 75 0c             	pushl  0xc(%ebp)
80108ae4:	ff 75 08             	pushl  0x8(%ebp)
80108ae7:	e8 c4 f5 ff ff       	call   801080b0 <walkpgdir>
80108aec:	83 c4 10             	add    $0x10,%esp
80108aef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108af2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108af6:	75 0d                	jne    80108b05 <clearpteu+0x33>
    panic("clearpteu");
80108af8:	83 ec 0c             	sub    $0xc,%esp
80108afb:	68 a0 99 10 80       	push   $0x801099a0
80108b00:	e8 03 7b ff ff       	call   80100608 <panic>
  *pte &= ~PTE_U;
80108b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b08:	8b 00                	mov    (%eax),%eax
80108b0a:	83 e0 fb             	and    $0xfffffffb,%eax
80108b0d:	89 c2                	mov    %eax,%edx
80108b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b12:	89 10                	mov    %edx,(%eax)
}
80108b14:	90                   	nop
80108b15:	c9                   	leave  
80108b16:	c3                   	ret    

80108b17 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108b17:	f3 0f 1e fb          	endbr32 
80108b1b:	55                   	push   %ebp
80108b1c:	89 e5                	mov    %esp,%ebp
80108b1e:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108b21:	e8 6c f9 ff ff       	call   80108492 <setupkvm>
80108b26:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108b29:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b2d:	75 0a                	jne    80108b39 <copyuvm+0x22>
    return 0;
80108b2f:	b8 00 00 00 00       	mov    $0x0,%eax
80108b34:	e9 fa 00 00 00       	jmp    80108c33 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108b39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108b40:	e9 c9 00 00 00       	jmp    80108c0e <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b48:	83 ec 04             	sub    $0x4,%esp
80108b4b:	6a 00                	push   $0x0
80108b4d:	50                   	push   %eax
80108b4e:	ff 75 08             	pushl  0x8(%ebp)
80108b51:	e8 5a f5 ff ff       	call   801080b0 <walkpgdir>
80108b56:	83 c4 10             	add    $0x10,%esp
80108b59:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108b5c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108b60:	75 0d                	jne    80108b6f <copyuvm+0x58>
      panic("copyuvm: pte should exist");
80108b62:	83 ec 0c             	sub    $0xc,%esp
80108b65:	68 aa 99 10 80       	push   $0x801099aa
80108b6a:	e8 99 7a ff ff       	call   80100608 <panic>
    if(!(*pte & (PTE_P | PTE_E)))
80108b6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b72:	8b 00                	mov    (%eax),%eax
80108b74:	25 01 04 00 00       	and    $0x401,%eax
80108b79:	85 c0                	test   %eax,%eax
80108b7b:	75 0d                	jne    80108b8a <copyuvm+0x73>
      panic("copyuvm: page not present");
80108b7d:	83 ec 0c             	sub    $0xc,%esp
80108b80:	68 c4 99 10 80       	push   $0x801099c4
80108b85:	e8 7e 7a ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
80108b8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b8d:	8b 00                	mov    (%eax),%eax
80108b8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b94:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108b97:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b9a:	8b 00                	mov    (%eax),%eax
80108b9c:	25 ff 0f 00 00       	and    $0xfff,%eax
80108ba1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108ba4:	e8 69 a2 ff ff       	call   80102e12 <kalloc>
80108ba9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108bac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108bb0:	74 6d                	je     80108c1f <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108bb2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bb5:	05 00 00 00 80       	add    $0x80000000,%eax
80108bba:	83 ec 04             	sub    $0x4,%esp
80108bbd:	68 00 10 00 00       	push   $0x1000
80108bc2:	50                   	push   %eax
80108bc3:	ff 75 e0             	pushl  -0x20(%ebp)
80108bc6:	e8 72 ca ff ff       	call   8010563d <memmove>
80108bcb:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80108bce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108bd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bd4:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bdd:	83 ec 0c             	sub    $0xc,%esp
80108be0:	52                   	push   %edx
80108be1:	51                   	push   %ecx
80108be2:	68 00 10 00 00       	push   $0x1000
80108be7:	50                   	push   %eax
80108be8:	ff 75 f0             	pushl  -0x10(%ebp)
80108beb:	e8 b9 f7 ff ff       	call   801083a9 <mappages>
80108bf0:	83 c4 20             	add    $0x20,%esp
80108bf3:	85 c0                	test   %eax,%eax
80108bf5:	79 10                	jns    80108c07 <copyuvm+0xf0>
      kfree(mem);
80108bf7:	83 ec 0c             	sub    $0xc,%esp
80108bfa:	ff 75 e0             	pushl  -0x20(%ebp)
80108bfd:	e8 72 a1 ff ff       	call   80102d74 <kfree>
80108c02:	83 c4 10             	add    $0x10,%esp
      goto bad;
80108c05:	eb 19                	jmp    80108c20 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80108c07:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c11:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108c14:	0f 82 2b ff ff ff    	jb     80108b45 <copyuvm+0x2e>
    }
  }
  return d;
80108c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c1d:	eb 14                	jmp    80108c33 <copyuvm+0x11c>
      goto bad;
80108c1f:	90                   	nop

bad:
  freevm(d);
80108c20:	83 ec 0c             	sub    $0xc,%esp
80108c23:	ff 75 f0             	pushl  -0x10(%ebp)
80108c26:	e8 0b fe ff ff       	call   80108a36 <freevm>
80108c2b:	83 c4 10             	add    $0x10,%esp
  return 0;
80108c2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c33:	c9                   	leave  
80108c34:	c3                   	ret    

80108c35 <uva2ka>:
// KVA -> PA
// PA -> KVA
// KVA = PA + KERNBASE
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108c35:	f3 0f 1e fb          	endbr32 
80108c39:	55                   	push   %ebp
80108c3a:	89 e5                	mov    %esp,%ebp
80108c3c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108c3f:	83 ec 04             	sub    $0x4,%esp
80108c42:	6a 00                	push   $0x0
80108c44:	ff 75 0c             	pushl  0xc(%ebp)
80108c47:	ff 75 08             	pushl  0x8(%ebp)
80108c4a:	e8 61 f4 ff ff       	call   801080b0 <walkpgdir>
80108c4f:	83 c4 10             	add    $0x10,%esp
80108c52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //TODO: uva2ka says not present if PTE_P is 0
  if(((*pte & PTE_P) | (*pte & PTE_E)) == 0)
80108c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c58:	8b 00                	mov    (%eax),%eax
80108c5a:	25 01 04 00 00       	and    $0x401,%eax
80108c5f:	85 c0                	test   %eax,%eax
80108c61:	75 07                	jne    80108c6a <uva2ka+0x35>
    return 0;
80108c63:	b8 00 00 00 00       	mov    $0x0,%eax
80108c68:	eb 22                	jmp    80108c8c <uva2ka+0x57>
  if((*pte & PTE_U) == 0)
80108c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c6d:	8b 00                	mov    (%eax),%eax
80108c6f:	83 e0 04             	and    $0x4,%eax
80108c72:	85 c0                	test   %eax,%eax
80108c74:	75 07                	jne    80108c7d <uva2ka+0x48>
    return 0;
80108c76:	b8 00 00 00 00       	mov    $0x0,%eax
80108c7b:	eb 0f                	jmp    80108c8c <uva2ka+0x57>
  return (char*)P2V(PTE_ADDR(*pte));
80108c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c80:	8b 00                	mov    (%eax),%eax
80108c82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c87:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108c8c:	c9                   	leave  
80108c8d:	c3                   	ret    

80108c8e <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108c8e:	f3 0f 1e fb          	endbr32 
80108c92:	55                   	push   %ebp
80108c93:	89 e5                	mov    %esp,%ebp
80108c95:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108c98:	8b 45 10             	mov    0x10(%ebp),%eax
80108c9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108c9e:	eb 7f                	jmp    80108d1f <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108ca0:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ca3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ca8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //TODO: what happens if you copyout to an encrypted page?
    pa0 = uva2ka(pgdir, (char*)va0);
80108cab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cae:	83 ec 08             	sub    $0x8,%esp
80108cb1:	50                   	push   %eax
80108cb2:	ff 75 08             	pushl  0x8(%ebp)
80108cb5:	e8 7b ff ff ff       	call   80108c35 <uva2ka>
80108cba:	83 c4 10             	add    $0x10,%esp
80108cbd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0) {
80108cc0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108cc4:	75 07                	jne    80108ccd <copyout+0x3f>
      return -1;
80108cc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ccb:	eb 61                	jmp    80108d2e <copyout+0xa0>
    }
    n = PGSIZE - (va - va0);
80108ccd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cd0:	2b 45 0c             	sub    0xc(%ebp),%eax
80108cd3:	05 00 10 00 00       	add    $0x1000,%eax
80108cd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cde:	3b 45 14             	cmp    0x14(%ebp),%eax
80108ce1:	76 06                	jbe    80108ce9 <copyout+0x5b>
      n = len;
80108ce3:	8b 45 14             	mov    0x14(%ebp),%eax
80108ce6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cec:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108cef:	89 c2                	mov    %eax,%edx
80108cf1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108cf4:	01 d0                	add    %edx,%eax
80108cf6:	83 ec 04             	sub    $0x4,%esp
80108cf9:	ff 75 f0             	pushl  -0x10(%ebp)
80108cfc:	ff 75 f4             	pushl  -0xc(%ebp)
80108cff:	50                   	push   %eax
80108d00:	e8 38 c9 ff ff       	call   8010563d <memmove>
80108d05:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108d08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d0b:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108d0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d11:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108d14:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d17:	05 00 10 00 00       	add    $0x1000,%eax
80108d1c:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108d1f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108d23:	0f 85 77 ff ff ff    	jne    80108ca0 <copyout+0x12>
  }
  return 0;
80108d29:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108d2e:	c9                   	leave  
80108d2f:	c3                   	ret    

80108d30 <mdecrypt>:


//returns 0 on success
int mdecrypt(char *virtual_addr) {
80108d30:	f3 0f 1e fb          	endbr32 
80108d34:	55                   	push   %ebp
80108d35:	89 e5                	mov    %esp,%ebp
80108d37:	83 ec 28             	sub    $0x28,%esp
  //cprintf("mdecrypt: VPN %d, %p, pid %d\n", PPN(virtual_addr), virtual_addr, myproc()->pid);
  //the given pointer is a virtual address in this pid's userspace
  // cprintf("in mdecrypt");
  struct proc * p = myproc();
80108d3a:	e8 71 b7 ff ff       	call   801044b0 <myproc>
80108d3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pde_t* mypd = p->pgdir;
80108d42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d45:	8b 40 04             	mov    0x4(%eax),%eax
80108d48:	89 45 e8             	mov    %eax,-0x18(%ebp)
  //set the present bit to true and encrypt bit to false
  pte_t * pte = walkpgdir(mypd, virtual_addr, 0);
80108d4b:	83 ec 04             	sub    $0x4,%esp
80108d4e:	6a 00                	push   $0x0
80108d50:	ff 75 08             	pushl  0x8(%ebp)
80108d53:	ff 75 e8             	pushl  -0x18(%ebp)
80108d56:	e8 55 f3 ff ff       	call   801080b0 <walkpgdir>
80108d5b:	83 c4 10             	add    $0x10,%esp
80108d5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (!pte || *pte == 0) {
80108d61:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108d65:	74 09                	je     80108d70 <mdecrypt+0x40>
80108d67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d6a:	8b 00                	mov    (%eax),%eax
80108d6c:	85 c0                	test   %eax,%eax
80108d6e:	75 07                	jne    80108d77 <mdecrypt+0x47>
    return -1;
80108d70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d75:	eb 7a                	jmp    80108df1 <mdecrypt+0xc1>
  }

  *pte = *pte & ~PTE_E;
80108d77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d7a:	8b 00                	mov    (%eax),%eax
80108d7c:	80 e4 fb             	and    $0xfb,%ah
80108d7f:	89 c2                	mov    %eax,%edx
80108d81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d84:	89 10                	mov    %edx,(%eax)
  *pte = *pte | PTE_P;
80108d86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d89:	8b 00                	mov    (%eax),%eax
80108d8b:	83 c8 01             	or     $0x1,%eax
80108d8e:	89 c2                	mov    %eax,%edx
80108d90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d93:	89 10                	mov    %edx,(%eax)
  *pte = *pte | PTE_A;
80108d95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d98:	8b 00                	mov    (%eax),%eax
80108d9a:	83 c8 20             	or     $0x20,%eax
80108d9d:	89 c2                	mov    %eax,%edx
80108d9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108da2:	89 10                	mov    %edx,(%eax)
  
  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108da4:	8b 45 08             	mov    0x8(%ebp),%eax
80108da7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108dac:	89 45 08             	mov    %eax,0x8(%ebp)
  

  char * slider = virtual_addr;
80108daf:	8b 45 08             	mov    0x8(%ebp),%eax
80108db2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108db5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108dbc:	eb 17                	jmp    80108dd5 <mdecrypt+0xa5>
    *slider = ~*slider;
80108dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dc1:	0f b6 00             	movzbl (%eax),%eax
80108dc4:	f7 d0                	not    %eax
80108dc6:	89 c2                	mov    %eax,%edx
80108dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dcb:	88 10                	mov    %dl,(%eax)
    slider++;
80108dcd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108dd1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108dd5:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80108ddc:	7e e0                	jle    80108dbe <mdecrypt+0x8e>
  }

  addtoworkingset(virtual_addr);
80108dde:	83 ec 0c             	sub    $0xc,%esp
80108de1:	ff 75 08             	pushl  0x8(%ebp)
80108de4:	e8 61 f3 ff ff       	call   8010814a <addtoworkingset>
80108de9:	83 c4 10             	add    $0x10,%esp

  return 0;
80108dec:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108df1:	c9                   	leave  
80108df2:	c3                   	ret    

80108df3 <mencrypt>:

int mencrypt(char *virtual_addr, int len) {
80108df3:	f3 0f 1e fb          	endbr32 
80108df7:	55                   	push   %ebp
80108df8:	89 e5                	mov    %esp,%ebp
80108dfa:	83 ec 28             	sub    $0x28,%esp
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
80108dfd:	e8 ae b6 ff ff       	call   801044b0 <myproc>
80108e02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t* mypd = p->pgdir;
80108e05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e08:	8b 40 04             	mov    0x4(%eax),%eax
80108e0b:	89 45 e0             	mov    %eax,-0x20(%ebp)

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108e0e:	8b 45 08             	mov    0x8(%ebp),%eax
80108e11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e16:	89 45 08             	mov    %eax,0x8(%ebp)

  //error checking first. all or nothing.
  char * slider = virtual_addr;
80108e19:	8b 45 08             	mov    0x8(%ebp),%eax
80108e1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108e1f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108e26:	eb 3f                	jmp    80108e67 <mencrypt+0x74>
    //check page table for each translation first
    char * kvp = uva2ka(mypd, slider);
80108e28:	83 ec 08             	sub    $0x8,%esp
80108e2b:	ff 75 f4             	pushl  -0xc(%ebp)
80108e2e:	ff 75 e0             	pushl  -0x20(%ebp)
80108e31:	e8 ff fd ff ff       	call   80108c35 <uva2ka>
80108e36:	83 c4 10             	add    $0x10,%esp
80108e39:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if (!kvp) {
80108e3c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80108e40:	75 1a                	jne    80108e5c <mencrypt+0x69>
      cprintf("mencrypt: Could not access address\n");
80108e42:	83 ec 0c             	sub    $0xc,%esp
80108e45:	68 e0 99 10 80       	push   $0x801099e0
80108e4a:	e8 c9 75 ff ff       	call   80100418 <cprintf>
80108e4f:	83 c4 10             	add    $0x10,%esp
      return -1;
80108e52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e57:	e9 ce 00 00 00       	jmp    80108f2a <mencrypt+0x137>
    }
    slider = slider + PGSIZE;
80108e5c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108e63:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e6a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e6d:	7c b9                	jl     80108e28 <mencrypt+0x35>
  }

  //encrypt stage. Have to do this before setting flag 
  //or else we'll page fault
  slider = virtual_addr;
80108e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80108e72:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108e75:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108e7c:	e9 87 00 00 00       	jmp    80108f08 <mencrypt+0x115>
    //we get the page table entry that corresponds to this VA
    pte_t * mypte = walkpgdir(mypd, slider, 0);
80108e81:	83 ec 04             	sub    $0x4,%esp
80108e84:	6a 00                	push   $0x0
80108e86:	ff 75 f4             	pushl  -0xc(%ebp)
80108e89:	ff 75 e0             	pushl  -0x20(%ebp)
80108e8c:	e8 1f f2 ff ff       	call   801080b0 <walkpgdir>
80108e91:	83 c4 10             	add    $0x10,%esp
80108e94:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (*mypte & PTE_E) {//already encrypted
80108e97:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e9a:	8b 00                	mov    (%eax),%eax
80108e9c:	25 00 04 00 00       	and    $0x400,%eax
80108ea1:	85 c0                	test   %eax,%eax
80108ea3:	74 09                	je     80108eae <mencrypt+0xbb>
      slider += PGSIZE;
80108ea5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      continue;
80108eac:	eb 56                	jmp    80108f04 <mencrypt+0x111>
    }
    for (int offset = 0; offset < PGSIZE; offset++) {
80108eae:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80108eb5:	eb 17                	jmp    80108ece <mencrypt+0xdb>
      *slider = ~*slider;
80108eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eba:	0f b6 00             	movzbl (%eax),%eax
80108ebd:	f7 d0                	not    %eax
80108ebf:	89 c2                	mov    %eax,%edx
80108ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ec4:	88 10                	mov    %dl,(%eax)
      slider++;
80108ec6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    for (int offset = 0; offset < PGSIZE; offset++) {
80108eca:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80108ece:	81 7d e8 ff 0f 00 00 	cmpl   $0xfff,-0x18(%ebp)
80108ed5:	7e e0                	jle    80108eb7 <mencrypt+0xc4>
    }
    *mypte = *mypte & ~PTE_P;
80108ed7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108eda:	8b 00                	mov    (%eax),%eax
80108edc:	83 e0 fe             	and    $0xfffffffe,%eax
80108edf:	89 c2                	mov    %eax,%edx
80108ee1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ee4:	89 10                	mov    %edx,(%eax)
    *mypte = *mypte | PTE_E;
80108ee6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ee9:	8b 00                	mov    (%eax),%eax
80108eeb:	80 cc 04             	or     $0x4,%ah
80108eee:	89 c2                	mov    %eax,%edx
80108ef0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ef3:	89 10                	mov    %edx,(%eax)
    *mypte = *mypte & ~PTE_A;
80108ef5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ef8:	8b 00                	mov    (%eax),%eax
80108efa:	83 e0 df             	and    $0xffffffdf,%eax
80108efd:	89 c2                	mov    %eax,%edx
80108eff:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f02:	89 10                	mov    %edx,(%eax)
  for (int i = 0; i < len; i++) { 
80108f04:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108f08:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f0b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f0e:	0f 8c 6d ff ff ff    	jl     80108e81 <mencrypt+0x8e>
  }

  switchuvm(myproc());
80108f14:	e8 97 b5 ff ff       	call   801044b0 <myproc>
80108f19:	83 ec 0c             	sub    $0xc,%esp
80108f1c:	50                   	push   %eax
80108f1d:	e8 46 f6 ff ff       	call   80108568 <switchuvm>
80108f22:	83 c4 10             	add    $0x10,%esp
  return 0;
80108f25:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f2a:	c9                   	leave  
80108f2b:	c3                   	ret    

80108f2c <getpgtable>:

int getpgtable(struct pt_entry* entries, int num, int wsetOnly) {
80108f2c:	f3 0f 1e fb          	endbr32 
80108f30:	55                   	push   %ebp
80108f31:	89 e5                	mov    %esp,%ebp
80108f33:	83 ec 28             	sub    $0x28,%esp
  struct proc * me = myproc();
80108f36:	e8 75 b5 ff ff       	call   801044b0 <myproc>
80108f3b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(wsetOnly != 0 && wsetOnly != 1)
80108f3e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108f42:	74 10                	je     80108f54 <getpgtable+0x28>
80108f44:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
80108f48:	74 0a                	je     80108f54 <getpgtable+0x28>
    return -1;
80108f4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f4f:	e9 4a 02 00 00       	jmp    8010919e <getpgtable+0x272>
  int index = 0;
80108f54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  int count=0;
80108f5b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  //reverse order
  // if(wsetOnly){
  //   num=num+1;
  // }
  
  for (void * i = (void*) PGROUNDDOWN(((int)me->sz)); i >= 0 && count < num; i-=PGSIZE) {
80108f62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f65:	8b 00                	mov    (%eax),%eax
80108f67:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108f6f:	e9 bd 01 00 00       	jmp    80109131 <getpgtable+0x205>
    // count++;

    // num--;
    // count++;
    //Those entries contain the physical page number + flags
    curr_pte = walkpgdir(me->pgdir, i, 0);
80108f74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f77:	8b 40 04             	mov    0x4(%eax),%eax
80108f7a:	83 ec 04             	sub    $0x4,%esp
80108f7d:	6a 00                	push   $0x0
80108f7f:	ff 75 ec             	pushl  -0x14(%ebp)
80108f82:	50                   	push   %eax
80108f83:	e8 28 f1 ff ff       	call   801080b0 <walkpgdir>
80108f88:	83 c4 10             	add    $0x10,%esp
80108f8b:	89 45 e0             	mov    %eax,-0x20(%ebp)


    //currPage is 0 if page is not allocated
    //see deallocuvm
    if (curr_pte && *curr_pte) {//this page is allocated
80108f8e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108f92:	0f 84 89 01 00 00    	je     80109121 <getpgtable+0x1f5>
80108f98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f9b:	8b 00                	mov    (%eax),%eax
80108f9d:	85 c0                	test   %eax,%eax
80108f9f:	0f 84 7c 01 00 00    	je     80109121 <getpgtable+0x1f5>
      //this is the same for all pt_entries... right?
      // if(*curr_pte& PTE_U){
      // count++;
      // }
      count++;
80108fa5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(wsetOnly){
80108fa9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108fad:	74 16                	je     80108fc5 <getpgtable+0x99>
        if(!inwset(i)) {
80108faf:	83 ec 0c             	sub    $0xc,%esp
80108fb2:	ff 75 ec             	pushl  -0x14(%ebp)
80108fb5:	e8 58 ed ff ff       	call   80107d12 <inwset>
80108fba:	83 c4 10             	add    $0x10,%esp
80108fbd:	85 c0                	test   %eax,%eax
80108fbf:	0f 84 64 01 00 00    	je     80109129 <getpgtable+0x1fd>
  
	      continue;
        }
      }

      entries[index].pdx = PDX(i); 
80108fc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fc8:	c1 e8 16             	shr    $0x16,%eax
80108fcb:	89 c1                	mov    %eax,%ecx
80108fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fd0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108fd7:	8b 45 08             	mov    0x8(%ebp),%eax
80108fda:	01 c2                	add    %eax,%edx
80108fdc:	89 c8                	mov    %ecx,%eax
80108fde:	66 25 ff 03          	and    $0x3ff,%ax
80108fe2:	66 25 ff 03          	and    $0x3ff,%ax
80108fe6:	89 c1                	mov    %eax,%ecx
80108fe8:	0f b7 02             	movzwl (%edx),%eax
80108feb:	66 25 00 fc          	and    $0xfc00,%ax
80108fef:	09 c8                	or     %ecx,%eax
80108ff1:	66 89 02             	mov    %ax,(%edx)
      entries[index].ptx = PTX(i);
80108ff4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ff7:	c1 e8 0c             	shr    $0xc,%eax
80108ffa:	89 c1                	mov    %eax,%ecx
80108ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fff:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109006:	8b 45 08             	mov    0x8(%ebp),%eax
80109009:	01 c2                	add    %eax,%edx
8010900b:	89 c8                	mov    %ecx,%eax
8010900d:	66 25 ff 03          	and    $0x3ff,%ax
80109011:	0f b7 c0             	movzwl %ax,%eax
80109014:	25 ff 03 00 00       	and    $0x3ff,%eax
80109019:	c1 e0 0a             	shl    $0xa,%eax
8010901c:	89 c1                	mov    %eax,%ecx
8010901e:	8b 02                	mov    (%edx),%eax
80109020:	25 ff 03 f0 ff       	and    $0xfff003ff,%eax
80109025:	09 c8                	or     %ecx,%eax
80109027:	89 02                	mov    %eax,(%edx)
      //convert to physical addr then shift to get PPN 
      entries[index].ppage = PPN(*curr_pte);
80109029:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010902c:	8b 00                	mov    (%eax),%eax
8010902e:	c1 e8 0c             	shr    $0xc,%eax
80109031:	89 c2                	mov    %eax,%edx
80109033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109036:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010903d:	8b 45 08             	mov    0x8(%ebp),%eax
80109040:	01 c8                	add    %ecx,%eax
80109042:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
80109048:	89 d1                	mov    %edx,%ecx
8010904a:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
80109050:	8b 50 04             	mov    0x4(%eax),%edx
80109053:	81 e2 00 00 f0 ff    	and    $0xfff00000,%edx
80109059:	09 ca                	or     %ecx,%edx
8010905b:	89 50 04             	mov    %edx,0x4(%eax)
      //have to set it like this because these are 1 bit wide fields
      entries[index].present = (*curr_pte & PTE_P) ? 1 : 0;
8010905e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109061:	8b 08                	mov    (%eax),%ecx
80109063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109066:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010906d:	8b 45 08             	mov    0x8(%ebp),%eax
80109070:	01 c2                	add    %eax,%edx
80109072:	89 c8                	mov    %ecx,%eax
80109074:	83 e0 01             	and    $0x1,%eax
80109077:	83 e0 01             	and    $0x1,%eax
8010907a:	c1 e0 04             	shl    $0x4,%eax
8010907d:	89 c1                	mov    %eax,%ecx
8010907f:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80109083:	83 e0 ef             	and    $0xffffffef,%eax
80109086:	09 c8                	or     %ecx,%eax
80109088:	88 42 06             	mov    %al,0x6(%edx)
      entries[index].writable = (*curr_pte & PTE_W) ? 1 : 0;
8010908b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010908e:	8b 00                	mov    (%eax),%eax
80109090:	d1 e8                	shr    %eax
80109092:	89 c1                	mov    %eax,%ecx
80109094:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109097:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010909e:	8b 45 08             	mov    0x8(%ebp),%eax
801090a1:	01 c2                	add    %eax,%edx
801090a3:	89 c8                	mov    %ecx,%eax
801090a5:	83 e0 01             	and    $0x1,%eax
801090a8:	83 e0 01             	and    $0x1,%eax
801090ab:	c1 e0 05             	shl    $0x5,%eax
801090ae:	89 c1                	mov    %eax,%ecx
801090b0:	0f b6 42 06          	movzbl 0x6(%edx),%eax
801090b4:	83 e0 df             	and    $0xffffffdf,%eax
801090b7:	09 c8                	or     %ecx,%eax
801090b9:	88 42 06             	mov    %al,0x6(%edx)
      entries[index].encrypted = (*curr_pte & PTE_E) ? 1 : 0;
801090bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090bf:	8b 00                	mov    (%eax),%eax
801090c1:	c1 e8 0a             	shr    $0xa,%eax
801090c4:	89 c1                	mov    %eax,%ecx
801090c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801090d0:	8b 45 08             	mov    0x8(%ebp),%eax
801090d3:	01 c2                	add    %eax,%edx
801090d5:	89 c8                	mov    %ecx,%eax
801090d7:	83 e0 01             	and    $0x1,%eax
801090da:	83 e0 01             	and    $0x1,%eax
801090dd:	c1 e0 06             	shl    $0x6,%eax
801090e0:	89 c1                	mov    %eax,%ecx
801090e2:	0f b6 42 06          	movzbl 0x6(%edx),%eax
801090e6:	83 e0 bf             	and    $0xffffffbf,%eax
801090e9:	09 c8                	or     %ecx,%eax
801090eb:	88 42 06             	mov    %al,0x6(%edx)
      entries[index].ref       =  (*curr_pte & PTE_A)? 1:0;
801090ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090f1:	8b 00                	mov    (%eax),%eax
801090f3:	c1 e8 05             	shr    $0x5,%eax
801090f6:	89 c1                	mov    %eax,%ecx
801090f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090fb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109102:	8b 45 08             	mov    0x8(%ebp),%eax
80109105:	01 c2                	add    %eax,%edx
80109107:	89 c8                	mov    %ecx,%eax
80109109:	83 e0 01             	and    $0x1,%eax
8010910c:	83 e0 01             	and    $0x1,%eax
8010910f:	89 c1                	mov    %eax,%ecx
80109111:	0f b6 42 07          	movzbl 0x7(%edx),%eax
80109115:	83 e0 fe             	and    $0xfffffffe,%eax
80109118:	09 c8                	or     %ecx,%eax
8010911a:	88 42 07             	mov    %al,0x7(%edx)
      index++;
8010911d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      
    }

    if (i == 0) {
80109121:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109125:	74 18                	je     8010913f <getpgtable+0x213>
80109127:	eb 01                	jmp    8010912a <getpgtable+0x1fe>
	      continue;
80109129:	90                   	nop
  for (void * i = (void*) PGROUNDDOWN(((int)me->sz)); i >= 0 && count < num; i-=PGSIZE) {
8010912a:	81 6d ec 00 10 00 00 	subl   $0x1000,-0x14(%ebp)
80109131:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109134:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109137:	0f 8c 37 fe ff ff    	jl     80108f74 <getpgtable+0x48>
8010913d:	eb 01                	jmp    80109140 <getpgtable+0x214>
      break;
8010913f:	90                   	nop
    }
    
  }
  if(index==0){
80109140:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109144:	75 55                	jne    8010919b <getpgtable+0x26f>
    cprintf("qeueue length %d\n",me->queue_size);
80109146:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109149:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
8010914f:	83 ec 08             	sub    $0x8,%esp
80109152:	50                   	push   %eax
80109153:	68 04 9a 10 80       	push   $0x80109a04
80109158:	e8 bb 72 ff ff       	call   80100418 <cprintf>
8010915d:	83 c4 10             	add    $0x10,%esp
    for (int i=0; i<CLOCKSIZE;i++){
80109160:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80109167:	eb 21                	jmp    8010918a <getpgtable+0x25e>
      cprintf("value is %d\n",me->clock_queue[i].va);
80109169:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010916c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010916f:	83 c2 10             	add    $0x10,%edx
80109172:	8b 04 d0             	mov    (%eax,%edx,8),%eax
80109175:	83 ec 08             	sub    $0x8,%esp
80109178:	50                   	push   %eax
80109179:	68 16 9a 10 80       	push   $0x80109a16
8010917e:	e8 95 72 ff ff       	call   80100418 <cprintf>
80109183:	83 c4 10             	add    $0x10,%esp
    for (int i=0; i<CLOCKSIZE;i++){
80109186:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
8010918a:	83 7d e8 07          	cmpl   $0x7,-0x18(%ebp)
8010918e:	7e d9                	jle    80109169 <getpgtable+0x23d>
      
    }
    return me->queue_size;
80109190:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109193:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
80109199:	eb 03                	jmp    8010919e <getpgtable+0x272>
  }  
  //index is the number of ptes copied
  return index;
8010919b:	8b 45 f4             	mov    -0xc(%ebp),%eax

}
8010919e:	c9                   	leave  
8010919f:	c3                   	ret    

801091a0 <dump_rawphymem>:


int dump_rawphymem(uint physical_addr, char * buffer) {
801091a0:	f3 0f 1e fb          	endbr32 
801091a4:	55                   	push   %ebp
801091a5:	89 e5                	mov    %esp,%ebp
801091a7:	56                   	push   %esi
801091a8:	53                   	push   %ebx
801091a9:	83 ec 10             	sub    $0x10,%esp
  //note that copyout converts buffer to a kva and then copies
  //which means that if buffer is encrypted, it won't trigger a decryption request
  *buffer = *buffer;
801091ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801091af:	0f b6 10             	movzbl (%eax),%edx
801091b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801091b5:	88 10                	mov    %dl,(%eax)
  int retval = copyout(myproc()->pgdir, (uint) buffer, (void *) P2V(physical_addr), PGSIZE);
801091b7:	8b 45 08             	mov    0x8(%ebp),%eax
801091ba:	05 00 00 00 80       	add    $0x80000000,%eax
801091bf:	89 c6                	mov    %eax,%esi
801091c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801091c4:	e8 e7 b2 ff ff       	call   801044b0 <myproc>
801091c9:	8b 40 04             	mov    0x4(%eax),%eax
801091cc:	68 00 10 00 00       	push   $0x1000
801091d1:	56                   	push   %esi
801091d2:	53                   	push   %ebx
801091d3:	50                   	push   %eax
801091d4:	e8 b5 fa ff ff       	call   80108c8e <copyout>
801091d9:	83 c4 10             	add    $0x10,%esp
801091dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (retval)
801091df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801091e3:	74 07                	je     801091ec <dump_rawphymem+0x4c>
    return -1;
801091e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091ea:	eb 05                	jmp    801091f1 <dump_rawphymem+0x51>
  return 0;
801091ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801091f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801091f4:	5b                   	pop    %ebx
801091f5:	5e                   	pop    %esi
801091f6:	5d                   	pop    %ebp
801091f7:	c3                   	ret    
