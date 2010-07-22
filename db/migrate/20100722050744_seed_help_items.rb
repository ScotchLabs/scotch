class SeedHelpItems < ActiveRecord::Migration
  def self.up
    HelpItem.create(:name => "SMC", :anchor => "why-smc", :display_text => "why do you want this?",
      :message => "We'd like your smc because...well I don't know. We're the mafia.")
    HelpItem.create(:name => "Phone Number", :anchor => "why-phone", :display_text => "why do you want this?",
      :message => "-Sometimes- At least 2463 times a day during a show, someone important needs to call someone else important. So if you ever want to be important it's a good idea to make your phone number public.")
    HelpItem.create(:name => "RedCloth", :anchor => "redcloth", :display_text => "RedCloth",
      :message => "[\"RedCloth\":http://redcloth.org/]  enables us to use the [\"Textile markup language\":http://en.wikipedia.org/wiki/Textile_(markup_language)]. Here are some examples of how to format certain things ([\"full manual\":http://redcloth.org/textile/]):

      <notextile><pre>h1. Foo --> creates an h1 element<br>
      h2. Bar --> creates an h2 element<br>
      _word_ --> italics<br>
      *word* --> bold<br>
      -word- --> strikethrough<br>
      +word+ --> underline<br>
      @word@ --> code<br>
      ==word== --> word will not be textiled<br>
      # item1 --> ordered list item<br>
      * item1 --> unordered list item</pre></notextile>")
  end

  def self.down
  end
end
