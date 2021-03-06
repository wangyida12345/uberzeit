# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140619185547) do

  create_table "absence_schedules", :force => true do |t|
    t.boolean  "active",                 :default => false
    t.integer  "absence_id"
    t.date     "ends_date"
    t.integer  "weekly_repeat_interval"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.datetime "deleted_at"
  end

  add_index "absence_schedules", ["absence_id"], :name => "index_absence_schedules_on_absence_id"

  create_table "absences", :force => true do |t|
    t.integer  "time_type_id"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "first_half_day",  :default => true
    t.boolean  "second_half_day", :default => true
    t.datetime "deleted_at"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "absences", ["time_type_id"], :name => "index_date_entries_on_time_type_id"
  add_index "absences", ["user_id"], :name => "index_absences_on_user_id"

  create_table "activities", :force => true do |t|
    t.integer  "activity_type_id"
    t.integer  "user_id"
    t.date     "date"
    t.integer  "duration"
    t.text     "description"
    t.integer  "customer_id"
    t.integer  "project_id"
    t.integer  "redmine_ticket_id"
    t.integer  "otrs_ticket_id",    :limit => 8
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.datetime "deleted_at"
    t.boolean  "billable",                       :default => false, :null => false
    t.boolean  "reviewed",                       :default => false, :null => false
    t.boolean  "billed",                         :default => false, :null => false
  end

  add_index "activities", ["activity_type_id"], :name => "index_activities_on_activity_type_id"
  add_index "activities", ["customer_id"], :name => "index_activities_on_customer_id"
  add_index "activities", ["otrs_ticket_id"], :name => "index_activities_on_otrs_ticket_id"
  add_index "activities", ["project_id"], :name => "index_activities_on_project_id"
  add_index "activities", ["redmine_ticket_id"], :name => "index_activities_on_redmine_ticket_id"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "activity_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.datetime "deleted_at"
  end

  create_table "adjustments", :force => true do |t|
    t.integer  "time_type_id"
    t.date     "date"
    t.integer  "duration"
    t.string   "label"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.datetime "deleted_at"
    t.integer  "user_id"
  end

  add_index "adjustments", ["time_type_id"], :name => "index_adjustments_on_time_type_id"
  add_index "adjustments", ["user_id"], :name => "index_adjustments_on_user_id"

  create_table "customers", :force => true do |t|
    t.integer  "number"
    t.string   "name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "abbreviation"
    t.datetime "deleted_at"
  end

  add_index "customers", ["number"], :name => "index_customers_on_id", :unique => true

  create_table "days", :force => true do |t|
    t.integer  "user_id"
    t.date     "date"
    t.integer  "planned_working_time"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "days", ["date"], :name => "index_days_on_date"
  add_index "days", ["user_id"], :name => "index_days_on_user_id"

  create_table "employments", :force => true do |t|
    t.integer  "user_id"
    t.date     "start_date"
    t.date     "end_date"
    t.float    "workload",   :default => 100.0
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.datetime "deleted_at"
  end

  add_index "employments", ["user_id"], :name => "index_employments_on_user_id"

  create_table "memberships", :force => true do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "memberships", ["team_id"], :name => "index_memberships_on_team_id"
  add_index "memberships", ["user_id"], :name => "index_memberships_on_user_id"

  create_table "projects", :force => true do |t|
    t.integer  "customer_id"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "deleted_at"
  end

  add_index "projects", ["customer_id"], :name => "index_projects_on_customer_id"

  create_table "public_holidays", :force => true do |t|
    t.date     "date"
    t.string   "name"
    t.boolean  "first_half_day",  :default => false
    t.boolean  "second_half_day", :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.datetime "deleted_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "settings", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.string   "uid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.datetime "deleted_at"
  end

  create_table "time_entries", :force => true do |t|
    t.integer  "time_type_id"
    t.datetime "starts"
    t.datetime "ends"
    t.datetime "deleted_at"
    t.integer  "user_id"
  end

  add_index "time_entries", ["time_type_id"], :name => "index_time_entries_on_time_type_id"
  add_index "time_entries", ["user_id"], :name => "index_time_entries_on_user_id"

  create_table "time_spans", :force => true do |t|
    t.date     "date"
    t.integer  "duration"
    t.float    "duration_in_work_days"
    t.integer  "duration_bonus"
    t.integer  "user_id"
    t.integer  "time_type_id"
    t.integer  "time_spanable_id"
    t.string   "time_spanable_type"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "credited_duration"
    t.float    "credited_duration_in_work_days"
  end

  add_index "time_spans", ["time_spanable_id"], :name => "index_time_spans_on_time_spanable_id"
  add_index "time_spans", ["time_type_id"], :name => "index_time_spans_on_time_type_id"
  add_index "time_spans", ["user_id"], :name => "index_time_spans_on_user_id"

  create_table "time_types", :force => true do |t|
    t.string   "name"
    t.boolean  "is_work",                  :default => false
    t.boolean  "is_vacation",              :default => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.datetime "deleted_at"
    t.string   "icon"
    t.integer  "color_index",              :default => 0
    t.boolean  "exclude_from_calculation", :default => false
    t.string   "bonus_calculator"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.datetime "deleted_at"
    t.string   "given_name"
    t.date     "birthday"
    t.string   "authentication_token"
    t.string   "password_digest"
    t.string   "auth_source"
    t.boolean  "active",               :default => true
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email"

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
