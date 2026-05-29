use bytes::Buf;

/// Dummy Buf implementation
struct TestBuf {
    buf: &'static [u8],
    readlens: &'static [usize],
    init_pos: usize,
    pos: usize,
    readlen_pos: usize,
    readlen: usize,
}

impl TestBuf {
    fn new(buf: &'static [u8], readlens: &'static [usize], init_pos: usize) -> TestBuf {
        let mut buf = TestBuf {
            buf,
            readlens,
            init_pos,
            pos: 0,
            readlen_pos: 0,
            readlen: 0,
        };
        buf.reset();
        buf
    }

    fn reset(&mut self) {
        self.pos = self.init_pos;
        self.readlen_pos = 0;
        self.next_readlen();
    }

    fn next_readlen(&mut self) {
        self.readlen = self.buf.len() - self.pos;
        if let Some(readlen) = self.readlens.get(self.readlen_pos) {
            self.readlen = std::cmp::min(self.readlen, *readlen);
            self.readlen_pos += 1;
        }
    }
}

impl Buf for TestBuf {
    fn remaining(&self) -> usize {
        self.buf.len() - self.pos
    }

    fn advance(&mut self, cnt: usize) {
        self.pos += cnt;
        assert!(self.pos <= self.buf.len());
        self.next_readlen();
    }

    fn chunk(&self) -> &[u8] {
        if self.readlen == 0 {
            Default::default()
        } else {
            &self.buf[self.pos..self.pos + self.readlen]
        }
    }
}

fn main() {
    let mut bufs = [
        TestBuf::new(&[1u8; 8 + 0], &[1], 0),
        TestBuf::new(&[1u8; 8 + 1], &[1], 1),
        TestBuf::new(&[1u8; 8 + 2], &[1], 2),
        TestBuf::new(&[1u8; 8 + 3], &[1], 3),
        TestBuf::new(&[1u8; 8 + 4], &[1], 4),
        TestBuf::new(&[1u8; 8 + 5], &[1], 5),
        TestBuf::new(&[1u8; 8 + 6], &[1], 6),
        TestBuf::new(&[1u8; 8 + 7], &[1], 7),
    ];

    for i in 0..8 {
        bufs[i].reset();
        let buf: &mut dyn Buf = &mut bufs[i];
        let val = buf.get_u64();
        println!("Buffer {}: get_u64() returned {}", i, val);
    }
}
