module Error : sig
  include Config.ERROR
end

module Prop : sig
  include Config.PROPS

  val is_string : t -> bool
  (** Whether or not a particular property kind is a
      string-valued property *)
end
