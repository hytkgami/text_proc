# coding:utf-8

def ntimes (n, &block)
  while n > 0
    block.call # もしくは, yield

    n -= 1
  end
end
