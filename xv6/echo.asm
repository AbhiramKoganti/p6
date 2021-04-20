
_echo:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "ptentry.h"

#define PGSIZE 4096

int main(void) {
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	51                   	push   %ecx
  12:	83 ec 34             	sub    $0x34,%esp
    const uint PAGES_NUM = 100;
  15:	c7 45 f0 64 00 00 00 	movl   $0x64,-0x10(%ebp)
    // Allocate one pages of space
    char *buffer = sbrk(PGSIZE * sizeof(char));
  1c:	83 ec 0c             	sub    $0xc,%esp
  1f:	68 00 10 00 00       	push   $0x1000
  24:	e8 77 04 00 00       	call   4a0 <sbrk>
  29:	83 c4 10             	add    $0x10,%esp
  2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    char *sp = buffer - PGSIZE;
  2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  32:	2d 00 10 00 00       	sub    $0x1000,%eax
  37:	89 45 e8             	mov    %eax,-0x18(%ebp)
    char *boundary = buffer - 2 * PGSIZE;
  3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  3d:	2d 00 20 00 00       	sub    $0x2000,%eax
  42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    char *text = 0x0;
  45:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    uint text_pages = (uint) boundary / PGSIZE;
  4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  4f:	c1 e8 0c             	shr    $0xc,%eax
  52:	89 45 dc             	mov    %eax,-0x24(%ebp)
    struct pt_entry pt_entries[PAGES_NUM];
  55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  58:	83 e8 01             	sub    $0x1,%eax
  5b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  61:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  68:	b8 10 00 00 00       	mov    $0x10,%eax
  6d:	83 e8 01             	sub    $0x1,%eax
  70:	01 d0                	add    %edx,%eax
  72:	b9 10 00 00 00       	mov    $0x10,%ecx
  77:	ba 00 00 00 00       	mov    $0x0,%edx
  7c:	f7 f1                	div    %ecx
  7e:	6b c0 10             	imul   $0x10,%eax,%eax
  81:	89 c2                	mov    %eax,%edx
  83:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  89:	89 e1                	mov    %esp,%ecx
  8b:	29 d1                	sub    %edx,%ecx
  8d:	89 ca                	mov    %ecx,%edx
  8f:	39 d4                	cmp    %edx,%esp
  91:	74 10                	je     a3 <main+0xa3>
  93:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  99:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  a0:	00 
  a1:	eb ec                	jmp    8f <main+0x8f>
  a3:	89 c2                	mov    %eax,%edx
  a5:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  ab:	29 d4                	sub    %edx,%esp
  ad:	89 c2                	mov    %eax,%edx
  af:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  b5:	85 d2                	test   %edx,%edx
  b7:	74 0d                	je     c6 <main+0xc6>
  b9:	25 ff 0f 00 00       	and    $0xfff,%eax
  be:	83 e8 04             	sub    $0x4,%eax
  c1:	01 e0                	add    %esp,%eax
  c3:	83 08 00             	orl    $0x0,(%eax)
  c6:	89 e0                	mov    %esp,%eax
  c8:	83 c0 03             	add    $0x3,%eax
  cb:	c1 e8 02             	shr    $0x2,%eax
  ce:	c1 e0 02             	shl    $0x2,%eax
  d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    sbrk(PAGES_NUM * PGSIZE);
  d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  d7:	c1 e0 0c             	shl    $0xc,%eax
  da:	83 ec 0c             	sub    $0xc,%esp
  dd:	50                   	push   %eax
  de:	e8 bd 03 00 00       	call   4a0 <sbrk>
  e3:	83 c4 10             	add    $0x10,%esp

    for (int i = 0; i < text_pages; i++)
  e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ed:	eb 23                	jmp    112 <main+0x112>
        text[i * PGSIZE] = text[i * PGSIZE];
  ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  f2:	c1 e0 0c             	shl    $0xc,%eax
  f5:	89 c2                	mov    %eax,%edx
  f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  fa:	01 d0                	add    %edx,%eax
  fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ff:	c1 e2 0c             	shl    $0xc,%edx
 102:	89 d1                	mov    %edx,%ecx
 104:	8b 55 e0             	mov    -0x20(%ebp),%edx
 107:	01 ca                	add    %ecx,%edx
 109:	0f b6 00             	movzbl (%eax),%eax
 10c:	88 02                	mov    %al,(%edx)
    for (int i = 0; i < text_pages; i++)
 10e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 112:	8b 45 f4             	mov    -0xc(%ebp),%eax
 115:	39 45 dc             	cmp    %eax,-0x24(%ebp)
 118:	77 d5                	ja     ef <main+0xef>
    sp[0] = sp[0];
 11a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 11d:	0f b6 10             	movzbl (%eax),%edx
 120:	8b 45 e8             	mov    -0x18(%ebp),%eax
 123:	88 10                	mov    %dl,(%eax)
    buffer[0] = buffer[0];
 125:	8b 45 ec             	mov    -0x14(%ebp),%eax
 128:	0f b6 10             	movzbl (%eax),%edx
 12b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 12e:	88 10                	mov    %dl,(%eax)
    printf(1, "buffer: %d\n", (int) buffer);
 130:	8b 45 ec             	mov    -0x14(%ebp),%eax
 133:	83 ec 04             	sub    $0x4,%esp
 136:	50                   	push   %eax
 137:	68 74 09 00 00       	push   $0x974
 13c:	6a 01                	push   $0x1
 13e:	e8 69 04 00 00       	call   5ac <printf>
 143:	83 c4 10             	add    $0x10,%esp
    int expected_pages_num = (uint)buffer / PGSIZE;
 146:	8b 45 ec             	mov    -0x14(%ebp),%eax
 149:	c1 e8 0c             	shr    $0xc,%eax
 14c:	89 45 d0             	mov    %eax,-0x30(%ebp)


    int retval = getpgtable(pt_entries, 100, 1);
 14f:	83 ec 04             	sub    $0x4,%esp
 152:	6a 01                	push   $0x1
 154:	6a 64                	push   $0x64
 156:	ff 75 d4             	pushl  -0x2c(%ebp)
 159:	e8 62 03 00 00       	call   4c0 <getpgtable>
 15e:	83 c4 10             	add    $0x10,%esp
 161:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if (retval != expected_pages_num) {
 164:	8b 45 cc             	mov    -0x34(%ebp),%eax
 167:	3b 45 d0             	cmp    -0x30(%ebp),%eax
 16a:	74 1a                	je     186 <main+0x186>
        printf(1, "XV6_TEST_OUTPUT: getpgtable returned incorrect value: expected %d, got %d\n", expected_pages_num, retval);
 16c:	ff 75 cc             	pushl  -0x34(%ebp)
 16f:	ff 75 d0             	pushl  -0x30(%ebp)
 172:	68 80 09 00 00       	push   $0x980
 177:	6a 01                	push   $0x1
 179:	e8 2e 04 00 00       	call   5ac <printf>
 17e:	83 c4 10             	add    $0x10,%esp
        exit();
 181:	e8 92 02 00 00       	call   418 <exit>
    }
    printf(1, "XV6_TEST_OUTPUT PASS!\n");
 186:	83 ec 08             	sub    $0x8,%esp
 189:	68 cb 09 00 00       	push   $0x9cb
 18e:	6a 01                	push   $0x1
 190:	e8 17 04 00 00       	call   5ac <printf>
 195:	83 c4 10             	add    $0x10,%esp
    exit();
 198:	e8 7b 02 00 00       	call   418 <exit>

0000019d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 19d:	55                   	push   %ebp
 19e:	89 e5                	mov    %esp,%ebp
 1a0:	57                   	push   %edi
 1a1:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1a5:	8b 55 10             	mov    0x10(%ebp),%edx
 1a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ab:	89 cb                	mov    %ecx,%ebx
 1ad:	89 df                	mov    %ebx,%edi
 1af:	89 d1                	mov    %edx,%ecx
 1b1:	fc                   	cld    
 1b2:	f3 aa                	rep stos %al,%es:(%edi)
 1b4:	89 ca                	mov    %ecx,%edx
 1b6:	89 fb                	mov    %edi,%ebx
 1b8:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1bb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1be:	90                   	nop
 1bf:	5b                   	pop    %ebx
 1c0:	5f                   	pop    %edi
 1c1:	5d                   	pop    %ebp
 1c2:	c3                   	ret    

000001c3 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 1c3:	f3 0f 1e fb          	endbr32 
 1c7:	55                   	push   %ebp
 1c8:	89 e5                	mov    %esp,%ebp
 1ca:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1cd:	8b 45 08             	mov    0x8(%ebp),%eax
 1d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1d3:	90                   	nop
 1d4:	8b 55 0c             	mov    0xc(%ebp),%edx
 1d7:	8d 42 01             	lea    0x1(%edx),%eax
 1da:	89 45 0c             	mov    %eax,0xc(%ebp)
 1dd:	8b 45 08             	mov    0x8(%ebp),%eax
 1e0:	8d 48 01             	lea    0x1(%eax),%ecx
 1e3:	89 4d 08             	mov    %ecx,0x8(%ebp)
 1e6:	0f b6 12             	movzbl (%edx),%edx
 1e9:	88 10                	mov    %dl,(%eax)
 1eb:	0f b6 00             	movzbl (%eax),%eax
 1ee:	84 c0                	test   %al,%al
 1f0:	75 e2                	jne    1d4 <strcpy+0x11>
    ;
  return os;
 1f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1f5:	c9                   	leave  
 1f6:	c3                   	ret    

000001f7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1f7:	f3 0f 1e fb          	endbr32 
 1fb:	55                   	push   %ebp
 1fc:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1fe:	eb 08                	jmp    208 <strcmp+0x11>
    p++, q++;
 200:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 204:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 208:	8b 45 08             	mov    0x8(%ebp),%eax
 20b:	0f b6 00             	movzbl (%eax),%eax
 20e:	84 c0                	test   %al,%al
 210:	74 10                	je     222 <strcmp+0x2b>
 212:	8b 45 08             	mov    0x8(%ebp),%eax
 215:	0f b6 10             	movzbl (%eax),%edx
 218:	8b 45 0c             	mov    0xc(%ebp),%eax
 21b:	0f b6 00             	movzbl (%eax),%eax
 21e:	38 c2                	cmp    %al,%dl
 220:	74 de                	je     200 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 222:	8b 45 08             	mov    0x8(%ebp),%eax
 225:	0f b6 00             	movzbl (%eax),%eax
 228:	0f b6 d0             	movzbl %al,%edx
 22b:	8b 45 0c             	mov    0xc(%ebp),%eax
 22e:	0f b6 00             	movzbl (%eax),%eax
 231:	0f b6 c0             	movzbl %al,%eax
 234:	29 c2                	sub    %eax,%edx
 236:	89 d0                	mov    %edx,%eax
}
 238:	5d                   	pop    %ebp
 239:	c3                   	ret    

0000023a <strlen>:

uint
strlen(const char *s)
{
 23a:	f3 0f 1e fb          	endbr32 
 23e:	55                   	push   %ebp
 23f:	89 e5                	mov    %esp,%ebp
 241:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 244:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 24b:	eb 04                	jmp    251 <strlen+0x17>
 24d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 251:	8b 55 fc             	mov    -0x4(%ebp),%edx
 254:	8b 45 08             	mov    0x8(%ebp),%eax
 257:	01 d0                	add    %edx,%eax
 259:	0f b6 00             	movzbl (%eax),%eax
 25c:	84 c0                	test   %al,%al
 25e:	75 ed                	jne    24d <strlen+0x13>
    ;
  return n;
 260:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 263:	c9                   	leave  
 264:	c3                   	ret    

00000265 <memset>:

void*
memset(void *dst, int c, uint n)
{
 265:	f3 0f 1e fb          	endbr32 
 269:	55                   	push   %ebp
 26a:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 26c:	8b 45 10             	mov    0x10(%ebp),%eax
 26f:	50                   	push   %eax
 270:	ff 75 0c             	pushl  0xc(%ebp)
 273:	ff 75 08             	pushl  0x8(%ebp)
 276:	e8 22 ff ff ff       	call   19d <stosb>
 27b:	83 c4 0c             	add    $0xc,%esp
  return dst;
 27e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 281:	c9                   	leave  
 282:	c3                   	ret    

00000283 <strchr>:

char*
strchr(const char *s, char c)
{
 283:	f3 0f 1e fb          	endbr32 
 287:	55                   	push   %ebp
 288:	89 e5                	mov    %esp,%ebp
 28a:	83 ec 04             	sub    $0x4,%esp
 28d:	8b 45 0c             	mov    0xc(%ebp),%eax
 290:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 293:	eb 14                	jmp    2a9 <strchr+0x26>
    if(*s == c)
 295:	8b 45 08             	mov    0x8(%ebp),%eax
 298:	0f b6 00             	movzbl (%eax),%eax
 29b:	38 45 fc             	cmp    %al,-0x4(%ebp)
 29e:	75 05                	jne    2a5 <strchr+0x22>
      return (char*)s;
 2a0:	8b 45 08             	mov    0x8(%ebp),%eax
 2a3:	eb 13                	jmp    2b8 <strchr+0x35>
  for(; *s; s++)
 2a5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2a9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ac:	0f b6 00             	movzbl (%eax),%eax
 2af:	84 c0                	test   %al,%al
 2b1:	75 e2                	jne    295 <strchr+0x12>
  return 0;
 2b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2b8:	c9                   	leave  
 2b9:	c3                   	ret    

000002ba <gets>:

char*
gets(char *buf, int max)
{
 2ba:	f3 0f 1e fb          	endbr32 
 2be:	55                   	push   %ebp
 2bf:	89 e5                	mov    %esp,%ebp
 2c1:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2cb:	eb 42                	jmp    30f <gets+0x55>
    cc = read(0, &c, 1);
 2cd:	83 ec 04             	sub    $0x4,%esp
 2d0:	6a 01                	push   $0x1
 2d2:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2d5:	50                   	push   %eax
 2d6:	6a 00                	push   $0x0
 2d8:	e8 53 01 00 00       	call   430 <read>
 2dd:	83 c4 10             	add    $0x10,%esp
 2e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2e7:	7e 33                	jle    31c <gets+0x62>
      break;
    buf[i++] = c;
 2e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ec:	8d 50 01             	lea    0x1(%eax),%edx
 2ef:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2f2:	89 c2                	mov    %eax,%edx
 2f4:	8b 45 08             	mov    0x8(%ebp),%eax
 2f7:	01 c2                	add    %eax,%edx
 2f9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2fd:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2ff:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 303:	3c 0a                	cmp    $0xa,%al
 305:	74 16                	je     31d <gets+0x63>
 307:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 30b:	3c 0d                	cmp    $0xd,%al
 30d:	74 0e                	je     31d <gets+0x63>
  for(i=0; i+1 < max; ){
 30f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 312:	83 c0 01             	add    $0x1,%eax
 315:	39 45 0c             	cmp    %eax,0xc(%ebp)
 318:	7f b3                	jg     2cd <gets+0x13>
 31a:	eb 01                	jmp    31d <gets+0x63>
      break;
 31c:	90                   	nop
      break;
  }
  buf[i] = '\0';
 31d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 320:	8b 45 08             	mov    0x8(%ebp),%eax
 323:	01 d0                	add    %edx,%eax
 325:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 328:	8b 45 08             	mov    0x8(%ebp),%eax
}
 32b:	c9                   	leave  
 32c:	c3                   	ret    

0000032d <stat>:

int
stat(const char *n, struct stat *st)
{
 32d:	f3 0f 1e fb          	endbr32 
 331:	55                   	push   %ebp
 332:	89 e5                	mov    %esp,%ebp
 334:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 337:	83 ec 08             	sub    $0x8,%esp
 33a:	6a 00                	push   $0x0
 33c:	ff 75 08             	pushl  0x8(%ebp)
 33f:	e8 14 01 00 00       	call   458 <open>
 344:	83 c4 10             	add    $0x10,%esp
 347:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 34a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 34e:	79 07                	jns    357 <stat+0x2a>
    return -1;
 350:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 355:	eb 25                	jmp    37c <stat+0x4f>
  r = fstat(fd, st);
 357:	83 ec 08             	sub    $0x8,%esp
 35a:	ff 75 0c             	pushl  0xc(%ebp)
 35d:	ff 75 f4             	pushl  -0xc(%ebp)
 360:	e8 0b 01 00 00       	call   470 <fstat>
 365:	83 c4 10             	add    $0x10,%esp
 368:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 36b:	83 ec 0c             	sub    $0xc,%esp
 36e:	ff 75 f4             	pushl  -0xc(%ebp)
 371:	e8 ca 00 00 00       	call   440 <close>
 376:	83 c4 10             	add    $0x10,%esp
  return r;
 379:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 37c:	c9                   	leave  
 37d:	c3                   	ret    

0000037e <atoi>:

int
atoi(const char *s)
{
 37e:	f3 0f 1e fb          	endbr32 
 382:	55                   	push   %ebp
 383:	89 e5                	mov    %esp,%ebp
 385:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 388:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 38f:	eb 25                	jmp    3b6 <atoi+0x38>
    n = n*10 + *s++ - '0';
 391:	8b 55 fc             	mov    -0x4(%ebp),%edx
 394:	89 d0                	mov    %edx,%eax
 396:	c1 e0 02             	shl    $0x2,%eax
 399:	01 d0                	add    %edx,%eax
 39b:	01 c0                	add    %eax,%eax
 39d:	89 c1                	mov    %eax,%ecx
 39f:	8b 45 08             	mov    0x8(%ebp),%eax
 3a2:	8d 50 01             	lea    0x1(%eax),%edx
 3a5:	89 55 08             	mov    %edx,0x8(%ebp)
 3a8:	0f b6 00             	movzbl (%eax),%eax
 3ab:	0f be c0             	movsbl %al,%eax
 3ae:	01 c8                	add    %ecx,%eax
 3b0:	83 e8 30             	sub    $0x30,%eax
 3b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3b6:	8b 45 08             	mov    0x8(%ebp),%eax
 3b9:	0f b6 00             	movzbl (%eax),%eax
 3bc:	3c 2f                	cmp    $0x2f,%al
 3be:	7e 0a                	jle    3ca <atoi+0x4c>
 3c0:	8b 45 08             	mov    0x8(%ebp),%eax
 3c3:	0f b6 00             	movzbl (%eax),%eax
 3c6:	3c 39                	cmp    $0x39,%al
 3c8:	7e c7                	jle    391 <atoi+0x13>
  return n;
 3ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3cd:	c9                   	leave  
 3ce:	c3                   	ret    

000003cf <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3cf:	f3 0f 1e fb          	endbr32 
 3d3:	55                   	push   %ebp
 3d4:	89 e5                	mov    %esp,%ebp
 3d6:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 3d9:	8b 45 08             	mov    0x8(%ebp),%eax
 3dc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3df:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3e5:	eb 17                	jmp    3fe <memmove+0x2f>
    *dst++ = *src++;
 3e7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3ea:	8d 42 01             	lea    0x1(%edx),%eax
 3ed:	89 45 f8             	mov    %eax,-0x8(%ebp)
 3f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3f3:	8d 48 01             	lea    0x1(%eax),%ecx
 3f6:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 3f9:	0f b6 12             	movzbl (%edx),%edx
 3fc:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 3fe:	8b 45 10             	mov    0x10(%ebp),%eax
 401:	8d 50 ff             	lea    -0x1(%eax),%edx
 404:	89 55 10             	mov    %edx,0x10(%ebp)
 407:	85 c0                	test   %eax,%eax
 409:	7f dc                	jg     3e7 <memmove+0x18>
  return vdst;
 40b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 40e:	c9                   	leave  
 40f:	c3                   	ret    

00000410 <fork>:
 410:	b8 01 00 00 00       	mov    $0x1,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <exit>:
 418:	b8 02 00 00 00       	mov    $0x2,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <wait>:
 420:	b8 03 00 00 00       	mov    $0x3,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <pipe>:
 428:	b8 04 00 00 00       	mov    $0x4,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <read>:
 430:	b8 05 00 00 00       	mov    $0x5,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <write>:
 438:	b8 10 00 00 00       	mov    $0x10,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <close>:
 440:	b8 15 00 00 00       	mov    $0x15,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <kill>:
 448:	b8 06 00 00 00       	mov    $0x6,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <exec>:
 450:	b8 07 00 00 00       	mov    $0x7,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <open>:
 458:	b8 0f 00 00 00       	mov    $0xf,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <mknod>:
 460:	b8 11 00 00 00       	mov    $0x11,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <unlink>:
 468:	b8 12 00 00 00       	mov    $0x12,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <fstat>:
 470:	b8 08 00 00 00       	mov    $0x8,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <link>:
 478:	b8 13 00 00 00       	mov    $0x13,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <mkdir>:
 480:	b8 14 00 00 00       	mov    $0x14,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <chdir>:
 488:	b8 09 00 00 00       	mov    $0x9,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <dup>:
 490:	b8 0a 00 00 00       	mov    $0xa,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <getpid>:
 498:	b8 0b 00 00 00       	mov    $0xb,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <sbrk>:
 4a0:	b8 0c 00 00 00       	mov    $0xc,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <sleep>:
 4a8:	b8 0d 00 00 00       	mov    $0xd,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <uptime>:
 4b0:	b8 0e 00 00 00       	mov    $0xe,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <mencrypt>:
 4b8:	b8 16 00 00 00       	mov    $0x16,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <getpgtable>:
 4c0:	b8 17 00 00 00       	mov    $0x17,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <dump_rawphymem>:
 4c8:	b8 18 00 00 00       	mov    $0x18,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <putc>:
 4d0:	f3 0f 1e fb          	endbr32 
 4d4:	55                   	push   %ebp
 4d5:	89 e5                	mov    %esp,%ebp
 4d7:	83 ec 18             	sub    $0x18,%esp
 4da:	8b 45 0c             	mov    0xc(%ebp),%eax
 4dd:	88 45 f4             	mov    %al,-0xc(%ebp)
 4e0:	83 ec 04             	sub    $0x4,%esp
 4e3:	6a 01                	push   $0x1
 4e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4e8:	50                   	push   %eax
 4e9:	ff 75 08             	pushl  0x8(%ebp)
 4ec:	e8 47 ff ff ff       	call   438 <write>
 4f1:	83 c4 10             	add    $0x10,%esp
 4f4:	90                   	nop
 4f5:	c9                   	leave  
 4f6:	c3                   	ret    

000004f7 <printint>:
 4f7:	f3 0f 1e fb          	endbr32 
 4fb:	55                   	push   %ebp
 4fc:	89 e5                	mov    %esp,%ebp
 4fe:	83 ec 28             	sub    $0x28,%esp
 501:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 508:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 50c:	74 17                	je     525 <printint+0x2e>
 50e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 512:	79 11                	jns    525 <printint+0x2e>
 514:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
 51b:	8b 45 0c             	mov    0xc(%ebp),%eax
 51e:	f7 d8                	neg    %eax
 520:	89 45 ec             	mov    %eax,-0x14(%ebp)
 523:	eb 06                	jmp    52b <printint+0x34>
 525:	8b 45 0c             	mov    0xc(%ebp),%eax
 528:	89 45 ec             	mov    %eax,-0x14(%ebp)
 52b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 532:	8b 4d 10             	mov    0x10(%ebp),%ecx
 535:	8b 45 ec             	mov    -0x14(%ebp),%eax
 538:	ba 00 00 00 00       	mov    $0x0,%edx
 53d:	f7 f1                	div    %ecx
 53f:	89 d1                	mov    %edx,%ecx
 541:	8b 45 f4             	mov    -0xc(%ebp),%eax
 544:	8d 50 01             	lea    0x1(%eax),%edx
 547:	89 55 f4             	mov    %edx,-0xc(%ebp)
 54a:	0f b6 91 30 0c 00 00 	movzbl 0xc30(%ecx),%edx
 551:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
 555:	8b 4d 10             	mov    0x10(%ebp),%ecx
 558:	8b 45 ec             	mov    -0x14(%ebp),%eax
 55b:	ba 00 00 00 00       	mov    $0x0,%edx
 560:	f7 f1                	div    %ecx
 562:	89 45 ec             	mov    %eax,-0x14(%ebp)
 565:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 569:	75 c7                	jne    532 <printint+0x3b>
 56b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 56f:	74 2d                	je     59e <printint+0xa7>
 571:	8b 45 f4             	mov    -0xc(%ebp),%eax
 574:	8d 50 01             	lea    0x1(%eax),%edx
 577:	89 55 f4             	mov    %edx,-0xc(%ebp)
 57a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)
 57f:	eb 1d                	jmp    59e <printint+0xa7>
 581:	8d 55 dc             	lea    -0x24(%ebp),%edx
 584:	8b 45 f4             	mov    -0xc(%ebp),%eax
 587:	01 d0                	add    %edx,%eax
 589:	0f b6 00             	movzbl (%eax),%eax
 58c:	0f be c0             	movsbl %al,%eax
 58f:	83 ec 08             	sub    $0x8,%esp
 592:	50                   	push   %eax
 593:	ff 75 08             	pushl  0x8(%ebp)
 596:	e8 35 ff ff ff       	call   4d0 <putc>
 59b:	83 c4 10             	add    $0x10,%esp
 59e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5a6:	79 d9                	jns    581 <printint+0x8a>
 5a8:	90                   	nop
 5a9:	90                   	nop
 5aa:	c9                   	leave  
 5ab:	c3                   	ret    

000005ac <printf>:
 5ac:	f3 0f 1e fb          	endbr32 
 5b0:	55                   	push   %ebp
 5b1:	89 e5                	mov    %esp,%ebp
 5b3:	83 ec 28             	sub    $0x28,%esp
 5b6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 5bd:	8d 45 0c             	lea    0xc(%ebp),%eax
 5c0:	83 c0 04             	add    $0x4,%eax
 5c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
 5c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5cd:	e9 59 01 00 00       	jmp    72b <printf+0x17f>
 5d2:	8b 55 0c             	mov    0xc(%ebp),%edx
 5d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5d8:	01 d0                	add    %edx,%eax
 5da:	0f b6 00             	movzbl (%eax),%eax
 5dd:	0f be c0             	movsbl %al,%eax
 5e0:	25 ff 00 00 00       	and    $0xff,%eax
 5e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 5e8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5ec:	75 2c                	jne    61a <printf+0x6e>
 5ee:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5f2:	75 0c                	jne    600 <printf+0x54>
 5f4:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5fb:	e9 27 01 00 00       	jmp    727 <printf+0x17b>
 600:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 603:	0f be c0             	movsbl %al,%eax
 606:	83 ec 08             	sub    $0x8,%esp
 609:	50                   	push   %eax
 60a:	ff 75 08             	pushl  0x8(%ebp)
 60d:	e8 be fe ff ff       	call   4d0 <putc>
 612:	83 c4 10             	add    $0x10,%esp
 615:	e9 0d 01 00 00       	jmp    727 <printf+0x17b>
 61a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 61e:	0f 85 03 01 00 00    	jne    727 <printf+0x17b>
 624:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 628:	75 1e                	jne    648 <printf+0x9c>
 62a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 62d:	8b 00                	mov    (%eax),%eax
 62f:	6a 01                	push   $0x1
 631:	6a 0a                	push   $0xa
 633:	50                   	push   %eax
 634:	ff 75 08             	pushl  0x8(%ebp)
 637:	e8 bb fe ff ff       	call   4f7 <printint>
 63c:	83 c4 10             	add    $0x10,%esp
 63f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 643:	e9 d8 00 00 00       	jmp    720 <printf+0x174>
 648:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 64c:	74 06                	je     654 <printf+0xa8>
 64e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 652:	75 1e                	jne    672 <printf+0xc6>
 654:	8b 45 e8             	mov    -0x18(%ebp),%eax
 657:	8b 00                	mov    (%eax),%eax
 659:	6a 00                	push   $0x0
 65b:	6a 10                	push   $0x10
 65d:	50                   	push   %eax
 65e:	ff 75 08             	pushl  0x8(%ebp)
 661:	e8 91 fe ff ff       	call   4f7 <printint>
 666:	83 c4 10             	add    $0x10,%esp
 669:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 66d:	e9 ae 00 00 00       	jmp    720 <printf+0x174>
 672:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 676:	75 43                	jne    6bb <printf+0x10f>
 678:	8b 45 e8             	mov    -0x18(%ebp),%eax
 67b:	8b 00                	mov    (%eax),%eax
 67d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 680:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 684:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 688:	75 25                	jne    6af <printf+0x103>
 68a:	c7 45 f4 e2 09 00 00 	movl   $0x9e2,-0xc(%ebp)
 691:	eb 1c                	jmp    6af <printf+0x103>
 693:	8b 45 f4             	mov    -0xc(%ebp),%eax
 696:	0f b6 00             	movzbl (%eax),%eax
 699:	0f be c0             	movsbl %al,%eax
 69c:	83 ec 08             	sub    $0x8,%esp
 69f:	50                   	push   %eax
 6a0:	ff 75 08             	pushl  0x8(%ebp)
 6a3:	e8 28 fe ff ff       	call   4d0 <putc>
 6a8:	83 c4 10             	add    $0x10,%esp
 6ab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 6af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b2:	0f b6 00             	movzbl (%eax),%eax
 6b5:	84 c0                	test   %al,%al
 6b7:	75 da                	jne    693 <printf+0xe7>
 6b9:	eb 65                	jmp    720 <printf+0x174>
 6bb:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6bf:	75 1d                	jne    6de <printf+0x132>
 6c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c4:	8b 00                	mov    (%eax),%eax
 6c6:	0f be c0             	movsbl %al,%eax
 6c9:	83 ec 08             	sub    $0x8,%esp
 6cc:	50                   	push   %eax
 6cd:	ff 75 08             	pushl  0x8(%ebp)
 6d0:	e8 fb fd ff ff       	call   4d0 <putc>
 6d5:	83 c4 10             	add    $0x10,%esp
 6d8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6dc:	eb 42                	jmp    720 <printf+0x174>
 6de:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6e2:	75 17                	jne    6fb <printf+0x14f>
 6e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e7:	0f be c0             	movsbl %al,%eax
 6ea:	83 ec 08             	sub    $0x8,%esp
 6ed:	50                   	push   %eax
 6ee:	ff 75 08             	pushl  0x8(%ebp)
 6f1:	e8 da fd ff ff       	call   4d0 <putc>
 6f6:	83 c4 10             	add    $0x10,%esp
 6f9:	eb 25                	jmp    720 <printf+0x174>
 6fb:	83 ec 08             	sub    $0x8,%esp
 6fe:	6a 25                	push   $0x25
 700:	ff 75 08             	pushl  0x8(%ebp)
 703:	e8 c8 fd ff ff       	call   4d0 <putc>
 708:	83 c4 10             	add    $0x10,%esp
 70b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 70e:	0f be c0             	movsbl %al,%eax
 711:	83 ec 08             	sub    $0x8,%esp
 714:	50                   	push   %eax
 715:	ff 75 08             	pushl  0x8(%ebp)
 718:	e8 b3 fd ff ff       	call   4d0 <putc>
 71d:	83 c4 10             	add    $0x10,%esp
 720:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 727:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 72b:	8b 55 0c             	mov    0xc(%ebp),%edx
 72e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 731:	01 d0                	add    %edx,%eax
 733:	0f b6 00             	movzbl (%eax),%eax
 736:	84 c0                	test   %al,%al
 738:	0f 85 94 fe ff ff    	jne    5d2 <printf+0x26>
 73e:	90                   	nop
 73f:	90                   	nop
 740:	c9                   	leave  
 741:	c3                   	ret    

00000742 <free>:
 742:	f3 0f 1e fb          	endbr32 
 746:	55                   	push   %ebp
 747:	89 e5                	mov    %esp,%ebp
 749:	83 ec 10             	sub    $0x10,%esp
 74c:	8b 45 08             	mov    0x8(%ebp),%eax
 74f:	83 e8 08             	sub    $0x8,%eax
 752:	89 45 f8             	mov    %eax,-0x8(%ebp)
 755:	a1 4c 0c 00 00       	mov    0xc4c,%eax
 75a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 75d:	eb 24                	jmp    783 <free+0x41>
 75f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 762:	8b 00                	mov    (%eax),%eax
 764:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 767:	72 12                	jb     77b <free+0x39>
 769:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 76f:	77 24                	ja     795 <free+0x53>
 771:	8b 45 fc             	mov    -0x4(%ebp),%eax
 774:	8b 00                	mov    (%eax),%eax
 776:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 779:	72 1a                	jb     795 <free+0x53>
 77b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77e:	8b 00                	mov    (%eax),%eax
 780:	89 45 fc             	mov    %eax,-0x4(%ebp)
 783:	8b 45 f8             	mov    -0x8(%ebp),%eax
 786:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 789:	76 d4                	jbe    75f <free+0x1d>
 78b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78e:	8b 00                	mov    (%eax),%eax
 790:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 793:	73 ca                	jae    75f <free+0x1d>
 795:	8b 45 f8             	mov    -0x8(%ebp),%eax
 798:	8b 40 04             	mov    0x4(%eax),%eax
 79b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a5:	01 c2                	add    %eax,%edx
 7a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7aa:	8b 00                	mov    (%eax),%eax
 7ac:	39 c2                	cmp    %eax,%edx
 7ae:	75 24                	jne    7d4 <free+0x92>
 7b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b3:	8b 50 04             	mov    0x4(%eax),%edx
 7b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b9:	8b 00                	mov    (%eax),%eax
 7bb:	8b 40 04             	mov    0x4(%eax),%eax
 7be:	01 c2                	add    %eax,%edx
 7c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c3:	89 50 04             	mov    %edx,0x4(%eax)
 7c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c9:	8b 00                	mov    (%eax),%eax
 7cb:	8b 10                	mov    (%eax),%edx
 7cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d0:	89 10                	mov    %edx,(%eax)
 7d2:	eb 0a                	jmp    7de <free+0x9c>
 7d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d7:	8b 10                	mov    (%eax),%edx
 7d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7dc:	89 10                	mov    %edx,(%eax)
 7de:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e1:	8b 40 04             	mov    0x4(%eax),%eax
 7e4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ee:	01 d0                	add    %edx,%eax
 7f0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7f3:	75 20                	jne    815 <free+0xd3>
 7f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f8:	8b 50 04             	mov    0x4(%eax),%edx
 7fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fe:	8b 40 04             	mov    0x4(%eax),%eax
 801:	01 c2                	add    %eax,%edx
 803:	8b 45 fc             	mov    -0x4(%ebp),%eax
 806:	89 50 04             	mov    %edx,0x4(%eax)
 809:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80c:	8b 10                	mov    (%eax),%edx
 80e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 811:	89 10                	mov    %edx,(%eax)
 813:	eb 08                	jmp    81d <free+0xdb>
 815:	8b 45 fc             	mov    -0x4(%ebp),%eax
 818:	8b 55 f8             	mov    -0x8(%ebp),%edx
 81b:	89 10                	mov    %edx,(%eax)
 81d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 820:	a3 4c 0c 00 00       	mov    %eax,0xc4c
 825:	90                   	nop
 826:	c9                   	leave  
 827:	c3                   	ret    

00000828 <morecore>:
 828:	f3 0f 1e fb          	endbr32 
 82c:	55                   	push   %ebp
 82d:	89 e5                	mov    %esp,%ebp
 82f:	83 ec 18             	sub    $0x18,%esp
 832:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 839:	77 07                	ja     842 <morecore+0x1a>
 83b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
 842:	8b 45 08             	mov    0x8(%ebp),%eax
 845:	c1 e0 03             	shl    $0x3,%eax
 848:	83 ec 0c             	sub    $0xc,%esp
 84b:	50                   	push   %eax
 84c:	e8 4f fc ff ff       	call   4a0 <sbrk>
 851:	83 c4 10             	add    $0x10,%esp
 854:	89 45 f4             	mov    %eax,-0xc(%ebp)
 857:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 85b:	75 07                	jne    864 <morecore+0x3c>
 85d:	b8 00 00 00 00       	mov    $0x0,%eax
 862:	eb 26                	jmp    88a <morecore+0x62>
 864:	8b 45 f4             	mov    -0xc(%ebp),%eax
 867:	89 45 f0             	mov    %eax,-0x10(%ebp)
 86a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86d:	8b 55 08             	mov    0x8(%ebp),%edx
 870:	89 50 04             	mov    %edx,0x4(%eax)
 873:	8b 45 f0             	mov    -0x10(%ebp),%eax
 876:	83 c0 08             	add    $0x8,%eax
 879:	83 ec 0c             	sub    $0xc,%esp
 87c:	50                   	push   %eax
 87d:	e8 c0 fe ff ff       	call   742 <free>
 882:	83 c4 10             	add    $0x10,%esp
 885:	a1 4c 0c 00 00       	mov    0xc4c,%eax
 88a:	c9                   	leave  
 88b:	c3                   	ret    

0000088c <malloc>:
 88c:	f3 0f 1e fb          	endbr32 
 890:	55                   	push   %ebp
 891:	89 e5                	mov    %esp,%ebp
 893:	83 ec 18             	sub    $0x18,%esp
 896:	8b 45 08             	mov    0x8(%ebp),%eax
 899:	83 c0 07             	add    $0x7,%eax
 89c:	c1 e8 03             	shr    $0x3,%eax
 89f:	83 c0 01             	add    $0x1,%eax
 8a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8a5:	a1 4c 0c 00 00       	mov    0xc4c,%eax
 8aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8b1:	75 23                	jne    8d6 <malloc+0x4a>
 8b3:	c7 45 f0 44 0c 00 00 	movl   $0xc44,-0x10(%ebp)
 8ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8bd:	a3 4c 0c 00 00       	mov    %eax,0xc4c
 8c2:	a1 4c 0c 00 00       	mov    0xc4c,%eax
 8c7:	a3 44 0c 00 00       	mov    %eax,0xc44
 8cc:	c7 05 48 0c 00 00 00 	movl   $0x0,0xc48
 8d3:	00 00 00 
 8d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d9:	8b 00                	mov    (%eax),%eax
 8db:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e1:	8b 40 04             	mov    0x4(%eax),%eax
 8e4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 8e7:	77 4d                	ja     936 <malloc+0xaa>
 8e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ec:	8b 40 04             	mov    0x4(%eax),%eax
 8ef:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 8f2:	75 0c                	jne    900 <malloc+0x74>
 8f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f7:	8b 10                	mov    (%eax),%edx
 8f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8fc:	89 10                	mov    %edx,(%eax)
 8fe:	eb 26                	jmp    926 <malloc+0x9a>
 900:	8b 45 f4             	mov    -0xc(%ebp),%eax
 903:	8b 40 04             	mov    0x4(%eax),%eax
 906:	2b 45 ec             	sub    -0x14(%ebp),%eax
 909:	89 c2                	mov    %eax,%edx
 90b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90e:	89 50 04             	mov    %edx,0x4(%eax)
 911:	8b 45 f4             	mov    -0xc(%ebp),%eax
 914:	8b 40 04             	mov    0x4(%eax),%eax
 917:	c1 e0 03             	shl    $0x3,%eax
 91a:	01 45 f4             	add    %eax,-0xc(%ebp)
 91d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 920:	8b 55 ec             	mov    -0x14(%ebp),%edx
 923:	89 50 04             	mov    %edx,0x4(%eax)
 926:	8b 45 f0             	mov    -0x10(%ebp),%eax
 929:	a3 4c 0c 00 00       	mov    %eax,0xc4c
 92e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 931:	83 c0 08             	add    $0x8,%eax
 934:	eb 3b                	jmp    971 <malloc+0xe5>
 936:	a1 4c 0c 00 00       	mov    0xc4c,%eax
 93b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 93e:	75 1e                	jne    95e <malloc+0xd2>
 940:	83 ec 0c             	sub    $0xc,%esp
 943:	ff 75 ec             	pushl  -0x14(%ebp)
 946:	e8 dd fe ff ff       	call   828 <morecore>
 94b:	83 c4 10             	add    $0x10,%esp
 94e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 951:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 955:	75 07                	jne    95e <malloc+0xd2>
 957:	b8 00 00 00 00       	mov    $0x0,%eax
 95c:	eb 13                	jmp    971 <malloc+0xe5>
 95e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 961:	89 45 f0             	mov    %eax,-0x10(%ebp)
 964:	8b 45 f4             	mov    -0xc(%ebp),%eax
 967:	8b 00                	mov    (%eax),%eax
 969:	89 45 f4             	mov    %eax,-0xc(%ebp)
 96c:	e9 6d ff ff ff       	jmp    8de <malloc+0x52>
 971:	c9                   	leave  
 972:	c3                   	ret    
