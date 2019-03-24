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
      play note,
        attack: 0.1,
        decay: 0.05,
        sustain_level: 0.7,
        release: 1,
        pan: rrand(-0.5, 0.5)
    end
  end
  sleep 0.5
end

# Define a couple functions to avoid typing
# "main_synth root" a million times
define :n1 do |note|
  main_synth note
end
define :n2 do |note|
  main_synth note + 7
end
define :n3 do |note|
  main_synth note + 12
end

define :common_synth_part do |note|
  # First part of the beat is
  # the same for both sections
  2.times do
    n1 note
  end
  n3 note
  n2 note
end

define :synth_beat do |root|
  # Construct the main synth beat.
  #
  # Args:
  #  root - first note of the beat, used to calculate offsets
  #
  # TODO: is there any way to avoid how clunky this feels?
  
  common_synth_part root
  3.times do
    n1 root
  end
  n2 root
  
  common_synth_part root
  n1 root
  n3 root
  2.times do
    n2 root
  end
end

define :synth_loop do
  # Main synth loop just ping pongs between d3 and b2
  synth_beat :d3
  synth_beat :b2
end

define :aah_sound do
  # Ethereal vocal bits I don't feel like singing
  with_fx :reverb, room: 0.7 do
    sample :ambi_choir,
      pitch: -3,  # It starts as an A but needs to be F#... however, this sounds awful
      lpf: 90
  end
  sleep 16
end

#########################
# DRUMS
#########################

define :kick do |slp|
  # Set the sound of the kick(? I guess) drum
  sample :drum_heavy_kick,
    rate: 1,
    pitch_dis: 0.001
  sleep slp
end

define :snare_1 do |slp|
  # Set the sound of the first snare
  sample :drum_snare_soft
  sleep slp
end

define :snare_2 do |slp|
  # Sound of the second snare
  sample :drum_snare_hard,
    amp: 0.5,
    finish: 0.7
  sleep slp
end

define :common_drum_part do
  # A repeated drum part
  kick 1
  snare_1 0.5
  kick 0.5
  kick 1
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

# Choir sounds
in_thread do
  sync :drum_beat  # Maybe I should rename this cue
  4.times do
    aah_sound
  end
end


