require "validates_as_fragment/validation"
require "validates_as_fragment/form_scanner"

module ValidatesAsFragment
end

ActiveRecord::Base.send(:include, ValidatesAsFragment::Validation)

