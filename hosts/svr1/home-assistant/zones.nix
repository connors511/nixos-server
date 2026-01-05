{
  services.home-assistant.config.homeassistant = {
    name = "Home";
    latitude = "!secret home_latitude";
    country = "DE";
    longitude = "!secret home_longitude";
    unit_system = "metric";
    time_zone = "Europe/Copenhagen";
  };
  services.home-assistant.config.zone = [
    {
      name = "Matthias Work";
      icon = "mdi:briefcase";
      latitude = "!secret matthias_work_latitude";
      longitude = "!secret matthias_work_longitude";
      radius = "300";
    }
    {
      name = "Andrea Work";
      icon = "mdi:briefcase";
      latitude = "!secret andrea_work_latitude";
      longitude = "!secret andrea_work_longitude";
      radius = "300";
    }
    {
      name = "Mor";
      icon = "mdi:human-male-female-child";
      latitude = "!secret mom_latitude";
      longitude = "!secret mom_longitude";
      radius = "200";
    }
  ];
}
