const menuToggle = document.querySelector(".menu-toggle");
const primaryNav = document.querySelector("#primary-nav");

if (menuToggle && primaryNav) {
  menuToggle.addEventListener("click", () => {
    const isExpanded = menuToggle.getAttribute("aria-expanded") === "true";
    menuToggle.setAttribute("aria-expanded", String(!isExpanded));
    menuToggle.setAttribute("aria-label", isExpanded ? "Open navigation" : "Close navigation");
    primaryNav.classList.toggle("is-open", !isExpanded);
  });

  primaryNav.addEventListener("click", (event) => {
    if (event.target instanceof HTMLAnchorElement) {
      menuToggle.setAttribute("aria-expanded", "false");
      menuToggle.setAttribute("aria-label", "Open navigation");
      primaryNav.classList.remove("is-open");
    }
  });
}

const year = document.querySelector("#current-year");
if (year) year.textContent = String(new Date().getFullYear());

const scrollProgress = document.querySelector(".scroll-progress span");
if (scrollProgress) {
  let scrollFrame = null;
  const updateScrollProgress = () => {
    const scrollableHeight = document.documentElement.scrollHeight - window.innerHeight;
    const progress = scrollableHeight > 0 ? Math.min(window.scrollY / scrollableHeight, 1) : 0;
    scrollProgress.style.transform = `scaleX(${progress})`;
    scrollFrame = null;
  };
  const scheduleScrollProgress = () => {
    if (scrollFrame !== null) return;
    scrollFrame = window.requestAnimationFrame(updateScrollProgress);
  };

  window.addEventListener("scroll", scheduleScrollProgress, { passive: true });
  window.addEventListener("resize", scheduleScrollProgress, { passive: true });
  updateScrollProgress();
}

const revealItems = document.querySelectorAll(".motion-reveal");
if ("IntersectionObserver" in window && !window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
  document.documentElement.classList.add("has-motion");
  const revealObserver = new IntersectionObserver((entries, observer) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.18 });

  revealItems.forEach((item) => revealObserver.observe(item));
}

const motionStage = document.querySelector(".motion-stage");
const motionObject = document.querySelector(".motion-object");
const canTiltMotion = window.matchMedia("(hover: hover) and (pointer: fine)");
const prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

if (motionStage && motionObject && canTiltMotion.matches && !prefersReducedMotion.matches) {
  motionStage.addEventListener("pointermove", (event) => {
    const bounds = motionStage.getBoundingClientRect();
    const x = (event.clientX - bounds.left) / bounds.width - 0.5;
    const y = (event.clientY - bounds.top) / bounds.height - 0.5;
    motionObject.style.setProperty("--motion-y", `${x * 12 - 6}deg`);
    motionObject.style.setProperty("--motion-x", `${y * -10 + 3}deg`);
  });

  motionStage.addEventListener("pointerleave", () => {
    motionObject.style.removeProperty("--motion-x");
    motionObject.style.removeProperty("--motion-y");
  });
}
