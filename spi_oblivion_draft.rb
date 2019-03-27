# Sonic Pi instrumental cover of "Oblivion" by Grimes
# !!VERY FAR FROM FINISHED!!
use_random_seed 133337
use_bpm 156

#########################
# SYNTHS
#########################
define :main_synth do |note|
  # Set the sound of our primary synth.
  #
  # Args:
  #   note - single note to play (e.g. 62, :d3)
  with_synth :prophet do
    with_fx :lpf, cutoff: 90 do
      with_fx :echo, phase: 0.25, mix: [0,0,0,0.25].choose do  # TODO there has to be a prettier way D:
        play note,
          amp: rrand(0.8, 1.1),
          attack: 0.1,
          decay: 0.05,
          sustain_level: 0.7,
          release: 1,
          pan: rrand(-0.5, 0.5)
      end
    end
  end
  sleep 0.5
end

define :synth_beat do |root|
  # Construct the main synth beat.
  #
  # Args:
  #  root - first note of the beat, used to calculate offsets
  
  pattern = [0, 0, 12, 7,
             0, 0, 0, 7,
             0, 0, 12, 7,
             0, 12, 7, 7].ring + root
  16.times do
    main_synth pattern.tick
  end
end

define :synth_loop do
  # Main synth loop just ping pongs between d3 and b2
  synth_beat :d3
  synth_beat :b2
end

define :aah_sound do |synth, amp|
  # Ethereal vocal bits I don't feel like singing
  #
  # Args:
  #   synth - built in synth sound to use
  #   amp - how loud to be (0, 1)
  use_synth synth
  with_fx :reverb do
    play :fs,
      amp: amp,
      attack: 0.2,
      decay_level: 0.6,
      decay: 0.2,
      pan: rrand(-0.5, 0.5),
      ##| pan: [0.5, -0.5].ring.tick,
      release: rrand(6, 8)
  end
end

define :end_synth do |note, len|
  # Look, naming is one of the two hardest
  # problems in computer science, okay? It's
  # a synth that comes in near the end.
  #
  # Args:
  #   note - note to play
  #   len - length of time (in beats) to both sustain and sleep
  use_synth :hoover
  play note, amp: rrand(0.3, 0.4), attack: 0.1, sustain: len, release: 0
  sleep len
end

define :end_synth_loop do |root|
  # Defines the pattern for this synth
  #
  # Args:
  #   root - note to calculate offsets
  pattern = [0, 1, 2, 3, 0, -2].ring
  times = [2.5, 0.5, 0.5, 0.5, 3, 1].ring
  
  # TODO I hate that I can't just use "play_pattern_timed" for this
  idx = 0
  2.times do
    pattern.length.times do
      end_synth (pattern + root)[idx], times[idx]
      idx = idx + 1
    end
  end
end

#########################
# DRUMS
#########################

# TODO abstract out all these sleep parameters

define :kick do |slp|
  # Set the sound of the kick(? I guess) drum
  #
  # Args:
  #   slp - sleep time after sample
  sample :drum_heavy_kick,
    rate: 1,
    pitch_dis: 0.001
  sleep slp
end

define :snare_1 do |slp|
  # Set the sound of the first snare
  #
  # Args:
  #   slp - sleep time after sample
  sample :drum_snare_soft
  sleep slp
end

define :snare_2 do |slp|
  # Sound of the second snare
  #
  # Args:
  #   slp - sleep time after sample
  sample :drum_snare_hard,
    amp: 0.5,
    finish: 0.5
  sleep slp
end

define :common_drum_part do
  # A repeated drum part
  kick 1
  snare_1 0.5
  kick 0.5
  # Maybe echo, maybe don't
  # TODO is there a more elegant way to express this?
  if one_in(5)
    with_fx :echo, amp: 0.75, phase: 0.2, decay: 0.2, mix: 0.25 do
      kick 1
    end
  else
    kick 1
  end
end

define :main_drum_beat do
  # Construct the drum beat
  3.times do
    common_drum_part
    snare_1 1
  end
  common_drum_part
  snare_2 1
end


#########################
# THE ACTUAL SONG
#########################

# Main thread, will send cues
in_thread do
  synth_loop
  cue :drum_beat  # Start drums after first synth loop
  1.times do
    synth_loop
  end
  cue :end_synth  # start end synth
  loop do
    synth_loop
  end
end

# Drums
in_thread do
  sync :drum_beat
  loop do
    main_drum_beat
  end
end

# Additional synths
in_thread do
  sync :drum_beat  # Maybe I should rename this cue
  loop do
    aah_sound :sine, 0.4
    aah_sound :dsaw, 0.1
    sleep 16
  end
end

in_thread do
  sync :end_synth
  2.times do
    end_synth_loop :d3
    end_synth_loop :b2
  end
end


