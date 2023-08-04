import {
  Home,
  Assessment,
  SwapVert,
  Group,
  ListAlt,
  HowToReg,
  AccountCircle,
  Help,
  Flag,
  Favorite,
  MobileScreenShare,
  Person,
  People,
  SettingsApplications,
  LibraryBooks
} from "@material-ui/icons";
import PropTypes from "prop-types";
import SignalWifiOffIcon from "@material-ui/icons/SignalWifiOff";
import SignalWifi4BarIcon from "@material-ui/icons/SignalWifi4Bar";

import { CasesIcon, IncidentsIcon, LogoutIcon, Insights, RegistryRecordIcon } from "../../images/primero-icons";

const ListIcon = ({ icon }) => {
  switch (icon) {
    case "home":
      return <Home />;
    case "activity_log":
      return <LibraryBooks />;
    case "cases":
      return <CasesIcon />;
    case "incidents":
      return <IncidentsIcon />;
    case "tracing_request":
      return <ListAlt />;
    case "matches":
      return <Group />;
    case "key_performance_indicators":
      return <Favorite />;
    case "reports":
      return <Assessment />;
    case "exports":
      return <SwapVert />;
    case "tasks":
      return <HowToReg />;
    case "account":
      return <AccountCircle />;
    case "support":
      return <Help />;
    case "logout":
      return <LogoutIcon />;
    case "flagged_label":
      return <Flag />;
    case "mark_for_mobile":
      return <MobileScreenShare />;
    case "my_cases":
      return <Person />;
    case "referred_cases":
      return <People />;
    case "settings":
    case "roles":
    case "admin/forms":
      return <SettingsApplications />;
    case "insights":
      return <Insights />;
    case "registry_records":
      return <RegistryRecordIcon />;
    case "disconnected":
      return <SignalWifiOffIcon />;
    case "connected":
      return <SignalWifi4BarIcon />;
    default:
      return null;
  }
};

ListIcon.displayName = "ListIcon";

ListIcon.propTypes = {
  icon: PropTypes.string.isRequired
};

export default ListIcon;
