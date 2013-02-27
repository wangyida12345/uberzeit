# Special case for whole day entries
# All times are stored in UTC, but if we enable whole day, a 2010-06-03 00:00 time in GMT+01 would be stored as 2010-06-02 23:00
# The user expects that this entry occupies the whole day, independent from the timezone
# So we need to do some magic (Time.utc and using two different attribute reader methods) to properly handle this
class SingleEntry < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :time_sheet
  belongs_to :time_type
  attr_accessible :end_time, :start_time, :time_type_id, :whole_day

  validates_presence_of :time_type, :time_sheet, :start_time

  validates_datetime :start_time
  validates_datetime :end_time, after: :start_time, unless: lambda { whole_day }

  before_validation :round_times
  before_save :set_times_for_whole_day, if: lambda { whole_day_changed? && whole_day == true }

  # http://stackoverflow.com/questions/143552/comparing-date-ranges
  scope :between, lambda { |starts, ends| 
    starts = starts.midnight if starts.kind_of?(Date) # Gracefully convert to local time zone
    ends = ends.midnight if ends.kind_of?(Date) # To ensure we acknowledge the users time zone with dates
    { conditions: ['(whole_day = false AND start_time < ? AND end_time > ?) OR 
                    (whole_day = true AND start_time < ? AND end_time > ?)', 
                    ends, starts, Time.utc(ends.year, ends.month, ends.day), Time.utc(starts.year, starts.month, starts.day) ] } 
  }

  scope :work, joins: :time_type, conditions: ['is_work = ?', true]
  scope :vacation, joins: :time_type, conditions: ['is_vacation = ?', true]
  scope :onduty, joins: :time_type, conditions: ['is_onduty = ?', true]

  def range_for(date_or_range)
    range_range = date_or_range.to_range
    range.intersect(range_range)
  end

  def duration_for(date_or_range)
    intersection = range_for(date_or_range)
    duration = intersection.nil? ? 0 : intersection.duration
    duration
  end

  def duration
    (ends - starts).to_i
  end

  def range
    (starts..ends)
  end

  def whole_day?
    whole_day
  end

  def starts
    if whole_day?
      # we are not interested in the offset for whole days
      time = start_time - Time.zone.utc_offset
    else
      time = start_time
    end
    time
  end

  def ends
    if whole_day?
      #raise starts.to_s
      time = starts + 24.hours
    else
      time = end_time
    end
    time
  end

  private

  # Make sure these are private and we get the time via starts/ends
  def start_time
    self[:start_time]
  end

  def end_time
    self[:end_time]
  end

  def set_times_for_whole_day
    # Make sure the start time is UTC 00:00 so there's no mess when timezone changes in future
    ref_time = start_time
    self.start_time = Time.utc(ref_time.year, ref_time.month, ref_time.day)
    self.end_time = start_time + 24.hours
  end

  def round_times
    self.start_time = start_time.round
    self.end_time = end_time.round
  end
end