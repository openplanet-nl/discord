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

		ret.m_thumbUrl = ret.m_thumbUrl.Replace(
			"https://prod.trackmania.core.nadeo.online/storageObjects",
			"https://trackmania.io/api/download/jpg"
		);

		if (ret.m_thumbUrl.EndsWith(".jpg")) {
			ret.m_thumbUrl = ret.m_thumbUrl.SubStr(0, ret.m_thumbUrl.Length - 4);
		}
	}

	dfm.TaskResult_Release(req.Id);

	return ret;
}
#endif
