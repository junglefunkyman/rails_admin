# encoding: UTF-8
require 'csv'
require 'pp'

module RailsAdmin
  class CSVConverter
    UTF8_ENCODINGS = [nil, '', 'utf8', 'utf-8', 'unicode', 'UTF8', 'UTF-8', 'UNICODE', 'utf8mb4']
    TARGET_ENCODINGS = %w(UTF-8 UTF-16LE UTF-16BE UTF-32LE UTF-32BE UTF-7 ISO-8859-1 ISO-8859-15 IBM850 MacRoman Windows-1252 ISO-8859-3 IBM852 ISO-8859-2 Windows-1250 IBM855 ISO-8859-5 KOI8-R MacCyrillic Windows-1251 IBM866 GB2312 GBK GB18030 Big5 Big5-HKSCS EUC-TW EUC-JP ISO-2022-JP Shift_JIS EUC-KR)
    def initialize(objects = [], schema = {})
      return self if (@objects = objects).blank?
      puts schema

      schema = {:only => [:id, :first_name, :last_name, :middle_name, :sex],
          :include => {
              :city => {:only => [:id, :country_id, :region_id, :name]},
              :physical_parameters => {:only => [:id, :measured, :height, :weight, :imt, :waist, :hips, :fat_mass_abs, :fat_mass_rel]},
              :passport => {:only => [:id, :serial, :number, :sex, :birth_weight, :race, :ethnicity, :issued, :issued_by, :birth_date, :birth_location]},
              :new_oso_questionaries => {:only => [:id, :filled, :q1, :q2, :q3, :q4, :q5, :q6, :q7, :q8, :q9, :q10, :q11, :q12, :q13, :q14, :q15, :q16, :q17, :q18, :q19, :q20, :q21, :q22, :q23, :q24, :q25, :q26, :q27, :q28, :q29, :q30, :q31, :q32, :q33, :q34, :q35, :q36, :q37, :q38, :q39, :q40, :q41, :q42, :q43, :q44, :q45, :q46, :q47, :q48, :q49, :q50, :q51, :q52, :q53, :q54, :q55, :q56, :q57, :q58]},
              :new_sts_questionaries => {:only => [:id, :filled, :q1, :q2, :q3, :q4, :q5, :q6, :q7, :q8, :q9, :q10, :q11, :q12, :q13, :q14, :q15, :q16, :q17, :q18, :q19, :q20, :q21, :q22, :q23, :q24, :q25, :q26, :q27, :q28, :q29, :q30, :q31, :q32, :q33, :q34, :q35, :q36, :q37, :q38, :q39, :q40, :q41, :q42, :q43, :q44, :q45, :q46, :q47, :q48, :q49, :q50, :q51, :q52, :q53, :q54]},
              :new_usk_questionaries => {:only => [:id, :filled, :q1, :q2, :q3, :q4, :q5, :q6, :q7, :q8, :q9, :q10, :q11, :q12, :q13, :q14, :q15, :q16, :q17, :q18, :q19, :q20, :q21, :q22, :q23, :q24, :q25, :q26, :q27, :q28, :q29, :q30, :q31, :q32, :q33, :q34, :q35, :q36, :q37, :q38, :q39, :q40, :q41, :q42, :q43, :q44]},
              :clamps => {:only => [:id, :date]},
              :soc_dem_fins => {:only => [:id, :filled, :marital_status, :children],
                  :include => {
                      :education => {:only => [:id]}, :occupation => {:only => [:id]}, :position => {:only => [:id]}, :qualification => {:only => [:id]}, :income => {:only => [:id]}
                  }
              },
              :life_styles => {
                  :only => [:id, :filled, :physical_active, :activity_level, :activity_hours_per_week, :activity_hours_per_day, :no_activity_hours_per_week, :no_activity_hours_per_day, :take_lift, :health_food, :eating_day_min, :eating_day_max, :max_eating_load, :snacks_freq, :vegetables_freq, :fruits_freq, :fat_pref, :alcohol_freq, :min_weight, :max_weight, :fat_ancestors, :is_fat, :sleep_duration, :night_awake_freq_month, :wakeup_time, :activity_types_other, :cooking_preferences_other, :food_types_other, :snack_types_other, :transport_type_other, :smoking, :smoke_duration_years, :smoke_since_age, :smoke_quit_duration_months, :smoke_quit_duration_years, :smoke_per_day, :smoke_per_week],
                  :include => {
                      :transport_type => {:only => [:id]},
                      :activity_freq => {:only => [:id]},
                      :activity_types => {:only => [:id], :has_many => true},
                      :snack_types => {:only => [:id], :has_many => true},
                      :cooking_preferences => {:only => [:id], :has_many => true},
                      :food_types => {:only => [:id], :has_many => true},
                      :drink_types => {:only => [:id], :has_many => true},
                      :alco_preference => {:only => [:id]}
                  }
              },
              :complete_blood_counts => {
                  :only => [:id, :filled, :erythrocytes, :hemoglobin, :hematocrit, :msv, :mch, :mchc, :rdw, :platelets, :mpv, :pct, :pdw, :esr],
                  :include => {
                      :leukocyte_count => {:only => [:leukocytes, :neutrophils, :lymphocytes, :monocytes, :eosinophils, :basophils, :neutrophils_abs, :lymphocytes_abs, :monocytes_abs, :eosinophils_abs, :basophils_abs]},
                  }
              },
              :blood_chemistries => {:only => [:id, :filled, :glucose, :total_bilirubin, :total_cholesterol, :ldl_cholesterol, :hdl_cholesterol, :triglycerides, :uric_acid, :urea, :protein, :creatinine, :GFR, :AST, :ALT, :alpha_amylase, :alkaline_phosphatase, :GGT, :calcium, :serum_iron, :hba1c]},
              :hormonal_blood_analysis => {:only => [:id, :filled, :tsh, :insulin_0, :insulin_60, :insulin_120, :insulin_240, :c_peptide_0, :c_peptide_60, :c_peptide_120, :c_peptide_240, :irisin_before, :irisin_after, :fgf21_before, :fgf21_after]},
              :complete_urines => {:only => [:id, :filled, :glucose, :protein, :bilirubin, :urobilinogen, :acidity, :red_blood_cells, :ketones, :nitrite, :white_blood_cells, :transparency, :specific_density, :color]},
              :biochemical_urines => {:only => [:id, :filled, :albumin_creatinine, :albumin, :creatinine]},
              :infectious_markers => {:only => [:id, :filled, :hiv, :hepatitis_b, :hepatitis_c, :syphilis]},
              :insulin_resistances => {:only => [:id, :filled, :insulin_0, :glucose_0, :index_noma]}}}

      @model = objects.dup.first.class
      # puts 'MODEL:'
      # puts @model
      @abstract_model = RailsAdmin::AbstractModel.new(@model)
      @model_config = @abstract_model.config
      @methods = [(schema[:only] || []) + (schema[:methods] || [])].flatten.compact
      @fields = @methods.collect { |m| export_fields_for(m).first }
      @empty = ::I18n.t('admin.export.empty_value_for_associated_objects')
      schema_include = schema.delete(:include) || {}

      @associations = build_associations(schema_include, @model_config)

      # puts @associations.inspect
    end

    def build_associations(schema_include, model_config)
      # puts "-----"
      # puts @model_config
      # puts "-----"
      # puts model_config
      # puts "-----"
      return {} if schema_include.blank?
      # puts "NOT BLANK"
      # puts schema_include
      schema_include.each_with_object({}) do |(key, values), hash|
        # puts key
        # puts model_config.inspect
        association = association_for(key, model_config)
        # puts association
        mc = association.associated_model_config
        # puts mc
        abstract_model = mc.abstract_model
        methods = [(values[:only] || []) + (values[:methods] || [])].flatten.compact
        subs = values[:include] || {}
        unless subs.empty?
          puts "--------->>>>>>>>"
          puts subs
          subs = build_associations(subs, mc)
        end

        hash[key] = {
            association: association,
            model: abstract_model.model,
            abstract_model: abstract_model,
            model_config: mc,
            fields: methods.collect { |m| export_fields_for(m, mc).first },
            subs: subs,
            has_many: values[:has_many]
        }
        hash
      end
    end

    def to_csv(options = {})
      # encoding shenanigans first
      enc = @abstract_model.encoding != 'iso_1' ? @abstract_model.encoding : 'ISO-8859-1'
      @encoding_from = Encoding.find(UTF8_ENCODINGS.include?(enc) ? 'UTF-8' : enc)
      @encoding_to = Encoding.find(options[:encoding_to].presence || @encoding_from)

      csv_string = generate_csv_string(options)

      if @encoding_to != @encoding_from
        csv_string = csv_string.encode(@encoding_to, @encoding_from, invalid: :replace, undef: :replace, replace: '?')
      end
      # Add a BOM for utf8 encodings, helps with utf8 auto-detect for some versions of Excel.
      # Don't add if utf8 but user don't want to touch input encoding:
      # If user chooses utf8, they will open it in utf8 and BOM will disappear at reading.
      # But that way "English" users who don't bother and chooses to let utf8 by default won't get BOM added
      # and will not see it if Excel opens the file with a different encoding.
      if options[:encoding_to].present? && @encoding_to == Encoding::UTF_8
        csv_string = "\xEF\xBB\xBF#{csv_string}"
      end
      [!options[:skip_header], @encoding_to.to_s, csv_string]
    end

  private

    def association_for(key, model_config = @model_config)
      export_fields_for(key, model_config).detect(&:association?)
    end

    def export_fields_for(method, model_config = @model_config)
      model_config.export.fields.select { |f| f.name == method }
    end

    def generate_csv_string(options)
      generator_options = (options[:generator] || {}).symbolize_keys.delete_if { |_, value| value.blank? }
      CSV.generate(generator_options) do |csv|
        csv << generate_csv_header unless options[:skip_header]

        method = @objects.respond_to?(:find_each) ? :find_each : :each
        @objects.send(method) do |object|
          csv << generate_csv_row(object)
        end
      end
    end

    def generate_csv_header
      @fields.collect do |field|
        ::I18n.t('admin.export.csv.header_for_root_methods', name: field.label, model: @abstract_model.pretty_name)
      end +
        @associations.flat_map do |_association_name, option_hash|
          option_hash[:fields].collect do |field|
            ::I18n.t('admin.export.csv.header_for_association_methods', name: field.label, association: option_hash[:association].label)
          end
          .concat(sub_header(option_hash))
        end
    end

    def sub_header(option_hash)
      option_hash[:subs].flat_map do |_sub_name, sub_hash|
        if sub_hash[:has_many]
          sub_hash[:model].all.collect do |value|
            ::I18n.t('admin.export.csv.header_for_association_methods_sub', sub: value.name, association: option_hash[:association].label, name: sub_hash[:association].label)
          end
        else
          sub_hash[:fields].collect do |field|
            ::I18n.t('admin.export.csv.header_for_association_methods_sub', name: field.label, association: option_hash[:association].label, sub: sub_hash[:association].label)
          end
        end
      end
    end

    def generate_csv_row(object)
      @fields.collect do |field|
        field.with(object: object).export_value
      end +
          build_association_values(@associations, object)
    end

    def build_association_values(associations, object)
      associations.flat_map do |association_name, option_hash|
        puts '>>>>>>>>>'
        puts association_name
        if object.blank?
          associated_objects = []
        else
          associated_objects = [object.send(association_name)].flatten.compact
        end
        fields = option_hash[:fields].collect do |field|
          associated_objects.collect { |ao| field.with(object: ao).export_value.presence || @empty }.join(',')
        end
        subs = option_hash[:subs].blank? ? [] : build_association_values(option_hash[:subs], (associated_objects.blank? ? {} : associated_objects[0]))
        if option_hash[:has_many]
          split = fields[0].split(',')
          pp fields
          pp split
          puts fields.size
          puts split.size
          puts '!' + association_name.to_s
          subs_bitmap = [23]
          m = option_hash[:model]
          puts subs
          puts subs.join(',')
          m.all.each_with_index do |v, i|
            puts v.id
            subs_bitmap[i] = (split.include? v.id.to_s) ? 1 : 0
          end
          fields = subs_bitmap
        end
        result = subs.blank? ? fields : fields.concat(subs).flatten
        puts '-------'
        puts result.join(',')
        puts '-------'
        result
      end
    end
  end
end
