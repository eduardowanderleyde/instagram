module ApplicationHelper
  # Foto de perfil redonda, com fallback para a imagem padrão.
  def avatar_tag(user, size: "w-10 h-10", **options)
    source = user&.profile_pic&.attached? ? user.profile_pic : "user-pp.jpeg"
    image_tag source, alt: user&.username.to_s,
      class: "#{size} rounded-full object-cover border border-gray-200 shrink-0 #{options.delete(:class)}", **options
  end
end
