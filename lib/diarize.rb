require "rjb"

RJB_LOAD_PATH = [File.join(File.expand_path(File.dirname(__FILE__)), 'diarize', 'LIUM_SpkDiarization-4.2.jar')].join(File::PATH_SEPARATOR)
RJB_OPTIONS   = ['-Xms16m', '-Xmx1024m']

Rjb::load(RJB_LOAD_PATH, RJB_OPTIONS)

require "byebug"
require "matrix"
require "audio-playback"
require "diarize/version"
require "diarize/lium"
require "diarize/audio"
require "diarize/segment"
require "diarize/segmentation"
require "diarize/audio_player"
require "diarize/super_vector"

# Extenions to the {Ruby-Java Bridge}[http://rjb.rubyforge.org/] module that
# adds a generic Java object wrapper class.
module Rjb
  # A generic wrapper for a Java object loaded via the Ruby Java Bridge.  The
  # wrapper class handles intialization and stringification, and passes other
  # method calls down to the underlying Java object.  Objects returned by the
  # underlying Java object are converted to the appropriate Ruby object.
  #
  # This object is enumerable, yielding items in the order defined by the Java
  # object's iterator.
  class JavaObjectWrapper
    include Enumerable

    # The underlying Java object.
    attr_reader :java_object

    # Initialize with a Java object <em>obj</em>.  If <em>obj</em> is a
    # String, assume it is a Java class name and instantiate it.  Otherwise,
    # treat <em>obj</em> as an instance of a Java object.
    def initialize(obj, *args)
      @java_object = obj.class == String ?
      Rjb::import(obj).send(:new, *args) : obj
    end

    # Enumerate all the items in the object using its iterator.  If the object
    # has no iterator, this function yields nothing.
    def each
      if @java_object.getClass.getMethods.any? {|m| m.getName == "iterator"}
        i = @java_object.iterator
        while i.hasNext
          yield wrap_java_object(i.next)
        end
      end
    end # each

    # Reflect unhandled method calls to the underlying Java object.
    def method_missing(m, *args)
      wrap_java_object(@java_object.send(m, *args))
    end

    # Convert a value returned by a call to the underlying Java object to the
    # appropriate Ruby object as follows:
    # * RJB objects are placed inside a generic JavaObjectWrapper wrapper.
    # * <tt>java.util.ArrayList</tt> objects are converted to Ruby Arrays.
    # * <tt>java.util.HashSet</tt> objects are converted to Ruby Sets
    # * Other objects are left unchanged.
    #
    # This function is applied recursively to items in collection objects such
    # as set and arrays.
    def wrap_java_object(object)
      if object.kind_of?(Array)
        object.collect {|item| wrap_java_object(item)}
      # Ruby-Java Bridge Java objects all have a _classname member which tells
      # the name of their Java class.
      elsif object.respond_to?(:_classname)
        case object._classname
        when /java\.util\.ArrayList/
          # Convert java.util.ArrayList objects to Ruby arrays.
          array_list = []
          object.size.times do
            |i| array_list << wrap_java_object(object.get(i))
          end
          array_list
        when /java\.util\.HashSet/
          # Convert java.util.HashSet objects to Ruby sets.
          set = Set.new
          i = object.iterator
          while i.hasNext
            set << wrap_java_object(i.next)
          end
          set
        else
          # Pass other RJB objects off to a handler.
          wrap_rjb_object(object)
        end # case
      else
        # Return non-RJB objects unchanged.
        object
      end # if
    end # wrap_java_object

    # By default, all RJB classes other than <tt>java.util.ArrayList</tt> and
    # <tt>java.util.HashSet</tt> go in a generic wrapper.  Derived classes may
    # change this behavior.
    def wrap_rjb_object(object)
      JavaObjectWrapper.new(object)
    end

    # Show the classname of the underlying Java object.
    def inspect
      "<#{@java_object._classname}>"
    end

    # Use the underlying Java object's stringification.
    def to_s
      toString
    end

    protected :wrap_java_object, :wrap_rjb_object
  end # JavaObjectWrapper
end # Rjb
