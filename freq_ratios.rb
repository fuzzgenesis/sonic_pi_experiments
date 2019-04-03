# Exploring consonance and dissonance with
# frequency ratios.

use_random_seed 1192038
# TODO this is gross
FIRST_20_PRIMES = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71]

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

  # The ratios should all be floats
  # to prevent integer division mishaps.
  ratios = ratios.map {|x| Float(x)}
  puts ratios
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

def generate_from_primes(primes, max_iter)
  # Generate a number by multiplying
  # randomly chosen primes from a certain subset
  n = primes.choose
  (1..max_iter).to_a.choose.times do
    n *= primes.choose
  end
  return n
end

def chord_with_limit(root, n, l)
  # Generate a chord from root, with
  # n notes and dissonance proportional to l.
  # For now, l should be a small prime number.
  # TODO I guess it's not necessarily the "root"
  # after going through this function

  # l is the largest prime factor any of
  # our ratio numbers can have
  idx = FIRST_20_PRIMES.index(l)
  available_primes = FIRST_20_PRIMES[0, idx]
  ratios = [l * generate_from_primes(available_primes, 2)]
  # Choose the proportions, basically at random
  # TODO prevent it from choosing the same number twice :|
  (n - 1).times do
    ratios.push(generate_from_primes(available_primes, 3))
  end
  return create_chord(root, ratios.sort)
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
  f3 = f2 * (6.0/5)
  n2 = freq_to_note(f2)
  n3 = freq_to_note(f3)
  play n
  play n2
  play n3
  sleep 2
  # Finally, use create_chord
  play_chord create_chord(:a4, [4, 5, 6])
end

# Examples
use_synth :fm
# Something consonant (5 limit)
play_chord create_chord(:b3, [2, 3, 5])
##| play_chord chord_with_limit(:b3, 3, 5)  # TODO this does NOT sound consonant :( time to go deeper
sleep 1
# Something dissonant (11 limit), configurable
play_chord chord_with_limit(:b3, 3, 11)
sleep 1
# Something really dissonant (71 limit???)
play_chord create_chord(:b3, [13, 59, 71])
##| play_chord chord_with_limit(:b3, 3, 71)
sleep 1
