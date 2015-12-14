# coding: utf-8
require 'pp'

class Tokenizer
  # IMPのマップ
  @@imps = {
    " " => :stack,
    "\t " => :arithmetic,
    "\t\t" => :heap,
    "\n" => :flow,
    "\t\n" => :io
  }
  # コマンドのマップ
  @@cmd = {
    stack: {
      " " => :push,
      "\n " => :dup,
      "\n\t" => :swap,
      "\n\n" => :discard
    },
    arithmetic: {
      "  " => :add,
      " \t" => :sub,
      " \n" => :mul,
      "\t " => :div,
      "\t\t" => :mod
    },
    heap: {
      " " => :store,
      "\t" => :retrive
    },
    flow: {
      "  " => :label,
      " \t" => :call,
      " \n" => :jump,
      "\t " => :jz,
      "\t\t" => :jn,
      "\t\n" => :ret,
      "\n\n" => :exit
    },
    io: {
      "  " => :outchar,
      " \t" => :outnum,
      "\t " => :readchar,
      "\t\t" => :readnum
    }
  }
  # 第3引数持ちのコマンド
  @@has_param = [:push, :label, :call, :jump, :jz, :jn]

  attr_reader :tokens
  def initialize
    @tokens = []
    @program = ARGF.read.tr("^ \n\t", "")
    tokenize
  end

  def tokenize
    while @program != ""
      @imp = nil; @cmd = nil; @param = nil;
      analyze_imp
      analyze_cmd
      @tokens << [@imp, @cmd, @param]
    end
  end

  private
  def analyze_imp
    unless @program.sub!(/\A( |\n|\t[ \n\t])/, '')
      raise Exception, 'undefined IMP'
    else
      @imp = @@imps[$1]
    end
  end

  def analyze_cmd
    param_match = /\A([ \t]+)\n/
    unless @program.sub!(/\A(#{@@cmd[@imp].keys.join('|')})/, '')
      raise Exception, 'undefined Command'
    else
      @cmd = @@cmd[@imp][$1]
      if @@has_param.include? @cmd
        unless $' =~ param_match
          raise Exception, 'undefined Parameters'
        else
          @param = eval("0b#{$1.tr(" \t", "01")}")
          @program.sub!(param_match, '')
        end
      end
    end
  end
end

class Executor
  def initialize(tokens)
    @tokens = tokens
  end

  def run
    @pc = 0
    @stack = []
    @heap = {}
    @callStack = []
    loop do
      _, cmd, param = @tokens[@pc]
      @pc += 1
      case cmd
      when :push then @stack << param
      when :dup then @stack << @stack.last
      when :outnum then print @stack.pop
      when :outchar then print @stack.pop.chr

      when :add then calc("+")
      when :sub then calc("-")
      when :mul then calc("*")
      when :div then calc("/")
      when :mod then calc("%")

      when :jz then jump(param) if @stack.pop == 0
      when :jn then jump(param) if @stack.pop < 0
      when :jump then jump(param)

      when :discard then @stack.pop
      when :exit then exit

      when :store
        value = @stack.pop
        address = @stack.pop
        @heap[address] = value
      when :call
        @callStack << @pc
        jump(param)
      when :retrive then @stack << @heap[@stack.pop]
      when :ret then @pc = @callStack.pop
      when :readchar then @heap[@stack.pop] = $stdin.getc
      when :readnum then @heap[@stack.pop] = $stdin.gets.to_i
      when :swap then @stack << @stack.slice!(-2)
      end
    end
  end
  private

  def calc(op)
    b = @stack.pop
    a = @stack.pop
    @stack.push eval("a #{op} b")
  end

  def jump(label)
    @tokens.each_with_index do |token, i|
      if token == [:flow, :label, label]
        @pc = i
        break
      end
    end
  end
end

Executor.new(Tokenizer.new.tokens).run
