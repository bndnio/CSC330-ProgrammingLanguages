# a little language for 2D geometry objects

# each subclass of GeometryExpression, including subclasses of GeometryValue,
#  needs to respond to messages preprocess_prog and eval_prog
#
# each subclass of GeometryValue additionally needs:
#   * shift
#   * intersect, which uses the double-dispatch pattern
#   * intersectPoint, intersectLine, and intersectVerticalLine for 
#       for being called by intersect of appropriate clases and doing
#       the correct intersection calculuation
#   * (We would need intersectNoPoints and intersectLineSegment, but these
#      are provided by GeometryValue and should not be overridden.)
#   *  intersectWithSegmentAsLineResult, which is used by 
#      intersectLineSegment as described in the assignment
#
# you can define other helper methods, but will not find much need to

# Note: geometry objects should be immutable: assign to fields only during
#       object construction

# Note: For eval_prog, represent environments as arrays of 2-element arrays
# as described in the assignment

class GeometryExpression  
  # do *not* change this class definition
  Epsilon = 0.00001
end

class GeometryValue 
  # do *not* change methods in this class definition
  # you can add methods if you wish

  protected
  # some helper methods that may be generally useful
  def real_close(r1,r2) 
      (r1 - r2).abs < GeometryExpression::Epsilon
  end
  def real_close_point(x1,y1,x2,y2) 
      real_close(x1,x2) && real_close(y1,y2)
  end
  # two_points_to_line could return a Line or a VerticalLine
  def two_points_to_line(x1,y1,x2,y2) 
      if real_close(x1,x2)
        VerticalLine.new x1
      else
        m = (y2 - y1).to_f / (x2 - x1)
        b = y1 - m * x1
        Line.new(m,b)
      end
  end

  public
  # we put this in this class so all subclasses can inherit it:
  # the intersection of self with a NoPoints is a NoPoints object
  def intersectNoPoints np
    np # could also have NoPoints.new here instead
  end

  # we put this in this class so all subclasses can inhert it:
  # the intersection of self with a LineSegment is computed by
  # first intersecting with the line containing the segment and then
  # calling the result's intersectWithSegmentAsLineResult with the segment
  def intersectLineSegment seg
    line_result = intersect(two_points_to_line(seg.x1,seg.y1,seg.x2,seg.y2))
    line_result.intersectWithSegmentAsLineResult seg
  end
end

class NoPoints < GeometryValue
  # do *not* change this class definition: everything is done for you
  # (although this is the easiest class, it shows what methods every subclass
  # of geometry values needs)

  # Note: no initialize method only because there is nothing it needs to do
  def eval_prog env 
    self # all values evaluate to self
  end
  def preprocess_prog
    self # no pre-processing to do here
  end
  def shift(dx,dy)
    self # shifting no-points is no-points
  end
  def intersect other
    other.intersectNoPoints self # will be NoPoints but follow double-dispatch
  end
  def intersectPoint p
    self # intersection with point and no-points is no-points
  end
  def intersectLine line
    self # intersection with line and no-points is no-points
  end
  def intersectVerticalLine vline
    self # intersection with line and no-points is no-points
  end
  # if self is the intersection of (1) some shape s and (2) 
  # the line containing seg, then we return the intersection of the 
  # shape s and the seg.  seg is an instance of LineSegment
  def intersectWithSegmentAsLineResult seg
    self
  end
end


class Point < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods

  # Note: You may want a private helper method like the local
  # helper function inbetween in the ML code
  attr_reader :x, :y
  def initialize(x,y)
    @x = x
    @y = y
  end

  def eval_prog env 
    self # all values evaluate to self
  end

  def preprocess_prog
    self # no pre-processing to do here
  end

  def shift(dx,dy)
    Point.new(@x+dx, @y+dy)
  end

  def intersect other
    other.intersectPoint self
  end

  def intersectPoint p
    if self.real_close_point(p.x, p.y, @x, @y) # intersection with point and point is point if same
      Point.new(@x, @y)
    else
      NoPoints.new
    end
  end

  def intersectLine line
    if self.real_close(@y, line.m*@x+line.b)
      Point.new(@x, @y)
    else 
      NoPoints.new
    end
  end

  def intersectVerticalLine vline
   if self.real_close(@x,vline.x)
    self
   else
    NoPoints.new
   end
  end

  # if self is the intersection of (1) some shape s and (2) 
  # the line containing seg, then we return the intersection of the 
  # shape s and the seg.  seg is an instance of LineSegment
  def intersectWithSegmentAsLineResult seg
    seg.intersectPoint(self)
  end
end

class Line < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  attr_reader :m, :b 
  def initialize(m,b)
    @m = m
    @b = b
  end

  def eval_prog env 
    self # all values evaluate to self
  end

  def preprocess_prog
    self # no pre-processing to do here
  end

  def shift(dx,dy)
    Line.new(@m, @b+dy-(dx*@m))
  end

  def intersect other
    other.intersectLine self
  end

  def intersectPoint p
    p.intersectLine(self)
  end

  def intersectLine line
    if self.real_close(@m, line.m)
      if self.real_close(@b, line.b)
        Line.new(@m, @b)
      else
        NoPoints.new
      end
    else
      x = (line.b - @b) / (@m - line.m)
      y = @m * x + @b
      Point.new(x, y)
    end
  end

  def intersectVerticalLine vline
    Point.new(vline.x, @m * vline.x + @b)
  end

  # if self is the intersection of (1) some shape s and (2) 
  # the line containing seg, then we return the intersection of the 
  # shape s and the seg.  seg is an instance of LineSegment
  def intersectWithSegmentAsLineResult seg
    seg.intersectLine(self)
  end
end

class VerticalLine < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  attr_reader :x
  def initialize x
    @x = x
  end

  def eval_prog env 
    self # all values evaluate to self
  end
  
  def preprocess_prog
    self # no pre-processing to do here
  end

  def shift(dx,dy)
    VerticalLine.new(@x+dx)
  end

  def intersect other
    other.intersectVerticalLine(self)
  end

  def intersectPoint p
    p.intersectVerticalLine(self)
  end

  def intersectLine line
    Point.new(@x, line.m * @x + line.b)
  end

  def intersectVerticalLine vline
    if self.real_close(@x, vline.x)
      VerticalLine.new(@x)
    else
      NoPoints.new
    end
  end

  # if self is the intersection of (1) some shape s and (2) 
  # the line containing seg, then we return the intersection of the 
  # shape s and the seg.  seg is an instance of LineSegment
  def intersectWithSegmentAsLineResult seg
    seg.intersectVerticalLine(self)
  end
end

class LineSegment < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  # Note: This is the most difficult class.  In the sample solution,
  #  preprocess_prog is about 15 lines long and 
  # intersectWithSegmentAsLineResult is about 40 lines long
  attr_reader :x1, :y1, :x2, :y2
  def initialize (x1,y1,x2,y2)
    @x1 = x1
    @y1 = y1
    @x2 = x2
    @y2 = y2
  end

  def eval_prog env 
    self # all values evaluate to self
  end

  def preprocess_prog
    if self.real_close_point(@x1, @y1, @x2, @y2)
      Point.new((@x1 < @x2 ? @x1 : @x2), (@y1 < @y2 ? @y1 : @y2))
    elsif real_close(@x1, @x2) && @y1 > @y2
      LineSegment.new(@x2, @y2, @x1, @y1)
    elsif @x1 > @x2 + GeometryExpression::Epsilon
      LineSegment.new(@x2, @y2, @x1, @y1)
    else
      LineSegment.new(@x1, @y1, @x2, @y2)
    end
  end

  def shift(dx,dy)
    LineSegment.new(@x1+dx, @y1+dy, @x2+dx, @y2+dy)
  end

  def intersect other
    other.intersectLineSegment self
  end

  def intersectPoint p
    def inBetween(v, end1, end2)
      (end1-GeometryExpression::Epsilon <= v and v <= end2+GeometryExpression::Epsilon) or (end2-GeometryExpression::Epsilon <= v and v <= end1+GeometryExpression::Epsilon)
    end

    if inBetween(p.x, @x1, @x2) and inBetween(p.y, @y1, @y2)
      Point.new(p.x, p.y)
    else
      NoPoints.new
    end
  end

  def intersectLine line
    m = (@y2-@y1)/(@x2-@x1)
    if real_close(line.m, m)
      b = (@y1-m*@x1)
      if real_close(line.b, b)
        LineSegment.new(@x1, @y1, @x2, @y2)
      else
        NoPoints.new
      end
    elsif (@y1 <= (line.m*@x1+line.b) and @y2 >= (line.m*@x2+line.b)) or (@y1 >= (line.m*@x1+line.b) and @y2 <= (line.m*@x2+line.b))
        line.intersect(Line.new(m, (@y1-m*@x1)))
    else
      NoPoints.new
    end
  end

  def intersectVerticalLine vline
    if real_close(@x1, @x2) or (real_close(@x1, vline.x) or real_close(@x2, vline.x))
      LineSegment.new(@x1, @y1, @x2, @y2)
    else
      m = (@y2-@y1)/(@x2-@x1)
      b = (@y1-m*@x1)
      if @x1 < vline.x and @x2 > vline.x
        vline.intersect(Line.new(m, b))
      else
        NoPoints.new
      end
    end
  end

  # if self is the intersection of (1) some shape s and (2) 
  # the line containing seg, then we return the intersection of the 
  # shape s and the seg.  seg is an instance of LineSegment
  def intersectWithSegmentAsLineResult seg
    x1start, y1start, x1end, y1end = @x1, @y1, @x2, @y2
    x2start, y2start, x2end, y2end = seg.x1, seg.y1, seg.x2, seg.y2

    if self.real_close(x1start, x1end)
      if y1start < y2start
        aXstart, aYstart, aXend, aYend = @x1, @y1, @x2, @y2
        bXstart, bYstart, bXend, bYend = seg.x1, seg.y1, seg.x2, seg.y2
      else
        aXstart, aYstart, aXend, aYend = seg.x1, seg.y1, seg.x2, seg.y2
        bXstart, bYstart, bXend, bYend = @x1, @y1, @x2, @y2
      end

      if real_close(aYend, bYstart)
        Point.new(aXend, bYstart) # just touching
      elsif aYend < bYstart
        NoPoints.new # disjoint
      elsif aYend > bYend
        LineSegment.new(bXstart,bYstart,bXend,bYend) # b inside a
      else
        LineSegment.new(bXstart,bYstart,aXend,aYend) # overlapping
      end
    else
      if x1start < x2start
        aXstart, aYstart, aXend, aYend = @x1, @y1, @x2, @y2
        bXstart, bYstart, bXend, bYend = seg.x1, seg.y1, seg.x2, seg.y2
      else
        aXstart, aYstart, aXend, aYend = seg.x1, seg.y1, seg.x2, seg.y2
        bXstart, bYstart, bXend, bYend = @x1, @y1, @x2, @y2
      end

      if real_close(aXend, bXstart)
        Point.new(aXend, aYend) # just touching
      elsif aXend < bXstart
        NoPoints.new # disjoint
      elsif aXend > bXend
        LineSegment.new(bXstart,bYstart,bXend,bYend) # b inside a
      else
        LineSegment.new(bXstart,bYstart,aXend,aYend) # overlapping
      end
    end
  end
end

# Note: there is no need for getter methods for the non-value classes

class Intersect < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  def initialize(e1,e2)
    @e1 = e1
    @e2 = e2
  end

  def eval_prog env 
    @e1.eval_prog(env).intersect(@e2.eval_prog(env))
  end

  def preprocess_prog
    Intersect.new(@e1.preprocess_prog, @e2.preprocess_prog)
  end

  def shift(dx,dy)
    raise "bad call to shift: only for shape values"
  end

  def intersect other
    raise "bad call to intersect: only for shape values"
  end

  def intersectPoint p
    raise "bad call to intersectPoint: only for shape values"
  end

  def intersectLine line
    raise "bad call to intersectLine: only for shape values"
  end

  def intersectVerticalLine vline
    raise "bad call to intersectVerticalLine: only for shape values"
  end

  # if self is the intersection of (1) some shape s and (2) 
  # the line containing seg, then we return the intersection of the 
  # shape s and the seg.  seg is an instance of LineSegment
  def intersectWithSegmentAsLineResult seg
    raise "bad call to intersectWithSegmentAsLineResult: only for shape values"
  end
end

class Let < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  # Note: Look at Var to guide how you implement Let
  def initialize(s,e1,e2)
    @s = s
    @e1 = e1
    @e2 = e2
  end

  def eval_prog env 
    @e2.eval_prog(env.unshift([@s, @e1.eval_prog(env)]))
  end

  def preprocess_prog
    Let.new(@s, @e1.preprocess_prog, @e2.preprocess_prog)
  end

  def shift(dx,dy)
    raise "bad call to shift: only for shape values"
  end

  def intersect other
    raise "bad call to intersect: only for shape values"
  end

  def intersectPoint p
    raise "bad call to intersectPoint: only for shape values"
  end

  def intersectLine line
    raise "bad call to intersectLine: only for shape values"
  end

  def intersectVerticalLine vline
    raise "bad call to intersectVertialLine: only for shape values"
  end

  # if self is the intersection of (1) some shape s and (2) 
  # the line containing seg, then we return the intersection of the 
  # shape s and the seg.  seg is an instance of LineSegment
  def intersectWithSegmentAsLineResult seg
    raise "bad call to intersectWithSegmentAsLineResult: only for shape values"
  end
end

class Var < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  def initialize s
    @s = s
  end

  def eval_prog env # remember: do not change this method
    pr = env.assoc @s
    raise "undefined variable" if pr.nil?
    pr[1]
  end

  def preprocess_prog
    self # no pre-processing to do here
  end

  def shift(dx,dy)
    raise "bad call to shift: only for shape values"
  end

  def intersect other
    raise "bad call to intersect: only for shape values"
  end

  def intersectPoint p
    raise "bad call to intersectPoint: only for shape values"
  end

  def intersectLine line
    raise "bad call to intersectLine: only for shape values"
  end

  def intersectVerticalLine vline
    raise "bad call to intersectVertialLine: only for shape values"
  end

  # if self is the intersection of (1) some shape s and (2) 
  # the line containing seg, then we return the intersection of the 
  # shape s and the seg.  seg is an instance of LineSegment
  def intersectWithSegmentAsLineResult seg
    raise "bad call to intersectWithSegmentAsLineResult: only for shape values"
  end
end

class Shift < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  def initialize(dx,dy,e)
    @dx = dx
    @dy = dy
    @e = e
  end

  def eval_prog env 
    @e.eval_prog(env).shift(@dx, @dy)
  end

  def preprocess_prog
    Shift.new(@dx, @dy, @e.preprocess_prog)
  end

  def shift(dx,dy)
    raise "bad call to shift: only for shape values"
  end

  def intersect other
    raise "bad call to intersect: only for shape values"
  end

  def intersectPoint p
    raise "bad call to intersectPoint: only for shape values"
  end

  def intersectLine line
    raise "bad call to intersectLine: only for shape values"
  end

  def intersectVerticalLine vline
    raise "bad call to intersectVerticalLine: only for shape values"
  end

  # if self is the intersection of (1) some shape s and (2) 
  # the line containing seg, then we return the intersection of the 
  # shape s and the seg.  seg is an instance of LineSegment
  def intersectWithSegmentAsLineResult seg
    raise "bad call to intersectWithSegmentAsLineResult: only for shape values"
  end
end
