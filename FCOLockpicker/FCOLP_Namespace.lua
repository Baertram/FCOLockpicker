------------------------------------------------------------------
-- FCOLP_Namespace.lua
-- Author: Baertram
------------------------------------------------------------------

FCOLP = FCOLP or {}
local FCOLP = FCOLP

FCOLP.addonVars                            = {}
FCOLP.addonVars.gAddonName                 = "FCOLockpicker"
FCOLP.addonVars.addonNameMenu              = "FCO Lockpicker"
FCOLP.addonVars.addonNameMenuDisplay       = "|c00FF00FCO |cFFFF00Lockpicker|r"
FCOLP.addonVars.addonAuthor                = '|cFFFF00Baertram|r'
FCOLP.addonVars.addonVersionOptions        = '0.31'
FCOLP.addonVars.addonSavedVariablesName    = "FCOLockpicker_Settings"
FCOLP.addonVars.addonSavedVariablesVersion = 0.01
FCOLP.addonVars.gAddonLoaded               = false

FCOLP.origChamberStressedSound = SOUNDS["LOCKPICKING_CHAMBER_STRESS"]
FCOLP.sounds = {}
if SOUNDS then
    for soundName, _ in pairs(SOUNDS) do
        if soundName ~= "NONE" and soundName ~= "LOCKPICKING_CHAMBER_STRESS" then
            table.insert(FCOLP.sounds, soundName)
        end
    end
    if #FCOLP.sounds > 0 then
        table.sort(FCOLP.sounds)
        table.insert(FCOLP.sounds, 1, "NONE")
        table.insert(FCOLP.sounds, 2, "LOCKPICKING_CHAMBER_STRESS")
    end
end
if #FCOLP.sounds <= 0 then
    d("[FCOLockpicker] No sounds could be found!")
end

FCOLP.zosVars = {}
FCOLP.zosVars.LOCKPICKS_LEFT  = ZO_LockpickPanelInfoBarLockpicksLeft
FCOLP.zosVars.LOCKPICK = LOCK_PICK
FCOLP.zosVars.LOCKPICK_GP_SCENE = LOCK_PICK_GAMEPAD_SCENE

FCOLP.settingsVars = {}
FCOLP.settingsVars.settings = {}
FCOLP.settingsVars.defaultSettings = {}

FCOLP.chamberResolvedIcons = {

	[[/esoui/art/guild/guildheraldry_indexicon_finalize_down.dds]],
	[[/esoui/art/campaign/campaignbrowser_fullpop.dds]],
	[[/esoui/art/inventory/inventory_tabicon_armor_disabled.dds]],
	[[/esoui/art/crafting/smithing_tabicon_research_disabled.dds]],
	[[/esoui/art/tradinghouse/tradinghouse_sell_tabicon_disabled.dds]],
	[[/esoui/art/campaign/overview_indexicon_bonus_disabled.dds]],
	[[/esoui/art/ava/tabicon_bg_score_disabled.dds]],
	[[/esoui/art/guild/guild_rankicon_leader_large.dds]],
	[[/esoui/art/lfg/lfg_healer_up.dds]],
	[[/esoui/art/miscellaneous/timer_32.dds]],
	[[/esoui/art/crafting/alchemy_tabicon_solvent_up.dds]],
	[[/esoui/art/buttons/cancel_up.dds]],
	[[/esoui/art/buttons/info_up.dds]],
	[[/esoui/art/buttons/pinned_normal.dds]],
	[[/esoui/art/cadwell/cadwell_indexicon_gold_up.dds]],
	[[/esoui/art/cadwell/cadwell_indexicon_silver_up.dds]],
	[[/esoui/art/campaign/campaignbonus_keepicon.dds]],
	[[/esoui/art/icons/scroll_005.dds]],
	[[/esoui/art/campaign/campaignbrowser_columnheader_ad.dds]],
	[[/esoui/art/campaign/campaignbrowser_columnheader_dc.dds]],
	[[/esoui/art/campaign/campaignbrowser_columnheader_ep.dds]],
	[[/esoui/art/campaign/campaignbrowser_guild.dds]],
	[[/esoui/art/campaign/campaignbrowser_indexicon_normal_up.dds]],
	[[/esoui/art/campaign/overview_indexicon_scoring_up.dds]],
	[[/esoui/art/charactercreate/charactercreate_bodyicon_up.dds]],
	[[/esoui/art/characterwindow/gearslot_offhand.dds]],
	[[/esoui/art/characterwindow/gearslot_mainhand.dds]],
	[[/esoui/art/characterwindow/gearslot_costume.dds]],
	[[/esoui/art/chatwindow/chat_mail_up.dds]],
	[[/esoui/art/chatwindow/chat_notification_up.dds]],
	[[/esoui/art/crafting/alchemy_tabicon_reagent_up.dds]],
	[[/esoui/art/crafting/smithing_tabicon_refine_up.dds]],
	[[/esoui/art/deathrecap/deathrecap_killingblow_icon.dds]],
	[[/esoui/art/fishing/bait_emptyslot.dds]],
	[[/esoui/art/guild/guildhistory_indexicon_guildbank_up.dds]],
	[[/esoui/art/guild/guild_indexicon_member_up.dds]],
	[[/esoui/art/guild/tabicon_roster_up.dds]],
	[[/esoui/art/icons/poi/poi_dungeon_complete.dds]],
	[[/esoui/art/icons/poi/poi_groupinstance_complete.dds]],
	[[/esoui/art/icons/servicemappins/servicepin_magesguild.dds]],
	[[/esoui/art/icons/servicemappins/servicepin_fightersguild.dds]],
	[[/esoui/art/lfg/lfg_dps_up.dds]],
	[[/esoui/art/lfg/lfg_leader_icon.dds]],
	[[/esoui/art/lfg/lfg_tank_up.dds]],
	[[/esoui/art/lfg/lfg_veterandungeon_up.dds]],
	[[/esoui/art/lfg/lfg_normaldungeon_up.dds]],
	[[/esoui/art/progression/icon_dualwield.dds]],
	[[/esoui/art/progression/icon_firestaff.dds]],
	[[/esoui/art/progression/icon_bows.dds]],
	[[/esoui/art/progression/icon_2handed.dds]],
	[[/esoui/art/progression/icon_1handed.dds]],
	[[/esoui/art/progression/progression_tabicon_backup_inactive.dds]],
	[[/esoui/art/repair/inventory_tabicon_repair_disabled.dds]],
	[[/esoui/art/worldmap/selectedquesthighlight.dds]],
	[[/esoui/art/guild/guildHeraldry_indexIcon_background_up.dds]],
	[[/esoui/art/crafting/enchantment_tabicon_deconstruction_disabled.dds]],
	[[/esoui/art/crafting/smithing_tabicon_improve_disabled.dds]],
	[[/esoui/art/bank/bank_tabicon_deposit_up.dds]],
	[[/esoui/art/currency/currency_gold.dds]],
	[[/esoui/art/guild/guild_bankaccess.dds]],
	[[/esoui/art/progression/progression_indexicon_guilds_up.dds]],
	[[/esoui/art/buttons/accept_up.dds]],
	[[/esoui/art/buttons/checkbox_checked.dds]],
	[[/esoui/art/buttons/checkbox_indeterminate.dds]],
	[[/esoui/art/buttons/dropbox_arrow_normal.dds]],
	[[/esoui/art/buttons/decline_up.dds]],
	[[/esoui/art/buttons/edit_cancel_up.dds]],
	[[/esoui/art/buttons/edit_up.dds]],
	[[/esoui/art/buttons/edit_save_up.dds]],
	[[/esoui/art/buttons/gamepad/console-widget-slider.dds]],
	[[/esoui/art/buttons/gamepad/console-widget-stepper.dds]],
	[[/esoui/art/buttons/gamepad/gp_checkbox_down.dds]],
	[[/esoui/art/buttons/gamepad/gp_checkbox_up.dds]],
	[[/esoui/art/buttons/gamepad/gp_downarrow.dds]],
	[[/esoui/art/buttons/gamepad/gp_menu_rightarrow.dds]],
	[[/esoui/art/buttons/gamepad/gp_uparrow.dds]],
	[[/esoui/art/buttons/gamepad/gp_spinnerlr.dds]],
	[[/esoui/art/buttons/gamepad/ps4/nav_ps4_circle.dds]],
	[[/esoui/art/buttons/gamepad/ps4/nav_ps4_ls.dds]],
	[[/esoui/art/buttons/gamepad/ps4/nav_ps4_rs.dds]],
	[[/esoui/art/buttons/gamepad/ps4/nav_ps4_share.dds]],
	[[/esoui/art/buttons/gamepad/ps4/nav_ps4_square.dds]],
	[[/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_circle.dds]],
	[[/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_leftright.dds]],
	[[/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_lefttoright.dds]],
	[[/esoui/art/buttons/gamepad/ps4/nav_ps4_triangle.dds]],
	[[/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_updown.dds]],
	[[/esoui/art/buttons/gamepad/ps4/nav_ps4_x.dds]],
	[[/esoui/art/buttons/gamepad/xbox/leftarrow_down.dds]],
	[[/esoui/art/buttons/gamepad/xbox/nav_xbone_a.dds]],
	[[/esoui/art/buttons/gamepad/xbox/nav_xbone_b.dds]],
	[[/esoui/art/buttons/gamepad/xbox/nav_xbone_dpadright.dds]],
	[[/esoui/art/buttons/gamepad/xbox/nav_xbone_rs_menu.dds]],
	[[/esoui/art/buttons/gamepad/xbox/nav_xbone_x.dds]],
	[[/esoui/art/buttons/gamepad/xbox/nav_xbone_y.dds]],
	[[/esoui/art/buttons/radiobuttonup.dds]],
	[[/esoui/art/buttons/radiobuttondown.dds]],
	[[/esoui/art/buttons/smoothsliderbutton_up.dds]],
	[[/esoui/art/buttons/swatchframe_selected.dds]],
	[[/esoui/art/buttons/switch_disabled.dds]],
	[[/esoui/art/buttons/unpinned_normal.dds]],
	[[/esoui/art/mounts/tabicon_mounts_disabled.dds]],
	[[/esoui/art/mounts/tabicon_ridingskills_disabled.dds]],
	[[/esoui/art/mounts/ridingskill_stamina.dds]],
	[[/esoui/art/mounts/ridingskill_speed.dds]],
	[[/esoui/art/mounts/ridingskill_ready.dds]],
	[[/esoui/art/mounts/ridingskill_capacity.dds]],
	[[/esoui/art/mounts/feed_icon.dds]],
	[[/esoui/art/mounts/activemount_icon.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_communications.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_collections.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_character.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_champion.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_achievements.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_contacts.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_crowncrates.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_emotes.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_groups.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_journal.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_logout.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_lorelibrary.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_multiplayer.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_settings.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_store.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_submitfeedback.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_terms.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_textchat.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_icon_unstuck.dds]],
	[[/esoui/art/menubar/gamepad/gp_playermenu_statusicon_pointstospend.dds]],
	[[/esoui/art/tutorial/bank_tabicon_deposit_up.dds]],
	[[/esoui/art/bank/bank_tabicon_gold_up.dds]],
	[[/esoui/art/bank/bank_tabicon_telvar_up.dds]],
	[[/esoui/art/tutorial/bank_tabicon_withdraw_up.dds]],
	[[/esoui/art/tutorial/guild_indexicon_misc09_up.dds]],
	[[/esoui/art/icons/store_upgrade_bank.dds]],
	[[/esoui/art/campaign/campaignbrowser_guild.dds]],
	[[/esoui/art/currency/currency_fightersguild.dds]],
	[[/esoui/art/currency/currency_magesguild.dds]],
	[[/esoui/art/currency/currency_thievesguild.dds]],
	[[/esoui/art/guild/gamepad/gp_guild_heraldryaccess.dds]],
	[[/esoui/art/guild/gamepad/gp_guild_menuicon_customization.dds]],
	[[/esoui/art/guild/gamepad/gp_guild_menuicon_leaveguild.dds]],
	[[/esoui/art/guild/gamepad/gp_guild_menuicon_ownership.dds]],
	[[/esoui/art/guild/gamepad/gp_guild_menuicon_purchases.dds]],
	[[/esoui/art/guild/gamepad/gp_guild_menuicon_releaseownership.dds]],
	[[/esoui/art/guild/gamepad/gp_guild_menuicon_trader.dds]],
	[[/esoui/art/guild/gamepad/gp_guild_menuicon_unlocks.dds]],
	[[/esoui/art/guild/gamepad/gp_guild_options_changeicon.dds]],
	[[/esoui/art/guild/gamepad/gp_guild_options_permissions.dds]],
	[[/esoui/art/guild/gamepad/gp_guild_options_rename.dds]],
	[[/esoui/art/guild/gamepad/gp_guild_tradinghouseaccess.dds]],
	[[/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_thievesguild.dds]],
	[[/esoui/art/tutorial/guild-tabicon_heraldry_up.dds]],
	[[/esoui/art/tutorial/guild-tabicon_home_up.dds]],
	[[/esoui/art/tutorial/guild_indexicon_leader_up.dds]],
	[[/esoui/art/tutorial/guild_indexicon_recruit_up.dds]],
	[[/esoui/art/tutorial/guild_indexicon_officer_up.dds]],
	[[/esoui/art/tutorial/guild_indexicon_misc01_up.dds]],
	[[/esoui/art/tutorial/guild_indexicon_misc02_up.dds]],
	[[/esoui/art/tutorial/guild_indexicon_misc03_up.dds]],
	[[/esoui/art/tutorial/guild_indexicon_misc04_up.dds]],
	[[/esoui/art/tutorial/guild_indexicon_misc05_up.dds]],
	[[/esoui/art/tutorial/guild_indexicon_misc06_up.dds]],
	[[/esoui/art/tutorial/guild_indexicon_misc07_up.dds]],
	[[/esoui/art/tutorial/guild_indexicon_misc08_up.dds]],
	[[/esoui/art/tutorial/guild_indexicon_misc10_up.dds]],
	[[/esoui/art/tutorial/guild_indexicon_misc11_up.dds]],
	[[/esoui/art/tutorial/guild_indexicon_misc12_up.dds]],
	[[/esoui/art/guild/guildbanner_icon_aldmeri.dds]],
	[[/esoui/art/guild/guildbanner_icon_daggerfall.dds]],
	[[/esoui/art/guild/guildbanner_icon_ebonheart.dds]],
	[[/esoui/art/tutorial/guildheraldry_indexicon_background_up.dds]],
	[[/esoui/art/guild/guildheraldry_indexicon_crest_up.dds]],
	[[/esoui/art/tutorial/guildstore-tradinghouse_listings_tabicon_up.dds]],
	[[/esoui/art/tutorial/progression_tabicon_fightersguild_up.dds]],
	[[/esoui/art/tutorial/progression_tabicon_magesguild_up.dds]],
	[[/esoui/art/icons/store_thievesguilddlc_collectable.dds]],
	[[/esoui/art/tutorial/tabicon_createguild_up.dds]],
	[[/esoui/art/voip/voip-guild.dds]],
	[[/esoui/art/death/death_timer_fill.dds]],
	[[/esoui/art/death/death_soulreservoir_icon.dds]],
	[[/esoui/art/currency/alliancepoints_32.dds]],
	[[/esoui/art/tutorial/inventory_trait_retrait_icon.dds]],
	[[/esoui/art/currency/currency_gold_32.dds]],
	[[/esoui/art/currency/currency_inspiration_32.dds]],
	[[/esoui/art/currency/currency_seedcrystal_32.dds]],
	[[/esoui/art/currency/currency_seedcrystals_multi_mipmap.dds]],
	[[/esoui/art/currency/currency_telvar_32.dds]],
	[[/esoui/art/currency/currency_writvoucher.dds]],
	[[/esoui/art/dye/dye_hat.dds]],
	[[/esoui/art/dye/dye_swatch_highlight.dds]],
	[[/esoui/art/dye/dyes_categoryicon_up.dds]],
	[[/esoui/art/dye/dyes_tabicon_outfitstyledye_up.dds]],
	[[/esoui/art/dye/outfitslot_staff.dds]],
	[[/esoui/art/dye/outfitslot_twohanded.dds]],
	[[/esoui/art/armory/builditem_icon.dds]],
	[[/esoui/art/armory/newbuild_icon.dds]],
	[[/esoui/art/unitframes/groupicon_leader.dds]],
	[[/esoui/art/companion/keyboard/category_u30_companions_up.dds]],
	[[/esoui/art/battlegrounds/battlegroundscapturebar_teambadge_green.dds]],
	[[/esoui/art/battlegrounds/battlegroundscapturebar_teambadge_orange.dds]],
	[[/esoui/art/battlegrounds/battlegroundscapturebar_teambadge_purple.dds]],
	[[/esoui/art/icons/store_battleground.dds]],
	[[/esoui/art/collections/collections_tabIcon_itemSets_down.dds]],
	[[/esoui/art/collections/collections_tabIcon_itemSets_up.dds]],
	[[/esoui/art/armory/buildicons/buildicon_1.dds]],
	[[/esoui/art/armory/buildicons/buildicon_2.dds]],
	[[/esoui/art/armory/buildicons/buildicon_3.dds]],
	[[/esoui/art/armory/buildicons/buildicon_4.dds]],
	[[/esoui/art/armory/buildicons/buildicon_5.dds]],
	[[/esoui/art/armory/buildicons/buildicon_6.dds]],
	[[/esoui/art/armory/buildicons/buildicon_7.dds]],
	[[/esoui/art/armory/buildicons/buildicon_8.dds]],
	[[/esoui/art/armory/buildicons/buildicon_9.dds]],
	[[/esoui/art/armory/buildicons/buildicon_10.dds]],
	[[/esoui/art/armory/buildicons/buildicon_11.dds]],
	[[/esoui/art/armory/buildicons/buildicon_12.dds]],
	[[/esoui/art/armory/buildicons/buildicon_13.dds]],
	[[/esoui/art/armory/buildicons/buildicon_14.dds]],
	[[/esoui/art/armory/buildicons/buildicon_15.dds]],
	[[/esoui/art/armory/buildicons/buildicon_16.dds]],
	[[/esoui/art/armory/buildicons/buildicon_17.dds]],
	[[/esoui/art/armory/buildicons/buildicon_18.dds]],
	[[/esoui/art/armory/buildicons/buildicon_19.dds]],
	[[/esoui/art/armory/buildicons/buildicon_20.dds]],
	[[/esoui/art/armory/buildicons/buildicon_21.dds]],
	[[/esoui/art/armory/buildicons/buildicon_22.dds]],
	[[/esoui/art/armory/buildicons/buildicon_23.dds]],
	[[/esoui/art/armory/buildicons/buildicon_24.dds]],
	[[/esoui/art/armory/buildicons/buildicon_25.dds]],
	[[/esoui/art/armory/buildicons/buildicon_26.dds]],
	[[/esoui/art/armory/buildicons/buildicon_27.dds]],
	[[/esoui/art/armory/buildicons/buildicon_28.dds]],
	[[/esoui/art/armory/buildicons/buildicon_29.dds]],
	[[/esoui/art/armory/buildicons/buildicon_30.dds]],
	[[/esoui/art/armory/buildicons/buildicon_31.dds]],
	[[/esoui/art/armory/buildicons/buildicon_32.dds]],
	[[/esoui/art/armory/buildicons/buildicon_33.dds]],
	[[/esoui/art/armory/buildicons/buildicon_34.dds]],
	[[/esoui/art/armory/buildicons/buildicon_35.dds]],
	[[/esoui/art/armory/buildicons/buildicon_36.dds]],
	[[/esoui/art/armory/buildicons/buildicon_37.dds]],
	[[/esoui/art/armory/buildicons/buildicon_38.dds]],
	[[/esoui/art/armory/buildicons/buildicon_39.dds]],
	[[/esoui/art/armory/buildicons/buildicon_40.dds]],
	[[/esoui/art/armory/buildicons/buildicon_41.dds]],
	[[/esoui/art/armory/buildicons/buildicon_42.dds]],
	[[/esoui/art/armory/buildicons/buildicon_43.dds]],
	[[/esoui/art/armory/buildicons/buildicon_44.dds]],
	[[/esoui/art/armory/buildicons/buildicon_45.dds]],
	[[/esoui/art/armory/buildicons/buildicon_46.dds]],
	[[/esoui/art/armory/buildicons/buildicon_47.dds]],
	[[/esoui/art/armory/buildicons/buildicon_48.dds]],
	[[/esoui/art/armory/buildicons/buildicon_49.dds]],
	[[/esoui/art/armory/buildicons/buildicon_50.dds]],
	[[/esoui/art/armory/buildicons/buildicon_51.dds]],
	[[/esoui/art/armory/buildicons/buildicon_52.dds]],
	[[/esoui/art/armory/buildicons/buildicon_53.dds]],
	[[/esoui/art/armory/buildicons/buildicon_54.dds]],
	[[/esoui/art/armory/buildicons/buildicon_55.dds]],
	[[/esoui/art/armory/buildicons/buildicon_56.dds]],
	[[/esoui/art/armory/buildicons/buildicon_57.dds]],
	[[/esoui/art/armory/buildicons/buildicon_58.dds]],
	[[/esoui/art/armory/buildicons/buildicon_59.dds]],
	[[/esoui/art/armory/buildicons/buildicon_60.dds]],
	[[/esoui/art/armory/buildicons/buildicon_61.dds]],
	[[/esoui/art/armory/buildicons/buildicon_62.dds]],
	[[/esoui/art/armory/buildicons/buildicon_63.dds]],
	[[/esoui/art/armory/buildicons/buildicon_64.dds]],
	[[/esoui/art/armory/buildicons/buildicon_65.dds]],
	[[/esoui/art/armory/buildicons/buildicon_66.dds]],
	[[/esoui/art/armory/buildicons/buildicon_67.dds]],
	[[/esoui/art/armory/buildicons/buildicon_68.dds]],
	[[/esoui/art/armory/buildicons/buildicon_69.dds]],
	[[/esoui/art/armory/buildicons/buildicon_70.dds]],
	[[/esoui/art/armory/buildicons/buildicon_71.dds]],
	[[/esoui/art/armory/buildicons/buildicon_72.dds]],
	[[/esoui/art/armory/buildicons/buildicon_73.dds]],
	[[/esoui/art/armory/buildicons/buildicon_74.dds]],
	[[/esoui/art/inventory/gamepad/gp_inventory_icon_companionitems.dds]],

}

FCOLP.chamberResolvedIconsTooltips = {}
for iconIndex, texturePath in ipairs(FCOLP.chamberResolvedIcons) do
    FCOLP.chamberResolvedIconsTooltips[iconIndex] = texturePath
end

FCOLP.preventerVars = {}
FCOLP.preventerVars.gLocalizationDone = false
FCOLP.preventerVars.gLockpickActive = false
FCOLP.preventerVars.gOnLockpickChatStateWasMinimized = false

FCOLP.numVars = {}
FCOLP.numVars.languageCount = 8
FCOLP.langVars = {}
FCOLP.langVars.languages = {}
for languageIndex = 1, FCOLP.numVars.languageCount do
    FCOLP.langVars.languages[languageIndex] = true
end

FCOLP.localizationVars = {}
FCOLP.localizationVars.FCOLP_loc = {}

FCOLP.preChatText = "FCOLockpicker"
FCOLP.preChatTextGreen = "|c22DD22" .. FCOLP.preChatText .. "|r "
FCOLP.preChatTextBlue = "|c2222DD" .. FCOLP.preChatText .. "|r "
