# Sonic Pi instrumental cover of "Oblivion" by Grimes | Created by Fuzz Genesis
use_random_seed 133337
use_bpm 156

#########################
# SYNTHS
#########################
define :main_synth do |synth, note|
  # Set the sound of our primary synth.
  # Args:
  #   synth - synth sound to use
  #   note - single note to play (e.g. 62, :d3)
  with_synth synth do
    with_fx :lpf, cutoff: 90 do
      with_fx :echo, phase: 0.25, mix: [0,0,0,0.25].choose do  # TODO there has to be a prettier way D:
        play note,
          amp: rrand(0.6, 0.9),
          attack: 0.1,
          decay: 0.05,
          sustain_level: 0.7,
          release: 1,
          pan: rrand(-0.5, 0.5)
      end
    end
  end
end

define :synth_beat do |root|
  # Construct the main synth beat.
  # Args:
  #  root - first note of the beat, used to calculate offsets
  pattern = [0, 0, 12, 7,
             0, 0, 0, 7,
             0, 0, 12, 7,
             0, 12, 7, 7].ring + root
  idx = 0
  pattern.length.times do
    main_synth :prophet, pattern[idx]
    main_synth :fm, pattern[idx]
    idx = idx + 1
    sleep 0.5
  end
end

define :synth_loop do
  # Main synth loop just ping pongs between d3 and b2
  # 16 beats long
  synth_beat :d3
  synth_beat :b2
end

define :aah_sound do |synth, amp|
  # Ethereal vocal bits I don't feel like singing
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
      release: rrand(6, 8)
  end
end

define :end_synth do |note, len|
  # Synth that comes in near the end.
  # Args:
  #   note - note to play
  #   len - length of time (in beats) to both sustain and sleep
  use_synth :dsaw
  play note, amp: 0.2, attack: 0.05, sustain: len, release: 0
  sleep len
end

define :end_synth_loop do |root|
  # Defines the pattern for this synth.
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

define :synth3 do
  # The synth that comes in with the piano
  use_synth :square
  pattern = [:d3,:cs3, :a2, :fs2].ring + 12
  with_fx :lpf, cutoff: 80 do
    play_pattern_timed pattern, [0.25]
    sleep 0.5
  end
end

# Sparkly sounds
define :sparkle_synth do |note|
  with_fx :hpf, cutoff: 100 do
    with_fx :reverb, room: 1 do
      use_synth :dsaw
      play note, amp: 0.15, sustain: 3, release: 2
      use_synth :tech_saws
      play note, amp: 0.05, sustain: 3, release: 2
    end
  end
end

define :sparkle_pattern do
  pattern = [:b5, :a5, :g5, :fs5,
             :d5, :d5,
             :b5, :a5, :g5, :fs5,
             :d5, :d5, :e5, :fs5,
             :d6,
             :b5,
             :b5, :cs6, :d6, :e6, :fs6, :g6, :a6,
             :fs6, :d6].ring
  times = [1, 1, 1, 1,
           2, 2.5,
           1, 0.5, 1, 1,
           1, 0.5, 0.5, 2,
           4,
           4,
           1, 1, 0.5, 1, 1, 0.5, 1,
           1, 1].ring
  idx = 0
  pattern.length.times do
    sparkle_synth pattern[idx]
    sleep times[idx]
    idx += 1
  end
end

#########################
# ALL THE FKN PIANO PARTS
#########################

define :piano1 do
  use_synth :piano
  p1 = (knit :b4, 1, :a4, 1, :fs4, 6)
  p2 = ([:fs4, :d4] * 4).ring
  pattern = p1 + p2
  pattern.length.times do
    play pattern.tick
    sleep 0.5
  end
end

define :piano2 do
  use_synth :piano
  8.times do
    play :d5
    play :b4
    sleep 0.5
  end
  p = [:d5, :cs5, :b4, :cs5, :d5]
  times = [1, 1, 1, 1, 2]
  play_pattern_timed p, times
end

define :piano3 do
  use_synth :piano
  p = (knit :cs4, 1, :d4, 3)
  3.times do
    p.length.times do
      play p.tick
      sleep 0.5
    end
  end
end

define :piano4 do
  use_synth :piano
  p = ([:b5, :a5, :fs5] * 4).ring
  p.length.times do
    play p.tick
    sleep 0.5
  end
end

define :piano5 do
  use_synth :piano
  p = ([:fs4, :fs4, :g4, :a4, :fs4])
  t = [0.5, 0.25, 0.25, 0.5, 0.5]
  4.times do
    play_pattern_timed p, t
  end
end

#########################
# DRUMS
#########################

# TODO abstract out all these sleep parameters

def kick(slp)
  # Kick drum
  # Args:
  #   slp - sleep time after sample
  sample :drum_heavy_kick,
    rate: 1,
    pitch_dis: 0.001,
    lpf: 110
  sleep slp
end

define :snare_1 do |slp|
  # Set the sound of the first snare
  # Args:
  #   slp - sleep time after sample
  sample :drum_snare_soft
  sleep slp
end

define :snare_2 do |slp|
  # Sound of the second snare
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
    with_fx :echo, amp: 0.6, phase: 0.2, decay: 0.2, mix: 0.25 do
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
# VOCALS
#########################
define :all_vocs do
  smpl = "/Users/jaguarshark/personal/music/oblivion_samples/all_vocs.wav"
  sample smpl, amp: 1.5
end

#########################
# THE ACTUAL SONG
#########################
# Main thread, sends cues and sleeps
in_thread do
  sleep 4  # IDK why this is necessary, but it is
  # TODO 1 bar of intro
  cue :all_vocals
  sleep 0.17  # Experimentally determined  :|
  cue :synth_loop
  sleep 32
  cue :drum_beat
  cue :aah
  sleep 256
  cue :piano
  cue :drum_beat
  sleep 64
  cue :sparkles
  sleep 32
  cue :end_synth
  cue :drum_beat
  sleep 64
  cue :synth_loop
end

# Vocals
in_thread do
  sync :all_vocals
  all_vocs
end

# Main synth
in_thread do
  sync :synth_loop
  20.times do
    synth_loop
  end
  sync :synth_loop
  10.times do
    synth_loop
  end
end

# Drums
in_thread do
  # drum beat is 16 beats / 4 bars long
  sync :drum_beat
  14.times do
    main_drum_beat
  end  # bar 65
  cue :kick_only
  sync :drum_beat
  # And return to normal drum pattern at bar 73
  5.times do
    main_drum_beat
  end  # TODO there's some fading effect but eh. Bar 137
  cue :kick_only
  sync :drum_beat
  10.times do
    main_drum_beat
  end
end

in_thread do
  sync :kick_only
  16.times do
    kick 2
  end  # bar 73
  sync :kick_only
  6.times do
    kick 2
  end
end

# Additional synths
in_thread do
  sync :aah
  5.times do
    aah_sound :sine, 0.3
    aah_sound :dsaw, 0.1
    sleep 16
  end
  aah_sound :sine, 0.3
  aah_sound :dsaw, 0.1
  sleep 64
  10.times do
    aah_sound :sine, 0.3
    aah_sound :dsaw, 0.1
    sleep 16
  end
end

# Piano
in_thread do
  sync :piano
  with_fx :level, amp: 0.3 do
    3.times do
      piano1
    end
  end
end

in_thread do
  sync :piano
  sleep 4
  with_fx :level, amp: 0.3 do
    3.times do
      piano1
    end
  end
end

in_thread do
  sync :piano
  sleep 8
  with_fx :level, amp: 0.4 do
    piano2
    sleep 6
    piano2
    sleep 22
    piano2
  end
end

in_thread do
  sync :piano
  sleep 32
  with_fx :level, amp: 0.3 do
    3.times do
      piano3
      sleep 2
    end
  end
end

in_thread do
  sync :piano
  sleep 34
  with_fx :level, amp: 0.2 do
    3.times do
      piano4
      sleep 2
    end
  end
end

in_thread do
  sync :piano
  sleep 48
  with_fx :level, amp: 0.5 do
    2.times do
      piano5
    end
  end
end

# Synth that accompanies the piano
in_thread do
  sync :piano
  with_fx :level, amp: 0.1 do
    22.times do
      synth3
    end
  end
end

in_thread do
  sync :sparkles
  sparkle_pattern
end

# End synth
in_thread do
  sync :end_synth
  with_fx :reverb, room: 0.8 do
    8.times do
      end_synth_loop :d3
      end_synth_loop :b2
    end
  end
end




