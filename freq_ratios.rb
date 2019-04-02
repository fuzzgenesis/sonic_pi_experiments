# Exploring consonance and dissonance with
# frequency ratios.
# 
# # TODO the consonance/dissonance is actually defined by
# the limit of the ratios, not just the value of the numbers

def note_to_freq(note)
  # Get the frequency for this note.
  # (On a piano it would be note-49,
  # since a4 is the 49th key,
  # but in sonic pi a4 is 69)
  return 440 * (2**((note-69)/12.0))
end

def freq_to_note(freq)
  # Get the note for a given frequency.
  return 69 + 12 * (Math.log(freq/440.0) / Math.log(2))
end

def create_chord(root, ratios)
  # Given a root note and a list of
  # frequency ratios, create a chord.
  # Theoretically, smaller numbers
  # in the ratio list will sound more consonant.
  # See https://pages.mtu.edu/~suits/chords.html
  #
  # Example: create_chord(69, [4.0, 5.0, 6.0])) gives you
  # an A major chord (frequencies 440, 550, 660)
  #
  # Note: the ratios should all be floats
  # to prevent integer division mishaps.
  
  notes = [root]
  freq = note_to_freq(root)
  # TODO I'm sure Ruby has a nicer loop syntax, I'm just lazy
  idx = 0
  (ratios.length - 1).times do
    freq *= (ratios[idx + 1]/ratios[idx])
    notes.push(freq_to_note(freq))
    idx += 1
  end
  return notes
end


define :test_a_major do
# Test: these 3 chords should all sound the same
use_synth :fm
# First, play it the sonic pi way
play_chord chord(:a4, :major)
sleep 2
# Next, calculate the frequencies and notes manually
n = 69
f = note_to_freq(n)
f2 = f * (5.0/4)
    # Whyyyy is it indenting like this D:
    f3 = f2 * (6.0/5)
    n2 = freq_to_note(f2)
    n3 = freq_to_note(f3)
    play n
    play n2
    play n3
    sleep 2
    
    # Finally, use create_chord
    play_chord create_chord(:a4, [4.0, 5.0, 6.0])
  end
  
  use_synth :fm
  # Something consonant
  play_chord create_chord(:b3, [2.0, 3.0, 5.0])
  sleep 1
  # Something dissonant
  play_chord create_chord(:b3, [13.0, 71.0, 97.0])
  
  
  