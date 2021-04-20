
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
8010002d:	b8 3e 3a 10 80       	mov    $0x80103a3e,%eax
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
80100041:	68 2c 93 10 80       	push   $0x8010932c
80100046:	68 60 d6 10 80       	push   $0x8010d660
8010004b:	e8 63 52 00 00       	call   801052b3 <initlock>
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
8010008f:	68 33 93 10 80       	push   $0x80109333
80100094:	50                   	push   %eax
80100095:	e8 86 50 00 00       	call   80105120 <initsleeplock>
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
801000d7:	e8 fd 51 00 00       	call   801052d9 <acquire>
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
80100116:	e8 30 52 00 00       	call   8010534b <release>
8010011b:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	83 c0 0c             	add    $0xc,%eax
80100124:	83 ec 0c             	sub    $0xc,%esp
80100127:	50                   	push   %eax
80100128:	e8 33 50 00 00       	call   80105160 <acquiresleep>
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
80100197:	e8 af 51 00 00       	call   8010534b <release>
8010019c:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010019f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a2:	83 c0 0c             	add    $0xc,%eax
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	50                   	push   %eax
801001a9:	e8 b2 4f 00 00       	call   80105160 <acquiresleep>
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
801001cb:	68 3a 93 10 80       	push   $0x8010933a
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
80100207:	e8 b7 28 00 00       	call   80102ac3 <iderw>
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
80100228:	e8 ed 4f 00 00       	call   8010521a <holdingsleep>
8010022d:	83 c4 10             	add    $0x10,%esp
80100230:	85 c0                	test   %eax,%eax
80100232:	75 0d                	jne    80100241 <bwrite+0x2d>
    panic("bwrite");
80100234:	83 ec 0c             	sub    $0xc,%esp
80100237:	68 4b 93 10 80       	push   $0x8010934b
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
80100256:	e8 68 28 00 00       	call   80102ac3 <iderw>
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
80100275:	e8 a0 4f 00 00       	call   8010521a <holdingsleep>
8010027a:	83 c4 10             	add    $0x10,%esp
8010027d:	85 c0                	test   %eax,%eax
8010027f:	75 0d                	jne    8010028e <brelse+0x2d>
    panic("brelse");
80100281:	83 ec 0c             	sub    $0xc,%esp
80100284:	68 52 93 10 80       	push   $0x80109352
80100289:	e8 7a 03 00 00       	call   80100608 <panic>

  releasesleep(&b->lock);
8010028e:	8b 45 08             	mov    0x8(%ebp),%eax
80100291:	83 c0 0c             	add    $0xc,%eax
80100294:	83 ec 0c             	sub    $0xc,%esp
80100297:	50                   	push   %eax
80100298:	e8 2b 4f 00 00       	call   801051c8 <releasesleep>
8010029d:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	68 60 d6 10 80       	push   $0x8010d660
801002a8:	e8 2c 50 00 00       	call   801052d9 <acquire>
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
80100318:	e8 2e 50 00 00       	call   8010534b <release>
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
80100438:	e8 e3 4f 00 00       	call   80105420 <holding>
8010043d:	83 c4 10             	add    $0x10,%esp
80100440:	85 c0                	test   %eax,%eax
80100442:	75 10                	jne    80100454 <cprintf+0x3c>
    acquire(&cons.lock);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	68 c0 c5 10 80       	push   $0x8010c5c0
8010044c:	e8 88 4e 00 00       	call   801052d9 <acquire>
80100451:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100454:	8b 45 08             	mov    0x8(%ebp),%eax
80100457:	85 c0                	test   %eax,%eax
80100459:	75 0d                	jne    80100468 <cprintf+0x50>
    panic("null fmt");
8010045b:	83 ec 0c             	sub    $0xc,%esp
8010045e:	68 5c 93 10 80       	push   $0x8010935c
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
801004ee:	8b 04 85 6c 93 10 80 	mov    -0x7fef6c94(,%eax,4),%eax
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
8010054c:	c7 45 ec 65 93 10 80 	movl   $0x80109365,-0x14(%ebp)
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
801005fd:	e8 49 4d 00 00       	call   8010534b <release>
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
80100621:	e8 69 2b 00 00       	call   8010318f <lapicid>
80100626:	83 ec 08             	sub    $0x8,%esp
80100629:	50                   	push   %eax
8010062a:	68 c4 93 10 80       	push   $0x801093c4
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
80100649:	68 d8 93 10 80       	push   $0x801093d8
8010064e:	e8 c5 fd ff ff       	call   80100418 <cprintf>
80100653:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100656:	83 ec 08             	sub    $0x8,%esp
80100659:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010065c:	50                   	push   %eax
8010065d:	8d 45 08             	lea    0x8(%ebp),%eax
80100660:	50                   	push   %eax
80100661:	e8 3b 4d 00 00       	call   801053a1 <getcallerpcs>
80100666:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100670:	eb 1c                	jmp    8010068e <panic+0x86>
    cprintf(" %p", pcs[i]);
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100679:	83 ec 08             	sub    $0x8,%esp
8010067c:	50                   	push   %eax
8010067d:	68 da 93 10 80       	push   $0x801093da
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
80100772:	68 de 93 10 80       	push   $0x801093de
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
8010079f:	e8 9b 4e 00 00       	call   8010563f <memmove>
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
801007c9:	e8 aa 4d 00 00       	call   80105578 <memset>
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
80100865:	e8 2a 68 00 00       	call   80107094 <uartputc>
8010086a:	83 c4 10             	add    $0x10,%esp
8010086d:	83 ec 0c             	sub    $0xc,%esp
80100870:	6a 20                	push   $0x20
80100872:	e8 1d 68 00 00       	call   80107094 <uartputc>
80100877:	83 c4 10             	add    $0x10,%esp
8010087a:	83 ec 0c             	sub    $0xc,%esp
8010087d:	6a 08                	push   $0x8
8010087f:	e8 10 68 00 00       	call   80107094 <uartputc>
80100884:	83 c4 10             	add    $0x10,%esp
80100887:	eb 0e                	jmp    80100897 <consputc+0x5a>
  } else
    uartputc(c);
80100889:	83 ec 0c             	sub    $0xc,%esp
8010088c:	ff 75 08             	pushl  0x8(%ebp)
8010088f:	e8 00 68 00 00       	call   80107094 <uartputc>
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
801008c1:	e8 13 4a 00 00       	call   801052d9 <acquire>
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
80100a17:	e8 3d 45 00 00       	call   80104f59 <wakeup>
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
80100a3a:	e8 0c 49 00 00       	call   8010534b <release>
80100a3f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100a42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a46:	74 05                	je     80100a4d <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
80100a48:	e8 d2 45 00 00       	call   8010501f <procdump>
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
80100a60:	e8 e4 11 00 00       	call   80101c49 <iunlock>
80100a65:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a68:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a76:	e8 5e 48 00 00       	call   801052d9 <acquire>
80100a7b:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a7e:	e9 ab 00 00 00       	jmp    80100b2e <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
80100a83:	e8 38 3a 00 00       	call   801044c0 <myproc>
80100a88:	8b 40 24             	mov    0x24(%eax),%eax
80100a8b:	85 c0                	test   %eax,%eax
80100a8d:	74 28                	je     80100ab7 <consoleread+0x67>
        release(&cons.lock);
80100a8f:	83 ec 0c             	sub    $0xc,%esp
80100a92:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a97:	e8 af 48 00 00       	call   8010534b <release>
80100a9c:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a9f:	83 ec 0c             	sub    $0xc,%esp
80100aa2:	ff 75 08             	pushl  0x8(%ebp)
80100aa5:	e8 88 10 00 00       	call   80101b32 <ilock>
80100aaa:	83 c4 10             	add    $0x10,%esp
        return -1;
80100aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ab2:	e9 ab 00 00 00       	jmp    80100b62 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100ab7:	83 ec 08             	sub    $0x8,%esp
80100aba:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abf:	68 40 20 11 80       	push   $0x80112040
80100ac4:	e8 9e 43 00 00       	call   80104e67 <sleep>
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
80100b42:	e8 04 48 00 00       	call   8010534b <release>
80100b47:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	ff 75 08             	pushl  0x8(%ebp)
80100b50:	e8 dd 0f 00 00       	call   80101b32 <ilock>
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
80100b74:	e8 d0 10 00 00       	call   80101c49 <iunlock>
80100b79:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b7c:	83 ec 0c             	sub    $0xc,%esp
80100b7f:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b84:	e8 50 47 00 00       	call   801052d9 <acquire>
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
80100bc6:	e8 80 47 00 00       	call   8010534b <release>
80100bcb:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bce:	83 ec 0c             	sub    $0xc,%esp
80100bd1:	ff 75 08             	pushl  0x8(%ebp)
80100bd4:	e8 59 0f 00 00       	call   80101b32 <ilock>
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
80100bee:	68 f1 93 10 80       	push   $0x801093f1
80100bf3:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bf8:	e8 b6 46 00 00       	call   801052b3 <initlock>
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
80100c25:	e8 72 20 00 00       	call   80102c9c <ioapicenable>
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
80100c3d:	e8 7e 38 00 00       	call   801044c0 <myproc>
80100c42:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c45:	e8 b7 2a 00 00       	call   80103701 <begin_op>

  if((ip = namei(path)) == 0){
80100c4a:	83 ec 0c             	sub    $0xc,%esp
80100c4d:	ff 75 08             	pushl  0x8(%ebp)
80100c50:	e8 48 1a 00 00       	call   8010269d <namei>
80100c55:	83 c4 10             	add    $0x10,%esp
80100c58:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c5b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c5f:	75 1f                	jne    80100c80 <exec+0x50>
    end_op();
80100c61:	e8 2b 2b 00 00       	call   80103791 <end_op>
    cprintf("exec: fail\n");
80100c66:	83 ec 0c             	sub    $0xc,%esp
80100c69:	68 f9 93 10 80       	push   $0x801093f9
80100c6e:	e8 a5 f7 ff ff       	call   80100418 <cprintf>
80100c73:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c7b:	e9 48 04 00 00       	jmp    801010c8 <exec+0x498>
  }
  ilock(ip);
80100c80:	83 ec 0c             	sub    $0xc,%esp
80100c83:	ff 75 d8             	pushl  -0x28(%ebp)
80100c86:	e8 a7 0e 00 00       	call   80101b32 <ilock>
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
80100ca3:	e8 92 13 00 00       	call   8010203a <readi>
80100ca8:	83 c4 10             	add    $0x10,%esp
80100cab:	83 f8 34             	cmp    $0x34,%eax
80100cae:	0f 85 bd 03 00 00    	jne    80101071 <exec+0x441>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100cb4:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100cba:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cbf:	0f 85 af 03 00 00    	jne    80101074 <exec+0x444>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100cc5:	e8 2e 79 00 00       	call   801085f8 <setupkvm>
80100cca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ccd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100cd1:	0f 84 a0 03 00 00    	je     80101077 <exec+0x447>
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
80100d03:	e8 32 13 00 00       	call   8010203a <readi>
80100d08:	83 c4 10             	add    $0x10,%esp
80100d0b:	83 f8 20             	cmp    $0x20,%eax
80100d0e:	0f 85 66 03 00 00    	jne    8010107a <exec+0x44a>
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
80100d31:	0f 82 46 03 00 00    	jb     8010107d <exec+0x44d>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d37:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d3d:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d43:	01 c2                	add    %eax,%edx
80100d45:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d4b:	39 c2                	cmp    %eax,%edx
80100d4d:	0f 82 2d 03 00 00    	jb     80101080 <exec+0x450>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d53:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d59:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d5f:	01 d0                	add    %edx,%eax
80100d61:	83 ec 04             	sub    $0x4,%esp
80100d64:	50                   	push   %eax
80100d65:	ff 75 e0             	pushl  -0x20(%ebp)
80100d68:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d6b:	e8 46 7c 00 00       	call   801089b6 <allocuvm>
80100d70:	83 c4 10             	add    $0x10,%esp
80100d73:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d76:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7a:	0f 84 03 03 00 00    	je     80101083 <exec+0x453>
      goto bad;

    if(ph.vaddr % PGSIZE != 0)
80100d80:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d86:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d8b:	85 c0                	test   %eax,%eax
80100d8d:	0f 85 f3 02 00 00    	jne    80101086 <exec+0x456>
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
80100db1:	e8 2f 7b 00 00       	call   801088e5 <loaduvm>
80100db6:	83 c4 20             	add    $0x20,%esp
80100db9:	85 c0                	test   %eax,%eax
80100dbb:	0f 88 c8 02 00 00    	js     80101089 <exec+0x459>
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
80100dea:	e8 80 0f 00 00       	call   80101d6f <iunlockput>
80100def:	83 c4 10             	add    $0x10,%esp
  end_op();
80100df2:	e8 9a 29 00 00       	call   80103791 <end_op>
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
80100e20:	e8 91 7b 00 00       	call   801089b6 <allocuvm>
80100e25:	83 c4 10             	add    $0x10,%esp
80100e28:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e2b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e2f:	0f 84 57 02 00 00    	je     8010108c <exec+0x45c>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e38:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e3d:	83 ec 08             	sub    $0x8,%esp
80100e40:	50                   	push   %eax
80100e41:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e44:	e8 ef 7d 00 00       	call   80108c38 <clearpteu>
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
80100e62:	0f 87 27 02 00 00    	ja     8010108f <exec+0x45f>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e72:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e75:	01 d0                	add    %edx,%eax
80100e77:	8b 00                	mov    (%eax),%eax
80100e79:	83 ec 0c             	sub    $0xc,%esp
80100e7c:	50                   	push   %eax
80100e7d:	e8 5f 49 00 00       	call   801057e1 <strlen>
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
80100eaa:	e8 32 49 00 00       	call   801057e1 <strlen>
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
80100ed0:	e8 1f 7f 00 00       	call   80108df4 <copyout>
80100ed5:	83 c4 10             	add    $0x10,%esp
80100ed8:	85 c0                	test   %eax,%eax
80100eda:	0f 88 b2 01 00 00    	js     80101092 <exec+0x462>
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
80100f6c:	e8 83 7e 00 00       	call   80108df4 <copyout>
80100f71:	83 c4 10             	add    $0x10,%esp
80100f74:	85 c0                	test   %eax,%eax
80100f76:	0f 88 19 01 00 00    	js     80101095 <exec+0x465>
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
80100fae:	83 c0 6c             	add    $0x6c,%eax
80100fb1:	83 ec 04             	sub    $0x4,%esp
80100fb4:	6a 10                	push   $0x10
80100fb6:	ff 75 f0             	pushl  -0x10(%ebp)
80100fb9:	50                   	push   %eax
80100fba:	e8 d4 47 00 00       	call   80105793 <safestrcpy>
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

  cprintf("in exec");
80100fd4:	83 ec 0c             	sub    $0xc,%esp
80100fd7:	68 05 94 10 80       	push   $0x80109405
80100fdc:	e8 37 f4 ff ff       	call   80100418 <cprintf>
80100fe1:	83 c4 10             	add    $0x10,%esp


  //uint change = sz - PGROUNDDOWN(curproc->sz);
  curproc->sz = sz;
80100fe4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fe7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fea:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fec:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fef:	8b 40 18             	mov    0x18(%eax),%eax
80100ff2:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100ff8:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100ffb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ffe:	8b 40 18             	mov    0x18(%eax),%eax
80101001:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101004:	89 50 44             	mov    %edx,0x44(%eax)

    
  switchuvm(curproc);
80101007:	83 ec 0c             	sub    $0xc,%esp
8010100a:	ff 75 d0             	pushl  -0x30(%ebp)
8010100d:	e8 bc 76 00 00       	call   801086ce <switchuvm>
80101012:	83 c4 10             	add    $0x10,%esp
    // // if(curproc->clock_queue[i].va!=0){
    // // mencrypt(curproc->clock_queue[i].va,1);
    // // }
    // // curproc->clock_queue[i].va=0;
    // }
    curproc->queue_size=0;
80101015:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101018:	c7 80 bc 00 00 00 00 	movl   $0x0,0xbc(%eax)
8010101f:	00 00 00 
    curproc->hand=0;
80101022:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101025:	c7 80 c4 00 00 00 00 	movl   $0x0,0xc4(%eax)
8010102c:	00 00 00 
  // }
  // curproc->queue_size = 0;
  // curproc->hand = 0;
  // for (int i=PGROUNDDOWN(curproc->sz);i>=0;i-=PGSIZE){
  // mencrypt((char*)i,1)
  mencrypt(0, sz/PGSIZE - 2);
8010102f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101032:	c1 e8 0c             	shr    $0xc,%eax
80101035:	83 e8 02             	sub    $0x2,%eax
80101038:	83 ec 08             	sub    $0x8,%esp
8010103b:	50                   	push   %eax
8010103c:	6a 00                	push   $0x0
8010103e:	e8 16 7f 00 00       	call   80108f59 <mencrypt>
80101043:	83 c4 10             	add    $0x10,%esp
  mencrypt((char*) sz - PGSIZE, 1);//(void*)PGROUNDDOWN((int)sz - change), change/PGSIZE);
80101046:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101049:	2d 00 10 00 00       	sub    $0x1000,%eax
8010104e:	83 ec 08             	sub    $0x8,%esp
80101051:	6a 01                	push   $0x1
80101053:	50                   	push   %eax
80101054:	e8 00 7f 00 00       	call   80108f59 <mencrypt>
80101059:	83 c4 10             	add    $0x10,%esp
 // cprintf("%d\n", sz);
  // }
 // cprintf("%d\n", change);

  freevm(oldpgdir);
8010105c:	83 ec 0c             	sub    $0xc,%esp
8010105f:	ff 75 cc             	pushl  -0x34(%ebp)
80101062:	e8 35 7b 00 00       	call   80108b9c <freevm>
80101067:	83 c4 10             	add    $0x10,%esp
  //for (void * i = (void*) PGROUNDDOWN(((int)curproc->sz)); i >= 0; i-=PGSIZE) {
  //  if(mencrypt(i, 1) != 0)
  //    break;
  //}

  return 0;
8010106a:	b8 00 00 00 00       	mov    $0x0,%eax
8010106f:	eb 57                	jmp    801010c8 <exec+0x498>
    goto bad;
80101071:	90                   	nop
80101072:	eb 22                	jmp    80101096 <exec+0x466>
    goto bad;
80101074:	90                   	nop
80101075:	eb 1f                	jmp    80101096 <exec+0x466>
    goto bad;
80101077:	90                   	nop
80101078:	eb 1c                	jmp    80101096 <exec+0x466>
      goto bad;
8010107a:	90                   	nop
8010107b:	eb 19                	jmp    80101096 <exec+0x466>
      goto bad;
8010107d:	90                   	nop
8010107e:	eb 16                	jmp    80101096 <exec+0x466>
      goto bad;
80101080:	90                   	nop
80101081:	eb 13                	jmp    80101096 <exec+0x466>
      goto bad;
80101083:	90                   	nop
80101084:	eb 10                	jmp    80101096 <exec+0x466>
      goto bad;
80101086:	90                   	nop
80101087:	eb 0d                	jmp    80101096 <exec+0x466>
      goto bad;
80101089:	90                   	nop
8010108a:	eb 0a                	jmp    80101096 <exec+0x466>
    goto bad;
8010108c:	90                   	nop
8010108d:	eb 07                	jmp    80101096 <exec+0x466>
      goto bad;
8010108f:	90                   	nop
80101090:	eb 04                	jmp    80101096 <exec+0x466>
      goto bad;
80101092:	90                   	nop
80101093:	eb 01                	jmp    80101096 <exec+0x466>
    goto bad;
80101095:	90                   	nop

 bad:
  if(pgdir)
80101096:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010109a:	74 0e                	je     801010aa <exec+0x47a>
    freevm(pgdir);
8010109c:	83 ec 0c             	sub    $0xc,%esp
8010109f:	ff 75 d4             	pushl  -0x2c(%ebp)
801010a2:	e8 f5 7a 00 00       	call   80108b9c <freevm>
801010a7:	83 c4 10             	add    $0x10,%esp
  if(ip){
801010aa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801010ae:	74 13                	je     801010c3 <exec+0x493>
    iunlockput(ip);
801010b0:	83 ec 0c             	sub    $0xc,%esp
801010b3:	ff 75 d8             	pushl  -0x28(%ebp)
801010b6:	e8 b4 0c 00 00       	call   80101d6f <iunlockput>
801010bb:	83 c4 10             	add    $0x10,%esp
    end_op();
801010be:	e8 ce 26 00 00       	call   80103791 <end_op>
  }
  return -1;
801010c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010c8:	c9                   	leave  
801010c9:	c3                   	ret    

801010ca <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010ca:	f3 0f 1e fb          	endbr32 
801010ce:	55                   	push   %ebp
801010cf:	89 e5                	mov    %esp,%ebp
801010d1:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801010d4:	83 ec 08             	sub    $0x8,%esp
801010d7:	68 0d 94 10 80       	push   $0x8010940d
801010dc:	68 60 20 11 80       	push   $0x80112060
801010e1:	e8 cd 41 00 00       	call   801052b3 <initlock>
801010e6:	83 c4 10             	add    $0x10,%esp
}
801010e9:	90                   	nop
801010ea:	c9                   	leave  
801010eb:	c3                   	ret    

801010ec <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010ec:	f3 0f 1e fb          	endbr32 
801010f0:	55                   	push   %ebp
801010f1:	89 e5                	mov    %esp,%ebp
801010f3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
801010f6:	83 ec 0c             	sub    $0xc,%esp
801010f9:	68 60 20 11 80       	push   $0x80112060
801010fe:	e8 d6 41 00 00       	call   801052d9 <acquire>
80101103:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101106:	c7 45 f4 94 20 11 80 	movl   $0x80112094,-0xc(%ebp)
8010110d:	eb 2d                	jmp    8010113c <filealloc+0x50>
    if(f->ref == 0){
8010110f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101112:	8b 40 04             	mov    0x4(%eax),%eax
80101115:	85 c0                	test   %eax,%eax
80101117:	75 1f                	jne    80101138 <filealloc+0x4c>
      f->ref = 1;
80101119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010111c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101123:	83 ec 0c             	sub    $0xc,%esp
80101126:	68 60 20 11 80       	push   $0x80112060
8010112b:	e8 1b 42 00 00       	call   8010534b <release>
80101130:	83 c4 10             	add    $0x10,%esp
      return f;
80101133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101136:	eb 23                	jmp    8010115b <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101138:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010113c:	b8 f4 29 11 80       	mov    $0x801129f4,%eax
80101141:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101144:	72 c9                	jb     8010110f <filealloc+0x23>
    }
  }
  release(&ftable.lock);
80101146:	83 ec 0c             	sub    $0xc,%esp
80101149:	68 60 20 11 80       	push   $0x80112060
8010114e:	e8 f8 41 00 00       	call   8010534b <release>
80101153:	83 c4 10             	add    $0x10,%esp
  return 0;
80101156:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010115b:	c9                   	leave  
8010115c:	c3                   	ret    

8010115d <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010115d:	f3 0f 1e fb          	endbr32 
80101161:	55                   	push   %ebp
80101162:	89 e5                	mov    %esp,%ebp
80101164:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101167:	83 ec 0c             	sub    $0xc,%esp
8010116a:	68 60 20 11 80       	push   $0x80112060
8010116f:	e8 65 41 00 00       	call   801052d9 <acquire>
80101174:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101177:	8b 45 08             	mov    0x8(%ebp),%eax
8010117a:	8b 40 04             	mov    0x4(%eax),%eax
8010117d:	85 c0                	test   %eax,%eax
8010117f:	7f 0d                	jg     8010118e <filedup+0x31>
    panic("filedup");
80101181:	83 ec 0c             	sub    $0xc,%esp
80101184:	68 14 94 10 80       	push   $0x80109414
80101189:	e8 7a f4 ff ff       	call   80100608 <panic>
  f->ref++;
8010118e:	8b 45 08             	mov    0x8(%ebp),%eax
80101191:	8b 40 04             	mov    0x4(%eax),%eax
80101194:	8d 50 01             	lea    0x1(%eax),%edx
80101197:	8b 45 08             	mov    0x8(%ebp),%eax
8010119a:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010119d:	83 ec 0c             	sub    $0xc,%esp
801011a0:	68 60 20 11 80       	push   $0x80112060
801011a5:	e8 a1 41 00 00       	call   8010534b <release>
801011aa:	83 c4 10             	add    $0x10,%esp
  return f;
801011ad:	8b 45 08             	mov    0x8(%ebp),%eax
}
801011b0:	c9                   	leave  
801011b1:	c3                   	ret    

801011b2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011b2:	f3 0f 1e fb          	endbr32 
801011b6:	55                   	push   %ebp
801011b7:	89 e5                	mov    %esp,%ebp
801011b9:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801011bc:	83 ec 0c             	sub    $0xc,%esp
801011bf:	68 60 20 11 80       	push   $0x80112060
801011c4:	e8 10 41 00 00       	call   801052d9 <acquire>
801011c9:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011cc:	8b 45 08             	mov    0x8(%ebp),%eax
801011cf:	8b 40 04             	mov    0x4(%eax),%eax
801011d2:	85 c0                	test   %eax,%eax
801011d4:	7f 0d                	jg     801011e3 <fileclose+0x31>
    panic("fileclose");
801011d6:	83 ec 0c             	sub    $0xc,%esp
801011d9:	68 1c 94 10 80       	push   $0x8010941c
801011de:	e8 25 f4 ff ff       	call   80100608 <panic>
  if(--f->ref > 0){
801011e3:	8b 45 08             	mov    0x8(%ebp),%eax
801011e6:	8b 40 04             	mov    0x4(%eax),%eax
801011e9:	8d 50 ff             	lea    -0x1(%eax),%edx
801011ec:	8b 45 08             	mov    0x8(%ebp),%eax
801011ef:	89 50 04             	mov    %edx,0x4(%eax)
801011f2:	8b 45 08             	mov    0x8(%ebp),%eax
801011f5:	8b 40 04             	mov    0x4(%eax),%eax
801011f8:	85 c0                	test   %eax,%eax
801011fa:	7e 15                	jle    80101211 <fileclose+0x5f>
    release(&ftable.lock);
801011fc:	83 ec 0c             	sub    $0xc,%esp
801011ff:	68 60 20 11 80       	push   $0x80112060
80101204:	e8 42 41 00 00       	call   8010534b <release>
80101209:	83 c4 10             	add    $0x10,%esp
8010120c:	e9 8b 00 00 00       	jmp    8010129c <fileclose+0xea>
    return;
  }
  ff = *f;
80101211:	8b 45 08             	mov    0x8(%ebp),%eax
80101214:	8b 10                	mov    (%eax),%edx
80101216:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101219:	8b 50 04             	mov    0x4(%eax),%edx
8010121c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010121f:	8b 50 08             	mov    0x8(%eax),%edx
80101222:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101225:	8b 50 0c             	mov    0xc(%eax),%edx
80101228:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010122b:	8b 50 10             	mov    0x10(%eax),%edx
8010122e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101231:	8b 40 14             	mov    0x14(%eax),%eax
80101234:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101237:	8b 45 08             	mov    0x8(%ebp),%eax
8010123a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101241:	8b 45 08             	mov    0x8(%ebp),%eax
80101244:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010124a:	83 ec 0c             	sub    $0xc,%esp
8010124d:	68 60 20 11 80       	push   $0x80112060
80101252:	e8 f4 40 00 00       	call   8010534b <release>
80101257:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010125a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010125d:	83 f8 01             	cmp    $0x1,%eax
80101260:	75 19                	jne    8010127b <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101262:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101266:	0f be d0             	movsbl %al,%edx
80101269:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010126c:	83 ec 08             	sub    $0x8,%esp
8010126f:	52                   	push   %edx
80101270:	50                   	push   %eax
80101271:	e8 c1 2e 00 00       	call   80104137 <pipeclose>
80101276:	83 c4 10             	add    $0x10,%esp
80101279:	eb 21                	jmp    8010129c <fileclose+0xea>
  else if(ff.type == FD_INODE){
8010127b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010127e:	83 f8 02             	cmp    $0x2,%eax
80101281:	75 19                	jne    8010129c <fileclose+0xea>
    begin_op();
80101283:	e8 79 24 00 00       	call   80103701 <begin_op>
    iput(ff.ip);
80101288:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010128b:	83 ec 0c             	sub    $0xc,%esp
8010128e:	50                   	push   %eax
8010128f:	e8 07 0a 00 00       	call   80101c9b <iput>
80101294:	83 c4 10             	add    $0x10,%esp
    end_op();
80101297:	e8 f5 24 00 00       	call   80103791 <end_op>
  }
}
8010129c:	c9                   	leave  
8010129d:	c3                   	ret    

8010129e <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010129e:	f3 0f 1e fb          	endbr32 
801012a2:	55                   	push   %ebp
801012a3:	89 e5                	mov    %esp,%ebp
801012a5:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801012a8:	8b 45 08             	mov    0x8(%ebp),%eax
801012ab:	8b 00                	mov    (%eax),%eax
801012ad:	83 f8 02             	cmp    $0x2,%eax
801012b0:	75 40                	jne    801012f2 <filestat+0x54>
    ilock(f->ip);
801012b2:	8b 45 08             	mov    0x8(%ebp),%eax
801012b5:	8b 40 10             	mov    0x10(%eax),%eax
801012b8:	83 ec 0c             	sub    $0xc,%esp
801012bb:	50                   	push   %eax
801012bc:	e8 71 08 00 00       	call   80101b32 <ilock>
801012c1:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801012c4:	8b 45 08             	mov    0x8(%ebp),%eax
801012c7:	8b 40 10             	mov    0x10(%eax),%eax
801012ca:	83 ec 08             	sub    $0x8,%esp
801012cd:	ff 75 0c             	pushl  0xc(%ebp)
801012d0:	50                   	push   %eax
801012d1:	e8 1a 0d 00 00       	call   80101ff0 <stati>
801012d6:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801012d9:	8b 45 08             	mov    0x8(%ebp),%eax
801012dc:	8b 40 10             	mov    0x10(%eax),%eax
801012df:	83 ec 0c             	sub    $0xc,%esp
801012e2:	50                   	push   %eax
801012e3:	e8 61 09 00 00       	call   80101c49 <iunlock>
801012e8:	83 c4 10             	add    $0x10,%esp
    return 0;
801012eb:	b8 00 00 00 00       	mov    $0x0,%eax
801012f0:	eb 05                	jmp    801012f7 <filestat+0x59>
  }
  return -1;
801012f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012f7:	c9                   	leave  
801012f8:	c3                   	ret    

801012f9 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012f9:	f3 0f 1e fb          	endbr32 
801012fd:	55                   	push   %ebp
801012fe:	89 e5                	mov    %esp,%ebp
80101300:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101303:	8b 45 08             	mov    0x8(%ebp),%eax
80101306:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010130a:	84 c0                	test   %al,%al
8010130c:	75 0a                	jne    80101318 <fileread+0x1f>
    return -1;
8010130e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101313:	e9 9b 00 00 00       	jmp    801013b3 <fileread+0xba>
  if(f->type == FD_PIPE)
80101318:	8b 45 08             	mov    0x8(%ebp),%eax
8010131b:	8b 00                	mov    (%eax),%eax
8010131d:	83 f8 01             	cmp    $0x1,%eax
80101320:	75 1a                	jne    8010133c <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101322:	8b 45 08             	mov    0x8(%ebp),%eax
80101325:	8b 40 0c             	mov    0xc(%eax),%eax
80101328:	83 ec 04             	sub    $0x4,%esp
8010132b:	ff 75 10             	pushl  0x10(%ebp)
8010132e:	ff 75 0c             	pushl  0xc(%ebp)
80101331:	50                   	push   %eax
80101332:	e8 b5 2f 00 00       	call   801042ec <piperead>
80101337:	83 c4 10             	add    $0x10,%esp
8010133a:	eb 77                	jmp    801013b3 <fileread+0xba>
  if(f->type == FD_INODE){
8010133c:	8b 45 08             	mov    0x8(%ebp),%eax
8010133f:	8b 00                	mov    (%eax),%eax
80101341:	83 f8 02             	cmp    $0x2,%eax
80101344:	75 60                	jne    801013a6 <fileread+0xad>
    ilock(f->ip);
80101346:	8b 45 08             	mov    0x8(%ebp),%eax
80101349:	8b 40 10             	mov    0x10(%eax),%eax
8010134c:	83 ec 0c             	sub    $0xc,%esp
8010134f:	50                   	push   %eax
80101350:	e8 dd 07 00 00       	call   80101b32 <ilock>
80101355:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101358:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	8b 50 14             	mov    0x14(%eax),%edx
80101361:	8b 45 08             	mov    0x8(%ebp),%eax
80101364:	8b 40 10             	mov    0x10(%eax),%eax
80101367:	51                   	push   %ecx
80101368:	52                   	push   %edx
80101369:	ff 75 0c             	pushl  0xc(%ebp)
8010136c:	50                   	push   %eax
8010136d:	e8 c8 0c 00 00       	call   8010203a <readi>
80101372:	83 c4 10             	add    $0x10,%esp
80101375:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101378:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010137c:	7e 11                	jle    8010138f <fileread+0x96>
      f->off += r;
8010137e:	8b 45 08             	mov    0x8(%ebp),%eax
80101381:	8b 50 14             	mov    0x14(%eax),%edx
80101384:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101387:	01 c2                	add    %eax,%edx
80101389:	8b 45 08             	mov    0x8(%ebp),%eax
8010138c:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010138f:	8b 45 08             	mov    0x8(%ebp),%eax
80101392:	8b 40 10             	mov    0x10(%eax),%eax
80101395:	83 ec 0c             	sub    $0xc,%esp
80101398:	50                   	push   %eax
80101399:	e8 ab 08 00 00       	call   80101c49 <iunlock>
8010139e:	83 c4 10             	add    $0x10,%esp
    return r;
801013a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a4:	eb 0d                	jmp    801013b3 <fileread+0xba>
  }
  panic("fileread");
801013a6:	83 ec 0c             	sub    $0xc,%esp
801013a9:	68 26 94 10 80       	push   $0x80109426
801013ae:	e8 55 f2 ff ff       	call   80100608 <panic>
}
801013b3:	c9                   	leave  
801013b4:	c3                   	ret    

801013b5 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801013b5:	f3 0f 1e fb          	endbr32 
801013b9:	55                   	push   %ebp
801013ba:	89 e5                	mov    %esp,%ebp
801013bc:	53                   	push   %ebx
801013bd:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801013c0:	8b 45 08             	mov    0x8(%ebp),%eax
801013c3:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801013c7:	84 c0                	test   %al,%al
801013c9:	75 0a                	jne    801013d5 <filewrite+0x20>
    return -1;
801013cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013d0:	e9 1b 01 00 00       	jmp    801014f0 <filewrite+0x13b>
  if(f->type == FD_PIPE)
801013d5:	8b 45 08             	mov    0x8(%ebp),%eax
801013d8:	8b 00                	mov    (%eax),%eax
801013da:	83 f8 01             	cmp    $0x1,%eax
801013dd:	75 1d                	jne    801013fc <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801013df:	8b 45 08             	mov    0x8(%ebp),%eax
801013e2:	8b 40 0c             	mov    0xc(%eax),%eax
801013e5:	83 ec 04             	sub    $0x4,%esp
801013e8:	ff 75 10             	pushl  0x10(%ebp)
801013eb:	ff 75 0c             	pushl  0xc(%ebp)
801013ee:	50                   	push   %eax
801013ef:	e8 f2 2d 00 00       	call   801041e6 <pipewrite>
801013f4:	83 c4 10             	add    $0x10,%esp
801013f7:	e9 f4 00 00 00       	jmp    801014f0 <filewrite+0x13b>
  if(f->type == FD_INODE){
801013fc:	8b 45 08             	mov    0x8(%ebp),%eax
801013ff:	8b 00                	mov    (%eax),%eax
80101401:	83 f8 02             	cmp    $0x2,%eax
80101404:	0f 85 d9 00 00 00    	jne    801014e3 <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
8010140a:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101411:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101418:	e9 a3 00 00 00       	jmp    801014c0 <filewrite+0x10b>
      int n1 = n - i;
8010141d:	8b 45 10             	mov    0x10(%ebp),%eax
80101420:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101423:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101426:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101429:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010142c:	7e 06                	jle    80101434 <filewrite+0x7f>
        n1 = max;
8010142e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101431:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101434:	e8 c8 22 00 00       	call   80103701 <begin_op>
      ilock(f->ip);
80101439:	8b 45 08             	mov    0x8(%ebp),%eax
8010143c:	8b 40 10             	mov    0x10(%eax),%eax
8010143f:	83 ec 0c             	sub    $0xc,%esp
80101442:	50                   	push   %eax
80101443:	e8 ea 06 00 00       	call   80101b32 <ilock>
80101448:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010144b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010144e:	8b 45 08             	mov    0x8(%ebp),%eax
80101451:	8b 50 14             	mov    0x14(%eax),%edx
80101454:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101457:	8b 45 0c             	mov    0xc(%ebp),%eax
8010145a:	01 c3                	add    %eax,%ebx
8010145c:	8b 45 08             	mov    0x8(%ebp),%eax
8010145f:	8b 40 10             	mov    0x10(%eax),%eax
80101462:	51                   	push   %ecx
80101463:	52                   	push   %edx
80101464:	53                   	push   %ebx
80101465:	50                   	push   %eax
80101466:	e8 28 0d 00 00       	call   80102193 <writei>
8010146b:	83 c4 10             	add    $0x10,%esp
8010146e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101471:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101475:	7e 11                	jle    80101488 <filewrite+0xd3>
        f->off += r;
80101477:	8b 45 08             	mov    0x8(%ebp),%eax
8010147a:	8b 50 14             	mov    0x14(%eax),%edx
8010147d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101480:	01 c2                	add    %eax,%edx
80101482:	8b 45 08             	mov    0x8(%ebp),%eax
80101485:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101488:	8b 45 08             	mov    0x8(%ebp),%eax
8010148b:	8b 40 10             	mov    0x10(%eax),%eax
8010148e:	83 ec 0c             	sub    $0xc,%esp
80101491:	50                   	push   %eax
80101492:	e8 b2 07 00 00       	call   80101c49 <iunlock>
80101497:	83 c4 10             	add    $0x10,%esp
      end_op();
8010149a:	e8 f2 22 00 00       	call   80103791 <end_op>

      if(r < 0)
8010149f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801014a3:	78 29                	js     801014ce <filewrite+0x119>
        break;
      if(r != n1)
801014a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014a8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801014ab:	74 0d                	je     801014ba <filewrite+0x105>
        panic("short filewrite");
801014ad:	83 ec 0c             	sub    $0xc,%esp
801014b0:	68 2f 94 10 80       	push   $0x8010942f
801014b5:	e8 4e f1 ff ff       	call   80100608 <panic>
      i += r;
801014ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014bd:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801014c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014c3:	3b 45 10             	cmp    0x10(%ebp),%eax
801014c6:	0f 8c 51 ff ff ff    	jl     8010141d <filewrite+0x68>
801014cc:	eb 01                	jmp    801014cf <filewrite+0x11a>
        break;
801014ce:	90                   	nop
    }
    return i == n ? n : -1;
801014cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d2:	3b 45 10             	cmp    0x10(%ebp),%eax
801014d5:	75 05                	jne    801014dc <filewrite+0x127>
801014d7:	8b 45 10             	mov    0x10(%ebp),%eax
801014da:	eb 14                	jmp    801014f0 <filewrite+0x13b>
801014dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014e1:	eb 0d                	jmp    801014f0 <filewrite+0x13b>
  }
  panic("filewrite");
801014e3:	83 ec 0c             	sub    $0xc,%esp
801014e6:	68 3f 94 10 80       	push   $0x8010943f
801014eb:	e8 18 f1 ff ff       	call   80100608 <panic>
}
801014f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801014f3:	c9                   	leave  
801014f4:	c3                   	ret    

801014f5 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014f5:	f3 0f 1e fb          	endbr32 
801014f9:	55                   	push   %ebp
801014fa:	89 e5                	mov    %esp,%ebp
801014fc:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101502:	83 ec 08             	sub    $0x8,%esp
80101505:	6a 01                	push   $0x1
80101507:	50                   	push   %eax
80101508:	e8 ca ec ff ff       	call   801001d7 <bread>
8010150d:	83 c4 10             	add    $0x10,%esp
80101510:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101516:	83 c0 5c             	add    $0x5c,%eax
80101519:	83 ec 04             	sub    $0x4,%esp
8010151c:	6a 1c                	push   $0x1c
8010151e:	50                   	push   %eax
8010151f:	ff 75 0c             	pushl  0xc(%ebp)
80101522:	e8 18 41 00 00       	call   8010563f <memmove>
80101527:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010152a:	83 ec 0c             	sub    $0xc,%esp
8010152d:	ff 75 f4             	pushl  -0xc(%ebp)
80101530:	e8 2c ed ff ff       	call   80100261 <brelse>
80101535:	83 c4 10             	add    $0x10,%esp
}
80101538:	90                   	nop
80101539:	c9                   	leave  
8010153a:	c3                   	ret    

8010153b <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010153b:	f3 0f 1e fb          	endbr32 
8010153f:	55                   	push   %ebp
80101540:	89 e5                	mov    %esp,%ebp
80101542:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101545:	8b 55 0c             	mov    0xc(%ebp),%edx
80101548:	8b 45 08             	mov    0x8(%ebp),%eax
8010154b:	83 ec 08             	sub    $0x8,%esp
8010154e:	52                   	push   %edx
8010154f:	50                   	push   %eax
80101550:	e8 82 ec ff ff       	call   801001d7 <bread>
80101555:	83 c4 10             	add    $0x10,%esp
80101558:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010155b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010155e:	83 c0 5c             	add    $0x5c,%eax
80101561:	83 ec 04             	sub    $0x4,%esp
80101564:	68 00 02 00 00       	push   $0x200
80101569:	6a 00                	push   $0x0
8010156b:	50                   	push   %eax
8010156c:	e8 07 40 00 00       	call   80105578 <memset>
80101571:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101574:	83 ec 0c             	sub    $0xc,%esp
80101577:	ff 75 f4             	pushl  -0xc(%ebp)
8010157a:	e8 cb 23 00 00       	call   8010394a <log_write>
8010157f:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101582:	83 ec 0c             	sub    $0xc,%esp
80101585:	ff 75 f4             	pushl  -0xc(%ebp)
80101588:	e8 d4 ec ff ff       	call   80100261 <brelse>
8010158d:	83 c4 10             	add    $0x10,%esp
}
80101590:	90                   	nop
80101591:	c9                   	leave  
80101592:	c3                   	ret    

80101593 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101593:	f3 0f 1e fb          	endbr32 
80101597:	55                   	push   %ebp
80101598:	89 e5                	mov    %esp,%ebp
8010159a:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010159d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801015a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801015ab:	e9 13 01 00 00       	jmp    801016c3 <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801015b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015b3:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801015b9:	85 c0                	test   %eax,%eax
801015bb:	0f 48 c2             	cmovs  %edx,%eax
801015be:	c1 f8 0c             	sar    $0xc,%eax
801015c1:	89 c2                	mov    %eax,%edx
801015c3:	a1 78 2a 11 80       	mov    0x80112a78,%eax
801015c8:	01 d0                	add    %edx,%eax
801015ca:	83 ec 08             	sub    $0x8,%esp
801015cd:	50                   	push   %eax
801015ce:	ff 75 08             	pushl  0x8(%ebp)
801015d1:	e8 01 ec ff ff       	call   801001d7 <bread>
801015d6:	83 c4 10             	add    $0x10,%esp
801015d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015dc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015e3:	e9 a6 00 00 00       	jmp    8010168e <balloc+0xfb>
      m = 1 << (bi % 8);
801015e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015eb:	99                   	cltd   
801015ec:	c1 ea 1d             	shr    $0x1d,%edx
801015ef:	01 d0                	add    %edx,%eax
801015f1:	83 e0 07             	and    $0x7,%eax
801015f4:	29 d0                	sub    %edx,%eax
801015f6:	ba 01 00 00 00       	mov    $0x1,%edx
801015fb:	89 c1                	mov    %eax,%ecx
801015fd:	d3 e2                	shl    %cl,%edx
801015ff:	89 d0                	mov    %edx,%eax
80101601:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101604:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101607:	8d 50 07             	lea    0x7(%eax),%edx
8010160a:	85 c0                	test   %eax,%eax
8010160c:	0f 48 c2             	cmovs  %edx,%eax
8010160f:	c1 f8 03             	sar    $0x3,%eax
80101612:	89 c2                	mov    %eax,%edx
80101614:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101617:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010161c:	0f b6 c0             	movzbl %al,%eax
8010161f:	23 45 e8             	and    -0x18(%ebp),%eax
80101622:	85 c0                	test   %eax,%eax
80101624:	75 64                	jne    8010168a <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
80101626:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101629:	8d 50 07             	lea    0x7(%eax),%edx
8010162c:	85 c0                	test   %eax,%eax
8010162e:	0f 48 c2             	cmovs  %edx,%eax
80101631:	c1 f8 03             	sar    $0x3,%eax
80101634:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101637:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010163c:	89 d1                	mov    %edx,%ecx
8010163e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101641:	09 ca                	or     %ecx,%edx
80101643:	89 d1                	mov    %edx,%ecx
80101645:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101648:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010164c:	83 ec 0c             	sub    $0xc,%esp
8010164f:	ff 75 ec             	pushl  -0x14(%ebp)
80101652:	e8 f3 22 00 00       	call   8010394a <log_write>
80101657:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010165a:	83 ec 0c             	sub    $0xc,%esp
8010165d:	ff 75 ec             	pushl  -0x14(%ebp)
80101660:	e8 fc eb ff ff       	call   80100261 <brelse>
80101665:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101668:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010166b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010166e:	01 c2                	add    %eax,%edx
80101670:	8b 45 08             	mov    0x8(%ebp),%eax
80101673:	83 ec 08             	sub    $0x8,%esp
80101676:	52                   	push   %edx
80101677:	50                   	push   %eax
80101678:	e8 be fe ff ff       	call   8010153b <bzero>
8010167d:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101680:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101683:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101686:	01 d0                	add    %edx,%eax
80101688:	eb 57                	jmp    801016e1 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010168a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010168e:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101695:	7f 17                	jg     801016ae <balloc+0x11b>
80101697:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010169a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010169d:	01 d0                	add    %edx,%eax
8010169f:	89 c2                	mov    %eax,%edx
801016a1:	a1 60 2a 11 80       	mov    0x80112a60,%eax
801016a6:	39 c2                	cmp    %eax,%edx
801016a8:	0f 82 3a ff ff ff    	jb     801015e8 <balloc+0x55>
      }
    }
    brelse(bp);
801016ae:	83 ec 0c             	sub    $0xc,%esp
801016b1:	ff 75 ec             	pushl  -0x14(%ebp)
801016b4:	e8 a8 eb ff ff       	call   80100261 <brelse>
801016b9:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801016bc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801016c3:	8b 15 60 2a 11 80    	mov    0x80112a60,%edx
801016c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016cc:	39 c2                	cmp    %eax,%edx
801016ce:	0f 87 dc fe ff ff    	ja     801015b0 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
801016d4:	83 ec 0c             	sub    $0xc,%esp
801016d7:	68 4c 94 10 80       	push   $0x8010944c
801016dc:	e8 27 ef ff ff       	call   80100608 <panic>
}
801016e1:	c9                   	leave  
801016e2:	c3                   	ret    

801016e3 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801016e3:	f3 0f 1e fb          	endbr32 
801016e7:	55                   	push   %ebp
801016e8:	89 e5                	mov    %esp,%ebp
801016ea:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801016ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801016f0:	c1 e8 0c             	shr    $0xc,%eax
801016f3:	89 c2                	mov    %eax,%edx
801016f5:	a1 78 2a 11 80       	mov    0x80112a78,%eax
801016fa:	01 c2                	add    %eax,%edx
801016fc:	8b 45 08             	mov    0x8(%ebp),%eax
801016ff:	83 ec 08             	sub    $0x8,%esp
80101702:	52                   	push   %edx
80101703:	50                   	push   %eax
80101704:	e8 ce ea ff ff       	call   801001d7 <bread>
80101709:	83 c4 10             	add    $0x10,%esp
8010170c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010170f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101712:	25 ff 0f 00 00       	and    $0xfff,%eax
80101717:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010171a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171d:	99                   	cltd   
8010171e:	c1 ea 1d             	shr    $0x1d,%edx
80101721:	01 d0                	add    %edx,%eax
80101723:	83 e0 07             	and    $0x7,%eax
80101726:	29 d0                	sub    %edx,%eax
80101728:	ba 01 00 00 00       	mov    $0x1,%edx
8010172d:	89 c1                	mov    %eax,%ecx
8010172f:	d3 e2                	shl    %cl,%edx
80101731:	89 d0                	mov    %edx,%eax
80101733:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101736:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101739:	8d 50 07             	lea    0x7(%eax),%edx
8010173c:	85 c0                	test   %eax,%eax
8010173e:	0f 48 c2             	cmovs  %edx,%eax
80101741:	c1 f8 03             	sar    $0x3,%eax
80101744:	89 c2                	mov    %eax,%edx
80101746:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101749:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010174e:	0f b6 c0             	movzbl %al,%eax
80101751:	23 45 ec             	and    -0x14(%ebp),%eax
80101754:	85 c0                	test   %eax,%eax
80101756:	75 0d                	jne    80101765 <bfree+0x82>
    panic("freeing free block");
80101758:	83 ec 0c             	sub    $0xc,%esp
8010175b:	68 62 94 10 80       	push   $0x80109462
80101760:	e8 a3 ee ff ff       	call   80100608 <panic>
  bp->data[bi/8] &= ~m;
80101765:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101768:	8d 50 07             	lea    0x7(%eax),%edx
8010176b:	85 c0                	test   %eax,%eax
8010176d:	0f 48 c2             	cmovs  %edx,%eax
80101770:	c1 f8 03             	sar    $0x3,%eax
80101773:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101776:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010177b:	89 d1                	mov    %edx,%ecx
8010177d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101780:	f7 d2                	not    %edx
80101782:	21 ca                	and    %ecx,%edx
80101784:	89 d1                	mov    %edx,%ecx
80101786:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101789:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010178d:	83 ec 0c             	sub    $0xc,%esp
80101790:	ff 75 f4             	pushl  -0xc(%ebp)
80101793:	e8 b2 21 00 00       	call   8010394a <log_write>
80101798:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010179b:	83 ec 0c             	sub    $0xc,%esp
8010179e:	ff 75 f4             	pushl  -0xc(%ebp)
801017a1:	e8 bb ea ff ff       	call   80100261 <brelse>
801017a6:	83 c4 10             	add    $0x10,%esp
}
801017a9:	90                   	nop
801017aa:	c9                   	leave  
801017ab:	c3                   	ret    

801017ac <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801017ac:	f3 0f 1e fb          	endbr32 
801017b0:	55                   	push   %ebp
801017b1:	89 e5                	mov    %esp,%ebp
801017b3:	57                   	push   %edi
801017b4:	56                   	push   %esi
801017b5:	53                   	push   %ebx
801017b6:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801017b9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801017c0:	83 ec 08             	sub    $0x8,%esp
801017c3:	68 75 94 10 80       	push   $0x80109475
801017c8:	68 80 2a 11 80       	push   $0x80112a80
801017cd:	e8 e1 3a 00 00       	call   801052b3 <initlock>
801017d2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017d5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801017dc:	eb 2d                	jmp    8010180b <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
801017de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801017e1:	89 d0                	mov    %edx,%eax
801017e3:	c1 e0 03             	shl    $0x3,%eax
801017e6:	01 d0                	add    %edx,%eax
801017e8:	c1 e0 04             	shl    $0x4,%eax
801017eb:	83 c0 30             	add    $0x30,%eax
801017ee:	05 80 2a 11 80       	add    $0x80112a80,%eax
801017f3:	83 c0 10             	add    $0x10,%eax
801017f6:	83 ec 08             	sub    $0x8,%esp
801017f9:	68 7c 94 10 80       	push   $0x8010947c
801017fe:	50                   	push   %eax
801017ff:	e8 1c 39 00 00       	call   80105120 <initsleeplock>
80101804:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101807:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010180b:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
8010180f:	7e cd                	jle    801017de <iinit+0x32>
  }

  readsb(dev, &sb);
80101811:	83 ec 08             	sub    $0x8,%esp
80101814:	68 60 2a 11 80       	push   $0x80112a60
80101819:	ff 75 08             	pushl  0x8(%ebp)
8010181c:	e8 d4 fc ff ff       	call   801014f5 <readsb>
80101821:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101824:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101829:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010182c:	8b 3d 74 2a 11 80    	mov    0x80112a74,%edi
80101832:	8b 35 70 2a 11 80    	mov    0x80112a70,%esi
80101838:	8b 1d 6c 2a 11 80    	mov    0x80112a6c,%ebx
8010183e:	8b 0d 68 2a 11 80    	mov    0x80112a68,%ecx
80101844:	8b 15 64 2a 11 80    	mov    0x80112a64,%edx
8010184a:	a1 60 2a 11 80       	mov    0x80112a60,%eax
8010184f:	ff 75 d4             	pushl  -0x2c(%ebp)
80101852:	57                   	push   %edi
80101853:	56                   	push   %esi
80101854:	53                   	push   %ebx
80101855:	51                   	push   %ecx
80101856:	52                   	push   %edx
80101857:	50                   	push   %eax
80101858:	68 84 94 10 80       	push   $0x80109484
8010185d:	e8 b6 eb ff ff       	call   80100418 <cprintf>
80101862:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101865:	90                   	nop
80101866:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101869:	5b                   	pop    %ebx
8010186a:	5e                   	pop    %esi
8010186b:	5f                   	pop    %edi
8010186c:	5d                   	pop    %ebp
8010186d:	c3                   	ret    

8010186e <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010186e:	f3 0f 1e fb          	endbr32 
80101872:	55                   	push   %ebp
80101873:	89 e5                	mov    %esp,%ebp
80101875:	83 ec 28             	sub    $0x28,%esp
80101878:	8b 45 0c             	mov    0xc(%ebp),%eax
8010187b:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010187f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101886:	e9 9e 00 00 00       	jmp    80101929 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
8010188b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188e:	c1 e8 03             	shr    $0x3,%eax
80101891:	89 c2                	mov    %eax,%edx
80101893:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101898:	01 d0                	add    %edx,%eax
8010189a:	83 ec 08             	sub    $0x8,%esp
8010189d:	50                   	push   %eax
8010189e:	ff 75 08             	pushl  0x8(%ebp)
801018a1:	e8 31 e9 ff ff       	call   801001d7 <bread>
801018a6:	83 c4 10             	add    $0x10,%esp
801018a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801018ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018af:	8d 50 5c             	lea    0x5c(%eax),%edx
801018b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b5:	83 e0 07             	and    $0x7,%eax
801018b8:	c1 e0 06             	shl    $0x6,%eax
801018bb:	01 d0                	add    %edx,%eax
801018bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801018c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018c3:	0f b7 00             	movzwl (%eax),%eax
801018c6:	66 85 c0             	test   %ax,%ax
801018c9:	75 4c                	jne    80101917 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
801018cb:	83 ec 04             	sub    $0x4,%esp
801018ce:	6a 40                	push   $0x40
801018d0:	6a 00                	push   $0x0
801018d2:	ff 75 ec             	pushl  -0x14(%ebp)
801018d5:	e8 9e 3c 00 00       	call   80105578 <memset>
801018da:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801018dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018e0:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801018e4:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801018e7:	83 ec 0c             	sub    $0xc,%esp
801018ea:	ff 75 f0             	pushl  -0x10(%ebp)
801018ed:	e8 58 20 00 00       	call   8010394a <log_write>
801018f2:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801018f5:	83 ec 0c             	sub    $0xc,%esp
801018f8:	ff 75 f0             	pushl  -0x10(%ebp)
801018fb:	e8 61 e9 ff ff       	call   80100261 <brelse>
80101900:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101906:	83 ec 08             	sub    $0x8,%esp
80101909:	50                   	push   %eax
8010190a:	ff 75 08             	pushl  0x8(%ebp)
8010190d:	e8 fc 00 00 00       	call   80101a0e <iget>
80101912:	83 c4 10             	add    $0x10,%esp
80101915:	eb 30                	jmp    80101947 <ialloc+0xd9>
    }
    brelse(bp);
80101917:	83 ec 0c             	sub    $0xc,%esp
8010191a:	ff 75 f0             	pushl  -0x10(%ebp)
8010191d:	e8 3f e9 ff ff       	call   80100261 <brelse>
80101922:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101925:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101929:	8b 15 68 2a 11 80    	mov    0x80112a68,%edx
8010192f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101932:	39 c2                	cmp    %eax,%edx
80101934:	0f 87 51 ff ff ff    	ja     8010188b <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
8010193a:	83 ec 0c             	sub    $0xc,%esp
8010193d:	68 d7 94 10 80       	push   $0x801094d7
80101942:	e8 c1 ec ff ff       	call   80100608 <panic>
}
80101947:	c9                   	leave  
80101948:	c3                   	ret    

80101949 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101949:	f3 0f 1e fb          	endbr32 
8010194d:	55                   	push   %ebp
8010194e:	89 e5                	mov    %esp,%ebp
80101950:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101953:	8b 45 08             	mov    0x8(%ebp),%eax
80101956:	8b 40 04             	mov    0x4(%eax),%eax
80101959:	c1 e8 03             	shr    $0x3,%eax
8010195c:	89 c2                	mov    %eax,%edx
8010195e:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101963:	01 c2                	add    %eax,%edx
80101965:	8b 45 08             	mov    0x8(%ebp),%eax
80101968:	8b 00                	mov    (%eax),%eax
8010196a:	83 ec 08             	sub    $0x8,%esp
8010196d:	52                   	push   %edx
8010196e:	50                   	push   %eax
8010196f:	e8 63 e8 ff ff       	call   801001d7 <bread>
80101974:	83 c4 10             	add    $0x10,%esp
80101977:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010197a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101980:	8b 45 08             	mov    0x8(%ebp),%eax
80101983:	8b 40 04             	mov    0x4(%eax),%eax
80101986:	83 e0 07             	and    $0x7,%eax
80101989:	c1 e0 06             	shl    $0x6,%eax
8010198c:	01 d0                	add    %edx,%eax
8010198e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101991:	8b 45 08             	mov    0x8(%ebp),%eax
80101994:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101998:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010199b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010199e:	8b 45 08             	mov    0x8(%ebp),%eax
801019a1:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801019a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019a8:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801019ac:	8b 45 08             	mov    0x8(%ebp),%eax
801019af:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801019b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b6:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801019ba:	8b 45 08             	mov    0x8(%ebp),%eax
801019bd:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801019c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c4:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801019c8:	8b 45 08             	mov    0x8(%ebp),%eax
801019cb:	8b 50 58             	mov    0x58(%eax),%edx
801019ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d1:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019d4:	8b 45 08             	mov    0x8(%ebp),%eax
801019d7:	8d 50 5c             	lea    0x5c(%eax),%edx
801019da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019dd:	83 c0 0c             	add    $0xc,%eax
801019e0:	83 ec 04             	sub    $0x4,%esp
801019e3:	6a 34                	push   $0x34
801019e5:	52                   	push   %edx
801019e6:	50                   	push   %eax
801019e7:	e8 53 3c 00 00       	call   8010563f <memmove>
801019ec:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801019ef:	83 ec 0c             	sub    $0xc,%esp
801019f2:	ff 75 f4             	pushl  -0xc(%ebp)
801019f5:	e8 50 1f 00 00       	call   8010394a <log_write>
801019fa:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019fd:	83 ec 0c             	sub    $0xc,%esp
80101a00:	ff 75 f4             	pushl  -0xc(%ebp)
80101a03:	e8 59 e8 ff ff       	call   80100261 <brelse>
80101a08:	83 c4 10             	add    $0x10,%esp
}
80101a0b:	90                   	nop
80101a0c:	c9                   	leave  
80101a0d:	c3                   	ret    

80101a0e <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a0e:	f3 0f 1e fb          	endbr32 
80101a12:	55                   	push   %ebp
80101a13:	89 e5                	mov    %esp,%ebp
80101a15:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a18:	83 ec 0c             	sub    $0xc,%esp
80101a1b:	68 80 2a 11 80       	push   $0x80112a80
80101a20:	e8 b4 38 00 00       	call   801052d9 <acquire>
80101a25:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101a28:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a2f:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
80101a36:	eb 60                	jmp    80101a98 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3b:	8b 40 08             	mov    0x8(%eax),%eax
80101a3e:	85 c0                	test   %eax,%eax
80101a40:	7e 39                	jle    80101a7b <iget+0x6d>
80101a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a45:	8b 00                	mov    (%eax),%eax
80101a47:	39 45 08             	cmp    %eax,0x8(%ebp)
80101a4a:	75 2f                	jne    80101a7b <iget+0x6d>
80101a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4f:	8b 40 04             	mov    0x4(%eax),%eax
80101a52:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101a55:	75 24                	jne    80101a7b <iget+0x6d>
      ip->ref++;
80101a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a5a:	8b 40 08             	mov    0x8(%eax),%eax
80101a5d:	8d 50 01             	lea    0x1(%eax),%edx
80101a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a63:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a66:	83 ec 0c             	sub    $0xc,%esp
80101a69:	68 80 2a 11 80       	push   $0x80112a80
80101a6e:	e8 d8 38 00 00       	call   8010534b <release>
80101a73:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a79:	eb 77                	jmp    80101af2 <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a7f:	75 10                	jne    80101a91 <iget+0x83>
80101a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a84:	8b 40 08             	mov    0x8(%eax),%eax
80101a87:	85 c0                	test   %eax,%eax
80101a89:	75 06                	jne    80101a91 <iget+0x83>
      empty = ip;
80101a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a91:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a98:	81 7d f4 d4 46 11 80 	cmpl   $0x801146d4,-0xc(%ebp)
80101a9f:	72 97                	jb     80101a38 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101aa1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101aa5:	75 0d                	jne    80101ab4 <iget+0xa6>
    panic("iget: no inodes");
80101aa7:	83 ec 0c             	sub    $0xc,%esp
80101aaa:	68 e9 94 10 80       	push   $0x801094e9
80101aaf:	e8 54 eb ff ff       	call   80100608 <panic>

  ip = empty;
80101ab4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101abd:	8b 55 08             	mov    0x8(%ebp),%edx
80101ac0:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac5:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ac8:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ace:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ad8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101adf:	83 ec 0c             	sub    $0xc,%esp
80101ae2:	68 80 2a 11 80       	push   $0x80112a80
80101ae7:	e8 5f 38 00 00       	call   8010534b <release>
80101aec:	83 c4 10             	add    $0x10,%esp

  return ip;
80101aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101af2:	c9                   	leave  
80101af3:	c3                   	ret    

80101af4 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101af4:	f3 0f 1e fb          	endbr32 
80101af8:	55                   	push   %ebp
80101af9:	89 e5                	mov    %esp,%ebp
80101afb:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101afe:	83 ec 0c             	sub    $0xc,%esp
80101b01:	68 80 2a 11 80       	push   $0x80112a80
80101b06:	e8 ce 37 00 00       	call   801052d9 <acquire>
80101b0b:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b11:	8b 40 08             	mov    0x8(%eax),%eax
80101b14:	8d 50 01             	lea    0x1(%eax),%edx
80101b17:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1a:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b1d:	83 ec 0c             	sub    $0xc,%esp
80101b20:	68 80 2a 11 80       	push   $0x80112a80
80101b25:	e8 21 38 00 00       	call   8010534b <release>
80101b2a:	83 c4 10             	add    $0x10,%esp
  return ip;
80101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b30:	c9                   	leave  
80101b31:	c3                   	ret    

80101b32 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b32:	f3 0f 1e fb          	endbr32 
80101b36:	55                   	push   %ebp
80101b37:	89 e5                	mov    %esp,%ebp
80101b39:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b3c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b40:	74 0a                	je     80101b4c <ilock+0x1a>
80101b42:	8b 45 08             	mov    0x8(%ebp),%eax
80101b45:	8b 40 08             	mov    0x8(%eax),%eax
80101b48:	85 c0                	test   %eax,%eax
80101b4a:	7f 0d                	jg     80101b59 <ilock+0x27>
    panic("ilock");
80101b4c:	83 ec 0c             	sub    $0xc,%esp
80101b4f:	68 f9 94 10 80       	push   $0x801094f9
80101b54:	e8 af ea ff ff       	call   80100608 <panic>

  acquiresleep(&ip->lock);
80101b59:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5c:	83 c0 0c             	add    $0xc,%eax
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	50                   	push   %eax
80101b63:	e8 f8 35 00 00       	call   80105160 <acquiresleep>
80101b68:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b71:	85 c0                	test   %eax,%eax
80101b73:	0f 85 cd 00 00 00    	jne    80101c46 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b79:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7c:	8b 40 04             	mov    0x4(%eax),%eax
80101b7f:	c1 e8 03             	shr    $0x3,%eax
80101b82:	89 c2                	mov    %eax,%edx
80101b84:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101b89:	01 c2                	add    %eax,%edx
80101b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8e:	8b 00                	mov    (%eax),%eax
80101b90:	83 ec 08             	sub    $0x8,%esp
80101b93:	52                   	push   %edx
80101b94:	50                   	push   %eax
80101b95:	e8 3d e6 ff ff       	call   801001d7 <bread>
80101b9a:	83 c4 10             	add    $0x10,%esp
80101b9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ba3:	8d 50 5c             	lea    0x5c(%eax),%edx
80101ba6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba9:	8b 40 04             	mov    0x4(%eax),%eax
80101bac:	83 e0 07             	and    $0x7,%eax
80101baf:	c1 e0 06             	shl    $0x6,%eax
80101bb2:	01 d0                	add    %edx,%eax
80101bb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bba:	0f b7 10             	movzwl (%eax),%edx
80101bbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc0:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bc7:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bce:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bd5:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101bd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdc:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101be0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be3:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101be7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bea:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101bee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bf1:	8b 50 08             	mov    0x8(%eax),%edx
80101bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf7:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bfd:	8d 50 0c             	lea    0xc(%eax),%edx
80101c00:	8b 45 08             	mov    0x8(%ebp),%eax
80101c03:	83 c0 5c             	add    $0x5c,%eax
80101c06:	83 ec 04             	sub    $0x4,%esp
80101c09:	6a 34                	push   $0x34
80101c0b:	52                   	push   %edx
80101c0c:	50                   	push   %eax
80101c0d:	e8 2d 3a 00 00       	call   8010563f <memmove>
80101c12:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101c15:	83 ec 0c             	sub    $0xc,%esp
80101c18:	ff 75 f4             	pushl  -0xc(%ebp)
80101c1b:	e8 41 e6 ff ff       	call   80100261 <brelse>
80101c20:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101c23:	8b 45 08             	mov    0x8(%ebp),%eax
80101c26:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c30:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101c34:	66 85 c0             	test   %ax,%ax
80101c37:	75 0d                	jne    80101c46 <ilock+0x114>
      panic("ilock: no type");
80101c39:	83 ec 0c             	sub    $0xc,%esp
80101c3c:	68 ff 94 10 80       	push   $0x801094ff
80101c41:	e8 c2 e9 ff ff       	call   80100608 <panic>
  }
}
80101c46:	90                   	nop
80101c47:	c9                   	leave  
80101c48:	c3                   	ret    

80101c49 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c49:	f3 0f 1e fb          	endbr32 
80101c4d:	55                   	push   %ebp
80101c4e:	89 e5                	mov    %esp,%ebp
80101c50:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c53:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c57:	74 20                	je     80101c79 <iunlock+0x30>
80101c59:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5c:	83 c0 0c             	add    $0xc,%eax
80101c5f:	83 ec 0c             	sub    $0xc,%esp
80101c62:	50                   	push   %eax
80101c63:	e8 b2 35 00 00       	call   8010521a <holdingsleep>
80101c68:	83 c4 10             	add    $0x10,%esp
80101c6b:	85 c0                	test   %eax,%eax
80101c6d:	74 0a                	je     80101c79 <iunlock+0x30>
80101c6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c72:	8b 40 08             	mov    0x8(%eax),%eax
80101c75:	85 c0                	test   %eax,%eax
80101c77:	7f 0d                	jg     80101c86 <iunlock+0x3d>
    panic("iunlock");
80101c79:	83 ec 0c             	sub    $0xc,%esp
80101c7c:	68 0e 95 10 80       	push   $0x8010950e
80101c81:	e8 82 e9 ff ff       	call   80100608 <panic>

  releasesleep(&ip->lock);
80101c86:	8b 45 08             	mov    0x8(%ebp),%eax
80101c89:	83 c0 0c             	add    $0xc,%eax
80101c8c:	83 ec 0c             	sub    $0xc,%esp
80101c8f:	50                   	push   %eax
80101c90:	e8 33 35 00 00       	call   801051c8 <releasesleep>
80101c95:	83 c4 10             	add    $0x10,%esp
}
80101c98:	90                   	nop
80101c99:	c9                   	leave  
80101c9a:	c3                   	ret    

80101c9b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c9b:	f3 0f 1e fb          	endbr32 
80101c9f:	55                   	push   %ebp
80101ca0:	89 e5                	mov    %esp,%ebp
80101ca2:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101ca5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca8:	83 c0 0c             	add    $0xc,%eax
80101cab:	83 ec 0c             	sub    $0xc,%esp
80101cae:	50                   	push   %eax
80101caf:	e8 ac 34 00 00       	call   80105160 <acquiresleep>
80101cb4:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101cb7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cba:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cbd:	85 c0                	test   %eax,%eax
80101cbf:	74 6a                	je     80101d2b <iput+0x90>
80101cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101cc8:	66 85 c0             	test   %ax,%ax
80101ccb:	75 5e                	jne    80101d2b <iput+0x90>
    acquire(&icache.lock);
80101ccd:	83 ec 0c             	sub    $0xc,%esp
80101cd0:	68 80 2a 11 80       	push   $0x80112a80
80101cd5:	e8 ff 35 00 00       	call   801052d9 <acquire>
80101cda:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce0:	8b 40 08             	mov    0x8(%eax),%eax
80101ce3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101ce6:	83 ec 0c             	sub    $0xc,%esp
80101ce9:	68 80 2a 11 80       	push   $0x80112a80
80101cee:	e8 58 36 00 00       	call   8010534b <release>
80101cf3:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101cf6:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101cfa:	75 2f                	jne    80101d2b <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101cfc:	83 ec 0c             	sub    $0xc,%esp
80101cff:	ff 75 08             	pushl  0x8(%ebp)
80101d02:	e8 b5 01 00 00       	call   80101ebc <itrunc>
80101d07:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0d:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101d13:	83 ec 0c             	sub    $0xc,%esp
80101d16:	ff 75 08             	pushl  0x8(%ebp)
80101d19:	e8 2b fc ff ff       	call   80101949 <iupdate>
80101d1e:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101d21:	8b 45 08             	mov    0x8(%ebp),%eax
80101d24:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2e:	83 c0 0c             	add    $0xc,%eax
80101d31:	83 ec 0c             	sub    $0xc,%esp
80101d34:	50                   	push   %eax
80101d35:	e8 8e 34 00 00       	call   801051c8 <releasesleep>
80101d3a:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101d3d:	83 ec 0c             	sub    $0xc,%esp
80101d40:	68 80 2a 11 80       	push   $0x80112a80
80101d45:	e8 8f 35 00 00       	call   801052d9 <acquire>
80101d4a:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101d4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d50:	8b 40 08             	mov    0x8(%eax),%eax
80101d53:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d56:	8b 45 08             	mov    0x8(%ebp),%eax
80101d59:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d5c:	83 ec 0c             	sub    $0xc,%esp
80101d5f:	68 80 2a 11 80       	push   $0x80112a80
80101d64:	e8 e2 35 00 00       	call   8010534b <release>
80101d69:	83 c4 10             	add    $0x10,%esp
}
80101d6c:	90                   	nop
80101d6d:	c9                   	leave  
80101d6e:	c3                   	ret    

80101d6f <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d6f:	f3 0f 1e fb          	endbr32 
80101d73:	55                   	push   %ebp
80101d74:	89 e5                	mov    %esp,%ebp
80101d76:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d79:	83 ec 0c             	sub    $0xc,%esp
80101d7c:	ff 75 08             	pushl  0x8(%ebp)
80101d7f:	e8 c5 fe ff ff       	call   80101c49 <iunlock>
80101d84:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d87:	83 ec 0c             	sub    $0xc,%esp
80101d8a:	ff 75 08             	pushl  0x8(%ebp)
80101d8d:	e8 09 ff ff ff       	call   80101c9b <iput>
80101d92:	83 c4 10             	add    $0x10,%esp
}
80101d95:	90                   	nop
80101d96:	c9                   	leave  
80101d97:	c3                   	ret    

80101d98 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d98:	f3 0f 1e fb          	endbr32 
80101d9c:	55                   	push   %ebp
80101d9d:	89 e5                	mov    %esp,%ebp
80101d9f:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101da2:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101da6:	77 42                	ja     80101dea <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101da8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dab:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dae:	83 c2 14             	add    $0x14,%edx
80101db1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101db5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101db8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dbc:	75 24                	jne    80101de2 <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc1:	8b 00                	mov    (%eax),%eax
80101dc3:	83 ec 0c             	sub    $0xc,%esp
80101dc6:	50                   	push   %eax
80101dc7:	e8 c7 f7 ff ff       	call   80101593 <balloc>
80101dcc:	83 c4 10             	add    $0x10,%esp
80101dcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd5:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dd8:	8d 4a 14             	lea    0x14(%edx),%ecx
80101ddb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dde:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101de5:	e9 d0 00 00 00       	jmp    80101eba <bmap+0x122>
  }
  bn -= NDIRECT;
80101dea:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101dee:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101df2:	0f 87 b5 00 00 00    	ja     80101ead <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101df8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfb:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e01:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e04:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e08:	75 20                	jne    80101e2a <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0d:	8b 00                	mov    (%eax),%eax
80101e0f:	83 ec 0c             	sub    $0xc,%esp
80101e12:	50                   	push   %eax
80101e13:	e8 7b f7 ff ff       	call   80101593 <balloc>
80101e18:	83 c4 10             	add    $0x10,%esp
80101e1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e24:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2d:	8b 00                	mov    (%eax),%eax
80101e2f:	83 ec 08             	sub    $0x8,%esp
80101e32:	ff 75 f4             	pushl  -0xc(%ebp)
80101e35:	50                   	push   %eax
80101e36:	e8 9c e3 ff ff       	call   801001d7 <bread>
80101e3b:	83 c4 10             	add    $0x10,%esp
80101e3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e44:	83 c0 5c             	add    $0x5c,%eax
80101e47:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e4d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e57:	01 d0                	add    %edx,%eax
80101e59:	8b 00                	mov    (%eax),%eax
80101e5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e5e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e62:	75 36                	jne    80101e9a <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101e64:	8b 45 08             	mov    0x8(%ebp),%eax
80101e67:	8b 00                	mov    (%eax),%eax
80101e69:	83 ec 0c             	sub    $0xc,%esp
80101e6c:	50                   	push   %eax
80101e6d:	e8 21 f7 ff ff       	call   80101593 <balloc>
80101e72:	83 c4 10             	add    $0x10,%esp
80101e75:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e78:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e7b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e82:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e85:	01 c2                	add    %eax,%edx
80101e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e8a:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101e8c:	83 ec 0c             	sub    $0xc,%esp
80101e8f:	ff 75 f0             	pushl  -0x10(%ebp)
80101e92:	e8 b3 1a 00 00       	call   8010394a <log_write>
80101e97:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e9a:	83 ec 0c             	sub    $0xc,%esp
80101e9d:	ff 75 f0             	pushl  -0x10(%ebp)
80101ea0:	e8 bc e3 ff ff       	call   80100261 <brelse>
80101ea5:	83 c4 10             	add    $0x10,%esp
    return addr;
80101ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eab:	eb 0d                	jmp    80101eba <bmap+0x122>
  }

  panic("bmap: out of range");
80101ead:	83 ec 0c             	sub    $0xc,%esp
80101eb0:	68 16 95 10 80       	push   $0x80109516
80101eb5:	e8 4e e7 ff ff       	call   80100608 <panic>
}
80101eba:	c9                   	leave  
80101ebb:	c3                   	ret    

80101ebc <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101ebc:	f3 0f 1e fb          	endbr32 
80101ec0:	55                   	push   %ebp
80101ec1:	89 e5                	mov    %esp,%ebp
80101ec3:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101ec6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ecd:	eb 45                	jmp    80101f14 <itrunc+0x58>
    if(ip->addrs[i]){
80101ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ed5:	83 c2 14             	add    $0x14,%edx
80101ed8:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101edc:	85 c0                	test   %eax,%eax
80101ede:	74 30                	je     80101f10 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ee6:	83 c2 14             	add    $0x14,%edx
80101ee9:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101eed:	8b 55 08             	mov    0x8(%ebp),%edx
80101ef0:	8b 12                	mov    (%edx),%edx
80101ef2:	83 ec 08             	sub    $0x8,%esp
80101ef5:	50                   	push   %eax
80101ef6:	52                   	push   %edx
80101ef7:	e8 e7 f7 ff ff       	call   801016e3 <bfree>
80101efc:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101eff:	8b 45 08             	mov    0x8(%ebp),%eax
80101f02:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f05:	83 c2 14             	add    $0x14,%edx
80101f08:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101f0f:	00 
  for(i = 0; i < NDIRECT; i++){
80101f10:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f14:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f18:	7e b5                	jle    80101ecf <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1d:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f23:	85 c0                	test   %eax,%eax
80101f25:	0f 84 aa 00 00 00    	je     80101fd5 <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2e:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f34:	8b 45 08             	mov    0x8(%ebp),%eax
80101f37:	8b 00                	mov    (%eax),%eax
80101f39:	83 ec 08             	sub    $0x8,%esp
80101f3c:	52                   	push   %edx
80101f3d:	50                   	push   %eax
80101f3e:	e8 94 e2 ff ff       	call   801001d7 <bread>
80101f43:	83 c4 10             	add    $0x10,%esp
80101f46:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f4c:	83 c0 5c             	add    $0x5c,%eax
80101f4f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f52:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f59:	eb 3c                	jmp    80101f97 <itrunc+0xdb>
      if(a[j])
80101f5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f5e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f65:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f68:	01 d0                	add    %edx,%eax
80101f6a:	8b 00                	mov    (%eax),%eax
80101f6c:	85 c0                	test   %eax,%eax
80101f6e:	74 23                	je     80101f93 <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101f70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f73:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f7a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f7d:	01 d0                	add    %edx,%eax
80101f7f:	8b 00                	mov    (%eax),%eax
80101f81:	8b 55 08             	mov    0x8(%ebp),%edx
80101f84:	8b 12                	mov    (%edx),%edx
80101f86:	83 ec 08             	sub    $0x8,%esp
80101f89:	50                   	push   %eax
80101f8a:	52                   	push   %edx
80101f8b:	e8 53 f7 ff ff       	call   801016e3 <bfree>
80101f90:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101f93:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f9a:	83 f8 7f             	cmp    $0x7f,%eax
80101f9d:	76 bc                	jbe    80101f5b <itrunc+0x9f>
    }
    brelse(bp);
80101f9f:	83 ec 0c             	sub    $0xc,%esp
80101fa2:	ff 75 ec             	pushl  -0x14(%ebp)
80101fa5:	e8 b7 e2 ff ff       	call   80100261 <brelse>
80101faa:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101fad:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb0:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101fb6:	8b 55 08             	mov    0x8(%ebp),%edx
80101fb9:	8b 12                	mov    (%edx),%edx
80101fbb:	83 ec 08             	sub    $0x8,%esp
80101fbe:	50                   	push   %eax
80101fbf:	52                   	push   %edx
80101fc0:	e8 1e f7 ff ff       	call   801016e3 <bfree>
80101fc5:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101fc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101fcb:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101fd2:	00 00 00 
  }

  ip->size = 0;
80101fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd8:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101fdf:	83 ec 0c             	sub    $0xc,%esp
80101fe2:	ff 75 08             	pushl  0x8(%ebp)
80101fe5:	e8 5f f9 ff ff       	call   80101949 <iupdate>
80101fea:	83 c4 10             	add    $0x10,%esp
}
80101fed:	90                   	nop
80101fee:	c9                   	leave  
80101fef:	c3                   	ret    

80101ff0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101ff0:	f3 0f 1e fb          	endbr32 
80101ff4:	55                   	push   %ebp
80101ff5:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffa:	8b 00                	mov    (%eax),%eax
80101ffc:	89 c2                	mov    %eax,%edx
80101ffe:	8b 45 0c             	mov    0xc(%ebp),%eax
80102001:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102004:	8b 45 08             	mov    0x8(%ebp),%eax
80102007:	8b 50 04             	mov    0x4(%eax),%edx
8010200a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010200d:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102010:	8b 45 08             	mov    0x8(%ebp),%eax
80102013:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80102017:	8b 45 0c             	mov    0xc(%ebp),%eax
8010201a:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
8010201d:	8b 45 08             	mov    0x8(%ebp),%eax
80102020:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80102024:	8b 45 0c             	mov    0xc(%ebp),%eax
80102027:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
8010202b:	8b 45 08             	mov    0x8(%ebp),%eax
8010202e:	8b 50 58             	mov    0x58(%eax),%edx
80102031:	8b 45 0c             	mov    0xc(%ebp),%eax
80102034:	89 50 10             	mov    %edx,0x10(%eax)
}
80102037:	90                   	nop
80102038:	5d                   	pop    %ebp
80102039:	c3                   	ret    

8010203a <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
8010203a:	f3 0f 1e fb          	endbr32 
8010203e:	55                   	push   %ebp
8010203f:	89 e5                	mov    %esp,%ebp
80102041:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102044:	8b 45 08             	mov    0x8(%ebp),%eax
80102047:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010204b:	66 83 f8 03          	cmp    $0x3,%ax
8010204f:	75 5c                	jne    801020ad <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102051:	8b 45 08             	mov    0x8(%ebp),%eax
80102054:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102058:	66 85 c0             	test   %ax,%ax
8010205b:	78 20                	js     8010207d <readi+0x43>
8010205d:	8b 45 08             	mov    0x8(%ebp),%eax
80102060:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102064:	66 83 f8 09          	cmp    $0x9,%ax
80102068:	7f 13                	jg     8010207d <readi+0x43>
8010206a:	8b 45 08             	mov    0x8(%ebp),%eax
8010206d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102071:	98                   	cwtl   
80102072:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
80102079:	85 c0                	test   %eax,%eax
8010207b:	75 0a                	jne    80102087 <readi+0x4d>
      return -1;
8010207d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102082:	e9 0a 01 00 00       	jmp    80102191 <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80102087:	8b 45 08             	mov    0x8(%ebp),%eax
8010208a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010208e:	98                   	cwtl   
8010208f:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
80102096:	8b 55 14             	mov    0x14(%ebp),%edx
80102099:	83 ec 04             	sub    $0x4,%esp
8010209c:	52                   	push   %edx
8010209d:	ff 75 0c             	pushl  0xc(%ebp)
801020a0:	ff 75 08             	pushl  0x8(%ebp)
801020a3:	ff d0                	call   *%eax
801020a5:	83 c4 10             	add    $0x10,%esp
801020a8:	e9 e4 00 00 00       	jmp    80102191 <readi+0x157>
  }

  if(off > ip->size || off + n < off)
801020ad:	8b 45 08             	mov    0x8(%ebp),%eax
801020b0:	8b 40 58             	mov    0x58(%eax),%eax
801020b3:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b6:	77 0d                	ja     801020c5 <readi+0x8b>
801020b8:	8b 55 10             	mov    0x10(%ebp),%edx
801020bb:	8b 45 14             	mov    0x14(%ebp),%eax
801020be:	01 d0                	add    %edx,%eax
801020c0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020c3:	76 0a                	jbe    801020cf <readi+0x95>
    return -1;
801020c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020ca:	e9 c2 00 00 00       	jmp    80102191 <readi+0x157>
  if(off + n > ip->size)
801020cf:	8b 55 10             	mov    0x10(%ebp),%edx
801020d2:	8b 45 14             	mov    0x14(%ebp),%eax
801020d5:	01 c2                	add    %eax,%edx
801020d7:	8b 45 08             	mov    0x8(%ebp),%eax
801020da:	8b 40 58             	mov    0x58(%eax),%eax
801020dd:	39 c2                	cmp    %eax,%edx
801020df:	76 0c                	jbe    801020ed <readi+0xb3>
    n = ip->size - off;
801020e1:	8b 45 08             	mov    0x8(%ebp),%eax
801020e4:	8b 40 58             	mov    0x58(%eax),%eax
801020e7:	2b 45 10             	sub    0x10(%ebp),%eax
801020ea:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020f4:	e9 89 00 00 00       	jmp    80102182 <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020f9:	8b 45 10             	mov    0x10(%ebp),%eax
801020fc:	c1 e8 09             	shr    $0x9,%eax
801020ff:	83 ec 08             	sub    $0x8,%esp
80102102:	50                   	push   %eax
80102103:	ff 75 08             	pushl  0x8(%ebp)
80102106:	e8 8d fc ff ff       	call   80101d98 <bmap>
8010210b:	83 c4 10             	add    $0x10,%esp
8010210e:	8b 55 08             	mov    0x8(%ebp),%edx
80102111:	8b 12                	mov    (%edx),%edx
80102113:	83 ec 08             	sub    $0x8,%esp
80102116:	50                   	push   %eax
80102117:	52                   	push   %edx
80102118:	e8 ba e0 ff ff       	call   801001d7 <bread>
8010211d:	83 c4 10             	add    $0x10,%esp
80102120:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102123:	8b 45 10             	mov    0x10(%ebp),%eax
80102126:	25 ff 01 00 00       	and    $0x1ff,%eax
8010212b:	ba 00 02 00 00       	mov    $0x200,%edx
80102130:	29 c2                	sub    %eax,%edx
80102132:	8b 45 14             	mov    0x14(%ebp),%eax
80102135:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102138:	39 c2                	cmp    %eax,%edx
8010213a:	0f 46 c2             	cmovbe %edx,%eax
8010213d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102140:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102143:	8d 50 5c             	lea    0x5c(%eax),%edx
80102146:	8b 45 10             	mov    0x10(%ebp),%eax
80102149:	25 ff 01 00 00       	and    $0x1ff,%eax
8010214e:	01 d0                	add    %edx,%eax
80102150:	83 ec 04             	sub    $0x4,%esp
80102153:	ff 75 ec             	pushl  -0x14(%ebp)
80102156:	50                   	push   %eax
80102157:	ff 75 0c             	pushl  0xc(%ebp)
8010215a:	e8 e0 34 00 00       	call   8010563f <memmove>
8010215f:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102162:	83 ec 0c             	sub    $0xc,%esp
80102165:	ff 75 f0             	pushl  -0x10(%ebp)
80102168:	e8 f4 e0 ff ff       	call   80100261 <brelse>
8010216d:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102170:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102173:	01 45 f4             	add    %eax,-0xc(%ebp)
80102176:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102179:	01 45 10             	add    %eax,0x10(%ebp)
8010217c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217f:	01 45 0c             	add    %eax,0xc(%ebp)
80102182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102185:	3b 45 14             	cmp    0x14(%ebp),%eax
80102188:	0f 82 6b ff ff ff    	jb     801020f9 <readi+0xbf>
  }
  return n;
8010218e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102191:	c9                   	leave  
80102192:	c3                   	ret    

80102193 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102193:	f3 0f 1e fb          	endbr32 
80102197:	55                   	push   %ebp
80102198:	89 e5                	mov    %esp,%ebp
8010219a:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010219d:	8b 45 08             	mov    0x8(%ebp),%eax
801021a0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021a4:	66 83 f8 03          	cmp    $0x3,%ax
801021a8:	75 5c                	jne    80102206 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801021aa:	8b 45 08             	mov    0x8(%ebp),%eax
801021ad:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021b1:	66 85 c0             	test   %ax,%ax
801021b4:	78 20                	js     801021d6 <writei+0x43>
801021b6:	8b 45 08             	mov    0x8(%ebp),%eax
801021b9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021bd:	66 83 f8 09          	cmp    $0x9,%ax
801021c1:	7f 13                	jg     801021d6 <writei+0x43>
801021c3:	8b 45 08             	mov    0x8(%ebp),%eax
801021c6:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021ca:	98                   	cwtl   
801021cb:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021d2:	85 c0                	test   %eax,%eax
801021d4:	75 0a                	jne    801021e0 <writei+0x4d>
      return -1;
801021d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021db:	e9 3b 01 00 00       	jmp    8010231b <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
801021e0:	8b 45 08             	mov    0x8(%ebp),%eax
801021e3:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021e7:	98                   	cwtl   
801021e8:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021ef:	8b 55 14             	mov    0x14(%ebp),%edx
801021f2:	83 ec 04             	sub    $0x4,%esp
801021f5:	52                   	push   %edx
801021f6:	ff 75 0c             	pushl  0xc(%ebp)
801021f9:	ff 75 08             	pushl  0x8(%ebp)
801021fc:	ff d0                	call   *%eax
801021fe:	83 c4 10             	add    $0x10,%esp
80102201:	e9 15 01 00 00       	jmp    8010231b <writei+0x188>
  }

  if(off > ip->size || off + n < off)
80102206:	8b 45 08             	mov    0x8(%ebp),%eax
80102209:	8b 40 58             	mov    0x58(%eax),%eax
8010220c:	39 45 10             	cmp    %eax,0x10(%ebp)
8010220f:	77 0d                	ja     8010221e <writei+0x8b>
80102211:	8b 55 10             	mov    0x10(%ebp),%edx
80102214:	8b 45 14             	mov    0x14(%ebp),%eax
80102217:	01 d0                	add    %edx,%eax
80102219:	39 45 10             	cmp    %eax,0x10(%ebp)
8010221c:	76 0a                	jbe    80102228 <writei+0x95>
    return -1;
8010221e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102223:	e9 f3 00 00 00       	jmp    8010231b <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102228:	8b 55 10             	mov    0x10(%ebp),%edx
8010222b:	8b 45 14             	mov    0x14(%ebp),%eax
8010222e:	01 d0                	add    %edx,%eax
80102230:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102235:	76 0a                	jbe    80102241 <writei+0xae>
    return -1;
80102237:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010223c:	e9 da 00 00 00       	jmp    8010231b <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102241:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102248:	e9 97 00 00 00       	jmp    801022e4 <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010224d:	8b 45 10             	mov    0x10(%ebp),%eax
80102250:	c1 e8 09             	shr    $0x9,%eax
80102253:	83 ec 08             	sub    $0x8,%esp
80102256:	50                   	push   %eax
80102257:	ff 75 08             	pushl  0x8(%ebp)
8010225a:	e8 39 fb ff ff       	call   80101d98 <bmap>
8010225f:	83 c4 10             	add    $0x10,%esp
80102262:	8b 55 08             	mov    0x8(%ebp),%edx
80102265:	8b 12                	mov    (%edx),%edx
80102267:	83 ec 08             	sub    $0x8,%esp
8010226a:	50                   	push   %eax
8010226b:	52                   	push   %edx
8010226c:	e8 66 df ff ff       	call   801001d7 <bread>
80102271:	83 c4 10             	add    $0x10,%esp
80102274:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102277:	8b 45 10             	mov    0x10(%ebp),%eax
8010227a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010227f:	ba 00 02 00 00       	mov    $0x200,%edx
80102284:	29 c2                	sub    %eax,%edx
80102286:	8b 45 14             	mov    0x14(%ebp),%eax
80102289:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010228c:	39 c2                	cmp    %eax,%edx
8010228e:	0f 46 c2             	cmovbe %edx,%eax
80102291:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102294:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102297:	8d 50 5c             	lea    0x5c(%eax),%edx
8010229a:	8b 45 10             	mov    0x10(%ebp),%eax
8010229d:	25 ff 01 00 00       	and    $0x1ff,%eax
801022a2:	01 d0                	add    %edx,%eax
801022a4:	83 ec 04             	sub    $0x4,%esp
801022a7:	ff 75 ec             	pushl  -0x14(%ebp)
801022aa:	ff 75 0c             	pushl  0xc(%ebp)
801022ad:	50                   	push   %eax
801022ae:	e8 8c 33 00 00       	call   8010563f <memmove>
801022b3:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801022b6:	83 ec 0c             	sub    $0xc,%esp
801022b9:	ff 75 f0             	pushl  -0x10(%ebp)
801022bc:	e8 89 16 00 00       	call   8010394a <log_write>
801022c1:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801022c4:	83 ec 0c             	sub    $0xc,%esp
801022c7:	ff 75 f0             	pushl  -0x10(%ebp)
801022ca:	e8 92 df ff ff       	call   80100261 <brelse>
801022cf:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022d5:	01 45 f4             	add    %eax,-0xc(%ebp)
801022d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022db:	01 45 10             	add    %eax,0x10(%ebp)
801022de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022e1:	01 45 0c             	add    %eax,0xc(%ebp)
801022e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e7:	3b 45 14             	cmp    0x14(%ebp),%eax
801022ea:	0f 82 5d ff ff ff    	jb     8010224d <writei+0xba>
  }

  if(n > 0 && off > ip->size){
801022f0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801022f4:	74 22                	je     80102318 <writei+0x185>
801022f6:	8b 45 08             	mov    0x8(%ebp),%eax
801022f9:	8b 40 58             	mov    0x58(%eax),%eax
801022fc:	39 45 10             	cmp    %eax,0x10(%ebp)
801022ff:	76 17                	jbe    80102318 <writei+0x185>
    ip->size = off;
80102301:	8b 45 08             	mov    0x8(%ebp),%eax
80102304:	8b 55 10             	mov    0x10(%ebp),%edx
80102307:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010230a:	83 ec 0c             	sub    $0xc,%esp
8010230d:	ff 75 08             	pushl  0x8(%ebp)
80102310:	e8 34 f6 ff ff       	call   80101949 <iupdate>
80102315:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102318:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010231b:	c9                   	leave  
8010231c:	c3                   	ret    

8010231d <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010231d:	f3 0f 1e fb          	endbr32 
80102321:	55                   	push   %ebp
80102322:	89 e5                	mov    %esp,%ebp
80102324:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102327:	83 ec 04             	sub    $0x4,%esp
8010232a:	6a 0e                	push   $0xe
8010232c:	ff 75 0c             	pushl  0xc(%ebp)
8010232f:	ff 75 08             	pushl  0x8(%ebp)
80102332:	e8 a6 33 00 00       	call   801056dd <strncmp>
80102337:	83 c4 10             	add    $0x10,%esp
}
8010233a:	c9                   	leave  
8010233b:	c3                   	ret    

8010233c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010233c:	f3 0f 1e fb          	endbr32 
80102340:	55                   	push   %ebp
80102341:	89 e5                	mov    %esp,%ebp
80102343:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102346:	8b 45 08             	mov    0x8(%ebp),%eax
80102349:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010234d:	66 83 f8 01          	cmp    $0x1,%ax
80102351:	74 0d                	je     80102360 <dirlookup+0x24>
    panic("dirlookup not DIR");
80102353:	83 ec 0c             	sub    $0xc,%esp
80102356:	68 29 95 10 80       	push   $0x80109529
8010235b:	e8 a8 e2 ff ff       	call   80100608 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102360:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102367:	eb 7b                	jmp    801023e4 <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102369:	6a 10                	push   $0x10
8010236b:	ff 75 f4             	pushl  -0xc(%ebp)
8010236e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102371:	50                   	push   %eax
80102372:	ff 75 08             	pushl  0x8(%ebp)
80102375:	e8 c0 fc ff ff       	call   8010203a <readi>
8010237a:	83 c4 10             	add    $0x10,%esp
8010237d:	83 f8 10             	cmp    $0x10,%eax
80102380:	74 0d                	je     8010238f <dirlookup+0x53>
      panic("dirlookup read");
80102382:	83 ec 0c             	sub    $0xc,%esp
80102385:	68 3b 95 10 80       	push   $0x8010953b
8010238a:	e8 79 e2 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
8010238f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102393:	66 85 c0             	test   %ax,%ax
80102396:	74 47                	je     801023df <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
80102398:	83 ec 08             	sub    $0x8,%esp
8010239b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010239e:	83 c0 02             	add    $0x2,%eax
801023a1:	50                   	push   %eax
801023a2:	ff 75 0c             	pushl  0xc(%ebp)
801023a5:	e8 73 ff ff ff       	call   8010231d <namecmp>
801023aa:	83 c4 10             	add    $0x10,%esp
801023ad:	85 c0                	test   %eax,%eax
801023af:	75 2f                	jne    801023e0 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
801023b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801023b5:	74 08                	je     801023bf <dirlookup+0x83>
        *poff = off;
801023b7:	8b 45 10             	mov    0x10(%ebp),%eax
801023ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023bd:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801023bf:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023c3:	0f b7 c0             	movzwl %ax,%eax
801023c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801023c9:	8b 45 08             	mov    0x8(%ebp),%eax
801023cc:	8b 00                	mov    (%eax),%eax
801023ce:	83 ec 08             	sub    $0x8,%esp
801023d1:	ff 75 f0             	pushl  -0x10(%ebp)
801023d4:	50                   	push   %eax
801023d5:	e8 34 f6 ff ff       	call   80101a0e <iget>
801023da:	83 c4 10             	add    $0x10,%esp
801023dd:	eb 19                	jmp    801023f8 <dirlookup+0xbc>
      continue;
801023df:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
801023e0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801023e4:	8b 45 08             	mov    0x8(%ebp),%eax
801023e7:	8b 40 58             	mov    0x58(%eax),%eax
801023ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801023ed:	0f 82 76 ff ff ff    	jb     80102369 <dirlookup+0x2d>
    }
  }

  return 0;
801023f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023f8:	c9                   	leave  
801023f9:	c3                   	ret    

801023fa <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801023fa:	f3 0f 1e fb          	endbr32 
801023fe:	55                   	push   %ebp
801023ff:	89 e5                	mov    %esp,%ebp
80102401:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102404:	83 ec 04             	sub    $0x4,%esp
80102407:	6a 00                	push   $0x0
80102409:	ff 75 0c             	pushl  0xc(%ebp)
8010240c:	ff 75 08             	pushl  0x8(%ebp)
8010240f:	e8 28 ff ff ff       	call   8010233c <dirlookup>
80102414:	83 c4 10             	add    $0x10,%esp
80102417:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010241a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010241e:	74 18                	je     80102438 <dirlink+0x3e>
    iput(ip);
80102420:	83 ec 0c             	sub    $0xc,%esp
80102423:	ff 75 f0             	pushl  -0x10(%ebp)
80102426:	e8 70 f8 ff ff       	call   80101c9b <iput>
8010242b:	83 c4 10             	add    $0x10,%esp
    return -1;
8010242e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102433:	e9 9c 00 00 00       	jmp    801024d4 <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102438:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010243f:	eb 39                	jmp    8010247a <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102444:	6a 10                	push   $0x10
80102446:	50                   	push   %eax
80102447:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010244a:	50                   	push   %eax
8010244b:	ff 75 08             	pushl  0x8(%ebp)
8010244e:	e8 e7 fb ff ff       	call   8010203a <readi>
80102453:	83 c4 10             	add    $0x10,%esp
80102456:	83 f8 10             	cmp    $0x10,%eax
80102459:	74 0d                	je     80102468 <dirlink+0x6e>
      panic("dirlink read");
8010245b:	83 ec 0c             	sub    $0xc,%esp
8010245e:	68 4a 95 10 80       	push   $0x8010954a
80102463:	e8 a0 e1 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
80102468:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010246c:	66 85 c0             	test   %ax,%ax
8010246f:	74 18                	je     80102489 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102471:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102474:	83 c0 10             	add    $0x10,%eax
80102477:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010247a:	8b 45 08             	mov    0x8(%ebp),%eax
8010247d:	8b 50 58             	mov    0x58(%eax),%edx
80102480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102483:	39 c2                	cmp    %eax,%edx
80102485:	77 ba                	ja     80102441 <dirlink+0x47>
80102487:	eb 01                	jmp    8010248a <dirlink+0x90>
      break;
80102489:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010248a:	83 ec 04             	sub    $0x4,%esp
8010248d:	6a 0e                	push   $0xe
8010248f:	ff 75 0c             	pushl  0xc(%ebp)
80102492:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102495:	83 c0 02             	add    $0x2,%eax
80102498:	50                   	push   %eax
80102499:	e8 99 32 00 00       	call   80105737 <strncpy>
8010249e:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801024a1:	8b 45 10             	mov    0x10(%ebp),%eax
801024a4:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024ab:	6a 10                	push   $0x10
801024ad:	50                   	push   %eax
801024ae:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024b1:	50                   	push   %eax
801024b2:	ff 75 08             	pushl  0x8(%ebp)
801024b5:	e8 d9 fc ff ff       	call   80102193 <writei>
801024ba:	83 c4 10             	add    $0x10,%esp
801024bd:	83 f8 10             	cmp    $0x10,%eax
801024c0:	74 0d                	je     801024cf <dirlink+0xd5>
    panic("dirlink");
801024c2:	83 ec 0c             	sub    $0xc,%esp
801024c5:	68 57 95 10 80       	push   $0x80109557
801024ca:	e8 39 e1 ff ff       	call   80100608 <panic>

  return 0;
801024cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024d4:	c9                   	leave  
801024d5:	c3                   	ret    

801024d6 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801024d6:	f3 0f 1e fb          	endbr32 
801024da:	55                   	push   %ebp
801024db:	89 e5                	mov    %esp,%ebp
801024dd:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801024e0:	eb 04                	jmp    801024e6 <skipelem+0x10>
    path++;
801024e2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024e6:	8b 45 08             	mov    0x8(%ebp),%eax
801024e9:	0f b6 00             	movzbl (%eax),%eax
801024ec:	3c 2f                	cmp    $0x2f,%al
801024ee:	74 f2                	je     801024e2 <skipelem+0xc>
  if(*path == 0)
801024f0:	8b 45 08             	mov    0x8(%ebp),%eax
801024f3:	0f b6 00             	movzbl (%eax),%eax
801024f6:	84 c0                	test   %al,%al
801024f8:	75 07                	jne    80102501 <skipelem+0x2b>
    return 0;
801024fa:	b8 00 00 00 00       	mov    $0x0,%eax
801024ff:	eb 77                	jmp    80102578 <skipelem+0xa2>
  s = path;
80102501:	8b 45 08             	mov    0x8(%ebp),%eax
80102504:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102507:	eb 04                	jmp    8010250d <skipelem+0x37>
    path++;
80102509:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
8010250d:	8b 45 08             	mov    0x8(%ebp),%eax
80102510:	0f b6 00             	movzbl (%eax),%eax
80102513:	3c 2f                	cmp    $0x2f,%al
80102515:	74 0a                	je     80102521 <skipelem+0x4b>
80102517:	8b 45 08             	mov    0x8(%ebp),%eax
8010251a:	0f b6 00             	movzbl (%eax),%eax
8010251d:	84 c0                	test   %al,%al
8010251f:	75 e8                	jne    80102509 <skipelem+0x33>
  len = path - s;
80102521:	8b 45 08             	mov    0x8(%ebp),%eax
80102524:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102527:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010252a:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010252e:	7e 15                	jle    80102545 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102530:	83 ec 04             	sub    $0x4,%esp
80102533:	6a 0e                	push   $0xe
80102535:	ff 75 f4             	pushl  -0xc(%ebp)
80102538:	ff 75 0c             	pushl  0xc(%ebp)
8010253b:	e8 ff 30 00 00       	call   8010563f <memmove>
80102540:	83 c4 10             	add    $0x10,%esp
80102543:	eb 26                	jmp    8010256b <skipelem+0x95>
  else {
    memmove(name, s, len);
80102545:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102548:	83 ec 04             	sub    $0x4,%esp
8010254b:	50                   	push   %eax
8010254c:	ff 75 f4             	pushl  -0xc(%ebp)
8010254f:	ff 75 0c             	pushl  0xc(%ebp)
80102552:	e8 e8 30 00 00       	call   8010563f <memmove>
80102557:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010255a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010255d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102560:	01 d0                	add    %edx,%eax
80102562:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102565:	eb 04                	jmp    8010256b <skipelem+0x95>
    path++;
80102567:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010256b:	8b 45 08             	mov    0x8(%ebp),%eax
8010256e:	0f b6 00             	movzbl (%eax),%eax
80102571:	3c 2f                	cmp    $0x2f,%al
80102573:	74 f2                	je     80102567 <skipelem+0x91>
  return path;
80102575:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102578:	c9                   	leave  
80102579:	c3                   	ret    

8010257a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010257a:	f3 0f 1e fb          	endbr32 
8010257e:	55                   	push   %ebp
8010257f:	89 e5                	mov    %esp,%ebp
80102581:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102584:	8b 45 08             	mov    0x8(%ebp),%eax
80102587:	0f b6 00             	movzbl (%eax),%eax
8010258a:	3c 2f                	cmp    $0x2f,%al
8010258c:	75 17                	jne    801025a5 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
8010258e:	83 ec 08             	sub    $0x8,%esp
80102591:	6a 01                	push   $0x1
80102593:	6a 01                	push   $0x1
80102595:	e8 74 f4 ff ff       	call   80101a0e <iget>
8010259a:	83 c4 10             	add    $0x10,%esp
8010259d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801025a0:	e9 ba 00 00 00       	jmp    8010265f <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
801025a5:	e8 16 1f 00 00       	call   801044c0 <myproc>
801025aa:	8b 40 68             	mov    0x68(%eax),%eax
801025ad:	83 ec 0c             	sub    $0xc,%esp
801025b0:	50                   	push   %eax
801025b1:	e8 3e f5 ff ff       	call   80101af4 <idup>
801025b6:	83 c4 10             	add    $0x10,%esp
801025b9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801025bc:	e9 9e 00 00 00       	jmp    8010265f <namex+0xe5>
    ilock(ip);
801025c1:	83 ec 0c             	sub    $0xc,%esp
801025c4:	ff 75 f4             	pushl  -0xc(%ebp)
801025c7:	e8 66 f5 ff ff       	call   80101b32 <ilock>
801025cc:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801025cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025d2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801025d6:	66 83 f8 01          	cmp    $0x1,%ax
801025da:	74 18                	je     801025f4 <namex+0x7a>
      iunlockput(ip);
801025dc:	83 ec 0c             	sub    $0xc,%esp
801025df:	ff 75 f4             	pushl  -0xc(%ebp)
801025e2:	e8 88 f7 ff ff       	call   80101d6f <iunlockput>
801025e7:	83 c4 10             	add    $0x10,%esp
      return 0;
801025ea:	b8 00 00 00 00       	mov    $0x0,%eax
801025ef:	e9 a7 00 00 00       	jmp    8010269b <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
801025f4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025f8:	74 20                	je     8010261a <namex+0xa0>
801025fa:	8b 45 08             	mov    0x8(%ebp),%eax
801025fd:	0f b6 00             	movzbl (%eax),%eax
80102600:	84 c0                	test   %al,%al
80102602:	75 16                	jne    8010261a <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
80102604:	83 ec 0c             	sub    $0xc,%esp
80102607:	ff 75 f4             	pushl  -0xc(%ebp)
8010260a:	e8 3a f6 ff ff       	call   80101c49 <iunlock>
8010260f:	83 c4 10             	add    $0x10,%esp
      return ip;
80102612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102615:	e9 81 00 00 00       	jmp    8010269b <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010261a:	83 ec 04             	sub    $0x4,%esp
8010261d:	6a 00                	push   $0x0
8010261f:	ff 75 10             	pushl  0x10(%ebp)
80102622:	ff 75 f4             	pushl  -0xc(%ebp)
80102625:	e8 12 fd ff ff       	call   8010233c <dirlookup>
8010262a:	83 c4 10             	add    $0x10,%esp
8010262d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102630:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102634:	75 15                	jne    8010264b <namex+0xd1>
      iunlockput(ip);
80102636:	83 ec 0c             	sub    $0xc,%esp
80102639:	ff 75 f4             	pushl  -0xc(%ebp)
8010263c:	e8 2e f7 ff ff       	call   80101d6f <iunlockput>
80102641:	83 c4 10             	add    $0x10,%esp
      return 0;
80102644:	b8 00 00 00 00       	mov    $0x0,%eax
80102649:	eb 50                	jmp    8010269b <namex+0x121>
    }
    iunlockput(ip);
8010264b:	83 ec 0c             	sub    $0xc,%esp
8010264e:	ff 75 f4             	pushl  -0xc(%ebp)
80102651:	e8 19 f7 ff ff       	call   80101d6f <iunlockput>
80102656:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102659:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010265c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
8010265f:	83 ec 08             	sub    $0x8,%esp
80102662:	ff 75 10             	pushl  0x10(%ebp)
80102665:	ff 75 08             	pushl  0x8(%ebp)
80102668:	e8 69 fe ff ff       	call   801024d6 <skipelem>
8010266d:	83 c4 10             	add    $0x10,%esp
80102670:	89 45 08             	mov    %eax,0x8(%ebp)
80102673:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102677:	0f 85 44 ff ff ff    	jne    801025c1 <namex+0x47>
  }
  if(nameiparent){
8010267d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102681:	74 15                	je     80102698 <namex+0x11e>
    iput(ip);
80102683:	83 ec 0c             	sub    $0xc,%esp
80102686:	ff 75 f4             	pushl  -0xc(%ebp)
80102689:	e8 0d f6 ff ff       	call   80101c9b <iput>
8010268e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102691:	b8 00 00 00 00       	mov    $0x0,%eax
80102696:	eb 03                	jmp    8010269b <namex+0x121>
  }
  return ip;
80102698:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010269b:	c9                   	leave  
8010269c:	c3                   	ret    

8010269d <namei>:

struct inode*
namei(char *path)
{
8010269d:	f3 0f 1e fb          	endbr32 
801026a1:	55                   	push   %ebp
801026a2:	89 e5                	mov    %esp,%ebp
801026a4:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801026a7:	83 ec 04             	sub    $0x4,%esp
801026aa:	8d 45 ea             	lea    -0x16(%ebp),%eax
801026ad:	50                   	push   %eax
801026ae:	6a 00                	push   $0x0
801026b0:	ff 75 08             	pushl  0x8(%ebp)
801026b3:	e8 c2 fe ff ff       	call   8010257a <namex>
801026b8:	83 c4 10             	add    $0x10,%esp
}
801026bb:	c9                   	leave  
801026bc:	c3                   	ret    

801026bd <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801026bd:	f3 0f 1e fb          	endbr32 
801026c1:	55                   	push   %ebp
801026c2:	89 e5                	mov    %esp,%ebp
801026c4:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801026c7:	83 ec 04             	sub    $0x4,%esp
801026ca:	ff 75 0c             	pushl  0xc(%ebp)
801026cd:	6a 01                	push   $0x1
801026cf:	ff 75 08             	pushl  0x8(%ebp)
801026d2:	e8 a3 fe ff ff       	call   8010257a <namex>
801026d7:	83 c4 10             	add    $0x10,%esp
}
801026da:	c9                   	leave  
801026db:	c3                   	ret    

801026dc <inb>:
{
801026dc:	55                   	push   %ebp
801026dd:	89 e5                	mov    %esp,%ebp
801026df:	83 ec 14             	sub    $0x14,%esp
801026e2:	8b 45 08             	mov    0x8(%ebp),%eax
801026e5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801026e9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801026ed:	89 c2                	mov    %eax,%edx
801026ef:	ec                   	in     (%dx),%al
801026f0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801026f3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801026f7:	c9                   	leave  
801026f8:	c3                   	ret    

801026f9 <insl>:
{
801026f9:	55                   	push   %ebp
801026fa:	89 e5                	mov    %esp,%ebp
801026fc:	57                   	push   %edi
801026fd:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801026fe:	8b 55 08             	mov    0x8(%ebp),%edx
80102701:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102704:	8b 45 10             	mov    0x10(%ebp),%eax
80102707:	89 cb                	mov    %ecx,%ebx
80102709:	89 df                	mov    %ebx,%edi
8010270b:	89 c1                	mov    %eax,%ecx
8010270d:	fc                   	cld    
8010270e:	f3 6d                	rep insl (%dx),%es:(%edi)
80102710:	89 c8                	mov    %ecx,%eax
80102712:	89 fb                	mov    %edi,%ebx
80102714:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102717:	89 45 10             	mov    %eax,0x10(%ebp)
}
8010271a:	90                   	nop
8010271b:	5b                   	pop    %ebx
8010271c:	5f                   	pop    %edi
8010271d:	5d                   	pop    %ebp
8010271e:	c3                   	ret    

8010271f <outb>:
{
8010271f:	55                   	push   %ebp
80102720:	89 e5                	mov    %esp,%ebp
80102722:	83 ec 08             	sub    $0x8,%esp
80102725:	8b 45 08             	mov    0x8(%ebp),%eax
80102728:	8b 55 0c             	mov    0xc(%ebp),%edx
8010272b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010272f:	89 d0                	mov    %edx,%eax
80102731:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102734:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102738:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010273c:	ee                   	out    %al,(%dx)
}
8010273d:	90                   	nop
8010273e:	c9                   	leave  
8010273f:	c3                   	ret    

80102740 <outsl>:
{
80102740:	55                   	push   %ebp
80102741:	89 e5                	mov    %esp,%ebp
80102743:	56                   	push   %esi
80102744:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102745:	8b 55 08             	mov    0x8(%ebp),%edx
80102748:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010274b:	8b 45 10             	mov    0x10(%ebp),%eax
8010274e:	89 cb                	mov    %ecx,%ebx
80102750:	89 de                	mov    %ebx,%esi
80102752:	89 c1                	mov    %eax,%ecx
80102754:	fc                   	cld    
80102755:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102757:	89 c8                	mov    %ecx,%eax
80102759:	89 f3                	mov    %esi,%ebx
8010275b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010275e:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102761:	90                   	nop
80102762:	5b                   	pop    %ebx
80102763:	5e                   	pop    %esi
80102764:	5d                   	pop    %ebp
80102765:	c3                   	ret    

80102766 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102766:	f3 0f 1e fb          	endbr32 
8010276a:	55                   	push   %ebp
8010276b:	89 e5                	mov    %esp,%ebp
8010276d:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102770:	90                   	nop
80102771:	68 f7 01 00 00       	push   $0x1f7
80102776:	e8 61 ff ff ff       	call   801026dc <inb>
8010277b:	83 c4 04             	add    $0x4,%esp
8010277e:	0f b6 c0             	movzbl %al,%eax
80102781:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102784:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102787:	25 c0 00 00 00       	and    $0xc0,%eax
8010278c:	83 f8 40             	cmp    $0x40,%eax
8010278f:	75 e0                	jne    80102771 <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102791:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102795:	74 11                	je     801027a8 <idewait+0x42>
80102797:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010279a:	83 e0 21             	and    $0x21,%eax
8010279d:	85 c0                	test   %eax,%eax
8010279f:	74 07                	je     801027a8 <idewait+0x42>
    return -1;
801027a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027a6:	eb 05                	jmp    801027ad <idewait+0x47>
  return 0;
801027a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801027ad:	c9                   	leave  
801027ae:	c3                   	ret    

801027af <ideinit>:

void
ideinit(void)
{
801027af:	f3 0f 1e fb          	endbr32 
801027b3:	55                   	push   %ebp
801027b4:	89 e5                	mov    %esp,%ebp
801027b6:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801027b9:	83 ec 08             	sub    $0x8,%esp
801027bc:	68 5f 95 10 80       	push   $0x8010955f
801027c1:	68 00 c6 10 80       	push   $0x8010c600
801027c6:	e8 e8 2a 00 00       	call   801052b3 <initlock>
801027cb:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801027ce:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
801027d3:	83 e8 01             	sub    $0x1,%eax
801027d6:	83 ec 08             	sub    $0x8,%esp
801027d9:	50                   	push   %eax
801027da:	6a 0e                	push   $0xe
801027dc:	e8 bb 04 00 00       	call   80102c9c <ioapicenable>
801027e1:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801027e4:	83 ec 0c             	sub    $0xc,%esp
801027e7:	6a 00                	push   $0x0
801027e9:	e8 78 ff ff ff       	call   80102766 <idewait>
801027ee:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801027f1:	83 ec 08             	sub    $0x8,%esp
801027f4:	68 f0 00 00 00       	push   $0xf0
801027f9:	68 f6 01 00 00       	push   $0x1f6
801027fe:	e8 1c ff ff ff       	call   8010271f <outb>
80102803:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102806:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010280d:	eb 24                	jmp    80102833 <ideinit+0x84>
    if(inb(0x1f7) != 0){
8010280f:	83 ec 0c             	sub    $0xc,%esp
80102812:	68 f7 01 00 00       	push   $0x1f7
80102817:	e8 c0 fe ff ff       	call   801026dc <inb>
8010281c:	83 c4 10             	add    $0x10,%esp
8010281f:	84 c0                	test   %al,%al
80102821:	74 0c                	je     8010282f <ideinit+0x80>
      havedisk1 = 1;
80102823:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
8010282a:	00 00 00 
      break;
8010282d:	eb 0d                	jmp    8010283c <ideinit+0x8d>
  for(i=0; i<1000; i++){
8010282f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102833:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010283a:	7e d3                	jle    8010280f <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010283c:	83 ec 08             	sub    $0x8,%esp
8010283f:	68 e0 00 00 00       	push   $0xe0
80102844:	68 f6 01 00 00       	push   $0x1f6
80102849:	e8 d1 fe ff ff       	call   8010271f <outb>
8010284e:	83 c4 10             	add    $0x10,%esp
}
80102851:	90                   	nop
80102852:	c9                   	leave  
80102853:	c3                   	ret    

80102854 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102854:	f3 0f 1e fb          	endbr32 
80102858:	55                   	push   %ebp
80102859:	89 e5                	mov    %esp,%ebp
8010285b:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010285e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102862:	75 0d                	jne    80102871 <idestart+0x1d>
    panic("idestart");
80102864:	83 ec 0c             	sub    $0xc,%esp
80102867:	68 63 95 10 80       	push   $0x80109563
8010286c:	e8 97 dd ff ff       	call   80100608 <panic>
  if(b->blockno >= FSSIZE)
80102871:	8b 45 08             	mov    0x8(%ebp),%eax
80102874:	8b 40 08             	mov    0x8(%eax),%eax
80102877:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010287c:	76 0d                	jbe    8010288b <idestart+0x37>
    panic("incorrect blockno");
8010287e:	83 ec 0c             	sub    $0xc,%esp
80102881:	68 6c 95 10 80       	push   $0x8010956c
80102886:	e8 7d dd ff ff       	call   80100608 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010288b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102892:	8b 45 08             	mov    0x8(%ebp),%eax
80102895:	8b 50 08             	mov    0x8(%eax),%edx
80102898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010289b:	0f af c2             	imul   %edx,%eax
8010289e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801028a1:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028a5:	75 07                	jne    801028ae <idestart+0x5a>
801028a7:	b8 20 00 00 00       	mov    $0x20,%eax
801028ac:	eb 05                	jmp    801028b3 <idestart+0x5f>
801028ae:	b8 c4 00 00 00       	mov    $0xc4,%eax
801028b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801028b6:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028ba:	75 07                	jne    801028c3 <idestart+0x6f>
801028bc:	b8 30 00 00 00       	mov    $0x30,%eax
801028c1:	eb 05                	jmp    801028c8 <idestart+0x74>
801028c3:	b8 c5 00 00 00       	mov    $0xc5,%eax
801028c8:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801028cb:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801028cf:	7e 0d                	jle    801028de <idestart+0x8a>
801028d1:	83 ec 0c             	sub    $0xc,%esp
801028d4:	68 63 95 10 80       	push   $0x80109563
801028d9:	e8 2a dd ff ff       	call   80100608 <panic>

  idewait(0);
801028de:	83 ec 0c             	sub    $0xc,%esp
801028e1:	6a 00                	push   $0x0
801028e3:	e8 7e fe ff ff       	call   80102766 <idewait>
801028e8:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801028eb:	83 ec 08             	sub    $0x8,%esp
801028ee:	6a 00                	push   $0x0
801028f0:	68 f6 03 00 00       	push   $0x3f6
801028f5:	e8 25 fe ff ff       	call   8010271f <outb>
801028fa:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
801028fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102900:	0f b6 c0             	movzbl %al,%eax
80102903:	83 ec 08             	sub    $0x8,%esp
80102906:	50                   	push   %eax
80102907:	68 f2 01 00 00       	push   $0x1f2
8010290c:	e8 0e fe ff ff       	call   8010271f <outb>
80102911:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102914:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102917:	0f b6 c0             	movzbl %al,%eax
8010291a:	83 ec 08             	sub    $0x8,%esp
8010291d:	50                   	push   %eax
8010291e:	68 f3 01 00 00       	push   $0x1f3
80102923:	e8 f7 fd ff ff       	call   8010271f <outb>
80102928:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
8010292b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010292e:	c1 f8 08             	sar    $0x8,%eax
80102931:	0f b6 c0             	movzbl %al,%eax
80102934:	83 ec 08             	sub    $0x8,%esp
80102937:	50                   	push   %eax
80102938:	68 f4 01 00 00       	push   $0x1f4
8010293d:	e8 dd fd ff ff       	call   8010271f <outb>
80102942:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102945:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102948:	c1 f8 10             	sar    $0x10,%eax
8010294b:	0f b6 c0             	movzbl %al,%eax
8010294e:	83 ec 08             	sub    $0x8,%esp
80102951:	50                   	push   %eax
80102952:	68 f5 01 00 00       	push   $0x1f5
80102957:	e8 c3 fd ff ff       	call   8010271f <outb>
8010295c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010295f:	8b 45 08             	mov    0x8(%ebp),%eax
80102962:	8b 40 04             	mov    0x4(%eax),%eax
80102965:	c1 e0 04             	shl    $0x4,%eax
80102968:	83 e0 10             	and    $0x10,%eax
8010296b:	89 c2                	mov    %eax,%edx
8010296d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102970:	c1 f8 18             	sar    $0x18,%eax
80102973:	83 e0 0f             	and    $0xf,%eax
80102976:	09 d0                	or     %edx,%eax
80102978:	83 c8 e0             	or     $0xffffffe0,%eax
8010297b:	0f b6 c0             	movzbl %al,%eax
8010297e:	83 ec 08             	sub    $0x8,%esp
80102981:	50                   	push   %eax
80102982:	68 f6 01 00 00       	push   $0x1f6
80102987:	e8 93 fd ff ff       	call   8010271f <outb>
8010298c:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
8010298f:	8b 45 08             	mov    0x8(%ebp),%eax
80102992:	8b 00                	mov    (%eax),%eax
80102994:	83 e0 04             	and    $0x4,%eax
80102997:	85 c0                	test   %eax,%eax
80102999:	74 35                	je     801029d0 <idestart+0x17c>
    outb(0x1f7, write_cmd);
8010299b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010299e:	0f b6 c0             	movzbl %al,%eax
801029a1:	83 ec 08             	sub    $0x8,%esp
801029a4:	50                   	push   %eax
801029a5:	68 f7 01 00 00       	push   $0x1f7
801029aa:	e8 70 fd ff ff       	call   8010271f <outb>
801029af:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801029b2:	8b 45 08             	mov    0x8(%ebp),%eax
801029b5:	83 c0 5c             	add    $0x5c,%eax
801029b8:	83 ec 04             	sub    $0x4,%esp
801029bb:	68 80 00 00 00       	push   $0x80
801029c0:	50                   	push   %eax
801029c1:	68 f0 01 00 00       	push   $0x1f0
801029c6:	e8 75 fd ff ff       	call   80102740 <outsl>
801029cb:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
801029ce:	eb 17                	jmp    801029e7 <idestart+0x193>
    outb(0x1f7, read_cmd);
801029d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801029d3:	0f b6 c0             	movzbl %al,%eax
801029d6:	83 ec 08             	sub    $0x8,%esp
801029d9:	50                   	push   %eax
801029da:	68 f7 01 00 00       	push   $0x1f7
801029df:	e8 3b fd ff ff       	call   8010271f <outb>
801029e4:	83 c4 10             	add    $0x10,%esp
}
801029e7:	90                   	nop
801029e8:	c9                   	leave  
801029e9:	c3                   	ret    

801029ea <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801029ea:	f3 0f 1e fb          	endbr32 
801029ee:	55                   	push   %ebp
801029ef:	89 e5                	mov    %esp,%ebp
801029f1:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801029f4:	83 ec 0c             	sub    $0xc,%esp
801029f7:	68 00 c6 10 80       	push   $0x8010c600
801029fc:	e8 d8 28 00 00       	call   801052d9 <acquire>
80102a01:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102a04:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a10:	75 15                	jne    80102a27 <ideintr+0x3d>
    release(&idelock);
80102a12:	83 ec 0c             	sub    $0xc,%esp
80102a15:	68 00 c6 10 80       	push   $0x8010c600
80102a1a:	e8 2c 29 00 00       	call   8010534b <release>
80102a1f:	83 c4 10             	add    $0x10,%esp
    return;
80102a22:	e9 9a 00 00 00       	jmp    80102ac1 <ideintr+0xd7>
  }
  idequeue = b->qnext;
80102a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a2a:	8b 40 58             	mov    0x58(%eax),%eax
80102a2d:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a35:	8b 00                	mov    (%eax),%eax
80102a37:	83 e0 04             	and    $0x4,%eax
80102a3a:	85 c0                	test   %eax,%eax
80102a3c:	75 2d                	jne    80102a6b <ideintr+0x81>
80102a3e:	83 ec 0c             	sub    $0xc,%esp
80102a41:	6a 01                	push   $0x1
80102a43:	e8 1e fd ff ff       	call   80102766 <idewait>
80102a48:	83 c4 10             	add    $0x10,%esp
80102a4b:	85 c0                	test   %eax,%eax
80102a4d:	78 1c                	js     80102a6b <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a52:	83 c0 5c             	add    $0x5c,%eax
80102a55:	83 ec 04             	sub    $0x4,%esp
80102a58:	68 80 00 00 00       	push   $0x80
80102a5d:	50                   	push   %eax
80102a5e:	68 f0 01 00 00       	push   $0x1f0
80102a63:	e8 91 fc ff ff       	call   801026f9 <insl>
80102a68:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a6e:	8b 00                	mov    (%eax),%eax
80102a70:	83 c8 02             	or     $0x2,%eax
80102a73:	89 c2                	mov    %eax,%edx
80102a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a78:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a7d:	8b 00                	mov    (%eax),%eax
80102a7f:	83 e0 fb             	and    $0xfffffffb,%eax
80102a82:	89 c2                	mov    %eax,%edx
80102a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a87:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102a89:	83 ec 0c             	sub    $0xc,%esp
80102a8c:	ff 75 f4             	pushl  -0xc(%ebp)
80102a8f:	e8 c5 24 00 00       	call   80104f59 <wakeup>
80102a94:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102a97:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a9c:	85 c0                	test   %eax,%eax
80102a9e:	74 11                	je     80102ab1 <ideintr+0xc7>
    idestart(idequeue);
80102aa0:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102aa5:	83 ec 0c             	sub    $0xc,%esp
80102aa8:	50                   	push   %eax
80102aa9:	e8 a6 fd ff ff       	call   80102854 <idestart>
80102aae:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102ab1:	83 ec 0c             	sub    $0xc,%esp
80102ab4:	68 00 c6 10 80       	push   $0x8010c600
80102ab9:	e8 8d 28 00 00       	call   8010534b <release>
80102abe:	83 c4 10             	add    $0x10,%esp
}
80102ac1:	c9                   	leave  
80102ac2:	c3                   	ret    

80102ac3 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102ac3:	f3 0f 1e fb          	endbr32 
80102ac7:	55                   	push   %ebp
80102ac8:	89 e5                	mov    %esp,%ebp
80102aca:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102acd:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad0:	83 c0 0c             	add    $0xc,%eax
80102ad3:	83 ec 0c             	sub    $0xc,%esp
80102ad6:	50                   	push   %eax
80102ad7:	e8 3e 27 00 00       	call   8010521a <holdingsleep>
80102adc:	83 c4 10             	add    $0x10,%esp
80102adf:	85 c0                	test   %eax,%eax
80102ae1:	75 0d                	jne    80102af0 <iderw+0x2d>
    panic("iderw: buf not locked");
80102ae3:	83 ec 0c             	sub    $0xc,%esp
80102ae6:	68 7e 95 10 80       	push   $0x8010957e
80102aeb:	e8 18 db ff ff       	call   80100608 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102af0:	8b 45 08             	mov    0x8(%ebp),%eax
80102af3:	8b 00                	mov    (%eax),%eax
80102af5:	83 e0 06             	and    $0x6,%eax
80102af8:	83 f8 02             	cmp    $0x2,%eax
80102afb:	75 0d                	jne    80102b0a <iderw+0x47>
    panic("iderw: nothing to do");
80102afd:	83 ec 0c             	sub    $0xc,%esp
80102b00:	68 94 95 10 80       	push   $0x80109594
80102b05:	e8 fe da ff ff       	call   80100608 <panic>
  if(b->dev != 0 && !havedisk1)
80102b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0d:	8b 40 04             	mov    0x4(%eax),%eax
80102b10:	85 c0                	test   %eax,%eax
80102b12:	74 16                	je     80102b2a <iderw+0x67>
80102b14:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102b19:	85 c0                	test   %eax,%eax
80102b1b:	75 0d                	jne    80102b2a <iderw+0x67>
    panic("iderw: ide disk 1 not present");
80102b1d:	83 ec 0c             	sub    $0xc,%esp
80102b20:	68 a9 95 10 80       	push   $0x801095a9
80102b25:	e8 de da ff ff       	call   80100608 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b2a:	83 ec 0c             	sub    $0xc,%esp
80102b2d:	68 00 c6 10 80       	push   $0x8010c600
80102b32:	e8 a2 27 00 00       	call   801052d9 <acquire>
80102b37:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3d:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b44:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102b4b:	eb 0b                	jmp    80102b58 <iderw+0x95>
80102b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b50:	8b 00                	mov    (%eax),%eax
80102b52:	83 c0 58             	add    $0x58,%eax
80102b55:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b5b:	8b 00                	mov    (%eax),%eax
80102b5d:	85 c0                	test   %eax,%eax
80102b5f:	75 ec                	jne    80102b4d <iderw+0x8a>
    ;
  *pp = b;
80102b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b64:	8b 55 08             	mov    0x8(%ebp),%edx
80102b67:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102b69:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102b6e:	39 45 08             	cmp    %eax,0x8(%ebp)
80102b71:	75 23                	jne    80102b96 <iderw+0xd3>
    idestart(b);
80102b73:	83 ec 0c             	sub    $0xc,%esp
80102b76:	ff 75 08             	pushl  0x8(%ebp)
80102b79:	e8 d6 fc ff ff       	call   80102854 <idestart>
80102b7e:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b81:	eb 13                	jmp    80102b96 <iderw+0xd3>
    sleep(b, &idelock);
80102b83:	83 ec 08             	sub    $0x8,%esp
80102b86:	68 00 c6 10 80       	push   $0x8010c600
80102b8b:	ff 75 08             	pushl  0x8(%ebp)
80102b8e:	e8 d4 22 00 00       	call   80104e67 <sleep>
80102b93:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b96:	8b 45 08             	mov    0x8(%ebp),%eax
80102b99:	8b 00                	mov    (%eax),%eax
80102b9b:	83 e0 06             	and    $0x6,%eax
80102b9e:	83 f8 02             	cmp    $0x2,%eax
80102ba1:	75 e0                	jne    80102b83 <iderw+0xc0>
  }


  release(&idelock);
80102ba3:	83 ec 0c             	sub    $0xc,%esp
80102ba6:	68 00 c6 10 80       	push   $0x8010c600
80102bab:	e8 9b 27 00 00       	call   8010534b <release>
80102bb0:	83 c4 10             	add    $0x10,%esp
}
80102bb3:	90                   	nop
80102bb4:	c9                   	leave  
80102bb5:	c3                   	ret    

80102bb6 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102bb6:	f3 0f 1e fb          	endbr32 
80102bba:	55                   	push   %ebp
80102bbb:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bbd:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bc2:	8b 55 08             	mov    0x8(%ebp),%edx
80102bc5:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102bc7:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bcc:	8b 40 10             	mov    0x10(%eax),%eax
}
80102bcf:	5d                   	pop    %ebp
80102bd0:	c3                   	ret    

80102bd1 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102bd1:	f3 0f 1e fb          	endbr32 
80102bd5:	55                   	push   %ebp
80102bd6:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bd8:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bdd:	8b 55 08             	mov    0x8(%ebp),%edx
80102be0:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102be2:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102be7:	8b 55 0c             	mov    0xc(%ebp),%edx
80102bea:	89 50 10             	mov    %edx,0x10(%eax)
}
80102bed:	90                   	nop
80102bee:	5d                   	pop    %ebp
80102bef:	c3                   	ret    

80102bf0 <ioapicinit>:

void
ioapicinit(void)
{
80102bf0:	f3 0f 1e fb          	endbr32 
80102bf4:	55                   	push   %ebp
80102bf5:	89 e5                	mov    %esp,%ebp
80102bf7:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102bfa:	c7 05 d4 46 11 80 00 	movl   $0xfec00000,0x801146d4
80102c01:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c04:	6a 01                	push   $0x1
80102c06:	e8 ab ff ff ff       	call   80102bb6 <ioapicread>
80102c0b:	83 c4 04             	add    $0x4,%esp
80102c0e:	c1 e8 10             	shr    $0x10,%eax
80102c11:	25 ff 00 00 00       	and    $0xff,%eax
80102c16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c19:	6a 00                	push   $0x0
80102c1b:	e8 96 ff ff ff       	call   80102bb6 <ioapicread>
80102c20:	83 c4 04             	add    $0x4,%esp
80102c23:	c1 e8 18             	shr    $0x18,%eax
80102c26:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c29:	0f b6 05 00 48 11 80 	movzbl 0x80114800,%eax
80102c30:	0f b6 c0             	movzbl %al,%eax
80102c33:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102c36:	74 10                	je     80102c48 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c38:	83 ec 0c             	sub    $0xc,%esp
80102c3b:	68 c8 95 10 80       	push   $0x801095c8
80102c40:	e8 d3 d7 ff ff       	call   80100418 <cprintf>
80102c45:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c4f:	eb 3f                	jmp    80102c90 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c54:	83 c0 20             	add    $0x20,%eax
80102c57:	0d 00 00 01 00       	or     $0x10000,%eax
80102c5c:	89 c2                	mov    %eax,%edx
80102c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c61:	83 c0 08             	add    $0x8,%eax
80102c64:	01 c0                	add    %eax,%eax
80102c66:	83 ec 08             	sub    $0x8,%esp
80102c69:	52                   	push   %edx
80102c6a:	50                   	push   %eax
80102c6b:	e8 61 ff ff ff       	call   80102bd1 <ioapicwrite>
80102c70:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c76:	83 c0 08             	add    $0x8,%eax
80102c79:	01 c0                	add    %eax,%eax
80102c7b:	83 c0 01             	add    $0x1,%eax
80102c7e:	83 ec 08             	sub    $0x8,%esp
80102c81:	6a 00                	push   $0x0
80102c83:	50                   	push   %eax
80102c84:	e8 48 ff ff ff       	call   80102bd1 <ioapicwrite>
80102c89:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102c8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c93:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c96:	7e b9                	jle    80102c51 <ioapicinit+0x61>
  }
}
80102c98:	90                   	nop
80102c99:	90                   	nop
80102c9a:	c9                   	leave  
80102c9b:	c3                   	ret    

80102c9c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c9c:	f3 0f 1e fb          	endbr32 
80102ca0:	55                   	push   %ebp
80102ca1:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca6:	83 c0 20             	add    $0x20,%eax
80102ca9:	89 c2                	mov    %eax,%edx
80102cab:	8b 45 08             	mov    0x8(%ebp),%eax
80102cae:	83 c0 08             	add    $0x8,%eax
80102cb1:	01 c0                	add    %eax,%eax
80102cb3:	52                   	push   %edx
80102cb4:	50                   	push   %eax
80102cb5:	e8 17 ff ff ff       	call   80102bd1 <ioapicwrite>
80102cba:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102cbd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cc0:	c1 e0 18             	shl    $0x18,%eax
80102cc3:	89 c2                	mov    %eax,%edx
80102cc5:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc8:	83 c0 08             	add    $0x8,%eax
80102ccb:	01 c0                	add    %eax,%eax
80102ccd:	83 c0 01             	add    $0x1,%eax
80102cd0:	52                   	push   %edx
80102cd1:	50                   	push   %eax
80102cd2:	e8 fa fe ff ff       	call   80102bd1 <ioapicwrite>
80102cd7:	83 c4 08             	add    $0x8,%esp
}
80102cda:	90                   	nop
80102cdb:	c9                   	leave  
80102cdc:	c3                   	ret    

80102cdd <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102cdd:	f3 0f 1e fb          	endbr32 
80102ce1:	55                   	push   %ebp
80102ce2:	89 e5                	mov    %esp,%ebp
80102ce4:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102ce7:	83 ec 08             	sub    $0x8,%esp
80102cea:	68 fa 95 10 80       	push   $0x801095fa
80102cef:	68 e0 46 11 80       	push   $0x801146e0
80102cf4:	e8 ba 25 00 00       	call   801052b3 <initlock>
80102cf9:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102cfc:	c7 05 14 47 11 80 00 	movl   $0x0,0x80114714
80102d03:	00 00 00 
  freerange(vstart, vend);
80102d06:	83 ec 08             	sub    $0x8,%esp
80102d09:	ff 75 0c             	pushl  0xc(%ebp)
80102d0c:	ff 75 08             	pushl  0x8(%ebp)
80102d0f:	e8 2e 00 00 00       	call   80102d42 <freerange>
80102d14:	83 c4 10             	add    $0x10,%esp
}
80102d17:	90                   	nop
80102d18:	c9                   	leave  
80102d19:	c3                   	ret    

80102d1a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d1a:	f3 0f 1e fb          	endbr32 
80102d1e:	55                   	push   %ebp
80102d1f:	89 e5                	mov    %esp,%ebp
80102d21:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102d24:	83 ec 08             	sub    $0x8,%esp
80102d27:	ff 75 0c             	pushl  0xc(%ebp)
80102d2a:	ff 75 08             	pushl  0x8(%ebp)
80102d2d:	e8 10 00 00 00       	call   80102d42 <freerange>
80102d32:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102d35:	c7 05 14 47 11 80 01 	movl   $0x1,0x80114714
80102d3c:	00 00 00 
}
80102d3f:	90                   	nop
80102d40:	c9                   	leave  
80102d41:	c3                   	ret    

80102d42 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d42:	f3 0f 1e fb          	endbr32 
80102d46:	55                   	push   %ebp
80102d47:	89 e5                	mov    %esp,%ebp
80102d49:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d4c:	8b 45 08             	mov    0x8(%ebp),%eax
80102d4f:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d54:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d59:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d5c:	eb 15                	jmp    80102d73 <freerange+0x31>
    kfree(p);
80102d5e:	83 ec 0c             	sub    $0xc,%esp
80102d61:	ff 75 f4             	pushl  -0xc(%ebp)
80102d64:	e8 1b 00 00 00       	call   80102d84 <kfree>
80102d69:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d6c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d76:	05 00 10 00 00       	add    $0x1000,%eax
80102d7b:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102d7e:	73 de                	jae    80102d5e <freerange+0x1c>
}
80102d80:	90                   	nop
80102d81:	90                   	nop
80102d82:	c9                   	leave  
80102d83:	c3                   	ret    

80102d84 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d84:	f3 0f 1e fb          	endbr32 
80102d88:	55                   	push   %ebp
80102d89:	89 e5                	mov    %esp,%ebp
80102d8b:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80102d91:	25 ff 0f 00 00       	and    $0xfff,%eax
80102d96:	85 c0                	test   %eax,%eax
80102d98:	75 18                	jne    80102db2 <kfree+0x2e>
80102d9a:	81 7d 08 48 88 11 80 	cmpl   $0x80118848,0x8(%ebp)
80102da1:	72 0f                	jb     80102db2 <kfree+0x2e>
80102da3:	8b 45 08             	mov    0x8(%ebp),%eax
80102da6:	05 00 00 00 80       	add    $0x80000000,%eax
80102dab:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102db0:	76 0d                	jbe    80102dbf <kfree+0x3b>
    panic("kfree");
80102db2:	83 ec 0c             	sub    $0xc,%esp
80102db5:	68 ff 95 10 80       	push   $0x801095ff
80102dba:	e8 49 d8 ff ff       	call   80100608 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102dbf:	83 ec 04             	sub    $0x4,%esp
80102dc2:	68 00 10 00 00       	push   $0x1000
80102dc7:	6a 01                	push   $0x1
80102dc9:	ff 75 08             	pushl  0x8(%ebp)
80102dcc:	e8 a7 27 00 00       	call   80105578 <memset>
80102dd1:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102dd4:	a1 14 47 11 80       	mov    0x80114714,%eax
80102dd9:	85 c0                	test   %eax,%eax
80102ddb:	74 10                	je     80102ded <kfree+0x69>
    acquire(&kmem.lock);
80102ddd:	83 ec 0c             	sub    $0xc,%esp
80102de0:	68 e0 46 11 80       	push   $0x801146e0
80102de5:	e8 ef 24 00 00       	call   801052d9 <acquire>
80102dea:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102ded:	8b 45 08             	mov    0x8(%ebp),%eax
80102df0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102df3:	8b 15 18 47 11 80    	mov    0x80114718,%edx
80102df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dfc:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e01:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102e06:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e0b:	85 c0                	test   %eax,%eax
80102e0d:	74 10                	je     80102e1f <kfree+0x9b>
    release(&kmem.lock);
80102e0f:	83 ec 0c             	sub    $0xc,%esp
80102e12:	68 e0 46 11 80       	push   $0x801146e0
80102e17:	e8 2f 25 00 00       	call   8010534b <release>
80102e1c:	83 c4 10             	add    $0x10,%esp
}
80102e1f:	90                   	nop
80102e20:	c9                   	leave  
80102e21:	c3                   	ret    

80102e22 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e22:	f3 0f 1e fb          	endbr32 
80102e26:	55                   	push   %ebp
80102e27:	89 e5                	mov    %esp,%ebp
80102e29:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102e2c:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e31:	85 c0                	test   %eax,%eax
80102e33:	74 10                	je     80102e45 <kalloc+0x23>
    acquire(&kmem.lock);
80102e35:	83 ec 0c             	sub    $0xc,%esp
80102e38:	68 e0 46 11 80       	push   $0x801146e0
80102e3d:	e8 97 24 00 00       	call   801052d9 <acquire>
80102e42:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102e45:	a1 18 47 11 80       	mov    0x80114718,%eax
80102e4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e4d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e51:	74 0a                	je     80102e5d <kalloc+0x3b>
    kmem.freelist = r->next;
80102e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e56:	8b 00                	mov    (%eax),%eax
80102e58:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102e5d:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e62:	85 c0                	test   %eax,%eax
80102e64:	74 10                	je     80102e76 <kalloc+0x54>
    release(&kmem.lock);
80102e66:	83 ec 0c             	sub    $0xc,%esp
80102e69:	68 e0 46 11 80       	push   $0x801146e0
80102e6e:	e8 d8 24 00 00       	call   8010534b <release>
80102e73:	83 c4 10             	add    $0x10,%esp

  return (char*)r;
80102e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e79:	c9                   	leave  
80102e7a:	c3                   	ret    

80102e7b <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e7b:	55                   	push   %ebp
80102e7c:	89 e5                	mov    %esp,%ebp
80102e7e:	83 ec 14             	sub    $0x14,%esp
80102e81:	8b 45 08             	mov    0x8(%ebp),%eax
80102e84:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e88:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e8c:	89 c2                	mov    %eax,%edx
80102e8e:	ec                   	in     (%dx),%al
80102e8f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e92:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e96:	c9                   	leave  
80102e97:	c3                   	ret    

80102e98 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e98:	f3 0f 1e fb          	endbr32 
80102e9c:	55                   	push   %ebp
80102e9d:	89 e5                	mov    %esp,%ebp
80102e9f:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ea2:	6a 64                	push   $0x64
80102ea4:	e8 d2 ff ff ff       	call   80102e7b <inb>
80102ea9:	83 c4 04             	add    $0x4,%esp
80102eac:	0f b6 c0             	movzbl %al,%eax
80102eaf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eb5:	83 e0 01             	and    $0x1,%eax
80102eb8:	85 c0                	test   %eax,%eax
80102eba:	75 0a                	jne    80102ec6 <kbdgetc+0x2e>
    return -1;
80102ebc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ec1:	e9 23 01 00 00       	jmp    80102fe9 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102ec6:	6a 60                	push   $0x60
80102ec8:	e8 ae ff ff ff       	call   80102e7b <inb>
80102ecd:	83 c4 04             	add    $0x4,%esp
80102ed0:	0f b6 c0             	movzbl %al,%eax
80102ed3:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102ed6:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102edd:	75 17                	jne    80102ef6 <kbdgetc+0x5e>
    shift |= E0ESC;
80102edf:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102ee4:	83 c8 40             	or     $0x40,%eax
80102ee7:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102eec:	b8 00 00 00 00       	mov    $0x0,%eax
80102ef1:	e9 f3 00 00 00       	jmp    80102fe9 <kbdgetc+0x151>
  } else if(data & 0x80){
80102ef6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ef9:	25 80 00 00 00       	and    $0x80,%eax
80102efe:	85 c0                	test   %eax,%eax
80102f00:	74 45                	je     80102f47 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f02:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f07:	83 e0 40             	and    $0x40,%eax
80102f0a:	85 c0                	test   %eax,%eax
80102f0c:	75 08                	jne    80102f16 <kbdgetc+0x7e>
80102f0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f11:	83 e0 7f             	and    $0x7f,%eax
80102f14:	eb 03                	jmp    80102f19 <kbdgetc+0x81>
80102f16:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f19:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f1f:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f24:	0f b6 00             	movzbl (%eax),%eax
80102f27:	83 c8 40             	or     $0x40,%eax
80102f2a:	0f b6 c0             	movzbl %al,%eax
80102f2d:	f7 d0                	not    %eax
80102f2f:	89 c2                	mov    %eax,%edx
80102f31:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f36:	21 d0                	and    %edx,%eax
80102f38:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f3d:	b8 00 00 00 00       	mov    $0x0,%eax
80102f42:	e9 a2 00 00 00       	jmp    80102fe9 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102f47:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f4c:	83 e0 40             	and    $0x40,%eax
80102f4f:	85 c0                	test   %eax,%eax
80102f51:	74 14                	je     80102f67 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f53:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f5a:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f5f:	83 e0 bf             	and    $0xffffffbf,%eax
80102f62:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102f67:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f6a:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f6f:	0f b6 00             	movzbl (%eax),%eax
80102f72:	0f b6 d0             	movzbl %al,%edx
80102f75:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f7a:	09 d0                	or     %edx,%eax
80102f7c:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102f81:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f84:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102f89:	0f b6 00             	movzbl (%eax),%eax
80102f8c:	0f b6 d0             	movzbl %al,%edx
80102f8f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f94:	31 d0                	xor    %edx,%eax
80102f96:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102f9b:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fa0:	83 e0 03             	and    $0x3,%eax
80102fa3:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102faa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fad:	01 d0                	add    %edx,%eax
80102faf:	0f b6 00             	movzbl (%eax),%eax
80102fb2:	0f b6 c0             	movzbl %al,%eax
80102fb5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102fb8:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fbd:	83 e0 08             	and    $0x8,%eax
80102fc0:	85 c0                	test   %eax,%eax
80102fc2:	74 22                	je     80102fe6 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102fc4:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102fc8:	76 0c                	jbe    80102fd6 <kbdgetc+0x13e>
80102fca:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102fce:	77 06                	ja     80102fd6 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102fd0:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102fd4:	eb 10                	jmp    80102fe6 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102fd6:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102fda:	76 0a                	jbe    80102fe6 <kbdgetc+0x14e>
80102fdc:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102fe0:	77 04                	ja     80102fe6 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102fe2:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102fe6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102fe9:	c9                   	leave  
80102fea:	c3                   	ret    

80102feb <kbdintr>:

void
kbdintr(void)
{
80102feb:	f3 0f 1e fb          	endbr32 
80102fef:	55                   	push   %ebp
80102ff0:	89 e5                	mov    %esp,%ebp
80102ff2:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102ff5:	83 ec 0c             	sub    $0xc,%esp
80102ff8:	68 98 2e 10 80       	push   $0x80102e98
80102ffd:	e8 a6 d8 ff ff       	call   801008a8 <consoleintr>
80103002:	83 c4 10             	add    $0x10,%esp
}
80103005:	90                   	nop
80103006:	c9                   	leave  
80103007:	c3                   	ret    

80103008 <inb>:
{
80103008:	55                   	push   %ebp
80103009:	89 e5                	mov    %esp,%ebp
8010300b:	83 ec 14             	sub    $0x14,%esp
8010300e:	8b 45 08             	mov    0x8(%ebp),%eax
80103011:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103015:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103019:	89 c2                	mov    %eax,%edx
8010301b:	ec                   	in     (%dx),%al
8010301c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010301f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103023:	c9                   	leave  
80103024:	c3                   	ret    

80103025 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103025:	55                   	push   %ebp
80103026:	89 e5                	mov    %esp,%ebp
80103028:	83 ec 08             	sub    $0x8,%esp
8010302b:	8b 45 08             	mov    0x8(%ebp),%eax
8010302e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103031:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103035:	89 d0                	mov    %edx,%eax
80103037:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010303a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010303e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103042:	ee                   	out    %al,(%dx)
}
80103043:	90                   	nop
80103044:	c9                   	leave  
80103045:	c3                   	ret    

80103046 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80103046:	f3 0f 1e fb          	endbr32 
8010304a:	55                   	push   %ebp
8010304b:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010304d:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103052:	8b 55 08             	mov    0x8(%ebp),%edx
80103055:	c1 e2 02             	shl    $0x2,%edx
80103058:	01 c2                	add    %eax,%edx
8010305a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010305d:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
8010305f:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103064:	83 c0 20             	add    $0x20,%eax
80103067:	8b 00                	mov    (%eax),%eax
}
80103069:	90                   	nop
8010306a:	5d                   	pop    %ebp
8010306b:	c3                   	ret    

8010306c <lapicinit>:

void
lapicinit(void)
{
8010306c:	f3 0f 1e fb          	endbr32 
80103070:	55                   	push   %ebp
80103071:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80103073:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103078:	85 c0                	test   %eax,%eax
8010307a:	0f 84 0c 01 00 00    	je     8010318c <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103080:	68 3f 01 00 00       	push   $0x13f
80103085:	6a 3c                	push   $0x3c
80103087:	e8 ba ff ff ff       	call   80103046 <lapicw>
8010308c:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
8010308f:	6a 0b                	push   $0xb
80103091:	68 f8 00 00 00       	push   $0xf8
80103096:	e8 ab ff ff ff       	call   80103046 <lapicw>
8010309b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010309e:	68 20 00 02 00       	push   $0x20020
801030a3:	68 c8 00 00 00       	push   $0xc8
801030a8:	e8 99 ff ff ff       	call   80103046 <lapicw>
801030ad:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
801030b0:	68 80 96 98 00       	push   $0x989680
801030b5:	68 e0 00 00 00       	push   $0xe0
801030ba:	e8 87 ff ff ff       	call   80103046 <lapicw>
801030bf:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030c2:	68 00 00 01 00       	push   $0x10000
801030c7:	68 d4 00 00 00       	push   $0xd4
801030cc:	e8 75 ff ff ff       	call   80103046 <lapicw>
801030d1:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
801030d4:	68 00 00 01 00       	push   $0x10000
801030d9:	68 d8 00 00 00       	push   $0xd8
801030de:	e8 63 ff ff ff       	call   80103046 <lapicw>
801030e3:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801030e6:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801030eb:	83 c0 30             	add    $0x30,%eax
801030ee:	8b 00                	mov    (%eax),%eax
801030f0:	c1 e8 10             	shr    $0x10,%eax
801030f3:	25 fc 00 00 00       	and    $0xfc,%eax
801030f8:	85 c0                	test   %eax,%eax
801030fa:	74 12                	je     8010310e <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
801030fc:	68 00 00 01 00       	push   $0x10000
80103101:	68 d0 00 00 00       	push   $0xd0
80103106:	e8 3b ff ff ff       	call   80103046 <lapicw>
8010310b:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010310e:	6a 33                	push   $0x33
80103110:	68 dc 00 00 00       	push   $0xdc
80103115:	e8 2c ff ff ff       	call   80103046 <lapicw>
8010311a:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010311d:	6a 00                	push   $0x0
8010311f:	68 a0 00 00 00       	push   $0xa0
80103124:	e8 1d ff ff ff       	call   80103046 <lapicw>
80103129:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010312c:	6a 00                	push   $0x0
8010312e:	68 a0 00 00 00       	push   $0xa0
80103133:	e8 0e ff ff ff       	call   80103046 <lapicw>
80103138:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010313b:	6a 00                	push   $0x0
8010313d:	6a 2c                	push   $0x2c
8010313f:	e8 02 ff ff ff       	call   80103046 <lapicw>
80103144:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103147:	6a 00                	push   $0x0
80103149:	68 c4 00 00 00       	push   $0xc4
8010314e:	e8 f3 fe ff ff       	call   80103046 <lapicw>
80103153:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103156:	68 00 85 08 00       	push   $0x88500
8010315b:	68 c0 00 00 00       	push   $0xc0
80103160:	e8 e1 fe ff ff       	call   80103046 <lapicw>
80103165:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103168:	90                   	nop
80103169:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010316e:	05 00 03 00 00       	add    $0x300,%eax
80103173:	8b 00                	mov    (%eax),%eax
80103175:	25 00 10 00 00       	and    $0x1000,%eax
8010317a:	85 c0                	test   %eax,%eax
8010317c:	75 eb                	jne    80103169 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010317e:	6a 00                	push   $0x0
80103180:	6a 20                	push   $0x20
80103182:	e8 bf fe ff ff       	call   80103046 <lapicw>
80103187:	83 c4 08             	add    $0x8,%esp
8010318a:	eb 01                	jmp    8010318d <lapicinit+0x121>
    return;
8010318c:	90                   	nop
}
8010318d:	c9                   	leave  
8010318e:	c3                   	ret    

8010318f <lapicid>:

int
lapicid(void)
{
8010318f:	f3 0f 1e fb          	endbr32 
80103193:	55                   	push   %ebp
80103194:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103196:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010319b:	85 c0                	test   %eax,%eax
8010319d:	75 07                	jne    801031a6 <lapicid+0x17>
    return 0;
8010319f:	b8 00 00 00 00       	mov    $0x0,%eax
801031a4:	eb 0d                	jmp    801031b3 <lapicid+0x24>
  return lapic[ID] >> 24;
801031a6:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031ab:	83 c0 20             	add    $0x20,%eax
801031ae:	8b 00                	mov    (%eax),%eax
801031b0:	c1 e8 18             	shr    $0x18,%eax
}
801031b3:	5d                   	pop    %ebp
801031b4:	c3                   	ret    

801031b5 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801031b5:	f3 0f 1e fb          	endbr32 
801031b9:	55                   	push   %ebp
801031ba:	89 e5                	mov    %esp,%ebp
  if(lapic)
801031bc:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031c1:	85 c0                	test   %eax,%eax
801031c3:	74 0c                	je     801031d1 <lapiceoi+0x1c>
    lapicw(EOI, 0);
801031c5:	6a 00                	push   $0x0
801031c7:	6a 2c                	push   $0x2c
801031c9:	e8 78 fe ff ff       	call   80103046 <lapicw>
801031ce:	83 c4 08             	add    $0x8,%esp
}
801031d1:	90                   	nop
801031d2:	c9                   	leave  
801031d3:	c3                   	ret    

801031d4 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801031d4:	f3 0f 1e fb          	endbr32 
801031d8:	55                   	push   %ebp
801031d9:	89 e5                	mov    %esp,%ebp
}
801031db:	90                   	nop
801031dc:	5d                   	pop    %ebp
801031dd:	c3                   	ret    

801031de <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801031de:	f3 0f 1e fb          	endbr32 
801031e2:	55                   	push   %ebp
801031e3:	89 e5                	mov    %esp,%ebp
801031e5:	83 ec 14             	sub    $0x14,%esp
801031e8:	8b 45 08             	mov    0x8(%ebp),%eax
801031eb:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801031ee:	6a 0f                	push   $0xf
801031f0:	6a 70                	push   $0x70
801031f2:	e8 2e fe ff ff       	call   80103025 <outb>
801031f7:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801031fa:	6a 0a                	push   $0xa
801031fc:	6a 71                	push   $0x71
801031fe:	e8 22 fe ff ff       	call   80103025 <outb>
80103203:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103206:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010320d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103210:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103215:	8b 45 0c             	mov    0xc(%ebp),%eax
80103218:	c1 e8 04             	shr    $0x4,%eax
8010321b:	89 c2                	mov    %eax,%edx
8010321d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103220:	83 c0 02             	add    $0x2,%eax
80103223:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103226:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010322a:	c1 e0 18             	shl    $0x18,%eax
8010322d:	50                   	push   %eax
8010322e:	68 c4 00 00 00       	push   $0xc4
80103233:	e8 0e fe ff ff       	call   80103046 <lapicw>
80103238:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010323b:	68 00 c5 00 00       	push   $0xc500
80103240:	68 c0 00 00 00       	push   $0xc0
80103245:	e8 fc fd ff ff       	call   80103046 <lapicw>
8010324a:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010324d:	68 c8 00 00 00       	push   $0xc8
80103252:	e8 7d ff ff ff       	call   801031d4 <microdelay>
80103257:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010325a:	68 00 85 00 00       	push   $0x8500
8010325f:	68 c0 00 00 00       	push   $0xc0
80103264:	e8 dd fd ff ff       	call   80103046 <lapicw>
80103269:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010326c:	6a 64                	push   $0x64
8010326e:	e8 61 ff ff ff       	call   801031d4 <microdelay>
80103273:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103276:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010327d:	eb 3d                	jmp    801032bc <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
8010327f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103283:	c1 e0 18             	shl    $0x18,%eax
80103286:	50                   	push   %eax
80103287:	68 c4 00 00 00       	push   $0xc4
8010328c:	e8 b5 fd ff ff       	call   80103046 <lapicw>
80103291:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103294:	8b 45 0c             	mov    0xc(%ebp),%eax
80103297:	c1 e8 0c             	shr    $0xc,%eax
8010329a:	80 cc 06             	or     $0x6,%ah
8010329d:	50                   	push   %eax
8010329e:	68 c0 00 00 00       	push   $0xc0
801032a3:	e8 9e fd ff ff       	call   80103046 <lapicw>
801032a8:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801032ab:	68 c8 00 00 00       	push   $0xc8
801032b0:	e8 1f ff ff ff       	call   801031d4 <microdelay>
801032b5:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801032b8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801032bc:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801032c0:	7e bd                	jle    8010327f <lapicstartap+0xa1>
  }
}
801032c2:	90                   	nop
801032c3:	90                   	nop
801032c4:	c9                   	leave  
801032c5:	c3                   	ret    

801032c6 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801032c6:	f3 0f 1e fb          	endbr32 
801032ca:	55                   	push   %ebp
801032cb:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801032cd:	8b 45 08             	mov    0x8(%ebp),%eax
801032d0:	0f b6 c0             	movzbl %al,%eax
801032d3:	50                   	push   %eax
801032d4:	6a 70                	push   $0x70
801032d6:	e8 4a fd ff ff       	call   80103025 <outb>
801032db:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801032de:	68 c8 00 00 00       	push   $0xc8
801032e3:	e8 ec fe ff ff       	call   801031d4 <microdelay>
801032e8:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801032eb:	6a 71                	push   $0x71
801032ed:	e8 16 fd ff ff       	call   80103008 <inb>
801032f2:	83 c4 04             	add    $0x4,%esp
801032f5:	0f b6 c0             	movzbl %al,%eax
}
801032f8:	c9                   	leave  
801032f9:	c3                   	ret    

801032fa <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801032fa:	f3 0f 1e fb          	endbr32 
801032fe:	55                   	push   %ebp
801032ff:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103301:	6a 00                	push   $0x0
80103303:	e8 be ff ff ff       	call   801032c6 <cmos_read>
80103308:	83 c4 04             	add    $0x4,%esp
8010330b:	8b 55 08             	mov    0x8(%ebp),%edx
8010330e:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103310:	6a 02                	push   $0x2
80103312:	e8 af ff ff ff       	call   801032c6 <cmos_read>
80103317:	83 c4 04             	add    $0x4,%esp
8010331a:	8b 55 08             	mov    0x8(%ebp),%edx
8010331d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103320:	6a 04                	push   $0x4
80103322:	e8 9f ff ff ff       	call   801032c6 <cmos_read>
80103327:	83 c4 04             	add    $0x4,%esp
8010332a:	8b 55 08             	mov    0x8(%ebp),%edx
8010332d:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103330:	6a 07                	push   $0x7
80103332:	e8 8f ff ff ff       	call   801032c6 <cmos_read>
80103337:	83 c4 04             	add    $0x4,%esp
8010333a:	8b 55 08             	mov    0x8(%ebp),%edx
8010333d:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103340:	6a 08                	push   $0x8
80103342:	e8 7f ff ff ff       	call   801032c6 <cmos_read>
80103347:	83 c4 04             	add    $0x4,%esp
8010334a:	8b 55 08             	mov    0x8(%ebp),%edx
8010334d:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103350:	6a 09                	push   $0x9
80103352:	e8 6f ff ff ff       	call   801032c6 <cmos_read>
80103357:	83 c4 04             	add    $0x4,%esp
8010335a:	8b 55 08             	mov    0x8(%ebp),%edx
8010335d:	89 42 14             	mov    %eax,0x14(%edx)
}
80103360:	90                   	nop
80103361:	c9                   	leave  
80103362:	c3                   	ret    

80103363 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80103363:	f3 0f 1e fb          	endbr32 
80103367:	55                   	push   %ebp
80103368:	89 e5                	mov    %esp,%ebp
8010336a:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010336d:	6a 0b                	push   $0xb
8010336f:	e8 52 ff ff ff       	call   801032c6 <cmos_read>
80103374:	83 c4 04             	add    $0x4,%esp
80103377:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010337a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010337d:	83 e0 04             	and    $0x4,%eax
80103380:	85 c0                	test   %eax,%eax
80103382:	0f 94 c0             	sete   %al
80103385:	0f b6 c0             	movzbl %al,%eax
80103388:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010338b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010338e:	50                   	push   %eax
8010338f:	e8 66 ff ff ff       	call   801032fa <fill_rtcdate>
80103394:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103397:	6a 0a                	push   $0xa
80103399:	e8 28 ff ff ff       	call   801032c6 <cmos_read>
8010339e:	83 c4 04             	add    $0x4,%esp
801033a1:	25 80 00 00 00       	and    $0x80,%eax
801033a6:	85 c0                	test   %eax,%eax
801033a8:	75 27                	jne    801033d1 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
801033aa:	8d 45 c0             	lea    -0x40(%ebp),%eax
801033ad:	50                   	push   %eax
801033ae:	e8 47 ff ff ff       	call   801032fa <fill_rtcdate>
801033b3:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801033b6:	83 ec 04             	sub    $0x4,%esp
801033b9:	6a 18                	push   $0x18
801033bb:	8d 45 c0             	lea    -0x40(%ebp),%eax
801033be:	50                   	push   %eax
801033bf:	8d 45 d8             	lea    -0x28(%ebp),%eax
801033c2:	50                   	push   %eax
801033c3:	e8 1b 22 00 00       	call   801055e3 <memcmp>
801033c8:	83 c4 10             	add    $0x10,%esp
801033cb:	85 c0                	test   %eax,%eax
801033cd:	74 05                	je     801033d4 <cmostime+0x71>
801033cf:	eb ba                	jmp    8010338b <cmostime+0x28>
        continue;
801033d1:	90                   	nop
    fill_rtcdate(&t1);
801033d2:	eb b7                	jmp    8010338b <cmostime+0x28>
      break;
801033d4:	90                   	nop
  }

  // convert
  if(bcd) {
801033d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801033d9:	0f 84 b4 00 00 00    	je     80103493 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801033df:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033e2:	c1 e8 04             	shr    $0x4,%eax
801033e5:	89 c2                	mov    %eax,%edx
801033e7:	89 d0                	mov    %edx,%eax
801033e9:	c1 e0 02             	shl    $0x2,%eax
801033ec:	01 d0                	add    %edx,%eax
801033ee:	01 c0                	add    %eax,%eax
801033f0:	89 c2                	mov    %eax,%edx
801033f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033f5:	83 e0 0f             	and    $0xf,%eax
801033f8:	01 d0                	add    %edx,%eax
801033fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801033fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103400:	c1 e8 04             	shr    $0x4,%eax
80103403:	89 c2                	mov    %eax,%edx
80103405:	89 d0                	mov    %edx,%eax
80103407:	c1 e0 02             	shl    $0x2,%eax
8010340a:	01 d0                	add    %edx,%eax
8010340c:	01 c0                	add    %eax,%eax
8010340e:	89 c2                	mov    %eax,%edx
80103410:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103413:	83 e0 0f             	and    $0xf,%eax
80103416:	01 d0                	add    %edx,%eax
80103418:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010341b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010341e:	c1 e8 04             	shr    $0x4,%eax
80103421:	89 c2                	mov    %eax,%edx
80103423:	89 d0                	mov    %edx,%eax
80103425:	c1 e0 02             	shl    $0x2,%eax
80103428:	01 d0                	add    %edx,%eax
8010342a:	01 c0                	add    %eax,%eax
8010342c:	89 c2                	mov    %eax,%edx
8010342e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103431:	83 e0 0f             	and    $0xf,%eax
80103434:	01 d0                	add    %edx,%eax
80103436:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103439:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010343c:	c1 e8 04             	shr    $0x4,%eax
8010343f:	89 c2                	mov    %eax,%edx
80103441:	89 d0                	mov    %edx,%eax
80103443:	c1 e0 02             	shl    $0x2,%eax
80103446:	01 d0                	add    %edx,%eax
80103448:	01 c0                	add    %eax,%eax
8010344a:	89 c2                	mov    %eax,%edx
8010344c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010344f:	83 e0 0f             	and    $0xf,%eax
80103452:	01 d0                	add    %edx,%eax
80103454:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103457:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010345a:	c1 e8 04             	shr    $0x4,%eax
8010345d:	89 c2                	mov    %eax,%edx
8010345f:	89 d0                	mov    %edx,%eax
80103461:	c1 e0 02             	shl    $0x2,%eax
80103464:	01 d0                	add    %edx,%eax
80103466:	01 c0                	add    %eax,%eax
80103468:	89 c2                	mov    %eax,%edx
8010346a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010346d:	83 e0 0f             	and    $0xf,%eax
80103470:	01 d0                	add    %edx,%eax
80103472:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103475:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103478:	c1 e8 04             	shr    $0x4,%eax
8010347b:	89 c2                	mov    %eax,%edx
8010347d:	89 d0                	mov    %edx,%eax
8010347f:	c1 e0 02             	shl    $0x2,%eax
80103482:	01 d0                	add    %edx,%eax
80103484:	01 c0                	add    %eax,%eax
80103486:	89 c2                	mov    %eax,%edx
80103488:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010348b:	83 e0 0f             	and    $0xf,%eax
8010348e:	01 d0                	add    %edx,%eax
80103490:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103493:	8b 45 08             	mov    0x8(%ebp),%eax
80103496:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103499:	89 10                	mov    %edx,(%eax)
8010349b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010349e:	89 50 04             	mov    %edx,0x4(%eax)
801034a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801034a4:	89 50 08             	mov    %edx,0x8(%eax)
801034a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801034aa:	89 50 0c             	mov    %edx,0xc(%eax)
801034ad:	8b 55 e8             	mov    -0x18(%ebp),%edx
801034b0:	89 50 10             	mov    %edx,0x10(%eax)
801034b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034b6:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801034b9:	8b 45 08             	mov    0x8(%ebp),%eax
801034bc:	8b 40 14             	mov    0x14(%eax),%eax
801034bf:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801034c5:	8b 45 08             	mov    0x8(%ebp),%eax
801034c8:	89 50 14             	mov    %edx,0x14(%eax)
}
801034cb:	90                   	nop
801034cc:	c9                   	leave  
801034cd:	c3                   	ret    

801034ce <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801034ce:	f3 0f 1e fb          	endbr32 
801034d2:	55                   	push   %ebp
801034d3:	89 e5                	mov    %esp,%ebp
801034d5:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801034d8:	83 ec 08             	sub    $0x8,%esp
801034db:	68 05 96 10 80       	push   $0x80109605
801034e0:	68 20 47 11 80       	push   $0x80114720
801034e5:	e8 c9 1d 00 00       	call   801052b3 <initlock>
801034ea:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801034ed:	83 ec 08             	sub    $0x8,%esp
801034f0:	8d 45 dc             	lea    -0x24(%ebp),%eax
801034f3:	50                   	push   %eax
801034f4:	ff 75 08             	pushl  0x8(%ebp)
801034f7:	e8 f9 df ff ff       	call   801014f5 <readsb>
801034fc:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801034ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103502:	a3 54 47 11 80       	mov    %eax,0x80114754
  log.size = sb.nlog;
80103507:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010350a:	a3 58 47 11 80       	mov    %eax,0x80114758
  log.dev = dev;
8010350f:	8b 45 08             	mov    0x8(%ebp),%eax
80103512:	a3 64 47 11 80       	mov    %eax,0x80114764
  recover_from_log();
80103517:	e8 bf 01 00 00       	call   801036db <recover_from_log>
}
8010351c:	90                   	nop
8010351d:	c9                   	leave  
8010351e:	c3                   	ret    

8010351f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010351f:	f3 0f 1e fb          	endbr32 
80103523:	55                   	push   %ebp
80103524:	89 e5                	mov    %esp,%ebp
80103526:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103529:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103530:	e9 95 00 00 00       	jmp    801035ca <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103535:	8b 15 54 47 11 80    	mov    0x80114754,%edx
8010353b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010353e:	01 d0                	add    %edx,%eax
80103540:	83 c0 01             	add    $0x1,%eax
80103543:	89 c2                	mov    %eax,%edx
80103545:	a1 64 47 11 80       	mov    0x80114764,%eax
8010354a:	83 ec 08             	sub    $0x8,%esp
8010354d:	52                   	push   %edx
8010354e:	50                   	push   %eax
8010354f:	e8 83 cc ff ff       	call   801001d7 <bread>
80103554:	83 c4 10             	add    $0x10,%esp
80103557:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010355a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010355d:	83 c0 10             	add    $0x10,%eax
80103560:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
80103567:	89 c2                	mov    %eax,%edx
80103569:	a1 64 47 11 80       	mov    0x80114764,%eax
8010356e:	83 ec 08             	sub    $0x8,%esp
80103571:	52                   	push   %edx
80103572:	50                   	push   %eax
80103573:	e8 5f cc ff ff       	call   801001d7 <bread>
80103578:	83 c4 10             	add    $0x10,%esp
8010357b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010357e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103581:	8d 50 5c             	lea    0x5c(%eax),%edx
80103584:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103587:	83 c0 5c             	add    $0x5c,%eax
8010358a:	83 ec 04             	sub    $0x4,%esp
8010358d:	68 00 02 00 00       	push   $0x200
80103592:	52                   	push   %edx
80103593:	50                   	push   %eax
80103594:	e8 a6 20 00 00       	call   8010563f <memmove>
80103599:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010359c:	83 ec 0c             	sub    $0xc,%esp
8010359f:	ff 75 ec             	pushl  -0x14(%ebp)
801035a2:	e8 6d cc ff ff       	call   80100214 <bwrite>
801035a7:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801035aa:	83 ec 0c             	sub    $0xc,%esp
801035ad:	ff 75 f0             	pushl  -0x10(%ebp)
801035b0:	e8 ac cc ff ff       	call   80100261 <brelse>
801035b5:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801035b8:	83 ec 0c             	sub    $0xc,%esp
801035bb:	ff 75 ec             	pushl  -0x14(%ebp)
801035be:	e8 9e cc ff ff       	call   80100261 <brelse>
801035c3:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801035c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035ca:	a1 68 47 11 80       	mov    0x80114768,%eax
801035cf:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035d2:	0f 8c 5d ff ff ff    	jl     80103535 <install_trans+0x16>
  }
}
801035d8:	90                   	nop
801035d9:	90                   	nop
801035da:	c9                   	leave  
801035db:	c3                   	ret    

801035dc <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801035dc:	f3 0f 1e fb          	endbr32 
801035e0:	55                   	push   %ebp
801035e1:	89 e5                	mov    %esp,%ebp
801035e3:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801035e6:	a1 54 47 11 80       	mov    0x80114754,%eax
801035eb:	89 c2                	mov    %eax,%edx
801035ed:	a1 64 47 11 80       	mov    0x80114764,%eax
801035f2:	83 ec 08             	sub    $0x8,%esp
801035f5:	52                   	push   %edx
801035f6:	50                   	push   %eax
801035f7:	e8 db cb ff ff       	call   801001d7 <bread>
801035fc:	83 c4 10             	add    $0x10,%esp
801035ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103605:	83 c0 5c             	add    $0x5c,%eax
80103608:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010360b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010360e:	8b 00                	mov    (%eax),%eax
80103610:	a3 68 47 11 80       	mov    %eax,0x80114768
  for (i = 0; i < log.lh.n; i++) {
80103615:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010361c:	eb 1b                	jmp    80103639 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
8010361e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103621:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103624:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103628:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010362b:	83 c2 10             	add    $0x10,%edx
8010362e:	89 04 95 2c 47 11 80 	mov    %eax,-0x7feeb8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103635:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103639:	a1 68 47 11 80       	mov    0x80114768,%eax
8010363e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103641:	7c db                	jl     8010361e <read_head+0x42>
  }
  brelse(buf);
80103643:	83 ec 0c             	sub    $0xc,%esp
80103646:	ff 75 f0             	pushl  -0x10(%ebp)
80103649:	e8 13 cc ff ff       	call   80100261 <brelse>
8010364e:	83 c4 10             	add    $0x10,%esp
}
80103651:	90                   	nop
80103652:	c9                   	leave  
80103653:	c3                   	ret    

80103654 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103654:	f3 0f 1e fb          	endbr32 
80103658:	55                   	push   %ebp
80103659:	89 e5                	mov    %esp,%ebp
8010365b:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010365e:	a1 54 47 11 80       	mov    0x80114754,%eax
80103663:	89 c2                	mov    %eax,%edx
80103665:	a1 64 47 11 80       	mov    0x80114764,%eax
8010366a:	83 ec 08             	sub    $0x8,%esp
8010366d:	52                   	push   %edx
8010366e:	50                   	push   %eax
8010366f:	e8 63 cb ff ff       	call   801001d7 <bread>
80103674:	83 c4 10             	add    $0x10,%esp
80103677:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010367a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010367d:	83 c0 5c             	add    $0x5c,%eax
80103680:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103683:	8b 15 68 47 11 80    	mov    0x80114768,%edx
80103689:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010368c:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010368e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103695:	eb 1b                	jmp    801036b2 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010369a:	83 c0 10             	add    $0x10,%eax
8010369d:	8b 0c 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%ecx
801036a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036aa:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801036ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036b2:	a1 68 47 11 80       	mov    0x80114768,%eax
801036b7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801036ba:	7c db                	jl     80103697 <write_head+0x43>
  }
  bwrite(buf);
801036bc:	83 ec 0c             	sub    $0xc,%esp
801036bf:	ff 75 f0             	pushl  -0x10(%ebp)
801036c2:	e8 4d cb ff ff       	call   80100214 <bwrite>
801036c7:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801036ca:	83 ec 0c             	sub    $0xc,%esp
801036cd:	ff 75 f0             	pushl  -0x10(%ebp)
801036d0:	e8 8c cb ff ff       	call   80100261 <brelse>
801036d5:	83 c4 10             	add    $0x10,%esp
}
801036d8:	90                   	nop
801036d9:	c9                   	leave  
801036da:	c3                   	ret    

801036db <recover_from_log>:

static void
recover_from_log(void)
{
801036db:	f3 0f 1e fb          	endbr32 
801036df:	55                   	push   %ebp
801036e0:	89 e5                	mov    %esp,%ebp
801036e2:	83 ec 08             	sub    $0x8,%esp
  read_head();
801036e5:	e8 f2 fe ff ff       	call   801035dc <read_head>
  install_trans(); // if committed, copy from log to disk
801036ea:	e8 30 fe ff ff       	call   8010351f <install_trans>
  log.lh.n = 0;
801036ef:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
801036f6:	00 00 00 
  write_head(); // clear the log
801036f9:	e8 56 ff ff ff       	call   80103654 <write_head>
}
801036fe:	90                   	nop
801036ff:	c9                   	leave  
80103700:	c3                   	ret    

80103701 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103701:	f3 0f 1e fb          	endbr32 
80103705:	55                   	push   %ebp
80103706:	89 e5                	mov    %esp,%ebp
80103708:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010370b:	83 ec 0c             	sub    $0xc,%esp
8010370e:	68 20 47 11 80       	push   $0x80114720
80103713:	e8 c1 1b 00 00       	call   801052d9 <acquire>
80103718:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010371b:	a1 60 47 11 80       	mov    0x80114760,%eax
80103720:	85 c0                	test   %eax,%eax
80103722:	74 17                	je     8010373b <begin_op+0x3a>
      sleep(&log, &log.lock);
80103724:	83 ec 08             	sub    $0x8,%esp
80103727:	68 20 47 11 80       	push   $0x80114720
8010372c:	68 20 47 11 80       	push   $0x80114720
80103731:	e8 31 17 00 00       	call   80104e67 <sleep>
80103736:	83 c4 10             	add    $0x10,%esp
80103739:	eb e0                	jmp    8010371b <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010373b:	8b 0d 68 47 11 80    	mov    0x80114768,%ecx
80103741:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103746:	8d 50 01             	lea    0x1(%eax),%edx
80103749:	89 d0                	mov    %edx,%eax
8010374b:	c1 e0 02             	shl    $0x2,%eax
8010374e:	01 d0                	add    %edx,%eax
80103750:	01 c0                	add    %eax,%eax
80103752:	01 c8                	add    %ecx,%eax
80103754:	83 f8 1e             	cmp    $0x1e,%eax
80103757:	7e 17                	jle    80103770 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103759:	83 ec 08             	sub    $0x8,%esp
8010375c:	68 20 47 11 80       	push   $0x80114720
80103761:	68 20 47 11 80       	push   $0x80114720
80103766:	e8 fc 16 00 00       	call   80104e67 <sleep>
8010376b:	83 c4 10             	add    $0x10,%esp
8010376e:	eb ab                	jmp    8010371b <begin_op+0x1a>
    } else {
      log.outstanding += 1;
80103770:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103775:	83 c0 01             	add    $0x1,%eax
80103778:	a3 5c 47 11 80       	mov    %eax,0x8011475c
      release(&log.lock);
8010377d:	83 ec 0c             	sub    $0xc,%esp
80103780:	68 20 47 11 80       	push   $0x80114720
80103785:	e8 c1 1b 00 00       	call   8010534b <release>
8010378a:	83 c4 10             	add    $0x10,%esp
      break;
8010378d:	90                   	nop
    }
  }
}
8010378e:	90                   	nop
8010378f:	c9                   	leave  
80103790:	c3                   	ret    

80103791 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103791:	f3 0f 1e fb          	endbr32 
80103795:	55                   	push   %ebp
80103796:	89 e5                	mov    %esp,%ebp
80103798:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010379b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801037a2:	83 ec 0c             	sub    $0xc,%esp
801037a5:	68 20 47 11 80       	push   $0x80114720
801037aa:	e8 2a 1b 00 00       	call   801052d9 <acquire>
801037af:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801037b2:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801037b7:	83 e8 01             	sub    $0x1,%eax
801037ba:	a3 5c 47 11 80       	mov    %eax,0x8011475c
  if(log.committing)
801037bf:	a1 60 47 11 80       	mov    0x80114760,%eax
801037c4:	85 c0                	test   %eax,%eax
801037c6:	74 0d                	je     801037d5 <end_op+0x44>
    panic("log.committing");
801037c8:	83 ec 0c             	sub    $0xc,%esp
801037cb:	68 09 96 10 80       	push   $0x80109609
801037d0:	e8 33 ce ff ff       	call   80100608 <panic>
  if(log.outstanding == 0){
801037d5:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801037da:	85 c0                	test   %eax,%eax
801037dc:	75 13                	jne    801037f1 <end_op+0x60>
    do_commit = 1;
801037de:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801037e5:	c7 05 60 47 11 80 01 	movl   $0x1,0x80114760
801037ec:	00 00 00 
801037ef:	eb 10                	jmp    80103801 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801037f1:	83 ec 0c             	sub    $0xc,%esp
801037f4:	68 20 47 11 80       	push   $0x80114720
801037f9:	e8 5b 17 00 00       	call   80104f59 <wakeup>
801037fe:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103801:	83 ec 0c             	sub    $0xc,%esp
80103804:	68 20 47 11 80       	push   $0x80114720
80103809:	e8 3d 1b 00 00       	call   8010534b <release>
8010380e:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103811:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103815:	74 3f                	je     80103856 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103817:	e8 fa 00 00 00       	call   80103916 <commit>
    acquire(&log.lock);
8010381c:	83 ec 0c             	sub    $0xc,%esp
8010381f:	68 20 47 11 80       	push   $0x80114720
80103824:	e8 b0 1a 00 00       	call   801052d9 <acquire>
80103829:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010382c:	c7 05 60 47 11 80 00 	movl   $0x0,0x80114760
80103833:	00 00 00 
    wakeup(&log);
80103836:	83 ec 0c             	sub    $0xc,%esp
80103839:	68 20 47 11 80       	push   $0x80114720
8010383e:	e8 16 17 00 00       	call   80104f59 <wakeup>
80103843:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103846:	83 ec 0c             	sub    $0xc,%esp
80103849:	68 20 47 11 80       	push   $0x80114720
8010384e:	e8 f8 1a 00 00       	call   8010534b <release>
80103853:	83 c4 10             	add    $0x10,%esp
  }
}
80103856:	90                   	nop
80103857:	c9                   	leave  
80103858:	c3                   	ret    

80103859 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103859:	f3 0f 1e fb          	endbr32 
8010385d:	55                   	push   %ebp
8010385e:	89 e5                	mov    %esp,%ebp
80103860:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103863:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010386a:	e9 95 00 00 00       	jmp    80103904 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010386f:	8b 15 54 47 11 80    	mov    0x80114754,%edx
80103875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103878:	01 d0                	add    %edx,%eax
8010387a:	83 c0 01             	add    $0x1,%eax
8010387d:	89 c2                	mov    %eax,%edx
8010387f:	a1 64 47 11 80       	mov    0x80114764,%eax
80103884:	83 ec 08             	sub    $0x8,%esp
80103887:	52                   	push   %edx
80103888:	50                   	push   %eax
80103889:	e8 49 c9 ff ff       	call   801001d7 <bread>
8010388e:	83 c4 10             	add    $0x10,%esp
80103891:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103897:	83 c0 10             	add    $0x10,%eax
8010389a:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
801038a1:	89 c2                	mov    %eax,%edx
801038a3:	a1 64 47 11 80       	mov    0x80114764,%eax
801038a8:	83 ec 08             	sub    $0x8,%esp
801038ab:	52                   	push   %edx
801038ac:	50                   	push   %eax
801038ad:	e8 25 c9 ff ff       	call   801001d7 <bread>
801038b2:	83 c4 10             	add    $0x10,%esp
801038b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801038b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038bb:	8d 50 5c             	lea    0x5c(%eax),%edx
801038be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c1:	83 c0 5c             	add    $0x5c,%eax
801038c4:	83 ec 04             	sub    $0x4,%esp
801038c7:	68 00 02 00 00       	push   $0x200
801038cc:	52                   	push   %edx
801038cd:	50                   	push   %eax
801038ce:	e8 6c 1d 00 00       	call   8010563f <memmove>
801038d3:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801038d6:	83 ec 0c             	sub    $0xc,%esp
801038d9:	ff 75 f0             	pushl  -0x10(%ebp)
801038dc:	e8 33 c9 ff ff       	call   80100214 <bwrite>
801038e1:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801038e4:	83 ec 0c             	sub    $0xc,%esp
801038e7:	ff 75 ec             	pushl  -0x14(%ebp)
801038ea:	e8 72 c9 ff ff       	call   80100261 <brelse>
801038ef:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801038f2:	83 ec 0c             	sub    $0xc,%esp
801038f5:	ff 75 f0             	pushl  -0x10(%ebp)
801038f8:	e8 64 c9 ff ff       	call   80100261 <brelse>
801038fd:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103900:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103904:	a1 68 47 11 80       	mov    0x80114768,%eax
80103909:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010390c:	0f 8c 5d ff ff ff    	jl     8010386f <write_log+0x16>
  }
}
80103912:	90                   	nop
80103913:	90                   	nop
80103914:	c9                   	leave  
80103915:	c3                   	ret    

80103916 <commit>:

static void
commit()
{
80103916:	f3 0f 1e fb          	endbr32 
8010391a:	55                   	push   %ebp
8010391b:	89 e5                	mov    %esp,%ebp
8010391d:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103920:	a1 68 47 11 80       	mov    0x80114768,%eax
80103925:	85 c0                	test   %eax,%eax
80103927:	7e 1e                	jle    80103947 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103929:	e8 2b ff ff ff       	call   80103859 <write_log>
    write_head();    // Write header to disk -- the real commit
8010392e:	e8 21 fd ff ff       	call   80103654 <write_head>
    install_trans(); // Now install writes to home locations
80103933:	e8 e7 fb ff ff       	call   8010351f <install_trans>
    log.lh.n = 0;
80103938:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
8010393f:	00 00 00 
    write_head();    // Erase the transaction from the log
80103942:	e8 0d fd ff ff       	call   80103654 <write_head>
  }
}
80103947:	90                   	nop
80103948:	c9                   	leave  
80103949:	c3                   	ret    

8010394a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010394a:	f3 0f 1e fb          	endbr32 
8010394e:	55                   	push   %ebp
8010394f:	89 e5                	mov    %esp,%ebp
80103951:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103954:	a1 68 47 11 80       	mov    0x80114768,%eax
80103959:	83 f8 1d             	cmp    $0x1d,%eax
8010395c:	7f 12                	jg     80103970 <log_write+0x26>
8010395e:	a1 68 47 11 80       	mov    0x80114768,%eax
80103963:	8b 15 58 47 11 80    	mov    0x80114758,%edx
80103969:	83 ea 01             	sub    $0x1,%edx
8010396c:	39 d0                	cmp    %edx,%eax
8010396e:	7c 0d                	jl     8010397d <log_write+0x33>
    panic("too big a transaction");
80103970:	83 ec 0c             	sub    $0xc,%esp
80103973:	68 18 96 10 80       	push   $0x80109618
80103978:	e8 8b cc ff ff       	call   80100608 <panic>
  if (log.outstanding < 1)
8010397d:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103982:	85 c0                	test   %eax,%eax
80103984:	7f 0d                	jg     80103993 <log_write+0x49>
    panic("log_write outside of trans");
80103986:	83 ec 0c             	sub    $0xc,%esp
80103989:	68 2e 96 10 80       	push   $0x8010962e
8010398e:	e8 75 cc ff ff       	call   80100608 <panic>

  acquire(&log.lock);
80103993:	83 ec 0c             	sub    $0xc,%esp
80103996:	68 20 47 11 80       	push   $0x80114720
8010399b:	e8 39 19 00 00       	call   801052d9 <acquire>
801039a0:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801039a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039aa:	eb 1d                	jmp    801039c9 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801039ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039af:	83 c0 10             	add    $0x10,%eax
801039b2:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
801039b9:	89 c2                	mov    %eax,%edx
801039bb:	8b 45 08             	mov    0x8(%ebp),%eax
801039be:	8b 40 08             	mov    0x8(%eax),%eax
801039c1:	39 c2                	cmp    %eax,%edx
801039c3:	74 10                	je     801039d5 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
801039c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039c9:	a1 68 47 11 80       	mov    0x80114768,%eax
801039ce:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039d1:	7c d9                	jl     801039ac <log_write+0x62>
801039d3:	eb 01                	jmp    801039d6 <log_write+0x8c>
      break;
801039d5:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801039d6:	8b 45 08             	mov    0x8(%ebp),%eax
801039d9:	8b 40 08             	mov    0x8(%eax),%eax
801039dc:	89 c2                	mov    %eax,%edx
801039de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e1:	83 c0 10             	add    $0x10,%eax
801039e4:	89 14 85 2c 47 11 80 	mov    %edx,-0x7feeb8d4(,%eax,4)
  if (i == log.lh.n)
801039eb:	a1 68 47 11 80       	mov    0x80114768,%eax
801039f0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039f3:	75 0d                	jne    80103a02 <log_write+0xb8>
    log.lh.n++;
801039f5:	a1 68 47 11 80       	mov    0x80114768,%eax
801039fa:	83 c0 01             	add    $0x1,%eax
801039fd:	a3 68 47 11 80       	mov    %eax,0x80114768
  b->flags |= B_DIRTY; // prevent eviction
80103a02:	8b 45 08             	mov    0x8(%ebp),%eax
80103a05:	8b 00                	mov    (%eax),%eax
80103a07:	83 c8 04             	or     $0x4,%eax
80103a0a:	89 c2                	mov    %eax,%edx
80103a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a0f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103a11:	83 ec 0c             	sub    $0xc,%esp
80103a14:	68 20 47 11 80       	push   $0x80114720
80103a19:	e8 2d 19 00 00       	call   8010534b <release>
80103a1e:	83 c4 10             	add    $0x10,%esp
}
80103a21:	90                   	nop
80103a22:	c9                   	leave  
80103a23:	c3                   	ret    

80103a24 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103a24:	55                   	push   %ebp
80103a25:	89 e5                	mov    %esp,%ebp
80103a27:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103a2a:	8b 55 08             	mov    0x8(%ebp),%edx
80103a2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a30:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103a33:	f0 87 02             	lock xchg %eax,(%edx)
80103a36:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103a39:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103a3c:	c9                   	leave  
80103a3d:	c3                   	ret    

80103a3e <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103a3e:	f3 0f 1e fb          	endbr32 
80103a42:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103a46:	83 e4 f0             	and    $0xfffffff0,%esp
80103a49:	ff 71 fc             	pushl  -0x4(%ecx)
80103a4c:	55                   	push   %ebp
80103a4d:	89 e5                	mov    %esp,%ebp
80103a4f:	51                   	push   %ecx
80103a50:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103a53:	83 ec 08             	sub    $0x8,%esp
80103a56:	68 00 00 40 80       	push   $0x80400000
80103a5b:	68 48 88 11 80       	push   $0x80118848
80103a60:	e8 78 f2 ff ff       	call   80102cdd <kinit1>
80103a65:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103a68:	e8 28 4c 00 00       	call   80108695 <kvmalloc>
  mpinit();        // detect other processors
80103a6d:	e8 d9 03 00 00       	call   80103e4b <mpinit>
  lapicinit();     // interrupt controller
80103a72:	e8 f5 f5 ff ff       	call   8010306c <lapicinit>
  seginit();       // segment descriptors
80103a77:	e8 70 43 00 00       	call   80107dec <seginit>
  picinit();       // disable pic
80103a7c:	e8 35 05 00 00       	call   80103fb6 <picinit>
  ioapicinit();    // another interrupt controller
80103a81:	e8 6a f1 ff ff       	call   80102bf0 <ioapicinit>
  consoleinit();   // console hardware
80103a86:	e8 56 d1 ff ff       	call   80100be1 <consoleinit>
  uartinit();      // serial port
80103a8b:	e8 19 35 00 00       	call   80106fa9 <uartinit>
  pinit();         // process table
80103a90:	e8 6e 09 00 00       	call   80104403 <pinit>
  tvinit();        // trap vectors
80103a95:	e8 a8 30 00 00       	call   80106b42 <tvinit>
  binit();         // buffer cache
80103a9a:	e8 95 c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103a9f:	e8 26 d6 ff ff       	call   801010ca <fileinit>
  ideinit();       // disk 
80103aa4:	e8 06 ed ff ff       	call   801027af <ideinit>
  startothers();   // start other processors
80103aa9:	e8 88 00 00 00       	call   80103b36 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103aae:	83 ec 08             	sub    $0x8,%esp
80103ab1:	68 00 00 00 8e       	push   $0x8e000000
80103ab6:	68 00 00 40 80       	push   $0x80400000
80103abb:	e8 5a f2 ff ff       	call   80102d1a <kinit2>
80103ac0:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103ac3:	e8 5e 0b 00 00       	call   80104626 <userinit>
  mpmain();        // finish this processor's setup
80103ac8:	e8 1e 00 00 00       	call   80103aeb <mpmain>

80103acd <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103acd:	f3 0f 1e fb          	endbr32 
80103ad1:	55                   	push   %ebp
80103ad2:	89 e5                	mov    %esp,%ebp
80103ad4:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103ad7:	e8 d5 4b 00 00       	call   801086b1 <switchkvm>
  seginit();
80103adc:	e8 0b 43 00 00       	call   80107dec <seginit>
  lapicinit();
80103ae1:	e8 86 f5 ff ff       	call   8010306c <lapicinit>
  mpmain();
80103ae6:	e8 00 00 00 00       	call   80103aeb <mpmain>

80103aeb <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103aeb:	f3 0f 1e fb          	endbr32 
80103aef:	55                   	push   %ebp
80103af0:	89 e5                	mov    %esp,%ebp
80103af2:	53                   	push   %ebx
80103af3:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103af6:	e8 2a 09 00 00       	call   80104425 <cpuid>
80103afb:	89 c3                	mov    %eax,%ebx
80103afd:	e8 23 09 00 00       	call   80104425 <cpuid>
80103b02:	83 ec 04             	sub    $0x4,%esp
80103b05:	53                   	push   %ebx
80103b06:	50                   	push   %eax
80103b07:	68 49 96 10 80       	push   $0x80109649
80103b0c:	e8 07 c9 ff ff       	call   80100418 <cprintf>
80103b11:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103b14:	e8 a3 31 00 00       	call   80106cbc <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103b19:	e8 26 09 00 00       	call   80104444 <mycpu>
80103b1e:	05 a0 00 00 00       	add    $0xa0,%eax
80103b23:	83 ec 08             	sub    $0x8,%esp
80103b26:	6a 01                	push   $0x1
80103b28:	50                   	push   %eax
80103b29:	e8 f6 fe ff ff       	call   80103a24 <xchg>
80103b2e:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103b31:	e8 2d 11 00 00       	call   80104c63 <scheduler>

80103b36 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103b36:	f3 0f 1e fb          	endbr32 
80103b3a:	55                   	push   %ebp
80103b3b:	89 e5                	mov    %esp,%ebp
80103b3d:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103b40:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103b47:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103b4c:	83 ec 04             	sub    $0x4,%esp
80103b4f:	50                   	push   %eax
80103b50:	68 0c c5 10 80       	push   $0x8010c50c
80103b55:	ff 75 f0             	pushl  -0x10(%ebp)
80103b58:	e8 e2 1a 00 00       	call   8010563f <memmove>
80103b5d:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103b60:	c7 45 f4 20 48 11 80 	movl   $0x80114820,-0xc(%ebp)
80103b67:	eb 79                	jmp    80103be2 <startothers+0xac>
    if(c == mycpu())  // We've started already.
80103b69:	e8 d6 08 00 00       	call   80104444 <mycpu>
80103b6e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b71:	74 67                	je     80103bda <startothers+0xa4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103b73:	e8 aa f2 ff ff       	call   80102e22 <kalloc>
80103b78:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b7e:	83 e8 04             	sub    $0x4,%eax
80103b81:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b84:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103b8a:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b8f:	83 e8 08             	sub    $0x8,%eax
80103b92:	c7 00 cd 3a 10 80    	movl   $0x80103acd,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103b98:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103b9d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba6:	83 e8 0c             	sub    $0xc,%eax
80103ba9:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bae:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb7:	0f b6 00             	movzbl (%eax),%eax
80103bba:	0f b6 c0             	movzbl %al,%eax
80103bbd:	83 ec 08             	sub    $0x8,%esp
80103bc0:	52                   	push   %edx
80103bc1:	50                   	push   %eax
80103bc2:	e8 17 f6 ff ff       	call   801031de <lapicstartap>
80103bc7:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103bca:	90                   	nop
80103bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bce:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103bd4:	85 c0                	test   %eax,%eax
80103bd6:	74 f3                	je     80103bcb <startothers+0x95>
80103bd8:	eb 01                	jmp    80103bdb <startothers+0xa5>
      continue;
80103bda:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103bdb:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103be2:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103be7:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103bed:	05 20 48 11 80       	add    $0x80114820,%eax
80103bf2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103bf5:	0f 82 6e ff ff ff    	jb     80103b69 <startothers+0x33>
      ;
  }
}
80103bfb:	90                   	nop
80103bfc:	90                   	nop
80103bfd:	c9                   	leave  
80103bfe:	c3                   	ret    

80103bff <inb>:
{
80103bff:	55                   	push   %ebp
80103c00:	89 e5                	mov    %esp,%ebp
80103c02:	83 ec 14             	sub    $0x14,%esp
80103c05:	8b 45 08             	mov    0x8(%ebp),%eax
80103c08:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103c0c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103c10:	89 c2                	mov    %eax,%edx
80103c12:	ec                   	in     (%dx),%al
80103c13:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103c16:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103c1a:	c9                   	leave  
80103c1b:	c3                   	ret    

80103c1c <outb>:
{
80103c1c:	55                   	push   %ebp
80103c1d:	89 e5                	mov    %esp,%ebp
80103c1f:	83 ec 08             	sub    $0x8,%esp
80103c22:	8b 45 08             	mov    0x8(%ebp),%eax
80103c25:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c28:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103c2c:	89 d0                	mov    %edx,%eax
80103c2e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c31:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103c35:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103c39:	ee                   	out    %al,(%dx)
}
80103c3a:	90                   	nop
80103c3b:	c9                   	leave  
80103c3c:	c3                   	ret    

80103c3d <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103c3d:	f3 0f 1e fb          	endbr32 
80103c41:	55                   	push   %ebp
80103c42:	89 e5                	mov    %esp,%ebp
80103c44:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103c47:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c4e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103c55:	eb 15                	jmp    80103c6c <sum+0x2f>
    sum += addr[i];
80103c57:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c5d:	01 d0                	add    %edx,%eax
80103c5f:	0f b6 00             	movzbl (%eax),%eax
80103c62:	0f b6 c0             	movzbl %al,%eax
80103c65:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c68:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103c6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103c6f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103c72:	7c e3                	jl     80103c57 <sum+0x1a>
  return sum;
80103c74:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103c77:	c9                   	leave  
80103c78:	c3                   	ret    

80103c79 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103c79:	f3 0f 1e fb          	endbr32 
80103c7d:	55                   	push   %ebp
80103c7e:	89 e5                	mov    %esp,%ebp
80103c80:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103c83:	8b 45 08             	mov    0x8(%ebp),%eax
80103c86:	05 00 00 00 80       	add    $0x80000000,%eax
80103c8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103c8e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c94:	01 d0                	add    %edx,%eax
80103c96:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c9f:	eb 36                	jmp    80103cd7 <mpsearch1+0x5e>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103ca1:	83 ec 04             	sub    $0x4,%esp
80103ca4:	6a 04                	push   $0x4
80103ca6:	68 60 96 10 80       	push   $0x80109660
80103cab:	ff 75 f4             	pushl  -0xc(%ebp)
80103cae:	e8 30 19 00 00       	call   801055e3 <memcmp>
80103cb3:	83 c4 10             	add    $0x10,%esp
80103cb6:	85 c0                	test   %eax,%eax
80103cb8:	75 19                	jne    80103cd3 <mpsearch1+0x5a>
80103cba:	83 ec 08             	sub    $0x8,%esp
80103cbd:	6a 10                	push   $0x10
80103cbf:	ff 75 f4             	pushl  -0xc(%ebp)
80103cc2:	e8 76 ff ff ff       	call   80103c3d <sum>
80103cc7:	83 c4 10             	add    $0x10,%esp
80103cca:	84 c0                	test   %al,%al
80103ccc:	75 05                	jne    80103cd3 <mpsearch1+0x5a>
      return (struct mp*)p;
80103cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd1:	eb 11                	jmp    80103ce4 <mpsearch1+0x6b>
  for(p = addr; p < e; p += sizeof(struct mp))
80103cd3:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cda:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cdd:	72 c2                	jb     80103ca1 <mpsearch1+0x28>
  return 0;
80103cdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ce4:	c9                   	leave  
80103ce5:	c3                   	ret    

80103ce6 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103ce6:	f3 0f 1e fb          	endbr32 
80103cea:	55                   	push   %ebp
80103ceb:	89 e5                	mov    %esp,%ebp
80103ced:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103cf0:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cfa:	83 c0 0f             	add    $0xf,%eax
80103cfd:	0f b6 00             	movzbl (%eax),%eax
80103d00:	0f b6 c0             	movzbl %al,%eax
80103d03:	c1 e0 08             	shl    $0x8,%eax
80103d06:	89 c2                	mov    %eax,%edx
80103d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0b:	83 c0 0e             	add    $0xe,%eax
80103d0e:	0f b6 00             	movzbl (%eax),%eax
80103d11:	0f b6 c0             	movzbl %al,%eax
80103d14:	09 d0                	or     %edx,%eax
80103d16:	c1 e0 04             	shl    $0x4,%eax
80103d19:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d1c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d20:	74 21                	je     80103d43 <mpsearch+0x5d>
    if((mp = mpsearch1(p, 1024)))
80103d22:	83 ec 08             	sub    $0x8,%esp
80103d25:	68 00 04 00 00       	push   $0x400
80103d2a:	ff 75 f0             	pushl  -0x10(%ebp)
80103d2d:	e8 47 ff ff ff       	call   80103c79 <mpsearch1>
80103d32:	83 c4 10             	add    $0x10,%esp
80103d35:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d38:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d3c:	74 51                	je     80103d8f <mpsearch+0xa9>
      return mp;
80103d3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d41:	eb 61                	jmp    80103da4 <mpsearch+0xbe>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d46:	83 c0 14             	add    $0x14,%eax
80103d49:	0f b6 00             	movzbl (%eax),%eax
80103d4c:	0f b6 c0             	movzbl %al,%eax
80103d4f:	c1 e0 08             	shl    $0x8,%eax
80103d52:	89 c2                	mov    %eax,%edx
80103d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d57:	83 c0 13             	add    $0x13,%eax
80103d5a:	0f b6 00             	movzbl (%eax),%eax
80103d5d:	0f b6 c0             	movzbl %al,%eax
80103d60:	09 d0                	or     %edx,%eax
80103d62:	c1 e0 0a             	shl    $0xa,%eax
80103d65:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d6b:	2d 00 04 00 00       	sub    $0x400,%eax
80103d70:	83 ec 08             	sub    $0x8,%esp
80103d73:	68 00 04 00 00       	push   $0x400
80103d78:	50                   	push   %eax
80103d79:	e8 fb fe ff ff       	call   80103c79 <mpsearch1>
80103d7e:	83 c4 10             	add    $0x10,%esp
80103d81:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d84:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d88:	74 05                	je     80103d8f <mpsearch+0xa9>
      return mp;
80103d8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d8d:	eb 15                	jmp    80103da4 <mpsearch+0xbe>
  }
  return mpsearch1(0xF0000, 0x10000);
80103d8f:	83 ec 08             	sub    $0x8,%esp
80103d92:	68 00 00 01 00       	push   $0x10000
80103d97:	68 00 00 0f 00       	push   $0xf0000
80103d9c:	e8 d8 fe ff ff       	call   80103c79 <mpsearch1>
80103da1:	83 c4 10             	add    $0x10,%esp
}
80103da4:	c9                   	leave  
80103da5:	c3                   	ret    

80103da6 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103da6:	f3 0f 1e fb          	endbr32 
80103daa:	55                   	push   %ebp
80103dab:	89 e5                	mov    %esp,%ebp
80103dad:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103db0:	e8 31 ff ff ff       	call   80103ce6 <mpsearch>
80103db5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103db8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103dbc:	74 0a                	je     80103dc8 <mpconfig+0x22>
80103dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc1:	8b 40 04             	mov    0x4(%eax),%eax
80103dc4:	85 c0                	test   %eax,%eax
80103dc6:	75 07                	jne    80103dcf <mpconfig+0x29>
    return 0;
80103dc8:	b8 00 00 00 00       	mov    $0x0,%eax
80103dcd:	eb 7a                	jmp    80103e49 <mpconfig+0xa3>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd2:	8b 40 04             	mov    0x4(%eax),%eax
80103dd5:	05 00 00 00 80       	add    $0x80000000,%eax
80103dda:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103ddd:	83 ec 04             	sub    $0x4,%esp
80103de0:	6a 04                	push   $0x4
80103de2:	68 65 96 10 80       	push   $0x80109665
80103de7:	ff 75 f0             	pushl  -0x10(%ebp)
80103dea:	e8 f4 17 00 00       	call   801055e3 <memcmp>
80103def:	83 c4 10             	add    $0x10,%esp
80103df2:	85 c0                	test   %eax,%eax
80103df4:	74 07                	je     80103dfd <mpconfig+0x57>
    return 0;
80103df6:	b8 00 00 00 00       	mov    $0x0,%eax
80103dfb:	eb 4c                	jmp    80103e49 <mpconfig+0xa3>
  if(conf->version != 1 && conf->version != 4)
80103dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e00:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e04:	3c 01                	cmp    $0x1,%al
80103e06:	74 12                	je     80103e1a <mpconfig+0x74>
80103e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e0b:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e0f:	3c 04                	cmp    $0x4,%al
80103e11:	74 07                	je     80103e1a <mpconfig+0x74>
    return 0;
80103e13:	b8 00 00 00 00       	mov    $0x0,%eax
80103e18:	eb 2f                	jmp    80103e49 <mpconfig+0xa3>
  if(sum((uchar*)conf, conf->length) != 0)
80103e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e1d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e21:	0f b7 c0             	movzwl %ax,%eax
80103e24:	83 ec 08             	sub    $0x8,%esp
80103e27:	50                   	push   %eax
80103e28:	ff 75 f0             	pushl  -0x10(%ebp)
80103e2b:	e8 0d fe ff ff       	call   80103c3d <sum>
80103e30:	83 c4 10             	add    $0x10,%esp
80103e33:	84 c0                	test   %al,%al
80103e35:	74 07                	je     80103e3e <mpconfig+0x98>
    return 0;
80103e37:	b8 00 00 00 00       	mov    $0x0,%eax
80103e3c:	eb 0b                	jmp    80103e49 <mpconfig+0xa3>
  *pmp = mp;
80103e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e44:	89 10                	mov    %edx,(%eax)
  return conf;
80103e46:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103e49:	c9                   	leave  
80103e4a:	c3                   	ret    

80103e4b <mpinit>:

void
mpinit(void)
{
80103e4b:	f3 0f 1e fb          	endbr32 
80103e4f:	55                   	push   %ebp
80103e50:	89 e5                	mov    %esp,%ebp
80103e52:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103e55:	83 ec 0c             	sub    $0xc,%esp
80103e58:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103e5b:	50                   	push   %eax
80103e5c:	e8 45 ff ff ff       	call   80103da6 <mpconfig>
80103e61:	83 c4 10             	add    $0x10,%esp
80103e64:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e67:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e6b:	75 0d                	jne    80103e7a <mpinit+0x2f>
    panic("Expect to run on an SMP");
80103e6d:	83 ec 0c             	sub    $0xc,%esp
80103e70:	68 6a 96 10 80       	push   $0x8010966a
80103e75:	e8 8e c7 ff ff       	call   80100608 <panic>
  ismp = 1;
80103e7a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103e81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e84:	8b 40 24             	mov    0x24(%eax),%eax
80103e87:	a3 1c 47 11 80       	mov    %eax,0x8011471c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e8f:	83 c0 2c             	add    $0x2c,%eax
80103e92:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e98:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e9c:	0f b7 d0             	movzwl %ax,%edx
80103e9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ea2:	01 d0                	add    %edx,%eax
80103ea4:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103ea7:	e9 8c 00 00 00       	jmp    80103f38 <mpinit+0xed>
    switch(*p){
80103eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eaf:	0f b6 00             	movzbl (%eax),%eax
80103eb2:	0f b6 c0             	movzbl %al,%eax
80103eb5:	83 f8 04             	cmp    $0x4,%eax
80103eb8:	7f 76                	jg     80103f30 <mpinit+0xe5>
80103eba:	83 f8 03             	cmp    $0x3,%eax
80103ebd:	7d 6b                	jge    80103f2a <mpinit+0xdf>
80103ebf:	83 f8 02             	cmp    $0x2,%eax
80103ec2:	74 4e                	je     80103f12 <mpinit+0xc7>
80103ec4:	83 f8 02             	cmp    $0x2,%eax
80103ec7:	7f 67                	jg     80103f30 <mpinit+0xe5>
80103ec9:	85 c0                	test   %eax,%eax
80103ecb:	74 07                	je     80103ed4 <mpinit+0x89>
80103ecd:	83 f8 01             	cmp    $0x1,%eax
80103ed0:	74 58                	je     80103f2a <mpinit+0xdf>
80103ed2:	eb 5c                	jmp    80103f30 <mpinit+0xe5>
    case MPPROC:
      proc = (struct mpproc*)p;
80103ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed7:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103eda:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103edf:	83 f8 07             	cmp    $0x7,%eax
80103ee2:	7f 28                	jg     80103f0c <mpinit+0xc1>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103ee4:	8b 15 a0 4d 11 80    	mov    0x80114da0,%edx
80103eea:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103eed:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ef1:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103ef7:	81 c2 20 48 11 80    	add    $0x80114820,%edx
80103efd:	88 02                	mov    %al,(%edx)
        ncpu++;
80103eff:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103f04:	83 c0 01             	add    $0x1,%eax
80103f07:	a3 a0 4d 11 80       	mov    %eax,0x80114da0
      }
      p += sizeof(struct mpproc);
80103f0c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103f10:	eb 26                	jmp    80103f38 <mpinit+0xed>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103f18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f1b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f1f:	a2 00 48 11 80       	mov    %al,0x80114800
      p += sizeof(struct mpioapic);
80103f24:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f28:	eb 0e                	jmp    80103f38 <mpinit+0xed>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f2a:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f2e:	eb 08                	jmp    80103f38 <mpinit+0xed>
    default:
      ismp = 0;
80103f30:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103f37:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f3b:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103f3e:	0f 82 68 ff ff ff    	jb     80103eac <mpinit+0x61>
    }
  }
  if(!ismp)
80103f44:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f48:	75 0d                	jne    80103f57 <mpinit+0x10c>
    panic("Didn't find a suitable machine");
80103f4a:	83 ec 0c             	sub    $0xc,%esp
80103f4d:	68 84 96 10 80       	push   $0x80109684
80103f52:	e8 b1 c6 ff ff       	call   80100608 <panic>

  if(mp->imcrp){
80103f57:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f5a:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f5e:	84 c0                	test   %al,%al
80103f60:	74 30                	je     80103f92 <mpinit+0x147>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f62:	83 ec 08             	sub    $0x8,%esp
80103f65:	6a 70                	push   $0x70
80103f67:	6a 22                	push   $0x22
80103f69:	e8 ae fc ff ff       	call   80103c1c <outb>
80103f6e:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103f71:	83 ec 0c             	sub    $0xc,%esp
80103f74:	6a 23                	push   $0x23
80103f76:	e8 84 fc ff ff       	call   80103bff <inb>
80103f7b:	83 c4 10             	add    $0x10,%esp
80103f7e:	83 c8 01             	or     $0x1,%eax
80103f81:	0f b6 c0             	movzbl %al,%eax
80103f84:	83 ec 08             	sub    $0x8,%esp
80103f87:	50                   	push   %eax
80103f88:	6a 23                	push   $0x23
80103f8a:	e8 8d fc ff ff       	call   80103c1c <outb>
80103f8f:	83 c4 10             	add    $0x10,%esp
  }
}
80103f92:	90                   	nop
80103f93:	c9                   	leave  
80103f94:	c3                   	ret    

80103f95 <outb>:
{
80103f95:	55                   	push   %ebp
80103f96:	89 e5                	mov    %esp,%ebp
80103f98:	83 ec 08             	sub    $0x8,%esp
80103f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fa1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103fa5:	89 d0                	mov    %edx,%eax
80103fa7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103faa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103fae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103fb2:	ee                   	out    %al,(%dx)
}
80103fb3:	90                   	nop
80103fb4:	c9                   	leave  
80103fb5:	c3                   	ret    

80103fb6 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103fb6:	f3 0f 1e fb          	endbr32 
80103fba:	55                   	push   %ebp
80103fbb:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103fbd:	68 ff 00 00 00       	push   $0xff
80103fc2:	6a 21                	push   $0x21
80103fc4:	e8 cc ff ff ff       	call   80103f95 <outb>
80103fc9:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103fcc:	68 ff 00 00 00       	push   $0xff
80103fd1:	68 a1 00 00 00       	push   $0xa1
80103fd6:	e8 ba ff ff ff       	call   80103f95 <outb>
80103fdb:	83 c4 08             	add    $0x8,%esp
}
80103fde:	90                   	nop
80103fdf:	c9                   	leave  
80103fe0:	c3                   	ret    

80103fe1 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fe1:	f3 0f 1e fb          	endbr32 
80103fe5:	55                   	push   %ebp
80103fe6:	89 e5                	mov    %esp,%ebp
80103fe8:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103feb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ff5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ffe:	8b 10                	mov    (%eax),%edx
80104000:	8b 45 08             	mov    0x8(%ebp),%eax
80104003:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104005:	e8 e2 d0 ff ff       	call   801010ec <filealloc>
8010400a:	8b 55 08             	mov    0x8(%ebp),%edx
8010400d:	89 02                	mov    %eax,(%edx)
8010400f:	8b 45 08             	mov    0x8(%ebp),%eax
80104012:	8b 00                	mov    (%eax),%eax
80104014:	85 c0                	test   %eax,%eax
80104016:	0f 84 c8 00 00 00    	je     801040e4 <pipealloc+0x103>
8010401c:	e8 cb d0 ff ff       	call   801010ec <filealloc>
80104021:	8b 55 0c             	mov    0xc(%ebp),%edx
80104024:	89 02                	mov    %eax,(%edx)
80104026:	8b 45 0c             	mov    0xc(%ebp),%eax
80104029:	8b 00                	mov    (%eax),%eax
8010402b:	85 c0                	test   %eax,%eax
8010402d:	0f 84 b1 00 00 00    	je     801040e4 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104033:	e8 ea ed ff ff       	call   80102e22 <kalloc>
80104038:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010403b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010403f:	0f 84 a2 00 00 00    	je     801040e7 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
80104045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104048:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010404f:	00 00 00 
  p->writeopen = 1;
80104052:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104055:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010405c:	00 00 00 
  p->nwrite = 0;
8010405f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104062:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104069:	00 00 00 
  p->nread = 0;
8010406c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406f:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104076:	00 00 00 
  initlock(&p->lock, "pipe");
80104079:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407c:	83 ec 08             	sub    $0x8,%esp
8010407f:	68 a3 96 10 80       	push   $0x801096a3
80104084:	50                   	push   %eax
80104085:	e8 29 12 00 00       	call   801052b3 <initlock>
8010408a:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010408d:	8b 45 08             	mov    0x8(%ebp),%eax
80104090:	8b 00                	mov    (%eax),%eax
80104092:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104098:	8b 45 08             	mov    0x8(%ebp),%eax
8010409b:	8b 00                	mov    (%eax),%eax
8010409d:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801040a1:	8b 45 08             	mov    0x8(%ebp),%eax
801040a4:	8b 00                	mov    (%eax),%eax
801040a6:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801040aa:	8b 45 08             	mov    0x8(%ebp),%eax
801040ad:	8b 00                	mov    (%eax),%eax
801040af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040b2:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801040b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b8:	8b 00                	mov    (%eax),%eax
801040ba:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801040c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c3:	8b 00                	mov    (%eax),%eax
801040c5:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801040c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801040cc:	8b 00                	mov    (%eax),%eax
801040ce:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801040d5:	8b 00                	mov    (%eax),%eax
801040d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040da:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040dd:	b8 00 00 00 00       	mov    $0x0,%eax
801040e2:	eb 51                	jmp    80104135 <pipealloc+0x154>
    goto bad;
801040e4:	90                   	nop
801040e5:	eb 01                	jmp    801040e8 <pipealloc+0x107>
    goto bad;
801040e7:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
801040e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040ec:	74 0e                	je     801040fc <pipealloc+0x11b>
    kfree((char*)p);
801040ee:	83 ec 0c             	sub    $0xc,%esp
801040f1:	ff 75 f4             	pushl  -0xc(%ebp)
801040f4:	e8 8b ec ff ff       	call   80102d84 <kfree>
801040f9:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801040fc:	8b 45 08             	mov    0x8(%ebp),%eax
801040ff:	8b 00                	mov    (%eax),%eax
80104101:	85 c0                	test   %eax,%eax
80104103:	74 11                	je     80104116 <pipealloc+0x135>
    fileclose(*f0);
80104105:	8b 45 08             	mov    0x8(%ebp),%eax
80104108:	8b 00                	mov    (%eax),%eax
8010410a:	83 ec 0c             	sub    $0xc,%esp
8010410d:	50                   	push   %eax
8010410e:	e8 9f d0 ff ff       	call   801011b2 <fileclose>
80104113:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104116:	8b 45 0c             	mov    0xc(%ebp),%eax
80104119:	8b 00                	mov    (%eax),%eax
8010411b:	85 c0                	test   %eax,%eax
8010411d:	74 11                	je     80104130 <pipealloc+0x14f>
    fileclose(*f1);
8010411f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104122:	8b 00                	mov    (%eax),%eax
80104124:	83 ec 0c             	sub    $0xc,%esp
80104127:	50                   	push   %eax
80104128:	e8 85 d0 ff ff       	call   801011b2 <fileclose>
8010412d:	83 c4 10             	add    $0x10,%esp
  return -1;
80104130:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104135:	c9                   	leave  
80104136:	c3                   	ret    

80104137 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104137:	f3 0f 1e fb          	endbr32 
8010413b:	55                   	push   %ebp
8010413c:	89 e5                	mov    %esp,%ebp
8010413e:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104141:	8b 45 08             	mov    0x8(%ebp),%eax
80104144:	83 ec 0c             	sub    $0xc,%esp
80104147:	50                   	push   %eax
80104148:	e8 8c 11 00 00       	call   801052d9 <acquire>
8010414d:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104150:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104154:	74 23                	je     80104179 <pipeclose+0x42>
    p->writeopen = 0;
80104156:	8b 45 08             	mov    0x8(%ebp),%eax
80104159:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104160:	00 00 00 
    wakeup(&p->nread);
80104163:	8b 45 08             	mov    0x8(%ebp),%eax
80104166:	05 34 02 00 00       	add    $0x234,%eax
8010416b:	83 ec 0c             	sub    $0xc,%esp
8010416e:	50                   	push   %eax
8010416f:	e8 e5 0d 00 00       	call   80104f59 <wakeup>
80104174:	83 c4 10             	add    $0x10,%esp
80104177:	eb 21                	jmp    8010419a <pipeclose+0x63>
  } else {
    p->readopen = 0;
80104179:	8b 45 08             	mov    0x8(%ebp),%eax
8010417c:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104183:	00 00 00 
    wakeup(&p->nwrite);
80104186:	8b 45 08             	mov    0x8(%ebp),%eax
80104189:	05 38 02 00 00       	add    $0x238,%eax
8010418e:	83 ec 0c             	sub    $0xc,%esp
80104191:	50                   	push   %eax
80104192:	e8 c2 0d 00 00       	call   80104f59 <wakeup>
80104197:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010419a:	8b 45 08             	mov    0x8(%ebp),%eax
8010419d:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041a3:	85 c0                	test   %eax,%eax
801041a5:	75 2c                	jne    801041d3 <pipeclose+0x9c>
801041a7:	8b 45 08             	mov    0x8(%ebp),%eax
801041aa:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801041b0:	85 c0                	test   %eax,%eax
801041b2:	75 1f                	jne    801041d3 <pipeclose+0x9c>
    release(&p->lock);
801041b4:	8b 45 08             	mov    0x8(%ebp),%eax
801041b7:	83 ec 0c             	sub    $0xc,%esp
801041ba:	50                   	push   %eax
801041bb:	e8 8b 11 00 00       	call   8010534b <release>
801041c0:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801041c3:	83 ec 0c             	sub    $0xc,%esp
801041c6:	ff 75 08             	pushl  0x8(%ebp)
801041c9:	e8 b6 eb ff ff       	call   80102d84 <kfree>
801041ce:	83 c4 10             	add    $0x10,%esp
801041d1:	eb 10                	jmp    801041e3 <pipeclose+0xac>
  } else
    release(&p->lock);
801041d3:	8b 45 08             	mov    0x8(%ebp),%eax
801041d6:	83 ec 0c             	sub    $0xc,%esp
801041d9:	50                   	push   %eax
801041da:	e8 6c 11 00 00       	call   8010534b <release>
801041df:	83 c4 10             	add    $0x10,%esp
}
801041e2:	90                   	nop
801041e3:	90                   	nop
801041e4:	c9                   	leave  
801041e5:	c3                   	ret    

801041e6 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801041e6:	f3 0f 1e fb          	endbr32 
801041ea:	55                   	push   %ebp
801041eb:	89 e5                	mov    %esp,%ebp
801041ed:	53                   	push   %ebx
801041ee:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801041f1:	8b 45 08             	mov    0x8(%ebp),%eax
801041f4:	83 ec 0c             	sub    $0xc,%esp
801041f7:	50                   	push   %eax
801041f8:	e8 dc 10 00 00       	call   801052d9 <acquire>
801041fd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104200:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104207:	e9 ad 00 00 00       	jmp    801042b9 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010420c:	8b 45 08             	mov    0x8(%ebp),%eax
8010420f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104215:	85 c0                	test   %eax,%eax
80104217:	74 0c                	je     80104225 <pipewrite+0x3f>
80104219:	e8 a2 02 00 00       	call   801044c0 <myproc>
8010421e:	8b 40 24             	mov    0x24(%eax),%eax
80104221:	85 c0                	test   %eax,%eax
80104223:	74 19                	je     8010423e <pipewrite+0x58>
        release(&p->lock);
80104225:	8b 45 08             	mov    0x8(%ebp),%eax
80104228:	83 ec 0c             	sub    $0xc,%esp
8010422b:	50                   	push   %eax
8010422c:	e8 1a 11 00 00       	call   8010534b <release>
80104231:	83 c4 10             	add    $0x10,%esp
        return -1;
80104234:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104239:	e9 a9 00 00 00       	jmp    801042e7 <pipewrite+0x101>
      }
      wakeup(&p->nread);
8010423e:	8b 45 08             	mov    0x8(%ebp),%eax
80104241:	05 34 02 00 00       	add    $0x234,%eax
80104246:	83 ec 0c             	sub    $0xc,%esp
80104249:	50                   	push   %eax
8010424a:	e8 0a 0d 00 00       	call   80104f59 <wakeup>
8010424f:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104252:	8b 45 08             	mov    0x8(%ebp),%eax
80104255:	8b 55 08             	mov    0x8(%ebp),%edx
80104258:	81 c2 38 02 00 00    	add    $0x238,%edx
8010425e:	83 ec 08             	sub    $0x8,%esp
80104261:	50                   	push   %eax
80104262:	52                   	push   %edx
80104263:	e8 ff 0b 00 00       	call   80104e67 <sleep>
80104268:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010426b:	8b 45 08             	mov    0x8(%ebp),%eax
8010426e:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104274:	8b 45 08             	mov    0x8(%ebp),%eax
80104277:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010427d:	05 00 02 00 00       	add    $0x200,%eax
80104282:	39 c2                	cmp    %eax,%edx
80104284:	74 86                	je     8010420c <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104286:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104289:	8b 45 0c             	mov    0xc(%ebp),%eax
8010428c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010428f:	8b 45 08             	mov    0x8(%ebp),%eax
80104292:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104298:	8d 48 01             	lea    0x1(%eax),%ecx
8010429b:	8b 55 08             	mov    0x8(%ebp),%edx
8010429e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801042a4:	25 ff 01 00 00       	and    $0x1ff,%eax
801042a9:	89 c1                	mov    %eax,%ecx
801042ab:	0f b6 13             	movzbl (%ebx),%edx
801042ae:	8b 45 08             	mov    0x8(%ebp),%eax
801042b1:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
801042b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042bc:	3b 45 10             	cmp    0x10(%ebp),%eax
801042bf:	7c aa                	jl     8010426b <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801042c1:	8b 45 08             	mov    0x8(%ebp),%eax
801042c4:	05 34 02 00 00       	add    $0x234,%eax
801042c9:	83 ec 0c             	sub    $0xc,%esp
801042cc:	50                   	push   %eax
801042cd:	e8 87 0c 00 00       	call   80104f59 <wakeup>
801042d2:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801042d5:	8b 45 08             	mov    0x8(%ebp),%eax
801042d8:	83 ec 0c             	sub    $0xc,%esp
801042db:	50                   	push   %eax
801042dc:	e8 6a 10 00 00       	call   8010534b <release>
801042e1:	83 c4 10             	add    $0x10,%esp
  return n;
801042e4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801042e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042ea:	c9                   	leave  
801042eb:	c3                   	ret    

801042ec <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801042ec:	f3 0f 1e fb          	endbr32 
801042f0:	55                   	push   %ebp
801042f1:	89 e5                	mov    %esp,%ebp
801042f3:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801042f6:	8b 45 08             	mov    0x8(%ebp),%eax
801042f9:	83 ec 0c             	sub    $0xc,%esp
801042fc:	50                   	push   %eax
801042fd:	e8 d7 0f 00 00       	call   801052d9 <acquire>
80104302:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104305:	eb 3e                	jmp    80104345 <piperead+0x59>
    if(myproc()->killed){
80104307:	e8 b4 01 00 00       	call   801044c0 <myproc>
8010430c:	8b 40 24             	mov    0x24(%eax),%eax
8010430f:	85 c0                	test   %eax,%eax
80104311:	74 19                	je     8010432c <piperead+0x40>
      release(&p->lock);
80104313:	8b 45 08             	mov    0x8(%ebp),%eax
80104316:	83 ec 0c             	sub    $0xc,%esp
80104319:	50                   	push   %eax
8010431a:	e8 2c 10 00 00       	call   8010534b <release>
8010431f:	83 c4 10             	add    $0x10,%esp
      return -1;
80104322:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104327:	e9 be 00 00 00       	jmp    801043ea <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010432c:	8b 45 08             	mov    0x8(%ebp),%eax
8010432f:	8b 55 08             	mov    0x8(%ebp),%edx
80104332:	81 c2 34 02 00 00    	add    $0x234,%edx
80104338:	83 ec 08             	sub    $0x8,%esp
8010433b:	50                   	push   %eax
8010433c:	52                   	push   %edx
8010433d:	e8 25 0b 00 00       	call   80104e67 <sleep>
80104342:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104345:	8b 45 08             	mov    0x8(%ebp),%eax
80104348:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010434e:	8b 45 08             	mov    0x8(%ebp),%eax
80104351:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104357:	39 c2                	cmp    %eax,%edx
80104359:	75 0d                	jne    80104368 <piperead+0x7c>
8010435b:	8b 45 08             	mov    0x8(%ebp),%eax
8010435e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104364:	85 c0                	test   %eax,%eax
80104366:	75 9f                	jne    80104307 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104368:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010436f:	eb 48                	jmp    801043b9 <piperead+0xcd>
    if(p->nread == p->nwrite)
80104371:	8b 45 08             	mov    0x8(%ebp),%eax
80104374:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010437a:	8b 45 08             	mov    0x8(%ebp),%eax
8010437d:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104383:	39 c2                	cmp    %eax,%edx
80104385:	74 3c                	je     801043c3 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104387:	8b 45 08             	mov    0x8(%ebp),%eax
8010438a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104390:	8d 48 01             	lea    0x1(%eax),%ecx
80104393:	8b 55 08             	mov    0x8(%ebp),%edx
80104396:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010439c:	25 ff 01 00 00       	and    $0x1ff,%eax
801043a1:	89 c1                	mov    %eax,%ecx
801043a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801043a9:	01 c2                	add    %eax,%edx
801043ab:	8b 45 08             	mov    0x8(%ebp),%eax
801043ae:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
801043b3:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801043b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043bc:	3b 45 10             	cmp    0x10(%ebp),%eax
801043bf:	7c b0                	jl     80104371 <piperead+0x85>
801043c1:	eb 01                	jmp    801043c4 <piperead+0xd8>
      break;
801043c3:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801043c4:	8b 45 08             	mov    0x8(%ebp),%eax
801043c7:	05 38 02 00 00       	add    $0x238,%eax
801043cc:	83 ec 0c             	sub    $0xc,%esp
801043cf:	50                   	push   %eax
801043d0:	e8 84 0b 00 00       	call   80104f59 <wakeup>
801043d5:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043d8:	8b 45 08             	mov    0x8(%ebp),%eax
801043db:	83 ec 0c             	sub    $0xc,%esp
801043de:	50                   	push   %eax
801043df:	e8 67 0f 00 00       	call   8010534b <release>
801043e4:	83 c4 10             	add    $0x10,%esp
  return i;
801043e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043ea:	c9                   	leave  
801043eb:	c3                   	ret    

801043ec <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801043ec:	55                   	push   %ebp
801043ed:	89 e5                	mov    %esp,%ebp
801043ef:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801043f2:	9c                   	pushf  
801043f3:	58                   	pop    %eax
801043f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801043f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043fa:	c9                   	leave  
801043fb:	c3                   	ret    

801043fc <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801043fc:	55                   	push   %ebp
801043fd:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801043ff:	fb                   	sti    
}
80104400:	90                   	nop
80104401:	5d                   	pop    %ebp
80104402:	c3                   	ret    

80104403 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104403:	f3 0f 1e fb          	endbr32 
80104407:	55                   	push   %ebp
80104408:	89 e5                	mov    %esp,%ebp
8010440a:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010440d:	83 ec 08             	sub    $0x8,%esp
80104410:	68 a8 96 10 80       	push   $0x801096a8
80104415:	68 c0 4d 11 80       	push   $0x80114dc0
8010441a:	e8 94 0e 00 00       	call   801052b3 <initlock>
8010441f:	83 c4 10             	add    $0x10,%esp
}
80104422:	90                   	nop
80104423:	c9                   	leave  
80104424:	c3                   	ret    

80104425 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104425:	f3 0f 1e fb          	endbr32 
80104429:	55                   	push   %ebp
8010442a:	89 e5                	mov    %esp,%ebp
8010442c:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010442f:	e8 10 00 00 00       	call   80104444 <mycpu>
80104434:	2d 20 48 11 80       	sub    $0x80114820,%eax
80104439:	c1 f8 04             	sar    $0x4,%eax
8010443c:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104442:	c9                   	leave  
80104443:	c3                   	ret    

80104444 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104444:	f3 0f 1e fb          	endbr32 
80104448:	55                   	push   %ebp
80104449:	89 e5                	mov    %esp,%ebp
8010444b:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
8010444e:	e8 99 ff ff ff       	call   801043ec <readeflags>
80104453:	25 00 02 00 00       	and    $0x200,%eax
80104458:	85 c0                	test   %eax,%eax
8010445a:	74 0d                	je     80104469 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
8010445c:	83 ec 0c             	sub    $0xc,%esp
8010445f:	68 b0 96 10 80       	push   $0x801096b0
80104464:	e8 9f c1 ff ff       	call   80100608 <panic>
  
  apicid = lapicid();
80104469:	e8 21 ed ff ff       	call   8010318f <lapicid>
8010446e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104471:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104478:	eb 2d                	jmp    801044a7 <mycpu+0x63>
    if (cpus[i].apicid == apicid)
8010447a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104483:	05 20 48 11 80       	add    $0x80114820,%eax
80104488:	0f b6 00             	movzbl (%eax),%eax
8010448b:	0f b6 c0             	movzbl %al,%eax
8010448e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104491:	75 10                	jne    801044a3 <mycpu+0x5f>
      return &cpus[i];
80104493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104496:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010449c:	05 20 48 11 80       	add    $0x80114820,%eax
801044a1:	eb 1b                	jmp    801044be <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
801044a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801044a7:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
801044ac:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801044af:	7c c9                	jl     8010447a <mycpu+0x36>
  }
  panic("unknown apicid\n");
801044b1:	83 ec 0c             	sub    $0xc,%esp
801044b4:	68 d6 96 10 80       	push   $0x801096d6
801044b9:	e8 4a c1 ff ff       	call   80100608 <panic>
}
801044be:	c9                   	leave  
801044bf:	c3                   	ret    

801044c0 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801044c0:	f3 0f 1e fb          	endbr32 
801044c4:	55                   	push   %ebp
801044c5:	89 e5                	mov    %esp,%ebp
801044c7:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801044ca:	e8 96 0f 00 00       	call   80105465 <pushcli>
  c = mycpu();
801044cf:	e8 70 ff ff ff       	call   80104444 <mycpu>
801044d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801044d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044da:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801044e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801044e3:	e8 ce 0f 00 00       	call   801054b6 <popcli>
  return p;
801044e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801044eb:	c9                   	leave  
801044ec:	c3                   	ret    

801044ed <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801044ed:	f3 0f 1e fb          	endbr32 
801044f1:	55                   	push   %ebp
801044f2:	89 e5                	mov    %esp,%ebp
801044f4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044f7:	83 ec 0c             	sub    $0xc,%esp
801044fa:	68 c0 4d 11 80       	push   $0x80114dc0
801044ff:	e8 d5 0d 00 00       	call   801052d9 <acquire>
80104504:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104507:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
8010450e:	eb 11                	jmp    80104521 <allocproc+0x34>
    if(p->state == UNUSED)
80104510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104513:	8b 40 0c             	mov    0xc(%eax),%eax
80104516:	85 c0                	test   %eax,%eax
80104518:	74 2a                	je     80104544 <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010451a:	81 45 f4 c8 00 00 00 	addl   $0xc8,-0xc(%ebp)
80104521:	81 7d f4 f4 7f 11 80 	cmpl   $0x80117ff4,-0xc(%ebp)
80104528:	72 e6                	jb     80104510 <allocproc+0x23>
      goto found;

  release(&ptable.lock);
8010452a:	83 ec 0c             	sub    $0xc,%esp
8010452d:	68 c0 4d 11 80       	push   $0x80114dc0
80104532:	e8 14 0e 00 00       	call   8010534b <release>
80104537:	83 c4 10             	add    $0x10,%esp
  return 0;
8010453a:	b8 00 00 00 00       	mov    $0x0,%eax
8010453f:	e9 e0 00 00 00       	jmp    80104624 <allocproc+0x137>
      goto found;
80104544:	90                   	nop
80104545:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80104549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454c:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104553:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80104558:	8d 50 01             	lea    0x1(%eax),%edx
8010455b:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
80104561:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104564:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80104567:	83 ec 0c             	sub    $0xc,%esp
8010456a:	68 c0 4d 11 80       	push   $0x80114dc0
8010456f:	e8 d7 0d 00 00       	call   8010534b <release>
80104574:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104577:	e8 a6 e8 ff ff       	call   80102e22 <kalloc>
8010457c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010457f:	89 42 08             	mov    %eax,0x8(%edx)
80104582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104585:	8b 40 08             	mov    0x8(%eax),%eax
80104588:	85 c0                	test   %eax,%eax
8010458a:	75 14                	jne    801045a0 <allocproc+0xb3>
    p->state = UNUSED;
8010458c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104596:	b8 00 00 00 00       	mov    $0x0,%eax
8010459b:	e9 84 00 00 00       	jmp    80104624 <allocproc+0x137>
  }
  sp = p->kstack + KSTACKSIZE;
801045a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a3:	8b 40 08             	mov    0x8(%eax),%eax
801045a6:	05 00 10 00 00       	add    $0x1000,%eax
801045ab:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801045ae:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801045b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045b8:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801045bb:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801045bf:	ba fc 6a 10 80       	mov    $0x80106afc,%edx
801045c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045c7:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801045c9:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801045cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045d3:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801045d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d9:	8b 40 1c             	mov    0x1c(%eax),%eax
801045dc:	83 ec 04             	sub    $0x4,%esp
801045df:	6a 14                	push   $0x14
801045e1:	6a 00                	push   $0x0
801045e3:	50                   	push   %eax
801045e4:	e8 8f 0f 00 00       	call   80105578 <memset>
801045e9:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801045ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ef:	8b 40 1c             	mov    0x1c(%eax),%eax
801045f2:	ba 1d 4e 10 80       	mov    $0x80104e1d,%edx
801045f7:	89 50 10             	mov    %edx,0x10(%eax)
  p->queue_size = 0;
801045fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fd:	c7 80 bc 00 00 00 00 	movl   $0x0,0xbc(%eax)
80104604:	00 00 00 
  p->hand = 0;
80104607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460a:	c7 80 c4 00 00 00 00 	movl   $0x0,0xc4(%eax)
80104611:	00 00 00 
  p->head = 0;
80104614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104617:	c7 80 c0 00 00 00 00 	movl   $0x0,0xc0(%eax)
8010461e:	00 00 00 
  return p;
80104621:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104624:	c9                   	leave  
80104625:	c3                   	ret    

80104626 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104626:	f3 0f 1e fb          	endbr32 
8010462a:	55                   	push   %ebp
8010462b:	89 e5                	mov    %esp,%ebp
8010462d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104630:	e8 b8 fe ff ff       	call   801044ed <allocproc>
80104635:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463b:	a3 40 c6 10 80       	mov    %eax,0x8010c640
  if((p->pgdir = setupkvm()) == 0)
80104640:	e8 b3 3f 00 00       	call   801085f8 <setupkvm>
80104645:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104648:	89 42 04             	mov    %eax,0x4(%edx)
8010464b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464e:	8b 40 04             	mov    0x4(%eax),%eax
80104651:	85 c0                	test   %eax,%eax
80104653:	75 0d                	jne    80104662 <userinit+0x3c>
    panic("userinit: out of memory?");
80104655:	83 ec 0c             	sub    $0xc,%esp
80104658:	68 e6 96 10 80       	push   $0x801096e6
8010465d:	e8 a6 bf ff ff       	call   80100608 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104662:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104667:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466a:	8b 40 04             	mov    0x4(%eax),%eax
8010466d:	83 ec 04             	sub    $0x4,%esp
80104670:	52                   	push   %edx
80104671:	68 e0 c4 10 80       	push   $0x8010c4e0
80104676:	50                   	push   %eax
80104677:	e8 f5 41 00 00       	call   80108871 <inituvm>
8010467c:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010467f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104682:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468b:	8b 40 18             	mov    0x18(%eax),%eax
8010468e:	83 ec 04             	sub    $0x4,%esp
80104691:	6a 4c                	push   $0x4c
80104693:	6a 00                	push   $0x0
80104695:	50                   	push   %eax
80104696:	e8 dd 0e 00 00       	call   80105578 <memset>
8010469b:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010469e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a1:	8b 40 18             	mov    0x18(%eax),%eax
801046a4:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801046aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ad:	8b 40 18             	mov    0x18(%eax),%eax
801046b0:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801046b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b9:	8b 50 18             	mov    0x18(%eax),%edx
801046bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046bf:	8b 40 18             	mov    0x18(%eax),%eax
801046c2:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046c6:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801046ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cd:	8b 50 18             	mov    0x18(%eax),%edx
801046d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d3:	8b 40 18             	mov    0x18(%eax),%eax
801046d6:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046da:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801046de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e1:	8b 40 18             	mov    0x18(%eax),%eax
801046e4:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801046eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ee:	8b 40 18             	mov    0x18(%eax),%eax
801046f1:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801046f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fb:	8b 40 18             	mov    0x18(%eax),%eax
801046fe:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104705:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104708:	83 c0 6c             	add    $0x6c,%eax
8010470b:	83 ec 04             	sub    $0x4,%esp
8010470e:	6a 10                	push   $0x10
80104710:	68 ff 96 10 80       	push   $0x801096ff
80104715:	50                   	push   %eax
80104716:	e8 78 10 00 00       	call   80105793 <safestrcpy>
8010471b:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010471e:	83 ec 0c             	sub    $0xc,%esp
80104721:	68 08 97 10 80       	push   $0x80109708
80104726:	e8 72 df ff ff       	call   8010269d <namei>
8010472b:	83 c4 10             	add    $0x10,%esp
8010472e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104731:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104734:	83 ec 0c             	sub    $0xc,%esp
80104737:	68 c0 4d 11 80       	push   $0x80114dc0
8010473c:	e8 98 0b 00 00       	call   801052d9 <acquire>
80104741:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104747:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010474e:	83 ec 0c             	sub    $0xc,%esp
80104751:	68 c0 4d 11 80       	push   $0x80114dc0
80104756:	e8 f0 0b 00 00       	call   8010534b <release>
8010475b:	83 c4 10             	add    $0x10,%esp
}
8010475e:	90                   	nop
8010475f:	c9                   	leave  
80104760:	c3                   	ret    

80104761 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104761:	f3 0f 1e fb          	endbr32 
80104765:	55                   	push   %ebp
80104766:	89 e5                	mov    %esp,%ebp
80104768:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
8010476b:	e8 50 fd ff ff       	call   801044c0 <myproc>
80104770:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104773:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104776:	8b 00                	mov    (%eax),%eax
80104778:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010477b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010477f:	7e 4f                	jle    801047d0 <growproc+0x6f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104781:	8b 55 08             	mov    0x8(%ebp),%edx
80104784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104787:	01 c2                	add    %eax,%edx
80104789:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010478c:	8b 40 04             	mov    0x4(%eax),%eax
8010478f:	83 ec 04             	sub    $0x4,%esp
80104792:	52                   	push   %edx
80104793:	ff 75 f4             	pushl  -0xc(%ebp)
80104796:	50                   	push   %eax
80104797:	e8 1a 42 00 00       	call   801089b6 <allocuvm>
8010479c:	83 c4 10             	add    $0x10,%esp
8010479f:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047a6:	75 07                	jne    801047af <growproc+0x4e>
      return -1;
801047a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047ad:	eb 6f                	jmp    8010481e <growproc+0xbd>
    // for (void * i = (void*) PGROUNDDOWN(((int)curproc->sz)); i >= 0; i-=PGSIZE) {
    mencrypt((void*)PGROUNDDOWN((int)curproc->sz), (PGROUNDDOWN(n)/PGSIZE));
801047af:	8b 45 08             	mov    0x8(%ebp),%eax
801047b2:	c1 f8 0c             	sar    $0xc,%eax
801047b5:	89 c2                	mov    %eax,%edx
801047b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047ba:	8b 00                	mov    (%eax),%eax
801047bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801047c1:	83 ec 08             	sub    $0x8,%esp
801047c4:	52                   	push   %edx
801047c5:	50                   	push   %eax
801047c6:	e8 8e 47 00 00       	call   80108f59 <mencrypt>
801047cb:	83 c4 10             	add    $0x10,%esp
801047ce:	eb 33                	jmp    80104803 <growproc+0xa2>
    // }
  } else if(n < 0){
801047d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047d4:	79 2d                	jns    80104803 <growproc+0xa2>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n, 1)) == 0)
801047d6:	8b 55 08             	mov    0x8(%ebp),%edx
801047d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047dc:	01 c2                	add    %eax,%edx
801047de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047e1:	8b 40 04             	mov    0x4(%eax),%eax
801047e4:	6a 01                	push   $0x1
801047e6:	52                   	push   %edx
801047e7:	ff 75 f4             	pushl  -0xc(%ebp)
801047ea:	50                   	push   %eax
801047eb:	e8 cd 42 00 00       	call   80108abd <deallocuvm>
801047f0:	83 c4 10             	add    $0x10,%esp
801047f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047fa:	75 07                	jne    80104803 <growproc+0xa2>
      return -1;
801047fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104801:	eb 1b                	jmp    8010481e <growproc+0xbd>
    //  break;
  //}
    //walk through the page table and read the entries
    //Those entries contain the physical page number + flags

  curproc->sz = sz;
80104803:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104806:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104809:	89 10                	mov    %edx,(%eax)

  switchuvm(curproc);
8010480b:	83 ec 0c             	sub    $0xc,%esp
8010480e:	ff 75 f0             	pushl  -0x10(%ebp)
80104811:	e8 b8 3e 00 00       	call   801086ce <switchuvm>
80104816:	83 c4 10             	add    $0x10,%esp
  return 0;
80104819:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010481e:	c9                   	leave  
8010481f:	c3                   	ret    

80104820 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104820:	f3 0f 1e fb          	endbr32 
80104824:	55                   	push   %ebp
80104825:	89 e5                	mov    %esp,%ebp
80104827:	57                   	push   %edi
80104828:	56                   	push   %esi
80104829:	53                   	push   %ebx
8010482a:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010482d:	e8 8e fc ff ff       	call   801044c0 <myproc>
80104832:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104835:	e8 b3 fc ff ff       	call   801044ed <allocproc>
8010483a:	89 45 d8             	mov    %eax,-0x28(%ebp)
8010483d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80104841:	75 0a                	jne    8010484d <fork+0x2d>
    return -1;
80104843:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104848:	e9 a2 01 00 00       	jmp    801049ef <fork+0x1cf>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010484d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104850:	8b 10                	mov    (%eax),%edx
80104852:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104855:	8b 40 04             	mov    0x4(%eax),%eax
80104858:	83 ec 08             	sub    $0x8,%esp
8010485b:	52                   	push   %edx
8010485c:	50                   	push   %eax
8010485d:	e8 1b 44 00 00       	call   80108c7d <copyuvm>
80104862:	83 c4 10             	add    $0x10,%esp
80104865:	8b 55 d8             	mov    -0x28(%ebp),%edx
80104868:	89 42 04             	mov    %eax,0x4(%edx)
8010486b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010486e:	8b 40 04             	mov    0x4(%eax),%eax
80104871:	85 c0                	test   %eax,%eax
80104873:	75 30                	jne    801048a5 <fork+0x85>
    kfree(np->kstack);
80104875:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104878:	8b 40 08             	mov    0x8(%eax),%eax
8010487b:	83 ec 0c             	sub    $0xc,%esp
8010487e:	50                   	push   %eax
8010487f:	e8 00 e5 ff ff       	call   80102d84 <kfree>
80104884:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104887:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010488a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104891:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104894:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010489b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048a0:	e9 4a 01 00 00       	jmp    801049ef <fork+0x1cf>
  }
  // curproc->child = np;
  np->sz = curproc->sz;
801048a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048a8:	8b 10                	mov    (%eax),%edx
801048aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
801048ad:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801048af:	8b 45 d8             	mov    -0x28(%ebp),%eax
801048b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
801048b5:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801048b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048bb:	8b 48 18             	mov    0x18(%eax),%ecx
801048be:	8b 45 d8             	mov    -0x28(%ebp),%eax
801048c1:	8b 40 18             	mov    0x18(%eax),%eax
801048c4:	89 c2                	mov    %eax,%edx
801048c6:	89 cb                	mov    %ecx,%ebx
801048c8:	b8 13 00 00 00       	mov    $0x13,%eax
801048cd:	89 d7                	mov    %edx,%edi
801048cf:	89 de                	mov    %ebx,%esi
801048d1:	89 c1                	mov    %eax,%ecx
801048d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->hand = curproc->hand;
801048d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048d8:	8b 90 c4 00 00 00    	mov    0xc4(%eax),%edx
801048de:	8b 45 d8             	mov    -0x28(%ebp),%eax
801048e1:	89 90 c4 00 00 00    	mov    %edx,0xc4(%eax)
  np->queue_size = curproc->queue_size;
801048e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048ea:	8b 90 bc 00 00 00    	mov    0xbc(%eax),%edx
801048f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801048f3:	89 90 bc 00 00 00    	mov    %edx,0xbc(%eax)
  for(int i = 0; i < 8; i++){
801048f9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80104900:	eb 27                	jmp    80104929 <fork+0x109>
    np->clock_queue[i] = curproc->clock_queue[i];
80104902:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80104905:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104908:	8d 58 0e             	lea    0xe(%eax),%ebx
8010490b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010490e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104911:	83 c2 0e             	add    $0xe,%edx
80104914:	8d 54 d0 0c          	lea    0xc(%eax,%edx,8),%edx
80104918:	8b 02                	mov    (%edx),%eax
8010491a:	8b 52 04             	mov    0x4(%edx),%edx
8010491d:	89 44 d9 0c          	mov    %eax,0xc(%ecx,%ebx,8)
80104921:	89 54 d9 10          	mov    %edx,0x10(%ecx,%ebx,8)
  for(int i = 0; i < 8; i++){
80104925:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80104929:	83 7d e0 07          	cmpl   $0x7,-0x20(%ebp)
8010492d:	7e d3                	jle    80104902 <fork+0xe2>
    // np->clock_queue[i].va = curproc->clock_queue[i].va;

      }

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010492f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104932:	8b 40 18             	mov    0x18(%eax),%eax
80104935:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010493c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104943:	eb 3b                	jmp    80104980 <fork+0x160>
    if(curproc->ofile[i])
80104945:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104948:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010494b:	83 c2 08             	add    $0x8,%edx
8010494e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104952:	85 c0                	test   %eax,%eax
80104954:	74 26                	je     8010497c <fork+0x15c>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104956:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104959:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010495c:	83 c2 08             	add    $0x8,%edx
8010495f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104963:	83 ec 0c             	sub    $0xc,%esp
80104966:	50                   	push   %eax
80104967:	e8 f1 c7 ff ff       	call   8010115d <filedup>
8010496c:	83 c4 10             	add    $0x10,%esp
8010496f:	8b 55 d8             	mov    -0x28(%ebp),%edx
80104972:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104975:	83 c1 08             	add    $0x8,%ecx
80104978:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
8010497c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104980:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104984:	7e bf                	jle    80104945 <fork+0x125>
  np->cwd = idup(curproc->cwd);
80104986:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104989:	8b 40 68             	mov    0x68(%eax),%eax
8010498c:	83 ec 0c             	sub    $0xc,%esp
8010498f:	50                   	push   %eax
80104990:	e8 5f d1 ff ff       	call   80101af4 <idup>
80104995:	83 c4 10             	add    $0x10,%esp
80104998:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010499b:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010499e:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049a1:	8d 50 6c             	lea    0x6c(%eax),%edx
801049a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801049a7:	83 c0 6c             	add    $0x6c,%eax
801049aa:	83 ec 04             	sub    $0x4,%esp
801049ad:	6a 10                	push   $0x10
801049af:	52                   	push   %edx
801049b0:	50                   	push   %eax
801049b1:	e8 dd 0d 00 00       	call   80105793 <safestrcpy>
801049b6:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801049b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801049bc:	8b 40 10             	mov    0x10(%eax),%eax
801049bf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

  acquire(&ptable.lock);
801049c2:	83 ec 0c             	sub    $0xc,%esp
801049c5:	68 c0 4d 11 80       	push   $0x80114dc0
801049ca:	e8 0a 09 00 00       	call   801052d9 <acquire>
801049cf:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801049d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801049d5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801049dc:	83 ec 0c             	sub    $0xc,%esp
801049df:	68 c0 4d 11 80       	push   $0x80114dc0
801049e4:	e8 62 09 00 00       	call   8010534b <release>
801049e9:	83 c4 10             	add    $0x10,%esp

  return pid;
801049ec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
801049ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
801049f2:	5b                   	pop    %ebx
801049f3:	5e                   	pop    %esi
801049f4:	5f                   	pop    %edi
801049f5:	5d                   	pop    %ebp
801049f6:	c3                   	ret    

801049f7 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801049f7:	f3 0f 1e fb          	endbr32 
801049fb:	55                   	push   %ebp
801049fc:	89 e5                	mov    %esp,%ebp
801049fe:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104a01:	e8 ba fa ff ff       	call   801044c0 <myproc>
80104a06:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104a09:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104a0e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a11:	75 0d                	jne    80104a20 <exit+0x29>
    panic("init exiting");
80104a13:	83 ec 0c             	sub    $0xc,%esp
80104a16:	68 0a 97 10 80       	push   $0x8010970a
80104a1b:	e8 e8 bb ff ff       	call   80100608 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a20:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a27:	eb 3f                	jmp    80104a68 <exit+0x71>
    if(curproc->ofile[fd]){
80104a29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a2f:	83 c2 08             	add    $0x8,%edx
80104a32:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a36:	85 c0                	test   %eax,%eax
80104a38:	74 2a                	je     80104a64 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104a3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a3d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a40:	83 c2 08             	add    $0x8,%edx
80104a43:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a47:	83 ec 0c             	sub    $0xc,%esp
80104a4a:	50                   	push   %eax
80104a4b:	e8 62 c7 ff ff       	call   801011b2 <fileclose>
80104a50:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104a53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a56:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a59:	83 c2 08             	add    $0x8,%edx
80104a5c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104a63:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104a64:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a68:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104a6c:	7e bb                	jle    80104a29 <exit+0x32>
    }
  }

  begin_op();
80104a6e:	e8 8e ec ff ff       	call   80103701 <begin_op>
  iput(curproc->cwd);
80104a73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a76:	8b 40 68             	mov    0x68(%eax),%eax
80104a79:	83 ec 0c             	sub    $0xc,%esp
80104a7c:	50                   	push   %eax
80104a7d:	e8 19 d2 ff ff       	call   80101c9b <iput>
80104a82:	83 c4 10             	add    $0x10,%esp
  end_op();
80104a85:	e8 07 ed ff ff       	call   80103791 <end_op>
  curproc->cwd = 0;
80104a8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a8d:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104a94:	83 ec 0c             	sub    $0xc,%esp
80104a97:	68 c0 4d 11 80       	push   $0x80114dc0
80104a9c:	e8 38 08 00 00       	call   801052d9 <acquire>
80104aa1:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104aa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aa7:	8b 40 14             	mov    0x14(%eax),%eax
80104aaa:	83 ec 0c             	sub    $0xc,%esp
80104aad:	50                   	push   %eax
80104aae:	e8 5f 04 00 00       	call   80104f12 <wakeup1>
80104ab3:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ab6:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104abd:	eb 3a                	jmp    80104af9 <exit+0x102>
    if(p->parent == curproc){
80104abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac2:	8b 40 14             	mov    0x14(%eax),%eax
80104ac5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104ac8:	75 28                	jne    80104af2 <exit+0xfb>
      p->parent = initproc;
80104aca:	8b 15 40 c6 10 80    	mov    0x8010c640,%edx
80104ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad3:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad9:	8b 40 0c             	mov    0xc(%eax),%eax
80104adc:	83 f8 05             	cmp    $0x5,%eax
80104adf:	75 11                	jne    80104af2 <exit+0xfb>
        wakeup1(initproc);
80104ae1:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104ae6:	83 ec 0c             	sub    $0xc,%esp
80104ae9:	50                   	push   %eax
80104aea:	e8 23 04 00 00       	call   80104f12 <wakeup1>
80104aef:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104af2:	81 45 f4 c8 00 00 00 	addl   $0xc8,-0xc(%ebp)
80104af9:	81 7d f4 f4 7f 11 80 	cmpl   $0x80117ff4,-0xc(%ebp)
80104b00:	72 bd                	jb     80104abf <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104b02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b05:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104b0c:	e8 11 02 00 00       	call   80104d22 <sched>
  panic("zombie exit");
80104b11:	83 ec 0c             	sub    $0xc,%esp
80104b14:	68 17 97 10 80       	push   $0x80109717
80104b19:	e8 ea ba ff ff       	call   80100608 <panic>

80104b1e <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104b1e:	f3 0f 1e fb          	endbr32 
80104b22:	55                   	push   %ebp
80104b23:	89 e5                	mov    %esp,%ebp
80104b25:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104b28:	e8 93 f9 ff ff       	call   801044c0 <myproc>
80104b2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104b30:	83 ec 0c             	sub    $0xc,%esp
80104b33:	68 c0 4d 11 80       	push   $0x80114dc0
80104b38:	e8 9c 07 00 00       	call   801052d9 <acquire>
80104b3d:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104b40:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b47:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104b4e:	e9 c2 00 00 00       	jmp    80104c15 <wait+0xf7>
      if(p->parent != curproc)
80104b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b56:	8b 40 14             	mov    0x14(%eax),%eax
80104b59:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104b5c:	0f 85 ab 00 00 00    	jne    80104c0d <wait+0xef>
        continue;
      havekids = 1;
80104b62:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b6c:	8b 40 0c             	mov    0xc(%eax),%eax
80104b6f:	83 f8 05             	cmp    $0x5,%eax
80104b72:	0f 85 96 00 00 00    	jne    80104c0e <wait+0xf0>
        // Found one.
        pid = p->pid;
80104b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b7b:	8b 40 10             	mov    0x10(%eax),%eax
80104b7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b84:	8b 40 08             	mov    0x8(%eax),%eax
80104b87:	83 ec 0c             	sub    $0xc,%esp
80104b8a:	50                   	push   %eax
80104b8b:	e8 f4 e1 ff ff       	call   80102d84 <kfree>
80104b90:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b96:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba0:	8b 40 04             	mov    0x4(%eax),%eax
80104ba3:	83 ec 0c             	sub    $0xc,%esp
80104ba6:	50                   	push   %eax
80104ba7:	e8 f0 3f 00 00       	call   80108b9c <freevm>
80104bac:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb2:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->hand=0;
80104bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc6:	c7 80 c4 00 00 00 00 	movl   $0x0,0xc4(%eax)
80104bcd:	00 00 00 
        p->queue_size=0;
80104bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd3:	c7 80 bc 00 00 00 00 	movl   $0x0,0xbc(%eax)
80104bda:	00 00 00 
        p->name[0] = 0;
80104bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be0:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be7:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104bf8:	83 ec 0c             	sub    $0xc,%esp
80104bfb:	68 c0 4d 11 80       	push   $0x80114dc0
80104c00:	e8 46 07 00 00       	call   8010534b <release>
80104c05:	83 c4 10             	add    $0x10,%esp
        return pid;
80104c08:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104c0b:	eb 54                	jmp    80104c61 <wait+0x143>
        continue;
80104c0d:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c0e:	81 45 f4 c8 00 00 00 	addl   $0xc8,-0xc(%ebp)
80104c15:	81 7d f4 f4 7f 11 80 	cmpl   $0x80117ff4,-0xc(%ebp)
80104c1c:	0f 82 31 ff ff ff    	jb     80104b53 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104c22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c26:	74 0a                	je     80104c32 <wait+0x114>
80104c28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c2b:	8b 40 24             	mov    0x24(%eax),%eax
80104c2e:	85 c0                	test   %eax,%eax
80104c30:	74 17                	je     80104c49 <wait+0x12b>
      release(&ptable.lock);
80104c32:	83 ec 0c             	sub    $0xc,%esp
80104c35:	68 c0 4d 11 80       	push   $0x80114dc0
80104c3a:	e8 0c 07 00 00       	call   8010534b <release>
80104c3f:	83 c4 10             	add    $0x10,%esp
      return -1;
80104c42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c47:	eb 18                	jmp    80104c61 <wait+0x143>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104c49:	83 ec 08             	sub    $0x8,%esp
80104c4c:	68 c0 4d 11 80       	push   $0x80114dc0
80104c51:	ff 75 ec             	pushl  -0x14(%ebp)
80104c54:	e8 0e 02 00 00       	call   80104e67 <sleep>
80104c59:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104c5c:	e9 df fe ff ff       	jmp    80104b40 <wait+0x22>
  }
}
80104c61:	c9                   	leave  
80104c62:	c3                   	ret    

80104c63 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c63:	f3 0f 1e fb          	endbr32 
80104c67:	55                   	push   %ebp
80104c68:	89 e5                	mov    %esp,%ebp
80104c6a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104c6d:	e8 d2 f7 ff ff       	call   80104444 <mycpu>
80104c72:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c78:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c7f:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c82:	e8 75 f7 ff ff       	call   801043fc <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c87:	83 ec 0c             	sub    $0xc,%esp
80104c8a:	68 c0 4d 11 80       	push   $0x80114dc0
80104c8f:	e8 45 06 00 00       	call   801052d9 <acquire>
80104c94:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c97:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104c9e:	eb 64                	jmp    80104d04 <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca3:	8b 40 0c             	mov    0xc(%eax),%eax
80104ca6:	83 f8 03             	cmp    $0x3,%eax
80104ca9:	75 51                	jne    80104cfc <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cae:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cb1:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104cb7:	83 ec 0c             	sub    $0xc,%esp
80104cba:	ff 75 f4             	pushl  -0xc(%ebp)
80104cbd:	e8 0c 3a 00 00       	call   801086ce <switchuvm>
80104cc2:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc8:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd2:	8b 40 1c             	mov    0x1c(%eax),%eax
80104cd5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cd8:	83 c2 04             	add    $0x4,%edx
80104cdb:	83 ec 08             	sub    $0x8,%esp
80104cde:	50                   	push   %eax
80104cdf:	52                   	push   %edx
80104ce0:	e8 27 0b 00 00       	call   8010580c <swtch>
80104ce5:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104ce8:	e8 c4 39 00 00       	call   801086b1 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cf0:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104cf7:	00 00 00 
80104cfa:	eb 01                	jmp    80104cfd <scheduler+0x9a>
        continue;
80104cfc:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cfd:	81 45 f4 c8 00 00 00 	addl   $0xc8,-0xc(%ebp)
80104d04:	81 7d f4 f4 7f 11 80 	cmpl   $0x80117ff4,-0xc(%ebp)
80104d0b:	72 93                	jb     80104ca0 <scheduler+0x3d>
    }
    release(&ptable.lock);
80104d0d:	83 ec 0c             	sub    $0xc,%esp
80104d10:	68 c0 4d 11 80       	push   $0x80114dc0
80104d15:	e8 31 06 00 00       	call   8010534b <release>
80104d1a:	83 c4 10             	add    $0x10,%esp
    sti();
80104d1d:	e9 60 ff ff ff       	jmp    80104c82 <scheduler+0x1f>

80104d22 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104d22:	f3 0f 1e fb          	endbr32 
80104d26:	55                   	push   %ebp
80104d27:	89 e5                	mov    %esp,%ebp
80104d29:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104d2c:	e8 8f f7 ff ff       	call   801044c0 <myproc>
80104d31:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104d34:	83 ec 0c             	sub    $0xc,%esp
80104d37:	68 c0 4d 11 80       	push   $0x80114dc0
80104d3c:	e8 df 06 00 00       	call   80105420 <holding>
80104d41:	83 c4 10             	add    $0x10,%esp
80104d44:	85 c0                	test   %eax,%eax
80104d46:	75 0d                	jne    80104d55 <sched+0x33>
    panic("sched ptable.lock");
80104d48:	83 ec 0c             	sub    $0xc,%esp
80104d4b:	68 23 97 10 80       	push   $0x80109723
80104d50:	e8 b3 b8 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli != 1)
80104d55:	e8 ea f6 ff ff       	call   80104444 <mycpu>
80104d5a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d60:	83 f8 01             	cmp    $0x1,%eax
80104d63:	74 0d                	je     80104d72 <sched+0x50>
    panic("sched locks");
80104d65:	83 ec 0c             	sub    $0xc,%esp
80104d68:	68 35 97 10 80       	push   $0x80109735
80104d6d:	e8 96 b8 ff ff       	call   80100608 <panic>
  if(p->state == RUNNING)
80104d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d75:	8b 40 0c             	mov    0xc(%eax),%eax
80104d78:	83 f8 04             	cmp    $0x4,%eax
80104d7b:	75 0d                	jne    80104d8a <sched+0x68>
    panic("sched running");
80104d7d:	83 ec 0c             	sub    $0xc,%esp
80104d80:	68 41 97 10 80       	push   $0x80109741
80104d85:	e8 7e b8 ff ff       	call   80100608 <panic>
  if(readeflags()&FL_IF)
80104d8a:	e8 5d f6 ff ff       	call   801043ec <readeflags>
80104d8f:	25 00 02 00 00       	and    $0x200,%eax
80104d94:	85 c0                	test   %eax,%eax
80104d96:	74 0d                	je     80104da5 <sched+0x83>
    panic("sched interruptible");
80104d98:	83 ec 0c             	sub    $0xc,%esp
80104d9b:	68 4f 97 10 80       	push   $0x8010974f
80104da0:	e8 63 b8 ff ff       	call   80100608 <panic>
  intena = mycpu()->intena;
80104da5:	e8 9a f6 ff ff       	call   80104444 <mycpu>
80104daa:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104db0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104db3:	e8 8c f6 ff ff       	call   80104444 <mycpu>
80104db8:	8b 40 04             	mov    0x4(%eax),%eax
80104dbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dbe:	83 c2 1c             	add    $0x1c,%edx
80104dc1:	83 ec 08             	sub    $0x8,%esp
80104dc4:	50                   	push   %eax
80104dc5:	52                   	push   %edx
80104dc6:	e8 41 0a 00 00       	call   8010580c <swtch>
80104dcb:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104dce:	e8 71 f6 ff ff       	call   80104444 <mycpu>
80104dd3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104dd6:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104ddc:	90                   	nop
80104ddd:	c9                   	leave  
80104dde:	c3                   	ret    

80104ddf <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104ddf:	f3 0f 1e fb          	endbr32 
80104de3:	55                   	push   %ebp
80104de4:	89 e5                	mov    %esp,%ebp
80104de6:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104de9:	83 ec 0c             	sub    $0xc,%esp
80104dec:	68 c0 4d 11 80       	push   $0x80114dc0
80104df1:	e8 e3 04 00 00       	call   801052d9 <acquire>
80104df6:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104df9:	e8 c2 f6 ff ff       	call   801044c0 <myproc>
80104dfe:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104e05:	e8 18 ff ff ff       	call   80104d22 <sched>
  release(&ptable.lock);
80104e0a:	83 ec 0c             	sub    $0xc,%esp
80104e0d:	68 c0 4d 11 80       	push   $0x80114dc0
80104e12:	e8 34 05 00 00       	call   8010534b <release>
80104e17:	83 c4 10             	add    $0x10,%esp
}
80104e1a:	90                   	nop
80104e1b:	c9                   	leave  
80104e1c:	c3                   	ret    

80104e1d <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e1d:	f3 0f 1e fb          	endbr32 
80104e21:	55                   	push   %ebp
80104e22:	89 e5                	mov    %esp,%ebp
80104e24:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e27:	83 ec 0c             	sub    $0xc,%esp
80104e2a:	68 c0 4d 11 80       	push   $0x80114dc0
80104e2f:	e8 17 05 00 00       	call   8010534b <release>
80104e34:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104e37:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104e3c:	85 c0                	test   %eax,%eax
80104e3e:	74 24                	je     80104e64 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104e40:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104e47:	00 00 00 
    iinit(ROOTDEV);
80104e4a:	83 ec 0c             	sub    $0xc,%esp
80104e4d:	6a 01                	push   $0x1
80104e4f:	e8 58 c9 ff ff       	call   801017ac <iinit>
80104e54:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104e57:	83 ec 0c             	sub    $0xc,%esp
80104e5a:	6a 01                	push   $0x1
80104e5c:	e8 6d e6 ff ff       	call   801034ce <initlog>
80104e61:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104e64:	90                   	nop
80104e65:	c9                   	leave  
80104e66:	c3                   	ret    

80104e67 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e67:	f3 0f 1e fb          	endbr32 
80104e6b:	55                   	push   %ebp
80104e6c:	89 e5                	mov    %esp,%ebp
80104e6e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104e71:	e8 4a f6 ff ff       	call   801044c0 <myproc>
80104e76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104e79:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e7d:	75 0d                	jne    80104e8c <sleep+0x25>
    panic("sleep");
80104e7f:	83 ec 0c             	sub    $0xc,%esp
80104e82:	68 63 97 10 80       	push   $0x80109763
80104e87:	e8 7c b7 ff ff       	call   80100608 <panic>

  if(lk == 0)
80104e8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e90:	75 0d                	jne    80104e9f <sleep+0x38>
    panic("sleep without lk");
80104e92:	83 ec 0c             	sub    $0xc,%esp
80104e95:	68 69 97 10 80       	push   $0x80109769
80104e9a:	e8 69 b7 ff ff       	call   80100608 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e9f:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104ea6:	74 1e                	je     80104ec6 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ea8:	83 ec 0c             	sub    $0xc,%esp
80104eab:	68 c0 4d 11 80       	push   $0x80114dc0
80104eb0:	e8 24 04 00 00       	call   801052d9 <acquire>
80104eb5:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104eb8:	83 ec 0c             	sub    $0xc,%esp
80104ebb:	ff 75 0c             	pushl  0xc(%ebp)
80104ebe:	e8 88 04 00 00       	call   8010534b <release>
80104ec3:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec9:	8b 55 08             	mov    0x8(%ebp),%edx
80104ecc:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed2:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104ed9:	e8 44 fe ff ff       	call   80104d22 <sched>

  // Tidy up.
  p->chan = 0;
80104ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee1:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ee8:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104eef:	74 1e                	je     80104f0f <sleep+0xa8>
    release(&ptable.lock);
80104ef1:	83 ec 0c             	sub    $0xc,%esp
80104ef4:	68 c0 4d 11 80       	push   $0x80114dc0
80104ef9:	e8 4d 04 00 00       	call   8010534b <release>
80104efe:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104f01:	83 ec 0c             	sub    $0xc,%esp
80104f04:	ff 75 0c             	pushl  0xc(%ebp)
80104f07:	e8 cd 03 00 00       	call   801052d9 <acquire>
80104f0c:	83 c4 10             	add    $0x10,%esp
  }
}
80104f0f:	90                   	nop
80104f10:	c9                   	leave  
80104f11:	c3                   	ret    

80104f12 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104f12:	f3 0f 1e fb          	endbr32 
80104f16:	55                   	push   %ebp
80104f17:	89 e5                	mov    %esp,%ebp
80104f19:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f1c:	c7 45 fc f4 4d 11 80 	movl   $0x80114df4,-0x4(%ebp)
80104f23:	eb 27                	jmp    80104f4c <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
80104f25:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f28:	8b 40 0c             	mov    0xc(%eax),%eax
80104f2b:	83 f8 02             	cmp    $0x2,%eax
80104f2e:	75 15                	jne    80104f45 <wakeup1+0x33>
80104f30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f33:	8b 40 20             	mov    0x20(%eax),%eax
80104f36:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f39:	75 0a                	jne    80104f45 <wakeup1+0x33>
      p->state = RUNNABLE;
80104f3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f3e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f45:	81 45 fc c8 00 00 00 	addl   $0xc8,-0x4(%ebp)
80104f4c:	81 7d fc f4 7f 11 80 	cmpl   $0x80117ff4,-0x4(%ebp)
80104f53:	72 d0                	jb     80104f25 <wakeup1+0x13>
}
80104f55:	90                   	nop
80104f56:	90                   	nop
80104f57:	c9                   	leave  
80104f58:	c3                   	ret    

80104f59 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f59:	f3 0f 1e fb          	endbr32 
80104f5d:	55                   	push   %ebp
80104f5e:	89 e5                	mov    %esp,%ebp
80104f60:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104f63:	83 ec 0c             	sub    $0xc,%esp
80104f66:	68 c0 4d 11 80       	push   $0x80114dc0
80104f6b:	e8 69 03 00 00       	call   801052d9 <acquire>
80104f70:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104f73:	83 ec 0c             	sub    $0xc,%esp
80104f76:	ff 75 08             	pushl  0x8(%ebp)
80104f79:	e8 94 ff ff ff       	call   80104f12 <wakeup1>
80104f7e:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104f81:	83 ec 0c             	sub    $0xc,%esp
80104f84:	68 c0 4d 11 80       	push   $0x80114dc0
80104f89:	e8 bd 03 00 00       	call   8010534b <release>
80104f8e:	83 c4 10             	add    $0x10,%esp
}
80104f91:	90                   	nop
80104f92:	c9                   	leave  
80104f93:	c3                   	ret    

80104f94 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f94:	f3 0f 1e fb          	endbr32 
80104f98:	55                   	push   %ebp
80104f99:	89 e5                	mov    %esp,%ebp
80104f9b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f9e:	83 ec 0c             	sub    $0xc,%esp
80104fa1:	68 c0 4d 11 80       	push   $0x80114dc0
80104fa6:	e8 2e 03 00 00       	call   801052d9 <acquire>
80104fab:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fae:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104fb5:	eb 48                	jmp    80104fff <kill+0x6b>
    if(p->pid == pid){
80104fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fba:	8b 40 10             	mov    0x10(%eax),%eax
80104fbd:	39 45 08             	cmp    %eax,0x8(%ebp)
80104fc0:	75 36                	jne    80104ff8 <kill+0x64>
      p->killed = 1;
80104fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fcf:	8b 40 0c             	mov    0xc(%eax),%eax
80104fd2:	83 f8 02             	cmp    $0x2,%eax
80104fd5:	75 0a                	jne    80104fe1 <kill+0x4d>
        p->state = RUNNABLE;
80104fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fda:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104fe1:	83 ec 0c             	sub    $0xc,%esp
80104fe4:	68 c0 4d 11 80       	push   $0x80114dc0
80104fe9:	e8 5d 03 00 00       	call   8010534b <release>
80104fee:	83 c4 10             	add    $0x10,%esp
      return 0;
80104ff1:	b8 00 00 00 00       	mov    $0x0,%eax
80104ff6:	eb 25                	jmp    8010501d <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ff8:	81 45 f4 c8 00 00 00 	addl   $0xc8,-0xc(%ebp)
80104fff:	81 7d f4 f4 7f 11 80 	cmpl   $0x80117ff4,-0xc(%ebp)
80105006:	72 af                	jb     80104fb7 <kill+0x23>
    }
  }
  release(&ptable.lock);
80105008:	83 ec 0c             	sub    $0xc,%esp
8010500b:	68 c0 4d 11 80       	push   $0x80114dc0
80105010:	e8 36 03 00 00       	call   8010534b <release>
80105015:	83 c4 10             	add    $0x10,%esp
  return -1;
80105018:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010501d:	c9                   	leave  
8010501e:	c3                   	ret    

8010501f <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010501f:	f3 0f 1e fb          	endbr32 
80105023:	55                   	push   %ebp
80105024:	89 e5                	mov    %esp,%ebp
80105026:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105029:	c7 45 f0 f4 4d 11 80 	movl   $0x80114df4,-0x10(%ebp)
80105030:	e9 da 00 00 00       	jmp    8010510f <procdump+0xf0>
    if(p->state == UNUSED)
80105035:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105038:	8b 40 0c             	mov    0xc(%eax),%eax
8010503b:	85 c0                	test   %eax,%eax
8010503d:	0f 84 c4 00 00 00    	je     80105107 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105043:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105046:	8b 40 0c             	mov    0xc(%eax),%eax
80105049:	83 f8 05             	cmp    $0x5,%eax
8010504c:	77 23                	ja     80105071 <procdump+0x52>
8010504e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105051:	8b 40 0c             	mov    0xc(%eax),%eax
80105054:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010505b:	85 c0                	test   %eax,%eax
8010505d:	74 12                	je     80105071 <procdump+0x52>
      state = states[p->state];
8010505f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105062:	8b 40 0c             	mov    0xc(%eax),%eax
80105065:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010506c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010506f:	eb 07                	jmp    80105078 <procdump+0x59>
    else
      state = "???";
80105071:	c7 45 ec 7a 97 10 80 	movl   $0x8010977a,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105078:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010507b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010507e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105081:	8b 40 10             	mov    0x10(%eax),%eax
80105084:	52                   	push   %edx
80105085:	ff 75 ec             	pushl  -0x14(%ebp)
80105088:	50                   	push   %eax
80105089:	68 7e 97 10 80       	push   $0x8010977e
8010508e:	e8 85 b3 ff ff       	call   80100418 <cprintf>
80105093:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105096:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105099:	8b 40 0c             	mov    0xc(%eax),%eax
8010509c:	83 f8 02             	cmp    $0x2,%eax
8010509f:	75 54                	jne    801050f5 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801050a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a4:	8b 40 1c             	mov    0x1c(%eax),%eax
801050a7:	8b 40 0c             	mov    0xc(%eax),%eax
801050aa:	83 c0 08             	add    $0x8,%eax
801050ad:	89 c2                	mov    %eax,%edx
801050af:	83 ec 08             	sub    $0x8,%esp
801050b2:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801050b5:	50                   	push   %eax
801050b6:	52                   	push   %edx
801050b7:	e8 e5 02 00 00       	call   801053a1 <getcallerpcs>
801050bc:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050c6:	eb 1c                	jmp    801050e4 <procdump+0xc5>
        cprintf(" %p", pc[i]);
801050c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050cb:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050cf:	83 ec 08             	sub    $0x8,%esp
801050d2:	50                   	push   %eax
801050d3:	68 87 97 10 80       	push   $0x80109787
801050d8:	e8 3b b3 ff ff       	call   80100418 <cprintf>
801050dd:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050e4:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801050e8:	7f 0b                	jg     801050f5 <procdump+0xd6>
801050ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ed:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050f1:	85 c0                	test   %eax,%eax
801050f3:	75 d3                	jne    801050c8 <procdump+0xa9>
    }
    cprintf("\n");
801050f5:	83 ec 0c             	sub    $0xc,%esp
801050f8:	68 8b 97 10 80       	push   $0x8010978b
801050fd:	e8 16 b3 ff ff       	call   80100418 <cprintf>
80105102:	83 c4 10             	add    $0x10,%esp
80105105:	eb 01                	jmp    80105108 <procdump+0xe9>
      continue;
80105107:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105108:	81 45 f0 c8 00 00 00 	addl   $0xc8,-0x10(%ebp)
8010510f:	81 7d f0 f4 7f 11 80 	cmpl   $0x80117ff4,-0x10(%ebp)
80105116:	0f 82 19 ff ff ff    	jb     80105035 <procdump+0x16>
  }
}
8010511c:	90                   	nop
8010511d:	90                   	nop
8010511e:	c9                   	leave  
8010511f:	c3                   	ret    

80105120 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105120:	f3 0f 1e fb          	endbr32 
80105124:	55                   	push   %ebp
80105125:	89 e5                	mov    %esp,%ebp
80105127:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
8010512a:	8b 45 08             	mov    0x8(%ebp),%eax
8010512d:	83 c0 04             	add    $0x4,%eax
80105130:	83 ec 08             	sub    $0x8,%esp
80105133:	68 b7 97 10 80       	push   $0x801097b7
80105138:	50                   	push   %eax
80105139:	e8 75 01 00 00       	call   801052b3 <initlock>
8010513e:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80105141:	8b 45 08             	mov    0x8(%ebp),%eax
80105144:	8b 55 0c             	mov    0xc(%ebp),%edx
80105147:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
8010514a:	8b 45 08             	mov    0x8(%ebp),%eax
8010514d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105153:	8b 45 08             	mov    0x8(%ebp),%eax
80105156:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
8010515d:	90                   	nop
8010515e:	c9                   	leave  
8010515f:	c3                   	ret    

80105160 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105160:	f3 0f 1e fb          	endbr32 
80105164:	55                   	push   %ebp
80105165:	89 e5                	mov    %esp,%ebp
80105167:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010516a:	8b 45 08             	mov    0x8(%ebp),%eax
8010516d:	83 c0 04             	add    $0x4,%eax
80105170:	83 ec 0c             	sub    $0xc,%esp
80105173:	50                   	push   %eax
80105174:	e8 60 01 00 00       	call   801052d9 <acquire>
80105179:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010517c:	eb 15                	jmp    80105193 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
8010517e:	8b 45 08             	mov    0x8(%ebp),%eax
80105181:	83 c0 04             	add    $0x4,%eax
80105184:	83 ec 08             	sub    $0x8,%esp
80105187:	50                   	push   %eax
80105188:	ff 75 08             	pushl  0x8(%ebp)
8010518b:	e8 d7 fc ff ff       	call   80104e67 <sleep>
80105190:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105193:	8b 45 08             	mov    0x8(%ebp),%eax
80105196:	8b 00                	mov    (%eax),%eax
80105198:	85 c0                	test   %eax,%eax
8010519a:	75 e2                	jne    8010517e <acquiresleep+0x1e>
  }
  lk->locked = 1;
8010519c:	8b 45 08             	mov    0x8(%ebp),%eax
8010519f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801051a5:	e8 16 f3 ff ff       	call   801044c0 <myproc>
801051aa:	8b 50 10             	mov    0x10(%eax),%edx
801051ad:	8b 45 08             	mov    0x8(%ebp),%eax
801051b0:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801051b3:	8b 45 08             	mov    0x8(%ebp),%eax
801051b6:	83 c0 04             	add    $0x4,%eax
801051b9:	83 ec 0c             	sub    $0xc,%esp
801051bc:	50                   	push   %eax
801051bd:	e8 89 01 00 00       	call   8010534b <release>
801051c2:	83 c4 10             	add    $0x10,%esp
}
801051c5:	90                   	nop
801051c6:	c9                   	leave  
801051c7:	c3                   	ret    

801051c8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801051c8:	f3 0f 1e fb          	endbr32 
801051cc:	55                   	push   %ebp
801051cd:	89 e5                	mov    %esp,%ebp
801051cf:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801051d2:	8b 45 08             	mov    0x8(%ebp),%eax
801051d5:	83 c0 04             	add    $0x4,%eax
801051d8:	83 ec 0c             	sub    $0xc,%esp
801051db:	50                   	push   %eax
801051dc:	e8 f8 00 00 00       	call   801052d9 <acquire>
801051e1:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801051e4:	8b 45 08             	mov    0x8(%ebp),%eax
801051e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051ed:	8b 45 08             	mov    0x8(%ebp),%eax
801051f0:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801051f7:	83 ec 0c             	sub    $0xc,%esp
801051fa:	ff 75 08             	pushl  0x8(%ebp)
801051fd:	e8 57 fd ff ff       	call   80104f59 <wakeup>
80105202:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105205:	8b 45 08             	mov    0x8(%ebp),%eax
80105208:	83 c0 04             	add    $0x4,%eax
8010520b:	83 ec 0c             	sub    $0xc,%esp
8010520e:	50                   	push   %eax
8010520f:	e8 37 01 00 00       	call   8010534b <release>
80105214:	83 c4 10             	add    $0x10,%esp
}
80105217:	90                   	nop
80105218:	c9                   	leave  
80105219:	c3                   	ret    

8010521a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010521a:	f3 0f 1e fb          	endbr32 
8010521e:	55                   	push   %ebp
8010521f:	89 e5                	mov    %esp,%ebp
80105221:	53                   	push   %ebx
80105222:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
80105225:	8b 45 08             	mov    0x8(%ebp),%eax
80105228:	83 c0 04             	add    $0x4,%eax
8010522b:	83 ec 0c             	sub    $0xc,%esp
8010522e:	50                   	push   %eax
8010522f:	e8 a5 00 00 00       	call   801052d9 <acquire>
80105234:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
80105237:	8b 45 08             	mov    0x8(%ebp),%eax
8010523a:	8b 00                	mov    (%eax),%eax
8010523c:	85 c0                	test   %eax,%eax
8010523e:	74 19                	je     80105259 <holdingsleep+0x3f>
80105240:	8b 45 08             	mov    0x8(%ebp),%eax
80105243:	8b 58 3c             	mov    0x3c(%eax),%ebx
80105246:	e8 75 f2 ff ff       	call   801044c0 <myproc>
8010524b:	8b 40 10             	mov    0x10(%eax),%eax
8010524e:	39 c3                	cmp    %eax,%ebx
80105250:	75 07                	jne    80105259 <holdingsleep+0x3f>
80105252:	b8 01 00 00 00       	mov    $0x1,%eax
80105257:	eb 05                	jmp    8010525e <holdingsleep+0x44>
80105259:	b8 00 00 00 00       	mov    $0x0,%eax
8010525e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105261:	8b 45 08             	mov    0x8(%ebp),%eax
80105264:	83 c0 04             	add    $0x4,%eax
80105267:	83 ec 0c             	sub    $0xc,%esp
8010526a:	50                   	push   %eax
8010526b:	e8 db 00 00 00       	call   8010534b <release>
80105270:	83 c4 10             	add    $0x10,%esp
  return r;
80105273:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105276:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105279:	c9                   	leave  
8010527a:	c3                   	ret    

8010527b <readeflags>:
{
8010527b:	55                   	push   %ebp
8010527c:	89 e5                	mov    %esp,%ebp
8010527e:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105281:	9c                   	pushf  
80105282:	58                   	pop    %eax
80105283:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105286:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105289:	c9                   	leave  
8010528a:	c3                   	ret    

8010528b <cli>:
{
8010528b:	55                   	push   %ebp
8010528c:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010528e:	fa                   	cli    
}
8010528f:	90                   	nop
80105290:	5d                   	pop    %ebp
80105291:	c3                   	ret    

80105292 <sti>:
{
80105292:	55                   	push   %ebp
80105293:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105295:	fb                   	sti    
}
80105296:	90                   	nop
80105297:	5d                   	pop    %ebp
80105298:	c3                   	ret    

80105299 <xchg>:
{
80105299:	55                   	push   %ebp
8010529a:	89 e5                	mov    %esp,%ebp
8010529c:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010529f:	8b 55 08             	mov    0x8(%ebp),%edx
801052a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052a8:	f0 87 02             	lock xchg %eax,(%edx)
801052ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801052ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052b1:	c9                   	leave  
801052b2:	c3                   	ret    

801052b3 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801052b3:	f3 0f 1e fb          	endbr32 
801052b7:	55                   	push   %ebp
801052b8:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801052ba:	8b 45 08             	mov    0x8(%ebp),%eax
801052bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801052c0:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801052c3:	8b 45 08             	mov    0x8(%ebp),%eax
801052c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801052cc:	8b 45 08             	mov    0x8(%ebp),%eax
801052cf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801052d6:	90                   	nop
801052d7:	5d                   	pop    %ebp
801052d8:	c3                   	ret    

801052d9 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801052d9:	f3 0f 1e fb          	endbr32 
801052dd:	55                   	push   %ebp
801052de:	89 e5                	mov    %esp,%ebp
801052e0:	53                   	push   %ebx
801052e1:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801052e4:	e8 7c 01 00 00       	call   80105465 <pushcli>
  if(holding(lk))
801052e9:	8b 45 08             	mov    0x8(%ebp),%eax
801052ec:	83 ec 0c             	sub    $0xc,%esp
801052ef:	50                   	push   %eax
801052f0:	e8 2b 01 00 00       	call   80105420 <holding>
801052f5:	83 c4 10             	add    $0x10,%esp
801052f8:	85 c0                	test   %eax,%eax
801052fa:	74 0d                	je     80105309 <acquire+0x30>
    panic("acquire");
801052fc:	83 ec 0c             	sub    $0xc,%esp
801052ff:	68 c2 97 10 80       	push   $0x801097c2
80105304:	e8 ff b2 ff ff       	call   80100608 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105309:	90                   	nop
8010530a:	8b 45 08             	mov    0x8(%ebp),%eax
8010530d:	83 ec 08             	sub    $0x8,%esp
80105310:	6a 01                	push   $0x1
80105312:	50                   	push   %eax
80105313:	e8 81 ff ff ff       	call   80105299 <xchg>
80105318:	83 c4 10             	add    $0x10,%esp
8010531b:	85 c0                	test   %eax,%eax
8010531d:	75 eb                	jne    8010530a <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010531f:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105324:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105327:	e8 18 f1 ff ff       	call   80104444 <mycpu>
8010532c:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010532f:	8b 45 08             	mov    0x8(%ebp),%eax
80105332:	83 c0 0c             	add    $0xc,%eax
80105335:	83 ec 08             	sub    $0x8,%esp
80105338:	50                   	push   %eax
80105339:	8d 45 08             	lea    0x8(%ebp),%eax
8010533c:	50                   	push   %eax
8010533d:	e8 5f 00 00 00       	call   801053a1 <getcallerpcs>
80105342:	83 c4 10             	add    $0x10,%esp
}
80105345:	90                   	nop
80105346:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105349:	c9                   	leave  
8010534a:	c3                   	ret    

8010534b <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010534b:	f3 0f 1e fb          	endbr32 
8010534f:	55                   	push   %ebp
80105350:	89 e5                	mov    %esp,%ebp
80105352:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105355:	83 ec 0c             	sub    $0xc,%esp
80105358:	ff 75 08             	pushl  0x8(%ebp)
8010535b:	e8 c0 00 00 00       	call   80105420 <holding>
80105360:	83 c4 10             	add    $0x10,%esp
80105363:	85 c0                	test   %eax,%eax
80105365:	75 0d                	jne    80105374 <release+0x29>
    panic("release");
80105367:	83 ec 0c             	sub    $0xc,%esp
8010536a:	68 ca 97 10 80       	push   $0x801097ca
8010536f:	e8 94 b2 ff ff       	call   80100608 <panic>

  lk->pcs[0] = 0;
80105374:	8b 45 08             	mov    0x8(%ebp),%eax
80105377:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010537e:	8b 45 08             	mov    0x8(%ebp),%eax
80105381:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105388:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010538d:	8b 45 08             	mov    0x8(%ebp),%eax
80105390:	8b 55 08             	mov    0x8(%ebp),%edx
80105393:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105399:	e8 18 01 00 00       	call   801054b6 <popcli>
}
8010539e:	90                   	nop
8010539f:	c9                   	leave  
801053a0:	c3                   	ret    

801053a1 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801053a1:	f3 0f 1e fb          	endbr32 
801053a5:	55                   	push   %ebp
801053a6:	89 e5                	mov    %esp,%ebp
801053a8:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801053ab:	8b 45 08             	mov    0x8(%ebp),%eax
801053ae:	83 e8 08             	sub    $0x8,%eax
801053b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053b4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801053bb:	eb 38                	jmp    801053f5 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801053bd:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801053c1:	74 53                	je     80105416 <getcallerpcs+0x75>
801053c3:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801053ca:	76 4a                	jbe    80105416 <getcallerpcs+0x75>
801053cc:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801053d0:	74 44                	je     80105416 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
801053d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801053df:	01 c2                	add    %eax,%edx
801053e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053e4:	8b 40 04             	mov    0x4(%eax),%eax
801053e7:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801053e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ec:	8b 00                	mov    (%eax),%eax
801053ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053f1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053f5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053f9:	7e c2                	jle    801053bd <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
801053fb:	eb 19                	jmp    80105416 <getcallerpcs+0x75>
    pcs[i] = 0;
801053fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105400:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105407:	8b 45 0c             	mov    0xc(%ebp),%eax
8010540a:	01 d0                	add    %edx,%eax
8010540c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105412:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105416:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010541a:	7e e1                	jle    801053fd <getcallerpcs+0x5c>
}
8010541c:	90                   	nop
8010541d:	90                   	nop
8010541e:	c9                   	leave  
8010541f:	c3                   	ret    

80105420 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105420:	f3 0f 1e fb          	endbr32 
80105424:	55                   	push   %ebp
80105425:	89 e5                	mov    %esp,%ebp
80105427:	53                   	push   %ebx
80105428:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
8010542b:	e8 35 00 00 00       	call   80105465 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80105430:	8b 45 08             	mov    0x8(%ebp),%eax
80105433:	8b 00                	mov    (%eax),%eax
80105435:	85 c0                	test   %eax,%eax
80105437:	74 16                	je     8010544f <holding+0x2f>
80105439:	8b 45 08             	mov    0x8(%ebp),%eax
8010543c:	8b 58 08             	mov    0x8(%eax),%ebx
8010543f:	e8 00 f0 ff ff       	call   80104444 <mycpu>
80105444:	39 c3                	cmp    %eax,%ebx
80105446:	75 07                	jne    8010544f <holding+0x2f>
80105448:	b8 01 00 00 00       	mov    $0x1,%eax
8010544d:	eb 05                	jmp    80105454 <holding+0x34>
8010544f:	b8 00 00 00 00       	mov    $0x0,%eax
80105454:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
80105457:	e8 5a 00 00 00       	call   801054b6 <popcli>
  return r;
8010545c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010545f:	83 c4 14             	add    $0x14,%esp
80105462:	5b                   	pop    %ebx
80105463:	5d                   	pop    %ebp
80105464:	c3                   	ret    

80105465 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105465:	f3 0f 1e fb          	endbr32 
80105469:	55                   	push   %ebp
8010546a:	89 e5                	mov    %esp,%ebp
8010546c:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010546f:	e8 07 fe ff ff       	call   8010527b <readeflags>
80105474:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105477:	e8 0f fe ff ff       	call   8010528b <cli>
  if(mycpu()->ncli == 0)
8010547c:	e8 c3 ef ff ff       	call   80104444 <mycpu>
80105481:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105487:	85 c0                	test   %eax,%eax
80105489:	75 14                	jne    8010549f <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
8010548b:	e8 b4 ef ff ff       	call   80104444 <mycpu>
80105490:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105493:	81 e2 00 02 00 00    	and    $0x200,%edx
80105499:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010549f:	e8 a0 ef ff ff       	call   80104444 <mycpu>
801054a4:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054aa:	83 c2 01             	add    $0x1,%edx
801054ad:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801054b3:	90                   	nop
801054b4:	c9                   	leave  
801054b5:	c3                   	ret    

801054b6 <popcli>:

void
popcli(void)
{
801054b6:	f3 0f 1e fb          	endbr32 
801054ba:	55                   	push   %ebp
801054bb:	89 e5                	mov    %esp,%ebp
801054bd:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801054c0:	e8 b6 fd ff ff       	call   8010527b <readeflags>
801054c5:	25 00 02 00 00       	and    $0x200,%eax
801054ca:	85 c0                	test   %eax,%eax
801054cc:	74 0d                	je     801054db <popcli+0x25>
    panic("popcli - interruptible");
801054ce:	83 ec 0c             	sub    $0xc,%esp
801054d1:	68 d2 97 10 80       	push   $0x801097d2
801054d6:	e8 2d b1 ff ff       	call   80100608 <panic>
  if(--mycpu()->ncli < 0)
801054db:	e8 64 ef ff ff       	call   80104444 <mycpu>
801054e0:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054e6:	83 ea 01             	sub    $0x1,%edx
801054e9:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801054ef:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054f5:	85 c0                	test   %eax,%eax
801054f7:	79 0d                	jns    80105506 <popcli+0x50>
    panic("popcli");
801054f9:	83 ec 0c             	sub    $0xc,%esp
801054fc:	68 e9 97 10 80       	push   $0x801097e9
80105501:	e8 02 b1 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105506:	e8 39 ef ff ff       	call   80104444 <mycpu>
8010550b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105511:	85 c0                	test   %eax,%eax
80105513:	75 14                	jne    80105529 <popcli+0x73>
80105515:	e8 2a ef ff ff       	call   80104444 <mycpu>
8010551a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105520:	85 c0                	test   %eax,%eax
80105522:	74 05                	je     80105529 <popcli+0x73>
    sti();
80105524:	e8 69 fd ff ff       	call   80105292 <sti>
}
80105529:	90                   	nop
8010552a:	c9                   	leave  
8010552b:	c3                   	ret    

8010552c <stosb>:
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
}
8010554d:	90                   	nop
8010554e:	5b                   	pop    %ebx
8010554f:	5f                   	pop    %edi
80105550:	5d                   	pop    %ebp
80105551:	c3                   	ret    

80105552 <stosl>:
{
80105552:	55                   	push   %ebp
80105553:	89 e5                	mov    %esp,%ebp
80105555:	57                   	push   %edi
80105556:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105557:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010555a:	8b 55 10             	mov    0x10(%ebp),%edx
8010555d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105560:	89 cb                	mov    %ecx,%ebx
80105562:	89 df                	mov    %ebx,%edi
80105564:	89 d1                	mov    %edx,%ecx
80105566:	fc                   	cld    
80105567:	f3 ab                	rep stos %eax,%es:(%edi)
80105569:	89 ca                	mov    %ecx,%edx
8010556b:	89 fb                	mov    %edi,%ebx
8010556d:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105570:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105573:	90                   	nop
80105574:	5b                   	pop    %ebx
80105575:	5f                   	pop    %edi
80105576:	5d                   	pop    %ebp
80105577:	c3                   	ret    

80105578 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105578:	f3 0f 1e fb          	endbr32 
8010557c:	55                   	push   %ebp
8010557d:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010557f:	8b 45 08             	mov    0x8(%ebp),%eax
80105582:	83 e0 03             	and    $0x3,%eax
80105585:	85 c0                	test   %eax,%eax
80105587:	75 43                	jne    801055cc <memset+0x54>
80105589:	8b 45 10             	mov    0x10(%ebp),%eax
8010558c:	83 e0 03             	and    $0x3,%eax
8010558f:	85 c0                	test   %eax,%eax
80105591:	75 39                	jne    801055cc <memset+0x54>
    c &= 0xFF;
80105593:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010559a:	8b 45 10             	mov    0x10(%ebp),%eax
8010559d:	c1 e8 02             	shr    $0x2,%eax
801055a0:	89 c1                	mov    %eax,%ecx
801055a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a5:	c1 e0 18             	shl    $0x18,%eax
801055a8:	89 c2                	mov    %eax,%edx
801055aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ad:	c1 e0 10             	shl    $0x10,%eax
801055b0:	09 c2                	or     %eax,%edx
801055b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b5:	c1 e0 08             	shl    $0x8,%eax
801055b8:	09 d0                	or     %edx,%eax
801055ba:	0b 45 0c             	or     0xc(%ebp),%eax
801055bd:	51                   	push   %ecx
801055be:	50                   	push   %eax
801055bf:	ff 75 08             	pushl  0x8(%ebp)
801055c2:	e8 8b ff ff ff       	call   80105552 <stosl>
801055c7:	83 c4 0c             	add    $0xc,%esp
801055ca:	eb 12                	jmp    801055de <memset+0x66>
  } else
    stosb(dst, c, n);
801055cc:	8b 45 10             	mov    0x10(%ebp),%eax
801055cf:	50                   	push   %eax
801055d0:	ff 75 0c             	pushl  0xc(%ebp)
801055d3:	ff 75 08             	pushl  0x8(%ebp)
801055d6:	e8 51 ff ff ff       	call   8010552c <stosb>
801055db:	83 c4 0c             	add    $0xc,%esp
  return dst;
801055de:	8b 45 08             	mov    0x8(%ebp),%eax
}
801055e1:	c9                   	leave  
801055e2:	c3                   	ret    

801055e3 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801055e3:	f3 0f 1e fb          	endbr32 
801055e7:	55                   	push   %ebp
801055e8:	89 e5                	mov    %esp,%ebp
801055ea:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801055ed:	8b 45 08             	mov    0x8(%ebp),%eax
801055f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801055f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801055f9:	eb 30                	jmp    8010562b <memcmp+0x48>
    if(*s1 != *s2)
801055fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055fe:	0f b6 10             	movzbl (%eax),%edx
80105601:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105604:	0f b6 00             	movzbl (%eax),%eax
80105607:	38 c2                	cmp    %al,%dl
80105609:	74 18                	je     80105623 <memcmp+0x40>
      return *s1 - *s2;
8010560b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010560e:	0f b6 00             	movzbl (%eax),%eax
80105611:	0f b6 d0             	movzbl %al,%edx
80105614:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105617:	0f b6 00             	movzbl (%eax),%eax
8010561a:	0f b6 c0             	movzbl %al,%eax
8010561d:	29 c2                	sub    %eax,%edx
8010561f:	89 d0                	mov    %edx,%eax
80105621:	eb 1a                	jmp    8010563d <memcmp+0x5a>
    s1++, s2++;
80105623:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105627:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
8010562b:	8b 45 10             	mov    0x10(%ebp),%eax
8010562e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105631:	89 55 10             	mov    %edx,0x10(%ebp)
80105634:	85 c0                	test   %eax,%eax
80105636:	75 c3                	jne    801055fb <memcmp+0x18>
  }

  return 0;
80105638:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010563d:	c9                   	leave  
8010563e:	c3                   	ret    

8010563f <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010563f:	f3 0f 1e fb          	endbr32 
80105643:	55                   	push   %ebp
80105644:	89 e5                	mov    %esp,%ebp
80105646:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105649:	8b 45 0c             	mov    0xc(%ebp),%eax
8010564c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010564f:	8b 45 08             	mov    0x8(%ebp),%eax
80105652:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105655:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105658:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010565b:	73 54                	jae    801056b1 <memmove+0x72>
8010565d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105660:	8b 45 10             	mov    0x10(%ebp),%eax
80105663:	01 d0                	add    %edx,%eax
80105665:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105668:	73 47                	jae    801056b1 <memmove+0x72>
    s += n;
8010566a:	8b 45 10             	mov    0x10(%ebp),%eax
8010566d:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105670:	8b 45 10             	mov    0x10(%ebp),%eax
80105673:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105676:	eb 13                	jmp    8010568b <memmove+0x4c>
      *--d = *--s;
80105678:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010567c:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105680:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105683:	0f b6 10             	movzbl (%eax),%edx
80105686:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105689:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010568b:	8b 45 10             	mov    0x10(%ebp),%eax
8010568e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105691:	89 55 10             	mov    %edx,0x10(%ebp)
80105694:	85 c0                	test   %eax,%eax
80105696:	75 e0                	jne    80105678 <memmove+0x39>
  if(s < d && s + n > d){
80105698:	eb 24                	jmp    801056be <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
8010569a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010569d:	8d 42 01             	lea    0x1(%edx),%eax
801056a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
801056a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056a6:	8d 48 01             	lea    0x1(%eax),%ecx
801056a9:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801056ac:	0f b6 12             	movzbl (%edx),%edx
801056af:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801056b1:	8b 45 10             	mov    0x10(%ebp),%eax
801056b4:	8d 50 ff             	lea    -0x1(%eax),%edx
801056b7:	89 55 10             	mov    %edx,0x10(%ebp)
801056ba:	85 c0                	test   %eax,%eax
801056bc:	75 dc                	jne    8010569a <memmove+0x5b>

  return dst;
801056be:	8b 45 08             	mov    0x8(%ebp),%eax
}
801056c1:	c9                   	leave  
801056c2:	c3                   	ret    

801056c3 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801056c3:	f3 0f 1e fb          	endbr32 
801056c7:	55                   	push   %ebp
801056c8:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801056ca:	ff 75 10             	pushl  0x10(%ebp)
801056cd:	ff 75 0c             	pushl  0xc(%ebp)
801056d0:	ff 75 08             	pushl  0x8(%ebp)
801056d3:	e8 67 ff ff ff       	call   8010563f <memmove>
801056d8:	83 c4 0c             	add    $0xc,%esp
}
801056db:	c9                   	leave  
801056dc:	c3                   	ret    

801056dd <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801056dd:	f3 0f 1e fb          	endbr32 
801056e1:	55                   	push   %ebp
801056e2:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801056e4:	eb 0c                	jmp    801056f2 <strncmp+0x15>
    n--, p++, q++;
801056e6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056ea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801056ee:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801056f2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056f6:	74 1a                	je     80105712 <strncmp+0x35>
801056f8:	8b 45 08             	mov    0x8(%ebp),%eax
801056fb:	0f b6 00             	movzbl (%eax),%eax
801056fe:	84 c0                	test   %al,%al
80105700:	74 10                	je     80105712 <strncmp+0x35>
80105702:	8b 45 08             	mov    0x8(%ebp),%eax
80105705:	0f b6 10             	movzbl (%eax),%edx
80105708:	8b 45 0c             	mov    0xc(%ebp),%eax
8010570b:	0f b6 00             	movzbl (%eax),%eax
8010570e:	38 c2                	cmp    %al,%dl
80105710:	74 d4                	je     801056e6 <strncmp+0x9>
  if(n == 0)
80105712:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105716:	75 07                	jne    8010571f <strncmp+0x42>
    return 0;
80105718:	b8 00 00 00 00       	mov    $0x0,%eax
8010571d:	eb 16                	jmp    80105735 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
8010571f:	8b 45 08             	mov    0x8(%ebp),%eax
80105722:	0f b6 00             	movzbl (%eax),%eax
80105725:	0f b6 d0             	movzbl %al,%edx
80105728:	8b 45 0c             	mov    0xc(%ebp),%eax
8010572b:	0f b6 00             	movzbl (%eax),%eax
8010572e:	0f b6 c0             	movzbl %al,%eax
80105731:	29 c2                	sub    %eax,%edx
80105733:	89 d0                	mov    %edx,%eax
}
80105735:	5d                   	pop    %ebp
80105736:	c3                   	ret    

80105737 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105737:	f3 0f 1e fb          	endbr32 
8010573b:	55                   	push   %ebp
8010573c:	89 e5                	mov    %esp,%ebp
8010573e:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105741:	8b 45 08             	mov    0x8(%ebp),%eax
80105744:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105747:	90                   	nop
80105748:	8b 45 10             	mov    0x10(%ebp),%eax
8010574b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010574e:	89 55 10             	mov    %edx,0x10(%ebp)
80105751:	85 c0                	test   %eax,%eax
80105753:	7e 2c                	jle    80105781 <strncpy+0x4a>
80105755:	8b 55 0c             	mov    0xc(%ebp),%edx
80105758:	8d 42 01             	lea    0x1(%edx),%eax
8010575b:	89 45 0c             	mov    %eax,0xc(%ebp)
8010575e:	8b 45 08             	mov    0x8(%ebp),%eax
80105761:	8d 48 01             	lea    0x1(%eax),%ecx
80105764:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105767:	0f b6 12             	movzbl (%edx),%edx
8010576a:	88 10                	mov    %dl,(%eax)
8010576c:	0f b6 00             	movzbl (%eax),%eax
8010576f:	84 c0                	test   %al,%al
80105771:	75 d5                	jne    80105748 <strncpy+0x11>
    ;
  while(n-- > 0)
80105773:	eb 0c                	jmp    80105781 <strncpy+0x4a>
    *s++ = 0;
80105775:	8b 45 08             	mov    0x8(%ebp),%eax
80105778:	8d 50 01             	lea    0x1(%eax),%edx
8010577b:	89 55 08             	mov    %edx,0x8(%ebp)
8010577e:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105781:	8b 45 10             	mov    0x10(%ebp),%eax
80105784:	8d 50 ff             	lea    -0x1(%eax),%edx
80105787:	89 55 10             	mov    %edx,0x10(%ebp)
8010578a:	85 c0                	test   %eax,%eax
8010578c:	7f e7                	jg     80105775 <strncpy+0x3e>
  return os;
8010578e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105791:	c9                   	leave  
80105792:	c3                   	ret    

80105793 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105793:	f3 0f 1e fb          	endbr32 
80105797:	55                   	push   %ebp
80105798:	89 e5                	mov    %esp,%ebp
8010579a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010579d:	8b 45 08             	mov    0x8(%ebp),%eax
801057a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801057a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057a7:	7f 05                	jg     801057ae <safestrcpy+0x1b>
    return os;
801057a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057ac:	eb 31                	jmp    801057df <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801057ae:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057b6:	7e 1e                	jle    801057d6 <safestrcpy+0x43>
801057b8:	8b 55 0c             	mov    0xc(%ebp),%edx
801057bb:	8d 42 01             	lea    0x1(%edx),%eax
801057be:	89 45 0c             	mov    %eax,0xc(%ebp)
801057c1:	8b 45 08             	mov    0x8(%ebp),%eax
801057c4:	8d 48 01             	lea    0x1(%eax),%ecx
801057c7:	89 4d 08             	mov    %ecx,0x8(%ebp)
801057ca:	0f b6 12             	movzbl (%edx),%edx
801057cd:	88 10                	mov    %dl,(%eax)
801057cf:	0f b6 00             	movzbl (%eax),%eax
801057d2:	84 c0                	test   %al,%al
801057d4:	75 d8                	jne    801057ae <safestrcpy+0x1b>
    ;
  *s = 0;
801057d6:	8b 45 08             	mov    0x8(%ebp),%eax
801057d9:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801057dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057df:	c9                   	leave  
801057e0:	c3                   	ret    

801057e1 <strlen>:

int
strlen(const char *s)
{
801057e1:	f3 0f 1e fb          	endbr32 
801057e5:	55                   	push   %ebp
801057e6:	89 e5                	mov    %esp,%ebp
801057e8:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801057eb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057f2:	eb 04                	jmp    801057f8 <strlen+0x17>
801057f4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057f8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057fb:	8b 45 08             	mov    0x8(%ebp),%eax
801057fe:	01 d0                	add    %edx,%eax
80105800:	0f b6 00             	movzbl (%eax),%eax
80105803:	84 c0                	test   %al,%al
80105805:	75 ed                	jne    801057f4 <strlen+0x13>
    ;
  return n;
80105807:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010580a:	c9                   	leave  
8010580b:	c3                   	ret    

8010580c <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010580c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105810:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80105814:	55                   	push   %ebp
  pushl %ebx
80105815:	53                   	push   %ebx
  pushl %esi
80105816:	56                   	push   %esi
  pushl %edi
80105817:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105818:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010581a:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
8010581c:	5f                   	pop    %edi
  popl %esi
8010581d:	5e                   	pop    %esi
  popl %ebx
8010581e:	5b                   	pop    %ebx
  popl %ebp
8010581f:	5d                   	pop    %ebp
  ret
80105820:	c3                   	ret    

80105821 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105821:	f3 0f 1e fb          	endbr32 
80105825:	55                   	push   %ebp
80105826:	89 e5                	mov    %esp,%ebp
80105828:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010582b:	e8 90 ec ff ff       	call   801044c0 <myproc>
80105830:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105833:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105836:	8b 00                	mov    (%eax),%eax
80105838:	39 45 08             	cmp    %eax,0x8(%ebp)
8010583b:	73 0f                	jae    8010584c <fetchint+0x2b>
8010583d:	8b 45 08             	mov    0x8(%ebp),%eax
80105840:	8d 50 04             	lea    0x4(%eax),%edx
80105843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105846:	8b 00                	mov    (%eax),%eax
80105848:	39 c2                	cmp    %eax,%edx
8010584a:	76 07                	jbe    80105853 <fetchint+0x32>
    return -1;
8010584c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105851:	eb 0f                	jmp    80105862 <fetchint+0x41>
  *ip = *(int*)(addr);
80105853:	8b 45 08             	mov    0x8(%ebp),%eax
80105856:	8b 10                	mov    (%eax),%edx
80105858:	8b 45 0c             	mov    0xc(%ebp),%eax
8010585b:	89 10                	mov    %edx,(%eax)
  return 0;
8010585d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105862:	c9                   	leave  
80105863:	c3                   	ret    

80105864 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105864:	f3 0f 1e fb          	endbr32 
80105868:	55                   	push   %ebp
80105869:	89 e5                	mov    %esp,%ebp
8010586b:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010586e:	e8 4d ec ff ff       	call   801044c0 <myproc>
80105873:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105876:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105879:	8b 00                	mov    (%eax),%eax
8010587b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010587e:	72 07                	jb     80105887 <fetchstr+0x23>
    return -1;
80105880:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105885:	eb 43                	jmp    801058ca <fetchstr+0x66>
  *pp = (char*)addr;
80105887:	8b 55 08             	mov    0x8(%ebp),%edx
8010588a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010588d:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010588f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105892:	8b 00                	mov    (%eax),%eax
80105894:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105897:	8b 45 0c             	mov    0xc(%ebp),%eax
8010589a:	8b 00                	mov    (%eax),%eax
8010589c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010589f:	eb 1c                	jmp    801058bd <fetchstr+0x59>
    if(*s == 0)
801058a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a4:	0f b6 00             	movzbl (%eax),%eax
801058a7:	84 c0                	test   %al,%al
801058a9:	75 0e                	jne    801058b9 <fetchstr+0x55>
      return s - *pp;
801058ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801058ae:	8b 00                	mov    (%eax),%eax
801058b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058b3:	29 c2                	sub    %eax,%edx
801058b5:	89 d0                	mov    %edx,%eax
801058b7:	eb 11                	jmp    801058ca <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
801058b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801058bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801058c3:	72 dc                	jb     801058a1 <fetchstr+0x3d>
  }
  return -1;
801058c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058ca:	c9                   	leave  
801058cb:	c3                   	ret    

801058cc <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801058cc:	f3 0f 1e fb          	endbr32 
801058d0:	55                   	push   %ebp
801058d1:	89 e5                	mov    %esp,%ebp
801058d3:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801058d6:	e8 e5 eb ff ff       	call   801044c0 <myproc>
801058db:	8b 40 18             	mov    0x18(%eax),%eax
801058de:	8b 40 44             	mov    0x44(%eax),%eax
801058e1:	8b 55 08             	mov    0x8(%ebp),%edx
801058e4:	c1 e2 02             	shl    $0x2,%edx
801058e7:	01 d0                	add    %edx,%eax
801058e9:	83 c0 04             	add    $0x4,%eax
801058ec:	83 ec 08             	sub    $0x8,%esp
801058ef:	ff 75 0c             	pushl  0xc(%ebp)
801058f2:	50                   	push   %eax
801058f3:	e8 29 ff ff ff       	call   80105821 <fetchint>
801058f8:	83 c4 10             	add    $0x10,%esp
}
801058fb:	c9                   	leave  
801058fc:	c3                   	ret    

801058fd <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801058fd:	f3 0f 1e fb          	endbr32 
80105901:	55                   	push   %ebp
80105902:	89 e5                	mov    %esp,%ebp
80105904:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105907:	e8 b4 eb ff ff       	call   801044c0 <myproc>
8010590c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010590f:	83 ec 08             	sub    $0x8,%esp
80105912:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105915:	50                   	push   %eax
80105916:	ff 75 08             	pushl  0x8(%ebp)
80105919:	e8 ae ff ff ff       	call   801058cc <argint>
8010591e:	83 c4 10             	add    $0x10,%esp
80105921:	85 c0                	test   %eax,%eax
80105923:	79 07                	jns    8010592c <argptr+0x2f>
    return -1;
80105925:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010592a:	eb 3b                	jmp    80105967 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010592c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105930:	78 1f                	js     80105951 <argptr+0x54>
80105932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105935:	8b 00                	mov    (%eax),%eax
80105937:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010593a:	39 d0                	cmp    %edx,%eax
8010593c:	76 13                	jbe    80105951 <argptr+0x54>
8010593e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105941:	89 c2                	mov    %eax,%edx
80105943:	8b 45 10             	mov    0x10(%ebp),%eax
80105946:	01 c2                	add    %eax,%edx
80105948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594b:	8b 00                	mov    (%eax),%eax
8010594d:	39 c2                	cmp    %eax,%edx
8010594f:	76 07                	jbe    80105958 <argptr+0x5b>
    return -1;
80105951:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105956:	eb 0f                	jmp    80105967 <argptr+0x6a>
  *pp = (char*)i;
80105958:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010595b:	89 c2                	mov    %eax,%edx
8010595d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105960:	89 10                	mov    %edx,(%eax)
  return 0;
80105962:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105967:	c9                   	leave  
80105968:	c3                   	ret    

80105969 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105969:	f3 0f 1e fb          	endbr32 
8010596d:	55                   	push   %ebp
8010596e:	89 e5                	mov    %esp,%ebp
80105970:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105973:	83 ec 08             	sub    $0x8,%esp
80105976:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105979:	50                   	push   %eax
8010597a:	ff 75 08             	pushl  0x8(%ebp)
8010597d:	e8 4a ff ff ff       	call   801058cc <argint>
80105982:	83 c4 10             	add    $0x10,%esp
80105985:	85 c0                	test   %eax,%eax
80105987:	79 07                	jns    80105990 <argstr+0x27>
    return -1;
80105989:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010598e:	eb 12                	jmp    801059a2 <argstr+0x39>
  return fetchstr(addr, pp);
80105990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105993:	83 ec 08             	sub    $0x8,%esp
80105996:	ff 75 0c             	pushl  0xc(%ebp)
80105999:	50                   	push   %eax
8010599a:	e8 c5 fe ff ff       	call   80105864 <fetchstr>
8010599f:	83 c4 10             	add    $0x10,%esp
}
801059a2:	c9                   	leave  
801059a3:	c3                   	ret    

801059a4 <syscall>:
[SYS_dump_rawphymem] sys_dump_rawphymem,
};

void
syscall(void)
{
801059a4:	f3 0f 1e fb          	endbr32 
801059a8:	55                   	push   %ebp
801059a9:	89 e5                	mov    %esp,%ebp
801059ab:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801059ae:	e8 0d eb ff ff       	call   801044c0 <myproc>
801059b3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801059b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b9:	8b 40 18             	mov    0x18(%eax),%eax
801059bc:	8b 40 1c             	mov    0x1c(%eax),%eax
801059bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801059c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059c6:	7e 2f                	jle    801059f7 <syscall+0x53>
801059c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059cb:	83 f8 18             	cmp    $0x18,%eax
801059ce:	77 27                	ja     801059f7 <syscall+0x53>
801059d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d3:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801059da:	85 c0                	test   %eax,%eax
801059dc:	74 19                	je     801059f7 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
801059de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e1:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801059e8:	ff d0                	call   *%eax
801059ea:	89 c2                	mov    %eax,%edx
801059ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ef:	8b 40 18             	mov    0x18(%eax),%eax
801059f2:	89 50 1c             	mov    %edx,0x1c(%eax)
801059f5:	eb 2c                	jmp    80105a23 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801059f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059fa:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801059fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a00:	8b 40 10             	mov    0x10(%eax),%eax
80105a03:	ff 75 f0             	pushl  -0x10(%ebp)
80105a06:	52                   	push   %edx
80105a07:	50                   	push   %eax
80105a08:	68 f0 97 10 80       	push   $0x801097f0
80105a0d:	e8 06 aa ff ff       	call   80100418 <cprintf>
80105a12:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a18:	8b 40 18             	mov    0x18(%eax),%eax
80105a1b:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a22:	90                   	nop
80105a23:	90                   	nop
80105a24:	c9                   	leave  
80105a25:	c3                   	ret    

80105a26 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a26:	f3 0f 1e fb          	endbr32 
80105a2a:	55                   	push   %ebp
80105a2b:	89 e5                	mov    %esp,%ebp
80105a2d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a30:	83 ec 08             	sub    $0x8,%esp
80105a33:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a36:	50                   	push   %eax
80105a37:	ff 75 08             	pushl  0x8(%ebp)
80105a3a:	e8 8d fe ff ff       	call   801058cc <argint>
80105a3f:	83 c4 10             	add    $0x10,%esp
80105a42:	85 c0                	test   %eax,%eax
80105a44:	79 07                	jns    80105a4d <argfd+0x27>
    return -1;
80105a46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a4b:	eb 4f                	jmp    80105a9c <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a50:	85 c0                	test   %eax,%eax
80105a52:	78 20                	js     80105a74 <argfd+0x4e>
80105a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a57:	83 f8 0f             	cmp    $0xf,%eax
80105a5a:	7f 18                	jg     80105a74 <argfd+0x4e>
80105a5c:	e8 5f ea ff ff       	call   801044c0 <myproc>
80105a61:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a64:	83 c2 08             	add    $0x8,%edx
80105a67:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a72:	75 07                	jne    80105a7b <argfd+0x55>
    return -1;
80105a74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a79:	eb 21                	jmp    80105a9c <argfd+0x76>
  if(pfd)
80105a7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a7f:	74 08                	je     80105a89 <argfd+0x63>
    *pfd = fd;
80105a81:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a84:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a87:	89 10                	mov    %edx,(%eax)
  if(pf)
80105a89:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a8d:	74 08                	je     80105a97 <argfd+0x71>
    *pf = f;
80105a8f:	8b 45 10             	mov    0x10(%ebp),%eax
80105a92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a95:	89 10                	mov    %edx,(%eax)
  return 0;
80105a97:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a9c:	c9                   	leave  
80105a9d:	c3                   	ret    

80105a9e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105a9e:	f3 0f 1e fb          	endbr32 
80105aa2:	55                   	push   %ebp
80105aa3:	89 e5                	mov    %esp,%ebp
80105aa5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105aa8:	e8 13 ea ff ff       	call   801044c0 <myproc>
80105aad:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105ab0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ab7:	eb 2a                	jmp    80105ae3 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105abf:	83 c2 08             	add    $0x8,%edx
80105ac2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105ac6:	85 c0                	test   %eax,%eax
80105ac8:	75 15                	jne    80105adf <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105acd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ad0:	8d 4a 08             	lea    0x8(%edx),%ecx
80105ad3:	8b 55 08             	mov    0x8(%ebp),%edx
80105ad6:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105add:	eb 0f                	jmp    80105aee <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105adf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105ae3:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105ae7:	7e d0                	jle    80105ab9 <fdalloc+0x1b>
    }
  }
  return -1;
80105ae9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105aee:	c9                   	leave  
80105aef:	c3                   	ret    

80105af0 <sys_dup>:

int
sys_dup(void)
{
80105af0:	f3 0f 1e fb          	endbr32 
80105af4:	55                   	push   %ebp
80105af5:	89 e5                	mov    %esp,%ebp
80105af7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105afa:	83 ec 04             	sub    $0x4,%esp
80105afd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b00:	50                   	push   %eax
80105b01:	6a 00                	push   $0x0
80105b03:	6a 00                	push   $0x0
80105b05:	e8 1c ff ff ff       	call   80105a26 <argfd>
80105b0a:	83 c4 10             	add    $0x10,%esp
80105b0d:	85 c0                	test   %eax,%eax
80105b0f:	79 07                	jns    80105b18 <sys_dup+0x28>
    return -1;
80105b11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b16:	eb 31                	jmp    80105b49 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b1b:	83 ec 0c             	sub    $0xc,%esp
80105b1e:	50                   	push   %eax
80105b1f:	e8 7a ff ff ff       	call   80105a9e <fdalloc>
80105b24:	83 c4 10             	add    $0x10,%esp
80105b27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b2e:	79 07                	jns    80105b37 <sys_dup+0x47>
    return -1;
80105b30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b35:	eb 12                	jmp    80105b49 <sys_dup+0x59>
  filedup(f);
80105b37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b3a:	83 ec 0c             	sub    $0xc,%esp
80105b3d:	50                   	push   %eax
80105b3e:	e8 1a b6 ff ff       	call   8010115d <filedup>
80105b43:	83 c4 10             	add    $0x10,%esp
  return fd;
80105b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b49:	c9                   	leave  
80105b4a:	c3                   	ret    

80105b4b <sys_read>:

int
sys_read(void)
{
80105b4b:	f3 0f 1e fb          	endbr32 
80105b4f:	55                   	push   %ebp
80105b50:	89 e5                	mov    %esp,%ebp
80105b52:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b55:	83 ec 04             	sub    $0x4,%esp
80105b58:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b5b:	50                   	push   %eax
80105b5c:	6a 00                	push   $0x0
80105b5e:	6a 00                	push   $0x0
80105b60:	e8 c1 fe ff ff       	call   80105a26 <argfd>
80105b65:	83 c4 10             	add    $0x10,%esp
80105b68:	85 c0                	test   %eax,%eax
80105b6a:	78 2e                	js     80105b9a <sys_read+0x4f>
80105b6c:	83 ec 08             	sub    $0x8,%esp
80105b6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b72:	50                   	push   %eax
80105b73:	6a 02                	push   $0x2
80105b75:	e8 52 fd ff ff       	call   801058cc <argint>
80105b7a:	83 c4 10             	add    $0x10,%esp
80105b7d:	85 c0                	test   %eax,%eax
80105b7f:	78 19                	js     80105b9a <sys_read+0x4f>
80105b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b84:	83 ec 04             	sub    $0x4,%esp
80105b87:	50                   	push   %eax
80105b88:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b8b:	50                   	push   %eax
80105b8c:	6a 01                	push   $0x1
80105b8e:	e8 6a fd ff ff       	call   801058fd <argptr>
80105b93:	83 c4 10             	add    $0x10,%esp
80105b96:	85 c0                	test   %eax,%eax
80105b98:	79 07                	jns    80105ba1 <sys_read+0x56>
    return -1;
80105b9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b9f:	eb 17                	jmp    80105bb8 <sys_read+0x6d>
  return fileread(f, p, n);
80105ba1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ba4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105baa:	83 ec 04             	sub    $0x4,%esp
80105bad:	51                   	push   %ecx
80105bae:	52                   	push   %edx
80105baf:	50                   	push   %eax
80105bb0:	e8 44 b7 ff ff       	call   801012f9 <fileread>
80105bb5:	83 c4 10             	add    $0x10,%esp
}
80105bb8:	c9                   	leave  
80105bb9:	c3                   	ret    

80105bba <sys_write>:

int
sys_write(void)
{
80105bba:	f3 0f 1e fb          	endbr32 
80105bbe:	55                   	push   %ebp
80105bbf:	89 e5                	mov    %esp,%ebp
80105bc1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105bc4:	83 ec 04             	sub    $0x4,%esp
80105bc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bca:	50                   	push   %eax
80105bcb:	6a 00                	push   $0x0
80105bcd:	6a 00                	push   $0x0
80105bcf:	e8 52 fe ff ff       	call   80105a26 <argfd>
80105bd4:	83 c4 10             	add    $0x10,%esp
80105bd7:	85 c0                	test   %eax,%eax
80105bd9:	78 2e                	js     80105c09 <sys_write+0x4f>
80105bdb:	83 ec 08             	sub    $0x8,%esp
80105bde:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105be1:	50                   	push   %eax
80105be2:	6a 02                	push   $0x2
80105be4:	e8 e3 fc ff ff       	call   801058cc <argint>
80105be9:	83 c4 10             	add    $0x10,%esp
80105bec:	85 c0                	test   %eax,%eax
80105bee:	78 19                	js     80105c09 <sys_write+0x4f>
80105bf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf3:	83 ec 04             	sub    $0x4,%esp
80105bf6:	50                   	push   %eax
80105bf7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bfa:	50                   	push   %eax
80105bfb:	6a 01                	push   $0x1
80105bfd:	e8 fb fc ff ff       	call   801058fd <argptr>
80105c02:	83 c4 10             	add    $0x10,%esp
80105c05:	85 c0                	test   %eax,%eax
80105c07:	79 07                	jns    80105c10 <sys_write+0x56>
    return -1;
80105c09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c0e:	eb 17                	jmp    80105c27 <sys_write+0x6d>
  return filewrite(f, p, n);
80105c10:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c13:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c19:	83 ec 04             	sub    $0x4,%esp
80105c1c:	51                   	push   %ecx
80105c1d:	52                   	push   %edx
80105c1e:	50                   	push   %eax
80105c1f:	e8 91 b7 ff ff       	call   801013b5 <filewrite>
80105c24:	83 c4 10             	add    $0x10,%esp
}
80105c27:	c9                   	leave  
80105c28:	c3                   	ret    

80105c29 <sys_close>:

int
sys_close(void)
{
80105c29:	f3 0f 1e fb          	endbr32 
80105c2d:	55                   	push   %ebp
80105c2e:	89 e5                	mov    %esp,%ebp
80105c30:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105c33:	83 ec 04             	sub    $0x4,%esp
80105c36:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c39:	50                   	push   %eax
80105c3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c3d:	50                   	push   %eax
80105c3e:	6a 00                	push   $0x0
80105c40:	e8 e1 fd ff ff       	call   80105a26 <argfd>
80105c45:	83 c4 10             	add    $0x10,%esp
80105c48:	85 c0                	test   %eax,%eax
80105c4a:	79 07                	jns    80105c53 <sys_close+0x2a>
    return -1;
80105c4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c51:	eb 27                	jmp    80105c7a <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105c53:	e8 68 e8 ff ff       	call   801044c0 <myproc>
80105c58:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c5b:	83 c2 08             	add    $0x8,%edx
80105c5e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c65:	00 
  fileclose(f);
80105c66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c69:	83 ec 0c             	sub    $0xc,%esp
80105c6c:	50                   	push   %eax
80105c6d:	e8 40 b5 ff ff       	call   801011b2 <fileclose>
80105c72:	83 c4 10             	add    $0x10,%esp
  return 0;
80105c75:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c7a:	c9                   	leave  
80105c7b:	c3                   	ret    

80105c7c <sys_fstat>:

int
sys_fstat(void)
{
80105c7c:	f3 0f 1e fb          	endbr32 
80105c80:	55                   	push   %ebp
80105c81:	89 e5                	mov    %esp,%ebp
80105c83:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105c86:	83 ec 04             	sub    $0x4,%esp
80105c89:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c8c:	50                   	push   %eax
80105c8d:	6a 00                	push   $0x0
80105c8f:	6a 00                	push   $0x0
80105c91:	e8 90 fd ff ff       	call   80105a26 <argfd>
80105c96:	83 c4 10             	add    $0x10,%esp
80105c99:	85 c0                	test   %eax,%eax
80105c9b:	78 17                	js     80105cb4 <sys_fstat+0x38>
80105c9d:	83 ec 04             	sub    $0x4,%esp
80105ca0:	6a 14                	push   $0x14
80105ca2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ca5:	50                   	push   %eax
80105ca6:	6a 01                	push   $0x1
80105ca8:	e8 50 fc ff ff       	call   801058fd <argptr>
80105cad:	83 c4 10             	add    $0x10,%esp
80105cb0:	85 c0                	test   %eax,%eax
80105cb2:	79 07                	jns    80105cbb <sys_fstat+0x3f>
    return -1;
80105cb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb9:	eb 13                	jmp    80105cce <sys_fstat+0x52>
  return filestat(f, st);
80105cbb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc1:	83 ec 08             	sub    $0x8,%esp
80105cc4:	52                   	push   %edx
80105cc5:	50                   	push   %eax
80105cc6:	e8 d3 b5 ff ff       	call   8010129e <filestat>
80105ccb:	83 c4 10             	add    $0x10,%esp
}
80105cce:	c9                   	leave  
80105ccf:	c3                   	ret    

80105cd0 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105cd0:	f3 0f 1e fb          	endbr32 
80105cd4:	55                   	push   %ebp
80105cd5:	89 e5                	mov    %esp,%ebp
80105cd7:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105cda:	83 ec 08             	sub    $0x8,%esp
80105cdd:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105ce0:	50                   	push   %eax
80105ce1:	6a 00                	push   $0x0
80105ce3:	e8 81 fc ff ff       	call   80105969 <argstr>
80105ce8:	83 c4 10             	add    $0x10,%esp
80105ceb:	85 c0                	test   %eax,%eax
80105ced:	78 15                	js     80105d04 <sys_link+0x34>
80105cef:	83 ec 08             	sub    $0x8,%esp
80105cf2:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105cf5:	50                   	push   %eax
80105cf6:	6a 01                	push   $0x1
80105cf8:	e8 6c fc ff ff       	call   80105969 <argstr>
80105cfd:	83 c4 10             	add    $0x10,%esp
80105d00:	85 c0                	test   %eax,%eax
80105d02:	79 0a                	jns    80105d0e <sys_link+0x3e>
    return -1;
80105d04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d09:	e9 68 01 00 00       	jmp    80105e76 <sys_link+0x1a6>

  begin_op();
80105d0e:	e8 ee d9 ff ff       	call   80103701 <begin_op>
  if((ip = namei(old)) == 0){
80105d13:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d16:	83 ec 0c             	sub    $0xc,%esp
80105d19:	50                   	push   %eax
80105d1a:	e8 7e c9 ff ff       	call   8010269d <namei>
80105d1f:	83 c4 10             	add    $0x10,%esp
80105d22:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d25:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d29:	75 0f                	jne    80105d3a <sys_link+0x6a>
    end_op();
80105d2b:	e8 61 da ff ff       	call   80103791 <end_op>
    return -1;
80105d30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d35:	e9 3c 01 00 00       	jmp    80105e76 <sys_link+0x1a6>
  }

  ilock(ip);
80105d3a:	83 ec 0c             	sub    $0xc,%esp
80105d3d:	ff 75 f4             	pushl  -0xc(%ebp)
80105d40:	e8 ed bd ff ff       	call   80101b32 <ilock>
80105d45:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d4f:	66 83 f8 01          	cmp    $0x1,%ax
80105d53:	75 1d                	jne    80105d72 <sys_link+0xa2>
    iunlockput(ip);
80105d55:	83 ec 0c             	sub    $0xc,%esp
80105d58:	ff 75 f4             	pushl  -0xc(%ebp)
80105d5b:	e8 0f c0 ff ff       	call   80101d6f <iunlockput>
80105d60:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d63:	e8 29 da ff ff       	call   80103791 <end_op>
    return -1;
80105d68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6d:	e9 04 01 00 00       	jmp    80105e76 <sys_link+0x1a6>
  }

  ip->nlink++;
80105d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d75:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d79:	83 c0 01             	add    $0x1,%eax
80105d7c:	89 c2                	mov    %eax,%edx
80105d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d81:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d85:	83 ec 0c             	sub    $0xc,%esp
80105d88:	ff 75 f4             	pushl  -0xc(%ebp)
80105d8b:	e8 b9 bb ff ff       	call   80101949 <iupdate>
80105d90:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105d93:	83 ec 0c             	sub    $0xc,%esp
80105d96:	ff 75 f4             	pushl  -0xc(%ebp)
80105d99:	e8 ab be ff ff       	call   80101c49 <iunlock>
80105d9e:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105da1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105da4:	83 ec 08             	sub    $0x8,%esp
80105da7:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105daa:	52                   	push   %edx
80105dab:	50                   	push   %eax
80105dac:	e8 0c c9 ff ff       	call   801026bd <nameiparent>
80105db1:	83 c4 10             	add    $0x10,%esp
80105db4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105db7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dbb:	74 71                	je     80105e2e <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105dbd:	83 ec 0c             	sub    $0xc,%esp
80105dc0:	ff 75 f0             	pushl  -0x10(%ebp)
80105dc3:	e8 6a bd ff ff       	call   80101b32 <ilock>
80105dc8:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dce:	8b 10                	mov    (%eax),%edx
80105dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd3:	8b 00                	mov    (%eax),%eax
80105dd5:	39 c2                	cmp    %eax,%edx
80105dd7:	75 1d                	jne    80105df6 <sys_link+0x126>
80105dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddc:	8b 40 04             	mov    0x4(%eax),%eax
80105ddf:	83 ec 04             	sub    $0x4,%esp
80105de2:	50                   	push   %eax
80105de3:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105de6:	50                   	push   %eax
80105de7:	ff 75 f0             	pushl  -0x10(%ebp)
80105dea:	e8 0b c6 ff ff       	call   801023fa <dirlink>
80105def:	83 c4 10             	add    $0x10,%esp
80105df2:	85 c0                	test   %eax,%eax
80105df4:	79 10                	jns    80105e06 <sys_link+0x136>
    iunlockput(dp);
80105df6:	83 ec 0c             	sub    $0xc,%esp
80105df9:	ff 75 f0             	pushl  -0x10(%ebp)
80105dfc:	e8 6e bf ff ff       	call   80101d6f <iunlockput>
80105e01:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105e04:	eb 29                	jmp    80105e2f <sys_link+0x15f>
  }
  iunlockput(dp);
80105e06:	83 ec 0c             	sub    $0xc,%esp
80105e09:	ff 75 f0             	pushl  -0x10(%ebp)
80105e0c:	e8 5e bf ff ff       	call   80101d6f <iunlockput>
80105e11:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105e14:	83 ec 0c             	sub    $0xc,%esp
80105e17:	ff 75 f4             	pushl  -0xc(%ebp)
80105e1a:	e8 7c be ff ff       	call   80101c9b <iput>
80105e1f:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e22:	e8 6a d9 ff ff       	call   80103791 <end_op>

  return 0;
80105e27:	b8 00 00 00 00       	mov    $0x0,%eax
80105e2c:	eb 48                	jmp    80105e76 <sys_link+0x1a6>
    goto bad;
80105e2e:	90                   	nop

bad:
  ilock(ip);
80105e2f:	83 ec 0c             	sub    $0xc,%esp
80105e32:	ff 75 f4             	pushl  -0xc(%ebp)
80105e35:	e8 f8 bc ff ff       	call   80101b32 <ilock>
80105e3a:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e40:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e44:	83 e8 01             	sub    $0x1,%eax
80105e47:	89 c2                	mov    %eax,%edx
80105e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4c:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e50:	83 ec 0c             	sub    $0xc,%esp
80105e53:	ff 75 f4             	pushl  -0xc(%ebp)
80105e56:	e8 ee ba ff ff       	call   80101949 <iupdate>
80105e5b:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e5e:	83 ec 0c             	sub    $0xc,%esp
80105e61:	ff 75 f4             	pushl  -0xc(%ebp)
80105e64:	e8 06 bf ff ff       	call   80101d6f <iunlockput>
80105e69:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e6c:	e8 20 d9 ff ff       	call   80103791 <end_op>
  return -1;
80105e71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e76:	c9                   	leave  
80105e77:	c3                   	ret    

80105e78 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105e78:	f3 0f 1e fb          	endbr32 
80105e7c:	55                   	push   %ebp
80105e7d:	89 e5                	mov    %esp,%ebp
80105e7f:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e82:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105e89:	eb 40                	jmp    80105ecb <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8e:	6a 10                	push   $0x10
80105e90:	50                   	push   %eax
80105e91:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e94:	50                   	push   %eax
80105e95:	ff 75 08             	pushl  0x8(%ebp)
80105e98:	e8 9d c1 ff ff       	call   8010203a <readi>
80105e9d:	83 c4 10             	add    $0x10,%esp
80105ea0:	83 f8 10             	cmp    $0x10,%eax
80105ea3:	74 0d                	je     80105eb2 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105ea5:	83 ec 0c             	sub    $0xc,%esp
80105ea8:	68 0c 98 10 80       	push   $0x8010980c
80105ead:	e8 56 a7 ff ff       	call   80100608 <panic>
    if(de.inum != 0)
80105eb2:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105eb6:	66 85 c0             	test   %ax,%ax
80105eb9:	74 07                	je     80105ec2 <isdirempty+0x4a>
      return 0;
80105ebb:	b8 00 00 00 00       	mov    $0x0,%eax
80105ec0:	eb 1b                	jmp    80105edd <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec5:	83 c0 10             	add    $0x10,%eax
80105ec8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ecb:	8b 45 08             	mov    0x8(%ebp),%eax
80105ece:	8b 50 58             	mov    0x58(%eax),%edx
80105ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed4:	39 c2                	cmp    %eax,%edx
80105ed6:	77 b3                	ja     80105e8b <isdirempty+0x13>
  }
  return 1;
80105ed8:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105edd:	c9                   	leave  
80105ede:	c3                   	ret    

80105edf <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105edf:	f3 0f 1e fb          	endbr32 
80105ee3:	55                   	push   %ebp
80105ee4:	89 e5                	mov    %esp,%ebp
80105ee6:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105ee9:	83 ec 08             	sub    $0x8,%esp
80105eec:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105eef:	50                   	push   %eax
80105ef0:	6a 00                	push   $0x0
80105ef2:	e8 72 fa ff ff       	call   80105969 <argstr>
80105ef7:	83 c4 10             	add    $0x10,%esp
80105efa:	85 c0                	test   %eax,%eax
80105efc:	79 0a                	jns    80105f08 <sys_unlink+0x29>
    return -1;
80105efe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f03:	e9 bf 01 00 00       	jmp    801060c7 <sys_unlink+0x1e8>

  begin_op();
80105f08:	e8 f4 d7 ff ff       	call   80103701 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105f0d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f10:	83 ec 08             	sub    $0x8,%esp
80105f13:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f16:	52                   	push   %edx
80105f17:	50                   	push   %eax
80105f18:	e8 a0 c7 ff ff       	call   801026bd <nameiparent>
80105f1d:	83 c4 10             	add    $0x10,%esp
80105f20:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f27:	75 0f                	jne    80105f38 <sys_unlink+0x59>
    end_op();
80105f29:	e8 63 d8 ff ff       	call   80103791 <end_op>
    return -1;
80105f2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f33:	e9 8f 01 00 00       	jmp    801060c7 <sys_unlink+0x1e8>
  }

  ilock(dp);
80105f38:	83 ec 0c             	sub    $0xc,%esp
80105f3b:	ff 75 f4             	pushl  -0xc(%ebp)
80105f3e:	e8 ef bb ff ff       	call   80101b32 <ilock>
80105f43:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f46:	83 ec 08             	sub    $0x8,%esp
80105f49:	68 1e 98 10 80       	push   $0x8010981e
80105f4e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f51:	50                   	push   %eax
80105f52:	e8 c6 c3 ff ff       	call   8010231d <namecmp>
80105f57:	83 c4 10             	add    $0x10,%esp
80105f5a:	85 c0                	test   %eax,%eax
80105f5c:	0f 84 49 01 00 00    	je     801060ab <sys_unlink+0x1cc>
80105f62:	83 ec 08             	sub    $0x8,%esp
80105f65:	68 20 98 10 80       	push   $0x80109820
80105f6a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f6d:	50                   	push   %eax
80105f6e:	e8 aa c3 ff ff       	call   8010231d <namecmp>
80105f73:	83 c4 10             	add    $0x10,%esp
80105f76:	85 c0                	test   %eax,%eax
80105f78:	0f 84 2d 01 00 00    	je     801060ab <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105f7e:	83 ec 04             	sub    $0x4,%esp
80105f81:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105f84:	50                   	push   %eax
80105f85:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f88:	50                   	push   %eax
80105f89:	ff 75 f4             	pushl  -0xc(%ebp)
80105f8c:	e8 ab c3 ff ff       	call   8010233c <dirlookup>
80105f91:	83 c4 10             	add    $0x10,%esp
80105f94:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f97:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f9b:	0f 84 0d 01 00 00    	je     801060ae <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105fa1:	83 ec 0c             	sub    $0xc,%esp
80105fa4:	ff 75 f0             	pushl  -0x10(%ebp)
80105fa7:	e8 86 bb ff ff       	call   80101b32 <ilock>
80105fac:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105faf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105fb6:	66 85 c0             	test   %ax,%ax
80105fb9:	7f 0d                	jg     80105fc8 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105fbb:	83 ec 0c             	sub    $0xc,%esp
80105fbe:	68 23 98 10 80       	push   $0x80109823
80105fc3:	e8 40 a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fcb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105fcf:	66 83 f8 01          	cmp    $0x1,%ax
80105fd3:	75 25                	jne    80105ffa <sys_unlink+0x11b>
80105fd5:	83 ec 0c             	sub    $0xc,%esp
80105fd8:	ff 75 f0             	pushl  -0x10(%ebp)
80105fdb:	e8 98 fe ff ff       	call   80105e78 <isdirempty>
80105fe0:	83 c4 10             	add    $0x10,%esp
80105fe3:	85 c0                	test   %eax,%eax
80105fe5:	75 13                	jne    80105ffa <sys_unlink+0x11b>
    iunlockput(ip);
80105fe7:	83 ec 0c             	sub    $0xc,%esp
80105fea:	ff 75 f0             	pushl  -0x10(%ebp)
80105fed:	e8 7d bd ff ff       	call   80101d6f <iunlockput>
80105ff2:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ff5:	e9 b5 00 00 00       	jmp    801060af <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105ffa:	83 ec 04             	sub    $0x4,%esp
80105ffd:	6a 10                	push   $0x10
80105fff:	6a 00                	push   $0x0
80106001:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106004:	50                   	push   %eax
80106005:	e8 6e f5 ff ff       	call   80105578 <memset>
8010600a:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010600d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106010:	6a 10                	push   $0x10
80106012:	50                   	push   %eax
80106013:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106016:	50                   	push   %eax
80106017:	ff 75 f4             	pushl  -0xc(%ebp)
8010601a:	e8 74 c1 ff ff       	call   80102193 <writei>
8010601f:	83 c4 10             	add    $0x10,%esp
80106022:	83 f8 10             	cmp    $0x10,%eax
80106025:	74 0d                	je     80106034 <sys_unlink+0x155>
    panic("unlink: writei");
80106027:	83 ec 0c             	sub    $0xc,%esp
8010602a:	68 35 98 10 80       	push   $0x80109835
8010602f:	e8 d4 a5 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR){
80106034:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106037:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010603b:	66 83 f8 01          	cmp    $0x1,%ax
8010603f:	75 21                	jne    80106062 <sys_unlink+0x183>
    dp->nlink--;
80106041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106044:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106048:	83 e8 01             	sub    $0x1,%eax
8010604b:	89 c2                	mov    %eax,%edx
8010604d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106050:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106054:	83 ec 0c             	sub    $0xc,%esp
80106057:	ff 75 f4             	pushl  -0xc(%ebp)
8010605a:	e8 ea b8 ff ff       	call   80101949 <iupdate>
8010605f:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106062:	83 ec 0c             	sub    $0xc,%esp
80106065:	ff 75 f4             	pushl  -0xc(%ebp)
80106068:	e8 02 bd ff ff       	call   80101d6f <iunlockput>
8010606d:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106070:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106073:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106077:	83 e8 01             	sub    $0x1,%eax
8010607a:	89 c2                	mov    %eax,%edx
8010607c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010607f:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80106083:	83 ec 0c             	sub    $0xc,%esp
80106086:	ff 75 f0             	pushl  -0x10(%ebp)
80106089:	e8 bb b8 ff ff       	call   80101949 <iupdate>
8010608e:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106091:	83 ec 0c             	sub    $0xc,%esp
80106094:	ff 75 f0             	pushl  -0x10(%ebp)
80106097:	e8 d3 bc ff ff       	call   80101d6f <iunlockput>
8010609c:	83 c4 10             	add    $0x10,%esp

  end_op();
8010609f:	e8 ed d6 ff ff       	call   80103791 <end_op>

  return 0;
801060a4:	b8 00 00 00 00       	mov    $0x0,%eax
801060a9:	eb 1c                	jmp    801060c7 <sys_unlink+0x1e8>
    goto bad;
801060ab:	90                   	nop
801060ac:	eb 01                	jmp    801060af <sys_unlink+0x1d0>
    goto bad;
801060ae:	90                   	nop

bad:
  iunlockput(dp);
801060af:	83 ec 0c             	sub    $0xc,%esp
801060b2:	ff 75 f4             	pushl  -0xc(%ebp)
801060b5:	e8 b5 bc ff ff       	call   80101d6f <iunlockput>
801060ba:	83 c4 10             	add    $0x10,%esp
  end_op();
801060bd:	e8 cf d6 ff ff       	call   80103791 <end_op>
  return -1;
801060c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060c7:	c9                   	leave  
801060c8:	c3                   	ret    

801060c9 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801060c9:	f3 0f 1e fb          	endbr32 
801060cd:	55                   	push   %ebp
801060ce:	89 e5                	mov    %esp,%ebp
801060d0:	83 ec 38             	sub    $0x38,%esp
801060d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801060d6:	8b 55 10             	mov    0x10(%ebp),%edx
801060d9:	8b 45 14             	mov    0x14(%ebp),%eax
801060dc:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801060e0:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801060e4:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801060e8:	83 ec 08             	sub    $0x8,%esp
801060eb:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801060ee:	50                   	push   %eax
801060ef:	ff 75 08             	pushl  0x8(%ebp)
801060f2:	e8 c6 c5 ff ff       	call   801026bd <nameiparent>
801060f7:	83 c4 10             	add    $0x10,%esp
801060fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106101:	75 0a                	jne    8010610d <create+0x44>
    return 0;
80106103:	b8 00 00 00 00       	mov    $0x0,%eax
80106108:	e9 8e 01 00 00       	jmp    8010629b <create+0x1d2>
  ilock(dp);
8010610d:	83 ec 0c             	sub    $0xc,%esp
80106110:	ff 75 f4             	pushl  -0xc(%ebp)
80106113:	e8 1a ba ff ff       	call   80101b32 <ilock>
80106118:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
8010611b:	83 ec 04             	sub    $0x4,%esp
8010611e:	6a 00                	push   $0x0
80106120:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106123:	50                   	push   %eax
80106124:	ff 75 f4             	pushl  -0xc(%ebp)
80106127:	e8 10 c2 ff ff       	call   8010233c <dirlookup>
8010612c:	83 c4 10             	add    $0x10,%esp
8010612f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106132:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106136:	74 50                	je     80106188 <create+0xbf>
    iunlockput(dp);
80106138:	83 ec 0c             	sub    $0xc,%esp
8010613b:	ff 75 f4             	pushl  -0xc(%ebp)
8010613e:	e8 2c bc ff ff       	call   80101d6f <iunlockput>
80106143:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106146:	83 ec 0c             	sub    $0xc,%esp
80106149:	ff 75 f0             	pushl  -0x10(%ebp)
8010614c:	e8 e1 b9 ff ff       	call   80101b32 <ilock>
80106151:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106154:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106159:	75 15                	jne    80106170 <create+0xa7>
8010615b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010615e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106162:	66 83 f8 02          	cmp    $0x2,%ax
80106166:	75 08                	jne    80106170 <create+0xa7>
      return ip;
80106168:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010616b:	e9 2b 01 00 00       	jmp    8010629b <create+0x1d2>
    iunlockput(ip);
80106170:	83 ec 0c             	sub    $0xc,%esp
80106173:	ff 75 f0             	pushl  -0x10(%ebp)
80106176:	e8 f4 bb ff ff       	call   80101d6f <iunlockput>
8010617b:	83 c4 10             	add    $0x10,%esp
    return 0;
8010617e:	b8 00 00 00 00       	mov    $0x0,%eax
80106183:	e9 13 01 00 00       	jmp    8010629b <create+0x1d2>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106188:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010618c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010618f:	8b 00                	mov    (%eax),%eax
80106191:	83 ec 08             	sub    $0x8,%esp
80106194:	52                   	push   %edx
80106195:	50                   	push   %eax
80106196:	e8 d3 b6 ff ff       	call   8010186e <ialloc>
8010619b:	83 c4 10             	add    $0x10,%esp
8010619e:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061a5:	75 0d                	jne    801061b4 <create+0xeb>
    panic("create: ialloc");
801061a7:	83 ec 0c             	sub    $0xc,%esp
801061aa:	68 44 98 10 80       	push   $0x80109844
801061af:	e8 54 a4 ff ff       	call   80100608 <panic>

  ilock(ip);
801061b4:	83 ec 0c             	sub    $0xc,%esp
801061b7:	ff 75 f0             	pushl  -0x10(%ebp)
801061ba:	e8 73 b9 ff ff       	call   80101b32 <ilock>
801061bf:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801061c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c5:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801061c9:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801061cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d0:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801061d4:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801061d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061db:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801061e1:	83 ec 0c             	sub    $0xc,%esp
801061e4:	ff 75 f0             	pushl  -0x10(%ebp)
801061e7:	e8 5d b7 ff ff       	call   80101949 <iupdate>
801061ec:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801061ef:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801061f4:	75 6a                	jne    80106260 <create+0x197>
    dp->nlink++;  // for ".."
801061f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801061fd:	83 c0 01             	add    $0x1,%eax
80106200:	89 c2                	mov    %eax,%edx
80106202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106205:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106209:	83 ec 0c             	sub    $0xc,%esp
8010620c:	ff 75 f4             	pushl  -0xc(%ebp)
8010620f:	e8 35 b7 ff ff       	call   80101949 <iupdate>
80106214:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106217:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010621a:	8b 40 04             	mov    0x4(%eax),%eax
8010621d:	83 ec 04             	sub    $0x4,%esp
80106220:	50                   	push   %eax
80106221:	68 1e 98 10 80       	push   $0x8010981e
80106226:	ff 75 f0             	pushl  -0x10(%ebp)
80106229:	e8 cc c1 ff ff       	call   801023fa <dirlink>
8010622e:	83 c4 10             	add    $0x10,%esp
80106231:	85 c0                	test   %eax,%eax
80106233:	78 1e                	js     80106253 <create+0x18a>
80106235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106238:	8b 40 04             	mov    0x4(%eax),%eax
8010623b:	83 ec 04             	sub    $0x4,%esp
8010623e:	50                   	push   %eax
8010623f:	68 20 98 10 80       	push   $0x80109820
80106244:	ff 75 f0             	pushl  -0x10(%ebp)
80106247:	e8 ae c1 ff ff       	call   801023fa <dirlink>
8010624c:	83 c4 10             	add    $0x10,%esp
8010624f:	85 c0                	test   %eax,%eax
80106251:	79 0d                	jns    80106260 <create+0x197>
      panic("create dots");
80106253:	83 ec 0c             	sub    $0xc,%esp
80106256:	68 53 98 10 80       	push   $0x80109853
8010625b:	e8 a8 a3 ff ff       	call   80100608 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106260:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106263:	8b 40 04             	mov    0x4(%eax),%eax
80106266:	83 ec 04             	sub    $0x4,%esp
80106269:	50                   	push   %eax
8010626a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010626d:	50                   	push   %eax
8010626e:	ff 75 f4             	pushl  -0xc(%ebp)
80106271:	e8 84 c1 ff ff       	call   801023fa <dirlink>
80106276:	83 c4 10             	add    $0x10,%esp
80106279:	85 c0                	test   %eax,%eax
8010627b:	79 0d                	jns    8010628a <create+0x1c1>
    panic("create: dirlink");
8010627d:	83 ec 0c             	sub    $0xc,%esp
80106280:	68 5f 98 10 80       	push   $0x8010985f
80106285:	e8 7e a3 ff ff       	call   80100608 <panic>

  iunlockput(dp);
8010628a:	83 ec 0c             	sub    $0xc,%esp
8010628d:	ff 75 f4             	pushl  -0xc(%ebp)
80106290:	e8 da ba ff ff       	call   80101d6f <iunlockput>
80106295:	83 c4 10             	add    $0x10,%esp

  return ip;
80106298:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010629b:	c9                   	leave  
8010629c:	c3                   	ret    

8010629d <sys_open>:

int
sys_open(void)
{
8010629d:	f3 0f 1e fb          	endbr32 
801062a1:	55                   	push   %ebp
801062a2:	89 e5                	mov    %esp,%ebp
801062a4:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801062a7:	83 ec 08             	sub    $0x8,%esp
801062aa:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062ad:	50                   	push   %eax
801062ae:	6a 00                	push   $0x0
801062b0:	e8 b4 f6 ff ff       	call   80105969 <argstr>
801062b5:	83 c4 10             	add    $0x10,%esp
801062b8:	85 c0                	test   %eax,%eax
801062ba:	78 15                	js     801062d1 <sys_open+0x34>
801062bc:	83 ec 08             	sub    $0x8,%esp
801062bf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062c2:	50                   	push   %eax
801062c3:	6a 01                	push   $0x1
801062c5:	e8 02 f6 ff ff       	call   801058cc <argint>
801062ca:	83 c4 10             	add    $0x10,%esp
801062cd:	85 c0                	test   %eax,%eax
801062cf:	79 0a                	jns    801062db <sys_open+0x3e>
    return -1;
801062d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d6:	e9 61 01 00 00       	jmp    8010643c <sys_open+0x19f>

  begin_op();
801062db:	e8 21 d4 ff ff       	call   80103701 <begin_op>

  if(omode & O_CREATE){
801062e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062e3:	25 00 02 00 00       	and    $0x200,%eax
801062e8:	85 c0                	test   %eax,%eax
801062ea:	74 2a                	je     80106316 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
801062ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062ef:	6a 00                	push   $0x0
801062f1:	6a 00                	push   $0x0
801062f3:	6a 02                	push   $0x2
801062f5:	50                   	push   %eax
801062f6:	e8 ce fd ff ff       	call   801060c9 <create>
801062fb:	83 c4 10             	add    $0x10,%esp
801062fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106301:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106305:	75 75                	jne    8010637c <sys_open+0xdf>
      end_op();
80106307:	e8 85 d4 ff ff       	call   80103791 <end_op>
      return -1;
8010630c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106311:	e9 26 01 00 00       	jmp    8010643c <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80106316:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106319:	83 ec 0c             	sub    $0xc,%esp
8010631c:	50                   	push   %eax
8010631d:	e8 7b c3 ff ff       	call   8010269d <namei>
80106322:	83 c4 10             	add    $0x10,%esp
80106325:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106328:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010632c:	75 0f                	jne    8010633d <sys_open+0xa0>
      end_op();
8010632e:	e8 5e d4 ff ff       	call   80103791 <end_op>
      return -1;
80106333:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106338:	e9 ff 00 00 00       	jmp    8010643c <sys_open+0x19f>
    }
    ilock(ip);
8010633d:	83 ec 0c             	sub    $0xc,%esp
80106340:	ff 75 f4             	pushl  -0xc(%ebp)
80106343:	e8 ea b7 ff ff       	call   80101b32 <ilock>
80106348:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010634b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010634e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106352:	66 83 f8 01          	cmp    $0x1,%ax
80106356:	75 24                	jne    8010637c <sys_open+0xdf>
80106358:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010635b:	85 c0                	test   %eax,%eax
8010635d:	74 1d                	je     8010637c <sys_open+0xdf>
      iunlockput(ip);
8010635f:	83 ec 0c             	sub    $0xc,%esp
80106362:	ff 75 f4             	pushl  -0xc(%ebp)
80106365:	e8 05 ba ff ff       	call   80101d6f <iunlockput>
8010636a:	83 c4 10             	add    $0x10,%esp
      end_op();
8010636d:	e8 1f d4 ff ff       	call   80103791 <end_op>
      return -1;
80106372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106377:	e9 c0 00 00 00       	jmp    8010643c <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010637c:	e8 6b ad ff ff       	call   801010ec <filealloc>
80106381:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106384:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106388:	74 17                	je     801063a1 <sys_open+0x104>
8010638a:	83 ec 0c             	sub    $0xc,%esp
8010638d:	ff 75 f0             	pushl  -0x10(%ebp)
80106390:	e8 09 f7 ff ff       	call   80105a9e <fdalloc>
80106395:	83 c4 10             	add    $0x10,%esp
80106398:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010639b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010639f:	79 2e                	jns    801063cf <sys_open+0x132>
    if(f)
801063a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063a5:	74 0e                	je     801063b5 <sys_open+0x118>
      fileclose(f);
801063a7:	83 ec 0c             	sub    $0xc,%esp
801063aa:	ff 75 f0             	pushl  -0x10(%ebp)
801063ad:	e8 00 ae ff ff       	call   801011b2 <fileclose>
801063b2:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801063b5:	83 ec 0c             	sub    $0xc,%esp
801063b8:	ff 75 f4             	pushl  -0xc(%ebp)
801063bb:	e8 af b9 ff ff       	call   80101d6f <iunlockput>
801063c0:	83 c4 10             	add    $0x10,%esp
    end_op();
801063c3:	e8 c9 d3 ff ff       	call   80103791 <end_op>
    return -1;
801063c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063cd:	eb 6d                	jmp    8010643c <sys_open+0x19f>
  }
  iunlock(ip);
801063cf:	83 ec 0c             	sub    $0xc,%esp
801063d2:	ff 75 f4             	pushl  -0xc(%ebp)
801063d5:	e8 6f b8 ff ff       	call   80101c49 <iunlock>
801063da:	83 c4 10             	add    $0x10,%esp
  end_op();
801063dd:	e8 af d3 ff ff       	call   80103791 <end_op>

  f->type = FD_INODE;
801063e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063e5:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801063eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063f1:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801063f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801063fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106401:	83 e0 01             	and    $0x1,%eax
80106404:	85 c0                	test   %eax,%eax
80106406:	0f 94 c0             	sete   %al
80106409:	89 c2                	mov    %eax,%edx
8010640b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010640e:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106411:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106414:	83 e0 01             	and    $0x1,%eax
80106417:	85 c0                	test   %eax,%eax
80106419:	75 0a                	jne    80106425 <sys_open+0x188>
8010641b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010641e:	83 e0 02             	and    $0x2,%eax
80106421:	85 c0                	test   %eax,%eax
80106423:	74 07                	je     8010642c <sys_open+0x18f>
80106425:	b8 01 00 00 00       	mov    $0x1,%eax
8010642a:	eb 05                	jmp    80106431 <sys_open+0x194>
8010642c:	b8 00 00 00 00       	mov    $0x0,%eax
80106431:	89 c2                	mov    %eax,%edx
80106433:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106436:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106439:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010643c:	c9                   	leave  
8010643d:	c3                   	ret    

8010643e <sys_mkdir>:

int
sys_mkdir(void)
{
8010643e:	f3 0f 1e fb          	endbr32 
80106442:	55                   	push   %ebp
80106443:	89 e5                	mov    %esp,%ebp
80106445:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106448:	e8 b4 d2 ff ff       	call   80103701 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010644d:	83 ec 08             	sub    $0x8,%esp
80106450:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106453:	50                   	push   %eax
80106454:	6a 00                	push   $0x0
80106456:	e8 0e f5 ff ff       	call   80105969 <argstr>
8010645b:	83 c4 10             	add    $0x10,%esp
8010645e:	85 c0                	test   %eax,%eax
80106460:	78 1b                	js     8010647d <sys_mkdir+0x3f>
80106462:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106465:	6a 00                	push   $0x0
80106467:	6a 00                	push   $0x0
80106469:	6a 01                	push   $0x1
8010646b:	50                   	push   %eax
8010646c:	e8 58 fc ff ff       	call   801060c9 <create>
80106471:	83 c4 10             	add    $0x10,%esp
80106474:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106477:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010647b:	75 0c                	jne    80106489 <sys_mkdir+0x4b>
    end_op();
8010647d:	e8 0f d3 ff ff       	call   80103791 <end_op>
    return -1;
80106482:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106487:	eb 18                	jmp    801064a1 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80106489:	83 ec 0c             	sub    $0xc,%esp
8010648c:	ff 75 f4             	pushl  -0xc(%ebp)
8010648f:	e8 db b8 ff ff       	call   80101d6f <iunlockput>
80106494:	83 c4 10             	add    $0x10,%esp
  end_op();
80106497:	e8 f5 d2 ff ff       	call   80103791 <end_op>
  return 0;
8010649c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064a1:	c9                   	leave  
801064a2:	c3                   	ret    

801064a3 <sys_mknod>:

int
sys_mknod(void)
{
801064a3:	f3 0f 1e fb          	endbr32 
801064a7:	55                   	push   %ebp
801064a8:	89 e5                	mov    %esp,%ebp
801064aa:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801064ad:	e8 4f d2 ff ff       	call   80103701 <begin_op>
  if((argstr(0, &path)) < 0 ||
801064b2:	83 ec 08             	sub    $0x8,%esp
801064b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064b8:	50                   	push   %eax
801064b9:	6a 00                	push   $0x0
801064bb:	e8 a9 f4 ff ff       	call   80105969 <argstr>
801064c0:	83 c4 10             	add    $0x10,%esp
801064c3:	85 c0                	test   %eax,%eax
801064c5:	78 4f                	js     80106516 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
801064c7:	83 ec 08             	sub    $0x8,%esp
801064ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064cd:	50                   	push   %eax
801064ce:	6a 01                	push   $0x1
801064d0:	e8 f7 f3 ff ff       	call   801058cc <argint>
801064d5:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801064d8:	85 c0                	test   %eax,%eax
801064da:	78 3a                	js     80106516 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
801064dc:	83 ec 08             	sub    $0x8,%esp
801064df:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064e2:	50                   	push   %eax
801064e3:	6a 02                	push   $0x2
801064e5:	e8 e2 f3 ff ff       	call   801058cc <argint>
801064ea:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801064ed:	85 c0                	test   %eax,%eax
801064ef:	78 25                	js     80106516 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
801064f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064f4:	0f bf c8             	movswl %ax,%ecx
801064f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064fa:	0f bf d0             	movswl %ax,%edx
801064fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106500:	51                   	push   %ecx
80106501:	52                   	push   %edx
80106502:	6a 03                	push   $0x3
80106504:	50                   	push   %eax
80106505:	e8 bf fb ff ff       	call   801060c9 <create>
8010650a:	83 c4 10             	add    $0x10,%esp
8010650d:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80106510:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106514:	75 0c                	jne    80106522 <sys_mknod+0x7f>
    end_op();
80106516:	e8 76 d2 ff ff       	call   80103791 <end_op>
    return -1;
8010651b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106520:	eb 18                	jmp    8010653a <sys_mknod+0x97>
  }
  iunlockput(ip);
80106522:	83 ec 0c             	sub    $0xc,%esp
80106525:	ff 75 f4             	pushl  -0xc(%ebp)
80106528:	e8 42 b8 ff ff       	call   80101d6f <iunlockput>
8010652d:	83 c4 10             	add    $0x10,%esp
  end_op();
80106530:	e8 5c d2 ff ff       	call   80103791 <end_op>
  return 0;
80106535:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010653a:	c9                   	leave  
8010653b:	c3                   	ret    

8010653c <sys_chdir>:

int
sys_chdir(void)
{
8010653c:	f3 0f 1e fb          	endbr32 
80106540:	55                   	push   %ebp
80106541:	89 e5                	mov    %esp,%ebp
80106543:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106546:	e8 75 df ff ff       	call   801044c0 <myproc>
8010654b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010654e:	e8 ae d1 ff ff       	call   80103701 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106553:	83 ec 08             	sub    $0x8,%esp
80106556:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106559:	50                   	push   %eax
8010655a:	6a 00                	push   $0x0
8010655c:	e8 08 f4 ff ff       	call   80105969 <argstr>
80106561:	83 c4 10             	add    $0x10,%esp
80106564:	85 c0                	test   %eax,%eax
80106566:	78 18                	js     80106580 <sys_chdir+0x44>
80106568:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010656b:	83 ec 0c             	sub    $0xc,%esp
8010656e:	50                   	push   %eax
8010656f:	e8 29 c1 ff ff       	call   8010269d <namei>
80106574:	83 c4 10             	add    $0x10,%esp
80106577:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010657a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010657e:	75 0c                	jne    8010658c <sys_chdir+0x50>
    end_op();
80106580:	e8 0c d2 ff ff       	call   80103791 <end_op>
    return -1;
80106585:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010658a:	eb 68                	jmp    801065f4 <sys_chdir+0xb8>
  }
  ilock(ip);
8010658c:	83 ec 0c             	sub    $0xc,%esp
8010658f:	ff 75 f0             	pushl  -0x10(%ebp)
80106592:	e8 9b b5 ff ff       	call   80101b32 <ilock>
80106597:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010659a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010659d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801065a1:	66 83 f8 01          	cmp    $0x1,%ax
801065a5:	74 1a                	je     801065c1 <sys_chdir+0x85>
    iunlockput(ip);
801065a7:	83 ec 0c             	sub    $0xc,%esp
801065aa:	ff 75 f0             	pushl  -0x10(%ebp)
801065ad:	e8 bd b7 ff ff       	call   80101d6f <iunlockput>
801065b2:	83 c4 10             	add    $0x10,%esp
    end_op();
801065b5:	e8 d7 d1 ff ff       	call   80103791 <end_op>
    return -1;
801065ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065bf:	eb 33                	jmp    801065f4 <sys_chdir+0xb8>
  }
  iunlock(ip);
801065c1:	83 ec 0c             	sub    $0xc,%esp
801065c4:	ff 75 f0             	pushl  -0x10(%ebp)
801065c7:	e8 7d b6 ff ff       	call   80101c49 <iunlock>
801065cc:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801065cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d2:	8b 40 68             	mov    0x68(%eax),%eax
801065d5:	83 ec 0c             	sub    $0xc,%esp
801065d8:	50                   	push   %eax
801065d9:	e8 bd b6 ff ff       	call   80101c9b <iput>
801065de:	83 c4 10             	add    $0x10,%esp
  end_op();
801065e1:	e8 ab d1 ff ff       	call   80103791 <end_op>
  curproc->cwd = ip;
801065e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065ec:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801065ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065f4:	c9                   	leave  
801065f5:	c3                   	ret    

801065f6 <sys_exec>:

int
sys_exec(void)
{
801065f6:	f3 0f 1e fb          	endbr32 
801065fa:	55                   	push   %ebp
801065fb:	89 e5                	mov    %esp,%ebp
801065fd:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106603:	83 ec 08             	sub    $0x8,%esp
80106606:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106609:	50                   	push   %eax
8010660a:	6a 00                	push   $0x0
8010660c:	e8 58 f3 ff ff       	call   80105969 <argstr>
80106611:	83 c4 10             	add    $0x10,%esp
80106614:	85 c0                	test   %eax,%eax
80106616:	78 18                	js     80106630 <sys_exec+0x3a>
80106618:	83 ec 08             	sub    $0x8,%esp
8010661b:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106621:	50                   	push   %eax
80106622:	6a 01                	push   $0x1
80106624:	e8 a3 f2 ff ff       	call   801058cc <argint>
80106629:	83 c4 10             	add    $0x10,%esp
8010662c:	85 c0                	test   %eax,%eax
8010662e:	79 0a                	jns    8010663a <sys_exec+0x44>
    return -1;
80106630:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106635:	e9 c6 00 00 00       	jmp    80106700 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
8010663a:	83 ec 04             	sub    $0x4,%esp
8010663d:	68 80 00 00 00       	push   $0x80
80106642:	6a 00                	push   $0x0
80106644:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010664a:	50                   	push   %eax
8010664b:	e8 28 ef ff ff       	call   80105578 <memset>
80106650:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106653:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010665a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010665d:	83 f8 1f             	cmp    $0x1f,%eax
80106660:	76 0a                	jbe    8010666c <sys_exec+0x76>
      return -1;
80106662:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106667:	e9 94 00 00 00       	jmp    80106700 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010666c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010666f:	c1 e0 02             	shl    $0x2,%eax
80106672:	89 c2                	mov    %eax,%edx
80106674:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010667a:	01 c2                	add    %eax,%edx
8010667c:	83 ec 08             	sub    $0x8,%esp
8010667f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106685:	50                   	push   %eax
80106686:	52                   	push   %edx
80106687:	e8 95 f1 ff ff       	call   80105821 <fetchint>
8010668c:	83 c4 10             	add    $0x10,%esp
8010668f:	85 c0                	test   %eax,%eax
80106691:	79 07                	jns    8010669a <sys_exec+0xa4>
      return -1;
80106693:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106698:	eb 66                	jmp    80106700 <sys_exec+0x10a>
    if(uarg == 0){
8010669a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066a0:	85 c0                	test   %eax,%eax
801066a2:	75 27                	jne    801066cb <sys_exec+0xd5>
      argv[i] = 0;
801066a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a7:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801066ae:	00 00 00 00 
      break;
801066b2:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801066b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066b6:	83 ec 08             	sub    $0x8,%esp
801066b9:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801066bf:	52                   	push   %edx
801066c0:	50                   	push   %eax
801066c1:	e8 6a a5 ff ff       	call   80100c30 <exec>
801066c6:	83 c4 10             	add    $0x10,%esp
801066c9:	eb 35                	jmp    80106700 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801066cb:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066d4:	c1 e2 02             	shl    $0x2,%edx
801066d7:	01 c2                	add    %eax,%edx
801066d9:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066df:	83 ec 08             	sub    $0x8,%esp
801066e2:	52                   	push   %edx
801066e3:	50                   	push   %eax
801066e4:	e8 7b f1 ff ff       	call   80105864 <fetchstr>
801066e9:	83 c4 10             	add    $0x10,%esp
801066ec:	85 c0                	test   %eax,%eax
801066ee:	79 07                	jns    801066f7 <sys_exec+0x101>
      return -1;
801066f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f5:	eb 09                	jmp    80106700 <sys_exec+0x10a>
  for(i=0;; i++){
801066f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801066fb:	e9 5a ff ff ff       	jmp    8010665a <sys_exec+0x64>
}
80106700:	c9                   	leave  
80106701:	c3                   	ret    

80106702 <sys_pipe>:

int
sys_pipe(void)
{
80106702:	f3 0f 1e fb          	endbr32 
80106706:	55                   	push   %ebp
80106707:	89 e5                	mov    %esp,%ebp
80106709:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010670c:	83 ec 04             	sub    $0x4,%esp
8010670f:	6a 08                	push   $0x8
80106711:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106714:	50                   	push   %eax
80106715:	6a 00                	push   $0x0
80106717:	e8 e1 f1 ff ff       	call   801058fd <argptr>
8010671c:	83 c4 10             	add    $0x10,%esp
8010671f:	85 c0                	test   %eax,%eax
80106721:	79 0a                	jns    8010672d <sys_pipe+0x2b>
    return -1;
80106723:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106728:	e9 ae 00 00 00       	jmp    801067db <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
8010672d:	83 ec 08             	sub    $0x8,%esp
80106730:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106733:	50                   	push   %eax
80106734:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106737:	50                   	push   %eax
80106738:	e8 a4 d8 ff ff       	call   80103fe1 <pipealloc>
8010673d:	83 c4 10             	add    $0x10,%esp
80106740:	85 c0                	test   %eax,%eax
80106742:	79 0a                	jns    8010674e <sys_pipe+0x4c>
    return -1;
80106744:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106749:	e9 8d 00 00 00       	jmp    801067db <sys_pipe+0xd9>
  fd0 = -1;
8010674e:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106755:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106758:	83 ec 0c             	sub    $0xc,%esp
8010675b:	50                   	push   %eax
8010675c:	e8 3d f3 ff ff       	call   80105a9e <fdalloc>
80106761:	83 c4 10             	add    $0x10,%esp
80106764:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106767:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010676b:	78 18                	js     80106785 <sys_pipe+0x83>
8010676d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106770:	83 ec 0c             	sub    $0xc,%esp
80106773:	50                   	push   %eax
80106774:	e8 25 f3 ff ff       	call   80105a9e <fdalloc>
80106779:	83 c4 10             	add    $0x10,%esp
8010677c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010677f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106783:	79 3e                	jns    801067c3 <sys_pipe+0xc1>
    if(fd0 >= 0)
80106785:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106789:	78 13                	js     8010679e <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
8010678b:	e8 30 dd ff ff       	call   801044c0 <myproc>
80106790:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106793:	83 c2 08             	add    $0x8,%edx
80106796:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010679d:	00 
    fileclose(rf);
8010679e:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067a1:	83 ec 0c             	sub    $0xc,%esp
801067a4:	50                   	push   %eax
801067a5:	e8 08 aa ff ff       	call   801011b2 <fileclose>
801067aa:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801067ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067b0:	83 ec 0c             	sub    $0xc,%esp
801067b3:	50                   	push   %eax
801067b4:	e8 f9 a9 ff ff       	call   801011b2 <fileclose>
801067b9:	83 c4 10             	add    $0x10,%esp
    return -1;
801067bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067c1:	eb 18                	jmp    801067db <sys_pipe+0xd9>
  }
  fd[0] = fd0;
801067c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067c9:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801067cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067ce:	8d 50 04             	lea    0x4(%eax),%edx
801067d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067d4:	89 02                	mov    %eax,(%edx)
  return 0;
801067d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067db:	c9                   	leave  
801067dc:	c3                   	ret    

801067dd <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801067dd:	f3 0f 1e fb          	endbr32 
801067e1:	55                   	push   %ebp
801067e2:	89 e5                	mov    %esp,%ebp
801067e4:	83 ec 08             	sub    $0x8,%esp
  return fork();
801067e7:	e8 34 e0 ff ff       	call   80104820 <fork>
}
801067ec:	c9                   	leave  
801067ed:	c3                   	ret    

801067ee <sys_exit>:

int
sys_exit(void)
{
801067ee:	f3 0f 1e fb          	endbr32 
801067f2:	55                   	push   %ebp
801067f3:	89 e5                	mov    %esp,%ebp
801067f5:	83 ec 08             	sub    $0x8,%esp
  exit();
801067f8:	e8 fa e1 ff ff       	call   801049f7 <exit>
  return 0;  // not reached
801067fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106802:	c9                   	leave  
80106803:	c3                   	ret    

80106804 <sys_wait>:

int
sys_wait(void)
{
80106804:	f3 0f 1e fb          	endbr32 
80106808:	55                   	push   %ebp
80106809:	89 e5                	mov    %esp,%ebp
8010680b:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010680e:	e8 0b e3 ff ff       	call   80104b1e <wait>
}
80106813:	c9                   	leave  
80106814:	c3                   	ret    

80106815 <sys_kill>:

int
sys_kill(void)
{
80106815:	f3 0f 1e fb          	endbr32 
80106819:	55                   	push   %ebp
8010681a:	89 e5                	mov    %esp,%ebp
8010681c:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010681f:	83 ec 08             	sub    $0x8,%esp
80106822:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106825:	50                   	push   %eax
80106826:	6a 00                	push   $0x0
80106828:	e8 9f f0 ff ff       	call   801058cc <argint>
8010682d:	83 c4 10             	add    $0x10,%esp
80106830:	85 c0                	test   %eax,%eax
80106832:	79 07                	jns    8010683b <sys_kill+0x26>
    return -1;
80106834:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106839:	eb 0f                	jmp    8010684a <sys_kill+0x35>
  return kill(pid);
8010683b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010683e:	83 ec 0c             	sub    $0xc,%esp
80106841:	50                   	push   %eax
80106842:	e8 4d e7 ff ff       	call   80104f94 <kill>
80106847:	83 c4 10             	add    $0x10,%esp
}
8010684a:	c9                   	leave  
8010684b:	c3                   	ret    

8010684c <sys_getpid>:

int
sys_getpid(void)
{
8010684c:	f3 0f 1e fb          	endbr32 
80106850:	55                   	push   %ebp
80106851:	89 e5                	mov    %esp,%ebp
80106853:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106856:	e8 65 dc ff ff       	call   801044c0 <myproc>
8010685b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010685e:	c9                   	leave  
8010685f:	c3                   	ret    

80106860 <sys_sbrk>:

int
sys_sbrk(void)
{
80106860:	f3 0f 1e fb          	endbr32 
80106864:	55                   	push   %ebp
80106865:	89 e5                	mov    %esp,%ebp
80106867:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010686a:	83 ec 08             	sub    $0x8,%esp
8010686d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106870:	50                   	push   %eax
80106871:	6a 00                	push   $0x0
80106873:	e8 54 f0 ff ff       	call   801058cc <argint>
80106878:	83 c4 10             	add    $0x10,%esp
8010687b:	85 c0                	test   %eax,%eax
8010687d:	79 07                	jns    80106886 <sys_sbrk+0x26>
    return -1;
8010687f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106884:	eb 27                	jmp    801068ad <sys_sbrk+0x4d>
  addr = myproc()->sz;
80106886:	e8 35 dc ff ff       	call   801044c0 <myproc>
8010688b:	8b 00                	mov    (%eax),%eax
8010688d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106890:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106893:	83 ec 0c             	sub    $0xc,%esp
80106896:	50                   	push   %eax
80106897:	e8 c5 de ff ff       	call   80104761 <growproc>
8010689c:	83 c4 10             	add    $0x10,%esp
8010689f:	85 c0                	test   %eax,%eax
801068a1:	79 07                	jns    801068aa <sys_sbrk+0x4a>
    return -1;
801068a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068a8:	eb 03                	jmp    801068ad <sys_sbrk+0x4d>
  return addr;
801068aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068ad:	c9                   	leave  
801068ae:	c3                   	ret    

801068af <sys_sleep>:

int
sys_sleep(void)
{
801068af:	f3 0f 1e fb          	endbr32 
801068b3:	55                   	push   %ebp
801068b4:	89 e5                	mov    %esp,%ebp
801068b6:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801068b9:	83 ec 08             	sub    $0x8,%esp
801068bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068bf:	50                   	push   %eax
801068c0:	6a 00                	push   $0x0
801068c2:	e8 05 f0 ff ff       	call   801058cc <argint>
801068c7:	83 c4 10             	add    $0x10,%esp
801068ca:	85 c0                	test   %eax,%eax
801068cc:	79 07                	jns    801068d5 <sys_sleep+0x26>
    return -1;
801068ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068d3:	eb 76                	jmp    8010694b <sys_sleep+0x9c>
  acquire(&tickslock);
801068d5:	83 ec 0c             	sub    $0xc,%esp
801068d8:	68 00 80 11 80       	push   $0x80118000
801068dd:	e8 f7 e9 ff ff       	call   801052d9 <acquire>
801068e2:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801068e5:	a1 40 88 11 80       	mov    0x80118840,%eax
801068ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801068ed:	eb 38                	jmp    80106927 <sys_sleep+0x78>
    if(myproc()->killed){
801068ef:	e8 cc db ff ff       	call   801044c0 <myproc>
801068f4:	8b 40 24             	mov    0x24(%eax),%eax
801068f7:	85 c0                	test   %eax,%eax
801068f9:	74 17                	je     80106912 <sys_sleep+0x63>
      release(&tickslock);
801068fb:	83 ec 0c             	sub    $0xc,%esp
801068fe:	68 00 80 11 80       	push   $0x80118000
80106903:	e8 43 ea ff ff       	call   8010534b <release>
80106908:	83 c4 10             	add    $0x10,%esp
      return -1;
8010690b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106910:	eb 39                	jmp    8010694b <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106912:	83 ec 08             	sub    $0x8,%esp
80106915:	68 00 80 11 80       	push   $0x80118000
8010691a:	68 40 88 11 80       	push   $0x80118840
8010691f:	e8 43 e5 ff ff       	call   80104e67 <sleep>
80106924:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106927:	a1 40 88 11 80       	mov    0x80118840,%eax
8010692c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010692f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106932:	39 d0                	cmp    %edx,%eax
80106934:	72 b9                	jb     801068ef <sys_sleep+0x40>
  }
  release(&tickslock);
80106936:	83 ec 0c             	sub    $0xc,%esp
80106939:	68 00 80 11 80       	push   $0x80118000
8010693e:	e8 08 ea ff ff       	call   8010534b <release>
80106943:	83 c4 10             	add    $0x10,%esp
  return 0;
80106946:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010694b:	c9                   	leave  
8010694c:	c3                   	ret    

8010694d <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010694d:	f3 0f 1e fb          	endbr32 
80106951:	55                   	push   %ebp
80106952:	89 e5                	mov    %esp,%ebp
80106954:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106957:	83 ec 0c             	sub    $0xc,%esp
8010695a:	68 00 80 11 80       	push   $0x80118000
8010695f:	e8 75 e9 ff ff       	call   801052d9 <acquire>
80106964:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106967:	a1 40 88 11 80       	mov    0x80118840,%eax
8010696c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010696f:	83 ec 0c             	sub    $0xc,%esp
80106972:	68 00 80 11 80       	push   $0x80118000
80106977:	e8 cf e9 ff ff       	call   8010534b <release>
8010697c:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010697f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106982:	c9                   	leave  
80106983:	c3                   	ret    

80106984 <sys_mencrypt>:

//changed: added wrapper here
int sys_mencrypt(void) {
80106984:	f3 0f 1e fb          	endbr32 
80106988:	55                   	push   %ebp
80106989:	89 e5                	mov    %esp,%ebp
8010698b:	83 ec 18             	sub    $0x18,%esp
  char * virtual_addr;

  //TODO: what to do if len is 0?

  //dummy size because we're dealing with actual pages here
  if(argint(1, &len) < 0)
8010698e:	83 ec 08             	sub    $0x8,%esp
80106991:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106994:	50                   	push   %eax
80106995:	6a 01                	push   $0x1
80106997:	e8 30 ef ff ff       	call   801058cc <argint>
8010699c:	83 c4 10             	add    $0x10,%esp
8010699f:	85 c0                	test   %eax,%eax
801069a1:	79 07                	jns    801069aa <sys_mencrypt+0x26>
    return -1;
801069a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069a8:	eb 5e                	jmp    80106a08 <sys_mencrypt+0x84>
  if (len == 0) {
801069aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ad:	85 c0                	test   %eax,%eax
801069af:	75 07                	jne    801069b8 <sys_mencrypt+0x34>
    return 0;
801069b1:	b8 00 00 00 00       	mov    $0x0,%eax
801069b6:	eb 50                	jmp    80106a08 <sys_mencrypt+0x84>
  }
  if (len < 0) {
801069b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069bb:	85 c0                	test   %eax,%eax
801069bd:	79 07                	jns    801069c6 <sys_mencrypt+0x42>
    return -1;
801069bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069c4:	eb 42                	jmp    80106a08 <sys_mencrypt+0x84>
  }
  if (argptr(0, &virtual_addr, 1) < 0) {
801069c6:	83 ec 04             	sub    $0x4,%esp
801069c9:	6a 01                	push   $0x1
801069cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069ce:	50                   	push   %eax
801069cf:	6a 00                	push   $0x0
801069d1:	e8 27 ef ff ff       	call   801058fd <argptr>
801069d6:	83 c4 10             	add    $0x10,%esp
801069d9:	85 c0                	test   %eax,%eax
801069db:	79 07                	jns    801069e4 <sys_mencrypt+0x60>
    return -1;
801069dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069e2:	eb 24                	jmp    80106a08 <sys_mencrypt+0x84>
  }

  //geq or ge?
  if ((void *) virtual_addr >= (void *)KERNBASE) {
801069e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069e7:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
801069ec:	76 07                	jbe    801069f5 <sys_mencrypt+0x71>
    return -1;
801069ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069f3:	eb 13                	jmp    80106a08 <sys_mencrypt+0x84>
  }
  //virtual_addr = (char *)5000;
  return mencrypt((char*)virtual_addr, len);
801069f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069fb:	83 ec 08             	sub    $0x8,%esp
801069fe:	52                   	push   %edx
801069ff:	50                   	push   %eax
80106a00:	e8 54 25 00 00       	call   80108f59 <mencrypt>
80106a05:	83 c4 10             	add    $0x10,%esp
}
80106a08:	c9                   	leave  
80106a09:	c3                   	ret    

80106a0a <sys_getpgtable>:

//changed: added wrapper here
int sys_getpgtable(void) {
80106a0a:	f3 0f 1e fb          	endbr32 
80106a0e:	55                   	push   %ebp
80106a0f:	89 e5                	mov    %esp,%ebp
80106a11:	83 ec 18             	sub    $0x18,%esp
  struct pt_entry * entries; 
  int num;
  int wsetOnly;

  if(argint(1, &num) < 0)
80106a14:	83 ec 08             	sub    $0x8,%esp
80106a17:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a1a:	50                   	push   %eax
80106a1b:	6a 01                	push   $0x1
80106a1d:	e8 aa ee ff ff       	call   801058cc <argint>
80106a22:	83 c4 10             	add    $0x10,%esp
80106a25:	85 c0                	test   %eax,%eax
80106a27:	79 07                	jns    80106a30 <sys_getpgtable+0x26>

    return -1;
80106a29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a2e:	eb 56                	jmp    80106a86 <sys_getpgtable+0x7c>


  if(argptr(0, (char**)&entries, num*sizeof(struct pt_entry)) < 0){
80106a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a33:	c1 e0 03             	shl    $0x3,%eax
80106a36:	83 ec 04             	sub    $0x4,%esp
80106a39:	50                   	push   %eax
80106a3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a3d:	50                   	push   %eax
80106a3e:	6a 00                	push   $0x0
80106a40:	e8 b8 ee ff ff       	call   801058fd <argptr>
80106a45:	83 c4 10             	add    $0x10,%esp
80106a48:	85 c0                	test   %eax,%eax
80106a4a:	79 07                	jns    80106a53 <sys_getpgtable+0x49>
    return -1;
80106a4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a51:	eb 33                	jmp    80106a86 <sys_getpgtable+0x7c>
  }
  if(argint(2, &wsetOnly) < 0) {
80106a53:	83 ec 08             	sub    $0x8,%esp
80106a56:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a59:	50                   	push   %eax
80106a5a:	6a 02                	push   $0x2
80106a5c:	e8 6b ee ff ff       	call   801058cc <argint>
80106a61:	83 c4 10             	add    $0x10,%esp
80106a64:	85 c0                	test   %eax,%eax
80106a66:	79 07                	jns    80106a6f <sys_getpgtable+0x65>
    return -1;
80106a68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a6d:	eb 17                	jmp    80106a86 <sys_getpgtable+0x7c>
  }
  return getpgtable(entries, num, wsetOnly);
80106a6f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106a72:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a78:	83 ec 04             	sub    $0x4,%esp
80106a7b:	51                   	push   %ecx
80106a7c:	52                   	push   %edx
80106a7d:	50                   	push   %eax
80106a7e:	e8 0f 26 00 00       	call   80109092 <getpgtable>
80106a83:	83 c4 10             	add    $0x10,%esp
}
80106a86:	c9                   	leave  
80106a87:	c3                   	ret    

80106a88 <sys_dump_rawphymem>:

//changed: added wrapper here
int sys_dump_rawphymem(void) {
80106a88:	f3 0f 1e fb          	endbr32 
80106a8c:	55                   	push   %ebp
80106a8d:	89 e5                	mov    %esp,%ebp
80106a8f:	83 ec 18             	sub    $0x18,%esp
  uint physical_addr; 
  char * buffer;

  if(argptr(1, &buffer, PGSIZE) < 0)
80106a92:	83 ec 04             	sub    $0x4,%esp
80106a95:	68 00 10 00 00       	push   $0x1000
80106a9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a9d:	50                   	push   %eax
80106a9e:	6a 01                	push   $0x1
80106aa0:	e8 58 ee ff ff       	call   801058fd <argptr>
80106aa5:	83 c4 10             	add    $0x10,%esp
80106aa8:	85 c0                	test   %eax,%eax
80106aaa:	79 07                	jns    80106ab3 <sys_dump_rawphymem+0x2b>
    return -1;
80106aac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ab1:	eb 2f                	jmp    80106ae2 <sys_dump_rawphymem+0x5a>

  //dummy size because we're dealing with actual pages here
  if(argint(0, (int*)&physical_addr) < 0)
80106ab3:	83 ec 08             	sub    $0x8,%esp
80106ab6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ab9:	50                   	push   %eax
80106aba:	6a 00                	push   $0x0
80106abc:	e8 0b ee ff ff       	call   801058cc <argint>
80106ac1:	83 c4 10             	add    $0x10,%esp
80106ac4:	85 c0                	test   %eax,%eax
80106ac6:	79 07                	jns    80106acf <sys_dump_rawphymem+0x47>
    return -1;
80106ac8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106acd:	eb 13                	jmp    80106ae2 <sys_dump_rawphymem+0x5a>

  return dump_rawphymem(physical_addr, buffer);
80106acf:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ad5:	83 ec 08             	sub    $0x8,%esp
80106ad8:	52                   	push   %edx
80106ad9:	50                   	push   %eax
80106ada:	e8 f5 27 00 00       	call   801092d4 <dump_rawphymem>
80106adf:	83 c4 10             	add    $0x10,%esp
}
80106ae2:	c9                   	leave  
80106ae3:	c3                   	ret    

80106ae4 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106ae4:	1e                   	push   %ds
  pushl %es
80106ae5:	06                   	push   %es
  pushl %fs
80106ae6:	0f a0                	push   %fs
  pushl %gs
80106ae8:	0f a8                	push   %gs
  pushal
80106aea:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106aeb:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106aef:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106af1:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106af3:	54                   	push   %esp
  call trap
80106af4:	e8 df 01 00 00       	call   80106cd8 <trap>
  addl $4, %esp
80106af9:	83 c4 04             	add    $0x4,%esp

80106afc <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106afc:	61                   	popa   
  popl %gs
80106afd:	0f a9                	pop    %gs
  popl %fs
80106aff:	0f a1                	pop    %fs
  popl %es
80106b01:	07                   	pop    %es
  popl %ds
80106b02:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106b03:	83 c4 08             	add    $0x8,%esp
  iret
80106b06:	cf                   	iret   

80106b07 <lidt>:
{
80106b07:	55                   	push   %ebp
80106b08:	89 e5                	mov    %esp,%ebp
80106b0a:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b10:	83 e8 01             	sub    $0x1,%eax
80106b13:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106b17:	8b 45 08             	mov    0x8(%ebp),%eax
80106b1a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80106b21:	c1 e8 10             	shr    $0x10,%eax
80106b24:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106b28:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106b2b:	0f 01 18             	lidtl  (%eax)
}
80106b2e:	90                   	nop
80106b2f:	c9                   	leave  
80106b30:	c3                   	ret    

80106b31 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106b31:	55                   	push   %ebp
80106b32:	89 e5                	mov    %esp,%ebp
80106b34:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106b37:	0f 20 d0             	mov    %cr2,%eax
80106b3a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106b3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106b40:	c9                   	leave  
80106b41:	c3                   	ret    

80106b42 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106b42:	f3 0f 1e fb          	endbr32 
80106b46:	55                   	push   %ebp
80106b47:	89 e5                	mov    %esp,%ebp
80106b49:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b53:	e9 c3 00 00 00       	jmp    80106c1b <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b5b:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106b62:	89 c2                	mov    %eax,%edx
80106b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b67:	66 89 14 c5 40 80 11 	mov    %dx,-0x7fee7fc0(,%eax,8)
80106b6e:	80 
80106b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b72:	66 c7 04 c5 42 80 11 	movw   $0x8,-0x7fee7fbe(,%eax,8)
80106b79:	80 08 00 
80106b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b7f:	0f b6 14 c5 44 80 11 	movzbl -0x7fee7fbc(,%eax,8),%edx
80106b86:	80 
80106b87:	83 e2 e0             	and    $0xffffffe0,%edx
80106b8a:	88 14 c5 44 80 11 80 	mov    %dl,-0x7fee7fbc(,%eax,8)
80106b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b94:	0f b6 14 c5 44 80 11 	movzbl -0x7fee7fbc(,%eax,8),%edx
80106b9b:	80 
80106b9c:	83 e2 1f             	and    $0x1f,%edx
80106b9f:	88 14 c5 44 80 11 80 	mov    %dl,-0x7fee7fbc(,%eax,8)
80106ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba9:	0f b6 14 c5 45 80 11 	movzbl -0x7fee7fbb(,%eax,8),%edx
80106bb0:	80 
80106bb1:	83 e2 f0             	and    $0xfffffff0,%edx
80106bb4:	83 ca 0e             	or     $0xe,%edx
80106bb7:	88 14 c5 45 80 11 80 	mov    %dl,-0x7fee7fbb(,%eax,8)
80106bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc1:	0f b6 14 c5 45 80 11 	movzbl -0x7fee7fbb(,%eax,8),%edx
80106bc8:	80 
80106bc9:	83 e2 ef             	and    $0xffffffef,%edx
80106bcc:	88 14 c5 45 80 11 80 	mov    %dl,-0x7fee7fbb(,%eax,8)
80106bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bd6:	0f b6 14 c5 45 80 11 	movzbl -0x7fee7fbb(,%eax,8),%edx
80106bdd:	80 
80106bde:	83 e2 9f             	and    $0xffffff9f,%edx
80106be1:	88 14 c5 45 80 11 80 	mov    %dl,-0x7fee7fbb(,%eax,8)
80106be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106beb:	0f b6 14 c5 45 80 11 	movzbl -0x7fee7fbb(,%eax,8),%edx
80106bf2:	80 
80106bf3:	83 ca 80             	or     $0xffffff80,%edx
80106bf6:	88 14 c5 45 80 11 80 	mov    %dl,-0x7fee7fbb(,%eax,8)
80106bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c00:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106c07:	c1 e8 10             	shr    $0x10,%eax
80106c0a:	89 c2                	mov    %eax,%edx
80106c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c0f:	66 89 14 c5 46 80 11 	mov    %dx,-0x7fee7fba(,%eax,8)
80106c16:	80 
  for(i = 0; i < 256; i++)
80106c17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c1b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106c22:	0f 8e 30 ff ff ff    	jle    80106b58 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106c28:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106c2d:	66 a3 40 82 11 80    	mov    %ax,0x80118240
80106c33:	66 c7 05 42 82 11 80 	movw   $0x8,0x80118242
80106c3a:	08 00 
80106c3c:	0f b6 05 44 82 11 80 	movzbl 0x80118244,%eax
80106c43:	83 e0 e0             	and    $0xffffffe0,%eax
80106c46:	a2 44 82 11 80       	mov    %al,0x80118244
80106c4b:	0f b6 05 44 82 11 80 	movzbl 0x80118244,%eax
80106c52:	83 e0 1f             	and    $0x1f,%eax
80106c55:	a2 44 82 11 80       	mov    %al,0x80118244
80106c5a:	0f b6 05 45 82 11 80 	movzbl 0x80118245,%eax
80106c61:	83 c8 0f             	or     $0xf,%eax
80106c64:	a2 45 82 11 80       	mov    %al,0x80118245
80106c69:	0f b6 05 45 82 11 80 	movzbl 0x80118245,%eax
80106c70:	83 e0 ef             	and    $0xffffffef,%eax
80106c73:	a2 45 82 11 80       	mov    %al,0x80118245
80106c78:	0f b6 05 45 82 11 80 	movzbl 0x80118245,%eax
80106c7f:	83 c8 60             	or     $0x60,%eax
80106c82:	a2 45 82 11 80       	mov    %al,0x80118245
80106c87:	0f b6 05 45 82 11 80 	movzbl 0x80118245,%eax
80106c8e:	83 c8 80             	or     $0xffffff80,%eax
80106c91:	a2 45 82 11 80       	mov    %al,0x80118245
80106c96:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106c9b:	c1 e8 10             	shr    $0x10,%eax
80106c9e:	66 a3 46 82 11 80    	mov    %ax,0x80118246

  initlock(&tickslock, "time");
80106ca4:	83 ec 08             	sub    $0x8,%esp
80106ca7:	68 70 98 10 80       	push   $0x80109870
80106cac:	68 00 80 11 80       	push   $0x80118000
80106cb1:	e8 fd e5 ff ff       	call   801052b3 <initlock>
80106cb6:	83 c4 10             	add    $0x10,%esp
}
80106cb9:	90                   	nop
80106cba:	c9                   	leave  
80106cbb:	c3                   	ret    

80106cbc <idtinit>:

void
idtinit(void)
{
80106cbc:	f3 0f 1e fb          	endbr32 
80106cc0:	55                   	push   %ebp
80106cc1:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106cc3:	68 00 08 00 00       	push   $0x800
80106cc8:	68 40 80 11 80       	push   $0x80118040
80106ccd:	e8 35 fe ff ff       	call   80106b07 <lidt>
80106cd2:	83 c4 08             	add    $0x8,%esp
}
80106cd5:	90                   	nop
80106cd6:	c9                   	leave  
80106cd7:	c3                   	ret    

80106cd8 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106cd8:	f3 0f 1e fb          	endbr32 
80106cdc:	55                   	push   %ebp
80106cdd:	89 e5                	mov    %esp,%ebp
80106cdf:	57                   	push   %edi
80106ce0:	56                   	push   %esi
80106ce1:	53                   	push   %ebx
80106ce2:	83 ec 2c             	sub    $0x2c,%esp
  //cprintf("in trap\n");
  if(tf->trapno == T_SYSCALL){
80106ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce8:	8b 40 30             	mov    0x30(%eax),%eax
80106ceb:	83 f8 40             	cmp    $0x40,%eax
80106cee:	75 3b                	jne    80106d2b <trap+0x53>
    if(myproc()->killed)
80106cf0:	e8 cb d7 ff ff       	call   801044c0 <myproc>
80106cf5:	8b 40 24             	mov    0x24(%eax),%eax
80106cf8:	85 c0                	test   %eax,%eax
80106cfa:	74 05                	je     80106d01 <trap+0x29>
      exit();
80106cfc:	e8 f6 dc ff ff       	call   801049f7 <exit>
    myproc()->tf = tf;
80106d01:	e8 ba d7 ff ff       	call   801044c0 <myproc>
80106d06:	8b 55 08             	mov    0x8(%ebp),%edx
80106d09:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106d0c:	e8 93 ec ff ff       	call   801059a4 <syscall>
    if(myproc()->killed)
80106d11:	e8 aa d7 ff ff       	call   801044c0 <myproc>
80106d16:	8b 40 24             	mov    0x24(%eax),%eax
80106d19:	85 c0                	test   %eax,%eax
80106d1b:	0f 84 41 02 00 00    	je     80106f62 <trap+0x28a>
      exit();
80106d21:	e8 d1 dc ff ff       	call   801049f7 <exit>
    return;
80106d26:	e9 37 02 00 00       	jmp    80106f62 <trap+0x28a>
  }
  char *addr;
  switch(tf->trapno){
80106d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80106d2e:	8b 40 30             	mov    0x30(%eax),%eax
80106d31:	83 e8 0e             	sub    $0xe,%eax
80106d34:	83 f8 31             	cmp    $0x31,%eax
80106d37:	0f 87 ed 00 00 00    	ja     80106e2a <trap+0x152>
80106d3d:	8b 04 85 28 99 10 80 	mov    -0x7fef66d8(,%eax,4),%eax
80106d44:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106d47:	e8 d9 d6 ff ff       	call   80104425 <cpuid>
80106d4c:	85 c0                	test   %eax,%eax
80106d4e:	75 3d                	jne    80106d8d <trap+0xb5>
      acquire(&tickslock);
80106d50:	83 ec 0c             	sub    $0xc,%esp
80106d53:	68 00 80 11 80       	push   $0x80118000
80106d58:	e8 7c e5 ff ff       	call   801052d9 <acquire>
80106d5d:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106d60:	a1 40 88 11 80       	mov    0x80118840,%eax
80106d65:	83 c0 01             	add    $0x1,%eax
80106d68:	a3 40 88 11 80       	mov    %eax,0x80118840
      wakeup(&ticks);
80106d6d:	83 ec 0c             	sub    $0xc,%esp
80106d70:	68 40 88 11 80       	push   $0x80118840
80106d75:	e8 df e1 ff ff       	call   80104f59 <wakeup>
80106d7a:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106d7d:	83 ec 0c             	sub    $0xc,%esp
80106d80:	68 00 80 11 80       	push   $0x80118000
80106d85:	e8 c1 e5 ff ff       	call   8010534b <release>
80106d8a:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106d8d:	e8 23 c4 ff ff       	call   801031b5 <lapiceoi>
    break;
80106d92:	e9 4b 01 00 00       	jmp    80106ee2 <trap+0x20a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106d97:	e8 4e bc ff ff       	call   801029ea <ideintr>
    lapiceoi();
80106d9c:	e8 14 c4 ff ff       	call   801031b5 <lapiceoi>
    break;
80106da1:	e9 3c 01 00 00       	jmp    80106ee2 <trap+0x20a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106da6:	e8 40 c2 ff ff       	call   80102feb <kbdintr>
    lapiceoi();
80106dab:	e8 05 c4 ff ff       	call   801031b5 <lapiceoi>
    break;
80106db0:	e9 2d 01 00 00       	jmp    80106ee2 <trap+0x20a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106db5:	e8 8a 03 00 00       	call   80107144 <uartintr>
    lapiceoi();
80106dba:	e8 f6 c3 ff ff       	call   801031b5 <lapiceoi>
    break;
80106dbf:	e9 1e 01 00 00       	jmp    80106ee2 <trap+0x20a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106dc4:	8b 45 08             	mov    0x8(%ebp),%eax
80106dc7:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106dca:	8b 45 08             	mov    0x8(%ebp),%eax
80106dcd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106dd1:	0f b7 d8             	movzwl %ax,%ebx
80106dd4:	e8 4c d6 ff ff       	call   80104425 <cpuid>
80106dd9:	56                   	push   %esi
80106dda:	53                   	push   %ebx
80106ddb:	50                   	push   %eax
80106ddc:	68 78 98 10 80       	push   $0x80109878
80106de1:	e8 32 96 ff ff       	call   80100418 <cprintf>
80106de6:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106de9:	e8 c7 c3 ff ff       	call   801031b5 <lapiceoi>
    break;
80106dee:	e9 ef 00 00 00       	jmp    80106ee2 <trap+0x20a>
  case T_PGFLT:
    //get the virtual address that caused the fault
    addr = (char*)rcr2();
80106df3:	e8 39 fd ff ff       	call   80106b31 <rcr2>
80106df8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    cprintf("the addr is %p\n",(char *)PGROUNDDOWN((uint)addr))
80106dfb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106dfe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106e03:	83 ec 08             	sub    $0x8,%esp
80106e06:	50                   	push   %eax
80106e07:	68 9c 98 10 80       	push   $0x8010989c
80106e0c:	e8 07 96 ff ff       	call   80100418 <cprintf>
80106e11:	83 c4 10             	add    $0x10,%esp
    ;
    if (!mdecrypt(addr)) {
80106e14:	83 ec 0c             	sub    $0xc,%esp
80106e17:	ff 75 e4             	pushl  -0x1c(%ebp)
80106e1a:	e8 77 20 00 00       	call   80108e96 <mdecrypt>
80106e1f:	83 c4 10             	add    $0x10,%esp
80106e22:	85 c0                	test   %eax,%eax
80106e24:	0f 84 b7 00 00 00    	je     80106ee1 <trap+0x209>
      //default kills the process
      break;
    };
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106e2a:	e8 91 d6 ff ff       	call   801044c0 <myproc>
80106e2f:	85 c0                	test   %eax,%eax
80106e31:	74 11                	je     80106e44 <trap+0x16c>
80106e33:	8b 45 08             	mov    0x8(%ebp),%eax
80106e36:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e3a:	0f b7 c0             	movzwl %ax,%eax
80106e3d:	83 e0 03             	and    $0x3,%eax
80106e40:	85 c0                	test   %eax,%eax
80106e42:	75 39                	jne    80106e7d <trap+0x1a5>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e44:	e8 e8 fc ff ff       	call   80106b31 <rcr2>
80106e49:	89 c3                	mov    %eax,%ebx
80106e4b:	8b 45 08             	mov    0x8(%ebp),%eax
80106e4e:	8b 70 38             	mov    0x38(%eax),%esi
80106e51:	e8 cf d5 ff ff       	call   80104425 <cpuid>
80106e56:	8b 55 08             	mov    0x8(%ebp),%edx
80106e59:	8b 52 30             	mov    0x30(%edx),%edx
80106e5c:	83 ec 0c             	sub    $0xc,%esp
80106e5f:	53                   	push   %ebx
80106e60:	56                   	push   %esi
80106e61:	50                   	push   %eax
80106e62:	52                   	push   %edx
80106e63:	68 ac 98 10 80       	push   $0x801098ac
80106e68:	e8 ab 95 ff ff       	call   80100418 <cprintf>
80106e6d:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106e70:	83 ec 0c             	sub    $0xc,%esp
80106e73:	68 de 98 10 80       	push   $0x801098de
80106e78:	e8 8b 97 ff ff       	call   80100608 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e7d:	e8 af fc ff ff       	call   80106b31 <rcr2>
80106e82:	89 c6                	mov    %eax,%esi
80106e84:	8b 45 08             	mov    0x8(%ebp),%eax
80106e87:	8b 40 38             	mov    0x38(%eax),%eax
80106e8a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106e8d:	e8 93 d5 ff ff       	call   80104425 <cpuid>
80106e92:	89 c3                	mov    %eax,%ebx
80106e94:	8b 45 08             	mov    0x8(%ebp),%eax
80106e97:	8b 48 34             	mov    0x34(%eax),%ecx
80106e9a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106e9d:	8b 45 08             	mov    0x8(%ebp),%eax
80106ea0:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106ea3:	e8 18 d6 ff ff       	call   801044c0 <myproc>
80106ea8:	8d 50 6c             	lea    0x6c(%eax),%edx
80106eab:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106eae:	e8 0d d6 ff ff       	call   801044c0 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106eb3:	8b 40 10             	mov    0x10(%eax),%eax
80106eb6:	56                   	push   %esi
80106eb7:	ff 75 d4             	pushl  -0x2c(%ebp)
80106eba:	53                   	push   %ebx
80106ebb:	ff 75 d0             	pushl  -0x30(%ebp)
80106ebe:	57                   	push   %edi
80106ebf:	ff 75 cc             	pushl  -0x34(%ebp)
80106ec2:	50                   	push   %eax
80106ec3:	68 e4 98 10 80       	push   $0x801098e4
80106ec8:	e8 4b 95 ff ff       	call   80100418 <cprintf>
80106ecd:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106ed0:	e8 eb d5 ff ff       	call   801044c0 <myproc>
80106ed5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106edc:	eb 04                	jmp    80106ee2 <trap+0x20a>
    break;
80106ede:	90                   	nop
80106edf:	eb 01                	jmp    80106ee2 <trap+0x20a>
      break;
80106ee1:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106ee2:	e8 d9 d5 ff ff       	call   801044c0 <myproc>
80106ee7:	85 c0                	test   %eax,%eax
80106ee9:	74 23                	je     80106f0e <trap+0x236>
80106eeb:	e8 d0 d5 ff ff       	call   801044c0 <myproc>
80106ef0:	8b 40 24             	mov    0x24(%eax),%eax
80106ef3:	85 c0                	test   %eax,%eax
80106ef5:	74 17                	je     80106f0e <trap+0x236>
80106ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80106efa:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106efe:	0f b7 c0             	movzwl %ax,%eax
80106f01:	83 e0 03             	and    $0x3,%eax
80106f04:	83 f8 03             	cmp    $0x3,%eax
80106f07:	75 05                	jne    80106f0e <trap+0x236>
    exit();
80106f09:	e8 e9 da ff ff       	call   801049f7 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106f0e:	e8 ad d5 ff ff       	call   801044c0 <myproc>
80106f13:	85 c0                	test   %eax,%eax
80106f15:	74 1d                	je     80106f34 <trap+0x25c>
80106f17:	e8 a4 d5 ff ff       	call   801044c0 <myproc>
80106f1c:	8b 40 0c             	mov    0xc(%eax),%eax
80106f1f:	83 f8 04             	cmp    $0x4,%eax
80106f22:	75 10                	jne    80106f34 <trap+0x25c>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106f24:	8b 45 08             	mov    0x8(%ebp),%eax
80106f27:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106f2a:	83 f8 20             	cmp    $0x20,%eax
80106f2d:	75 05                	jne    80106f34 <trap+0x25c>
    yield();
80106f2f:	e8 ab de ff ff       	call   80104ddf <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f34:	e8 87 d5 ff ff       	call   801044c0 <myproc>
80106f39:	85 c0                	test   %eax,%eax
80106f3b:	74 26                	je     80106f63 <trap+0x28b>
80106f3d:	e8 7e d5 ff ff       	call   801044c0 <myproc>
80106f42:	8b 40 24             	mov    0x24(%eax),%eax
80106f45:	85 c0                	test   %eax,%eax
80106f47:	74 1a                	je     80106f63 <trap+0x28b>
80106f49:	8b 45 08             	mov    0x8(%ebp),%eax
80106f4c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f50:	0f b7 c0             	movzwl %ax,%eax
80106f53:	83 e0 03             	and    $0x3,%eax
80106f56:	83 f8 03             	cmp    $0x3,%eax
80106f59:	75 08                	jne    80106f63 <trap+0x28b>
    exit();
80106f5b:	e8 97 da ff ff       	call   801049f7 <exit>
80106f60:	eb 01                	jmp    80106f63 <trap+0x28b>
    return;
80106f62:	90                   	nop
}
80106f63:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f66:	5b                   	pop    %ebx
80106f67:	5e                   	pop    %esi
80106f68:	5f                   	pop    %edi
80106f69:	5d                   	pop    %ebp
80106f6a:	c3                   	ret    

80106f6b <inb>:
{
80106f6b:	55                   	push   %ebp
80106f6c:	89 e5                	mov    %esp,%ebp
80106f6e:	83 ec 14             	sub    $0x14,%esp
80106f71:	8b 45 08             	mov    0x8(%ebp),%eax
80106f74:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f78:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106f7c:	89 c2                	mov    %eax,%edx
80106f7e:	ec                   	in     (%dx),%al
80106f7f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f82:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106f86:	c9                   	leave  
80106f87:	c3                   	ret    

80106f88 <outb>:
{
80106f88:	55                   	push   %ebp
80106f89:	89 e5                	mov    %esp,%ebp
80106f8b:	83 ec 08             	sub    $0x8,%esp
80106f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80106f91:	8b 55 0c             	mov    0xc(%ebp),%edx
80106f94:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106f98:	89 d0                	mov    %edx,%eax
80106f9a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106f9d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106fa1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106fa5:	ee                   	out    %al,(%dx)
}
80106fa6:	90                   	nop
80106fa7:	c9                   	leave  
80106fa8:	c3                   	ret    

80106fa9 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106fa9:	f3 0f 1e fb          	endbr32 
80106fad:	55                   	push   %ebp
80106fae:	89 e5                	mov    %esp,%ebp
80106fb0:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106fb3:	6a 00                	push   $0x0
80106fb5:	68 fa 03 00 00       	push   $0x3fa
80106fba:	e8 c9 ff ff ff       	call   80106f88 <outb>
80106fbf:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106fc2:	68 80 00 00 00       	push   $0x80
80106fc7:	68 fb 03 00 00       	push   $0x3fb
80106fcc:	e8 b7 ff ff ff       	call   80106f88 <outb>
80106fd1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106fd4:	6a 0c                	push   $0xc
80106fd6:	68 f8 03 00 00       	push   $0x3f8
80106fdb:	e8 a8 ff ff ff       	call   80106f88 <outb>
80106fe0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106fe3:	6a 00                	push   $0x0
80106fe5:	68 f9 03 00 00       	push   $0x3f9
80106fea:	e8 99 ff ff ff       	call   80106f88 <outb>
80106fef:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106ff2:	6a 03                	push   $0x3
80106ff4:	68 fb 03 00 00       	push   $0x3fb
80106ff9:	e8 8a ff ff ff       	call   80106f88 <outb>
80106ffe:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107001:	6a 00                	push   $0x0
80107003:	68 fc 03 00 00       	push   $0x3fc
80107008:	e8 7b ff ff ff       	call   80106f88 <outb>
8010700d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107010:	6a 01                	push   $0x1
80107012:	68 f9 03 00 00       	push   $0x3f9
80107017:	e8 6c ff ff ff       	call   80106f88 <outb>
8010701c:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010701f:	68 fd 03 00 00       	push   $0x3fd
80107024:	e8 42 ff ff ff       	call   80106f6b <inb>
80107029:	83 c4 04             	add    $0x4,%esp
8010702c:	3c ff                	cmp    $0xff,%al
8010702e:	74 61                	je     80107091 <uartinit+0xe8>
    return;
  uart = 1;
80107030:	c7 05 44 c6 10 80 01 	movl   $0x1,0x8010c644
80107037:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010703a:	68 fa 03 00 00       	push   $0x3fa
8010703f:	e8 27 ff ff ff       	call   80106f6b <inb>
80107044:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107047:	68 f8 03 00 00       	push   $0x3f8
8010704c:	e8 1a ff ff ff       	call   80106f6b <inb>
80107051:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80107054:	83 ec 08             	sub    $0x8,%esp
80107057:	6a 00                	push   $0x0
80107059:	6a 04                	push   $0x4
8010705b:	e8 3c bc ff ff       	call   80102c9c <ioapicenable>
80107060:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107063:	c7 45 f4 f0 99 10 80 	movl   $0x801099f0,-0xc(%ebp)
8010706a:	eb 19                	jmp    80107085 <uartinit+0xdc>
    uartputc(*p);
8010706c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010706f:	0f b6 00             	movzbl (%eax),%eax
80107072:	0f be c0             	movsbl %al,%eax
80107075:	83 ec 0c             	sub    $0xc,%esp
80107078:	50                   	push   %eax
80107079:	e8 16 00 00 00       	call   80107094 <uartputc>
8010707e:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80107081:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107085:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107088:	0f b6 00             	movzbl (%eax),%eax
8010708b:	84 c0                	test   %al,%al
8010708d:	75 dd                	jne    8010706c <uartinit+0xc3>
8010708f:	eb 01                	jmp    80107092 <uartinit+0xe9>
    return;
80107091:	90                   	nop
}
80107092:	c9                   	leave  
80107093:	c3                   	ret    

80107094 <uartputc>:

void
uartputc(int c)
{
80107094:	f3 0f 1e fb          	endbr32 
80107098:	55                   	push   %ebp
80107099:	89 e5                	mov    %esp,%ebp
8010709b:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010709e:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801070a3:	85 c0                	test   %eax,%eax
801070a5:	74 53                	je     801070fa <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801070ae:	eb 11                	jmp    801070c1 <uartputc+0x2d>
    microdelay(10);
801070b0:	83 ec 0c             	sub    $0xc,%esp
801070b3:	6a 0a                	push   $0xa
801070b5:	e8 1a c1 ff ff       	call   801031d4 <microdelay>
801070ba:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801070c1:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801070c5:	7f 1a                	jg     801070e1 <uartputc+0x4d>
801070c7:	83 ec 0c             	sub    $0xc,%esp
801070ca:	68 fd 03 00 00       	push   $0x3fd
801070cf:	e8 97 fe ff ff       	call   80106f6b <inb>
801070d4:	83 c4 10             	add    $0x10,%esp
801070d7:	0f b6 c0             	movzbl %al,%eax
801070da:	83 e0 20             	and    $0x20,%eax
801070dd:	85 c0                	test   %eax,%eax
801070df:	74 cf                	je     801070b0 <uartputc+0x1c>
  outb(COM1+0, c);
801070e1:	8b 45 08             	mov    0x8(%ebp),%eax
801070e4:	0f b6 c0             	movzbl %al,%eax
801070e7:	83 ec 08             	sub    $0x8,%esp
801070ea:	50                   	push   %eax
801070eb:	68 f8 03 00 00       	push   $0x3f8
801070f0:	e8 93 fe ff ff       	call   80106f88 <outb>
801070f5:	83 c4 10             	add    $0x10,%esp
801070f8:	eb 01                	jmp    801070fb <uartputc+0x67>
    return;
801070fa:	90                   	nop
}
801070fb:	c9                   	leave  
801070fc:	c3                   	ret    

801070fd <uartgetc>:

static int
uartgetc(void)
{
801070fd:	f3 0f 1e fb          	endbr32 
80107101:	55                   	push   %ebp
80107102:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107104:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80107109:	85 c0                	test   %eax,%eax
8010710b:	75 07                	jne    80107114 <uartgetc+0x17>
    return -1;
8010710d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107112:	eb 2e                	jmp    80107142 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80107114:	68 fd 03 00 00       	push   $0x3fd
80107119:	e8 4d fe ff ff       	call   80106f6b <inb>
8010711e:	83 c4 04             	add    $0x4,%esp
80107121:	0f b6 c0             	movzbl %al,%eax
80107124:	83 e0 01             	and    $0x1,%eax
80107127:	85 c0                	test   %eax,%eax
80107129:	75 07                	jne    80107132 <uartgetc+0x35>
    return -1;
8010712b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107130:	eb 10                	jmp    80107142 <uartgetc+0x45>
  return inb(COM1+0);
80107132:	68 f8 03 00 00       	push   $0x3f8
80107137:	e8 2f fe ff ff       	call   80106f6b <inb>
8010713c:	83 c4 04             	add    $0x4,%esp
8010713f:	0f b6 c0             	movzbl %al,%eax
}
80107142:	c9                   	leave  
80107143:	c3                   	ret    

80107144 <uartintr>:

void
uartintr(void)
{
80107144:	f3 0f 1e fb          	endbr32 
80107148:	55                   	push   %ebp
80107149:	89 e5                	mov    %esp,%ebp
8010714b:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010714e:	83 ec 0c             	sub    $0xc,%esp
80107151:	68 fd 70 10 80       	push   $0x801070fd
80107156:	e8 4d 97 ff ff       	call   801008a8 <consoleintr>
8010715b:	83 c4 10             	add    $0x10,%esp
}
8010715e:	90                   	nop
8010715f:	c9                   	leave  
80107160:	c3                   	ret    

80107161 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $0
80107163:	6a 00                	push   $0x0
  jmp alltraps
80107165:	e9 7a f9 ff ff       	jmp    80106ae4 <alltraps>

8010716a <vector1>:
.globl vector1
vector1:
  pushl $0
8010716a:	6a 00                	push   $0x0
  pushl $1
8010716c:	6a 01                	push   $0x1
  jmp alltraps
8010716e:	e9 71 f9 ff ff       	jmp    80106ae4 <alltraps>

80107173 <vector2>:
.globl vector2
vector2:
  pushl $0
80107173:	6a 00                	push   $0x0
  pushl $2
80107175:	6a 02                	push   $0x2
  jmp alltraps
80107177:	e9 68 f9 ff ff       	jmp    80106ae4 <alltraps>

8010717c <vector3>:
.globl vector3
vector3:
  pushl $0
8010717c:	6a 00                	push   $0x0
  pushl $3
8010717e:	6a 03                	push   $0x3
  jmp alltraps
80107180:	e9 5f f9 ff ff       	jmp    80106ae4 <alltraps>

80107185 <vector4>:
.globl vector4
vector4:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $4
80107187:	6a 04                	push   $0x4
  jmp alltraps
80107189:	e9 56 f9 ff ff       	jmp    80106ae4 <alltraps>

8010718e <vector5>:
.globl vector5
vector5:
  pushl $0
8010718e:	6a 00                	push   $0x0
  pushl $5
80107190:	6a 05                	push   $0x5
  jmp alltraps
80107192:	e9 4d f9 ff ff       	jmp    80106ae4 <alltraps>

80107197 <vector6>:
.globl vector6
vector6:
  pushl $0
80107197:	6a 00                	push   $0x0
  pushl $6
80107199:	6a 06                	push   $0x6
  jmp alltraps
8010719b:	e9 44 f9 ff ff       	jmp    80106ae4 <alltraps>

801071a0 <vector7>:
.globl vector7
vector7:
  pushl $0
801071a0:	6a 00                	push   $0x0
  pushl $7
801071a2:	6a 07                	push   $0x7
  jmp alltraps
801071a4:	e9 3b f9 ff ff       	jmp    80106ae4 <alltraps>

801071a9 <vector8>:
.globl vector8
vector8:
  pushl $8
801071a9:	6a 08                	push   $0x8
  jmp alltraps
801071ab:	e9 34 f9 ff ff       	jmp    80106ae4 <alltraps>

801071b0 <vector9>:
.globl vector9
vector9:
  pushl $0
801071b0:	6a 00                	push   $0x0
  pushl $9
801071b2:	6a 09                	push   $0x9
  jmp alltraps
801071b4:	e9 2b f9 ff ff       	jmp    80106ae4 <alltraps>

801071b9 <vector10>:
.globl vector10
vector10:
  pushl $10
801071b9:	6a 0a                	push   $0xa
  jmp alltraps
801071bb:	e9 24 f9 ff ff       	jmp    80106ae4 <alltraps>

801071c0 <vector11>:
.globl vector11
vector11:
  pushl $11
801071c0:	6a 0b                	push   $0xb
  jmp alltraps
801071c2:	e9 1d f9 ff ff       	jmp    80106ae4 <alltraps>

801071c7 <vector12>:
.globl vector12
vector12:
  pushl $12
801071c7:	6a 0c                	push   $0xc
  jmp alltraps
801071c9:	e9 16 f9 ff ff       	jmp    80106ae4 <alltraps>

801071ce <vector13>:
.globl vector13
vector13:
  pushl $13
801071ce:	6a 0d                	push   $0xd
  jmp alltraps
801071d0:	e9 0f f9 ff ff       	jmp    80106ae4 <alltraps>

801071d5 <vector14>:
.globl vector14
vector14:
  pushl $14
801071d5:	6a 0e                	push   $0xe
  jmp alltraps
801071d7:	e9 08 f9 ff ff       	jmp    80106ae4 <alltraps>

801071dc <vector15>:
.globl vector15
vector15:
  pushl $0
801071dc:	6a 00                	push   $0x0
  pushl $15
801071de:	6a 0f                	push   $0xf
  jmp alltraps
801071e0:	e9 ff f8 ff ff       	jmp    80106ae4 <alltraps>

801071e5 <vector16>:
.globl vector16
vector16:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $16
801071e7:	6a 10                	push   $0x10
  jmp alltraps
801071e9:	e9 f6 f8 ff ff       	jmp    80106ae4 <alltraps>

801071ee <vector17>:
.globl vector17
vector17:
  pushl $17
801071ee:	6a 11                	push   $0x11
  jmp alltraps
801071f0:	e9 ef f8 ff ff       	jmp    80106ae4 <alltraps>

801071f5 <vector18>:
.globl vector18
vector18:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $18
801071f7:	6a 12                	push   $0x12
  jmp alltraps
801071f9:	e9 e6 f8 ff ff       	jmp    80106ae4 <alltraps>

801071fe <vector19>:
.globl vector19
vector19:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $19
80107200:	6a 13                	push   $0x13
  jmp alltraps
80107202:	e9 dd f8 ff ff       	jmp    80106ae4 <alltraps>

80107207 <vector20>:
.globl vector20
vector20:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $20
80107209:	6a 14                	push   $0x14
  jmp alltraps
8010720b:	e9 d4 f8 ff ff       	jmp    80106ae4 <alltraps>

80107210 <vector21>:
.globl vector21
vector21:
  pushl $0
80107210:	6a 00                	push   $0x0
  pushl $21
80107212:	6a 15                	push   $0x15
  jmp alltraps
80107214:	e9 cb f8 ff ff       	jmp    80106ae4 <alltraps>

80107219 <vector22>:
.globl vector22
vector22:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $22
8010721b:	6a 16                	push   $0x16
  jmp alltraps
8010721d:	e9 c2 f8 ff ff       	jmp    80106ae4 <alltraps>

80107222 <vector23>:
.globl vector23
vector23:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $23
80107224:	6a 17                	push   $0x17
  jmp alltraps
80107226:	e9 b9 f8 ff ff       	jmp    80106ae4 <alltraps>

8010722b <vector24>:
.globl vector24
vector24:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $24
8010722d:	6a 18                	push   $0x18
  jmp alltraps
8010722f:	e9 b0 f8 ff ff       	jmp    80106ae4 <alltraps>

80107234 <vector25>:
.globl vector25
vector25:
  pushl $0
80107234:	6a 00                	push   $0x0
  pushl $25
80107236:	6a 19                	push   $0x19
  jmp alltraps
80107238:	e9 a7 f8 ff ff       	jmp    80106ae4 <alltraps>

8010723d <vector26>:
.globl vector26
vector26:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $26
8010723f:	6a 1a                	push   $0x1a
  jmp alltraps
80107241:	e9 9e f8 ff ff       	jmp    80106ae4 <alltraps>

80107246 <vector27>:
.globl vector27
vector27:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $27
80107248:	6a 1b                	push   $0x1b
  jmp alltraps
8010724a:	e9 95 f8 ff ff       	jmp    80106ae4 <alltraps>

8010724f <vector28>:
.globl vector28
vector28:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $28
80107251:	6a 1c                	push   $0x1c
  jmp alltraps
80107253:	e9 8c f8 ff ff       	jmp    80106ae4 <alltraps>

80107258 <vector29>:
.globl vector29
vector29:
  pushl $0
80107258:	6a 00                	push   $0x0
  pushl $29
8010725a:	6a 1d                	push   $0x1d
  jmp alltraps
8010725c:	e9 83 f8 ff ff       	jmp    80106ae4 <alltraps>

80107261 <vector30>:
.globl vector30
vector30:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $30
80107263:	6a 1e                	push   $0x1e
  jmp alltraps
80107265:	e9 7a f8 ff ff       	jmp    80106ae4 <alltraps>

8010726a <vector31>:
.globl vector31
vector31:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $31
8010726c:	6a 1f                	push   $0x1f
  jmp alltraps
8010726e:	e9 71 f8 ff ff       	jmp    80106ae4 <alltraps>

80107273 <vector32>:
.globl vector32
vector32:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $32
80107275:	6a 20                	push   $0x20
  jmp alltraps
80107277:	e9 68 f8 ff ff       	jmp    80106ae4 <alltraps>

8010727c <vector33>:
.globl vector33
vector33:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $33
8010727e:	6a 21                	push   $0x21
  jmp alltraps
80107280:	e9 5f f8 ff ff       	jmp    80106ae4 <alltraps>

80107285 <vector34>:
.globl vector34
vector34:
  pushl $0
80107285:	6a 00                	push   $0x0
  pushl $34
80107287:	6a 22                	push   $0x22
  jmp alltraps
80107289:	e9 56 f8 ff ff       	jmp    80106ae4 <alltraps>

8010728e <vector35>:
.globl vector35
vector35:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $35
80107290:	6a 23                	push   $0x23
  jmp alltraps
80107292:	e9 4d f8 ff ff       	jmp    80106ae4 <alltraps>

80107297 <vector36>:
.globl vector36
vector36:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $36
80107299:	6a 24                	push   $0x24
  jmp alltraps
8010729b:	e9 44 f8 ff ff       	jmp    80106ae4 <alltraps>

801072a0 <vector37>:
.globl vector37
vector37:
  pushl $0
801072a0:	6a 00                	push   $0x0
  pushl $37
801072a2:	6a 25                	push   $0x25
  jmp alltraps
801072a4:	e9 3b f8 ff ff       	jmp    80106ae4 <alltraps>

801072a9 <vector38>:
.globl vector38
vector38:
  pushl $0
801072a9:	6a 00                	push   $0x0
  pushl $38
801072ab:	6a 26                	push   $0x26
  jmp alltraps
801072ad:	e9 32 f8 ff ff       	jmp    80106ae4 <alltraps>

801072b2 <vector39>:
.globl vector39
vector39:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $39
801072b4:	6a 27                	push   $0x27
  jmp alltraps
801072b6:	e9 29 f8 ff ff       	jmp    80106ae4 <alltraps>

801072bb <vector40>:
.globl vector40
vector40:
  pushl $0
801072bb:	6a 00                	push   $0x0
  pushl $40
801072bd:	6a 28                	push   $0x28
  jmp alltraps
801072bf:	e9 20 f8 ff ff       	jmp    80106ae4 <alltraps>

801072c4 <vector41>:
.globl vector41
vector41:
  pushl $0
801072c4:	6a 00                	push   $0x0
  pushl $41
801072c6:	6a 29                	push   $0x29
  jmp alltraps
801072c8:	e9 17 f8 ff ff       	jmp    80106ae4 <alltraps>

801072cd <vector42>:
.globl vector42
vector42:
  pushl $0
801072cd:	6a 00                	push   $0x0
  pushl $42
801072cf:	6a 2a                	push   $0x2a
  jmp alltraps
801072d1:	e9 0e f8 ff ff       	jmp    80106ae4 <alltraps>

801072d6 <vector43>:
.globl vector43
vector43:
  pushl $0
801072d6:	6a 00                	push   $0x0
  pushl $43
801072d8:	6a 2b                	push   $0x2b
  jmp alltraps
801072da:	e9 05 f8 ff ff       	jmp    80106ae4 <alltraps>

801072df <vector44>:
.globl vector44
vector44:
  pushl $0
801072df:	6a 00                	push   $0x0
  pushl $44
801072e1:	6a 2c                	push   $0x2c
  jmp alltraps
801072e3:	e9 fc f7 ff ff       	jmp    80106ae4 <alltraps>

801072e8 <vector45>:
.globl vector45
vector45:
  pushl $0
801072e8:	6a 00                	push   $0x0
  pushl $45
801072ea:	6a 2d                	push   $0x2d
  jmp alltraps
801072ec:	e9 f3 f7 ff ff       	jmp    80106ae4 <alltraps>

801072f1 <vector46>:
.globl vector46
vector46:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $46
801072f3:	6a 2e                	push   $0x2e
  jmp alltraps
801072f5:	e9 ea f7 ff ff       	jmp    80106ae4 <alltraps>

801072fa <vector47>:
.globl vector47
vector47:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $47
801072fc:	6a 2f                	push   $0x2f
  jmp alltraps
801072fe:	e9 e1 f7 ff ff       	jmp    80106ae4 <alltraps>

80107303 <vector48>:
.globl vector48
vector48:
  pushl $0
80107303:	6a 00                	push   $0x0
  pushl $48
80107305:	6a 30                	push   $0x30
  jmp alltraps
80107307:	e9 d8 f7 ff ff       	jmp    80106ae4 <alltraps>

8010730c <vector49>:
.globl vector49
vector49:
  pushl $0
8010730c:	6a 00                	push   $0x0
  pushl $49
8010730e:	6a 31                	push   $0x31
  jmp alltraps
80107310:	e9 cf f7 ff ff       	jmp    80106ae4 <alltraps>

80107315 <vector50>:
.globl vector50
vector50:
  pushl $0
80107315:	6a 00                	push   $0x0
  pushl $50
80107317:	6a 32                	push   $0x32
  jmp alltraps
80107319:	e9 c6 f7 ff ff       	jmp    80106ae4 <alltraps>

8010731e <vector51>:
.globl vector51
vector51:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $51
80107320:	6a 33                	push   $0x33
  jmp alltraps
80107322:	e9 bd f7 ff ff       	jmp    80106ae4 <alltraps>

80107327 <vector52>:
.globl vector52
vector52:
  pushl $0
80107327:	6a 00                	push   $0x0
  pushl $52
80107329:	6a 34                	push   $0x34
  jmp alltraps
8010732b:	e9 b4 f7 ff ff       	jmp    80106ae4 <alltraps>

80107330 <vector53>:
.globl vector53
vector53:
  pushl $0
80107330:	6a 00                	push   $0x0
  pushl $53
80107332:	6a 35                	push   $0x35
  jmp alltraps
80107334:	e9 ab f7 ff ff       	jmp    80106ae4 <alltraps>

80107339 <vector54>:
.globl vector54
vector54:
  pushl $0
80107339:	6a 00                	push   $0x0
  pushl $54
8010733b:	6a 36                	push   $0x36
  jmp alltraps
8010733d:	e9 a2 f7 ff ff       	jmp    80106ae4 <alltraps>

80107342 <vector55>:
.globl vector55
vector55:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $55
80107344:	6a 37                	push   $0x37
  jmp alltraps
80107346:	e9 99 f7 ff ff       	jmp    80106ae4 <alltraps>

8010734b <vector56>:
.globl vector56
vector56:
  pushl $0
8010734b:	6a 00                	push   $0x0
  pushl $56
8010734d:	6a 38                	push   $0x38
  jmp alltraps
8010734f:	e9 90 f7 ff ff       	jmp    80106ae4 <alltraps>

80107354 <vector57>:
.globl vector57
vector57:
  pushl $0
80107354:	6a 00                	push   $0x0
  pushl $57
80107356:	6a 39                	push   $0x39
  jmp alltraps
80107358:	e9 87 f7 ff ff       	jmp    80106ae4 <alltraps>

8010735d <vector58>:
.globl vector58
vector58:
  pushl $0
8010735d:	6a 00                	push   $0x0
  pushl $58
8010735f:	6a 3a                	push   $0x3a
  jmp alltraps
80107361:	e9 7e f7 ff ff       	jmp    80106ae4 <alltraps>

80107366 <vector59>:
.globl vector59
vector59:
  pushl $0
80107366:	6a 00                	push   $0x0
  pushl $59
80107368:	6a 3b                	push   $0x3b
  jmp alltraps
8010736a:	e9 75 f7 ff ff       	jmp    80106ae4 <alltraps>

8010736f <vector60>:
.globl vector60
vector60:
  pushl $0
8010736f:	6a 00                	push   $0x0
  pushl $60
80107371:	6a 3c                	push   $0x3c
  jmp alltraps
80107373:	e9 6c f7 ff ff       	jmp    80106ae4 <alltraps>

80107378 <vector61>:
.globl vector61
vector61:
  pushl $0
80107378:	6a 00                	push   $0x0
  pushl $61
8010737a:	6a 3d                	push   $0x3d
  jmp alltraps
8010737c:	e9 63 f7 ff ff       	jmp    80106ae4 <alltraps>

80107381 <vector62>:
.globl vector62
vector62:
  pushl $0
80107381:	6a 00                	push   $0x0
  pushl $62
80107383:	6a 3e                	push   $0x3e
  jmp alltraps
80107385:	e9 5a f7 ff ff       	jmp    80106ae4 <alltraps>

8010738a <vector63>:
.globl vector63
vector63:
  pushl $0
8010738a:	6a 00                	push   $0x0
  pushl $63
8010738c:	6a 3f                	push   $0x3f
  jmp alltraps
8010738e:	e9 51 f7 ff ff       	jmp    80106ae4 <alltraps>

80107393 <vector64>:
.globl vector64
vector64:
  pushl $0
80107393:	6a 00                	push   $0x0
  pushl $64
80107395:	6a 40                	push   $0x40
  jmp alltraps
80107397:	e9 48 f7 ff ff       	jmp    80106ae4 <alltraps>

8010739c <vector65>:
.globl vector65
vector65:
  pushl $0
8010739c:	6a 00                	push   $0x0
  pushl $65
8010739e:	6a 41                	push   $0x41
  jmp alltraps
801073a0:	e9 3f f7 ff ff       	jmp    80106ae4 <alltraps>

801073a5 <vector66>:
.globl vector66
vector66:
  pushl $0
801073a5:	6a 00                	push   $0x0
  pushl $66
801073a7:	6a 42                	push   $0x42
  jmp alltraps
801073a9:	e9 36 f7 ff ff       	jmp    80106ae4 <alltraps>

801073ae <vector67>:
.globl vector67
vector67:
  pushl $0
801073ae:	6a 00                	push   $0x0
  pushl $67
801073b0:	6a 43                	push   $0x43
  jmp alltraps
801073b2:	e9 2d f7 ff ff       	jmp    80106ae4 <alltraps>

801073b7 <vector68>:
.globl vector68
vector68:
  pushl $0
801073b7:	6a 00                	push   $0x0
  pushl $68
801073b9:	6a 44                	push   $0x44
  jmp alltraps
801073bb:	e9 24 f7 ff ff       	jmp    80106ae4 <alltraps>

801073c0 <vector69>:
.globl vector69
vector69:
  pushl $0
801073c0:	6a 00                	push   $0x0
  pushl $69
801073c2:	6a 45                	push   $0x45
  jmp alltraps
801073c4:	e9 1b f7 ff ff       	jmp    80106ae4 <alltraps>

801073c9 <vector70>:
.globl vector70
vector70:
  pushl $0
801073c9:	6a 00                	push   $0x0
  pushl $70
801073cb:	6a 46                	push   $0x46
  jmp alltraps
801073cd:	e9 12 f7 ff ff       	jmp    80106ae4 <alltraps>

801073d2 <vector71>:
.globl vector71
vector71:
  pushl $0
801073d2:	6a 00                	push   $0x0
  pushl $71
801073d4:	6a 47                	push   $0x47
  jmp alltraps
801073d6:	e9 09 f7 ff ff       	jmp    80106ae4 <alltraps>

801073db <vector72>:
.globl vector72
vector72:
  pushl $0
801073db:	6a 00                	push   $0x0
  pushl $72
801073dd:	6a 48                	push   $0x48
  jmp alltraps
801073df:	e9 00 f7 ff ff       	jmp    80106ae4 <alltraps>

801073e4 <vector73>:
.globl vector73
vector73:
  pushl $0
801073e4:	6a 00                	push   $0x0
  pushl $73
801073e6:	6a 49                	push   $0x49
  jmp alltraps
801073e8:	e9 f7 f6 ff ff       	jmp    80106ae4 <alltraps>

801073ed <vector74>:
.globl vector74
vector74:
  pushl $0
801073ed:	6a 00                	push   $0x0
  pushl $74
801073ef:	6a 4a                	push   $0x4a
  jmp alltraps
801073f1:	e9 ee f6 ff ff       	jmp    80106ae4 <alltraps>

801073f6 <vector75>:
.globl vector75
vector75:
  pushl $0
801073f6:	6a 00                	push   $0x0
  pushl $75
801073f8:	6a 4b                	push   $0x4b
  jmp alltraps
801073fa:	e9 e5 f6 ff ff       	jmp    80106ae4 <alltraps>

801073ff <vector76>:
.globl vector76
vector76:
  pushl $0
801073ff:	6a 00                	push   $0x0
  pushl $76
80107401:	6a 4c                	push   $0x4c
  jmp alltraps
80107403:	e9 dc f6 ff ff       	jmp    80106ae4 <alltraps>

80107408 <vector77>:
.globl vector77
vector77:
  pushl $0
80107408:	6a 00                	push   $0x0
  pushl $77
8010740a:	6a 4d                	push   $0x4d
  jmp alltraps
8010740c:	e9 d3 f6 ff ff       	jmp    80106ae4 <alltraps>

80107411 <vector78>:
.globl vector78
vector78:
  pushl $0
80107411:	6a 00                	push   $0x0
  pushl $78
80107413:	6a 4e                	push   $0x4e
  jmp alltraps
80107415:	e9 ca f6 ff ff       	jmp    80106ae4 <alltraps>

8010741a <vector79>:
.globl vector79
vector79:
  pushl $0
8010741a:	6a 00                	push   $0x0
  pushl $79
8010741c:	6a 4f                	push   $0x4f
  jmp alltraps
8010741e:	e9 c1 f6 ff ff       	jmp    80106ae4 <alltraps>

80107423 <vector80>:
.globl vector80
vector80:
  pushl $0
80107423:	6a 00                	push   $0x0
  pushl $80
80107425:	6a 50                	push   $0x50
  jmp alltraps
80107427:	e9 b8 f6 ff ff       	jmp    80106ae4 <alltraps>

8010742c <vector81>:
.globl vector81
vector81:
  pushl $0
8010742c:	6a 00                	push   $0x0
  pushl $81
8010742e:	6a 51                	push   $0x51
  jmp alltraps
80107430:	e9 af f6 ff ff       	jmp    80106ae4 <alltraps>

80107435 <vector82>:
.globl vector82
vector82:
  pushl $0
80107435:	6a 00                	push   $0x0
  pushl $82
80107437:	6a 52                	push   $0x52
  jmp alltraps
80107439:	e9 a6 f6 ff ff       	jmp    80106ae4 <alltraps>

8010743e <vector83>:
.globl vector83
vector83:
  pushl $0
8010743e:	6a 00                	push   $0x0
  pushl $83
80107440:	6a 53                	push   $0x53
  jmp alltraps
80107442:	e9 9d f6 ff ff       	jmp    80106ae4 <alltraps>

80107447 <vector84>:
.globl vector84
vector84:
  pushl $0
80107447:	6a 00                	push   $0x0
  pushl $84
80107449:	6a 54                	push   $0x54
  jmp alltraps
8010744b:	e9 94 f6 ff ff       	jmp    80106ae4 <alltraps>

80107450 <vector85>:
.globl vector85
vector85:
  pushl $0
80107450:	6a 00                	push   $0x0
  pushl $85
80107452:	6a 55                	push   $0x55
  jmp alltraps
80107454:	e9 8b f6 ff ff       	jmp    80106ae4 <alltraps>

80107459 <vector86>:
.globl vector86
vector86:
  pushl $0
80107459:	6a 00                	push   $0x0
  pushl $86
8010745b:	6a 56                	push   $0x56
  jmp alltraps
8010745d:	e9 82 f6 ff ff       	jmp    80106ae4 <alltraps>

80107462 <vector87>:
.globl vector87
vector87:
  pushl $0
80107462:	6a 00                	push   $0x0
  pushl $87
80107464:	6a 57                	push   $0x57
  jmp alltraps
80107466:	e9 79 f6 ff ff       	jmp    80106ae4 <alltraps>

8010746b <vector88>:
.globl vector88
vector88:
  pushl $0
8010746b:	6a 00                	push   $0x0
  pushl $88
8010746d:	6a 58                	push   $0x58
  jmp alltraps
8010746f:	e9 70 f6 ff ff       	jmp    80106ae4 <alltraps>

80107474 <vector89>:
.globl vector89
vector89:
  pushl $0
80107474:	6a 00                	push   $0x0
  pushl $89
80107476:	6a 59                	push   $0x59
  jmp alltraps
80107478:	e9 67 f6 ff ff       	jmp    80106ae4 <alltraps>

8010747d <vector90>:
.globl vector90
vector90:
  pushl $0
8010747d:	6a 00                	push   $0x0
  pushl $90
8010747f:	6a 5a                	push   $0x5a
  jmp alltraps
80107481:	e9 5e f6 ff ff       	jmp    80106ae4 <alltraps>

80107486 <vector91>:
.globl vector91
vector91:
  pushl $0
80107486:	6a 00                	push   $0x0
  pushl $91
80107488:	6a 5b                	push   $0x5b
  jmp alltraps
8010748a:	e9 55 f6 ff ff       	jmp    80106ae4 <alltraps>

8010748f <vector92>:
.globl vector92
vector92:
  pushl $0
8010748f:	6a 00                	push   $0x0
  pushl $92
80107491:	6a 5c                	push   $0x5c
  jmp alltraps
80107493:	e9 4c f6 ff ff       	jmp    80106ae4 <alltraps>

80107498 <vector93>:
.globl vector93
vector93:
  pushl $0
80107498:	6a 00                	push   $0x0
  pushl $93
8010749a:	6a 5d                	push   $0x5d
  jmp alltraps
8010749c:	e9 43 f6 ff ff       	jmp    80106ae4 <alltraps>

801074a1 <vector94>:
.globl vector94
vector94:
  pushl $0
801074a1:	6a 00                	push   $0x0
  pushl $94
801074a3:	6a 5e                	push   $0x5e
  jmp alltraps
801074a5:	e9 3a f6 ff ff       	jmp    80106ae4 <alltraps>

801074aa <vector95>:
.globl vector95
vector95:
  pushl $0
801074aa:	6a 00                	push   $0x0
  pushl $95
801074ac:	6a 5f                	push   $0x5f
  jmp alltraps
801074ae:	e9 31 f6 ff ff       	jmp    80106ae4 <alltraps>

801074b3 <vector96>:
.globl vector96
vector96:
  pushl $0
801074b3:	6a 00                	push   $0x0
  pushl $96
801074b5:	6a 60                	push   $0x60
  jmp alltraps
801074b7:	e9 28 f6 ff ff       	jmp    80106ae4 <alltraps>

801074bc <vector97>:
.globl vector97
vector97:
  pushl $0
801074bc:	6a 00                	push   $0x0
  pushl $97
801074be:	6a 61                	push   $0x61
  jmp alltraps
801074c0:	e9 1f f6 ff ff       	jmp    80106ae4 <alltraps>

801074c5 <vector98>:
.globl vector98
vector98:
  pushl $0
801074c5:	6a 00                	push   $0x0
  pushl $98
801074c7:	6a 62                	push   $0x62
  jmp alltraps
801074c9:	e9 16 f6 ff ff       	jmp    80106ae4 <alltraps>

801074ce <vector99>:
.globl vector99
vector99:
  pushl $0
801074ce:	6a 00                	push   $0x0
  pushl $99
801074d0:	6a 63                	push   $0x63
  jmp alltraps
801074d2:	e9 0d f6 ff ff       	jmp    80106ae4 <alltraps>

801074d7 <vector100>:
.globl vector100
vector100:
  pushl $0
801074d7:	6a 00                	push   $0x0
  pushl $100
801074d9:	6a 64                	push   $0x64
  jmp alltraps
801074db:	e9 04 f6 ff ff       	jmp    80106ae4 <alltraps>

801074e0 <vector101>:
.globl vector101
vector101:
  pushl $0
801074e0:	6a 00                	push   $0x0
  pushl $101
801074e2:	6a 65                	push   $0x65
  jmp alltraps
801074e4:	e9 fb f5 ff ff       	jmp    80106ae4 <alltraps>

801074e9 <vector102>:
.globl vector102
vector102:
  pushl $0
801074e9:	6a 00                	push   $0x0
  pushl $102
801074eb:	6a 66                	push   $0x66
  jmp alltraps
801074ed:	e9 f2 f5 ff ff       	jmp    80106ae4 <alltraps>

801074f2 <vector103>:
.globl vector103
vector103:
  pushl $0
801074f2:	6a 00                	push   $0x0
  pushl $103
801074f4:	6a 67                	push   $0x67
  jmp alltraps
801074f6:	e9 e9 f5 ff ff       	jmp    80106ae4 <alltraps>

801074fb <vector104>:
.globl vector104
vector104:
  pushl $0
801074fb:	6a 00                	push   $0x0
  pushl $104
801074fd:	6a 68                	push   $0x68
  jmp alltraps
801074ff:	e9 e0 f5 ff ff       	jmp    80106ae4 <alltraps>

80107504 <vector105>:
.globl vector105
vector105:
  pushl $0
80107504:	6a 00                	push   $0x0
  pushl $105
80107506:	6a 69                	push   $0x69
  jmp alltraps
80107508:	e9 d7 f5 ff ff       	jmp    80106ae4 <alltraps>

8010750d <vector106>:
.globl vector106
vector106:
  pushl $0
8010750d:	6a 00                	push   $0x0
  pushl $106
8010750f:	6a 6a                	push   $0x6a
  jmp alltraps
80107511:	e9 ce f5 ff ff       	jmp    80106ae4 <alltraps>

80107516 <vector107>:
.globl vector107
vector107:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $107
80107518:	6a 6b                	push   $0x6b
  jmp alltraps
8010751a:	e9 c5 f5 ff ff       	jmp    80106ae4 <alltraps>

8010751f <vector108>:
.globl vector108
vector108:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $108
80107521:	6a 6c                	push   $0x6c
  jmp alltraps
80107523:	e9 bc f5 ff ff       	jmp    80106ae4 <alltraps>

80107528 <vector109>:
.globl vector109
vector109:
  pushl $0
80107528:	6a 00                	push   $0x0
  pushl $109
8010752a:	6a 6d                	push   $0x6d
  jmp alltraps
8010752c:	e9 b3 f5 ff ff       	jmp    80106ae4 <alltraps>

80107531 <vector110>:
.globl vector110
vector110:
  pushl $0
80107531:	6a 00                	push   $0x0
  pushl $110
80107533:	6a 6e                	push   $0x6e
  jmp alltraps
80107535:	e9 aa f5 ff ff       	jmp    80106ae4 <alltraps>

8010753a <vector111>:
.globl vector111
vector111:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $111
8010753c:	6a 6f                	push   $0x6f
  jmp alltraps
8010753e:	e9 a1 f5 ff ff       	jmp    80106ae4 <alltraps>

80107543 <vector112>:
.globl vector112
vector112:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $112
80107545:	6a 70                	push   $0x70
  jmp alltraps
80107547:	e9 98 f5 ff ff       	jmp    80106ae4 <alltraps>

8010754c <vector113>:
.globl vector113
vector113:
  pushl $0
8010754c:	6a 00                	push   $0x0
  pushl $113
8010754e:	6a 71                	push   $0x71
  jmp alltraps
80107550:	e9 8f f5 ff ff       	jmp    80106ae4 <alltraps>

80107555 <vector114>:
.globl vector114
vector114:
  pushl $0
80107555:	6a 00                	push   $0x0
  pushl $114
80107557:	6a 72                	push   $0x72
  jmp alltraps
80107559:	e9 86 f5 ff ff       	jmp    80106ae4 <alltraps>

8010755e <vector115>:
.globl vector115
vector115:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $115
80107560:	6a 73                	push   $0x73
  jmp alltraps
80107562:	e9 7d f5 ff ff       	jmp    80106ae4 <alltraps>

80107567 <vector116>:
.globl vector116
vector116:
  pushl $0
80107567:	6a 00                	push   $0x0
  pushl $116
80107569:	6a 74                	push   $0x74
  jmp alltraps
8010756b:	e9 74 f5 ff ff       	jmp    80106ae4 <alltraps>

80107570 <vector117>:
.globl vector117
vector117:
  pushl $0
80107570:	6a 00                	push   $0x0
  pushl $117
80107572:	6a 75                	push   $0x75
  jmp alltraps
80107574:	e9 6b f5 ff ff       	jmp    80106ae4 <alltraps>

80107579 <vector118>:
.globl vector118
vector118:
  pushl $0
80107579:	6a 00                	push   $0x0
  pushl $118
8010757b:	6a 76                	push   $0x76
  jmp alltraps
8010757d:	e9 62 f5 ff ff       	jmp    80106ae4 <alltraps>

80107582 <vector119>:
.globl vector119
vector119:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $119
80107584:	6a 77                	push   $0x77
  jmp alltraps
80107586:	e9 59 f5 ff ff       	jmp    80106ae4 <alltraps>

8010758b <vector120>:
.globl vector120
vector120:
  pushl $0
8010758b:	6a 00                	push   $0x0
  pushl $120
8010758d:	6a 78                	push   $0x78
  jmp alltraps
8010758f:	e9 50 f5 ff ff       	jmp    80106ae4 <alltraps>

80107594 <vector121>:
.globl vector121
vector121:
  pushl $0
80107594:	6a 00                	push   $0x0
  pushl $121
80107596:	6a 79                	push   $0x79
  jmp alltraps
80107598:	e9 47 f5 ff ff       	jmp    80106ae4 <alltraps>

8010759d <vector122>:
.globl vector122
vector122:
  pushl $0
8010759d:	6a 00                	push   $0x0
  pushl $122
8010759f:	6a 7a                	push   $0x7a
  jmp alltraps
801075a1:	e9 3e f5 ff ff       	jmp    80106ae4 <alltraps>

801075a6 <vector123>:
.globl vector123
vector123:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $123
801075a8:	6a 7b                	push   $0x7b
  jmp alltraps
801075aa:	e9 35 f5 ff ff       	jmp    80106ae4 <alltraps>

801075af <vector124>:
.globl vector124
vector124:
  pushl $0
801075af:	6a 00                	push   $0x0
  pushl $124
801075b1:	6a 7c                	push   $0x7c
  jmp alltraps
801075b3:	e9 2c f5 ff ff       	jmp    80106ae4 <alltraps>

801075b8 <vector125>:
.globl vector125
vector125:
  pushl $0
801075b8:	6a 00                	push   $0x0
  pushl $125
801075ba:	6a 7d                	push   $0x7d
  jmp alltraps
801075bc:	e9 23 f5 ff ff       	jmp    80106ae4 <alltraps>

801075c1 <vector126>:
.globl vector126
vector126:
  pushl $0
801075c1:	6a 00                	push   $0x0
  pushl $126
801075c3:	6a 7e                	push   $0x7e
  jmp alltraps
801075c5:	e9 1a f5 ff ff       	jmp    80106ae4 <alltraps>

801075ca <vector127>:
.globl vector127
vector127:
  pushl $0
801075ca:	6a 00                	push   $0x0
  pushl $127
801075cc:	6a 7f                	push   $0x7f
  jmp alltraps
801075ce:	e9 11 f5 ff ff       	jmp    80106ae4 <alltraps>

801075d3 <vector128>:
.globl vector128
vector128:
  pushl $0
801075d3:	6a 00                	push   $0x0
  pushl $128
801075d5:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801075da:	e9 05 f5 ff ff       	jmp    80106ae4 <alltraps>

801075df <vector129>:
.globl vector129
vector129:
  pushl $0
801075df:	6a 00                	push   $0x0
  pushl $129
801075e1:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801075e6:	e9 f9 f4 ff ff       	jmp    80106ae4 <alltraps>

801075eb <vector130>:
.globl vector130
vector130:
  pushl $0
801075eb:	6a 00                	push   $0x0
  pushl $130
801075ed:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801075f2:	e9 ed f4 ff ff       	jmp    80106ae4 <alltraps>

801075f7 <vector131>:
.globl vector131
vector131:
  pushl $0
801075f7:	6a 00                	push   $0x0
  pushl $131
801075f9:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801075fe:	e9 e1 f4 ff ff       	jmp    80106ae4 <alltraps>

80107603 <vector132>:
.globl vector132
vector132:
  pushl $0
80107603:	6a 00                	push   $0x0
  pushl $132
80107605:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010760a:	e9 d5 f4 ff ff       	jmp    80106ae4 <alltraps>

8010760f <vector133>:
.globl vector133
vector133:
  pushl $0
8010760f:	6a 00                	push   $0x0
  pushl $133
80107611:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107616:	e9 c9 f4 ff ff       	jmp    80106ae4 <alltraps>

8010761b <vector134>:
.globl vector134
vector134:
  pushl $0
8010761b:	6a 00                	push   $0x0
  pushl $134
8010761d:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107622:	e9 bd f4 ff ff       	jmp    80106ae4 <alltraps>

80107627 <vector135>:
.globl vector135
vector135:
  pushl $0
80107627:	6a 00                	push   $0x0
  pushl $135
80107629:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010762e:	e9 b1 f4 ff ff       	jmp    80106ae4 <alltraps>

80107633 <vector136>:
.globl vector136
vector136:
  pushl $0
80107633:	6a 00                	push   $0x0
  pushl $136
80107635:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010763a:	e9 a5 f4 ff ff       	jmp    80106ae4 <alltraps>

8010763f <vector137>:
.globl vector137
vector137:
  pushl $0
8010763f:	6a 00                	push   $0x0
  pushl $137
80107641:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107646:	e9 99 f4 ff ff       	jmp    80106ae4 <alltraps>

8010764b <vector138>:
.globl vector138
vector138:
  pushl $0
8010764b:	6a 00                	push   $0x0
  pushl $138
8010764d:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107652:	e9 8d f4 ff ff       	jmp    80106ae4 <alltraps>

80107657 <vector139>:
.globl vector139
vector139:
  pushl $0
80107657:	6a 00                	push   $0x0
  pushl $139
80107659:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010765e:	e9 81 f4 ff ff       	jmp    80106ae4 <alltraps>

80107663 <vector140>:
.globl vector140
vector140:
  pushl $0
80107663:	6a 00                	push   $0x0
  pushl $140
80107665:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010766a:	e9 75 f4 ff ff       	jmp    80106ae4 <alltraps>

8010766f <vector141>:
.globl vector141
vector141:
  pushl $0
8010766f:	6a 00                	push   $0x0
  pushl $141
80107671:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107676:	e9 69 f4 ff ff       	jmp    80106ae4 <alltraps>

8010767b <vector142>:
.globl vector142
vector142:
  pushl $0
8010767b:	6a 00                	push   $0x0
  pushl $142
8010767d:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107682:	e9 5d f4 ff ff       	jmp    80106ae4 <alltraps>

80107687 <vector143>:
.globl vector143
vector143:
  pushl $0
80107687:	6a 00                	push   $0x0
  pushl $143
80107689:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010768e:	e9 51 f4 ff ff       	jmp    80106ae4 <alltraps>

80107693 <vector144>:
.globl vector144
vector144:
  pushl $0
80107693:	6a 00                	push   $0x0
  pushl $144
80107695:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010769a:	e9 45 f4 ff ff       	jmp    80106ae4 <alltraps>

8010769f <vector145>:
.globl vector145
vector145:
  pushl $0
8010769f:	6a 00                	push   $0x0
  pushl $145
801076a1:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801076a6:	e9 39 f4 ff ff       	jmp    80106ae4 <alltraps>

801076ab <vector146>:
.globl vector146
vector146:
  pushl $0
801076ab:	6a 00                	push   $0x0
  pushl $146
801076ad:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801076b2:	e9 2d f4 ff ff       	jmp    80106ae4 <alltraps>

801076b7 <vector147>:
.globl vector147
vector147:
  pushl $0
801076b7:	6a 00                	push   $0x0
  pushl $147
801076b9:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801076be:	e9 21 f4 ff ff       	jmp    80106ae4 <alltraps>

801076c3 <vector148>:
.globl vector148
vector148:
  pushl $0
801076c3:	6a 00                	push   $0x0
  pushl $148
801076c5:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801076ca:	e9 15 f4 ff ff       	jmp    80106ae4 <alltraps>

801076cf <vector149>:
.globl vector149
vector149:
  pushl $0
801076cf:	6a 00                	push   $0x0
  pushl $149
801076d1:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801076d6:	e9 09 f4 ff ff       	jmp    80106ae4 <alltraps>

801076db <vector150>:
.globl vector150
vector150:
  pushl $0
801076db:	6a 00                	push   $0x0
  pushl $150
801076dd:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801076e2:	e9 fd f3 ff ff       	jmp    80106ae4 <alltraps>

801076e7 <vector151>:
.globl vector151
vector151:
  pushl $0
801076e7:	6a 00                	push   $0x0
  pushl $151
801076e9:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801076ee:	e9 f1 f3 ff ff       	jmp    80106ae4 <alltraps>

801076f3 <vector152>:
.globl vector152
vector152:
  pushl $0
801076f3:	6a 00                	push   $0x0
  pushl $152
801076f5:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801076fa:	e9 e5 f3 ff ff       	jmp    80106ae4 <alltraps>

801076ff <vector153>:
.globl vector153
vector153:
  pushl $0
801076ff:	6a 00                	push   $0x0
  pushl $153
80107701:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107706:	e9 d9 f3 ff ff       	jmp    80106ae4 <alltraps>

8010770b <vector154>:
.globl vector154
vector154:
  pushl $0
8010770b:	6a 00                	push   $0x0
  pushl $154
8010770d:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107712:	e9 cd f3 ff ff       	jmp    80106ae4 <alltraps>

80107717 <vector155>:
.globl vector155
vector155:
  pushl $0
80107717:	6a 00                	push   $0x0
  pushl $155
80107719:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010771e:	e9 c1 f3 ff ff       	jmp    80106ae4 <alltraps>

80107723 <vector156>:
.globl vector156
vector156:
  pushl $0
80107723:	6a 00                	push   $0x0
  pushl $156
80107725:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010772a:	e9 b5 f3 ff ff       	jmp    80106ae4 <alltraps>

8010772f <vector157>:
.globl vector157
vector157:
  pushl $0
8010772f:	6a 00                	push   $0x0
  pushl $157
80107731:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107736:	e9 a9 f3 ff ff       	jmp    80106ae4 <alltraps>

8010773b <vector158>:
.globl vector158
vector158:
  pushl $0
8010773b:	6a 00                	push   $0x0
  pushl $158
8010773d:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107742:	e9 9d f3 ff ff       	jmp    80106ae4 <alltraps>

80107747 <vector159>:
.globl vector159
vector159:
  pushl $0
80107747:	6a 00                	push   $0x0
  pushl $159
80107749:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010774e:	e9 91 f3 ff ff       	jmp    80106ae4 <alltraps>

80107753 <vector160>:
.globl vector160
vector160:
  pushl $0
80107753:	6a 00                	push   $0x0
  pushl $160
80107755:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010775a:	e9 85 f3 ff ff       	jmp    80106ae4 <alltraps>

8010775f <vector161>:
.globl vector161
vector161:
  pushl $0
8010775f:	6a 00                	push   $0x0
  pushl $161
80107761:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107766:	e9 79 f3 ff ff       	jmp    80106ae4 <alltraps>

8010776b <vector162>:
.globl vector162
vector162:
  pushl $0
8010776b:	6a 00                	push   $0x0
  pushl $162
8010776d:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107772:	e9 6d f3 ff ff       	jmp    80106ae4 <alltraps>

80107777 <vector163>:
.globl vector163
vector163:
  pushl $0
80107777:	6a 00                	push   $0x0
  pushl $163
80107779:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010777e:	e9 61 f3 ff ff       	jmp    80106ae4 <alltraps>

80107783 <vector164>:
.globl vector164
vector164:
  pushl $0
80107783:	6a 00                	push   $0x0
  pushl $164
80107785:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010778a:	e9 55 f3 ff ff       	jmp    80106ae4 <alltraps>

8010778f <vector165>:
.globl vector165
vector165:
  pushl $0
8010778f:	6a 00                	push   $0x0
  pushl $165
80107791:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107796:	e9 49 f3 ff ff       	jmp    80106ae4 <alltraps>

8010779b <vector166>:
.globl vector166
vector166:
  pushl $0
8010779b:	6a 00                	push   $0x0
  pushl $166
8010779d:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801077a2:	e9 3d f3 ff ff       	jmp    80106ae4 <alltraps>

801077a7 <vector167>:
.globl vector167
vector167:
  pushl $0
801077a7:	6a 00                	push   $0x0
  pushl $167
801077a9:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801077ae:	e9 31 f3 ff ff       	jmp    80106ae4 <alltraps>

801077b3 <vector168>:
.globl vector168
vector168:
  pushl $0
801077b3:	6a 00                	push   $0x0
  pushl $168
801077b5:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801077ba:	e9 25 f3 ff ff       	jmp    80106ae4 <alltraps>

801077bf <vector169>:
.globl vector169
vector169:
  pushl $0
801077bf:	6a 00                	push   $0x0
  pushl $169
801077c1:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801077c6:	e9 19 f3 ff ff       	jmp    80106ae4 <alltraps>

801077cb <vector170>:
.globl vector170
vector170:
  pushl $0
801077cb:	6a 00                	push   $0x0
  pushl $170
801077cd:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801077d2:	e9 0d f3 ff ff       	jmp    80106ae4 <alltraps>

801077d7 <vector171>:
.globl vector171
vector171:
  pushl $0
801077d7:	6a 00                	push   $0x0
  pushl $171
801077d9:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801077de:	e9 01 f3 ff ff       	jmp    80106ae4 <alltraps>

801077e3 <vector172>:
.globl vector172
vector172:
  pushl $0
801077e3:	6a 00                	push   $0x0
  pushl $172
801077e5:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801077ea:	e9 f5 f2 ff ff       	jmp    80106ae4 <alltraps>

801077ef <vector173>:
.globl vector173
vector173:
  pushl $0
801077ef:	6a 00                	push   $0x0
  pushl $173
801077f1:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801077f6:	e9 e9 f2 ff ff       	jmp    80106ae4 <alltraps>

801077fb <vector174>:
.globl vector174
vector174:
  pushl $0
801077fb:	6a 00                	push   $0x0
  pushl $174
801077fd:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107802:	e9 dd f2 ff ff       	jmp    80106ae4 <alltraps>

80107807 <vector175>:
.globl vector175
vector175:
  pushl $0
80107807:	6a 00                	push   $0x0
  pushl $175
80107809:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010780e:	e9 d1 f2 ff ff       	jmp    80106ae4 <alltraps>

80107813 <vector176>:
.globl vector176
vector176:
  pushl $0
80107813:	6a 00                	push   $0x0
  pushl $176
80107815:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010781a:	e9 c5 f2 ff ff       	jmp    80106ae4 <alltraps>

8010781f <vector177>:
.globl vector177
vector177:
  pushl $0
8010781f:	6a 00                	push   $0x0
  pushl $177
80107821:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107826:	e9 b9 f2 ff ff       	jmp    80106ae4 <alltraps>

8010782b <vector178>:
.globl vector178
vector178:
  pushl $0
8010782b:	6a 00                	push   $0x0
  pushl $178
8010782d:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107832:	e9 ad f2 ff ff       	jmp    80106ae4 <alltraps>

80107837 <vector179>:
.globl vector179
vector179:
  pushl $0
80107837:	6a 00                	push   $0x0
  pushl $179
80107839:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010783e:	e9 a1 f2 ff ff       	jmp    80106ae4 <alltraps>

80107843 <vector180>:
.globl vector180
vector180:
  pushl $0
80107843:	6a 00                	push   $0x0
  pushl $180
80107845:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010784a:	e9 95 f2 ff ff       	jmp    80106ae4 <alltraps>

8010784f <vector181>:
.globl vector181
vector181:
  pushl $0
8010784f:	6a 00                	push   $0x0
  pushl $181
80107851:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107856:	e9 89 f2 ff ff       	jmp    80106ae4 <alltraps>

8010785b <vector182>:
.globl vector182
vector182:
  pushl $0
8010785b:	6a 00                	push   $0x0
  pushl $182
8010785d:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107862:	e9 7d f2 ff ff       	jmp    80106ae4 <alltraps>

80107867 <vector183>:
.globl vector183
vector183:
  pushl $0
80107867:	6a 00                	push   $0x0
  pushl $183
80107869:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010786e:	e9 71 f2 ff ff       	jmp    80106ae4 <alltraps>

80107873 <vector184>:
.globl vector184
vector184:
  pushl $0
80107873:	6a 00                	push   $0x0
  pushl $184
80107875:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010787a:	e9 65 f2 ff ff       	jmp    80106ae4 <alltraps>

8010787f <vector185>:
.globl vector185
vector185:
  pushl $0
8010787f:	6a 00                	push   $0x0
  pushl $185
80107881:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107886:	e9 59 f2 ff ff       	jmp    80106ae4 <alltraps>

8010788b <vector186>:
.globl vector186
vector186:
  pushl $0
8010788b:	6a 00                	push   $0x0
  pushl $186
8010788d:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107892:	e9 4d f2 ff ff       	jmp    80106ae4 <alltraps>

80107897 <vector187>:
.globl vector187
vector187:
  pushl $0
80107897:	6a 00                	push   $0x0
  pushl $187
80107899:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010789e:	e9 41 f2 ff ff       	jmp    80106ae4 <alltraps>

801078a3 <vector188>:
.globl vector188
vector188:
  pushl $0
801078a3:	6a 00                	push   $0x0
  pushl $188
801078a5:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801078aa:	e9 35 f2 ff ff       	jmp    80106ae4 <alltraps>

801078af <vector189>:
.globl vector189
vector189:
  pushl $0
801078af:	6a 00                	push   $0x0
  pushl $189
801078b1:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801078b6:	e9 29 f2 ff ff       	jmp    80106ae4 <alltraps>

801078bb <vector190>:
.globl vector190
vector190:
  pushl $0
801078bb:	6a 00                	push   $0x0
  pushl $190
801078bd:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801078c2:	e9 1d f2 ff ff       	jmp    80106ae4 <alltraps>

801078c7 <vector191>:
.globl vector191
vector191:
  pushl $0
801078c7:	6a 00                	push   $0x0
  pushl $191
801078c9:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801078ce:	e9 11 f2 ff ff       	jmp    80106ae4 <alltraps>

801078d3 <vector192>:
.globl vector192
vector192:
  pushl $0
801078d3:	6a 00                	push   $0x0
  pushl $192
801078d5:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801078da:	e9 05 f2 ff ff       	jmp    80106ae4 <alltraps>

801078df <vector193>:
.globl vector193
vector193:
  pushl $0
801078df:	6a 00                	push   $0x0
  pushl $193
801078e1:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801078e6:	e9 f9 f1 ff ff       	jmp    80106ae4 <alltraps>

801078eb <vector194>:
.globl vector194
vector194:
  pushl $0
801078eb:	6a 00                	push   $0x0
  pushl $194
801078ed:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801078f2:	e9 ed f1 ff ff       	jmp    80106ae4 <alltraps>

801078f7 <vector195>:
.globl vector195
vector195:
  pushl $0
801078f7:	6a 00                	push   $0x0
  pushl $195
801078f9:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801078fe:	e9 e1 f1 ff ff       	jmp    80106ae4 <alltraps>

80107903 <vector196>:
.globl vector196
vector196:
  pushl $0
80107903:	6a 00                	push   $0x0
  pushl $196
80107905:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010790a:	e9 d5 f1 ff ff       	jmp    80106ae4 <alltraps>

8010790f <vector197>:
.globl vector197
vector197:
  pushl $0
8010790f:	6a 00                	push   $0x0
  pushl $197
80107911:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107916:	e9 c9 f1 ff ff       	jmp    80106ae4 <alltraps>

8010791b <vector198>:
.globl vector198
vector198:
  pushl $0
8010791b:	6a 00                	push   $0x0
  pushl $198
8010791d:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107922:	e9 bd f1 ff ff       	jmp    80106ae4 <alltraps>

80107927 <vector199>:
.globl vector199
vector199:
  pushl $0
80107927:	6a 00                	push   $0x0
  pushl $199
80107929:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010792e:	e9 b1 f1 ff ff       	jmp    80106ae4 <alltraps>

80107933 <vector200>:
.globl vector200
vector200:
  pushl $0
80107933:	6a 00                	push   $0x0
  pushl $200
80107935:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010793a:	e9 a5 f1 ff ff       	jmp    80106ae4 <alltraps>

8010793f <vector201>:
.globl vector201
vector201:
  pushl $0
8010793f:	6a 00                	push   $0x0
  pushl $201
80107941:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107946:	e9 99 f1 ff ff       	jmp    80106ae4 <alltraps>

8010794b <vector202>:
.globl vector202
vector202:
  pushl $0
8010794b:	6a 00                	push   $0x0
  pushl $202
8010794d:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107952:	e9 8d f1 ff ff       	jmp    80106ae4 <alltraps>

80107957 <vector203>:
.globl vector203
vector203:
  pushl $0
80107957:	6a 00                	push   $0x0
  pushl $203
80107959:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010795e:	e9 81 f1 ff ff       	jmp    80106ae4 <alltraps>

80107963 <vector204>:
.globl vector204
vector204:
  pushl $0
80107963:	6a 00                	push   $0x0
  pushl $204
80107965:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010796a:	e9 75 f1 ff ff       	jmp    80106ae4 <alltraps>

8010796f <vector205>:
.globl vector205
vector205:
  pushl $0
8010796f:	6a 00                	push   $0x0
  pushl $205
80107971:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107976:	e9 69 f1 ff ff       	jmp    80106ae4 <alltraps>

8010797b <vector206>:
.globl vector206
vector206:
  pushl $0
8010797b:	6a 00                	push   $0x0
  pushl $206
8010797d:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107982:	e9 5d f1 ff ff       	jmp    80106ae4 <alltraps>

80107987 <vector207>:
.globl vector207
vector207:
  pushl $0
80107987:	6a 00                	push   $0x0
  pushl $207
80107989:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010798e:	e9 51 f1 ff ff       	jmp    80106ae4 <alltraps>

80107993 <vector208>:
.globl vector208
vector208:
  pushl $0
80107993:	6a 00                	push   $0x0
  pushl $208
80107995:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010799a:	e9 45 f1 ff ff       	jmp    80106ae4 <alltraps>

8010799f <vector209>:
.globl vector209
vector209:
  pushl $0
8010799f:	6a 00                	push   $0x0
  pushl $209
801079a1:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801079a6:	e9 39 f1 ff ff       	jmp    80106ae4 <alltraps>

801079ab <vector210>:
.globl vector210
vector210:
  pushl $0
801079ab:	6a 00                	push   $0x0
  pushl $210
801079ad:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801079b2:	e9 2d f1 ff ff       	jmp    80106ae4 <alltraps>

801079b7 <vector211>:
.globl vector211
vector211:
  pushl $0
801079b7:	6a 00                	push   $0x0
  pushl $211
801079b9:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801079be:	e9 21 f1 ff ff       	jmp    80106ae4 <alltraps>

801079c3 <vector212>:
.globl vector212
vector212:
  pushl $0
801079c3:	6a 00                	push   $0x0
  pushl $212
801079c5:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801079ca:	e9 15 f1 ff ff       	jmp    80106ae4 <alltraps>

801079cf <vector213>:
.globl vector213
vector213:
  pushl $0
801079cf:	6a 00                	push   $0x0
  pushl $213
801079d1:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801079d6:	e9 09 f1 ff ff       	jmp    80106ae4 <alltraps>

801079db <vector214>:
.globl vector214
vector214:
  pushl $0
801079db:	6a 00                	push   $0x0
  pushl $214
801079dd:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801079e2:	e9 fd f0 ff ff       	jmp    80106ae4 <alltraps>

801079e7 <vector215>:
.globl vector215
vector215:
  pushl $0
801079e7:	6a 00                	push   $0x0
  pushl $215
801079e9:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801079ee:	e9 f1 f0 ff ff       	jmp    80106ae4 <alltraps>

801079f3 <vector216>:
.globl vector216
vector216:
  pushl $0
801079f3:	6a 00                	push   $0x0
  pushl $216
801079f5:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801079fa:	e9 e5 f0 ff ff       	jmp    80106ae4 <alltraps>

801079ff <vector217>:
.globl vector217
vector217:
  pushl $0
801079ff:	6a 00                	push   $0x0
  pushl $217
80107a01:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107a06:	e9 d9 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a0b <vector218>:
.globl vector218
vector218:
  pushl $0
80107a0b:	6a 00                	push   $0x0
  pushl $218
80107a0d:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107a12:	e9 cd f0 ff ff       	jmp    80106ae4 <alltraps>

80107a17 <vector219>:
.globl vector219
vector219:
  pushl $0
80107a17:	6a 00                	push   $0x0
  pushl $219
80107a19:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107a1e:	e9 c1 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a23 <vector220>:
.globl vector220
vector220:
  pushl $0
80107a23:	6a 00                	push   $0x0
  pushl $220
80107a25:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107a2a:	e9 b5 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a2f <vector221>:
.globl vector221
vector221:
  pushl $0
80107a2f:	6a 00                	push   $0x0
  pushl $221
80107a31:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107a36:	e9 a9 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a3b <vector222>:
.globl vector222
vector222:
  pushl $0
80107a3b:	6a 00                	push   $0x0
  pushl $222
80107a3d:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a42:	e9 9d f0 ff ff       	jmp    80106ae4 <alltraps>

80107a47 <vector223>:
.globl vector223
vector223:
  pushl $0
80107a47:	6a 00                	push   $0x0
  pushl $223
80107a49:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a4e:	e9 91 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a53 <vector224>:
.globl vector224
vector224:
  pushl $0
80107a53:	6a 00                	push   $0x0
  pushl $224
80107a55:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a5a:	e9 85 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a5f <vector225>:
.globl vector225
vector225:
  pushl $0
80107a5f:	6a 00                	push   $0x0
  pushl $225
80107a61:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a66:	e9 79 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a6b <vector226>:
.globl vector226
vector226:
  pushl $0
80107a6b:	6a 00                	push   $0x0
  pushl $226
80107a6d:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a72:	e9 6d f0 ff ff       	jmp    80106ae4 <alltraps>

80107a77 <vector227>:
.globl vector227
vector227:
  pushl $0
80107a77:	6a 00                	push   $0x0
  pushl $227
80107a79:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a7e:	e9 61 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a83 <vector228>:
.globl vector228
vector228:
  pushl $0
80107a83:	6a 00                	push   $0x0
  pushl $228
80107a85:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a8a:	e9 55 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a8f <vector229>:
.globl vector229
vector229:
  pushl $0
80107a8f:	6a 00                	push   $0x0
  pushl $229
80107a91:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107a96:	e9 49 f0 ff ff       	jmp    80106ae4 <alltraps>

80107a9b <vector230>:
.globl vector230
vector230:
  pushl $0
80107a9b:	6a 00                	push   $0x0
  pushl $230
80107a9d:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107aa2:	e9 3d f0 ff ff       	jmp    80106ae4 <alltraps>

80107aa7 <vector231>:
.globl vector231
vector231:
  pushl $0
80107aa7:	6a 00                	push   $0x0
  pushl $231
80107aa9:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107aae:	e9 31 f0 ff ff       	jmp    80106ae4 <alltraps>

80107ab3 <vector232>:
.globl vector232
vector232:
  pushl $0
80107ab3:	6a 00                	push   $0x0
  pushl $232
80107ab5:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107aba:	e9 25 f0 ff ff       	jmp    80106ae4 <alltraps>

80107abf <vector233>:
.globl vector233
vector233:
  pushl $0
80107abf:	6a 00                	push   $0x0
  pushl $233
80107ac1:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107ac6:	e9 19 f0 ff ff       	jmp    80106ae4 <alltraps>

80107acb <vector234>:
.globl vector234
vector234:
  pushl $0
80107acb:	6a 00                	push   $0x0
  pushl $234
80107acd:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107ad2:	e9 0d f0 ff ff       	jmp    80106ae4 <alltraps>

80107ad7 <vector235>:
.globl vector235
vector235:
  pushl $0
80107ad7:	6a 00                	push   $0x0
  pushl $235
80107ad9:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107ade:	e9 01 f0 ff ff       	jmp    80106ae4 <alltraps>

80107ae3 <vector236>:
.globl vector236
vector236:
  pushl $0
80107ae3:	6a 00                	push   $0x0
  pushl $236
80107ae5:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107aea:	e9 f5 ef ff ff       	jmp    80106ae4 <alltraps>

80107aef <vector237>:
.globl vector237
vector237:
  pushl $0
80107aef:	6a 00                	push   $0x0
  pushl $237
80107af1:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107af6:	e9 e9 ef ff ff       	jmp    80106ae4 <alltraps>

80107afb <vector238>:
.globl vector238
vector238:
  pushl $0
80107afb:	6a 00                	push   $0x0
  pushl $238
80107afd:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107b02:	e9 dd ef ff ff       	jmp    80106ae4 <alltraps>

80107b07 <vector239>:
.globl vector239
vector239:
  pushl $0
80107b07:	6a 00                	push   $0x0
  pushl $239
80107b09:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107b0e:	e9 d1 ef ff ff       	jmp    80106ae4 <alltraps>

80107b13 <vector240>:
.globl vector240
vector240:
  pushl $0
80107b13:	6a 00                	push   $0x0
  pushl $240
80107b15:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107b1a:	e9 c5 ef ff ff       	jmp    80106ae4 <alltraps>

80107b1f <vector241>:
.globl vector241
vector241:
  pushl $0
80107b1f:	6a 00                	push   $0x0
  pushl $241
80107b21:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107b26:	e9 b9 ef ff ff       	jmp    80106ae4 <alltraps>

80107b2b <vector242>:
.globl vector242
vector242:
  pushl $0
80107b2b:	6a 00                	push   $0x0
  pushl $242
80107b2d:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107b32:	e9 ad ef ff ff       	jmp    80106ae4 <alltraps>

80107b37 <vector243>:
.globl vector243
vector243:
  pushl $0
80107b37:	6a 00                	push   $0x0
  pushl $243
80107b39:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b3e:	e9 a1 ef ff ff       	jmp    80106ae4 <alltraps>

80107b43 <vector244>:
.globl vector244
vector244:
  pushl $0
80107b43:	6a 00                	push   $0x0
  pushl $244
80107b45:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b4a:	e9 95 ef ff ff       	jmp    80106ae4 <alltraps>

80107b4f <vector245>:
.globl vector245
vector245:
  pushl $0
80107b4f:	6a 00                	push   $0x0
  pushl $245
80107b51:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b56:	e9 89 ef ff ff       	jmp    80106ae4 <alltraps>

80107b5b <vector246>:
.globl vector246
vector246:
  pushl $0
80107b5b:	6a 00                	push   $0x0
  pushl $246
80107b5d:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b62:	e9 7d ef ff ff       	jmp    80106ae4 <alltraps>

80107b67 <vector247>:
.globl vector247
vector247:
  pushl $0
80107b67:	6a 00                	push   $0x0
  pushl $247
80107b69:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b6e:	e9 71 ef ff ff       	jmp    80106ae4 <alltraps>

80107b73 <vector248>:
.globl vector248
vector248:
  pushl $0
80107b73:	6a 00                	push   $0x0
  pushl $248
80107b75:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b7a:	e9 65 ef ff ff       	jmp    80106ae4 <alltraps>

80107b7f <vector249>:
.globl vector249
vector249:
  pushl $0
80107b7f:	6a 00                	push   $0x0
  pushl $249
80107b81:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b86:	e9 59 ef ff ff       	jmp    80106ae4 <alltraps>

80107b8b <vector250>:
.globl vector250
vector250:
  pushl $0
80107b8b:	6a 00                	push   $0x0
  pushl $250
80107b8d:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b92:	e9 4d ef ff ff       	jmp    80106ae4 <alltraps>

80107b97 <vector251>:
.globl vector251
vector251:
  pushl $0
80107b97:	6a 00                	push   $0x0
  pushl $251
80107b99:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107b9e:	e9 41 ef ff ff       	jmp    80106ae4 <alltraps>

80107ba3 <vector252>:
.globl vector252
vector252:
  pushl $0
80107ba3:	6a 00                	push   $0x0
  pushl $252
80107ba5:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107baa:	e9 35 ef ff ff       	jmp    80106ae4 <alltraps>

80107baf <vector253>:
.globl vector253
vector253:
  pushl $0
80107baf:	6a 00                	push   $0x0
  pushl $253
80107bb1:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107bb6:	e9 29 ef ff ff       	jmp    80106ae4 <alltraps>

80107bbb <vector254>:
.globl vector254
vector254:
  pushl $0
80107bbb:	6a 00                	push   $0x0
  pushl $254
80107bbd:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107bc2:	e9 1d ef ff ff       	jmp    80106ae4 <alltraps>

80107bc7 <vector255>:
.globl vector255
vector255:
  pushl $0
80107bc7:	6a 00                	push   $0x0
  pushl $255
80107bc9:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107bce:	e9 11 ef ff ff       	jmp    80106ae4 <alltraps>

80107bd3 <lgdt>:
{
80107bd3:	55                   	push   %ebp
80107bd4:	89 e5                	mov    %esp,%ebp
80107bd6:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bdc:	83 e8 01             	sub    $0x1,%eax
80107bdf:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107be3:	8b 45 08             	mov    0x8(%ebp),%eax
80107be6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107bea:	8b 45 08             	mov    0x8(%ebp),%eax
80107bed:	c1 e8 10             	shr    $0x10,%eax
80107bf0:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107bf4:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107bf7:	0f 01 10             	lgdtl  (%eax)
}
80107bfa:	90                   	nop
80107bfb:	c9                   	leave  
80107bfc:	c3                   	ret    

80107bfd <ltr>:
{
80107bfd:	55                   	push   %ebp
80107bfe:	89 e5                	mov    %esp,%ebp
80107c00:	83 ec 04             	sub    $0x4,%esp
80107c03:	8b 45 08             	mov    0x8(%ebp),%eax
80107c06:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107c0a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107c0e:	0f 00 d8             	ltr    %ax
}
80107c11:	90                   	nop
80107c12:	c9                   	leave  
80107c13:	c3                   	ret    

80107c14 <lcr3>:

static inline void
lcr3(uint val)
{
80107c14:	55                   	push   %ebp
80107c15:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107c17:	8b 45 08             	mov    0x8(%ebp),%eax
80107c1a:	0f 22 d8             	mov    %eax,%cr3
}
80107c1d:	90                   	nop
80107c1e:	5d                   	pop    %ebp
80107c1f:	c3                   	ret    

80107c20 <removepage>:
#include "mmu.h"
#include "proc.h"
#include "elf.h"


int removepage(char* va) {
80107c20:	f3 0f 1e fb          	endbr32 
80107c24:	55                   	push   %ebp
80107c25:	89 e5                	mov    %esp,%ebp
80107c27:	53                   	push   %ebx
80107c28:	83 ec 14             	sub    $0x14,%esp
cprintf("in remvoe page %p ",va);
80107c2b:	83 ec 08             	sub    $0x8,%esp
80107c2e:	ff 75 08             	pushl  0x8(%ebp)
80107c31:	68 f8 99 10 80       	push   $0x801099f8
80107c36:	e8 dd 87 ff ff       	call   80100418 <cprintf>
80107c3b:	83 c4 10             	add    $0x10,%esp
  // panic("wloefbn");
  struct proc* curproc = myproc();
80107c3e:	e8 7d c8 ff ff       	call   801044c0 <myproc>
80107c43:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(int i = 0; i < CLOCKSIZE; i++){
80107c46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c4d:	e9 39 01 00 00       	jmp    80107d8b <removepage+0x16b>
    if(curproc->clock_queue[i].va == va){
80107c52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c55:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107c58:	83 c2 0e             	add    $0xe,%edx
80107c5b:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80107c5f:	39 45 08             	cmp    %eax,0x8(%ebp)
80107c62:	0f 85 1f 01 00 00    	jne    80107d87 <removepage+0x167>

    for(int j = i; j+1 < curproc->queue_size; j++){
80107c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c6e:	eb 47                	jmp    80107cb7 <removepage+0x97>
       curproc->clock_queue[j] = curproc->clock_queue[j+1];
80107c70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c73:	8d 50 01             	lea    0x1(%eax),%edx
80107c76:	8b 4d e8             	mov    -0x18(%ebp),%ecx
80107c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c7c:	8d 58 0e             	lea    0xe(%eax),%ebx
80107c7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c82:	83 c2 0e             	add    $0xe,%edx
80107c85:	8d 54 d0 0c          	lea    0xc(%eax,%edx,8),%edx
80107c89:	8b 02                	mov    (%edx),%eax
80107c8b:	8b 52 04             	mov    0x4(%edx),%edx
80107c8e:	89 44 d9 0c          	mov    %eax,0xc(%ecx,%ebx,8)
80107c92:	89 54 d9 10          	mov    %edx,0x10(%ecx,%ebx,8)
       curproc->clock_queue[j].va = curproc->clock_queue[j+1].va;
80107c96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c99:	8d 50 01             	lea    0x1(%eax),%edx
80107c9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c9f:	83 c2 0e             	add    $0xe,%edx
80107ca2:	8b 54 d0 0c          	mov    0xc(%eax,%edx,8),%edx
80107ca6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ca9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80107cac:	83 c1 0e             	add    $0xe,%ecx
80107caf:	89 54 c8 0c          	mov    %edx,0xc(%eax,%ecx,8)
    for(int j = i; j+1 < curproc->queue_size; j++){
80107cb3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80107cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cba:	8d 50 01             	lea    0x1(%eax),%edx
80107cbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107cc0:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80107cc6:	39 c2                	cmp    %eax,%edx
80107cc8:	7c a6                	jl     80107c70 <removepage+0x50>
    }
    // curproc->clock_queue[curproc->queue_size-1].va = 0;

     curproc->queue_size--;
80107cca:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ccd:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80107cd3:	8d 50 ff             	lea    -0x1(%eax),%edx
80107cd6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107cd9:	89 90 bc 00 00 00    	mov    %edx,0xbc(%eax)

     if( curproc->hand > i)
80107cdf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ce2:	8b 80 c4 00 00 00    	mov    0xc4(%eax),%eax
80107ce8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80107ceb:	7d 15                	jge    80107d02 <removepage+0xe2>
       curproc->hand = curproc->hand - 1;
80107ced:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107cf0:	8b 80 c4 00 00 00    	mov    0xc4(%eax),%eax
80107cf6:	8d 50 ff             	lea    -0x1(%eax),%edx
80107cf9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107cfc:	89 90 c4 00 00 00    	mov    %edx,0xc4(%eax)
     if(curproc->hand==curproc->queue_size){
80107d02:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d05:	8b 90 c4 00 00 00    	mov    0xc4(%eax),%edx
80107d0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d0e:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80107d14:	39 c2                	cmp    %eax,%edx
80107d16:	75 0d                	jne    80107d25 <removepage+0x105>
       curproc->hand=0;
80107d18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d1b:	c7 80 c4 00 00 00 00 	movl   $0x0,0xc4(%eax)
80107d22:	00 00 00 
     }
     cprintf("hand %d ",curproc->hand);
80107d25:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d28:	8b 80 c4 00 00 00    	mov    0xc4(%eax),%eax
80107d2e:	83 ec 08             	sub    $0x8,%esp
80107d31:	50                   	push   %eax
80107d32:	68 0b 9a 10 80       	push   $0x80109a0b
80107d37:	e8 dc 86 ff ff       	call   80100418 <cprintf>
80107d3c:	83 c4 10             	add    $0x10,%esp
         for (int i=0; i<CLOCKSIZE;i++){
80107d3f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80107d46:	eb 22                	jmp    80107d6a <removepage+0x14a>
      cprintf(" value %p ",curproc->clock_queue[i].va);
80107d48:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d4b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107d4e:	83 c2 0e             	add    $0xe,%edx
80107d51:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80107d55:	83 ec 08             	sub    $0x8,%esp
80107d58:	50                   	push   %eax
80107d59:	68 14 9a 10 80       	push   $0x80109a14
80107d5e:	e8 b5 86 ff ff       	call   80100418 <cprintf>
80107d63:	83 c4 10             	add    $0x10,%esp
         for (int i=0; i<CLOCKSIZE;i++){
80107d66:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80107d6a:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80107d6e:	7e d8                	jle    80107d48 <removepage+0x128>
      
    }
    cprintf("\n");
80107d70:	83 ec 0c             	sub    $0xc,%esp
80107d73:	68 1f 9a 10 80       	push   $0x80109a1f
80107d78:	e8 9b 86 ff ff       	call   80100418 <cprintf>
80107d7d:	83 c4 10             	add    $0x10,%esp
     return 0;
80107d80:	b8 00 00 00 00       	mov    $0x0,%eax
80107d85:	eb 13                	jmp    80107d9a <removepage+0x17a>
  for(int i = 0; i < CLOCKSIZE; i++){
80107d87:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107d8b:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80107d8f:	0f 8e bd fe ff ff    	jle    80107c52 <removepage+0x32>
   }
 }
 return 0;
80107d95:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107d9d:	c9                   	leave  
80107d9e:	c3                   	ret    

80107d9f <inwset>:
//   }
//   return 0;
// }


int inwset(char* va){
80107d9f:	f3 0f 1e fb          	endbr32 
80107da3:	55                   	push   %ebp
80107da4:	89 e5                	mov    %esp,%ebp
80107da6:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80107da9:	e8 12 c7 ff ff       	call   801044c0 <myproc>
80107dae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // int count=0;
  for(int i = 0; i < curproc->queue_size; i++){
80107db1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107db8:	eb 1d                	jmp    80107dd7 <inwset+0x38>
    if(curproc->clock_queue[i].va == va){
80107dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dbd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107dc0:	83 c2 0e             	add    $0xe,%edx
80107dc3:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80107dc7:	39 45 08             	cmp    %eax,0x8(%ebp)
80107dca:	75 07                	jne    80107dd3 <inwset+0x34>
      // cprintf("Found %p", va);
      return 1;
80107dcc:	b8 01 00 00 00       	mov    $0x1,%eax
80107dd1:	eb 17                	jmp    80107dea <inwset+0x4b>
  for(int i = 0; i < curproc->queue_size; i++){
80107dd3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dda:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80107de0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80107de3:	7c d5                	jl     80107dba <inwset+0x1b>
    }
  }
  return 0;
80107de5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107dea:	c9                   	leave  
80107deb:	c3                   	ret    

80107dec <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107dec:	f3 0f 1e fb          	endbr32 
80107df0:	55                   	push   %ebp
80107df1:	89 e5                	mov    %esp,%ebp
80107df3:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107df6:	e8 2a c6 ff ff       	call   80104425 <cpuid>
80107dfb:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107e01:	05 20 48 11 80       	add    $0x80114820,%eax
80107e06:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0c:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e15:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1e:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e25:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e29:	83 e2 f0             	and    $0xfffffff0,%edx
80107e2c:	83 ca 0a             	or     $0xa,%edx
80107e2f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e35:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e39:	83 ca 10             	or     $0x10,%edx
80107e3c:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e42:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e46:	83 e2 9f             	and    $0xffffff9f,%edx
80107e49:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e53:	83 ca 80             	or     $0xffffff80,%edx
80107e56:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e60:	83 ca 0f             	or     $0xf,%edx
80107e63:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e69:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e6d:	83 e2 ef             	and    $0xffffffef,%edx
80107e70:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e76:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e7a:	83 e2 df             	and    $0xffffffdf,%edx
80107e7d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e83:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e87:	83 ca 40             	or     $0x40,%edx
80107e8a:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e90:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e94:	83 ca 80             	or     $0xffffff80,%edx
80107e97:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9d:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea4:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107eab:	ff ff 
80107ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb0:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107eb7:	00 00 
80107eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebc:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ecd:	83 e2 f0             	and    $0xfffffff0,%edx
80107ed0:	83 ca 02             	or     $0x2,%edx
80107ed3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107edc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ee3:	83 ca 10             	or     $0x10,%edx
80107ee6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eef:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ef6:	83 e2 9f             	and    $0xffffff9f,%edx
80107ef9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f02:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107f09:	83 ca 80             	or     $0xffffff80,%edx
80107f0c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f15:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f1c:	83 ca 0f             	or     $0xf,%edx
80107f1f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f28:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f2f:	83 e2 ef             	and    $0xffffffef,%edx
80107f32:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f3b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f42:	83 e2 df             	and    $0xffffffdf,%edx
80107f45:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f55:	83 ca 40             	or     $0x40,%edx
80107f58:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f61:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f68:	83 ca 80             	or     $0xffffff80,%edx
80107f6b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f74:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7e:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107f85:	ff ff 
80107f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8a:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107f91:	00 00 
80107f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f96:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107fa7:	83 e2 f0             	and    $0xfffffff0,%edx
80107faa:	83 ca 0a             	or     $0xa,%edx
80107fad:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107fbd:	83 ca 10             	or     $0x10,%edx
80107fc0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107fd0:	83 ca 60             	or     $0x60,%edx
80107fd3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fdc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107fe3:	83 ca 80             	or     $0xffffff80,%edx
80107fe6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fef:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ff6:	83 ca 0f             	or     $0xf,%edx
80107ff9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108002:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108009:	83 e2 ef             	and    $0xffffffef,%edx
8010800c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108012:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108015:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010801c:	83 e2 df             	and    $0xffffffdf,%edx
8010801f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108028:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010802f:	83 ca 40             	or     $0x40,%edx
80108032:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108042:	83 ca 80             	or     $0xffffff80,%edx
80108045:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010804b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804e:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108058:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010805f:	ff ff 
80108061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108064:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010806b:	00 00 
8010806d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108070:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010807a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108081:	83 e2 f0             	and    $0xfffffff0,%edx
80108084:	83 ca 02             	or     $0x2,%edx
80108087:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010808d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108090:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108097:	83 ca 10             	or     $0x10,%edx
8010809a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801080a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801080aa:	83 ca 60             	or     $0x60,%edx
801080ad:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801080b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801080bd:	83 ca 80             	or     $0xffffff80,%edx
801080c0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801080c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801080d0:	83 ca 0f             	or     $0xf,%edx
801080d3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801080d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080dc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801080e3:	83 e2 ef             	and    $0xffffffef,%edx
801080e6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801080ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ef:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801080f6:	83 e2 df             	and    $0xffffffdf,%edx
801080f9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801080ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108102:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108109:	83 ca 40             	or     $0x40,%edx
8010810c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108115:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010811c:	83 ca 80             	or     $0xffffff80,%edx
8010811f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108128:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010812f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108132:	83 c0 70             	add    $0x70,%eax
80108135:	83 ec 08             	sub    $0x8,%esp
80108138:	6a 30                	push   $0x30
8010813a:	50                   	push   %eax
8010813b:	e8 93 fa ff ff       	call   80107bd3 <lgdt>
80108140:	83 c4 10             	add    $0x10,%esp
}
80108143:	90                   	nop
80108144:	c9                   	leave  
80108145:	c3                   	ret    

80108146 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108146:	f3 0f 1e fb          	endbr32 
8010814a:	55                   	push   %ebp
8010814b:	89 e5                	mov    %esp,%ebp
8010814d:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108150:	8b 45 0c             	mov    0xc(%ebp),%eax
80108153:	c1 e8 16             	shr    $0x16,%eax
80108156:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010815d:	8b 45 08             	mov    0x8(%ebp),%eax
80108160:	01 d0                	add    %edx,%eax
80108162:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){//No need to check PTE_E here.
80108165:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108168:	8b 00                	mov    (%eax),%eax
8010816a:	83 e0 01             	and    $0x1,%eax
8010816d:	85 c0                	test   %eax,%eax
8010816f:	74 14                	je     80108185 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80108171:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108174:	8b 00                	mov    (%eax),%eax
80108176:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010817b:	05 00 00 00 80       	add    $0x80000000,%eax
80108180:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108183:	eb 42                	jmp    801081c7 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108185:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108189:	74 0e                	je     80108199 <walkpgdir+0x53>
8010818b:	e8 92 ac ff ff       	call   80102e22 <kalloc>
80108190:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108193:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108197:	75 07                	jne    801081a0 <walkpgdir+0x5a>
      return 0;
80108199:	b8 00 00 00 00       	mov    $0x0,%eax
8010819e:	eb 3e                	jmp    801081de <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801081a0:	83 ec 04             	sub    $0x4,%esp
801081a3:	68 00 10 00 00       	push   $0x1000
801081a8:	6a 00                	push   $0x0
801081aa:	ff 75 f4             	pushl  -0xc(%ebp)
801081ad:	e8 c6 d3 ff ff       	call   80105578 <memset>
801081b2:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801081b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b8:	05 00 00 00 80       	add    $0x80000000,%eax
801081bd:	83 c8 07             	or     $0x7,%eax
801081c0:	89 c2                	mov    %eax,%edx
801081c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081c5:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801081c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801081ca:	c1 e8 0c             	shr    $0xc,%eax
801081cd:	25 ff 03 00 00       	and    $0x3ff,%eax
801081d2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801081d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081dc:	01 d0                	add    %edx,%eax
}
801081de:	c9                   	leave  
801081df:	c3                   	ret    

801081e0 <addtoworkingset>:

int addtoworkingset(char* va){
801081e0:	f3 0f 1e fb          	endbr32 
801081e4:	55                   	push   %ebp
801081e5:	89 e5                	mov    %esp,%ebp
801081e7:	53                   	push   %ebx
801081e8:	83 ec 24             	sub    $0x24,%esp
  struct proc* curproc = myproc();
801081eb:	e8 d0 c2 ff ff       	call   801044c0 <myproc>
801081f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  pte_t * curr_pte;
  cprintf(" page %p ",va);
801081f3:	83 ec 08             	sub    $0x8,%esp
801081f6:	ff 75 08             	pushl  0x8(%ebp)
801081f9:	68 21 9a 10 80       	push   $0x80109a21
801081fe:	e8 15 82 ff ff       	call   80100418 <cprintf>
80108203:	83 c4 10             	add    $0x10,%esp
  cprintf("hand %d ",curproc->hand);
80108206:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108209:	8b 80 c4 00 00 00    	mov    0xc4(%eax),%eax
8010820f:	83 ec 08             	sub    $0x8,%esp
80108212:	50                   	push   %eax
80108213:	68 0b 9a 10 80       	push   $0x80109a0b
80108218:	e8 fb 81 ff ff       	call   80100418 <cprintf>
8010821d:	83 c4 10             	add    $0x10,%esp
  cprintf("%d ",curproc->queue_size);
80108220:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108223:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108229:	83 ec 08             	sub    $0x8,%esp
8010822c:	50                   	push   %eax
8010822d:	68 2b 9a 10 80       	push   $0x80109a2b
80108232:	e8 e1 81 ff ff       	call   80100418 <cprintf>
80108237:	83 c4 10             	add    $0x10,%esp
  if(curproc->queue_size < CLOCKSIZE) {
8010823a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010823d:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108243:	83 f8 07             	cmp    $0x7,%eax
80108246:	0f 8f a8 01 00 00    	jg     801083f4 <addtoworkingset+0x214>
    // cprintf("queue size is %d",curproc->queue_size);
    // cprintf(" pid is %d",curproc->pid);
    // cprintf("parent pid is %d\n",curproc->parent->pid);

    curr_pte=walkpgdir(curproc->pgdir,curproc->clock_queue[curproc->hand].va,0);
8010824c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010824f:	8b 90 c4 00 00 00    	mov    0xc4(%eax),%edx
80108255:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108258:	83 c2 0e             	add    $0xe,%edx
8010825b:	8b 54 d0 0c          	mov    0xc(%eax,%edx,8),%edx
8010825f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108262:	8b 40 04             	mov    0x4(%eax),%eax
80108265:	83 ec 04             	sub    $0x4,%esp
80108268:	6a 00                	push   $0x0
8010826a:	52                   	push   %edx
8010826b:	50                   	push   %eax
8010826c:	e8 d5 fe ff ff       	call   80108146 <walkpgdir>
80108271:	83 c4 10             	add    $0x10,%esp
80108274:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((*curr_pte & PTE_E)==PTE_E){
80108277:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010827a:	8b 00                	mov    (%eax),%eax
8010827c:	25 00 04 00 00       	and    $0x400,%eax
80108281:	85 c0                	test   %eax,%eax
80108283:	74 1d                	je     801082a2 <addtoworkingset+0xc2>
      cprintf("error");
80108285:	83 ec 0c             	sub    $0xc,%esp
80108288:	68 2f 9a 10 80       	push   $0x80109a2f
8010828d:	e8 86 81 ff ff       	call   80100418 <cprintf>
80108292:	83 c4 10             	add    $0x10,%esp
      panic("error");
80108295:	83 ec 0c             	sub    $0xc,%esp
80108298:	68 2f 9a 10 80       	push   $0x80109a2f
8010829d:	e8 66 83 ff ff       	call   80100608 <panic>
    }
    curproc->queue_size++;
801082a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082a5:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
801082ab:	8d 50 01             	lea    0x1(%eax),%edx
801082ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082b1:	89 90 bc 00 00 00    	mov    %edx,0xbc(%eax)

    for(int i = curproc->queue_size - 1; i > (curproc->hand + curproc->queue_size - 1) % curproc->queue_size ; i--){
801082b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082ba:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
801082c0:	83 e8 01             	sub    $0x1,%eax
801082c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801082c6:	eb 7f                	jmp    80108347 <addtoworkingset+0x167>
      curproc->clock_queue[i] = curproc->clock_queue[i - 1];
801082c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082cb:	8d 50 ff             	lea    -0x1(%eax),%edx
801082ce:	8b 4d e8             	mov    -0x18(%ebp),%ecx
801082d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d4:	8d 58 0e             	lea    0xe(%eax),%ebx
801082d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082da:	83 c2 0e             	add    $0xe,%edx
801082dd:	8d 54 d0 0c          	lea    0xc(%eax,%edx,8),%edx
801082e1:	8b 02                	mov    (%edx),%eax
801082e3:	8b 52 04             	mov    0x4(%edx),%edx
801082e6:	89 44 d9 0c          	mov    %eax,0xc(%ecx,%ebx,8)
801082ea:	89 54 d9 10          	mov    %edx,0x10(%ecx,%ebx,8)
      if((curproc->hand + curproc->queue_size - 1) % curproc->queue_size < curproc->hand){
801082ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082f1:	8b 90 c4 00 00 00    	mov    0xc4(%eax),%edx
801082f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082fa:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108300:	01 d0                	add    %edx,%eax
80108302:	8d 50 ff             	lea    -0x1(%eax),%edx
80108305:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108308:	8b 88 bc 00 00 00    	mov    0xbc(%eax),%ecx
8010830e:	89 d0                	mov    %edx,%eax
80108310:	99                   	cltd   
80108311:	f7 f9                	idiv   %ecx
80108313:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108316:	8b 80 c4 00 00 00    	mov    0xc4(%eax),%eax
8010831c:	39 c2                	cmp    %eax,%edx
8010831e:	7d 23                	jge    80108343 <addtoworkingset+0x163>
        curproc->hand = (curproc->hand + 1) % curproc->queue_size;
80108320:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108323:	8b 80 c4 00 00 00    	mov    0xc4(%eax),%eax
80108329:	8d 50 01             	lea    0x1(%eax),%edx
8010832c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010832f:	8b 88 bc 00 00 00    	mov    0xbc(%eax),%ecx
80108335:	89 d0                	mov    %edx,%eax
80108337:	99                   	cltd   
80108338:	f7 f9                	idiv   %ecx
8010833a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010833d:	89 90 c4 00 00 00    	mov    %edx,0xc4(%eax)
    for(int i = curproc->queue_size - 1; i > (curproc->hand + curproc->queue_size - 1) % curproc->queue_size ; i--){
80108343:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80108347:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010834a:	8b 90 c4 00 00 00    	mov    0xc4(%eax),%edx
80108350:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108353:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108359:	01 d0                	add    %edx,%eax
8010835b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010835e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108361:	8b 88 bc 00 00 00    	mov    0xbc(%eax),%ecx
80108367:	89 d0                	mov    %edx,%eax
80108369:	99                   	cltd   
8010836a:	f7 f9                	idiv   %ecx
8010836c:	89 d0                	mov    %edx,%eax
8010836e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80108371:	0f 8f 51 ff ff ff    	jg     801082c8 <addtoworkingset+0xe8>
      }
    }
   
    curproc->clock_queue[(curproc->hand + curproc->queue_size - 1) % curproc->queue_size].va = va;
80108377:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010837a:	8b 90 c4 00 00 00    	mov    0xc4(%eax),%edx
80108380:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108383:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108389:	01 d0                	add    %edx,%eax
8010838b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010838e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108391:	8b 88 bc 00 00 00    	mov    0xbc(%eax),%ecx
80108397:	89 d0                	mov    %edx,%eax
80108399:	99                   	cltd   
8010839a:	f7 f9                	idiv   %ecx
8010839c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010839f:	8d 4a 0e             	lea    0xe(%edx),%ecx
801083a2:	8b 55 08             	mov    0x8(%ebp),%edx
801083a5:	89 54 c8 0c          	mov    %edx,0xc(%eax,%ecx,8)
    for (int i=0; i<CLOCKSIZE;i++){
801083a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801083b0:	eb 22                	jmp    801083d4 <addtoworkingset+0x1f4>
      cprintf(" value %p ",curproc->clock_queue[i].va);
801083b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801083b8:	83 c2 0e             	add    $0xe,%edx
801083bb:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
801083bf:	83 ec 08             	sub    $0x8,%esp
801083c2:	50                   	push   %eax
801083c3:	68 14 9a 10 80       	push   $0x80109a14
801083c8:	e8 4b 80 ff ff       	call   80100418 <cprintf>
801083cd:	83 c4 10             	add    $0x10,%esp
    for (int i=0; i<CLOCKSIZE;i++){
801083d0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801083d4:	83 7d f0 07          	cmpl   $0x7,-0x10(%ebp)
801083d8:	7e d8                	jle    801083b2 <addtoworkingset+0x1d2>
      
    }
    cprintf("\n");
801083da:	83 ec 0c             	sub    $0xc,%esp
801083dd:	68 1f 9a 10 80       	push   $0x80109a1f
801083e2:	e8 31 80 ff ff       	call   80100418 <cprintf>
801083e7:	83 c4 10             	add    $0x10,%esp
    return 0;
801083ea:	b8 00 00 00 00       	mov    $0x0,%eax
801083ef:	e9 16 01 00 00       	jmp    8010850a <addtoworkingset+0x32a>

  while(1) {
    // cprintf("error");
    pte_t * curr_pte;
    //struct clock_queue_slot* cur_hand = &curproc->clock_queue[curproc->hand];
    curr_pte=walkpgdir(curproc->pgdir,curproc->clock_queue[curproc->hand].va,0);
801083f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083f7:	8b 90 c4 00 00 00    	mov    0xc4(%eax),%edx
801083fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108400:	83 c2 0e             	add    $0xe,%edx
80108403:	8b 54 d0 0c          	mov    0xc(%eax,%edx,8),%edx
80108407:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010840a:	8b 40 04             	mov    0x4(%eax),%eax
8010840d:	83 ec 04             	sub    $0x4,%esp
80108410:	6a 00                	push   $0x0
80108412:	52                   	push   %edx
80108413:	50                   	push   %eax
80108414:	e8 2d fd ff ff       	call   80108146 <walkpgdir>
80108419:	83 c4 10             	add    $0x10,%esp
8010841c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(!((*curr_pte & PTE_A) == PTE_A)){  
8010841f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108422:	8b 00                	mov    (%eax),%eax
80108424:	83 e0 20             	and    $0x20,%eax
80108427:	85 c0                	test   %eax,%eax
80108429:	74 39                	je     80108464 <addtoworkingset+0x284>
      break;
    }
    *curr_pte = *curr_pte & ~PTE_A;
8010842b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010842e:	8b 00                	mov    (%eax),%eax
80108430:	83 e0 df             	and    $0xffffffdf,%eax
80108433:	89 c2                	mov    %eax,%edx
80108435:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108438:	89 10                	mov    %edx,(%eax)
    // curproc->clock_queue[curproc->hand].abit = 0;
    //cprintf("hand before  is %d",curproc->hand);
    curproc->hand = (curproc->hand + 1) % CLOCKSIZE;
8010843a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010843d:	8b 80 c4 00 00 00    	mov    0xc4(%eax),%eax
80108443:	8d 50 01             	lea    0x1(%eax),%edx
80108446:	89 d0                	mov    %edx,%eax
80108448:	c1 f8 1f             	sar    $0x1f,%eax
8010844b:	c1 e8 1d             	shr    $0x1d,%eax
8010844e:	01 c2                	add    %eax,%edx
80108450:	83 e2 07             	and    $0x7,%edx
80108453:	29 c2                	sub    %eax,%edx
80108455:	89 d0                	mov    %edx,%eax
80108457:	89 c2                	mov    %eax,%edx
80108459:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010845c:	89 90 c4 00 00 00    	mov    %edx,0xc4(%eax)
  while(1) {
80108462:	eb 90                	jmp    801083f4 <addtoworkingset+0x214>
      break;
80108464:	90                   	nop
  }
  mencrypt(curproc->clock_queue[curproc->hand].va, 1);
80108465:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108468:	8b 90 c4 00 00 00    	mov    0xc4(%eax),%edx
8010846e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108471:	83 c2 0e             	add    $0xe,%edx
80108474:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80108478:	83 ec 08             	sub    $0x8,%esp
8010847b:	6a 01                	push   $0x1
8010847d:	50                   	push   %eax
8010847e:	e8 d6 0a 00 00       	call   80108f59 <mencrypt>
80108483:	83 c4 10             	add    $0x10,%esp
  //cprintf("hand is %d",curproc->hand);
  curproc->clock_queue[curproc->hand].va = va;
80108486:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108489:	8b 90 c4 00 00 00    	mov    0xc4(%eax),%edx
8010848f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108492:	8d 4a 0e             	lea    0xe(%edx),%ecx
80108495:	8b 55 08             	mov    0x8(%ebp),%edx
80108498:	89 54 c8 0c          	mov    %edx,0xc(%eax,%ecx,8)
  curproc->hand = (curproc->hand + 1) % CLOCKSIZE;
8010849c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010849f:	8b 80 c4 00 00 00    	mov    0xc4(%eax),%eax
801084a5:	8d 50 01             	lea    0x1(%eax),%edx
801084a8:	89 d0                	mov    %edx,%eax
801084aa:	c1 f8 1f             	sar    $0x1f,%eax
801084ad:	c1 e8 1d             	shr    $0x1d,%eax
801084b0:	01 c2                	add    %eax,%edx
801084b2:	83 e2 07             	and    $0x7,%edx
801084b5:	29 c2                	sub    %eax,%edx
801084b7:	89 d0                	mov    %edx,%eax
801084b9:	89 c2                	mov    %eax,%edx
801084bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084be:	89 90 c4 00 00 00    	mov    %edx,0xc4(%eax)
    for (int i=0; i<CLOCKSIZE;i++){
801084c4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801084cb:	eb 22                	jmp    801084ef <addtoworkingset+0x30f>
      cprintf(" value %p ",curproc->clock_queue[i].va);
801084cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801084d3:	83 c2 0e             	add    $0xe,%edx
801084d6:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
801084da:	83 ec 08             	sub    $0x8,%esp
801084dd:	50                   	push   %eax
801084de:	68 14 9a 10 80       	push   $0x80109a14
801084e3:	e8 30 7f ff ff       	call   80100418 <cprintf>
801084e8:	83 c4 10             	add    $0x10,%esp
    for (int i=0; i<CLOCKSIZE;i++){
801084eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801084ef:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801084f3:	7e d8                	jle    801084cd <addtoworkingset+0x2ed>
      
    }
    cprintf("\n");
801084f5:	83 ec 0c             	sub    $0xc,%esp
801084f8:	68 1f 9a 10 80       	push   $0x80109a1f
801084fd:	e8 16 7f ff ff       	call   80100418 <cprintf>
80108502:	83 c4 10             	add    $0x10,%esp
  return 0;
80108505:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010850a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010850d:	c9                   	leave  
8010850e:	c3                   	ret    

8010850f <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010850f:	f3 0f 1e fb          	endbr32 
80108513:	55                   	push   %ebp
80108514:	89 e5                	mov    %esp,%ebp
80108516:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80108519:	8b 45 0c             	mov    0xc(%ebp),%eax
8010851c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108521:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108524:	8b 55 0c             	mov    0xc(%ebp),%edx
80108527:	8b 45 10             	mov    0x10(%ebp),%eax
8010852a:	01 d0                	add    %edx,%eax
8010852c:	83 e8 01             	sub    $0x1,%eax
8010852f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108534:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108537:	83 ec 04             	sub    $0x4,%esp
8010853a:	6a 01                	push   $0x1
8010853c:	ff 75 f4             	pushl  -0xc(%ebp)
8010853f:	ff 75 08             	pushl  0x8(%ebp)
80108542:	e8 ff fb ff ff       	call   80108146 <walkpgdir>
80108547:	83 c4 10             	add    $0x10,%esp
8010854a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010854d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108551:	75 0a                	jne    8010855d <mappages+0x4e>
      return -1;
80108553:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108558:	e9 99 00 00 00       	jmp    801085f6 <mappages+0xe7>
    if(*pte & (PTE_P | PTE_E))
8010855d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108560:	8b 00                	mov    (%eax),%eax
80108562:	25 01 04 00 00       	and    $0x401,%eax
80108567:	85 c0                	test   %eax,%eax
80108569:	74 0d                	je     80108578 <mappages+0x69>
      panic("remap");
8010856b:	83 ec 0c             	sub    $0xc,%esp
8010856e:	68 35 9a 10 80       	push   $0x80109a35
80108573:	e8 90 80 ff ff       	call   80100608 <panic>
    
    //"perm" is just the lower 12 bits of the PTE
    //if encrypted, then ensure that PTE_P is not set
    //This is somewhat redundant. If our code is correct,
    //we should just be able to say pa | perm
    if (perm & PTE_E)
80108578:	8b 45 18             	mov    0x18(%ebp),%eax
8010857b:	25 00 04 00 00       	and    $0x400,%eax
80108580:	85 c0                	test   %eax,%eax
80108582:	74 17                	je     8010859b <mappages+0x8c>
      *pte = (pa | perm | PTE_E ) & ~PTE_P ;
80108584:	8b 45 18             	mov    0x18(%ebp),%eax
80108587:	0b 45 14             	or     0x14(%ebp),%eax
8010858a:	25 fe fb ff ff       	and    $0xfffffbfe,%eax
8010858f:	80 cc 04             	or     $0x4,%ah
80108592:	89 c2                	mov    %eax,%edx
80108594:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108597:	89 10                	mov    %edx,(%eax)
80108599:	eb 10                	jmp    801085ab <mappages+0x9c>
    else
      *pte = pa | perm | PTE_P;
8010859b:	8b 45 18             	mov    0x18(%ebp),%eax
8010859e:	0b 45 14             	or     0x14(%ebp),%eax
801085a1:	83 c8 01             	or     $0x1,%eax
801085a4:	89 c2                	mov    %eax,%edx
801085a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085a9:	89 10                	mov    %edx,(%eax)
    if((perm & PTE_A) == PTE_A){
801085ab:	8b 45 18             	mov    0x18(%ebp),%eax
801085ae:	83 e0 20             	and    $0x20,%eax
801085b1:	85 c0                	test   %eax,%eax
801085b3:	74 11                	je     801085c6 <mappages+0xb7>
      *pte = *pte | PTE_A;
801085b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085b8:	8b 00                	mov    (%eax),%eax
801085ba:	83 c8 20             	or     $0x20,%eax
801085bd:	89 c2                	mov    %eax,%edx
801085bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085c2:	89 10                	mov    %edx,(%eax)
801085c4:	eb 0f                	jmp    801085d5 <mappages+0xc6>
    }
    else{
      *pte = *pte & ~PTE_A;
801085c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085c9:	8b 00                	mov    (%eax),%eax
801085cb:	83 e0 df             	and    $0xffffffdf,%eax
801085ce:	89 c2                	mov    %eax,%edx
801085d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085d3:	89 10                	mov    %edx,(%eax)
    }

    if(a == last)
801085d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801085db:	74 13                	je     801085f0 <mappages+0xe1>
      break;
    a += PGSIZE;
801085dd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801085e4:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801085eb:	e9 47 ff ff ff       	jmp    80108537 <mappages+0x28>
      break;
801085f0:	90                   	nop
  }
  return 0;
801085f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085f6:	c9                   	leave  
801085f7:	c3                   	ret    

801085f8 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801085f8:	f3 0f 1e fb          	endbr32 
801085fc:	55                   	push   %ebp
801085fd:	89 e5                	mov    %esp,%ebp
801085ff:	53                   	push   %ebx
80108600:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108603:	e8 1a a8 ff ff       	call   80102e22 <kalloc>
80108608:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010860b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010860f:	75 07                	jne    80108618 <setupkvm+0x20>
    return 0;
80108611:	b8 00 00 00 00       	mov    $0x0,%eax
80108616:	eb 78                	jmp    80108690 <setupkvm+0x98>
  memset(pgdir, 0, PGSIZE);
80108618:	83 ec 04             	sub    $0x4,%esp
8010861b:	68 00 10 00 00       	push   $0x1000
80108620:	6a 00                	push   $0x0
80108622:	ff 75 f0             	pushl  -0x10(%ebp)
80108625:	e8 4e cf ff ff       	call   80105578 <memset>
8010862a:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010862d:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108634:	eb 4e                	jmp    80108684 <setupkvm+0x8c>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108636:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108639:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010863c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863f:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108645:	8b 58 08             	mov    0x8(%eax),%ebx
80108648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864b:	8b 40 04             	mov    0x4(%eax),%eax
8010864e:	29 c3                	sub    %eax,%ebx
80108650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108653:	8b 00                	mov    (%eax),%eax
80108655:	83 ec 0c             	sub    $0xc,%esp
80108658:	51                   	push   %ecx
80108659:	52                   	push   %edx
8010865a:	53                   	push   %ebx
8010865b:	50                   	push   %eax
8010865c:	ff 75 f0             	pushl  -0x10(%ebp)
8010865f:	e8 ab fe ff ff       	call   8010850f <mappages>
80108664:	83 c4 20             	add    $0x20,%esp
80108667:	85 c0                	test   %eax,%eax
80108669:	79 15                	jns    80108680 <setupkvm+0x88>
      freevm(pgdir);
8010866b:	83 ec 0c             	sub    $0xc,%esp
8010866e:	ff 75 f0             	pushl  -0x10(%ebp)
80108671:	e8 26 05 00 00       	call   80108b9c <freevm>
80108676:	83 c4 10             	add    $0x10,%esp
      return 0;
80108679:	b8 00 00 00 00       	mov    $0x0,%eax
8010867e:	eb 10                	jmp    80108690 <setupkvm+0x98>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108680:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108684:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
8010868b:	72 a9                	jb     80108636 <setupkvm+0x3e>
    }
  return pgdir;
8010868d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108690:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108693:	c9                   	leave  
80108694:	c3                   	ret    

80108695 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108695:	f3 0f 1e fb          	endbr32 
80108699:	55                   	push   %ebp
8010869a:	89 e5                	mov    %esp,%ebp
8010869c:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010869f:	e8 54 ff ff ff       	call   801085f8 <setupkvm>
801086a4:	a3 44 88 11 80       	mov    %eax,0x80118844
  switchkvm();
801086a9:	e8 03 00 00 00       	call   801086b1 <switchkvm>
}
801086ae:	90                   	nop
801086af:	c9                   	leave  
801086b0:	c3                   	ret    

801086b1 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801086b1:	f3 0f 1e fb          	endbr32 
801086b5:	55                   	push   %ebp
801086b6:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801086b8:	a1 44 88 11 80       	mov    0x80118844,%eax
801086bd:	05 00 00 00 80       	add    $0x80000000,%eax
801086c2:	50                   	push   %eax
801086c3:	e8 4c f5 ff ff       	call   80107c14 <lcr3>
801086c8:	83 c4 04             	add    $0x4,%esp
}
801086cb:	90                   	nop
801086cc:	c9                   	leave  
801086cd:	c3                   	ret    

801086ce <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801086ce:	f3 0f 1e fb          	endbr32 
801086d2:	55                   	push   %ebp
801086d3:	89 e5                	mov    %esp,%ebp
801086d5:	56                   	push   %esi
801086d6:	53                   	push   %ebx
801086d7:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801086da:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801086de:	75 0d                	jne    801086ed <switchuvm+0x1f>
    panic("switchuvm: no process");
801086e0:	83 ec 0c             	sub    $0xc,%esp
801086e3:	68 3b 9a 10 80       	push   $0x80109a3b
801086e8:	e8 1b 7f ff ff       	call   80100608 <panic>
  if(p->kstack == 0)
801086ed:	8b 45 08             	mov    0x8(%ebp),%eax
801086f0:	8b 40 08             	mov    0x8(%eax),%eax
801086f3:	85 c0                	test   %eax,%eax
801086f5:	75 0d                	jne    80108704 <switchuvm+0x36>
    panic("switchuvm: no kstack");
801086f7:	83 ec 0c             	sub    $0xc,%esp
801086fa:	68 51 9a 10 80       	push   $0x80109a51
801086ff:	e8 04 7f ff ff       	call   80100608 <panic>
  if(p->pgdir == 0)
80108704:	8b 45 08             	mov    0x8(%ebp),%eax
80108707:	8b 40 04             	mov    0x4(%eax),%eax
8010870a:	85 c0                	test   %eax,%eax
8010870c:	75 0d                	jne    8010871b <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
8010870e:	83 ec 0c             	sub    $0xc,%esp
80108711:	68 66 9a 10 80       	push   $0x80109a66
80108716:	e8 ed 7e ff ff       	call   80100608 <panic>

  pushcli();
8010871b:	e8 45 cd ff ff       	call   80105465 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108720:	e8 1f bd ff ff       	call   80104444 <mycpu>
80108725:	89 c3                	mov    %eax,%ebx
80108727:	e8 18 bd ff ff       	call   80104444 <mycpu>
8010872c:	83 c0 08             	add    $0x8,%eax
8010872f:	89 c6                	mov    %eax,%esi
80108731:	e8 0e bd ff ff       	call   80104444 <mycpu>
80108736:	83 c0 08             	add    $0x8,%eax
80108739:	c1 e8 10             	shr    $0x10,%eax
8010873c:	88 45 f7             	mov    %al,-0x9(%ebp)
8010873f:	e8 00 bd ff ff       	call   80104444 <mycpu>
80108744:	83 c0 08             	add    $0x8,%eax
80108747:	c1 e8 18             	shr    $0x18,%eax
8010874a:	89 c2                	mov    %eax,%edx
8010874c:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108753:	67 00 
80108755:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010875c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80108760:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80108766:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010876d:	83 e0 f0             	and    $0xfffffff0,%eax
80108770:	83 c8 09             	or     $0x9,%eax
80108773:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108779:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108780:	83 c8 10             	or     $0x10,%eax
80108783:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108789:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108790:	83 e0 9f             	and    $0xffffff9f,%eax
80108793:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108799:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801087a0:	83 c8 80             	or     $0xffffff80,%eax
801087a3:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801087a9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801087b0:	83 e0 f0             	and    $0xfffffff0,%eax
801087b3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801087b9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801087c0:	83 e0 ef             	and    $0xffffffef,%eax
801087c3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801087c9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801087d0:	83 e0 df             	and    $0xffffffdf,%eax
801087d3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801087d9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801087e0:	83 c8 40             	or     $0x40,%eax
801087e3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801087e9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801087f0:	83 e0 7f             	and    $0x7f,%eax
801087f3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801087f9:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801087ff:	e8 40 bc ff ff       	call   80104444 <mycpu>
80108804:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010880b:	83 e2 ef             	and    $0xffffffef,%edx
8010880e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108814:	e8 2b bc ff ff       	call   80104444 <mycpu>
80108819:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010881f:	8b 45 08             	mov    0x8(%ebp),%eax
80108822:	8b 40 08             	mov    0x8(%eax),%eax
80108825:	89 c3                	mov    %eax,%ebx
80108827:	e8 18 bc ff ff       	call   80104444 <mycpu>
8010882c:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80108832:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108835:	e8 0a bc ff ff       	call   80104444 <mycpu>
8010883a:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108840:	83 ec 0c             	sub    $0xc,%esp
80108843:	6a 28                	push   $0x28
80108845:	e8 b3 f3 ff ff       	call   80107bfd <ltr>
8010884a:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010884d:	8b 45 08             	mov    0x8(%ebp),%eax
80108850:	8b 40 04             	mov    0x4(%eax),%eax
80108853:	05 00 00 00 80       	add    $0x80000000,%eax
80108858:	83 ec 0c             	sub    $0xc,%esp
8010885b:	50                   	push   %eax
8010885c:	e8 b3 f3 ff ff       	call   80107c14 <lcr3>
80108861:	83 c4 10             	add    $0x10,%esp
  popcli();
80108864:	e8 4d cc ff ff       	call   801054b6 <popcli>
}
80108869:	90                   	nop
8010886a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010886d:	5b                   	pop    %ebx
8010886e:	5e                   	pop    %esi
8010886f:	5d                   	pop    %ebp
80108870:	c3                   	ret    

80108871 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108871:	f3 0f 1e fb          	endbr32 
80108875:	55                   	push   %ebp
80108876:	89 e5                	mov    %esp,%ebp
80108878:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010887b:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108882:	76 0d                	jbe    80108891 <inituvm+0x20>
    panic("inituvm: more than a page");
80108884:	83 ec 0c             	sub    $0xc,%esp
80108887:	68 7a 9a 10 80       	push   $0x80109a7a
8010888c:	e8 77 7d ff ff       	call   80100608 <panic>
  mem = kalloc();
80108891:	e8 8c a5 ff ff       	call   80102e22 <kalloc>
80108896:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108899:	83 ec 04             	sub    $0x4,%esp
8010889c:	68 00 10 00 00       	push   $0x1000
801088a1:	6a 00                	push   $0x0
801088a3:	ff 75 f4             	pushl  -0xc(%ebp)
801088a6:	e8 cd cc ff ff       	call   80105578 <memset>
801088ab:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801088ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b1:	05 00 00 00 80       	add    $0x80000000,%eax
801088b6:	83 ec 0c             	sub    $0xc,%esp
801088b9:	6a 06                	push   $0x6
801088bb:	50                   	push   %eax
801088bc:	68 00 10 00 00       	push   $0x1000
801088c1:	6a 00                	push   $0x0
801088c3:	ff 75 08             	pushl  0x8(%ebp)
801088c6:	e8 44 fc ff ff       	call   8010850f <mappages>
801088cb:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801088ce:	83 ec 04             	sub    $0x4,%esp
801088d1:	ff 75 10             	pushl  0x10(%ebp)
801088d4:	ff 75 0c             	pushl  0xc(%ebp)
801088d7:	ff 75 f4             	pushl  -0xc(%ebp)
801088da:	e8 60 cd ff ff       	call   8010563f <memmove>
801088df:	83 c4 10             	add    $0x10,%esp
}
801088e2:	90                   	nop
801088e3:	c9                   	leave  
801088e4:	c3                   	ret    

801088e5 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801088e5:	f3 0f 1e fb          	endbr32 
801088e9:	55                   	push   %ebp
801088ea:	89 e5                	mov    %esp,%ebp
801088ec:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801088ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801088f2:	25 ff 0f 00 00       	and    $0xfff,%eax
801088f7:	85 c0                	test   %eax,%eax
801088f9:	74 0d                	je     80108908 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
801088fb:	83 ec 0c             	sub    $0xc,%esp
801088fe:	68 94 9a 10 80       	push   $0x80109a94
80108903:	e8 00 7d ff ff       	call   80100608 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108908:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010890f:	e9 8f 00 00 00       	jmp    801089a3 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108914:	8b 55 0c             	mov    0xc(%ebp),%edx
80108917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891a:	01 d0                	add    %edx,%eax
8010891c:	83 ec 04             	sub    $0x4,%esp
8010891f:	6a 00                	push   $0x0
80108921:	50                   	push   %eax
80108922:	ff 75 08             	pushl  0x8(%ebp)
80108925:	e8 1c f8 ff ff       	call   80108146 <walkpgdir>
8010892a:	83 c4 10             	add    $0x10,%esp
8010892d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108930:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108934:	75 0d                	jne    80108943 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108936:	83 ec 0c             	sub    $0xc,%esp
80108939:	68 b7 9a 10 80       	push   $0x80109ab7
8010893e:	e8 c5 7c ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
80108943:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108946:	8b 00                	mov    (%eax),%eax
80108948:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010894d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108950:	8b 45 18             	mov    0x18(%ebp),%eax
80108953:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108956:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010895b:	77 0b                	ja     80108968 <loaduvm+0x83>
      n = sz - i;
8010895d:	8b 45 18             	mov    0x18(%ebp),%eax
80108960:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108963:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108966:	eb 07                	jmp    8010896f <loaduvm+0x8a>
    else
      n = PGSIZE;
80108968:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010896f:	8b 55 14             	mov    0x14(%ebp),%edx
80108972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108975:	01 d0                	add    %edx,%eax
80108977:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010897a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108980:	ff 75 f0             	pushl  -0x10(%ebp)
80108983:	50                   	push   %eax
80108984:	52                   	push   %edx
80108985:	ff 75 10             	pushl  0x10(%ebp)
80108988:	e8 ad 96 ff ff       	call   8010203a <readi>
8010898d:	83 c4 10             	add    $0x10,%esp
80108990:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108993:	74 07                	je     8010899c <loaduvm+0xb7>
      return -1;
80108995:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010899a:	eb 18                	jmp    801089b4 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
8010899c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801089a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a6:	3b 45 18             	cmp    0x18(%ebp),%eax
801089a9:	0f 82 65 ff ff ff    	jb     80108914 <loaduvm+0x2f>
  }
  return 0;
801089af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801089b4:	c9                   	leave  
801089b5:	c3                   	ret    

801089b6 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801089b6:	f3 0f 1e fb          	endbr32 
801089ba:	55                   	push   %ebp
801089bb:	89 e5                	mov    %esp,%ebp
801089bd:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801089c0:	8b 45 10             	mov    0x10(%ebp),%eax
801089c3:	85 c0                	test   %eax,%eax
801089c5:	79 0a                	jns    801089d1 <allocuvm+0x1b>
    return 0;
801089c7:	b8 00 00 00 00       	mov    $0x0,%eax
801089cc:	e9 ea 00 00 00       	jmp    80108abb <allocuvm+0x105>
  if(newsz < oldsz)
801089d1:	8b 45 10             	mov    0x10(%ebp),%eax
801089d4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801089d7:	73 08                	jae    801089e1 <allocuvm+0x2b>
    return oldsz;
801089d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801089dc:	e9 da 00 00 00       	jmp    80108abb <allocuvm+0x105>

  a = PGROUNDUP(oldsz);
801089e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801089e4:	05 ff 0f 00 00       	add    $0xfff,%eax
801089e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801089f1:	e9 b6 00 00 00       	jmp    80108aac <allocuvm+0xf6>
    mem = kalloc();
801089f6:	e8 27 a4 ff ff       	call   80102e22 <kalloc>
801089fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801089fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a02:	75 2d                	jne    80108a31 <allocuvm+0x7b>
      cprintf("allocuvm out of memory\n");
80108a04:	83 ec 0c             	sub    $0xc,%esp
80108a07:	68 d5 9a 10 80       	push   $0x80109ad5
80108a0c:	e8 07 7a ff ff       	call   80100418 <cprintf>
80108a11:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz, 0);
80108a14:	6a 00                	push   $0x0
80108a16:	ff 75 0c             	pushl  0xc(%ebp)
80108a19:	ff 75 10             	pushl  0x10(%ebp)
80108a1c:	ff 75 08             	pushl  0x8(%ebp)
80108a1f:	e8 99 00 00 00       	call   80108abd <deallocuvm>
80108a24:	83 c4 10             	add    $0x10,%esp
      return 0;
80108a27:	b8 00 00 00 00       	mov    $0x0,%eax
80108a2c:	e9 8a 00 00 00       	jmp    80108abb <allocuvm+0x105>
    }
    memset(mem, 0, PGSIZE);
80108a31:	83 ec 04             	sub    $0x4,%esp
80108a34:	68 00 10 00 00       	push   $0x1000
80108a39:	6a 00                	push   $0x0
80108a3b:	ff 75 f0             	pushl  -0x10(%ebp)
80108a3e:	e8 35 cb ff ff       	call   80105578 <memset>
80108a43:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108a46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a49:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a52:	83 ec 0c             	sub    $0xc,%esp
80108a55:	6a 06                	push   $0x6
80108a57:	52                   	push   %edx
80108a58:	68 00 10 00 00       	push   $0x1000
80108a5d:	50                   	push   %eax
80108a5e:	ff 75 08             	pushl  0x8(%ebp)
80108a61:	e8 a9 fa ff ff       	call   8010850f <mappages>
80108a66:	83 c4 20             	add    $0x20,%esp
80108a69:	85 c0                	test   %eax,%eax
80108a6b:	79 38                	jns    80108aa5 <allocuvm+0xef>
      cprintf("allocuvm out of memory (2)\n");
80108a6d:	83 ec 0c             	sub    $0xc,%esp
80108a70:	68 ed 9a 10 80       	push   $0x80109aed
80108a75:	e8 9e 79 ff ff       	call   80100418 <cprintf>
80108a7a:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz, 0);
80108a7d:	6a 00                	push   $0x0
80108a7f:	ff 75 0c             	pushl  0xc(%ebp)
80108a82:	ff 75 10             	pushl  0x10(%ebp)
80108a85:	ff 75 08             	pushl  0x8(%ebp)
80108a88:	e8 30 00 00 00       	call   80108abd <deallocuvm>
80108a8d:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108a90:	83 ec 0c             	sub    $0xc,%esp
80108a93:	ff 75 f0             	pushl  -0x10(%ebp)
80108a96:	e8 e9 a2 ff ff       	call   80102d84 <kfree>
80108a9b:	83 c4 10             	add    $0x10,%esp
      return 0;
80108a9e:	b8 00 00 00 00       	mov    $0x0,%eax
80108aa3:	eb 16                	jmp    80108abb <allocuvm+0x105>
  for(; a < newsz; a += PGSIZE){
80108aa5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aaf:	3b 45 10             	cmp    0x10(%ebp),%eax
80108ab2:	0f 82 3e ff ff ff    	jb     801089f6 <allocuvm+0x40>
    }
  }
  return newsz;
80108ab8:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108abb:	c9                   	leave  
80108abc:	c3                   	ret    

80108abd <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz, uint growproc)
{
80108abd:	f3 0f 1e fb          	endbr32 
80108ac1:	55                   	push   %ebp
80108ac2:	89 e5                	mov    %esp,%ebp
80108ac4:	83 ec 18             	sub    $0x18,%esp

  pte_t *pte;
  uint a, pa;
 
  if(newsz >= oldsz)
80108ac7:	8b 45 10             	mov    0x10(%ebp),%eax
80108aca:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108acd:	72 08                	jb     80108ad7 <deallocuvm+0x1a>
    return oldsz;
80108acf:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ad2:	e9 c3 00 00 00       	jmp    80108b9a <deallocuvm+0xdd>

  a = PGROUNDUP(newsz);
80108ad7:	8b 45 10             	mov    0x10(%ebp),%eax
80108ada:	05 ff 0f 00 00       	add    $0xfff,%eax
80108adf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ae4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108ae7:	e9 9f 00 00 00       	jmp    80108b8b <deallocuvm+0xce>
    
    pte = walkpgdir(pgdir, (char*)a, 0);
80108aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aef:	83 ec 04             	sub    $0x4,%esp
80108af2:	6a 00                	push   $0x0
80108af4:	50                   	push   %eax
80108af5:	ff 75 08             	pushl  0x8(%ebp)
80108af8:	e8 49 f6 ff ff       	call   80108146 <walkpgdir>
80108afd:	83 c4 10             	add    $0x10,%esp
80108b00:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108b03:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b07:	75 16                	jne    80108b1f <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b0c:	c1 e8 16             	shr    $0x16,%eax
80108b0f:	83 c0 01             	add    $0x1,%eax
80108b12:	c1 e0 16             	shl    $0x16,%eax
80108b15:	2d 00 10 00 00       	sub    $0x1000,%eax
80108b1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108b1d:	eb 65                	jmp    80108b84 <deallocuvm+0xc7>
    else if((*pte & (PTE_P | PTE_E)) != 0){
80108b1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b22:	8b 00                	mov    (%eax),%eax
80108b24:	25 01 04 00 00       	and    $0x401,%eax
80108b29:	85 c0                	test   %eax,%eax
80108b2b:	74 57                	je     80108b84 <deallocuvm+0xc7>
      pa = PTE_ADDR(*pte);
80108b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b30:	8b 00                	mov    (%eax),%eax
80108b32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b37:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108b3a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108b3e:	75 0d                	jne    80108b4d <deallocuvm+0x90>
        panic("kfree");
80108b40:	83 ec 0c             	sub    $0xc,%esp
80108b43:	68 09 9b 10 80       	push   $0x80109b09
80108b48:	e8 bb 7a ff ff       	call   80100608 <panic>
      if(growproc){
80108b4d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108b51:	74 0f                	je     80108b62 <deallocuvm+0xa5>
        removepage((char*)a);
80108b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b56:	83 ec 0c             	sub    $0xc,%esp
80108b59:	50                   	push   %eax
80108b5a:	e8 c1 f0 ff ff       	call   80107c20 <removepage>
80108b5f:	83 c4 10             	add    $0x10,%esp

      }
      char *v = P2V(pa);
80108b62:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b65:	05 00 00 00 80       	add    $0x80000000,%eax
80108b6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108b6d:	83 ec 0c             	sub    $0xc,%esp
80108b70:	ff 75 e8             	pushl  -0x18(%ebp)
80108b73:	e8 0c a2 ff ff       	call   80102d84 <kfree>
80108b78:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b7e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108b84:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b8e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108b91:	0f 82 55 ff ff ff    	jb     80108aec <deallocuvm+0x2f>

    }
  }
  return newsz;
80108b97:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108b9a:	c9                   	leave  
80108b9b:	c3                   	ret    

80108b9c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108b9c:	f3 0f 1e fb          	endbr32 
80108ba0:	55                   	push   %ebp
80108ba1:	89 e5                	mov    %esp,%ebp
80108ba3:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108ba6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108baa:	75 0d                	jne    80108bb9 <freevm+0x1d>
    panic("freevm: no pgdir");
80108bac:	83 ec 0c             	sub    $0xc,%esp
80108baf:	68 0f 9b 10 80       	push   $0x80109b0f
80108bb4:	e8 4f 7a ff ff       	call   80100608 <panic>
  deallocuvm(pgdir, KERNBASE, 0, 0);
80108bb9:	6a 00                	push   $0x0
80108bbb:	6a 00                	push   $0x0
80108bbd:	68 00 00 00 80       	push   $0x80000000
80108bc2:	ff 75 08             	pushl  0x8(%ebp)
80108bc5:	e8 f3 fe ff ff       	call   80108abd <deallocuvm>
80108bca:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108bcd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108bd4:	eb 48                	jmp    80108c1e <freevm+0x82>
    //you don't need to check for PTE_E here because
    //this is a pde_t, where PTE_E doesn't get set
    if(pgdir[i] & PTE_P){
80108bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bd9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108be0:	8b 45 08             	mov    0x8(%ebp),%eax
80108be3:	01 d0                	add    %edx,%eax
80108be5:	8b 00                	mov    (%eax),%eax
80108be7:	83 e0 01             	and    $0x1,%eax
80108bea:	85 c0                	test   %eax,%eax
80108bec:	74 2c                	je     80108c1a <freevm+0x7e>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bf1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80108bfb:	01 d0                	add    %edx,%eax
80108bfd:	8b 00                	mov    (%eax),%eax
80108bff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c04:	05 00 00 00 80       	add    $0x80000000,%eax
80108c09:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108c0c:	83 ec 0c             	sub    $0xc,%esp
80108c0f:	ff 75 f0             	pushl  -0x10(%ebp)
80108c12:	e8 6d a1 ff ff       	call   80102d84 <kfree>
80108c17:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108c1a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108c1e:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108c25:	76 af                	jbe    80108bd6 <freevm+0x3a>
    }
  }
  kfree((char*)pgdir);
80108c27:	83 ec 0c             	sub    $0xc,%esp
80108c2a:	ff 75 08             	pushl  0x8(%ebp)
80108c2d:	e8 52 a1 ff ff       	call   80102d84 <kfree>
80108c32:	83 c4 10             	add    $0x10,%esp
}
80108c35:	90                   	nop
80108c36:	c9                   	leave  
80108c37:	c3                   	ret    

80108c38 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108c38:	f3 0f 1e fb          	endbr32 
80108c3c:	55                   	push   %ebp
80108c3d:	89 e5                	mov    %esp,%ebp
80108c3f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108c42:	83 ec 04             	sub    $0x4,%esp
80108c45:	6a 00                	push   $0x0
80108c47:	ff 75 0c             	pushl  0xc(%ebp)
80108c4a:	ff 75 08             	pushl  0x8(%ebp)
80108c4d:	e8 f4 f4 ff ff       	call   80108146 <walkpgdir>
80108c52:	83 c4 10             	add    $0x10,%esp
80108c55:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108c58:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108c5c:	75 0d                	jne    80108c6b <clearpteu+0x33>
    panic("clearpteu");
80108c5e:	83 ec 0c             	sub    $0xc,%esp
80108c61:	68 20 9b 10 80       	push   $0x80109b20
80108c66:	e8 9d 79 ff ff       	call   80100608 <panic>
  *pte &= ~PTE_U;
80108c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c6e:	8b 00                	mov    (%eax),%eax
80108c70:	83 e0 fb             	and    $0xfffffffb,%eax
80108c73:	89 c2                	mov    %eax,%edx
80108c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c78:	89 10                	mov    %edx,(%eax)
}
80108c7a:	90                   	nop
80108c7b:	c9                   	leave  
80108c7c:	c3                   	ret    

80108c7d <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108c7d:	f3 0f 1e fb          	endbr32 
80108c81:	55                   	push   %ebp
80108c82:	89 e5                	mov    %esp,%ebp
80108c84:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108c87:	e8 6c f9 ff ff       	call   801085f8 <setupkvm>
80108c8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108c8f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108c93:	75 0a                	jne    80108c9f <copyuvm+0x22>
    return 0;
80108c95:	b8 00 00 00 00       	mov    $0x0,%eax
80108c9a:	e9 fa 00 00 00       	jmp    80108d99 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108c9f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108ca6:	e9 c9 00 00 00       	jmp    80108d74 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cae:	83 ec 04             	sub    $0x4,%esp
80108cb1:	6a 00                	push   $0x0
80108cb3:	50                   	push   %eax
80108cb4:	ff 75 08             	pushl  0x8(%ebp)
80108cb7:	e8 8a f4 ff ff       	call   80108146 <walkpgdir>
80108cbc:	83 c4 10             	add    $0x10,%esp
80108cbf:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108cc2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108cc6:	75 0d                	jne    80108cd5 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
80108cc8:	83 ec 0c             	sub    $0xc,%esp
80108ccb:	68 2a 9b 10 80       	push   $0x80109b2a
80108cd0:	e8 33 79 ff ff       	call   80100608 <panic>
    if(!(*pte & (PTE_P | PTE_E)))
80108cd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cd8:	8b 00                	mov    (%eax),%eax
80108cda:	25 01 04 00 00       	and    $0x401,%eax
80108cdf:	85 c0                	test   %eax,%eax
80108ce1:	75 0d                	jne    80108cf0 <copyuvm+0x73>
      panic("copyuvm: page not present");
80108ce3:	83 ec 0c             	sub    $0xc,%esp
80108ce6:	68 44 9b 10 80       	push   $0x80109b44
80108ceb:	e8 18 79 ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
80108cf0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cf3:	8b 00                	mov    (%eax),%eax
80108cf5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108cfa:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108cfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d00:	8b 00                	mov    (%eax),%eax
80108d02:	25 ff 0f 00 00       	and    $0xfff,%eax
80108d07:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108d0a:	e8 13 a1 ff ff       	call   80102e22 <kalloc>
80108d0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108d12:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108d16:	74 6d                	je     80108d85 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108d18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d1b:	05 00 00 00 80       	add    $0x80000000,%eax
80108d20:	83 ec 04             	sub    $0x4,%esp
80108d23:	68 00 10 00 00       	push   $0x1000
80108d28:	50                   	push   %eax
80108d29:	ff 75 e0             	pushl  -0x20(%ebp)
80108d2c:	e8 0e c9 ff ff       	call   8010563f <memmove>
80108d31:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80108d34:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108d37:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d3a:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d43:	83 ec 0c             	sub    $0xc,%esp
80108d46:	52                   	push   %edx
80108d47:	51                   	push   %ecx
80108d48:	68 00 10 00 00       	push   $0x1000
80108d4d:	50                   	push   %eax
80108d4e:	ff 75 f0             	pushl  -0x10(%ebp)
80108d51:	e8 b9 f7 ff ff       	call   8010850f <mappages>
80108d56:	83 c4 20             	add    $0x20,%esp
80108d59:	85 c0                	test   %eax,%eax
80108d5b:	79 10                	jns    80108d6d <copyuvm+0xf0>
      kfree(mem);
80108d5d:	83 ec 0c             	sub    $0xc,%esp
80108d60:	ff 75 e0             	pushl  -0x20(%ebp)
80108d63:	e8 1c a0 ff ff       	call   80102d84 <kfree>
80108d68:	83 c4 10             	add    $0x10,%esp
      goto bad;
80108d6b:	eb 19                	jmp    80108d86 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80108d6d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d77:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108d7a:	0f 82 2b ff ff ff    	jb     80108cab <copyuvm+0x2e>
    }
  }
  return d;
80108d80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d83:	eb 14                	jmp    80108d99 <copyuvm+0x11c>
      goto bad;
80108d85:	90                   	nop

bad:
  freevm(d);
80108d86:	83 ec 0c             	sub    $0xc,%esp
80108d89:	ff 75 f0             	pushl  -0x10(%ebp)
80108d8c:	e8 0b fe ff ff       	call   80108b9c <freevm>
80108d91:	83 c4 10             	add    $0x10,%esp
  return 0;
80108d94:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108d99:	c9                   	leave  
80108d9a:	c3                   	ret    

80108d9b <uva2ka>:
// KVA -> PA
// PA -> KVA
// KVA = PA + KERNBASE
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108d9b:	f3 0f 1e fb          	endbr32 
80108d9f:	55                   	push   %ebp
80108da0:	89 e5                	mov    %esp,%ebp
80108da2:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108da5:	83 ec 04             	sub    $0x4,%esp
80108da8:	6a 00                	push   $0x0
80108daa:	ff 75 0c             	pushl  0xc(%ebp)
80108dad:	ff 75 08             	pushl  0x8(%ebp)
80108db0:	e8 91 f3 ff ff       	call   80108146 <walkpgdir>
80108db5:	83 c4 10             	add    $0x10,%esp
80108db8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //TODO: uva2ka says not present if PTE_P is 0
  if(((*pte & PTE_P) | (*pte & PTE_E)) == 0)
80108dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dbe:	8b 00                	mov    (%eax),%eax
80108dc0:	25 01 04 00 00       	and    $0x401,%eax
80108dc5:	85 c0                	test   %eax,%eax
80108dc7:	75 07                	jne    80108dd0 <uva2ka+0x35>
    return 0;
80108dc9:	b8 00 00 00 00       	mov    $0x0,%eax
80108dce:	eb 22                	jmp    80108df2 <uva2ka+0x57>
  if((*pte & PTE_U) == 0)
80108dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dd3:	8b 00                	mov    (%eax),%eax
80108dd5:	83 e0 04             	and    $0x4,%eax
80108dd8:	85 c0                	test   %eax,%eax
80108dda:	75 07                	jne    80108de3 <uva2ka+0x48>
    return 0;
80108ddc:	b8 00 00 00 00       	mov    $0x0,%eax
80108de1:	eb 0f                	jmp    80108df2 <uva2ka+0x57>
  return (char*)P2V(PTE_ADDR(*pte));
80108de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de6:	8b 00                	mov    (%eax),%eax
80108de8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ded:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108df2:	c9                   	leave  
80108df3:	c3                   	ret    

80108df4 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108df4:	f3 0f 1e fb          	endbr32 
80108df8:	55                   	push   %ebp
80108df9:	89 e5                	mov    %esp,%ebp
80108dfb:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108dfe:	8b 45 10             	mov    0x10(%ebp),%eax
80108e01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108e04:	eb 7f                	jmp    80108e85 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108e06:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //TODO: what happens if you copyout to an encrypted page?
    pa0 = uva2ka(pgdir, (char*)va0);
80108e11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e14:	83 ec 08             	sub    $0x8,%esp
80108e17:	50                   	push   %eax
80108e18:	ff 75 08             	pushl  0x8(%ebp)
80108e1b:	e8 7b ff ff ff       	call   80108d9b <uva2ka>
80108e20:	83 c4 10             	add    $0x10,%esp
80108e23:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0) {
80108e26:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108e2a:	75 07                	jne    80108e33 <copyout+0x3f>
      return -1;
80108e2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e31:	eb 61                	jmp    80108e94 <copyout+0xa0>
    }
    n = PGSIZE - (va - va0);
80108e33:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e36:	2b 45 0c             	sub    0xc(%ebp),%eax
80108e39:	05 00 10 00 00       	add    $0x1000,%eax
80108e3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e44:	3b 45 14             	cmp    0x14(%ebp),%eax
80108e47:	76 06                	jbe    80108e4f <copyout+0x5b>
      n = len;
80108e49:	8b 45 14             	mov    0x14(%ebp),%eax
80108e4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e52:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108e55:	89 c2                	mov    %eax,%edx
80108e57:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e5a:	01 d0                	add    %edx,%eax
80108e5c:	83 ec 04             	sub    $0x4,%esp
80108e5f:	ff 75 f0             	pushl  -0x10(%ebp)
80108e62:	ff 75 f4             	pushl  -0xc(%ebp)
80108e65:	50                   	push   %eax
80108e66:	e8 d4 c7 ff ff       	call   8010563f <memmove>
80108e6b:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e71:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108e74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e77:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108e7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e7d:	05 00 10 00 00       	add    $0x1000,%eax
80108e82:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108e85:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108e89:	0f 85 77 ff ff ff    	jne    80108e06 <copyout+0x12>
  }
  return 0;
80108e8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108e94:	c9                   	leave  
80108e95:	c3                   	ret    

80108e96 <mdecrypt>:


//returns 0 on success
int mdecrypt(char *virtual_addr) {
80108e96:	f3 0f 1e fb          	endbr32 
80108e9a:	55                   	push   %ebp
80108e9b:	89 e5                	mov    %esp,%ebp
80108e9d:	83 ec 28             	sub    $0x28,%esp
  //cprintf("mdecrypt: VPN %d, %p, pid %d\n", PPN(virtual_addr), virtual_addr, myproc()->pid);
  //the given pointer is a virtual address in this pid's userspace
  // cprintf("in mdecrypt");
  struct proc * p = myproc();
80108ea0:	e8 1b b6 ff ff       	call   801044c0 <myproc>
80108ea5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pde_t* mypd = p->pgdir;
80108ea8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108eab:	8b 40 04             	mov    0x4(%eax),%eax
80108eae:	89 45 e8             	mov    %eax,-0x18(%ebp)
  //set the present bit to true and encrypt bit to false
  pte_t * pte = walkpgdir(mypd, virtual_addr, 0);
80108eb1:	83 ec 04             	sub    $0x4,%esp
80108eb4:	6a 00                	push   $0x0
80108eb6:	ff 75 08             	pushl  0x8(%ebp)
80108eb9:	ff 75 e8             	pushl  -0x18(%ebp)
80108ebc:	e8 85 f2 ff ff       	call   80108146 <walkpgdir>
80108ec1:	83 c4 10             	add    $0x10,%esp
80108ec4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (!pte || *pte == 0) {
80108ec7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108ecb:	74 09                	je     80108ed6 <mdecrypt+0x40>
80108ecd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ed0:	8b 00                	mov    (%eax),%eax
80108ed2:	85 c0                	test   %eax,%eax
80108ed4:	75 07                	jne    80108edd <mdecrypt+0x47>
    return -1;
80108ed6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108edb:	eb 7a                	jmp    80108f57 <mdecrypt+0xc1>
  }

  *pte = *pte & ~PTE_E;
80108edd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ee0:	8b 00                	mov    (%eax),%eax
80108ee2:	80 e4 fb             	and    $0xfb,%ah
80108ee5:	89 c2                	mov    %eax,%edx
80108ee7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108eea:	89 10                	mov    %edx,(%eax)
  *pte = *pte | PTE_P;
80108eec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108eef:	8b 00                	mov    (%eax),%eax
80108ef1:	83 c8 01             	or     $0x1,%eax
80108ef4:	89 c2                	mov    %eax,%edx
80108ef6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ef9:	89 10                	mov    %edx,(%eax)
  *pte = *pte | PTE_A;
80108efb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108efe:	8b 00                	mov    (%eax),%eax
80108f00:	83 c8 20             	or     $0x20,%eax
80108f03:	89 c2                	mov    %eax,%edx
80108f05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f08:	89 10                	mov    %edx,(%eax)
  
  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80108f0d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f12:	89 45 08             	mov    %eax,0x8(%ebp)
  

  char * slider = virtual_addr;
80108f15:	8b 45 08             	mov    0x8(%ebp),%eax
80108f18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108f1b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108f22:	eb 17                	jmp    80108f3b <mdecrypt+0xa5>
    *slider = ~*slider;
80108f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f27:	0f b6 00             	movzbl (%eax),%eax
80108f2a:	f7 d0                	not    %eax
80108f2c:	89 c2                	mov    %eax,%edx
80108f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f31:	88 10                	mov    %dl,(%eax)
    slider++;
80108f33:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108f37:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108f3b:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80108f42:	7e e0                	jle    80108f24 <mdecrypt+0x8e>
    //   for (int i=0; i<CLOCKSIZE;i++){
    //   cprintf(" value_r %p ",myproc()->clock_queue[i].va);
      
    // }
    // cprintf("\n");
  addtoworkingset(virtual_addr);
80108f44:	83 ec 0c             	sub    $0xc,%esp
80108f47:	ff 75 08             	pushl  0x8(%ebp)
80108f4a:	e8 91 f2 ff ff       	call   801081e0 <addtoworkingset>
80108f4f:	83 c4 10             	add    $0x10,%esp

  return 0;
80108f52:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f57:	c9                   	leave  
80108f58:	c3                   	ret    

80108f59 <mencrypt>:

int mencrypt(char *virtual_addr, int len) {
80108f59:	f3 0f 1e fb          	endbr32 
80108f5d:	55                   	push   %ebp
80108f5e:	89 e5                	mov    %esp,%ebp
80108f60:	83 ec 28             	sub    $0x28,%esp
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
80108f63:	e8 58 b5 ff ff       	call   801044c0 <myproc>
80108f68:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t* mypd = p->pgdir;
80108f6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f6e:	8b 40 04             	mov    0x4(%eax),%eax
80108f71:	89 45 e0             	mov    %eax,-0x20(%ebp)

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108f74:	8b 45 08             	mov    0x8(%ebp),%eax
80108f77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f7c:	89 45 08             	mov    %eax,0x8(%ebp)

  //error checking first. all or nothing.
  char * slider = virtual_addr;
80108f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80108f82:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108f85:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108f8c:	eb 3f                	jmp    80108fcd <mencrypt+0x74>
    //check page table for each translation first
    char * kvp = uva2ka(mypd, slider);
80108f8e:	83 ec 08             	sub    $0x8,%esp
80108f91:	ff 75 f4             	pushl  -0xc(%ebp)
80108f94:	ff 75 e0             	pushl  -0x20(%ebp)
80108f97:	e8 ff fd ff ff       	call   80108d9b <uva2ka>
80108f9c:	83 c4 10             	add    $0x10,%esp
80108f9f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if (!kvp) {
80108fa2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80108fa6:	75 1a                	jne    80108fc2 <mencrypt+0x69>
      cprintf("mencrypt: Could not access address\n");
80108fa8:	83 ec 0c             	sub    $0xc,%esp
80108fab:	68 60 9b 10 80       	push   $0x80109b60
80108fb0:	e8 63 74 ff ff       	call   80100418 <cprintf>
80108fb5:	83 c4 10             	add    $0x10,%esp
      return -1;
80108fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108fbd:	e9 ce 00 00 00       	jmp    80109090 <mencrypt+0x137>
    }
    slider = slider + PGSIZE;
80108fc2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108fc9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108fcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fd0:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108fd3:	7c b9                	jl     80108f8e <mencrypt+0x35>
  }

  //encrypt stage. Have to do this before setting flag 
  //or else we'll page fault
  slider = virtual_addr;
80108fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80108fd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108fdb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108fe2:	e9 87 00 00 00       	jmp    8010906e <mencrypt+0x115>
    //we get the page table entry that corresponds to this VA
    pte_t * mypte = walkpgdir(mypd, slider, 0);
80108fe7:	83 ec 04             	sub    $0x4,%esp
80108fea:	6a 00                	push   $0x0
80108fec:	ff 75 f4             	pushl  -0xc(%ebp)
80108fef:	ff 75 e0             	pushl  -0x20(%ebp)
80108ff2:	e8 4f f1 ff ff       	call   80108146 <walkpgdir>
80108ff7:	83 c4 10             	add    $0x10,%esp
80108ffa:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (*mypte & PTE_E) {//already encrypted
80108ffd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109000:	8b 00                	mov    (%eax),%eax
80109002:	25 00 04 00 00       	and    $0x400,%eax
80109007:	85 c0                	test   %eax,%eax
80109009:	74 09                	je     80109014 <mencrypt+0xbb>
      slider += PGSIZE;
8010900b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      continue;
80109012:	eb 56                	jmp    8010906a <mencrypt+0x111>
    }
    for (int offset = 0; offset < PGSIZE; offset++) {
80109014:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
8010901b:	eb 17                	jmp    80109034 <mencrypt+0xdb>
      *slider = ~*slider;
8010901d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109020:	0f b6 00             	movzbl (%eax),%eax
80109023:	f7 d0                	not    %eax
80109025:	89 c2                	mov    %eax,%edx
80109027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010902a:	88 10                	mov    %dl,(%eax)
      slider++;
8010902c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    for (int offset = 0; offset < PGSIZE; offset++) {
80109030:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80109034:	81 7d e8 ff 0f 00 00 	cmpl   $0xfff,-0x18(%ebp)
8010903b:	7e e0                	jle    8010901d <mencrypt+0xc4>
    }
    *mypte = *mypte & ~PTE_P;
8010903d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109040:	8b 00                	mov    (%eax),%eax
80109042:	83 e0 fe             	and    $0xfffffffe,%eax
80109045:	89 c2                	mov    %eax,%edx
80109047:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010904a:	89 10                	mov    %edx,(%eax)
    *mypte = *mypte | PTE_E;
8010904c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010904f:	8b 00                	mov    (%eax),%eax
80109051:	80 cc 04             	or     $0x4,%ah
80109054:	89 c2                	mov    %eax,%edx
80109056:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109059:	89 10                	mov    %edx,(%eax)
    *mypte = *mypte & ~PTE_A;
8010905b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010905e:	8b 00                	mov    (%eax),%eax
80109060:	83 e0 df             	and    $0xffffffdf,%eax
80109063:	89 c2                	mov    %eax,%edx
80109065:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109068:	89 10                	mov    %edx,(%eax)
  for (int i = 0; i < len; i++) { 
8010906a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010906e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109071:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109074:	0f 8c 6d ff ff ff    	jl     80108fe7 <mencrypt+0x8e>
  }

  switchuvm(myproc());
8010907a:	e8 41 b4 ff ff       	call   801044c0 <myproc>
8010907f:	83 ec 0c             	sub    $0xc,%esp
80109082:	50                   	push   %eax
80109083:	e8 46 f6 ff ff       	call   801086ce <switchuvm>
80109088:	83 c4 10             	add    $0x10,%esp
  return 0;
8010908b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109090:	c9                   	leave  
80109091:	c3                   	ret    

80109092 <getpgtable>:

int getpgtable(struct pt_entry* entries, int num, int wsetOnly) {
80109092:	f3 0f 1e fb          	endbr32 
80109096:	55                   	push   %ebp
80109097:	89 e5                	mov    %esp,%ebp
80109099:	83 ec 28             	sub    $0x28,%esp
  struct proc * me = myproc();
8010909c:	e8 1f b4 ff ff       	call   801044c0 <myproc>
801090a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(wsetOnly != 0 && wsetOnly != 1)
801090a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801090a8:	74 10                	je     801090ba <getpgtable+0x28>
801090aa:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
801090ae:	74 0a                	je     801090ba <getpgtable+0x28>
    return -1;
801090b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090b5:	e9 18 02 00 00       	jmp    801092d2 <getpgtable+0x240>
  int index = 0;
801090ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  int count=0;
801090c1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  pte_t * curr_pte;
  //reverse order
  if(wsetOnly){
801090c8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801090cc:	74 04                	je     801090d2 <getpgtable+0x40>
    num=num+1;
801090ce:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  }
  
  for (void * i = (void*) PGROUNDDOWN(((int)me->sz)); i >= 0 && count < num; i-=PGSIZE) {
801090d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090d5:	8b 00                	mov    (%eax),%eax
801090d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801090df:	e9 dc 01 00 00       	jmp    801092c0 <getpgtable+0x22e>

    curr_pte = walkpgdir(me->pgdir, i, 0);
801090e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090e7:	8b 40 04             	mov    0x4(%eax),%eax
801090ea:	83 ec 04             	sub    $0x4,%esp
801090ed:	6a 00                	push   $0x0
801090ef:	ff 75 ec             	pushl  -0x14(%ebp)
801090f2:	50                   	push   %eax
801090f3:	e8 4e f0 ff ff       	call   80108146 <walkpgdir>
801090f8:	83 c4 10             	add    $0x10,%esp
801090fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    //currPage is 0 if page is not allocated
    //see deallocuvm
    if (curr_pte && *curr_pte) {//this page is allocated
801090fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109102:	0f 84 a8 01 00 00    	je     801092b0 <getpgtable+0x21e>
80109108:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010910b:	8b 00                	mov    (%eax),%eax
8010910d:	85 c0                	test   %eax,%eax
8010910f:	0f 84 9b 01 00 00    	je     801092b0 <getpgtable+0x21e>
      //this is the same for all pt_entries... right?
      // if(*curr_pte& PTE_U){
      // count++;
      // }
      count++;
80109115:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(wsetOnly){
80109119:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010911d:	74 35                	je     80109154 <getpgtable+0xc2>
        if((*curr_pte & PTE_P)){
8010911f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109122:	8b 00                	mov    (%eax),%eax
80109124:	83 e0 01             	and    $0x1,%eax
80109127:	85 c0                	test   %eax,%eax
80109129:	74 13                	je     8010913e <getpgtable+0xac>
          cprintf("page fris %p\n",i);
8010912b:	83 ec 08             	sub    $0x8,%esp
8010912e:	ff 75 ec             	pushl  -0x14(%ebp)
80109131:	68 84 9b 10 80       	push   $0x80109b84
80109136:	e8 dd 72 ff ff       	call   80100418 <cprintf>
8010913b:	83 c4 10             	add    $0x10,%esp
        }
        if(!inwset(i)) {
8010913e:	83 ec 0c             	sub    $0xc,%esp
80109141:	ff 75 ec             	pushl  -0x14(%ebp)
80109144:	e8 56 ec ff ff       	call   80107d9f <inwset>
80109149:	83 c4 10             	add    $0x10,%esp
8010914c:	85 c0                	test   %eax,%eax
8010914e:	0f 84 64 01 00 00    	je     801092b8 <getpgtable+0x226>
  
	      continue;
        }
      }

      entries[index].pdx = PDX(i); 
80109154:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109157:	c1 e8 16             	shr    $0x16,%eax
8010915a:	89 c1                	mov    %eax,%ecx
8010915c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010915f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109166:	8b 45 08             	mov    0x8(%ebp),%eax
80109169:	01 c2                	add    %eax,%edx
8010916b:	89 c8                	mov    %ecx,%eax
8010916d:	66 25 ff 03          	and    $0x3ff,%ax
80109171:	66 25 ff 03          	and    $0x3ff,%ax
80109175:	89 c1                	mov    %eax,%ecx
80109177:	0f b7 02             	movzwl (%edx),%eax
8010917a:	66 25 00 fc          	and    $0xfc00,%ax
8010917e:	09 c8                	or     %ecx,%eax
80109180:	66 89 02             	mov    %ax,(%edx)
      entries[index].ptx = PTX(i);
80109183:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109186:	c1 e8 0c             	shr    $0xc,%eax
80109189:	89 c1                	mov    %eax,%ecx
8010918b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010918e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109195:	8b 45 08             	mov    0x8(%ebp),%eax
80109198:	01 c2                	add    %eax,%edx
8010919a:	89 c8                	mov    %ecx,%eax
8010919c:	66 25 ff 03          	and    $0x3ff,%ax
801091a0:	0f b7 c0             	movzwl %ax,%eax
801091a3:	25 ff 03 00 00       	and    $0x3ff,%eax
801091a8:	c1 e0 0a             	shl    $0xa,%eax
801091ab:	89 c1                	mov    %eax,%ecx
801091ad:	8b 02                	mov    (%edx),%eax
801091af:	25 ff 03 f0 ff       	and    $0xfff003ff,%eax
801091b4:	09 c8                	or     %ecx,%eax
801091b6:	89 02                	mov    %eax,(%edx)
      //convert to physical addr then shift to get PPN 
      entries[index].ppage = PPN(*curr_pte);
801091b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801091bb:	8b 00                	mov    (%eax),%eax
801091bd:	c1 e8 0c             	shr    $0xc,%eax
801091c0:	89 c2                	mov    %eax,%edx
801091c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c5:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801091cc:	8b 45 08             	mov    0x8(%ebp),%eax
801091cf:	01 c8                	add    %ecx,%eax
801091d1:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
801091d7:	89 d1                	mov    %edx,%ecx
801091d9:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
801091df:	8b 50 04             	mov    0x4(%eax),%edx
801091e2:	81 e2 00 00 f0 ff    	and    $0xfff00000,%edx
801091e8:	09 ca                	or     %ecx,%edx
801091ea:	89 50 04             	mov    %edx,0x4(%eax)
      //have to set it like this because these are 1 bit wide fields
      entries[index].present = (*curr_pte & PTE_P) ? 1 : 0;
801091ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801091f0:	8b 08                	mov    (%eax),%ecx
801091f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801091fc:	8b 45 08             	mov    0x8(%ebp),%eax
801091ff:	01 c2                	add    %eax,%edx
80109201:	89 c8                	mov    %ecx,%eax
80109203:	83 e0 01             	and    $0x1,%eax
80109206:	83 e0 01             	and    $0x1,%eax
80109209:	c1 e0 04             	shl    $0x4,%eax
8010920c:	89 c1                	mov    %eax,%ecx
8010920e:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80109212:	83 e0 ef             	and    $0xffffffef,%eax
80109215:	09 c8                	or     %ecx,%eax
80109217:	88 42 06             	mov    %al,0x6(%edx)
      entries[index].writable = (*curr_pte & PTE_W) ? 1 : 0;
8010921a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010921d:	8b 00                	mov    (%eax),%eax
8010921f:	d1 e8                	shr    %eax
80109221:	89 c1                	mov    %eax,%ecx
80109223:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109226:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010922d:	8b 45 08             	mov    0x8(%ebp),%eax
80109230:	01 c2                	add    %eax,%edx
80109232:	89 c8                	mov    %ecx,%eax
80109234:	83 e0 01             	and    $0x1,%eax
80109237:	83 e0 01             	and    $0x1,%eax
8010923a:	c1 e0 05             	shl    $0x5,%eax
8010923d:	89 c1                	mov    %eax,%ecx
8010923f:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80109243:	83 e0 df             	and    $0xffffffdf,%eax
80109246:	09 c8                	or     %ecx,%eax
80109248:	88 42 06             	mov    %al,0x6(%edx)
      entries[index].encrypted = (*curr_pte & PTE_E) ? 1 : 0;
8010924b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010924e:	8b 00                	mov    (%eax),%eax
80109250:	c1 e8 0a             	shr    $0xa,%eax
80109253:	89 c1                	mov    %eax,%ecx
80109255:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109258:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010925f:	8b 45 08             	mov    0x8(%ebp),%eax
80109262:	01 c2                	add    %eax,%edx
80109264:	89 c8                	mov    %ecx,%eax
80109266:	83 e0 01             	and    $0x1,%eax
80109269:	83 e0 01             	and    $0x1,%eax
8010926c:	c1 e0 06             	shl    $0x6,%eax
8010926f:	89 c1                	mov    %eax,%ecx
80109271:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80109275:	83 e0 bf             	and    $0xffffffbf,%eax
80109278:	09 c8                	or     %ecx,%eax
8010927a:	88 42 06             	mov    %al,0x6(%edx)
      entries[index].ref       =  (*curr_pte & PTE_A)? 1:0;
8010927d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109280:	8b 00                	mov    (%eax),%eax
80109282:	c1 e8 05             	shr    $0x5,%eax
80109285:	89 c1                	mov    %eax,%ecx
80109287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010928a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109291:	8b 45 08             	mov    0x8(%ebp),%eax
80109294:	01 c2                	add    %eax,%edx
80109296:	89 c8                	mov    %ecx,%eax
80109298:	83 e0 01             	and    $0x1,%eax
8010929b:	83 e0 01             	and    $0x1,%eax
8010929e:	89 c1                	mov    %eax,%ecx
801092a0:	0f b6 42 07          	movzbl 0x7(%edx),%eax
801092a4:	83 e0 fe             	and    $0xfffffffe,%eax
801092a7:	09 c8                	or     %ecx,%eax
801092a9:	88 42 07             	mov    %al,0x7(%edx)
      index++;
801092ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      
    }

    if (i == 0) {
801092b0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801092b4:	74 18                	je     801092ce <getpgtable+0x23c>
801092b6:	eb 01                	jmp    801092b9 <getpgtable+0x227>
	      continue;
801092b8:	90                   	nop
  for (void * i = (void*) PGROUNDDOWN(((int)me->sz)); i >= 0 && count < num; i-=PGSIZE) {
801092b9:	81 6d ec 00 10 00 00 	subl   $0x1000,-0x14(%ebp)
801092c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092c3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801092c6:	0f 8c 18 fe ff ff    	jl     801090e4 <getpgtable+0x52>
801092cc:	eb 01                	jmp    801092cf <getpgtable+0x23d>
      break;
801092ce:	90                   	nop
      
  //   // }
  //   return me->hand;
  // }  
  //index is the number of ptes copied
  return index;
801092cf:	8b 45 f4             	mov    -0xc(%ebp),%eax

}
801092d2:	c9                   	leave  
801092d3:	c3                   	ret    

801092d4 <dump_rawphymem>:


int dump_rawphymem(uint physical_addr, char * buffer) {
801092d4:	f3 0f 1e fb          	endbr32 
801092d8:	55                   	push   %ebp
801092d9:	89 e5                	mov    %esp,%ebp
801092db:	56                   	push   %esi
801092dc:	53                   	push   %ebx
801092dd:	83 ec 10             	sub    $0x10,%esp
  //note that copyout converts buffer to a kva and then copies
  //which means that if buffer is encrypted, it won't trigger a decryption request
  *buffer = *buffer;
801092e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801092e3:	0f b6 10             	movzbl (%eax),%edx
801092e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801092e9:	88 10                	mov    %dl,(%eax)
  int retval = copyout(myproc()->pgdir, (uint) buffer, (void *) P2V(physical_addr), PGSIZE);
801092eb:	8b 45 08             	mov    0x8(%ebp),%eax
801092ee:	05 00 00 00 80       	add    $0x80000000,%eax
801092f3:	89 c6                	mov    %eax,%esi
801092f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801092f8:	e8 c3 b1 ff ff       	call   801044c0 <myproc>
801092fd:	8b 40 04             	mov    0x4(%eax),%eax
80109300:	68 00 10 00 00       	push   $0x1000
80109305:	56                   	push   %esi
80109306:	53                   	push   %ebx
80109307:	50                   	push   %eax
80109308:	e8 e7 fa ff ff       	call   80108df4 <copyout>
8010930d:	83 c4 10             	add    $0x10,%esp
80109310:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (retval)
80109313:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109317:	74 07                	je     80109320 <dump_rawphymem+0x4c>
    return -1;
80109319:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010931e:	eb 05                	jmp    80109325 <dump_rawphymem+0x51>
  return 0;
80109320:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109325:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109328:	5b                   	pop    %ebx
80109329:	5e                   	pop    %esi
8010932a:	5d                   	pop    %ebp
8010932b:	c3                   	ret    
