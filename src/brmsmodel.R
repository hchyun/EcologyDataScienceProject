library(brms)

spcn <- c()
for(i in 1:ncol(cont_train_y)){
  currspc <- gsub('[ -]', '_', spcd_code[spcd_code$spcd == colnames(cont_train_y)[i], ]$common_name)
  currspc <- gsub('[)(,]','', currspc)
  spcn <- c(spcn, currspc)
}

cont_y_train <- cont_train_y
colnames(cont_y_train) <- spcn


testdata <- data.frame(cont_y_train,cont_train_x)
test <- brm(
  mvbind(
    Pacific_silver_fir, balsam_fir, white_fir, grand_fir, corkbark_fir, subalpine_fir, California_red_fir, Alaska_yellow_cedar, Pinchot_juniper, redberry_juniper, Ashe_juniper, alligator_juniper, western_juniper, Utah_juniper, Rocky_Mountain_juniper, eastern_redcedar, oneseed_juniper, tamarack_native, western_larch, incense_cedar, Engelmann_spruce, white_spruce, black_spruce, red_spruce, Sitka_spruce, whitebark_pine, jack_pine, common_or_two_needle_pinyon, sand_pine, lodgepole_pine, shortleaf_pine, slash_pine, limber_pine, Jeffrey_pine, sugar_pine, western_white_pine, longleaf_pine, ponderosa_pine, red_pine, pitch_pine, eastern_white_pine, loblolly_pine, Virginia_pine, singleleaf_pinyon, Douglas_fir, baldcypress, pondcypress, northern_white_cedar, western_redcedar, eastern_hemlock, western_hemlock, mountain_hemlock, boxelder, striped_maple, red_maple, silver_maple, sugar_maple, red_alder, yellow_birch, sweet_birch, paper_birch, American_hornbeam_musclewood, bitternut_hickory, pignut_hickory, shagbark_hickory, black_hickory, mockernut_hickory, sugarberry, hackberry, curlleaf_mountain_mahogany, American_beech, white_ash, black_ash, green_ash, loblolly_bay, American_holly, black_walnut, sweetgum, yellow_poplar, tanoak, sweetbay, water_tupelo, blackgum, swamp_tupelo, eastern_hophornbeam, sourwood, balsam_poplar, bigtooth_aspen, quaking_aspen, honey_mesquite, black_cherry, white_oak, Arizona_white_oak, canyon_live_oak, scarlet_oak, blue_oak, northern_pin_oak, southern_red_oak, Gambel_oak, Oregon_white_oak, California_black_oak, laurel_oak, bur_oak, water_oak, willow_oak, chestnut_oak, northern_red_oak, post_oak, black_oak, live_oak, sassafras, American_basswood, winged_elm, American_elm, Chinese_tallowtree
    )
    ~
    slope + aspect + elev + carbon_soil_org + dry + mod + DL3 + DL4 + DL10 + prec_6 + prec_7 + rad_8 + tmax_8 + tmin_1 + tmin_1_county + tmax_8_county + prec_6_county + prec7_county + rad_8_county + tmin_1_state + tmax_8_state + prec_6_state + prec7_state + rad_8_state,
  data=testdata, family=poisson()
  )
