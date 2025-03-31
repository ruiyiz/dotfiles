return {
  {
    'nvim-orgmode/orgmode',
    event = 'VeryLazy',
    config = function()
      require('orgmode').setup {
        org_agenda_files = '~/MyDrive/org/*',
        org_default_notes_file = '~/MyDrive/org/refile.org',
        org_agenda_custom_commands = {
          -- "v" is the shortcut that will be used in the prompt
          v = {
            description = 'Combined view', -- Description shown in the prompt for the shortcut
            types = {
              {
                type = 'tags_todo', -- Type can be agenda | tags | tags_todo
                match = '+PRIORITY="A"', --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
                org_agenda_overriding_header = 'Now',
                org_agenda_todo_ignore_deadlines = 'far', -- Ignore all deadlines that are too far in future (over org_deadline_warning_days). Possible values: all | near | far | past | future
              },
              {
                type = 'tags_todo', -- Type can be agenda | tags | tags_todo
                match = '+PRIORITY="B"', --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
                org_agenda_overriding_header = 'Today',
                org_agenda_todo_ignore_deadlines = 'far', -- Ignore all deadlines that are too far in future (over org_deadline_warning_days). Possible values: all | near | far | past | future
              },
              {
                type = 'tags_todo', -- Type can be agenda | tags | tags_todo
                match = '+PRIORITY="C"', --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
                org_agenda_overriding_header = 'This Week',
                org_agenda_todo_ignore_deadlines = 'far', -- Ignore all deadlines that are too far in future (over org_deadline_warning_days). Possible values: all | near | far | past | future
              },
              {
                type = 'agenda',
                org_agenda_overriding_header = 'Whole week overview',
                org_agenda_span = 'week', -- 'week' is default, so it's not necessary here, just an example
                org_agenda_start_on_weekday = 1, -- Start on Monday
                org_agenda_remove_tags = true, -- Do not show tags only for this view
              },
              {
                type = 'tags_todo', -- Type can be agenda | tags | tags_todo
                match = '+PRIORITY="D"', --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
                org_agenda_overriding_header = 'Next Week',
                org_agenda_todo_ignore_deadlines = 'far', -- Ignore all deadlines that are too far in future (over org_deadline_warning_days). Possible values: all | near | far | past | future
              },
            },
          },
        },
      }
    end,
  },
}
