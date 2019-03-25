# Sonic Pi instrumental cover of "Oblivion" by Grimes
# !!VERY FAR FROM FINISHED!!

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

define :common_synth_part do |n1, n2, n3|
  # First part of the beat, which is the same
  # for both sections.
  #
  # Args:
  #   n1, n2, n3 - 3 different notes
  2.times do
    main_synth n1
  end
  main_synth n3
  main_synth n2
end

define :synth_beat do |root|
  # Construct the main synth beat.
  #
  # Args:
  #  root - first note of the beat, used to calculate offsets
  #
  # TODO: is there any way to avoid how clunky this feels?
  n1 = root
  n2 = root + 7
  n3 = root + 12
  
  common_synth_part n1, n2, n3
  3.times do
    main_synth n1
  end
  main_synth n2
  
  common_synth_part n1, n2, n3
  main_synth n1
  main_synth n3
  2.times do
    main_synth n2
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
      release: 8
  end
end

#########################
# DRUMS
#########################

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


