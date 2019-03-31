# Little experiment with the Fibonacci sequence.
# I'd like to think it sounds nicer than random
# notes, but it's probably about the same.

use_random_seed 573114
use_synth :pluck

fib = [1,1,2,3,5,8,13,21].ring
slp_idx = rand_i(fib.length)

bm_scale = (scale :b3, :minor).ring
note_idx = rand_i(bm_scale.length)

live_loop :test do
  play bm_scale[note_idx]
  sleep fib[slp_idx] * 0.1  # Let's not sleep for tooooo long
  note_idx += fib[slp_idx]
  slp_idx += [-1, 1].choose
end
