# -*- coding: utf-8 -*-
require 'bosonnlp'

# Mixin module
module BosonnlpMixin
  def method_missing(name, *args)
    case name.to_s
    when /^(c_|m_|s_)(.+)$/
      @@nlp ||= Bosonnlp.new
      data = self
      data = [data] if self.class == String

      @@nlp.send name, data, *args
    else
      super
    end
  end
end

# Mixin it
class Array
  include BosonnlpMixin
end

# Mixin it
class String
  include BosonnlpMixin
end
