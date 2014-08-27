require 'rubygems'
require 'json'

file = File.read('data.json', encoding: 'UTF-8')
data = JSON.parse(file)


def normalize_version(v)
  v.gsub(/Ember /, '').gsub(/0\.9$/,'0.9.0')
end


since_hash = {}

data['classes'].each do |cn, cd|
  next unless since = cd["since"]
  since = normalize_version(since)
  since_hash[since] ||= {}
  since_hash[since]['classes'] ||= []
  since_hash[since]['classes'] << cd["name"]
end

data['classitems'].each do |cd|
  next unless since = cd["since"]
  since = normalize_version(since)
  since_hash[since] ||= {}
  item_type = cd['itemtype']
  class_name = cd["class"]

  since_hash[since]['classitems'] ||= {}
  since_hash[since]['classitems'][class_name] ||= {}
  since_hash[since]['classitems'][class_name][item_type] ||= []
  since_hash[since]['classitems'][class_name][item_type] << cd["name"]

end


out = File.open 'README.md', 'w'
since_keys = since_hash.keys.sort
since_keys.each do |sk|
  out.puts '#' + sk
  if since_hash[sk]['classes']
    since_hash[sk]['classes'].sort.each do |cn|
      out.puts "* *[#{cn}](http://emberjs.com/api/classes/#{cn})*"
    end
    out.puts ""
  end

  if since_hash[sk]['classitems']
    classes = since_hash[sk]['classitems'].keys.sort
    classes.each do |cn|
      next unless since_hash[sk]['classitems'][cn]
      %w(method property event).each do |it|
        next unless since_hash[sk]['classitems'][cn][it]
        # out.puts ""
        since_hash[sk]['classitems'][cn][it].each do |ci|
          out.puts "* [#{cn}.#{ci}](http://emberjs.com/api/classes/#{cn}##{it}_#{ci})"
        end
      end

    end
    out.puts ""
  end



end
