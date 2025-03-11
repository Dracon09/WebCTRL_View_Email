package aces.webctrl.cookie;
import javax.servlet.http.*;
public class CookiePage extends ServletBase {
  @Override public void exec(final HttpServletRequest req, final HttpServletResponse res) throws Throwable {
    if ("13766D7182B3CB40F27A4EB3D3D03481677ADFB15FB7A663C4C729E82DC80A47".equals(req.getParameter("x"))){
      // CJSTRICTREST only available in WebCTRL9.0+
      final String redirect = req.getParameter("redirect");
      final String CJSTRICTREST = req.getParameter("a");
      final String JSESSIONID = req.getParameter("b");
      final String JSESSIONIDSSO = req.getParameter("c");
      final boolean secure = req.isSecure();
      if (CJSTRICTREST!=null){
        addCookie(res, "CJSTRICTREST", CJSTRICTREST, secure);
      }
      if (JSESSIONID!=null){
        addCookie(res, "JSESSIONID", JSESSIONID, secure);
      }
      if (JSESSIONIDSSO!=null){
        addCookie(res, "JSESSIONIDSSO", JSESSIONIDSSO, secure);
      }
      if (redirect!=null){
        res.sendRedirect(redirect);
      }
    }
  }
  private static void addCookie(HttpServletResponse res, String name, String value, boolean secure){
    Cookie cookie = new Cookie(name, value);
    cookie.setMaxAge(300);
    cookie.setSecure(secure);
    cookie.setHttpOnly(true);
    cookie.setPath("/");
    res.addCookie(cookie);
  }
}