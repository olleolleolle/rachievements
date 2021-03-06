class GuildMailer < ActionMailer::Base

    helper :application
    
    def GuildMailer.send_weekly_summaries
        # call this method on mondays. It can cope with being called more than
        # once on a monday, but don't call it all the time.
        Guild.find(:all, :conditions => [ "email_sent_at < ? or email_sent_at is null", Time.now - 2.days ] ).each{|g|
            if !g.email.blank?
                puts "#{ g.to_s }"
                GuildMailer.deliver_weekly_summary( g )
            end
        }
    end

    def weekly_summary( guild, email = nil, force = false )
        email ||= guild.email
        
        if !force and guild.email_sent_at and guild.email_sent_at > Time.now - 2.days
            raise "email sent recently, not resending."
        end
        if email.blank?
            raise "no email address for guild #{ guild }"
        end
        recipients email
        from "Tom's Magical Mail Sending Robot <tom@jerakeen.org>"
        subject "The magical world of #{ guild.name }, week beginning #{ (Time.now - 7.days).strftime("%d %B") }"
        sent_on Time.now

        all_items = guild.character_achievements.all( :conditions => [ 'character_achievements.created_at >= ?', Date.today - 1.week ] )
        people = all_items.group_by{|i| i.character }.sort_by{|character, items| [ character.achpoints * -1, character.rank ] }
        level_80 = guild.characters.count(:conditions => { :level => 80 } )
        total = guild.characters.count
        levels = all_items.select{|i| i.achievement.name.match(/^Level \d+/) }.map{|i| [ i.character, i.achievement.name.downcase ] }.sort_by{|char, level| level }.reverse.uniq_by{|character, level| character }

        body( { :guild => guild, :people => people, :level_80 => level_80, :total => total, :levels => levels } )
        
        guild.update_attributes!( :email_sent_at => Time.now )
    end

end
