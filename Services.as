#if TMNEXT
class ServicesMapInfo
{
	string m_uid;
	string m_thumbUrl;
}

ServicesMapInfo GetMapFromServices(const string &in uid)
{
	ServicesMapInfo ret;

	auto maniaApp = g_app.MenuManager.MenuCustom_CurrentManiaApp;
	auto dfm = maniaApp.DataFileMgr;

	MwFastBuffer<wstring> uids;
	uids.Add(uid);

	auto req = dfm.Map_NadeoServices_GetListFromUid(0, uids);
	while (req.IsProcessing) {
		yield();
	}

	if (req.MapList.Length == 1) {
		CNadeoServicesMap@ mapInfo = req.MapList[0];
		ret.m_uid = mapInfo.Uid;
		ret.m_thumbUrl = mapInfo.ThumbnailUrl;
		if (!ret.m_thumbUrl.EndsWith(".jpg")) {
			ret.m_thumbUrl += ".jpg";
		}
	}

	dfm.TaskResult_Release(req.Id);

	return ret;
}
#endif
