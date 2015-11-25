require "optparse"
opt = OptionParser.new

# オプションが指定されればハッシュにtrueを渡す
options = {}
opt.on('-w') {|v| options[:w] = v}
opt.on('-l') {|v| options[:l] = v}
opt.on('-c') {|v| options[:c] = v}
opt.parse!(ARGV)

sum_words = 0
sum_lines = 0
sum_bytes = 0
ARGV.each {|filename|
	file = open(filename)
	words = 0
	lines = 0
	bytesize = 0
	file.each {|line|
		words += line.split.size
		# wcは\nをもって行数をカウントする
		lines += 1 if line.end_with? "\n"
		bytesize += line.bytesize
	}
	sum_words += words
	sum_lines += lines
	sum_bytes += bytesize

	# オプションの判定
	if options.all? {|w| !w }
		lines.to_s.rjust(7) unless options[:l]
		words.to_s.rjust(7) unless options[:w]
		bytesize.to_s.rjust(7) unless options[:c]
	else
		lines = ''.rjust(0) unless options[:l]
		words = ''.rjust(0) unless options[:w]
		bytesize = ''.rjust(0) unless options[:c]
	end
	puts " #{lines} #{words} #{bytesize} #{filename}"
	file.close
}
# totalの出力
if ARGV.size > 1
	if options.all? {|w| !w }
		sum_lines.to_s.rjust(7) unless options[:l]
		sum_words.to_s.rjust(7) unless options[:w]
		sum_bytes.to_s.rjust(7) unless options[:c]
	else
		sum_lines = ''.rjust(0) unless options[:l]
		sum_words = ''.rjust(0) unless options[:w]
		sum_bytes = ''.rjust(0) unless options[:c]
	end

	puts " #{sum_lines} #{sum_words} #{sum_bytes} total"
end
