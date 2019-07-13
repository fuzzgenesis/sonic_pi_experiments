# Trying to recreate "L's Theme B" from Death Note
# Not done
use_bpm 210
use_synth :pluck

define :budget_ppt do |notes, sleeps|
  # Like play_pattern_timed, but
  # without the unwanted side effects
  idx = 0
  notes.length.times do
    play notes[idx]
    sleep sleeps[idx]
    idx += 1
  end
end

define :intro_guitar_loop do
  use_synth :pluck
  root = :e3
  sequence = [3, 0, 5, 0,
              3, 0, 7, 3].ring + root
  sleeps = [1, 3] * 4
  budget_ppt sequence, sleeps
end

define :high_guitar_loop do
  use_synth  :pluck
  root = :a4
  sequence = [7, 0, 2, 5,
              12, 9, 7, 0,
              2, 5, 12, 9,
              5, 7, 9, 10].ring + root
  sleeps = [1] * sequence.length
  budget_ppt sequence, sleeps
end

define :drum_loop_1 do
  8.times do
    sample :drum_heavy_kick, amp: 1
    sample :drum_snare_soft, amp: 0.25
    ##| sample :drum_snare_soft, amp: 0.5
    sleep 1
    sample :drum_snare_soft, amp: 0.75
    sleep 1
    
  end
end

define :bass do
  use_synth :fm
  root = :a2
  sequence = [
    2,
    0, 2, 5, 7,
  0, 2, 2, 2].ring + root
  times = [
    3,
    0.5, 0.5, 1, 2,
  1, 1.5, 1.5, 5]
  budget_ppt sequence, times
end



# Main thread
# TODO organize this better
in_thread do
  sleep 1
  cue :intro_guitar
end


in_thread do
  1.times do
    intro_guitar_loop
  end
  cue :hgl
  loop do
    intro_guitar_loop
  end
end

in_thread do
  with_fx :reverb, room: 0.5 do
    with_fx :flanger, phase: 8 do
      sync :hgl
      sleep 0.02
      1.times do
        high_guitar_loop
      end
      cue :drums_come_in
      loop do
        high_guitar_loop
      end
    end
  end
end

in_thread do
  sync :drums_come_in
  1.times do
    drum_loop_1
  end
  cue :bass_comes_in
  loop do
    drum_loop_1
  end
end

in_thread do
  sync :bass_comes_in
  loop do
    bass
  end
end


