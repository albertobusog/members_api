module Mutations
  class AttendanceHistory < BaseMutation
    argument :user_id, ID, required: false

    field :visits, [ Types::VisitType ], null: true
    field :errors, [ String ], null: true

    def resolve(user_id: nil)
      current_user = context[:current_user]
      return { visits: nil, errors: [ "Not authorized" ] } unless current_user

      # Determinar el usuario objetivo según el rol
      user = current_user.admin? ? User.find_by(id: user_id) : current_user

      return { visits: nil, errors: [ "userId is required for admins" ] } if current_user.admin? && user_id.blank?
      return { visits: nil, errors: [ "Not authorized" ] } if current_user.client? && user_id.present? && user_id.to_i != current_user.id
      return { visits: nil, errors: [ "User not found" ] } unless user

      # Consultar las visitas asistidas del usuario
      visits = Visit.joins(:purchase).where(purchases: { user_id: user.id }, attended: true)

      { visits: visits, errors: nil }
    end
  end
end
