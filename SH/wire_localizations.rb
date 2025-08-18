#!/usr/bin/env ruby
# SH/wire_localizations.rb
# Re-wire proprement les localisations InfoPlist.strings dans Runner.xcodeproj

require 'xcodeproj'
require 'pathname'

proj_path = 'ios/Runner.xcodeproj'
project   = Xcodeproj::Project.open(proj_path)

target = project.targets.find { |t| t.name == 'Runner' } or abort "Target Runner introuvable"
runner_group = project.main_group.find_subpath('Runner', true)
runner_real  = Pathname(runner_group.real_path) # chemin disque de ios/Runner

# 1) Récupère / crée le Variant Group
variant = runner_group.children.find { |c| c.isa == 'PBXVariantGroup' && c.name == 'InfoPlist.strings' }
variant ||= runner_group.new_variant_group('InfoPlist.strings')

# 2) Supprime les références invalides (chemin qui n'existe pas)
variant.files.dup.each do |f|
  # Résout le chemin complet depuis ios/Runner
  candidate = f.path ? runner_real.join(f.path).to_s : nil
  if candidate.nil? || !File.exist?(candidate)
    puts "🧹 Suppression ref cassée: #{f.name.inspect} path=#{f.path.inspect}"
    f.remove_from_project
  end
end

# 3) Ajoute/recâble toutes les langues présentes sur disque
added_langs = []
Dir.glob(runner_real.join('*.lproj').to_s).sort.each do |dir|
  lang = File.basename(dir, '.lproj') # ex: fr, en-GB, zh-Hans, nb
  strings_abs = File.join(dir, 'InfoPlist.strings')
  next unless File.exist?(strings_abs)

  rel = Pathname(strings_abs).relative_path_from(runner_real).to_s # ex: fr.lproj/InfoPlist.strings

  # Déjà dans le variant ?
  existing = variant.files.find { |f| f.name == lang || f.path == rel }
  if existing
    # Normalise la ref (chemin relatif + nom = code langue)
    existing.path = rel
    existing.name = lang
    existing.source_tree = '<group>'
    existing.last_known_file_type = 'text.plist.strings'
    puts "• Normalisé: #{lang} (#{rel})"
  else
    ref = variant.new_file(rel)
    ref.name = lang
    ref.source_tree = '<group>'
    ref.last_known_file_type = 'text.plist.strings'
    puts "✅ Ajouté: #{lang} (#{rel})"
  end
  added_langs << lang
end

# 4) Assure la présence du Variant Group dans Copy Bundle Resources
unless target.resources_build_phase.files_references.include?(variant)
  target.resources_build_phase.add_file_reference(variant)
  puts "✅ Ajouté à Build Phase: Copy Bundle Resources"
end

# 5) known_regions (inclut Base)
project.root_object.known_regions = (project.root_object.known_regions + added_langs + ['Base']).uniq

project.save
puts "🎉 OK: #{added_langs.sort.join(', ')}"
