require 'rparsec'
require 'flexsymtax'

module Flexsym
    class Unflexsymast
        include Parsers

        C_SUCC  = :'+'
        C_PRED  = :'-'
        C_LEFT  = :'<'
        C_RIGHT = :'>'
        C_OUT   = :'^'
        C_VOID  = :'_'
        C_QUOTE = :';'
        
        CODES = {
            C_SUCC  => Flexsymtax.CODES[:succ],
            C_PRED  => Flexsymtax.CODES[:pred], 
            C_LEFT  => Flexsymtax.CODES[:left],
            C_RIGHT => Flexsymtax.CODES[:right],
            C_OUT   => Flexsymtax.CODES[:out],
            C_VOID  => Flexsymtax.CODES[:void],
            C_QUOTE => Flexsymtax.CODES[:quote]
        }

        def parser
        end
    end
end
