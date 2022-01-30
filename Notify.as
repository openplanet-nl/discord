class NotifyNod
{
	private CMwNod@ m_value;

	NotifyNod() { @m_value = null; }
	NotifyNod(CMwNod@ value) { @m_value = value; }

	CMwNod@ opImplConv() const { return m_value; }

	bool opEquals(const CMwNod@ value) const { return m_value is value; }

	NotifyNod@ opAssign(CMwNod@ value)
	{
		if (m_value !is value) {
			@m_value = value;
			g_updateQueued = true;
		}
		return this;
	}
}

class NotifyInt
{
	private int64 m_value;

	NotifyInt() { m_value = 0; }
	NotifyInt(int64 value) { m_value = value; }

	int64 opImplConv() const { return m_value; }

	NotifyInt@ opAssign(int64 value)
	{
		if (m_value != value) {
			m_value = value;
			g_updateQueued = true;
		}
		return this;
	}
}

class NotifyBool
{
	private bool m_value;

	NotifyBool() { m_value = false; }
	NotifyBool(bool value) { m_value = value; }

	bool opImplConv() const { return m_value; }

	NotifyBool@ opAssign(bool value)
	{
		if (m_value != value) {
			m_value = value;
			g_updateQueued = true;
		}
		return this;
	}
}

class NotifyString
{
	private string m_value;

	NotifyString() { m_value = ""; }
	NotifyString(string value) { m_value = value; }

	string opImplConv() const { return m_value; }

	NotifyString@ opAssign(string value)
	{
		if (m_value != value) {
			m_value = value;
			g_updateQueued = true;
		}
		return this;
	}
}
