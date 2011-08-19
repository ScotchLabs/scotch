class Time
  def yesterday?
    Time.utc(self.year,self.month,self.day) == Time.utc(Time.now.year,Time.now.month,Time.now.day).advance(:days => -1)
  end
  def tomorrow?
    Time.utc(self.year,self.month,self.day) == Time.utc(Time.now.year,Time.now.month,Time.now.day).advance(:days => 1)
  end
end
