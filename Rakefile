require 'tempfile'

require 'rspec/core/rake_task'

require 'meme_captain'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc 'Generate various sample memes and open them in a browser'
task 'sample' do
  source_images = {
      gif: File.read(File.join(%w{spec assets otter.gif})),
      jpg: File.read(File.join(%w{spec assets town_crier.jpg})),
      png: File.read(File.join(%w{spec assets me_gusta.png})),
  }

  words = %w{the quick brown fox jumped over the lazy dog}.cycle

  dir = Dir.mktmpdir

  word_tests = [1] +(5..50).step(5).to_a

  html = File.join(dir, 'sample.html')
  open(html, 'w') do |f|
    source_images.each do |ext, data|
      word_tests.each do |num_words|
        img_file = File.join(dir, "i#{num_words}.#{ext}")
        puts img_file
        MemeCaptain.meme_top_bottom(data, words.take(num_words).join(' '), nil, font: 'Impact-Regular').write(img_file)
        f.write("<img src=\"#{img_file}\">\n")
      end
    end
  end

  `open #{html}`
end
