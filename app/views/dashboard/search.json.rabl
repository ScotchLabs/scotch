object false

node :results do
  (@users + @shows + @groups).map do |r|
    thumbnail = ""

    if r.is_a? User
      thumbnail = r.headshot(:thumb)
      link = user_path(r)
    else
      thumbnail = r.image(:thumb)
      link = group_path(r)
    end

    {id: r.id, name: r.name, type: r.class.name, thumbnail: thumbnail,
      link: link}
  end
end

