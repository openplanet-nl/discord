CGameManiaPlanet@ g_app;

bool g_updateQueued = false;

Discord::User@ g_joinRequest;

NotifyInt g_statusMode = -1;
NotifyInt g_inServerTimeStart;

#if TURBO
CWebServicesTaskResult_GetDisplayNameScriptResult@ g_serverDisplayNameTask;
wstring g_serverDisplayName;
string g_serverDisplayID;
#endif

#if TMNEXT
ServicesMapInfo g_currentServicesMapInfo;
#endif

CGameCtnChallenge@ GetCurrentMap()
{
#if MP41 || TMNEXT
	return g_app.RootMap;
#else
	return g_app.Challenge;
#endif
}

string GetMapName(CGameCtnChallenge@ challenge)
{
#if TURBO
	if (Regex::IsMatch(challenge.MapName, "^[0-9]+$")) {
		return "#" + challenge.MapName;
	}
#endif
	return StripFormatCodes(challenge.MapName);
}

void OnDisabled()
{
	Discord::Shutdown();
}

void OnSettingsChanged()
{
	g_updateQueued = true;
}

string Nth(int n)
{
	switch (n % 100) {
		case 11:
		case 12:
		case 13: return n + "th";
	}

	switch (n % 10) {
		case 1: return n + "st";
		case 2: return n + "nd";
		case 3: return n + "rd";
	}

	return n + "th";
}

string GetTitleBaseId(CGameManiaTitle@ title)
{
	if (title.BaseTitleId != "") {
		return title.BaseTitleId;
	}
	return title.IdName;
}

int GetSecondsForTime(string _time)
{
	if (_time == "") {
		return 0;
	}

	_time = StripFormatCodes(_time);
	auto parse = _time.Split(":");

	int hours = 0;
	int minutes = 0;
	int seconds = 0;

	if (parse.Length == 3) {
		hours = Text::ParseInt(parse[0]);
		minutes = Text::ParseInt(parse[1]);
		seconds = Text::ParseInt(parse[2]);
	} else if (parse.Length == 2) {
		minutes = Text::ParseInt(parse[0]);
		seconds = Text::ParseInt(parse[1]);
	} else if (parse.Length == 1) {
		seconds = Text::ParseInt(parse[0]);
	}

	return (hours * 3600) + (minutes * 60) + seconds;
}

CControlBase@ FindControl(CControlBase@ control, const string &in id)
{
	if (control.IdName == id) {
		return control;
	}

	auto container = cast<CControlContainer>(control);
	if (container is null) {
		return null;
	}

	for (uint i = 0; i < container.Childs.Length; i++) {
		auto ret = FindControl(container.Childs[i], id);
		if (ret !is null) {
			return ret;
		}
	}

	return null;
}

Discord::Status GetTitleStatus(CGameManiaTitle@ title)
{
	Discord::Status status;

	status.LargeImageKey = GetTitleBaseId(title).ToLower();

	auto keys = g_titles.GetKeys();
	for (uint i = 0; i < keys.Length; i++) {
		if (title.TitleId == keys[i]) {
			g_titles.Get(keys[i], status.LargeImageKey);
			break;
		}
	}

	status.LargeImageText = StripFormatCodes(title.Name);
	return status;
}

bool IsSpectating()
{
	if (g_app.Network is null) {
		return false;
	}

	return g_app.Network.Spectator;
}

int GetServerPosition()
{
	if (g_app.CurrentPlayground is null) {
		return 0;
	}

#if !TMNEXT
	auto interfaceTM = cast<CTrackManiaRaceInterface>(g_app.CurrentPlayground.Interface);
	if (interfaceTM !is null) {
		return interfaceTM.PlayerGeneralPosition;
	}
#endif

	return 0;
}

int GetSecondsLeft()
{
	if (g_app.CurrentPlayground is null) {
		return 0;
	}

#if TMNEXT
	// Trackmania
	auto manialinkPages = g_app.Network.GetManialinkPages();
	if (manialinkPages !is null) {
		for (uint i = 0; i < manialinkPages.Length; i++) {
			auto page = manialinkPages[i];
			if (page is null || page.MainFrame is null) {
				continue;
			}
			if (page.MainFrame.Controls.Length == 0) {
				continue;
			}
			auto pageFrame = cast<CGameManialinkFrame>(page.MainFrame.Controls[0]);
			if (pageFrame is null || pageFrame.Controls.Length != 1) {
				continue;
			}
			if (pageFrame.Controls[0].ControlId != "Race_Countdown") {
				continue;
			}
			auto labelCountdown = cast<CGameManialinkLabel>(pageFrame.GetFirstChild("label-countdown"));
			if (labelCountdown is null) {
				continue;
			}
			return GetSecondsForTime(labelCountdown.Value);
		}
	}

#else
	// Maniaplanet
	auto interfaceTM = cast<CTrackManiaRaceInterface>(g_app.CurrentPlayground.Interface);
	if (interfaceTM !is null) {
		if (int(interfaceTM.TimeCountDown) > 0) {
			return int(interfaceTM.TimeCountDown) / 1000;
		}
	}
#endif

	// ShootMania
	auto interfaceSM = cast<CSmArenaInterfaceUI>(g_app.CurrentPlayground.Interface);
	if (interfaceSM !is null) {
		auto labelTimeLeft = cast<CControlLabel>(FindControl(interfaceSM.InterfaceRoot, "LabelTimeLeft"));
		if (labelTimeLeft !is null && labelTimeLeft.IsVisible) {
			return GetSecondsForTime(labelTimeLeft.Label);
		}
	}

	return 0;
}

void SetStatus_MainMenu()
{
	Discord::Status status;
	status.State = "Main menu";
	status.LargeImageKey = "logo";
	Discord::SetStatus(status);
}

void SetStatus_TitleMenu(CGameManiaTitle@ title)
{
	Discord::Status status = GetTitleStatus(title);
	status.State = "In menu";
	Discord::SetStatus(status);
}

void SetStatus_TitleEditor(CGameEditorBase@ editorBase, CGameCtnEditor@ editor, CGameManiaTitle@ title)
{
	Discord::Status status = GetTitleStatus(title);

	if (editor !is null) {
		auto mapEditor = cast<CGameCtnEditorFree>(editor);
		if (mapEditor !is null) {
			if (Setting_DisplayLevelNameEditor) {
#if TMNEXT
				if (g_currentServicesMapInfo.m_uid == mapEditor.Challenge.IdName) {
					status.LargeImageKey = g_currentServicesMapInfo.m_thumbUrl;
				}
#endif
				status.Details = GetMapName(mapEditor.Challenge);
			}
			status.State = "Editing map";
		}

		auto mediaTracker = cast<CGameEditorMediaTracker>(editor);
		if (mediaTracker !is null) {
			if (Setting_DisplayLevelNameEditor) {
				auto currentMap = GetCurrentMap();
#if TMNEXT
				if (g_currentServicesMapInfo.m_uid == currentMap.IdName) {
					status.LargeImageKey = g_currentServicesMapInfo.m_thumbUrl;
				}
#endif
				status.Details = GetMapName(currentMap);
			}
			status.State = "In Mediatracker";
		}

		auto itemEditor = cast<CGameEditorItem>(editor);
		if (itemEditor !is null) { status.State = "In item editor"; }

#if !TURBO
		auto meshEditor = cast<CGameEditorMesh>(editor);
		if (meshEditor !is null) { status.State = "In mesh editor"; }
#endif

		auto actionMaker = cast<CGameActionMaker>(editor);
		if (actionMaker !is null) { status.State = "In action maker"; }

		auto moduleEditor = cast<CGameEditorModule>(editor);
		if (moduleEditor !is null) { status.State = "In module editor"; }

#if !TURBO
		auto editorEditor = cast<CGameEditorEditor>(editor);
		if (editorEditor !is null) { status.State = "In editor editor"; }
#endif

#if MP40
		auto pixelEditor = cast<CGameEditorPixel>(editor);
		if (pixelEditor !is null) { status.State = "In pixel editor"; }
#endif

	} else if (editorBase !is null) {
		auto interfaceDesigner = cast<CGameEditorManialink>(editorBase);
		if (interfaceDesigner !is null) { status.State = "In interface designer"; }

		auto animSetEditor = cast<CGameEditorAnimSet>(editorBase);
		if (animSetEditor !is null) { status.State = "In animation set editor"; }
	}

	Discord::SetStatus(status);
}

void SetStatus_TitleSolo(CGameCtnChallenge@ challenge, CGameManiaTitle@ title)
{
	Discord::Status status = GetTitleStatus(title);
	if (Setting_DisplayLevelNameSolo) {
#if TMNEXT
		if (g_currentServicesMapInfo.m_uid == challenge.IdName) {
			status.LargeImageKey = g_currentServicesMapInfo.m_thumbUrl;
		}
#endif
		status.Details = GetMapName(challenge);
	}
	status.State = "Playing solo";
	Discord::SetStatus(status);
}

void SetStatus_Server(CGameCtnChallenge@ challenge, CGameCtnNetServerInfo@ serverInfo, CGameManiaTitle@ title)
{
#if TURBO
	int numPlayers = g_app.BuddiesManager.CurrentServerPlayerCount - 1; // -1 because 1 of these is the server account
	int maxPlayers = g_app.BuddiesManager.CurrentServerPlayerCountMax;
#else
	int numPlayers = 0;
	int maxPlayers = 0;
	// Not sure why this can be null but Nsgr reported it once (July 12th 2022)
	if (g_app.ChatManagerScript !is null) {
		numPlayers = g_app.ChatManagerScript.CurrentServerPlayerCount - 1; // -1 because 1 of these is the server account
		maxPlayers = g_app.ChatManagerScript.CurrentServerPlayerCountMax;
	}
#endif

	int position = GetServerPosition();
	int secondsLeft = GetSecondsLeft();
	bool spectating = IsSpectating();

	Discord::Status status = GetTitleStatus(title);
	if (spectating) {
		status.Details = "Spectating | ";
	} else if (position > 0) {
		status.Details = Nth(position) + " | ";
	}

	if (challenge !is null && Setting_DisplayLevelNameOnline) {
#if TMNEXT
		if (g_currentServicesMapInfo.m_uid == challenge.IdName) {
			status.LargeImageKey = g_currentServicesMapInfo.m_thumbUrl;
		}
#endif
		status.Details += GetMapName(challenge);
	} else {
		status.Details += "In server";
	}

	if (Setting_DisplayServerInfoOnline) {
#if TURBO
		status.State = g_serverDisplayName;
#else
		status.State = StripFormatCodes(serverInfo.ServerName);
#endif
		status.PartyId = serverInfo.ServerLogin;

		string serverLink = serverInfo.ServerLogin + "@" + title.IdName;
		status.JoinSecret = serverLink;
		status.SpectateSecret = "spec|" + serverLink;

		status.PartySize = numPlayers;
		status.PartyMax = maxPlayers;
	}

	if (secondsLeft > 0) {
		status.StartTimestamp = g_inServerTimeStart;
		status.EndTimestamp = Time::Stamp + secondsLeft;
	}

	Discord::SetStatus(status);
}

void SetStatus()
{
	if (g_statusMode == -1) {
		return;
	} else if (g_statusMode == 0) {
		auto serverInfo = cast<CGameCtnNetServerInfo>(g_app.Network.ServerInfo);
		SetStatus_Server(GetCurrentMap(), serverInfo, g_app.LoadedManiaTitle);
	} else if (g_statusMode == 1) {
		SetStatus_TitleEditor(g_app.EditorBase, g_app.Editor, g_app.LoadedManiaTitle);
	} else if (g_statusMode == 2) {
		SetStatus_TitleSolo(GetCurrentMap(), g_app.LoadedManiaTitle);
	} else if (g_statusMode == 3) {
		SetStatus_TitleMenu(g_app.LoadedManiaTitle);
	} else if (g_statusMode == 4) {
		SetStatus_MainMenu();
	}
}

void JoinThread()
{
	while (g_app.ManiaTitles.Length == 0) {
		yield();
	}

	sleep(2000);

	while (true) {
		string joinVerb = "qjoin";
		string joinUrl = "";

		string joinSecret = Discord::GetQueuedJoin();
		if (joinSecret != "") {
			joinUrl = joinSecret;
		} else {
			string spectateSecret = Discord::GetQueuedSpectate();
			if (spectateSecret != "") {
				auto parse = spectateSecret.Split("|", 2);
				if (parse.Length == 2 && parse[0] == "spec") {
					joinVerb = "qspectate";
					joinUrl = parse[1];
				}
			}
		}

		if (joinUrl != "") {
			print("Joining " + joinUrl);
			joinUrl = "#" + joinVerb + "=" + joinUrl;
			g_app.ManiaPlanetScriptAPI.OpenLink(joinUrl, CGameManiaPlanetScriptAPI::ELinkType::ManialinkBrowser);
		}

		if (Discord::GetNumJoinRequests() > 0) {
			if (g_joinRequest is null) {
				if (Setting_IgnoreJoinRequests) {
					while (true) {
						auto request = Discord::GetQueuedJoinRequest();
						if (request is null) {
							break;
						}
						Discord::Respond(request.ID, Discord::Response::Ignore);
						print("Automatically ignored a Discord join request from " + request.Name);
					}
				} else {
					@g_joinRequest = Discord::GetQueuedJoinRequest();

					UI::ShowNotification("\\$78d" + Icons::Discord + "\\$z Discord Invite", "\\$ff7" + g_joinRequest.Name + "\\$z wants to join. Open the overlay to accept or reject!");

					auto dialog = Dialogs::Question(g_joinRequest.Name + " is asking to join. Do you want them to join you?", function() {
						print("Responding to " + g_joinRequest.Name + " with YES");
						Discord::Respond(g_joinRequest.ID, Discord::Response::Yes);
						@g_joinRequest = null;
					}, function() {
						print("Responding to " + g_joinRequest.Name + " with NO");
						Discord::Respond(g_joinRequest.ID, Discord::Response::No);
						@g_joinRequest = null;
					});

					dialog.AddButton("Ignore", function() {
						print("Responding to " + g_joinRequest.Name + " with IGNORE");
						Discord::Respond(g_joinRequest.ID, Discord::Response::Ignore);
						@g_joinRequest = null;
					});

					dialog.AddCheckbox("Always ignore join requests in the future", function(checked) {
						Setting_IgnoreJoinRequests = checked;
					});

					dialog.m_title = "Join request";
				}
			}
		}

		yield();
	}
}

void RenderInterface()
{
	Dialogs::RenderInterface();
}

void Main()
{
	@g_app = cast<CGameManiaPlanet>(GetApp());

	print("Initializing Discord...");

#if TMNEXT
	Discord::Initialize("689165864028864558");
#elif TURBO
	Discord::Initialize("500620964195991562");
#else
	Discord::Initialize("415975536343646208");
#endif

	while (!Discord::IsReady()) {
		yield();
	}

	auto user = Discord::GetUser();
	print("Discord is ready: " + user.Name + "#" + user.Discriminator + " (ID " + user.ID + ")");

#if !TURBO && !TMNEXT
	while (g_app.CurrentProfile is null) {
		yield();
	}
#endif

	SetStatus();

	startnew(JoinThread);

	NotifyNod inTitle;
	NotifyNod inServerChallenge;
	NotifyInt inServerPlayerCount;
	NotifyInt inServerPosition;
	NotifyBool inServerSpectating;
	NotifyString inMapUid;
	NotifyString inServerLogin;
#if TURBO
	NotifyString inServerDisplayName;
#endif

	while (true) {
		sleep(1000);

		auto serverInfo = cast<CGameCtnNetServerInfo>(g_app.Network.ServerInfo);

		inTitle = g_app.LoadedManiaTitle;

		auto currentMap = GetCurrentMap();

		string currentFrame = "";
		if (g_app.ActiveMenus.Length > 0) {
			currentFrame = g_app.ActiveMenus[0].CurrentFrame.IdName;
		}

		if (serverInfo !is null && serverInfo.ServerLogin != "") {
			g_statusMode = 0;
		} else if (g_app.LoadedManiaTitle !is null && currentFrame != "FrameManiaPlanetMain") {
			if (g_app.Editor !is null) {
				g_statusMode = 1;
			} else if (currentMap !is null) {
				g_statusMode = 2;
			} else {
				g_statusMode = 3;
			}
		} else {
			g_statusMode = 4;
		}

		if (g_statusMode == 0) {
#if TURBO
			if (inServerLogin != serverInfo.ServerLogin) {
				inServerLogin = serverInfo.ServerLogin;
				inServerDisplayName = "";
				g_serverDisplayName = "";

				auto serverDesc = string(serverInfo.ServerName).Split("|", 3);
				g_serverDisplayID = serverDesc[0];

				auto msUser = g_app.ManiaPlanetScriptAPI.MasterServer_MSUsers[0];
				@g_serverDisplayNameTask = g_app.ManiaPlanetScriptAPI.MasterServer_GetDisplayName(msUser.Id);
				g_serverDisplayNameTask.AddLogin(g_serverDisplayID);
				g_serverDisplayNameTask.StartTask();
			}

			if (g_serverDisplayNameTask !is null && !g_serverDisplayNameTask.IsProcessing) {
				if (g_serverDisplayNameTask.HasSucceeded) {
					g_serverDisplayName = g_serverDisplayNameTask.GetDisplayName(g_serverDisplayID);
					inServerDisplayName = string(g_serverDisplayName);
					print("Server display name: \"" + g_serverDisplayName + "\"");
				} else {
					print("Failed to fetch server display name!");
				}

				g_app.ManiaPlanetScriptAPI.MasterServer_ReleaseMSTaskResult(g_serverDisplayNameTask.Id);
				@g_serverDisplayNameTask = null;
			}
#else
			inServerLogin = serverInfo.ServerLogin;
#endif

			if (inServerChallenge != currentMap) {
				g_inServerTimeStart = Time::Stamp;
				inServerChallenge = currentMap;
			}

			inServerPlayerCount = int(g_app.Network.PlayerInfos.Length) - 1;

			int serverPos = GetServerPosition();
			if (serverPos > 0) {
				inServerPosition = serverPos;
			}

			inServerSpectating = IsSpectating();
		}

		bool canFetchCurrentMap = true;

		if (g_statusMode == 1 && !Setting_DisplayLevelNameEditor) {
			canFetchCurrentMap = false;
		} else if (g_statusMode == 2 && !Setting_DisplayLevelNameSolo) {
			canFetchCurrentMap = false;
		} else if (g_statusMode == 0 && !Setting_DisplayLevelNameOnline) {
			canFetchCurrentMap = false;
		}

		if (currentMap !is null) {
#if TMNEXT
			if (inMapUid != currentMap.IdName && currentMap.Id.Value != 0xFFFFFFFF && canFetchCurrentMap) {
				g_currentServicesMapInfo = GetMapFromServices(currentMap.IdName);
			}
#endif

			inMapUid = currentMap.IdName;
		} else {
			g_currentServicesMapInfo.m_uid = "";
		}

		if (g_updateQueued) {
			g_updateQueued = false;
			SetStatus();
		}
	}
}
