# Little experiment with the Fibonacci sequence.
# I'd like to think it sounds nicer than random
# notes, but it's probably about the same.

use_random_seed 573114
use_synth :pluck

def generate_fib(n)
  # Generates a palindromic Fibonacci sequence
  # Don't make n anything too big
  if n > 8
    puts "n > 8 might have some preeetty long pauses FYI"
  end
  arr = [1, 1]
  next_fib = 2
  (n-1).times do
    idx = arr.length / 2
    arr.insert(idx, next_fib)
    arr.insert(idx, next_fib)
    next_fib += arr[(arr.length / 2) - 2]
  end
  return arr
end

def palindrome_scale(scl)
  # Wrap the scale around so it's continuous
  # in both directions
  reversed = scl.reverse
  reversed = reversed[1, reversed.length - 2]  # Maybe not necessary?
  return scl + reversed
end


fib = generate_fib(5).ring
slp_idx = rand_i(fib.length)

bm_scale = (scale :b2, :minor, num_octaves: 3).ring
bm_palindrome = palindrome_scale(bm_scale).ring

note_idx = rand_i(bm_palindrome.length)

live_loop :test do
  note_idx += [-1, 1].choose * fib[slp_idx]
  slp_idx += [-1, 1].choose
  play bm_palindrome[note_idx]
  sleep fib[slp_idx] * 0.1
end



