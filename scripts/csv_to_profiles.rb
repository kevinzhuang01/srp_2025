#!/usr/bin/env ruby

require 'csv'
require 'yaml'

# Helper script to convert CSV profile data to Jekyll profile pages

def slugify(text)
  text.to_s.downcase.strip.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-').gsub(/-+/, '-')
end

def csv_to_profiles
  csv_file = '_data/profiles.csv'
  profiles_dir = '_profiles'
  
  unless File.exist?(csv_file)
    puts "Error: #{csv_file} not found!"
    return
  end
  
  # Create profiles directory if it doesn't exist
  Dir.mkdir(profiles_dir) unless Dir.exist?(profiles_dir)
  
  # CSV columns: Submission,Status ,First,Last,Email,Institution,Department,Website,Citizenship Status,Academic Status,Title,Abstract ,Academic/Research Interests,Motivation,Additional Comments

  # Read CSV and create profile pages
  CSV.foreach(csv_file, headers: true, encoding: 'ISO-8859-1:UTF-8') do |row|
    first = row['First/Given Names (first)'] || row['First']
    last = row['Last/Family Name (first)'] || row['Last']
    name = "#{first}_#{last}"
    next if name.nil? || name.strip.empty?
    
    slug = slugify(name)
    filename = "#{profiles_dir}/#{slug}.md"
    
    # Get image from CSV column and construct path based on slug
    image_filename = row['Upload a photograph of this person (JPEG/GIF/PNG/TIFF)']
    image_path = nil
    
    if image_filename && !image_filename.strip.empty?
      # Try to find image by name with underscore in pictures directory
      possible_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.tiff']
      # Create filename with underscore: first_last, convert hyphens and spaces to underscores
      image_slug = "#{first}_#{last}".downcase.strip.gsub(/[^a-z0-9_\s-]/, '').gsub(/[-\s]+/, '_')
      
      possible_extensions.each do |ext|
        path = "assets/images/pictures/#{image_slug}#{ext}"
        if File.exist?(path)
          image_path = "/#{path}"
          break
        end
      end
    end
    
    # Prepare front matter
    front_matter = {
    "layout" => "profile",
    "first_name" => row["First/Given Names (first)"],
    "last_name" => row["Last/Family Name (first)"],
    "name" => "#{row['First/Given Names (first)']} #{row['Last/Family Name (first)']}",
    "email" => row["Email (first)"],
    "institution" => row["Institution"],
    "organization" => row["Institution"],
    "department" => row["Department"],
    "pronouns" => row["Pronouns"],
    "biography" => row["Short Biography (Maximum 200 words)"],
    "academic_status" => row["Academic Status"],
    "year_in_program" => row["Year in program"],
    "research_area" => row["Research Area/Department (check as many as appropriate)"],
    "major" => row["Major/Specialty"],
    "degrees" => row["Degrees Earned or in Progress (Degree/Field/Year)"],
    "courses" => row["What courses or academic preparation have you completed to prepare for a summer internship experience (we recommend at least two science or computer science classes)?"],
    "research_experience" => row["Where has your research been published or where have you conducted research/technical projects? Please include a few references, if available."],
    "academic_interests" => row["Please describe your research/academic interests."],
    "topical_areas" => row["Please select all the topical areas that apply to your field of study:"],
    "motivation" => row["Motivation"],
    "image" => image_path 
}
    
    # Remove empty fields
    front_matter.reject! { |k, v| v.nil? || v.strip.empty? }
    
    # Create the profile page content
    content = "---\n"
    content += front_matter.to_yaml.gsub(/^---\n/, '')
    content += "---\n\n"
    
    # Add Academic Interests section if available
    if front_matter['academic_interests'] && !front_matter['academic_interests'].strip.empty?
      content += "## Academic Interests\n\n"
      content += "#{front_matter['academic_interests']}\n\n"
    end
    
    # Write the file
    File.write(filename, content)
    puts "Created: #{filename}"
  end
  
  puts "\nProfile pages generated successfully!"
  puts "Remember to add profile images to the assets/images/ directory."
end

def csv_to_yaml
  csv_file = '_data/profiles.csv'
  yaml_file = '_data/profiles.yml'
  
  unless File.exist?(csv_file)
    puts "Error: #{csv_file} not found!"
    return
  end
  
  profiles = []
  CSV.foreach(csv_file, headers: true, encoding: 'ISO-8859-1:UTF-8') do |row|
    profile = {}
    row.headers.each do |header|
      value = row[header]
      profile[header] = value if value && !value.strip.empty?
    end
    profiles << profile unless profile.empty?
  end
  
  File.write(yaml_file, profiles.to_yaml)
  puts "Created: #{yaml_file}"
end

# Main execution
if ARGV.include?('--yaml-only')
  csv_to_yaml
else
  csv_to_profiles
  csv_to_yaml
end
